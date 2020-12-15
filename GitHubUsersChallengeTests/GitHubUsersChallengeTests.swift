//
//  GitHubUsersChallengeTests.swift
//  GitHubUsersChallengeTests
//
//  Created by Francis Martin Fuerte on 12/15/20.
//  Copyright © 2020 Fuerte Francis. All rights reserved.
//

import XCTest
@testable import GitHubUsersChallenge
import CoreData

class GitHubUsersChallengeTests: XCTestCase {
    
    var sut: CoreDataStore!
    

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = CoreDataStore(.inMemory)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExampleInsert() throws {
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let sampleJSON = "[{\"login\": \"mojombo\",\"id\": 1,\"node_id\": \"MDQ6VXNlcjE=\",\"avatar_url\": \"https://avatars0.githubusercontent.com/u/1?v=4\",\"gravatar_id\": \"\",\"url\": \"https://api.github.com/users/mojombo\",\"html_url\": \"https://github.com/mojombo\",\"followers_url\": \"https://api.github.com/users/mojombo/followers\",\"following_url\": \"https://api.github.com/users/mojombo/following{/other_user}\",\"gists_url\": \"https://api.github.com/users/mojombo/gists{/gist_id}\",\"starred_url\": \"https://api.github.com/users/mojombo/starred{/owner}{/repo}\",\"subscriptions_url\": \"https://api.github.com/users/mojombo/subscriptions\",\"organizations_url\": \"https://api.github.com/users/mojombo/orgs\",\"repos_url\": \"https://api.github.com/users/mojombo/repos\",\"events_url\": \"https://api.github.com/users/mojombo/events{/privacy}\",\"received_events_url\": \"https://api.github.com/users/mojombo/received_events\",\"type\": \"User\",\"site_admin\": false}]".data(using: .utf8)
        
        // Attempt to parse the JSON
        let decoder = JSONDecoder()
        
        do {
         // Assign the NSManagedObject Context to the decoder
            decoder.userInfo[CodingUserInfoKey.context!] = self.sut.persistentContainer.viewContext
         
        
            let DecodedUser = try decoder.decode([UsersList].self, from: sampleJSON!)
         
            
            XCTAssertNotNil(DecodedUser)
            
            
         
        
        do {
            try self.sut.persistentContainer.viewContext.save()
        } catch{
            print(error.localizedDescription)
            XCTFail()
        }
            
        }catch{
            print("error: " + error.localizedDescription)
            XCTFail()
        }
    }
    
    func testExampleLoad(){
        let request: NSFetchRequest<UsersList> = UsersList.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sort]
            do {
                   // fetch is performed on the NSManagedObjectContext
                let data = try sut.persistentContainer.viewContext.fetch(request)
                   
                XCTAssertNotNil(data)
                   
               } catch {
                   print("Fetch failed")
                    XCTFail()
               }
    }
    
    func testExampleUpdate(){
        
        do{
            try testExampleInsert()
        }catch{
            print("failed insert")
            XCTFail()
        }
        
        let request: NSFetchRequest<UsersList> = UsersList.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sort]
            do {
                   // fetch is performed on the NSManagedObjectContext
                let data = try sut.persistentContainer.viewContext.fetch(request)
                   
                XCTAssertNotNil(data)
                
                XCTAssertEqual(data[0].login, "mojombo")
                
                data[0].login = "Test Update"
                
                do {
                    try self.sut.persistentContainer.viewContext.save()
                } catch{
                    print(error.localizedDescription)
                    XCTFail()
                }
                          
                
                   
               } catch {
                   print("Fetch failed")
                    XCTFail()
               }
    }
    
    
    
    


}
