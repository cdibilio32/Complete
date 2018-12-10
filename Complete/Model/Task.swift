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
    var _catgory:String
    var _lane:String
    var _channelID:String
    var _userID:String
    var _date:String
    
    // --- Functions ---
    
    // Initializer
    init(name:String, id:String?, description:String, category:String, lane:String, channelID:String, userID:String, date:String) {
        self._name = name
        self._description = description
        self._catgory = category
        self._lane = lane
        self._channelID = channelID
        self._userID = userID
        self._date = date
        
        if (id != nil) {
            self._id = id
        }
    }
    
    // Add Task To Dictionary
    func add(toDictionary dict:[String:[Task]]) -> [String:[Task]] {
        let category = self._catgory
        var returnDict = dict
        
        if category == "Short Term" {
            // If there are no short term tasks, create array and add first one
            if dict["Short Term"] == nil {
                let currentArray = [self]
                returnDict["Short Term"] = currentArray
            }
            // If there is a short term task, get array add task and put pack
            else {
                var currentArray = returnDict["Short Term"]
                currentArray?.append(self)
                returnDict["Short Term"] = currentArray
            }
        }
        else if category == "Medium Term" {
            if returnDict["Medium Term"] == nil {
                let currentArray = [self]
                returnDict["Medium Term"] = currentArray
            }
            else {
                var currentArray = returnDict["Medium Term"]
                currentArray?.append(self)
                returnDict["Medium Term"] = currentArray
            }
        }
        else {
            if returnDict["Long Term"] == nil {
                let currentArray = [self]
                returnDict["Long Term"] = currentArray
            }
            else {
                var currentArray = returnDict["Long Term"]
                currentArray?.append(self)
                returnDict["Long Term"] = currentArray
            }
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
