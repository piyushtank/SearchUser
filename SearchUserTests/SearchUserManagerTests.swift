//
//  SearchUserManagerTests.swift
//  SearchUserTests
//

import XCTest
@testable import SearchUser

class SearchUserManagerTests: XCTestCase {
    
    var searchUserManager: SearchUserManager!
        var mockSlackAPI: MockSlackAPI!
        var mockStorageManager: MockStorageManager!
        var mockCacheManager: MockCacheManager!
        var testData: TestData!
        
        override func setUp() {
            super.setUp()
            testData = TestData()
            mockSlackAPI = MockSlackAPI()
            mockStorageManager = MockStorageManager()
            mockCacheManager = MockCacheManager()
            searchUserManager = SearchUserManager(apiService: mockSlackAPI,
                                                  storageManager: mockStorageManager,
                                                  cacheManager: mockCacheManager)
        }
        
        override func tearDown() {
            mockSlackAPI = nil
            mockStorageManager = nil
            mockCacheManager = nil
            searchUserManager = nil
            testData = nil
            super.tearDown()
        }
    
    struct TestData {
        
        // Ideally all elements should be meeting the size requirements
        // and have random factor injected while creating them
        
        let theImage = TestData.createJPEGImage() ?? UIImage()
        let theId: Int = Int.random(in: 0...1000)
        let theDisplayName = "John\(Int.random(in: 0...1000)) Doe"
        let theUserName = "jdoe\(Int.random(in: 0...1000))"
        let theUrlStr = "https://example.com/avatar.jpg"
        let theTerm = "a"
        
        static func createJPEGImage() -> UIImage? {
            // Create a simple image
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100))
            let image = renderer.image { context in
                UIColor.red.setFill()
                context.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
            }
            
            // Convert the image to JPEG data
            guard let jpegData = image.jpegData(compressionQuality: 1.0) else {
                return nil
            }
            
            // Create a UIImage from JPEG data
            return UIImage(data: jpegData)
        }
    }
    
    func testSearchUsers_whenTermIsInDenylist() async {
        searchUserManager.setDenylist(["d"])
        await searchUserManager.searchUsers(with: "d")
        
        XCTAssertEqual(searchUserManager.users.count, 0)
    }
    
    func testSearchUsers_whenTermIsCached() async {
        let expectation = self.expectation(description: "testSearchUsers_whenTermIsCached")

        let theImage = UIImage()
        let theId: Int = Int.random(in: 0...1000)
        let theDisplayName = "John\(Int.random(in: 0...1000)) Doe"
        let theUserName = "jdoe\(Int.random(in: 0...1000))"
        let theUrlStr = "https://example.com/avatar.jpg"
        let theTerm = "a" // this should be random as well
        
        let user = User(id: theId, displayName: theDisplayName, username: theUserName, avatarURL: theUrlStr)

        mockCacheManager.update([user], for: theTerm)
        mockCacheManager.update(theImage, for: theId)
        
        Task {
            await searchUserManager.searchUsers(with: theTerm)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5)
        
        XCTAssertEqual(searchUserManager.users.count, 1)
        XCTAssertEqual(searchUserManager.users.first?.user.displayName, theDisplayName)
        XCTAssertEqual(searchUserManager.users.first?.user.username, theUserName)
        XCTAssertEqual(searchUserManager.users.first?.user.avatarURL, theUrlStr)
        XCTAssertEqual(searchUserManager.users.first?.avatar.uiImage, theImage)
    }
    
    func testSearchUsers_whenFetchingFromAPI() async {
        let expectation = self.expectation(description: "testSearchUsers_whenFetchingFromAPI")

        let user = User(id: testData.theId,
                        displayName: testData.theDisplayName,
                        username: testData.theUserName,
                        avatarURL: testData.theUrlStr)
        mockSlackAPI.fetchUsersResult = .success(([user], testData.theTerm))
                
        Task {
            await searchUserManager.searchUsers(with: testData.theTerm)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5)
        
        XCTAssertEqual(searchUserManager.users.count, 1)
        XCTAssertEqual(searchUserManager.users.first?.user.displayName, testData.theDisplayName)
        XCTAssertEqual(searchUserManager.users.first?.user.username, testData.theUserName)
        XCTAssertEqual(searchUserManager.users.first?.user.avatarURL, testData.theUrlStr)
        XCTAssertTrue(mockStorageManager.mockTermsAndUserIds.keys.contains(testData.theTerm))
    }
    
    func testSearchUsers_whenAPIFailsDueToNoInternet() async {
        let expectation = self.expectation(description: "testSearchUsers_whenAPIFailsDueToNoInternet")

        let user = User(id: testData.theId,
                        displayName: testData.theDisplayName,
                        username: testData.theUserName,
                        avatarURL: testData.theUrlStr)
        
        mockStorageManager.saveUsers([user], for: testData.theTerm)
        mockStorageManager.saveAvatar(testData.theImage, for: testData.theId)
        
        mockSlackAPI.fetchUsersResult = .failure(URLError(.notConnectedToInternet))
        
        Task {
            await searchUserManager.searchUsers(with: testData.theTerm)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5)
                
        XCTAssertEqual(searchUserManager.users.count, 1)
        XCTAssertEqual(searchUserManager.users.first?.user.displayName, testData.theDisplayName)
        XCTAssertEqual(searchUserManager.users.first?.user.username, testData.theUserName)
        XCTAssertEqual(searchUserManager.users.first?.user.avatarURL, testData.theUrlStr)
        
        // since encoding and deconing may change bytes, we will verify the size only
        XCTAssertEqual(searchUserManager.users.first?.avatar.uiImage?.size, testData.theImage.size)
    }
}
