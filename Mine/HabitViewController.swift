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
private let MAXIMUM_HABIT_COUNT = 7

class HabitViewController: UIViewController {

    // MARL: - Public Properties
    
    var managedContext: NSManagedObjectContext!
    
    // MARK: - Private Properties
    
    private var fetchedResultsController: NSFetchedResultsController!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.backgroundColor = UIColor.blackColor()
        }
    }
    
    // MARK: - View Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest(entityName: "Habit")
        let remainDateSort = NSSortDescriptor(key: "remainDate", ascending: false)
        let addDateSort = NSSortDescriptor(key: "createDate", ascending: true)
        fetchRequest.sortDescriptors = [addDateSort, remainDateSort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: "MyHabit")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetch request error: \(error.localizedDescription)")
        }
        
        
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
                        strongSelf.addHabitWithTitle(tf.text!)
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
    
    private func addHabitWithTitle(title: String) {
        if fetchedResultsController.fetchedObjects?.count == MAXIMUM_HABIT_COUNT {
            let alert = UIAlertController(title: "提示",
                                          message: "最多添加 \(MAXIMUM_HABIT_COUNT) 个习惯",
                                          preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        } else {
            let habit = NSEntityDescription.insertNewObjectForEntityForName("Habit", inManagedObjectContext: managedContext) as! Habit
            habit.createDate = NSDate()
            habit.remainDate = FORM_HABIT_DAY_NUMBER
            habit.title = title
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Save create habit error: \(error.localizedDescription)")
            }
        }
    }
    
    private func fireNotification() {
        let calendar = NSCalendar.currentCalendar()
        let date = NSDate()
        let componentsForFireDate = calendar.components([.Day, .Hour, .Minute, .Second], fromDate: date)
        componentsForFireDate.hour = 24
        componentsForFireDate.minute = 0
        componentsForFireDate.second = 0
        
        let fireDateNotification = calendar.dateFromComponents(componentsForFireDate)
        let notification = UILocalNotification()
        notification.fireDate = fireDateNotification
        notification.timeZone = NSTimeZone.localTimeZone()
        notification.alertBody = nil
        notification.userInfo = nil
        notification.repeatInterval = .Day
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}

// MARK: - Table View DataSource

extension HabitViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (fetchedResultsController.fetchedObjects?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ID", forIndexPath: indexPath) as! HabitCell

        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    private func configureCell(cell: HabitCell, indexPath: NSIndexPath) {
        let habit = fetchedResultsController.objectAtIndexPath(indexPath) as! Habit
        
        let gradientView = GradientView(frame: cell.bounds)
        gradientView.colors = [
//            UIColor.blueColor(),
            UIColor.cyanColor(),
//            UIColor.greenColor(),
//            UIColor.yellowColor(),
            UIColor.redColor(),
            UIColor.magentaColor()
        ];
        gradientView.setNeedsDisplay()
        cell.backgroundView = gradientView
        
        cell.backgroundColor = UIColor.grayColor()
        
        cell.titleLabel.text = habit.title
        cell.addDateLabel.text = createDateText(habit.createDate!)
        cell.remainDateLabel.text = remainDateTextWithCreateDate(habit.createDate!)
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
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            let habit = fetchedResultsController.objectAtIndexPath(indexPath) as! Habit
            managedContext.deleteObject(habit)
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Delete habit error: \(error.localizedDescription)")
            }

        default:
            return
        }
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate

extension HabitViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as! HabitCell
            configureCell(cell, indexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}

