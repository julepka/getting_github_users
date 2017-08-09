//
//  ViewController.swift
//  GettingGithubUsers
//
//  Created by Julia Potapenko on 9.08.2017.
//  Copyright © 2017 Julia Potapenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var users: [User] = []
    
    var parentUser: User? = nil
    var pages = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        loadMoreUsers()
    }
    
    func loadMoreUsers() {
        var lastId = 0
        if let lastUser = self.users.last {
            lastId = lastUser.id
        }
        
        // loading followers
        if let parent = parentUser {
            self.pages = self.pages + 1
            DataLoader().getFollowers(url: parent.followers, page: pages) { [weak self] result in
                self?.users.append(contentsOf: result)
                self?.tableView.reloadData()
                if let usersCount = self?.users.count {
                    self?.loadAvatars(from: usersCount - result.count, to: usersCount)
                }
            }
            
        // if parent user is not set, loading all users
        } else {
            DataLoader().getUsers(lastId: lastId) { [weak self] result in
                self?.users.append(contentsOf: result)
                self?.tableView.reloadData()
                if let usersCount = self?.users.count {
                    self?.loadAvatars(from: usersCount - result.count, to: usersCount)
                }
            }
        }
    }
    
    func loadAvatars(from fromIndex: Int, to toIndex: Int) {
        for index in fromIndex..<toIndex {
            if users[index].image == nil {
                DataLoader().downloadImage(urlString: users[index].avatar) { [weak self] resultImage in
                    self?.users[index].image = resultImage
                    let indexPath = IndexPath(item: index, section: 0)
                    self?.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        cell.titleLabel.text = users[indexPath.row].login
        cell.subtitleLabel.text = users[indexPath.row].link
        cell.avatarImageView.image = nil
        if let image = users[indexPath.row].image {
            cell.avatarImageView.image = image
        }
        if indexPath.row == users.count - 1 {
            self.loadMoreUsers()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            viewController.parentUser = self.users[indexPath.row]
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
}

