//
//  CoreDataStore.swift
//  GitHubUsersChallenge
//
//  Created by Francis Martin Fuerte on 12/15/20.
//  Copyright © 2020 Fuerte Francis. All rights reserved.
//

import UIKit
import CoreData

enum StorageType {
  case persistent, inMemory
}

class CoreDataStore {
  let persistentContainer: NSPersistentContainer

  init(_ storageType: StorageType = .persistent) {
    
    self.persistentContainer = NSPersistentContainer(name: "GitHubUsersChallenge")

    if storageType == .inMemory {
      let description = NSPersistentStoreDescription()
      description.url = URL(fileURLWithPath: "/dev/null")
      self.persistentContainer.persistentStoreDescriptions = [description]
    }

    self.persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
    
        self.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
      
        if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
        
    })
    
  }
    
    
}
