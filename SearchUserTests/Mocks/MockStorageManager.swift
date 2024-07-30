//
//  MockStorageManager.swift
//  SearchUserTests
//

import UIKit

@testable import SearchUser

class MockStorageManager: StorageManagerInterface {
    var mockUsers: [String: Data] = [:]
    var mockAvatars: [String: Data] = [:]
    var mockTermsAndUserIds: [String: [String]] = [:]

    func saveUsers(_ users: [User], for term: String) {
        for user in users {
            if let data = try? JSONEncoder().encode(user) {
                mockUsers["\(user.id)"] = data
            }
        }
        mockTermsAndUserIds[term] = users.map { "\($0.id)" }
    }
    
    func saveAvatar(_ image: UIImage, for id: Int) {
        if let data = image.jpegData(compressionQuality: 1.0) {
            mockAvatars["\(id)"] = data
        }
    }
    
    var users: [String: SearchUserResult] {
        var results = [String: SearchUserResult]()
        for (id, data) in mockUsers {
            if let user = try? JSONDecoder().decode(User.self, from: data),
               let imageData = mockAvatars[id], let image = UIImage(data: imageData) {
                results[id] = SearchUserResult(user: user, image: image)
            }
        }
        return results
    }
    
    var termsAndUserIds: [String: [String]] {
        return mockTermsAndUserIds
    }
}

