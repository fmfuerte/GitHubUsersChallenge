//
//  UsersList+CoreDataClass.swift
//  GitHubUsersChallenge
//
//  Created by Francis Martin Fuerte on 12/14/20.
//  Copyright © 2020 Fuerte Francis. All rights reserved.
//
//

import Foundation
import CoreData



extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")
}

@objc(UsersList)
public class UsersList: NSManagedObject, Codable {
    
    /*
    static func == (lhs: UsersList, rhs: UsersList) -> Bool {
        return lhs.login == rhs.login && lhs.id == rhs.id
    }*/

    enum CodingKeys: CodingKey {
           case login
           case id
           case node_id
           case avatar_url
           case gravatar_id
           case url
           case html_url
           case followers_url
           case following_url
           case gists_url
           case starred_url
           case subscriptions_url
           case organizations_url
           case repos_url
           case events_url
           case received_events_url
           case type
           case site_admin
       }
       
       public func encode(to encoder: Encoder) throws {
              var container = encoder.container(keyedBy: CodingKeys.self)
              do {
                  try container.encode(login, forKey: .login)
              } catch {
                  print("error")
              }
          }
          
          required convenience public init(from decoder: Decoder) throws {
              // return the context from the decoder userinfo dictionary
              guard let contextUserInfoKey = CodingUserInfoKey.context,
              let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: "UsersList", in: managedObjectContext)
              else {
                  fatalError("decode failure")
              }
              // Super init of the NSManagedObject
              self.init(entity: entity, insertInto: managedObjectContext)
              let values = try decoder.container(keyedBy: CodingKeys.self)
           
           do {
               login = try values.decode(String.self, forKey: .login)
               id = try values.decode(Int64.self, forKey: .id)
               node_id = try values.decode(String.self, forKey: .node_id)
               avatar_url = try values.decode(String.self, forKey: .avatar_url)
               gravatar_id = try values.decode(String.self, forKey: .gravatar_id)
               url = try values.decode(String.self, forKey: .url)
               html_url = try values.decode(String.self, forKey: .html_url)
               followers_url = try values.decode(String.self, forKey: .followers_url)
               following_url = try values.decode(String.self, forKey: .following_url)
               gists_url = try values.decode(String.self, forKey: .gists_url)
               starred_url = try values.decode(String.self, forKey: .starred_url)
               subscriptions_url = try values.decode(String.self, forKey: .subscriptions_url)
               organizations_url = try values.decode(String.self, forKey: .organizations_url)
               repos_url = try values.decode(String.self, forKey: .repos_url)
               events_url = try values.decode(String.self, forKey: .events_url)
               received_events_url = try values.decode(String.self, forKey: .received_events_url)
               type = try values.decode(String.self, forKey: .type)
               site_admin = try values.decode(Bool.self, forKey: .site_admin)
              } catch {
                  print ("error")
              }
          }
    
    
}
