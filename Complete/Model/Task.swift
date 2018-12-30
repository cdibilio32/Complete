//
//  Task.swift
//  Complete
//
//  Created by Chuck Dibilio on 10/5/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import Foundation

class Task {
    
    // --- Properties ---
    var _name:String
    var _id:String?
    var _description:String
    var _categoryId:String
    var _lane:String
    var _channelID:String
    var _userID:String
    var _date:String
    var _rank:Int
    
    // --- Functions ---
    
    // Initializer
    init(name:String, id:String?, description:String, categoryId:String, lane:String, channelID:String, userID:String, date:String, rank:Int) {
        self._name = name
        self._description = description
        self._categoryId = categoryId
        self._lane = lane
        self._channelID = channelID
        self._userID = userID
        self._date = date
        self._rank = rank
        
        if (id != nil) {
            self._id = id
        }
    }
    
    // Add Task To Dictionary
    func add(toDictionary dict:[String:[Task]]) -> [String:[Task]] {
        let categoryId = self._categoryId
        var returnDict = dict
        
        // If there isn't an entry for categoryId - make one
        if dict[categoryId] == nil {
            let currentArray = [self]
            returnDict[categoryId] = currentArray
        }
        // If there is an entry for categoryId - add it to entry
        else {
            var currentArray = returnDict[categoryId]
            currentArray?.append(self)
            returnDict[categoryId] = currentArray
        }
        return returnDict
    }
    
    // Is Task in Array
    func isInArray(taskArray:[Task]) -> Bool {
        var returnValue = false
        
        for task in taskArray {
            if self._id == task._id {
                returnValue = true
                return returnValue
            }
        }
        return returnValue
    }
    
    // Did the task change
    // By Lane
    func didTaskChange(byLane: String) -> Bool {
        if byLane != self._lane {
            return true
        }
        return false
    }
    
    // By Name
    func didTaskChange(byName: String) -> Bool {
        if byName != self._name {
            return true
        }
        return false
    }
    
    // By Description
    func didTaskChange(byDescription: String) -> Bool {
        if byDescription != self._description {
            return true
        }
        return false
    }
}
