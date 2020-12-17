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
    
    func usersRetrieved()
    
    func showAlert(_ message:String,_ buttonStyle:UIAlertAction.Style)
}

class UsersModel {
    
    var networkContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
   var delegate:UsersModelProtocol?
   
   func getUsersList(_ since:Int) {
       // Create a string URL
    let stringUrl = "https://api.github.com/users?since="+since.description
  
       
       // Create a URL object
       let url = URL(string: stringUrl)
    
      var urlReq = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5)
    
            
        urlReq.addValue("token 95d270eeb0e76446a0cf5ff5663b62ac6fe12cd1", forHTTPHeaderField: "Authorization")
       
       // Check that it isn't nil
       guard url != nil else {
           print("Couldn't create url object")
           return
       }
       
    
       // Get the URL Session
       let session = URLSession.shared
    
    session.configuration.httpMaximumConnectionsPerHost = 1
    
    session.configuration.timeoutIntervalForResource = 60
    
    session.configuration.waitsForConnectivity = true
    
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
                
                self.saveContext(LoadedUsers)
                
                        // Move back on the main thread, and load the saved Data, this will also trigger loading of profiles
                        DispatchQueue.main.async {
                            self.loadSavedData()
                        }
               }
               catch {
                DispatchQueue.main.async {
                self.delegate?.showAlert("An error occurred while parsing the json: \(error)", .destructive)
                }
                
               } // End Do - Catch
               
           } // End if
           else{
            DispatchQueue.main.async {
            self.delegate?.showAlert("An error occurred while loading the network. Connect to the internet and pull to refresh", .destructive)
            }
        }
           
    } // End Data Task
       
       // Start the data task
       dataTask.resume()
 
   }
    
    //load the profiles one by one
    func loadProfiles(_ list:[UsersList]){
        
        
        for user in list{
            
        // Create a string URL
            if(user.profile == nil){
            let stringUrl = "https://api.github.com/users/"+user.login!
           
           // Create a URL object
           let url = URL(string: stringUrl)
                
                var urlReq = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
                    
                urlReq.addValue("token 95d270eeb0e76446a0cf5ff5663b62ac6fe12cd1", forHTTPHeaderField: "Authorization")
           
           // Check that it isn't nil
           guard url != nil else {
               print("Couldn't create url object")
               return
           }
                
        
        // Get the URL Session
        let session = URLSession.shared
                
        session.configuration.httpMaximumConnectionsPerHost = 1
                
        session.configuration.timeoutIntervalForResource = 30
                
        session.configuration.waitsForConnectivity = true
           
              // Create the data task
                let dataTask = session.dataTask(with: urlReq) { (data, response, error) in
                  
                  // Check that there are no errors and that there is data
                  if error == nil && data != nil {
                      
                      // Attempt to parse the JSON
                      let decoder = JSONDecoder()
                      
                      do {
                       // Assign the NSManagedObject Context to the decoder
                        decoder.userInfo[CodingUserInfoKey.context!] = self.networkContext
                       
                        let LoadedProfile = try decoder.decode(UserProfiles.self, from: data!)
                       
                        user.profile = LoadedProfile
                        user.profile!.seen = false
                        user.profile!.notes = ""
                       
                        //save the loaded profiles context
                        do {
                            
                            try self.networkContext.save()
                            
                            DispatchQueue.main.async {
                                self.delegate?.usersRetrieved()
                            }
                        } catch {
                            print("An error occurred while saving: \(error)")
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
        
    }
    
    func saveContext(_ LoadedUsers:[UsersList]) {
        let request: NSFetchRequest<UsersList> = UsersList.fetchRequest()
        
          do {
              // fetch is performed on the NSManagedObjectContext
            var data = try self.networkContext.fetch(request)
        
            let old = data.count //get the number of old data
           for user in LoadedUsers {
            //add a loaded user if it doesn't exist yet
            if (data.contains(where: {$0.login == user.login})==false){
                   data.append(user)
               }
           }
            let new = data.count //get the number of new data
            
            //if there is new data save the context
            if(old<new){
                do {
                    try self.networkContext.save()
                } catch {
                    DispatchQueue.main.async {
                        self.delegate?.showAlert("An error occurred while saving: \(error)", .destructive)
                    }
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
            // load data by fetching from context
            let data = try networkContext.fetch(request)
            
            //load Profiles
            loadProfiles(data)
            
            
        } catch {
            print("Fetch failed")
        }
    }
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        DispatchQueue.main.async {
        self.delegate?.showAlert("Waiting for internet connection", .destructive)
        }
    }
    
 
    

}

