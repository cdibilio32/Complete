//
//  Category.swift
//  Complete
//
//  Created by Chuck Dibilio on 12/17/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import Foundation

class Category {
    
    // --- Properties ---
    public var _name:String
    public var _id:String?
    public var _channelId:String
    public var _rank:Int
    
    // Initializer
    init(name:String, id:String?, channelId:String, rank:Int) {
        self._name = name
        self._channelId = channelId
        self._rank = rank
        if (id != nil) {
            self._id = id
        }
    }
    
    
    
    
    // --- Functions ---
    // Remove Tasks from associated Categories
    func removeTasks(allTasks:[String:[Task]]) -> [String:[Task]] {
        var newAllTasks = allTasks
        newAllTasks.removeValue(forKey: self._id!)
        return newAllTasks
    }
    
}
