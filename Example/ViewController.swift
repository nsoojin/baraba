//
//  ViewController.swift
//  Example
//
//  Created by Soojin Ro on Feb 14, 2020.
//  Copyright © 2020 nsoojin. All rights reserved.
//

import UIKit
import Baraba

class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView?
    @IBOutlet private weak var barabaButton: UIBarButtonItem?
    
    private var baraba: Baraba?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.dataSource = self
        barabaButton?.title = "Pause"
        
        baraba = Baraba(configuration: .automatic)
        baraba?.scrollView = tableView
        baraba?.delegate = self
        baraba?.resume()
    }
    
    @IBAction func barabaButtonPressed(_ sender: UIBarButtonItem) {
        if baraba?.isActive == true {
            sender.title = "Enable"
            baraba?.pause()
        } else {
            sender.title = "Pause"
            baraba?.resume()
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1000
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        
        cell.textLabel?.text = "hello \(indexPath.row)"
        
        return cell
    }
}

extension ViewController: BarabaDelegate {
    func barabaDidStartScrolling(_ baraba: Baraba) {
        // do something
    }
    
    func barabaDidStopScrolling(_ baraba: Baraba) {
        // do something
    }
    
    func baraba(_ baraba: Baraba, didFailWithError error: Error) {
        switch error {
        case BarabaError.cameraUnauthorized:
            ()
        case BarabaError.unsupportedConfiguration:
            ()
        default:
            ()
        }
    }
}
