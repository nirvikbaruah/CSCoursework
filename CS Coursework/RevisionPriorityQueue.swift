//
//  RevisionPriorityQueue.swift
//  CS Coursework
//
//  Created by Nirvik Baruah on 28/12/18.
//  Copyright © 2018 Nirvik Baruah. All rights reserved.
//

//Priority queue to represent RevisionTasks

import Foundation

//Needs to conform to NS protocols to enable copying by value
class RevisionPriorityQueue: NSObject, NSCopying{
    //Array representing queue. No need for a priority array as RevisionTask
    //object contains priority attribute
    var queue = [RevisionTask]()
    
    //Represents next free slot. Also represents array size
    var tailPointer: Int
    
    //Polymorphism of constructors
    override init() {
        self.tailPointer = 0
    }
    
    init(queue: [RevisionTask], pointer: Int){
        self.queue = queue
        self.tailPointer = pointer
    }
    
    func GetCount() -> Int{
        return self.tailPointer
    }
    
    //Pop
    func Pop() -> RevisionTask{
        self.tailPointer -= 1
        let firstElement: RevisionTask = self.queue[0]
        self.queue.remove(at: 0)
        return firstElement
    }
    
    //Peek
    func Peek() -> RevisionTask?{
        return self.queue.first
    }
    
    //Push
    func Push(task: RevisionTask){
        self.queue.append(task)
        self.tailPointer += 1
        Sort()
    }
    
    //Delete
    func Delete(task: RevisionTask){
        //Removes revision task element from queue
        self.queue = self.queue.filter {$0 != task}
        self.tailPointer -= 1
    }
    
    //Sort queue by priority first then by final deadline
    func Sort(){
        
        self.queue.sort { (elem1, elem2) -> Bool in
            //Sort bu priority first
            if elem1.GetPriority() > elem2.GetPriority() {
                return true
            }
            // Sort bu deadline next
            if elem1.GetPriority() == elem2.GetPriority() {
                return elem1.GetFinalDeadline() < elem2.GetFinalDeadline()
            }
            return false
        }
    }
    
    func GetQueue() -> [RevisionTask]{
        return queue
    }
    
    //Conform to NSCopying protocol to allow copying by value
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = RevisionPriorityQueue(queue: GetQueue(), pointer: GetCount())
        return copy
    }
    
}
