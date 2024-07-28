//
//  UsersManager.swift
//  SearchUser
//

import Foundation
import Combine

class UsersManager: ObservableObject {
    
    @Published private(set) var users: [User] = []
    
    func fetchUsers(with term: String) async {
        guard var urlComponents = URLComponents(string: UsersManager.baseURLString) else { return }
        let queryItemQuery = URLQueryItem(name: "query", value: term)
        urlComponents.queryItems = [queryItemQuery]
        
        guard let url = urlComponents.url else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            await usersReceived(results: apiResponse.users, for: term)
        } catch {
            print("API call failed: \(error.localizedDescription)")
            fetchFailed(with: error)
        }
    }
    
    @MainActor
    private func usersReceived(results: [User], for term: String) {
        self.users = results
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


