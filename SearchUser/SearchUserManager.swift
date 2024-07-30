//
//  SearchUserManager.swift
//  SearchUserManager
//

import Foundation
import Combine
import UIKit

/**
 * SearchUserManager is the central component  - interacts with ViewModel and SlackAPI
 * The SearchUserManager manages:
 * 1. User search result list
 * 2. Cache for optimization
 * 3. Storage for offline mode
 * 4. Deny list
 */
class SearchUserManager: ObservableObject {
    
    /// This property is observed by ViewModel to update the SwiftUI
    ///  Note: The property is always updated and accessed on thread
    @Published private(set) var users: [SearchUserResult] = []
    
    private let apiService: SlackAPIInterface
    private let storageManager: StorageManagerInterface
    private var cacheManager: CacheManagerInterface
    
    /// Actors to manage denyList and the cache's concurrency
    private var denylistActor = DenylistActor()
    private let cacheManagerActor: CacheManagerActor

    init(apiService: SlackAPIInterface = SlackAPI(),
         storageManager: StorageManagerInterface = StorageManager(),
         cacheManager: CacheManagerInterface = CacheManager()) {
        
        self.apiService = apiService
        self.storageManager = storageManager
        self.cacheManager = cacheManager
        self.cacheManagerActor = CacheManagerActor(cacheManager: cacheManager)
        
        loadDenylist()
    }

    private func loadDenylist() {
        if let path = Bundle.main.path(forResource: "denylist", ofType: "txt") {
            do {
                let content = try String(contentsOfFile: path, encoding: .utf8)
                let terms = content.split(separator: "\n")
                Task {
                    await denylistActor.updateDenylist(with: Set(terms.map { String($0) }))
                }
            } catch {
                print("Error loading denylist: \(error)")
            }
        }
    }
    
    func searchUsers(with term: String) async {
        // Early exit if the search term is empty
        guard !term.isEmpty else {
            await updateUsers([])
            return
        }
        
        // Check if the term is in the denylist
        if await isTermInDenylist(term) {
            print("Term is in denylist, skipping API call")
            await updateUsers([])
            return
        }
        
        // Check if the term's results are cached
        if let cachedUsers = await getCachedUsers(for: term) {
            print("Term is in cache, skipping API call")
            await updateUsers(cachedUsers)
            return
        }
        
        // Fetch users from the SlackAPI
        await fetchUsersFromAPI(with: term)
    }
    
    // Helper method to check if a term is in the denylist
    private func isTermInDenylist(_ term: String) async -> Bool {
        return await denylistActor.contains(term: term)
    }
    
    // Helper method to get cached users
    private func getCachedUsers(for term: String) async -> [SearchUserResult]? {
        return await cacheManagerActor.searchUserResults(for: term)
    }
    
    // Helper method to fetch users from the API
    private func fetchUsersFromAPI(with term: String) async {
        await apiService.fetchUsers(with: term) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let (usersList, term)):
                Task { await self.handleAPISuccess(usersList, for: term) }
            case .failure(let error):
                self.handleAPIFailure(error, for: term)
            }
        }
    }
    
    // This thread is called on a background thread
    private func handleAPISuccess(_ usersList: [User], for term: String) async {
        await cacheManagerActor.update(users: usersList, for: term)
        storageManager.saveUsers(usersList, for: term)
        
        if usersList.isEmpty {
            await denylistActor.add(term)

            // TODO: Should we update the disk with denylist?
            // We can either use UserDefaults or update the file. I have chosen
            // not updating either, as admin might add new users to the backend.
            
        } else {
            Task {
                let users = usersList.map { SearchUserResult(user: $0) }
                await updateUsers(users)
                await fetchAvatarImages(for: users)
            }
        }
    }
    
    // Handle API failure
    private func handleAPIFailure(_ error: Error, for term: String) {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                print("No internet connection. Please check your network settings.")
                Task { await loadStoredUsers(for: term) }
            case .timedOut:
                print("The request timed out. Please try again.")
                Task { await loadStoredUsers(for: term) }
            case .cannotFindHost, .cannotConnectToHost:
                print("Cannot connect to the server. Please check your server settings.")
            default:
                print("An unknown network error occurred: \(urlError.localizedDescription)")
            }
        } else {
            print("An unknown error occurred: \(error.localizedDescription)")
        }
    }
    
    func loadStoredUsers(for term: String) async {
        print("Using storage to show results")

        let storedUsers = storageManager.users
        let storedTermsAndUserIds = storageManager.termsAndUserIds
        if let userIds = storedTermsAndUserIds[term] {
            var theUsers = [SearchUserResult]()
            for userId in userIds {
                if let user = storedUsers[userId] {
                    theUsers.append(user)
                }
            }
            await self.updateUsers(theUsers)
        }
    }
    
    func fetchAvatarImages(for theUsers: [SearchUserResult]) async {
        for result in theUsers {
            let (id, image) = await result.fetchAvatarImage()
            if let image = image {
                self.storageManager.saveAvatar(image, for: id)
                await self.cacheManagerActor.update(image: image, for: id)
            }
        }
    }
    
    private func updateUsers(_ users: [SearchUserResult]) async {
        DispatchQueue.main.async {
            self.users = users
        }
    }
    
    private func fetchFailed(with error: Error) {
        print("Fetch failed: \(error)")
    }
    
    // Used for tests
    func setDenylist(_ denylist: Set<String>) {
        Task {
            await self.denylistActor.updateDenylist(with: denylist)
        }
    }
}

// Actor for managing the denylist
actor DenylistActor {
    private(set) var denylist: Set<String> = []
    
    func updateDenylist(with list: Set<String>) {
        denylist = list
    }
    
    func add(_ term: String) {
        denylist.insert(term)
    }
    
    func contains(term: String) -> Bool {
        return denylist.contains(where: { term.starts(with: $0) })
    }
}

// Actor for managing the cache
actor CacheManagerActor {
    private var cacheManager: CacheManagerInterface
    
    init(cacheManager: CacheManagerInterface) {
        self.cacheManager = cacheManager
    }
    
    func update(users: [User], for term: String) {
        cacheManager.update(users, for: term)
    }
    
    func update(image: UIImage, for id: Int) {
        cacheManager.update(image, for: id)
    }
    
    func searchUserResults(for term: String) -> [SearchUserResult]? {
        return cacheManager.searchUserResults(for: term)
    }
}

