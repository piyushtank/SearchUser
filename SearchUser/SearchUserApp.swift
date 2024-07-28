//
//  SearchUserApp.swift
//  SearchUser
//

import SwiftUI

@main
struct SearchUserApp: App {
    
    @StateObject var searchUserInfo = SearchUserInfo()
    
    var body: some Scene {
        WindowGroup {
            SearchUserView(searchUserInfo: searchUserInfo)
        }
    }
}
