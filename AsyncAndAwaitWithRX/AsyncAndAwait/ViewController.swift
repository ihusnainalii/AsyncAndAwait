//
//  ViewController.swift
//  AsyncAndAwait
//
//  Created by Husnain Ali on 15/09/2022.
//

import UIKit
import RxSwift
import RxCocoa

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
    
    // MARK: - Constant
    private let users = BehaviorRelay<[User]>(value: [])
    private let disposeBag = DisposeBag()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Navigation Configurations
        self.title = "Contact List"
        
        /// Bind TableView
        bindTableView()
        
        /// Subscribe Reply
        subscribeRelay()
        
        /// get users from remote api
        indicator.startAnimating()
        loadingView.isHidden = false
        fetchUsers()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//            self.fetchUsers()
//        })
    }
    
    // MARK: - Custom Functions
    /// Get user list from reemote api call function and reload the table
    func fetchUsers() {
        Task{
            let users = try await remoteAPICall()
            if let users = users {
                self.users.append(contentsOf: users)
            }
        }
    }
    
    /// Get list of users from remote URL
    /// - Returns: Array of users
    private func remoteAPICall() async throws -> [User]? {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else {
            return []
        }
        if #available(iOS 15.0, *) {
            let (data , _) = try await URLSession.shared.data(from: url , delegate: nil)
            let users = try? JSONDecoder().decode([User].self, from: data)
            return users
        }
        return nil
    }
    
    private func subscribeRelay() {
        users.observe(on: MainScheduler.instance).subscribe(
            onNext: { [unowned self] data in
                indicator.stopAnimating()
                loadingView.isHidden = true
                print(data)
            }
        ).disposed(by: disposeBag)
    }
    
    private func bindTableView() {
        users.bind(to: tableView.rx.items(cellIdentifier: "cell")) { [unowned self] (tableView, userData, cell) in
            cell.textLabel?.text = get(with: userData)
            cell.textLabel?.numberOfLines = 0
        }.disposed(by: disposeBag)
    }
    
    private func get(with user: User) -> String {
        let name = user.name
        let username = user.username
        let phone = user.phone
        let email = user.email
        return "\(name)\n\(username)\n\(phone)\n\(email)"
    }
}


extension BehaviorRelay where Element: RangeReplaceableCollection {

    func append(_ subElement: Element.Element) {
        var newValue = value
        newValue.append(subElement)
        accept(newValue)
    }
    
    func append(contentsOf: [Element.Element]) {
        var newValue = value
        newValue.append(contentsOf: contentsOf)
        accept(newValue)
    }
    
    public func remove(at index: Element.Index) {
        var newValue = value
        newValue.remove(at: index)
        accept(newValue)
    }
    
    public func removeAll() {
        var newValue = value
        newValue.removeAll()
        accept(newValue)
    }
}
