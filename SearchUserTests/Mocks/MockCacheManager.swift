//
//  MockCacheManager.swift
//  SearchUserTests
//

import UIKit

@testable import SearchUser

class MockCacheManager: CacheManagerInterface {
    private var cache = CacheManager.Cache(users: [String : User](),
                                           images: [String : UIImage](),
                                           termsAndUserIds: [String : [String]]())
    
    func update(_ users: [User], for term: String) {
        cache.update(users, for: term)
    }
    
    func update(_ image: UIImage, for id: Int) {
        cache.update(image, for: id)
    }
    
    func searchUserResults(for term: String) -> [SearchUserResult]? {
        return cache.searchUserResults(for: term)
    }
}
