//
//  SearchUserInfo.swift
//  SearchUser
//

import SwiftUI
import Combine
import Foundation

class SearchUserInfo: ObservableObject {
    @Published var searchText: String = ""
    @Published private(set) var users: [SearchUserResult] = []
    @Published private var manager: SearchUserManager
    
    private var searchCache: [String: [SearchUserResult]] = [:]
    private var cancellables: Set<AnyCancellable> = []
    
    init(searchUserManager: SearchUserManager = SearchUserManager()) {
        self.manager = searchUserManager
        observeManager()
        setupSearch()
    }

    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] term in
                guard let self = self else { return }
                Task {
                    await self.searchUsers(with: term)
                }
            }
            .store(in: &cancellables)
    }
    
    private func searchUsers(with term: String) async {
        guard !term.isEmpty else { return }
        
        if let cachedResults = searchCache[term] {
            await updateUsers(with: cachedResults)
            return
        }
        
        await manager.fetchUsers(with: term)
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
