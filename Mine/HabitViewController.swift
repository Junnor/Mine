//
//  HabitViewController.swift
//  Mine
//
//  Created by Ju on 16/6/30.
//  Copyright © 2016年 Ju. All rights reserved.
//

import UIKit
import CoreData

private let FORM_HABIT_DAY_NUMBER = 21

class HabitViewController: UIViewController {

    // MARL: - Public Properties
    
    var managedContext: NSManagedObjectContext!
    
    // MARK: - Private Properties
    
    private var habits: [Target] = []
    private var entity: NSEntityDescription!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        entity = NSEntityDescription.entityForName("Target", inManagedObjectContext: managedContext)
        
        loadHabitIfNeeded()
    }
    
    // MARK: - Helper

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
                        strongSelf.addTarget(tf.text!)
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
    
    private func addTarget(text: String) {

        let target = Target(entity: entity, insertIntoManagedObjectContext: managedContext)
        
        target.createDate = NSDate()
        target.remainDate = FORM_HABIT_DAY_NUMBER
        target.title = text
        
        do {
            try managedContext.save()
            habits.append(target)
            tableView.reloadData()
        } catch let error as NSError {
            print("Save create habit error: \(error.localizedDescription)")
        }
    }
    
    private func loadHabitIfNeeded() {
        let fetchRequest = NSFetchRequest(entityName: "Target")
        let count = managedContext.countForFetchRequest(fetchRequest, error: nil)
        if count == 0 { return }
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest) as! [Target]
            habits = results
            tableView.reloadData()
        } catch let error as NSError {
            print("Fetch exist habit error: \(error.localizedDescription)")
        }
    }
    
}

// MARK: - Table View DataSource

extension HabitViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ID", forIndexPath: indexPath) as! TargetCell
        let habit = habits[indexPath.row]

        cell.titleLabel.text = habit.title
        cell.addDateLabel.text = createDateText(habit.createDate!)
        cell.remainDateLabel.text = remainDateTextWithCreateDate(habit.createDate!)
        
        return cell
    }
    
    private func createDateText(date: NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day, .Month, .Year], fromDate: date)
        return "Created: \(components.year)-\(components.month)-\(components.day)"
    }
    
    private func remainDateTextWithCreateDate(createDate: NSDate) -> String {
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDayForDate(createDate)
        let date2 = calendar.startOfDayForDate(NSDate())
        
        let flags = NSCalendarUnit.Day
        let components = calendar.components(flags, fromDate: date1, toDate: date2, options: [])
        let remainDays = max(FORM_HABIT_DAY_NUMBER - components.day, 0)
        return "Remain: \(remainDays) day(s)"
    }
}

// MARK: - Table View Delegate

extension HabitViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}

