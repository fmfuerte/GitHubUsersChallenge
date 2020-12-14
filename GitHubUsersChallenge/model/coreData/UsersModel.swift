//
//  UsersModel.swift
//  GitHubUsersChallenge
//
//  Created by Francis Martin Fuerte on 12/13/20.
//  Copyright © 2020 Fuerte Francis. All rights reserved.
//

import UIKit
import Foundation
import CoreData


protocol UsersModelProtocol {
    
    func usersRetrieved(_ users:[UsersList])
}

class UsersModel {
    
    var container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    var networkContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
    var networkProfileContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()

   var delegate:UsersModelProtocol?
   
   func getUsersList(_ since:Int) {
    
    //check and load previous data if available
  // self.loadSavedData()
  //   self.deleteSavedData()
       
       // Fire off the request to the API
       
       // Create a string URL
    let stringUrl = "https://api.github.com/users?since="+since.description
  
       
       // Create a URL object
       let url = URL(string: stringUrl)
    
    
      var urlReq = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5)
            
        urlReq.addValue("token da28274eb5e02e4e8b01c2aefd89b0f62f65da7c", forHTTPHeaderField: "Authorization")
       
       // Check that it isn't nil
       guard url != nil else {
           print("Couldn't create url object")
           return
       }
       
        URLSession.shared.configuration.httpMaximumConnectionsPerHost = 1
    
       // Get the URL Session
       let session = URLSession.shared
    
       // Create the data task
    let dataTask = session.dataTask(with: urlReq) { (data, response, error) in
           
           // Check that there are no errors and that there is data
           if error == nil && data != nil {
               
               // Attempt to parse the JSON
               let decoder = JSONDecoder()
               
               do {
                // Assign the NSManagedObject Context to the decoder
               decoder.userInfo[CodingUserInfoKey.context!] = self.networkContext
                
                              
                let LoadedUsers = try decoder.decode([UsersList].self, from: data!)
                print("load "+LoadedUsers.count.description)
                self.saveContext(LoadedUsers)
                
                              // Move back on the main thread, as we call tableview.reload
                              DispatchQueue.main.async {
                            //    self.deleteSavedData()
                                //  self.saveContext()
                                self.loadSavedData()
                              //  self.delegate?.usersRetrieved(users)
                }
                   /*
                   // Parse the json into ArticleService
                   let UsersService = try decoder.decode(UsersListService.self, from: data!)
                   
                   // Get the users
                   let users = UsersService.results!
                   
                   // Pass it back to the view controller in the main thread
                   DispatchQueue.main.async {
                       self.delegate?.usersRetrieved(users)
                   }
                   */
               }
               catch {
                   print("Error parsing the json "  + error.localizedDescription)
               } // End Do - Catch
               
           } // End if
           
    } // End Data Task
       
       // Start the data task
       dataTask.resume()
 
   }
    
    func loadProfiles(_ list:[UsersList]){
        
        for user in list{
            
        // Create a string URL
            if(user.profile == nil){
            let stringUrl = "https://api.github.com/users/"+user.login!
           
           // Create a URL object
           let url = URL(string: stringUrl)
                
                var urlReq = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
                    
                urlReq.addValue("token da28274eb5e02e4e8b01c2aefd89b0f62f65da7c", forHTTPHeaderField: "Authorization")
           
           // Check that it isn't nil
           guard url != nil else {
               print("Couldn't create url object")
               return
           }
                
        URLSession.shared.configuration.httpMaximumConnectionsPerHost = 1
        
        // Get the URL Session
        let session = URLSession.shared
           
              // Create the data task
                let dataTask = session.dataTask(with: urlReq) { (data, response, error) in
                  
                  // Check that there are no errors and that there is data
                  if error == nil && data != nil {
                      
                      // Attempt to parse the JSON
                      let decoder = JSONDecoder()
                      
                      do {
                       // Assign the NSManagedObject Context to the decoder
                        decoder.userInfo[CodingUserInfoKey.context!] = self.container.viewContext
                       
                        let LoadedProfile = try decoder.decode(UserProfiles.self, from: data!)
                       
                        user.profile = LoadedProfile
                        user.profile!.seen = false
                        user.profile!.notes = ""
                       
                        //save the profile of the user
                          do {
                              try self.container.viewContext.save()
                          } catch {
                              print("An error occurred while saving: \(error)")
                          }
                        DispatchQueue.main.async {
                         self.delegate?.usersRetrieved(list)
                        }
                        
                      }
                      catch {
                        print("Error parsing the json 2 " + error.localizedDescription)
                      } // End Do - Catch
                      
                  } // End if
                  
           } // End Data Task
              
              // Start the data task
              dataTask.resume()
            }
            
        }
        
        
       
       // print("prof2"+list[0].profile!.description)
        
    }
    
    func saveContext(_ LoadedUsers:[UsersList]) {
        let request: NSFetchRequest<UsersList> = UsersList.fetchRequest()
        //  let sort = NSSortDescriptor(key: "id", ascending: true)
         // request.sortDescriptors = [sort]
          do {
              // fetch is performed on the NSManagedObjectContext
            var data = try self.container.viewContext.fetch(request)
        
            let old = data.count //get the number of old data
           for user in LoadedUsers {
            //add a loaded user if it doesn't exist yet
            if (data.contains(where: {$0.login == user.login})==false){
                   data.append(user)
               }
           }
            let new = data.count //get the number of new data
            
            if(old<new){
                do {
                    try self.networkContext.save()
                } catch {
                    print("An error occurred while saving: \(error)")
                }
            }
           
            
        }
        catch {
                print("Error fetch")
        }
        
    }
    
    
    func loadSavedData() {
        let request: NSFetchRequest<UsersList> = UsersList.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sort]
        do {
            // fetch is performed on the NSManagedObjectContext
            let data = try container.viewContext.fetch(request)
            
            //load Profiles
            loadProfiles(data)
            
            //refresh the tableview
            self.delegate?.usersRetrieved(data)
            
        } catch {
            print("Fetch failed")
        }
    }
    
    
 
    

}
