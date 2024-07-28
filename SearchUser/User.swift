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
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case username
        case avatarURL = "avatar_url"
    }
}
