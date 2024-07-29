//
//  SlackAPIService.swift
//  SearchUser
//
//  Created by Bhavisha Jethwa on 7/28/24.
//

import Foundation

class SlackAPI {
    
    private(set) var users: [SearchUserResult] = []

    func fetchUsers(with term: String, 
                    completion: @escaping (Result<([SearchUserResult], String), Error>) -> Void) async {

        guard var urlComponents = URLComponents(string: SlackAPI.baseURLString) else { return }
        let queryItemQuery = URLQueryItem(name: "query", value: term)
        urlComponents.queryItems = [queryItemQuery]
        
        guard let url = urlComponents.url else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            
            // Return the users and term via completion handler
            completion(.success((apiResponse.users, term)))
            
        } catch {
            print("API call failed: \(error.localizedDescription)")
            
            // Return the error via completion handler
            completion(.failure(error))
        }
    }
    
    struct APIResponse: Codable {
        let ok: Bool
        let users: [SearchUserResult]
    }
    
    private static let baseURLString = "https://mobile-code-exercise-a7fb88c7afa6.herokuapp.com/search"

}
