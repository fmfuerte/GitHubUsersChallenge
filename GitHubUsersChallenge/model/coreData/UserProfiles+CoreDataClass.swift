//
//  UserProfiles+CoreDataClass.swift
//  GitHubUsersChallenge
//
//  Created by Francis Martin Fuerte on 12/14/20.
//  Copyright © 2020 Fuerte Francis. All rights reserved.
//
//

import Foundation
import CoreData



@objc(UserProfiles)
public class UserProfiles: NSManagedObject, Codable {
    
    enum CodingKeys: CodingKey {
        case login
        case id
        case avatar_url
        case name
        case company
        case blog
        case location
        case email
        case hireable
        case bio
        case twitter_username
        case public_repos
        case public_gists
        case followers
        case following
        case created_at
        case updated_at
        case node_id
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
              let entity = NSEntityDescription.entity(forEntityName: "UserProfiles", in: managedObjectContext)
              else {
                  fatalError("decode failure")
              }
              // Super init of the NSManagedObject
              self.init(entity: entity, insertInto: managedObjectContext)
            let values = try decoder.container(keyedBy: CodingKeys.self)
           
           do {
                login = try values.decode(String.self, forKey: .login)
                id = try values.decode(Int64.self, forKey: .id)
                avatar_url = try values.decodeIfPresent(String.self, forKey: .avatar_url) ?? ""
                name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
                node_id = try values.decodeIfPresent(String.self, forKey: .node_id) ?? ""
                public_repos = try values.decodeIfPresent(Int64.self, forKey: .public_repos) ?? 0
                public_gists = try values.decodeIfPresent(Int64.self, forKey: .public_gists) ?? 0
                followers = try values.decodeIfPresent(Int64.self, forKey: .followers) ?? 0
                following = try values.decodeIfPresent(Int64.self, forKey: .following) ?? 0
                created_at = try values.decodeIfPresent(String.self, forKey: .created_at) ?? ""
                updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at) ?? ""
                gravatar_id = try values.decodeIfPresent(String.self, forKey: .gravatar_id) ?? ""
                url = try values.decodeIfPresent(String.self, forKey: .url) ?? ""
                html_url = try values.decodeIfPresent(String.self, forKey: .html_url) ?? ""
                followers_url = try values.decodeIfPresent(String.self, forKey: .followers_url) ?? ""
                following_url = try values.decodeIfPresent(String.self, forKey: .following_url) ?? ""
                gists_url = try values.decodeIfPresent(String.self, forKey: .gists_url) ?? ""
                starred_url = try values.decodeIfPresent(String.self, forKey: .starred_url) ?? ""
                subscriptions_url = try values.decodeIfPresent(String.self, forKey: .subscriptions_url) ?? ""
                organizations_url = try values.decodeIfPresent(String.self, forKey: .organizations_url) ?? ""
                repos_url = try values.decodeIfPresent(String.self, forKey: .repos_url) ?? ""
                events_url = try values.decodeIfPresent(String.self, forKey: .events_url) ?? ""
                received_events_url = try values.decodeIfPresent(String.self, forKey: .received_events_url) ?? ""
                type = try values.decodeIfPresent(String.self, forKey: .type) ?? ""
                site_admin = try values.decodeIfPresent(Bool.self, forKey: .site_admin) ?? false
                blog = try values.decodeIfPresent(String.self, forKey: .blog) ?? ""
                company = try values.decodeIfPresent(String.self, forKey: .company) ?? ""
                email = try values.decodeIfPresent(String.self, forKey: .email) ?? ""
                location = try values.decodeIfPresent(String.self, forKey: .location) ?? ""
                bio = try values.decodeIfPresent(String.self, forKey: .bio) ?? ""
                blog = try values.decodeIfPresent(String.self, forKey: .blog) ?? ""
           
            
            twitter_username = try values.decodeIfPresent(String.self, forKey: .twitter_username) ?? ""
            
             hireable = try values.decodeIfPresent(Bool.self, forKey: .hireable) ?? false
                
              } catch {
                print ("error " + error.localizedDescription)
              }
          }

    

}
