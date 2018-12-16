//
//  DataService.swift
//  Complete
//
//  Created by Chuck Dibilio on 10/5/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import Foundation
import FirebaseDatabase

// Reference to Database
let DB_BASE = Database.database().reference()

class DataService {
    
    // Singleton
    static let instance = DataService()
    
    // --- References to firebase---
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("Users")
    private var _REF_CHANNELS = DB_BASE.child("Channels")
    private var _REF_TASKS = DB_BASE.child("Tasks")
    
    // Listeners
    private var channelListener: DatabaseHandle?
    private var taskListener: DatabaseHandle?
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_CHANNELS: DatabaseReference {
        return _REF_CHANNELS
    }
    
    var REF_TASKS: DatabaseReference {
        return _REF_TASKS
    }
    
    
    
    
    
    // --- Functions ---
    // --- Read Data from Data base
    // Get All Channels for user
    func getAllChannelsForUser(handler: @escaping (_ channel:Channel) -> ()) {
        
        // Submit Request
        channelListener = REF_CHANNELS.child(userID).observe(.childAdded) { (snapshot) in
            
            let id = snapshot.key
            let name = snapshot.childSnapshot(forPath:"name").value as! String
            let date = snapshot.childSnapshot(forPath: "date").value as! String
            let rank = snapshot.childSnapshot(forPath: "rank").value as! Int
   
            let channelObject = Channel(name: name, id: id, date: date, rank:rank)

            // Pass channelArray to handler
            handler(channelObject)
        }
    }
    
    // Get All Tasks for User
    func getAllTasksForUser(handler: @escaping (_ task:Task) -> ()) {
        
        // Submit Request
        taskListener = _REF_TASKS.child(userID).observe(.childAdded) { (snapshot) in
        
            // Make task object
            let id = snapshot.key
            let name = snapshot.childSnapshot(forPath:"name").value as! String
            let description = snapshot.childSnapshot(forPath:"description").value as! String
            let category = snapshot.childSnapshot(forPath:"category").value as! String
            let lane = snapshot.childSnapshot(forPath:"lane").value as! String
            let channelId = snapshot.childSnapshot(forPath:"channelId").value as! String
            let userId = snapshot.childSnapshot(forPath:"userId").value as! String
            let date = snapshot.childSnapshot(forPath:"date").value as! String
            let rank = snapshot.childSnapshot(forPath:"rank").value as! Int
            
            let currentTask = Task(name: name, id: id, description: description, category: category, lane: lane, channelID: channelId, userID: userId, date: date, rank: rank)
            handler(currentTask)
        }
    }
    
    // Get Total Task Count
    func getTotalTaskCount(handler: @escaping (_ count:Int)->()) {
        // Submit request
        REF_USERS.child(userID).child("Tasks").observeSingleEvent(of: .value) { (snapshot) in
            let count = snapshot.childSnapshot(forPath: "Total").value as! Int
            handler(count)
        }
    }
    
    // Get Total Channel Count
    func getTotalChannelCount(handler: @escaping (_ count:Int)->()) {
        // Submit request
        REF_USERS.child(userID).child("Channels").observeSingleEvent(of: .value) { (snapshot) in
            let count = snapshot.childSnapshot(forPath: "Total").value as! Int
            handler(count)
        }
    }
    
    
    
    
    
    
    // --- Upload Data to Database ---
    // Add Task to Database
    func uploadTaskForUser(task: Task, handler: @escaping (_ status:Bool)->()) {
        
        // Get Task Info
        let newTaskDict = [
            "name": task._name,
            "description": task._description,
            "channelId": task._channelID,
            "category": task._catgory,
            "lane": task._lane,
            "date": task._date,
            "userId": task._userID,
            "rank": task._rank] as [String : Any]
        
        // Get Task Key
        let newTask = REF_TASKS.child(userID).childByAutoId()
        let taskID = newTask.key
        
        // Add task to user under Task Root
        REF_TASKS.child(userID).child(taskID).setValue(newTaskDict)
        
        // Add task to user under User root
        REF_USERS.child(userID).child("Tasks").child("List").child(taskID).setValue(true)
        
        // Update Task Count (in database)
        REF_USERS.child(userID).child("Tasks").child("Total").setValue(totalTaskCount)
        
        // Return True
        handler(true)
    }
    
    // Add Channel to Datebase
    func uploadChannelForUser(channel: Channel, handler: @escaping (_ status:Bool, _ channel:Channel)->()) {
        
        // Get Task Info
        let newChannelDict = [
            "name": channel._name,
            "date": channel._date,
            "rank": channel._rank] as [String : Any]
        
        // Get Task Key
        let newChannel = REF_CHANNELS.child(userID).childByAutoId()
        let channelId = newChannel.key
        
        // Add id to channel model
        channel._id = channelId
        
        // Add channel to user under Channel Root
        REF_CHANNELS.child(userID).child(channelId).updateChildValues(newChannelDict)
        
        // Add channel to user under user root
        REF_USERS.child(userID).child("Channels").child("List").child(channelId).setValue(true)
        
        // Update total channel count
        REF_USERS.child(userID).child("Channels").child("Total").setValue(totalChannelCount)
        
        // Return True
        handler(true, channel)
    }
    
    
    
    
    
    // --- Delete Functions ---
    // Delte task from database
    func deleteTaskForUser(task:Task) {
        REF_TASKS.child(userID).child(task._id!).removeValue()
        REF_USERS.child(userID).child("Tasks").child("List").child(task._id!).removeValue()
        REF_USERS.child(userID).child("Tasks").child("Total").setValue(totalTaskCount)
    }
    
    // Delete task from database
    func deleteChannelForUser(channel:Channel, allTasks:[String:[Task]]) -> [String:[Task]] {
        REF_CHANNELS.child(userID).child(channel._id!).removeValue()
        REF_USERS.child(userID).child("Channels").child("List").child(channel._id!).removeValue()
        REF_USERS.child(userID).child("Channels").child("Total").setValue(totalChannelCount)
        
        // Delete all tasks in channel
        var currentTaskDict = allTasks
        for (category, taskArray) in currentTaskDict {
            for task in taskArray {
                if task._channelID == channel._id! {
                    // Delete from Database
                    totalChannelCount = totalChannelCount - 1
                    deleteTaskForUser(task: task)
                }
            }
        }
        return currentTaskDict
    }
    
    
    
    
    // Edit values in task
    func editTask(updatedData: [String:Any], taskId: String) {
        REF_TASKS.child(userID).child(taskId).updateChildValues(updatedData)
    }
    
    
    
    
    // --- User Functions ---
    // Add user to database
    func createDBUser(userId:String, userData:[String:String]) {
        REF_USERS.child(userId).setValue(userData)
    }
    
    
    
    
    // --- Listener Functions ---
    // Remove Channel Listener
    func removeChannelListener() {
        REF_CHANNELS.child(userID).removeObserver(withHandle: channelListener!)
    }
    
    // Remove Task Listener
    func removeTaskListener() {
        REF_TASKS.child(userID).removeObserver(withHandle: taskListener!)
    }
}

