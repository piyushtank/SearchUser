//
//  SearchUserManager.swift
//  SearchUserManager
//

import Foundation
import Combine
import UIKit

class SearchUserManager: ObservableObject {
    
    @Published private(set) var users: [SearchUserResult] = []
    private var denylist: Set<String> = []
    private var apiService: SlackAPI = SlackAPI()

    init() {
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

        await apiService.fetchUsers(with: term) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let (usersList, term)):
                Task { @MainActor in
                    self.updateUsers(with: usersList, for: term)
                    await self.fetchAvatarImages()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func fetchAvatarImages() async {
        for result in users {
            await result.fetchAvatarImage()
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
    
    private func fetchFailed(with error: Error) {
        print("Fetch failed: \(error)")
    }
}


