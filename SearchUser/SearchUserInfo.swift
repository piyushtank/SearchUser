//
//  SearchUserInfo.swift
//  SearchUser
//

import Foundation
import Combine

class SearchUserInfo: ObservableObject {
    @Published var searchText: String = ""
    
    private var searchTask: AnyCancellable?
    
    init() {
        setUpSearch()
    }

    
    private static func createUsersManager() -> UsersManager {
        return UsersManager()
    }
    
    @Published private var usersManager = createUsersManager()
    
    var users: Array<User> {
        return usersManager.users
    }
    
    private func setUpSearch() {
        searchTask = $searchText
            .sink { [weak self] term in
                guard let self = self else { return }
                
                Task {
                    await self.searchUsers(with: term)
                }
            }
    }
    
    private func searchUsers(with term: String) async {
        guard !term.isEmpty else { return }
        
        await self.usersManager.fetchUsers(with: term)
    }
}
