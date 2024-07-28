//
//  UsersManager.swift
//  SearchUser
//
//  Created by Bhavisha Jethwa on 7/28/24.
//

import Foundation

class UsersManager {
    var users = [User]()
    
    @MainActor
    func update(users: [User]) {
        self.users = users
    }
    
    func fetchUsers(with term:String) async {
        guard var urlComponents = URLComponents(string: UsersManager.baseURLString) else { return }
        let queryItemQuery = URLQueryItem(name: "query", value: term)
        urlComponents.queryItems = [queryItemQuery]
        
        guard let url = urlComponents.url else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            usersReceived(results: apiResponse.users, for: term)
        } catch {
            print("API call failed: \(error.localizedDescription)")
            fetchFailed(with:error)
        }
    }
    
    private func usersReceived(results: [User], for term: String) {
        self.users = results
    }
    
    private func fetchFailed(with error: Error) {
        
    }
    
    struct APIResponse: Codable {
        let ok: Bool
        let users: [User]
    }
    
    private static let baseURLString = "https://mobile-code-exercise-a7fb88c7afa6.herokuapp.com/search"
}


