//
//  RevisionTask.swift
//  CS Coursework
//
//  Created by Nirvik Baruah on 26/12/18.
//  Copyright © 2018 Nirvik Baruah. All rights reserved.
//

import Foundation

//Subclass of Task
class RevisionTask: Task{
    //Static variable for all revision tasks
    static var user: User?
    
    //Final deadline is when task must be done by e.g when exam is
    //end date set in initialiser is to process when the task should be done
    var finalDeadline: Date?
    convenience init(taskName: String, start: Date, end : Date, final: Date, taskNotes : String, isFinished : Bool, priority : Int) {
        //Call superclass constructor
        self.init(taskName: taskName, startDate: start, endDate: end, taskNotes: taskNotes, isFinished: isFinished, priority: priority)
        self.finalDeadline = final
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let priority = aDecoder.decodeInteger(forKey: "priority")
        let taskName = aDecoder.decodeObject(forKey: "taskName") as! String
        let endDate = aDecoder.decodeObject(forKey: "endDate") as! Date
        let startDate = aDecoder.decodeObject(forKey: "startDate") as! Date
        let taskNotes = aDecoder.decodeObject(forKey: "taskNotes") as! String
        let isFinished = aDecoder.decodeBool(forKey: "isFinished")
        let finalDeadline = aDecoder.decodeObject(forKey: "finalDeadline") as! Date
        self.init(taskName: taskName, start: startDate, end: endDate, final: finalDeadline, taskNotes: taskNotes, isFinished: isFinished, priority: priority)
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.GetName(), forKey: "taskName")
        aCoder.encode(self.GetPriority(), forKey: "priority")
        aCoder.encode(self.GetStartDate(), forKey: "startDate")
        aCoder.encode(self.GetEndDate(), forKey: "endDate")
        aCoder.encode(self.GetNotes(), forKey: "taskNotes")
        aCoder.encode(self.GetIsFinished(), forKey: "isFinished")
        aCoder.encode(self.GetFinalDeadline(), forKey: "finalDeadline")
    }
    
    //Conform to NSCopying protocol
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = RevisionTask(taskName: GetName(), startDate: GetStartDate(), endDate: GetEndDate(), taskNotes: GetNotes(), isFinished: GetIsFinished(), priority: GetPriority())
        return copy
    }

    //Make class-level setter in order to set a class-level variable
    static func SetUser(newUser: User) -> Void{
        user = newUser
    }
    static func GetUser() -> User?{
        return user
    }

    func GetFinalDeadline() -> Date{
        return finalDeadline!
    }
    
    func SetFinalDeadline(newDate: Date){
        finalDeadline = newDate
    }
    
    //Other Getters and Setters defined in super class so no need to redefine
}

