//
//  DataLoader.swift
//  GettingGithubUsers
//
//  Created by Julia Potapenko on 9.08.2017.
//  Copyright © 2017 Julia Potapenko. All rights reserved.
//

import Foundation
import UIKit

class DataLoader {
    
    let usersUrl = "https://api.github.com/users"
    let batchSize = 50
    
    func getUsers(lastId: Int, completion: @escaping ([User]) -> ()) {
        guard var urlComp = URLComponents(string: usersUrl) else {
            return
        }
        urlComp.queryItems = [URLQueryItem(name: "since", value: "\(lastId)"),
                              URLQueryItem(name: "per_page", value: "\(batchSize)")]
        if let url = urlComp.url {
            self.userListRequest(url: url, completion: completion)
        }
    }
    
    func getFollowers(url: String, page: Int, completion: @escaping ([User]) -> ()) {
        guard var urlComp = URLComponents(string: url) else {
            return
        }
        urlComp.queryItems = [URLQueryItem(name: "page", value: "\(page)")]
        if let url = urlComp.url {
            self.userListRequest(url: url, completion: completion)
        }
    }
    
    private func userListRequest(url: URL, completion: @escaping ([User]) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            do {
                guard let validData = data else {
                    return
                }
                if let users = try JSONSerialization.jsonObject(with: validData) as? [[String: Any]] {
                    var result: [User] = []
                    for user in users {
                        let id = user["id"] as? Int ?? 0
                        let login = user["login"] as? String ?? ""
                        let link = user["html_url"] as? String ?? ""
                        let avatar = user["avatar_url"] as? String ?? ""
                        let followers = user["followers_url"] as? String ?? ""
                        result.append(User(id: id, login: login, link: link, avatar: avatar, followers: followers))
                    }
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    private func resizeImage(image: UIImage) -> UIImage? {
        let newWidth: CGFloat = 100
        let newHeight: CGFloat = 100
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0)
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func downloadImage(urlString: String, completion: @escaping (UIImage) -> ()) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let validData = data {
                        if let image = UIImage(data: validData) {
                            DispatchQueue.main.async {
                                if let resizedImage = self.resizeImage(image: image) {
                                    completion(resizedImage)
                                } else {
                                    completion(image)
                                }
                            }
                        }
                    }
                }
            }.resume()
        }
    }
    
}
