//
//  User.swift
//  ForPosition
//
//  Created by 李一正 on 2018/6/28.
//  Copyright © 2018年 lee. All rights reserved.
//

import Foundation

struct FriendsResult : Codable{
    var result : Bool
    var friends = [Friend]()
}

struct Friend : Codable {
    let id : String
    let friendName : String
    let lat : String
    let lon : String
    let lastUpdateDateTime : String
}

