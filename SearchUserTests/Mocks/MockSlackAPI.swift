//
//  MockSlackAPI.swift
//  SearchUserTests
//

import Foundation

import Foundation

@testable import SearchUser

class MockSlackAPI: SlackAPIInterface {
    var fetchUsersResult: Result<([User], String), Error>?
    
    func fetchUsers(with term: String,
                             completion: @escaping (Result<([User], String), Error>) -> Void) async {
        if let result = fetchUsersResult {
            completion(result)
        }
    }
}
