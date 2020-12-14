//
//  ImageCache.swift
//  GitHubUsersChallenge
//
//  Created by Francis Martin Fuerte on 12/12/20.
//  Copyright © 2020 Fuerte Francis. All rights reserved.
//

import UIKit

class ImageCache {
    
    static func storeImage(_ urlString: String,_ data: Data){
        let path = NSTemporaryDirectory().appending(UUID().uuidString)
        let url = URL(fileURLWithPath: path)
        
        //write the data to path
        try? data.write(to: url)
        
        var dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String:String]
        if dict == nil {
            dict = [String:String]()
        }
        
        //save the path location based on urlString
        dict![urlString] = path
        
        //saves the data along with the paths to UserDefaults
        UserDefaults.standard.set(dict, forKey: "ImageCache")
        
    }
    
    static func loadImage(_ urlString: String) -> Data?  {
        //load data from UserDefault if it exist based on url
        if let dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String:String] {
            
            if let path = dict[urlString]{
                
                if let data = try? Data(contentsOf: URL(fileURLWithPath: path)){
                    return data
                }
            }
            
        }
        
        return nil
        
    }

}
