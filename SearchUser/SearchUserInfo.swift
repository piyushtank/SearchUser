//
//  SearchUserInfo.swift
//  SearchUser
//

import Foundation

class SearchUserInfo: ObservableObject {
    @Published var searchText: String = ""
    
    private static func createUsersManager() -> UsersManager {
        return UsersManager()
    }
    
    @Published private var usersManager = createUsersManager()
}
