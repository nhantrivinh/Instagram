//
//  ViewController.swift
//  Instagram
//
//  Created by Jayven Nhan on 2/16/17.
//  Copyright © 2017 Jayven Nhan. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var newArray = [NSDictionary]()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        fetchData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        let finalUrl = self.newArray[indexPath.row].value(forKeyPath: "images.low_resolution.url") as! String
        let image = self.newArray[indexPath.row]["images"] as! NSDictionary
        let low_res = image["low_resolution"] as! NSDictionary
        let url = low_res["url"] as! String
        
        
        
        cell.imgView.setImageWith(URL(string: finalUrl)!)
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! PhotoDetailsViewController
        var indexPath = tableView.indexPath(for: sender as! UITableViewCell)
        let finalUrl = self.newArray[indexPath!.row].value(forKeyPath: "images.low_resolution.url") as! String
        vc.photoUrl = finalUrl
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        fetchData()
       
    }
    
    func fetchData() {
        let userId = "435569061"
        let accessToken = "435569061.c66ada7.5aac54e38a6a46169f9264f4242cdd99"
        let url = URL(string: "https://api.instagram.com/v1/users/\(userId)/media/recent/?access_token=\(accessToken)")
        
        if let url = url {
            let request = URLRequest(
                url: url,
                cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
                timeoutInterval: 10)
            let session = URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: nil,
                delegateQueue: OperationQueue.main)
            let task = session.dataTask(
                with: request,
                completionHandler: { (dataOrNil, response, error) in
                    if let data = dataOrNil {
                        if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                            
                            if let photoData = responseDictionary["data"] as? [NSDictionary] {
                                self.newArray = photoData
                                print("response: \(self.newArray)")
                                print(self.newArray.count)
                                self.tableView.reloadData()
                                self.refreshControl.endRefreshing()
                            }
                        }
                    }
            })
            task.resume()
        }
    }
}

