//
//  SearchUserInfo.swift
//  SearchUser
//

import SwiftUI
import Combine
import Foundation

class SearchUserInfo: ObservableObject {
    @Published var searchText: String = ""
    @Published private(set) var users: [User] = []
    @Published private var usersManager: UsersManager
    
    private var denylist: Set<String> = []
    private var searchCache: [String: [User]] = [:]
    private var cancellables: Set<AnyCancellable> = []
    
    init(usersManager: UsersManager = UsersManager()) {
        self.usersManager = usersManager
        loadDenylist()
        setupSearch()
        observeUsersManager()
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
        
        if denylist.contains(where: { term.starts(with: $0) }) {
            print("Term is in denylist, skipping API call")
            await updateUsers(with: [])
            return
        }
        
        if let cachedResults = searchCache[term] {
            await updateUsers(with: cachedResults)
            return
        }
        
        await usersManager.fetchUsers(with: term)
    }
    
    private func observeUsersManager() {
        usersManager.$users
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                self?.users = users
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func updateUsers(with users: [User]) {
        self.users = users
    }
}
