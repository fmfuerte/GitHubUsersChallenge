//
//  ViewController.swift
//  GitHubUsersChallenge
//
//  Created by Francis Martin Fuerte on 12/11/20.
//  Copyright © 2020 Fuerte Francis. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UsersModelProtocol {
    
    
    var container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    var contentView: UIView! = UIView()
    var tableView: UITableView! = UITableView()
    var searchBar: UITextField! = UITextField()
    var searchBtn: UIButton! = UIButton()
    
    var usersModel = UsersModel()
    
    var users = [UsersList]()
    var profiles = [UserProfiles]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set the viewcontroller as the datasource and delegate of the tableview
        tableView.delegate = self
        tableView.dataSource = self
               
        // Set the delegate from the UsersList model
        usersModel.delegate = self
        
        //deleteSavedData()
        fetchInitialData()
        
        if(users.count == 0){
            usersModel.getUsersList(0)
        }
        
        //Set up programmatic UI
        self.view.addSubview(contentView)
               
        setUpContent()
               
        searchBtn.addTarget(self, action: #selector(self.searchButtonPress), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchInitialData()
    }
    
    func fetchInitialData() {
            let request: NSFetchRequest<UsersList> = UsersList.fetchRequest()
            let sort = NSSortDescriptor(key: "id", ascending: true)
            request.sortDescriptors = [sort]
            do {
                // fetch is performed on the NSManagedObjectContext
                let data = try container.viewContext.fetch(request)
                                             
                self.users = data
                tableView.reloadData()
            } catch {
                print("Fetch failed")
            }
    }
    
    //only used for testing and debugging
    func deleteSavedData(){
        
               // create the delete request for the specified entity
               let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UsersList.fetchRequest()
               let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

               // get reference to the persistent container
               let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer

               // perform the delete
               do {
                   try persistentContainer.viewContext.execute(deleteRequest)
               } catch let error as NSError {
                   print(error)
               }
               
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
             
             // Detect the indexpath the user selected
             let indexPath = tableView.indexPathForSelectedRow
             
             guard indexPath != nil else {
                 // The user hasn't selected anything
                 return
             }
             
        
        //load user information
        
        // Get the item the user tapped on
        let userSelected = self.users[indexPath!.row].profile
             
        // Get a reference to the detail view controller
        let detailVC = segue.destination as! DetailViewController
        
        detailVC.navigationItem.title = userSelected!.login
        
        // Pass the user profile to the detail view controller
        detailVC.listIndex = indexPath!.row
        detailVC.userProfile = userSelected
        
    }
    
    @objc func searchButtonPress(){
        
        
        if let searchterm = searchBar?.text  {
            if searchterm != "" {
                //search for a term based on username (login)
                let request: NSFetchRequest<UsersList> = UsersList.fetchRequest()
                let pred = NSPredicate(format: "login CONTAINS '"+searchterm+"' OR profile.notes CONTAINS %@", searchterm)
                request.predicate = pred
                do {
                // fetch is performed on the NSManagedObjectContext
                let data = try container.viewContext.fetch(request)
            
                self.users = data
                tableView.reloadData()
                } catch {
                    print("Fetch failed")
                }
            }
            else{
                //return to base results
                let request: NSFetchRequest<UsersList> = UsersList.fetchRequest()
                let sort = NSSortDescriptor(key: "id", ascending: true)
                request.sortDescriptors = [sort]
                do {
                // fetch is performed on the NSManagedObjectContext
                let data = try container.viewContext.fetch(request)
            
                self.users = data
                tableView.reloadData()
                } catch {
                    print("Fetch failed")
                }
            }
        }
        
        
       }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        
        // Get the track that the tableview is asking about
        let user = users[indexPath.row]
        
        // Customize it
        if ((indexPath.row+1) % 4 == 0 ){
            cell.displayUser(user,true)
        }
        else{
            cell.displayUser(user,false)
        }
        // Return the cell
        
        // Load new data based on last user id
        if self.users.count != 0 { //if not empty or initial state
            if let searchterm = searchBar?.text  { //if not in search mode
            if searchterm == "" {
                if indexPath.row == self.users.count - 1 {
                    self.tableView.addLoading(indexPath) {
                        self.usersModel.getUsersList(Int(self.users.last!.id))
                    }
                }
            }
            }
        }
        
        return cell
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // User has just selected a row, trigger the segue to go to detail
        performSegue(withIdentifier: "goToDetail", sender: self)
    }
    
    func usersRetrieved(_ users: [UsersList]) {
           // Set the track property of the view controller to the tracks passed back from the model
                self.users = users
                
            //store to CoreData
           
                // Refresh the tableview
            tableView.stopLoading()
               tableView.reloadData()
                
    }
    
    
    func profileRetrieved(_ profile: UserProfiles) {
        if self.profiles.contains(profile) {
            self.profiles[Int(profile.id)] = profile
        }
    }
    
    func profilesRetrieved(_ profiles: [UserProfiles]) {
        self.profiles = profiles
    }
    
    //Set up UI Programmatically
    
    func setUpContent(){
        
        contentView.addSubview(searchBtn)
        contentView.addSubview(searchBar)
        contentView.addSubview(tableView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        setUpSearchButton()
        setUpSearchBar()
        setUpTableView()
    }
    
    func setUpSearchButton(){
        searchBtn.setBackgroundImage(UIImage(systemName: "magnifyingglass"), for: .normal)
    
           
        searchBtn.translatesAutoresizingMaskIntoConstraints = false
                 
        searchBtn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        searchBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        searchBtn.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        searchBtn.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
    //    searchBtn.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
      //  searchBtn.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
           
       }
    
    
    func setUpSearchBar(){
        searchBar.borderStyle = .roundedRect
        searchBar.autocapitalizationType = .none
   
        searchBar.translatesAutoresizingMaskIntoConstraints = false
                 
        searchBar.widthAnchor.constraint(equalToConstant: 50).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        searchBar.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        searchBar.rightAnchor.constraint(equalTo: searchBtn.leftAnchor, constant: -20).isActive = true
        searchBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
    //    searchBtn.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
      //  searchBtn.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
           
       }
    
    func setUpTableView(){
    
        tableView.translatesAutoresizingMaskIntoConstraints = false
                 
        tableView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        tableView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: -10).isActive = true
        tableView.topAnchor.constraint(equalTo: searchBtn.bottomAnchor, constant: 20).isActive = true
        tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
    //    searchBtn.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
      //  searchBtn.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
       }
    


}

extension UITableView{

func indicatorView() -> UIActivityIndicatorView{
    var activityIndicatorView = UIActivityIndicatorView()
    if self.tableFooterView == nil{
        let indicatorFrame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 40)
        activityIndicatorView = UIActivityIndicatorView(frame: indicatorFrame)
        activityIndicatorView.isHidden = false
        activityIndicatorView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        activityIndicatorView.isHidden = true
        self.tableFooterView = activityIndicatorView
        return activityIndicatorView
    }else{
        return activityIndicatorView
    }
}

func addLoading(_ indexPath:IndexPath, closure: @escaping (() -> Void)){
    indicatorView().startAnimating()
    if let lastVisibleIndexPath = self.indexPathsForVisibleRows?.last {
        if indexPath == lastVisibleIndexPath && indexPath.row == self.numberOfRows(inSection: 0) - 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                closure()
            }
        }
    }
    indicatorView().isHidden = false
}

func stopLoading(){
    indicatorView().stopAnimating()
    indicatorView().isHidden = true
}
    
}
