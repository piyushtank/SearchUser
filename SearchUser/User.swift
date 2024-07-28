//
//  User.swift
//  SearchUser
//

import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let displayName: String
    let username: String
    let avatarURL: String
}
