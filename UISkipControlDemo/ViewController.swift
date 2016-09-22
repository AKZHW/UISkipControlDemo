//
//  ViewController.swift
//  UISkipControlDemo
//
//  Created by AKsoftware on 16/9/22.
//  Copyright © 2016年 AKsoftware. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didStart(_ sender: AnyObject) {
        self.navigationController?.pushViewController(UISkipControlDemoViewController(name:"1"), animated: true)
        //failed
        self.navigationController?.pushViewController(UISkipControlDemoViewController(name:"2"), animated: true)
        //
        self.navigationController?.pushViewController(UISkipControlDemoViewController(name:"3"), animated: true, allowQueued: true, completionBlock: {
                self.navigationController?.pushViewController(UISkipControlDemoViewController(name:"4"), animated: true)
        })
        
        //1 3 4
    }

}

