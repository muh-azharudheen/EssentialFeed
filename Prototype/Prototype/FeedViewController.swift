//
//  FeedViewController.swift
//  Prototype
//
//  Created by Muhammed Azharudheen on 20/01/2022.
//

import UIKit

class FeedViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 10 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "FeedImageCell")!
    }
}
