//
//  DetailViewController.swift
//  GitHubUsersChallenge
//
//  Created by Francis Martin Fuerte on 12/12/20.
//  Copyright © 2020 Fuerte Francis. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class DetailViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var LocationTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var blogTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    var listIndex:Int?
    var userProfile:UserProfiles?
    
     var container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //load image
        loadImage()
        
        notesTextView.autocapitalizationType = .none
        
        //populate fields
        followerLabel.text = "Followers: " + (userProfile?.followers.description ?? "0")
        followingLabel.text = "Following: " + (userProfile?.following.description ?? "0")
        nameTextField.text = userProfile?.name ?? ""
        bioTextView.text = userProfile?.bio ?? ""
        LocationTextField.text = userProfile?.location ?? ""
        companyTextField.text = userProfile?.company ?? ""
        emailTextField.text = userProfile?.email ?? ""
        blogTextField.text = userProfile?.blog ?? ""
        notesTextView.text = userProfile?.notes ?? ""
        
        bioTextView.layer.borderWidth = 1
        bioTextView.layer.borderColor = UIColor.lightGray.cgColor
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        
    }
    
    
    @IBAction func btnSave(_ sender: Any) {
        
        do{
            let request: NSFetchRequest<UsersList> = UsersList.fetchRequest()
            let sort = NSSortDescriptor(key: "id", ascending: true)
            request.sortDescriptors = [sort]
              do {
                  // fetch is performed on the NSManagedObjectContext
                let data = try self.container.viewContext.fetch(request)
            
                data[listIndex!].profile!.notes = notesTextView.text
                
                    do {
                        try self.container.viewContext.save()
                        
                        let alert = UIAlertController(title: "Information", message: "Note Successfully Saved!", preferredStyle: .alert)

                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

                        self.present(alert, animated: true)
                        
                        
                    } catch {
                        
                        let alert = UIAlertController(title: "Information", message: "An error occurred while saving: \(error)", preferredStyle: .alert)

                        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))

                        self.present(alert, animated: true)
                        
                    }
                }
               
                
            }
            catch {
                    print("Error fetch")
            }
       }
    
    func loadImage(){
        // Create url string
             let urlString = userProfile!.avatar_url!
            
            // Check the cachemanager before downloading any image data
            if let imageData = ImageCache.loadImage(urlString) {
                // There is image data, set the imageview and return
                
                self.avatarImageView!.maskCircle(UIImage(data: imageData)!)
                return
            }
            
            
             // Create the url
            let url = URL(string: userProfile!.avatar_url!)
                   
                   // Check that the url isn't nil
                   guard url != nil else {
                       print("Couldn't create url object")
                       return
                   }
                   
                   // Get a URLSession
                   let session = URLSession.shared
                   
                   // Create a datatask
                   let dataTask = session.dataTask(with: url!) { (data, response, error) in
                       
                       // Check that there were no errors
                       if error == nil && data != nil {
                           
                           // Save the data into cache
                        ImageCache.storeImage(self.userProfile!.avatar_url!, data!)
                           
                           // Check if the url string that the data task went off to download matches the avatar this cell is set to display
                       if self.userProfile!.avatar_url == urlString {
                               
                               DispatchQueue.main.async {
                                   // Display the image data in the image view
                                self.avatarImageView.maskCircle(UIImage(data: data!)!)
                                
                               }
                        }
                               
                           
                           
                       } // End if
                       
                   } // End data task
                   
                   // Kick off the datatask
                   dataTask.resume()
        
    }


}
