//
//  Task.swift
//  CS Coursework
//
//  Created by Nirvik Baruah on 7/9/18.
//  Copyright © 2018 Nirvik Baruah. All rights reserved.
//

import Foundation

//Needs to conform to NSCoding in order to be saved to local UserDefaults
class Task: NSObject, NSCoding, NSCopying{
    //Private variables initialized
    private var taskName : String
    private var endDate : Date
    private var startDate : Date
    //Optional value
    private var taskNotes : String?
    private var isFinished : Bool
    //Highest priority is most important
    private var priority : Int
    
    //Constructor - set object values
    init(taskName: String, startDate: Date, endDate : Date, taskNotes : String, isFinished : Bool, priority : Int) {
        self.taskName = taskName
        self.startDate = startDate
        self.endDate = endDate
        self.taskNotes = taskNotes
        self.isFinished = isFinished
        self.priority = priority
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let priority = aDecoder.decodeInteger(forKey: "priority")
        let taskName = aDecoder.decodeObject(forKey: "taskName") as! String
        let endDate = aDecoder.decodeObject(forKey: "endDate") as! Date
        let startDate = aDecoder.decodeObject(forKey: "startDate") as! Date
        let taskNotes = aDecoder.decodeObject(forKey: "taskNotes") as! String
        let isFinished = aDecoder.decodeBool(forKey: "isFinished")
        self.init(taskName: taskName, startDate: startDate, endDate: endDate, taskNotes: taskNotes, isFinished: isFinished, priority: priority)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(taskName, forKey: "taskName")
        aCoder.encode(priority, forKey: "priority")
        aCoder.encode(startDate, forKey: "startDate")
        aCoder.encode(endDate, forKey: "endDate")
        aCoder.encode(taskNotes, forKey: "taskNotes")
        aCoder.encode(isFinished, forKey: "isFinished")
    }
    
    /*
     Overloaded constructor for Google Classroom tasks
    convenience init(test : String){
        self.init(...)
    }
     */
    
    //Getter methods
    func GetName() -> String{
        return self.taskName
    }
    func GetEndDate() -> Date{
        return self.endDate
    }
    func GetStartDate() -> Date{
        return self.startDate
    }
    func GetNotes() -> String{
        //Unwrapping optional
        return self.taskNotes!
    }
    func GetIsFinished() -> Bool{
        return self.isFinished
    }
    func GetPriority() -> Int{
        return self.priority
    }
    
    //Setter methods
    func SetName(name : String) -> Void{
        self.taskName = name
    }
    func SetEndDate(date : Date) -> Void{
        self.endDate = date
    }
    func SetStartDate(date : Date) -> Void{
        self.startDate = date
    }
    func SetNotes(notes : String) -> Void{
        self.taskNotes = notes
    }
    func SetIsFinished() -> Void{
        self.isFinished = !self.isFinished
    }
    func SetPriority(enteredPriority : Int) -> Void{
        self.priority = enteredPriority
    }
    
    //Conform to NSCopying protocol to allow copy by value
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Task(taskName: GetName(), startDate: GetStartDate(), endDate: GetEndDate(), taskNotes: GetNotes(), isFinished: GetIsFinished(), priority: GetPriority())
        return copy
    }
}
