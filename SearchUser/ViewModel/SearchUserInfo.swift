//
//  SearchUserInfo.swift
//  SearchUser
//

import SwiftUI
import Combine
import Foundation

/**
 * The View Model.
 * Interacts with SwiftUI Views and Manager.
 */
class SearchUserInfo: ObservableObject {
    // Binded property with SwiftUI's search text view
    @Published var searchText: String = ""
    
    @Published private(set) var users: [SearchUserResult] = []
    @Published private var manager: SearchUserManager
    
    private var cancellables: Set<AnyCancellable> = []
    private static var debounceInterval = 300 // MilliSeconds, read from a const config?
    
    init(searchUserManager: SearchUserManager = SearchUserManager()) {
        self.manager = searchUserManager
        observeManager()
        setupSearch()
    }
    
    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(SearchUserInfo.debounceInterval), 
                      scheduler: RunLoop.main)
            .sink { [weak self] term in
                guard let self = self else { return }
                Task {
                    await self.manager.searchUsers(with: term)
                }
            }
            .store(in: &cancellables)
    }
    
    private func observeManager() {
        manager.$users
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                self?.users = users
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func updateUsers(with users: [SearchUserResult]) {
        self.users = users
    }
}
