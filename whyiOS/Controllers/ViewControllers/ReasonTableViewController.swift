//
//  ReasonTableViewController.swift
//  whyiOS
//
//  Created by Travis Chapman on 10/17/18.
//  Copyright © 2018 Travis Chapman. All rights reserved.
//

import UIKit

class ReasonTableViewController: UITableViewController {

    // MARK: - Constants & Variables
    
    var posts = [Post]()
    
    
    // MARK: - Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refresh()
    }
    
    // MARK: - Actions
    
    @IBAction func addReasonButtonTapped(_ sender: UIBarButtonItem) {
        
        presentNewReasonAlert()
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        
        refresh()
    }
    
    @IBAction func refreshControlPulled(_ sender: UIRefreshControl) {
        
        refresh()
    }
    
}

// MARK: - Class Functions

extension ReasonTableViewController {
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reasonCell", for: indexPath) as? PostTableViewCell
            else { return UITableViewCell() }
        
        let post = posts[indexPath.row]
        
        cell.cohortLabel.text = post.cohort
        cell.nameLabel.text = post.name
        cell.reasonLabel.text = post.reason
        
        return cell
    }
    
    // MARK: - Other Functions
    
    func refresh() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PostController.fetchPosts { (posts) in
            self.posts = posts ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    func presentNewReasonAlert() {
        
        let alert = UIAlertController(title: "Add Your Reason!", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (cohortTextField) in
            cohortTextField.placeholder = "Which Cohort are you in?"
        }
        
        alert.addTextField { (nameTextField) in
            nameTextField.placeholder = "What is your name?"
        }
        
        alert.addTextField { (reasonTextField) in
            reasonTextField.placeholder = "What is your reason for learning iOS?"
        }
        
        let dismiss = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        let post = UIAlertAction(title: "Post!", style: .default) { (_) in
            guard let cohort = alert.textFields?.first?.text, !cohort.isEmpty,
                let name = alert.textFields?[1].text, !name.isEmpty,
                let reason = alert.textFields?.last?.text, !reason.isEmpty
                else { return }
            
            PostController.postReason(name: name, reason: reason, cohort: cohort, completion: { (posts) in
                self.posts = posts ?? []
                self.refresh()
            })
        }
        
        alert.addAction(dismiss)
        alert.addAction(post)
        
        present(alert, animated: true)
    }
}
