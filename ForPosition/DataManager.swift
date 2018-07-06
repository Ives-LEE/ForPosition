//
//  DataManager.swift
//  ForPosition
//
//  Created by 李一正 on 2018/6/28.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit


class DataManager{
    
   
    let myName = "LEE_I_CHENG"
    let group = "cp101"
    static let BASIC_URL = "http://class.softarts.cc/FindMyFriends/"
    var  sendMyPositionURL = BASIC_URL + "updateUserLocation.php?"
    var getFriendURL = BASIC_URL + "queryFriendLocations.php?GroupName=cp101"
    //GroupName=zz888&UserName=Kent&Lat=21.123456&Lon=121.1 23456
    //GroupName=
    
    typealias DownloadHandler = (Error?,[Friend]?) -> Void
    
    init() {
        
    }
    
    
    func dataSender(lat:String,lon:String){
        var data = sendMyPositionURL+"GroupName=\(group)&UserName=\(myName)&Lat=\(lat)&Lon=\(lon)"
        guard let url = URL(string:data) else {
            assertionFailure("get fail.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data,response,error) in
        
            print("Coordinate: \(lat),\(lon)")

        }
        task.resume()
        
    }
    
    func dateReceiver(doneHandler : @escaping DownloadHandler) {
        guard let url = URL(string:getFriendURL) else {
            assertionFailure("get fail.")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data,response,error) in
            
            guard let data = data ,let result = try? JSONDecoder().decode(FriendsResult.self, from: data) else{
                print("fail")
                return
            }
            DispatchQueue.main.async {
                doneHandler(nil,result.friends)
            }
        }
        task.resume()
        
    }
}


