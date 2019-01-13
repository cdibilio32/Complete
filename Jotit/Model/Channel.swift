//
//  Channel.swift
//  Complete
//
//  Created by Chuck Dibilio on 10/5/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import Foundation

class Channel {
    
    // -- Properties --
    public var _name:String
    public var _id:String?
    public var _date:String
    public var _rank:Int
    
    // -- Functions --
    
    // Initializer
    init(name:String, id:String?, date:String, rank:Int) {
        self._name = name
        self._date = date
        self._rank = rank
        if (id != nil) {
            self._id = id
        }
    }
    
    // Is Channel in Array
    func isInArray(channelArray:[Channel]) -> Bool {
        var returnValue = false
        
        for channel in channelArray {
            if self._id == channel._id {
                returnValue = true
            }
        }
        return returnValue
    }
}
