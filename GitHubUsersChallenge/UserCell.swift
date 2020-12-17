//
//  UserCell.swift
//  GitHubUsersChallenge
//
//  Created by Francis Martin Fuerte on 12/12/20.
//  Copyright © 2020 Fuerte Francis. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    var container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    var userToDisplay:UsersList?
    
    func displayUser(_ user:UsersList,_ inverted:Bool) {
        // Clean up the cell before displaying the next article
        self.imageView!.image = nil
        self.accessoryView = nil
        self.textLabel!.text = ""
        self.detailTextLabel!.text = ""
        
        // Keep a reference to the user
        userToDisplay = user
        
        //self.textLabel?.textColor = UIColor.black
       // self.detailTextLabel?.textColor = UIColor.black
        
        //set up the fields
        self.textLabel!.text = userToDisplay!.login
        self.detailTextLabel!.text = userToDisplay!.type
        if let name = userToDisplay!.profile?.name {
            self.detailTextLabel!.text = userToDisplay!.type! + " - " + name
        }
        if(userToDisplay!.profile?.seen != nil){
            if(userToDisplay!.profile?.seen == true){
                self.textLabel?.textColor = UIColor.lightGray
                self.detailTextLabel?.textColor = UIColor.lightGray
            }
        }
        
        //check if theres a note, show note uimage on accessory view if there is
        if( userToDisplay!.profile?.notes != nil){
            if (userToDisplay!.profile?.notes?.count ?? 0) > 1 {
                self.accessoryView =  UIImageView(image: UIImage(systemName: "square.and.pencil"))
            }
        }
        
        //load the image
        self.loadImage(inverted)
    }
    
    func loadImage(_ inverted:Bool){
        // Create url string
             let urlString = userToDisplay!.avatar_url!
            
            // Check the cachemanager before downloading any image data
            if let imageData = ImageCache.loadImage(urlString) {
                // There is image data, set the imageview and return
                let image:UIImage
                if(inverted){
                    image = invertImage(UIImage(data: imageData)!)
                }
                else{
                    image = UIImage(data: imageData)!
                }
                self.imageView!.image = image
                self.setNeedsLayout()
                self.setNeedsDisplay()
                return
            }
            else{
            //if image is not in cache
            
             // Create the url
            let url = URL(string: userToDisplay!.avatar_url!)
                   
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
                        ImageCache.storeImage(self.userToDisplay!.avatar_url!, data!)
                           
                           // Check if the url string that the data task went off to download matches the article this cell is set to display
                       if self.userToDisplay!.avatar_url == urlString {
                               
                               DispatchQueue.main.async {
                                   // Display the image data in the image view
                                let image:UIImage
                                if(inverted){
                                    image = self.invertImage(UIImage(data: data!)!)
                                }
                                else{
                                    image = UIImage(data: data!)!
                                }
                                self.imageView!.image = image
                                self.setNeedsLayout()
                                self.setNeedsDisplay()
                               }
                        }
                               
                           
                           
                       } // End if
                       
                   } // End data task
                   
                   // Kick off the datatask
                   dataTask.resume()
                
        }
        
    }
    
    //invert the image color
    func invertImage(_ image:UIImage) -> UIImage {
        let beginImage = CIImage(image: image)
        let filter = CIFilter(name: "CIColorInvert")
        
        filter!.setValue(beginImage, forKey: kCIInputImageKey)
        return UIImage(ciImage: filter!.outputImage!)
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


