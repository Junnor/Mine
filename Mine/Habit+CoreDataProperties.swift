//
//  Habit+CoreDataProperties.swift
//  Mine
//
//  Created by Ju on 16/7/9.
//  Copyright © 2016年 Ju. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Habit {

    @NSManaged var title: String?
    @NSManaged var remainDate: NSNumber?
    @NSManaged var createDate: NSDate?

}
