//
//  UISkipControlDemoViewController.swift
//  UISkipControlDemo
//
//  Created by AKsoftware on 16/9/22.
//  Copyright © 2016年 AKsoftware. All rights reserved.
//

import Foundation
import UIKit

class UISkipControlDemoViewController: UIViewController {
    var label:UILabel?
    init(name:String) {
        super.init(nibName: nil
            , bundle: nil
        )
        self.label = UILabel()
        self.label?.textAlignment = NSTextAlignment.center
        self.label?.text = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
       self.label?.frame = self.view.bounds
        self.view.addSubview(self.label!)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
