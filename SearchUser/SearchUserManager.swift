//
//  SearchUserManager.swift
//  SearchUserManager
//

import Foundation
import Combine

class SearchUserManager: ObservableObject {
    
    @Published private(set) var users: [User] = []
    private var denylist: Set<String> = []

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
    
    func fetchUsers(with term: String) async {
        
        if denylist.contains(where: { term.starts(with: $0) }) {
            print("Term is in denylist, skipping API call")
            await updateUsers(with: [])
            return
        }
        
        guard var urlComponents = URLComponents(string: SearchUserManager.baseURLString) else { return }
        let queryItemQuery = URLQueryItem(name: "query", value: term)
        urlComponents.queryItems = [queryItemQuery]
        
        guard let url = urlComponents.url else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            await updateUsers(with: apiResponse.users, for: term)
        } catch {
            print("API call failed: \(error.localizedDescription)")
            fetchFailed(with: error)
        }
    }
    
    @MainActor
    private func updateUsers(with users: [User], for term: String) {
        if users.isEmpty {
            // Upadate denylist if no user found for the termaf
        }
        updateUsers(with:users)
    }
    
    @MainActor
    private func updateUsers(with users: [User]) {
        self.users = users
    }
    
    private func fetchFailed(with error: Error) {
        print("Fetch failed: \(error)")
    }
    
    struct APIResponse: Codable {
        let ok: Bool
        let users: [User]
    }
    
    private static let baseURLString = "https://mobile-code-exercise-a7fb88c7afa6.herokuapp.com/search"
}


