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
    
    // Initializer
    init(name:String, id:String?, channelId:String) {
        self._name = name
        self._channelId = channelId
        if (id != nil) {
            self._id = id
        }
    }
    
}
