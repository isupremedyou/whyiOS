//
//  PostController.swift
//  whyiOS
//
//  Created by Travis Chapman on 10/17/18.
//  Copyright © 2018 Travis Chapman. All rights reserved.
//

import Foundation

class PostController {
    
    static let baseURL = URL(string: "https://whydidyouchooseios.firebaseio.com/reasons")
    
    static func fetchPosts(completion: @escaping ([Post]?) -> Void) {
        
        guard let fullURL = baseURL?.appendingPathExtension("json")
            else { completion(nil) ; return }
        print(fullURL.absoluteString)
        
        var request = URLRequest(url: fullURL)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error: \(error) || \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else { completion(nil) ; return }
            
            do {
                let jd = JSONDecoder()
                let postsDict = try jd.decode([String : Post].self, from: data)
                let posts: [Post] = postsDict.compactMap({ (string, value) -> Post in
                    return value
                })
                
                completion(posts)
            } catch {
                print("Error: \(error) || \(error.localizedDescription)")
                completion(nil)
                return
            }
        }
        dataTask.resume()
    }
    
    static func postReason(name: String, reason: String, cohort: String, completion: @escaping ([Post]?) -> Void) {
        
        guard let fullURL = baseURL?.appendingPathExtension("json")
            else { completion(nil) ; return }
        
        let post = Post(cohort: cohort, name: name, reason: reason)
        
        var postData = Data()
        
        do {
            let je = JSONEncoder()
            postData = try je.encode(post)
        } catch {
            print("Error: \(error) || \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: fullURL)
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let dataTask = URLSession.shared.uploadTask(with: request, from: request.httpBody) { (data, _, error) in
            if let error = error {
                print("Error: \(error) || \(error.localizedDescription)")
                completion(nil)
                return
            } else if let data = data {
                guard let dataString = String(bytes: data, encoding: .utf8) else { completion(nil) ; return }
                print(dataString)
                print("HTTP POST was successful")
            }
            
            fetchPosts(completion: { (posts) in
                completion(posts)
            })
        }
        dataTask.resume()
    }
}
