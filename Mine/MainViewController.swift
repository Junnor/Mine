//
//  ViewController.swift
//  Mine
//
//  Created by Ju on 16/6/30.
//  Copyright © 2016年 Ju. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var remainLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = NSDate()
//        let calendar = NSCalendar.currentCalendar()
//        let components = calendar.components([.Day, .Month, .Year], fromDate: date)
        
        let cal = NSCalendar(calendarIdentifier:NSCalendarIdentifierGregorian)!
        let days = cal.rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: date)
        print(days.length)
        
    }
}

