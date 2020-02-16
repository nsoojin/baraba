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
    
    private let baraba = Baraba(configuration: .default)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.dataSource = self
        barabaButton?.title = "Enable"
        
        baraba.scrollView = tableView
    }
    
    @IBAction func barabaButtonPressed(_ sender: UIBarButtonItem) {
        if baraba.isRunning {
            sender.title = "Enable"
            baraba.pause()
        } else {
            sender.title = "Pause"
            baraba.resume()
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
