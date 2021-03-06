//
//  constants.swift
//  Complete
//
//  Created by Chuck Dibilio on 10/17/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import Foundation

// --- Global Variables ---
var userID = "Logged Out"      // Holds user ID
var isNewUser = false           // Keeps track if a new user logged in
var justLoggedIn = false
var totalTaskCount = 0
var totalChannelCount = 0
var totalCategoryCount = 0
var newTaskOrCategoryCreated = false





// --- Global Constants ---
// Placeholder text for task description
let taskDescriptionPlaceHolder = "Task Description"
let taskDescPHForTaskDetail = "Any additional information related to the task"
let channelVCMargin:Double = 0.1

// Ad Mob
let adMobAppID = "ca-app-pub-5383101165774401~1391043887"
let adMobTestAdUnit = "ca-app-pub-3940256099942544/2934735716"
let adMobTaskVCAdUnit = "ca-app-pub-5383101165774401/3144244729"

// App store connect
let appSecret = "94810e51e24f4a78baff97e3d51be333"
let WeeklySubscriptionProductId = "ChuckDibilio.Jotitt"
let YearlySubscriptionProductId = "ChuckDibilio.Jotitt.YearlySubscription"

// Limits
let channelLimit = 25
let categoryLimit = 50
let taskLimit = 150
let channelLimitWithSubscription = 1000
let categoryLimitWithSubscription = 2500
let taskLimitWithSubscription = 5000
