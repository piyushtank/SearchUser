//
//  SearchUserManager.swift
//  SearchUserManager
//

import Foundation
import Combine
import UIKit

class SearchUserManager: ObservableObject {
    
    @Published private(set) var users: [SearchUserResult] = []
    private(set) var denylist: Set<String> = []
    private let apiService: SlackAPIInterface
    private let storageManager: StorageManagerInterface
    private var cacheManager: CacheManagerInterface

    init(apiService: SlackAPIInterface = SlackAPI(),
         storageManager: StorageManagerInterface = StorageManager(),
         cacheManager: CacheManagerInterface = CacheManager()) {
        self.apiService = apiService
        self.storageManager = storageManager
        self.cacheManager = cacheManager
        loadDenylist()
    }

    private func loadDenylist() {
        if let path = Bundle.main.path(forResource: "denylist", ofType: "txt") {
            do {
                let content = try String(contentsOfFile: path, encoding: .utf8)
                let terms = content.split(separator: "\n")
                denylist = Set(terms.map { String($0) })
            } catch {
                print("Error loading denylist: \(error)")
            }
        }
    }
    
    func searchUsers(with term: String) async {
        
        if denylist.contains(where: { term.starts(with: $0) }) {
            print("Term is in denylist, skipping API call")
            await updateUsers(with: [])
            return
        }
        
        if let users = cacheManager.searchUserResults(for: term) {
            print("Term is in cache, skipping API call")
            Task {
                await updateUserResults(with: users)
            }
            return
        }

        await apiService.fetchUsers(with: term) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let (usersList, term)):
                cacheManager.update(usersList, for: term)
                storageManager.saveUsers(usersList, for: term)
                
                if usersList.isEmpty {
                    denylist.insert(term)
                    
                    // TODO: Should we update the disk with denylist?
                    // We can either use UserDefaults or update the file. I have chosen
                    // not updating either, as admin might add new users to the backend.
                    
                } else {
                    Task { @MainActor in
                        self.updateUsers(with: usersList, for: term)
                        await self.fetchAvatarImages()
                    }
                }
            case .failure(let error):
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        print("No internet connection. Please check your network settings.")
                        Task {
                            await self.loadStoredUsers(for: term)
                        }
                    case .timedOut:
                        print("The request timed out. Please try again.")
                        Task {
                            await self.loadStoredUsers(for: term)
                        }
                    case .cannotFindHost, .cannotConnectToHost:
                        print("Cannot connect to the server. Please check your server settings.")
                    default:
                        print("An unknown network error occurred: \(urlError.localizedDescription)")
                    }
                } else {
                    print("An unknown error occurred: \(error.localizedDescription)")
                }
            }
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
            await self.updateUserResults(with: theUsers)
        }
    }
    
    func fetchAvatarImages() async {
        for result in users {
            await result.fetchAvatarImage() { [weak self] id, image in
                if let self = self {
                    self.storageManager.saveAvatar(image, for: id)
                    self.cacheManager.update(image, for: id)
                }
            }
        }
    }
    
    @MainActor private func updateUsers(with users: [User], for term: String) {
        if users.isEmpty {
            // Upadate denylist if no user found for the termaf
        }
        updateUsers(with:users)
    }
    
    @MainActor private func updateUsers(with users: [User]) {
        self.users = users.map { SearchUserResult(user: $0) }
    }
    
    @MainActor private func updateUserResults(with users: [SearchUserResult]) {
        self.users = users
    }
    
    private func fetchFailed(with error: Error) {
        print("Fetch failed: \(error)")
    }
    
    // Used for tests
    func setDenylist(_ denylist: Set<String>) {
        self.denylist = denylist
    }
}
