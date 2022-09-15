//
//  ViewController.swift
//  AsyncAndAwait
//
//  Created by Husnain Ali on 15/09/2022.
//

import UIKit

struct User: Decodable {
    let name: String
    let username: String
    let email: String
    let phone: String
}

class ViewController: UIViewController {
   
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    var users = [User]() {
        didSet {
            indicator.stopAnimating()
            loadingView.isHidden = true
        }
    }
    
    // MARK: - Constant
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Navigation Configurations
        self.title = "Contact List"
        
        /// Confirm Delegate
        tableView.delegate = self
        tableView.dataSource = self
        
        /// get users from remote api
        fetchUsers()
    }
    
    // MARK: - Custom Functions
    /// Get user list from reemote api call function and reload the table
    func fetchUsers() {
        Task{
            let users = try await remoteAPICall()
            self.users = users ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    /// Get list of users from remote URL
    /// - Returns: Array of users
    private func remoteAPICall() async throws -> [User]? {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else {
            return []
        }
        indicator.startAnimating()
        loadingView.isHidden = false
        if #available(iOS 15.0, *) {
            let (data , _) = try await URLSession.shared.data(from: url , delegate: nil)
            let users = try? JSONDecoder().decode([User].self, from: data)
            return users
        }
        return nil
    }
}


// MARK: - Extension for table view delegates
extension ViewController: UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let name = users[indexPath.row].name
        let username = users[indexPath.row].username
        let phone = users[indexPath.row].phone
        let email = users[indexPath.row].email
        cell.textLabel?.text = "\(name)\n\(username)\n\(phone)\n\(email)"
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
