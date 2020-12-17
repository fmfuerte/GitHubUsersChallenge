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
    
    var errorHeader: UIView! = UIView()
    var errorShown = false
    
    let refreshControl = UIRefreshControl()
    
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
        
        deleteSavedData()
        fetchSavedData()
        
        if(users.count == 0){
            usersModel.getUsersList(0)
        }
        
      
        //Set up programmatic UI
        self.view.addSubview(contentView)
               
        setUpContent()
        
        //add pull to refresh
        tableView.addSubview(refreshControl)
               
        //add actions
        searchBtn.addTarget(self, action: #selector(self.searchButtonPress), for: .touchUpInside)
        refreshControl.addTarget(self, action:  #selector(refresh), for: .valueChanged)
              
        
    }
    
    //fetch the saved data when view will appear
    override func viewWillAppear(_ animated: Bool) {
        fetchSavedData()
    }

    @objc func refresh(){
        //check if the error message was shown
        if(errorShown){
            errorHeaderWillHide()
        }
    
        refreshControl.beginRefreshing()
        fetchSavedData()
        if(users.count == 0){
            usersModel.getUsersList(0)
        }
    }
    
   
    //fetch the saved data
    func fetchSavedData() {
            let request: NSFetchRequest<UsersList> = UsersList.fetchRequest()
            let sort = NSSortDescriptor(key: "id", ascending: true)
            request.sortDescriptors = [sort]
            do {
                // fetch is performed on the NSManagedObjectContext
                let data = try container.viewContext.fetch(request)
                                             
                self.users = data
                refreshControl.endRefreshing()
                tableView.stopLoading()
                
                //relead the tableview
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
    
    
    //show the error header
    @objc func errorHeaderWillShow() {
        //mark that the error was shown
        errorShown = true
        
        //set up error header
        errorHeader.frame =  CGRect(x: 0, y: -50, width: self.contentView.frame.width, height: 50)
        errorHeader.backgroundColor = .red
        
        let errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.errorHeader.frame.width, height: 50) )
        errorLabel.text = "Problem with Network. Pull to refresh"
        errorLabel.textAlignment = .center
        errorLabel.textColor = UIColor.white
        
        errorHeader.translatesAutoresizingMaskIntoConstraints = false
        
        errorHeader.addSubview(errorLabel)
        
        //add error header to contentview
        self.contentView.addSubview(errorHeader)
        
        //move the content view down to acommodate error header
        self.contentView.frame.origin.y = self.contentView.frame.origin.y + 50
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
       }

    @objc func errorHeaderWillHide() {
        //mark that the header is hidden
        errorShown = false
        
        //remoce error header from content view
        errorHeader.removeFromSuperview()
        
         // move back the content view back to normal
         self.contentView.frame.origin.y = self.contentView.frame.origin.y - 50
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
        
        //get the title of the detail view controller to the username
        detailVC.navigationItem.title = userSelected!.login
        
        // Pass the user profile to the detail view controller
        detailVC.listIndex = indexPath!.row
        detailVC.userProfile = userSelected
        
    }
    
    //set up the search button press logic
    @objc func searchButtonPress(){
        if let searchterm = searchBar?.text  {
            if searchterm != "" {
                //search for a term based on username (login)
                let request: NSFetchRequest<UsersList> = UsersList.fetchRequest()
                let pred = NSPredicate(format: "(login like '"+searchterm+"' OR login CONTAINS '"+searchterm+"') OR (profile.notes like '"+searchterm+"' OR profile.notes CONTAINS %@)", searchterm)
                
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
    
    //set up the table view
    
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
    
    
    //set up the tableview selected row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // User has just selected a row, trigger the segue to go to detail
        performSegue(withIdentifier: "goToDetail", sender: self)
    }
    
    func usersRetrieved() {
        //fetch new data
        fetchSavedData()
                
        // Refresh the tableview
        refreshControl.endRefreshing()
        tableView.stopLoading()
        tableView.reloadData()
                
    }
    
    //show alert protocol - used to show alertbox
    func showAlert(_ message: String, _ buttonStyle: UIAlertAction.Style) {
         self.tableView.stopLoading()
        self.refreshControl.endRefreshing()
        
         errorHeaderWillShow()
        
        
           let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)

           alert.addAction(UIAlertAction(title: "Ok", style: buttonStyle, handler: nil))

           self.present(alert, animated: true)
           
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
           
       }
    
  
    
    func setUpTableView(){
        tableView.translatesAutoresizingMaskIntoConstraints = false
                 
        tableView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        tableView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: -10).isActive = true
        tableView.topAnchor.constraint(equalTo: searchBtn.bottomAnchor, constant: 20).isActive = true
        tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
       }
    


}

//add a loading progress view to the tableview when scrolled to load more users
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
