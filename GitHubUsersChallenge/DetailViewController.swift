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
    
    var detailContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
         // call the 'keyboardWillShow' function when the view controller receive the notification that a keyboard is going to be shown
          NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
          NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    

    @objc func keyboardWillShow(notification: NSNotification) {
            
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
      
      // move the root view up by the distance of keyboard height
      self.view.frame.origin.y = 0 - keyboardSize.height
    }

    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      self.view.frame.origin.y = 0
    }
    
    //load data when view appears
    override func viewWillAppear(_ animated: Bool) {
        //load image
        loadImage()
        
        //set profile seen
        setSeen()
        
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
    
    func setSeen(){
        do{
        let request: NSFetchRequest<UsersList> = UsersList.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sort]
          do {
              // fetch is performed on the NSManagedObjectContext
            let data = try self.detailContext.fetch(request)
        
            data[listIndex!].profile!.seen = true
            
                do {
                    try self.detailContext.save()
                } catch {
                    print("Error setting seen")
                }
            }
           
            
        }
        catch {
                print("Error fetch")
        }
    }
    
    
    @IBAction func btnSave(_ sender: Any) {
        
        do{
            let request: NSFetchRequest<UsersList> = UsersList.fetchRequest()
            let sort = NSSortDescriptor(key: "id", ascending: true)
            request.sortDescriptors = [sort]
              do {
                  // fetch is performed on the NSManagedObjectContext
                let data = try self.detailContext.fetch(request)
            
                data[listIndex!].profile!.notes = notesTextView.text
                
                    do {
                        try self.detailContext.save()
                        
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
                
                //apply circular mask to the imageview
                self.avatarImageView!.maskCircle(UIImage(data: imageData)!)
                return
            }
            else{
            //if no cache image load from network
            
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
                                   // Display the image data in the image view, apple circular mask
                                self.avatarImageView.maskCircle(UIImage(data: data!)!)
                                
                               }
                        }
                               
                       } // End if
                       
                   } // End data task
                   
                   // Kick off the datatask
                   dataTask.resume()
        
            }
    }
        
}




//create a circular profile image
extension UIImageView {
  public func maskCircle(_ image: UIImage) {
    self.contentMode = UIView.ContentMode.scaleAspectFill
    self.layer.cornerRadius = self.frame.height / 2
    self.layer.masksToBounds = false
    self.clipsToBounds = true

   self.image = image
    self.setNeedsLayout()
  }
}
