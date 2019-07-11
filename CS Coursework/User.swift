//
//  User.swift
//  CS Coursework
//
//  Created by Nirvik Baruah on 19/12/18.
//  Copyright © 2018 Nirvik Baruah. All rights reserved.
//

import Foundation

//Needs to conform to NSCoding in order to be saved to local UserDefaults
//User class to store user details
class User: NSObject, NSCoding{
    //Private variables initialized
    //Static variable as should be the same regardless of user
    private static var numTasksDone: Int = 0
    private static var totalTasksAdded: Int = 0
    private var userName : String
    private var startTime: Date
    private var endTime: Date
    private var minBreakTime: Int
    private var minTaskTime: Int
    private var maxTaskTime: Int
    
    //Constructor - set object values
    init(name: String, startTime: Date, endTime: Date, minBreakTime: Int, minTaskTime: Int, maxTaskTime: Int) {
        self.userName = name
        self.startTime = startTime
        self.endTime = endTime
        self.minBreakTime = User.RoundUp(number: minBreakTime)
        self.minTaskTime = minTaskTime
        self.maxTaskTime = maxTaskTime
    }
    
    //Overloaded constructor for User Defaults loading
    init(name: String, startTime: Date, endTime: Date, minBreakTime: Int, minTaskTime: Int, maxTaskTime: Int, numTasksDone: Int, totalTasksAdded: Int){
        self.userName = name
        self.startTime = startTime
        self.endTime = endTime
        self.minBreakTime = User.RoundUp(number: minBreakTime)
        self.minTaskTime = minTaskTime
        self.maxTaskTime = maxTaskTime
        User.numTasksDone = numTasksDone
        User.totalTasksAdded = totalTasksAdded
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let numTasksDone = aDecoder.decodeInteger(forKey: "numTasksDone")
        let totalTasksAdded = aDecoder.decodeInteger(forKey: "totalTasksAdded")
        let userName = aDecoder.decodeObject(forKey: "userName") as! String
        let startTime = aDecoder.decodeObject(forKey: "startTime") as! Date
        let endTime = aDecoder.decodeObject(forKey: "endTime") as! Date
        let minBreakTime = aDecoder.decodeInteger(forKey: "minBreakTime")
        let minTaskTime = aDecoder.decodeInteger(forKey: "minTaskTime")
        let maxTaskTime = aDecoder.decodeInteger(forKey: "maxTaskTime")
        self.init(name: userName, startTime: startTime, endTime: endTime, minBreakTime: minBreakTime, minTaskTime: minTaskTime, maxTaskTime: maxTaskTime, numTasksDone: numTasksDone, totalTasksAdded: totalTasksAdded)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(User.numTasksDone, forKey: "numTasksDone")
        aCoder.encode(User.totalTasksAdded, forKey: "totalTasksAdded")
        aCoder.encode(userName, forKey: "userName")
        aCoder.encode(startTime, forKey: "startTime")
        aCoder.encode(endTime, forKey: "endTime")
        aCoder.encode(minBreakTime, forKey: "minBreakTime")
        aCoder.encode(minTaskTime, forKey: "minTaskTime")
        aCoder.encode(maxTaskTime, forKey: "maxTaskTime")
    }
    
    //Getter methods
    func GetNumTasksDone() -> Int{
        return User.numTasksDone
    }
    func GetUserName() -> String{
        return self.userName
    }
    func GetStartTime() -> Date{
        return self.startTime
    }
    func GetEndTime() -> Date{
        return self.endTime
    }
    func GetMinBreakTime() -> Int{
        return self.minBreakTime
    }
    func GetMinTaskTime() -> Int{
        return self.minTaskTime
    }
    func GetMaxTaskTime() -> Int{
        return self.maxTaskTime
    }
    func GetNumTasksAdded() -> Int{
        return User.totalTasksAdded
    }
    
    //Setter methods
    func IncrementTasksDone() -> Void{
        User.numTasksDone += 1
    }
    func SetUserName(name: String) -> Void{
        self.userName = name
    }
    func SetStartTime(time: Date) -> Void{
        self.startTime = time
    }
    func SetEndTime(time: Date) -> Void{
        self.endTime = time
    }
    func SetMinBreakTime(time: Int) -> Void{
        //Must be a multiple of 2 as my system is only accurate to the nearest minute
        self.minBreakTime = User.RoundUp(number: time)
    }
    func SetMinTaskTime(time: Int) -> Void{
        self.minTaskTime = time
    }
    func SetMaxTaskTime(time: Int) -> Void{
        self.maxTaskTime = time
    }
    func IncrementTasksAdded(){
        User.totalTasksAdded += 1
    }
    
    //Function for rounding up to nearest even number
    private static func RoundUp(number: Int) -> Int{
        if (number % 2 == 1){
            return number + 1
        }
        return number
    }
}
