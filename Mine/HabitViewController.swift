//
//  HabitViewController.swift
//  Mine
//
//  Created by Ju on 16/6/30.
//  Copyright © 2016年 Ju. All rights reserved.
//

import UIKit

class HabitViewController: UIViewController {

    private var habits: [Habit] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addHabit(sender: AnyObject) {
        let alert = UIAlertController(title: "添加习惯", message: "添加一个你将要达到习惯", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { textFiled in
            textFiled.placeholder = "习惯名称"
        }
        let addAction = UIAlertAction(title: "保持", style: .Default) { [weak self] action in
            if let strongSelf = self {
                if let tf = alert.textFields?.first {
                    let trimmed = tf.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    if !trimmed.isEmpty {
                        let habit = Habit(title: tf.text!, createDate: NSDate())
                        strongSelf.habits.append(habit)
                        strongSelf.tableView.reloadData()
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .Default) { action in
        }

        alert.addAction(addAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: - Table View DataSource

extension HabitViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ID", forIndexPath: indexPath)
        let habit = habits[indexPath.row]
        cell.textLabel?.text = habit.title
        cell.detailTextLabel?.text = "\(habit.createDate)"
        return cell
    }
}

// MARK: - Table View Delegate

extension HabitViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}

