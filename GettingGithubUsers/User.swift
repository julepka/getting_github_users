//
//  User.swift
//  GettingGithubUsers
//
//  Created by Julia Potapenko on 9.08.2017.
//  Copyright © 2017 Julia Potapenko. All rights reserved.
//

import Foundation
import UIKit

class User {
    let id: Int
    let login: String
    let link: String
    let avatar: String
    let followers: String
    var image: UIImage?
    
    init(id: Int, login: String, link: String, avatar: String, followers: String) {
        self.id = id
        self.login = login
        self.link = link
        self.avatar = avatar
        self.followers = followers
        self.image = nil
    }
}
