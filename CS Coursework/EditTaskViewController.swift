//
//  EditTaskViewController.swift
//  CS Coursework
//
//  Created by Nirvik Baruah on 8/1/19.
//  Copyright © 2019 Nirvik Baruah. All rights reserved.
//

import UIKit

class EditTaskViewController: UIViewController {
    
    //Private variables
    var task: Task?
    var taskList: TaskList?
    var wasOriginallyRevisionTask: Bool = false
    let formatter = DateFormatter()
    
    //Inputs from page
    @IBOutlet weak var taskNameInp: TextField!
    @IBOutlet weak var startTimeInp: TextField!
    @IBOutlet weak var endTimeInp: TextField!
    @IBOutlet weak var priorityInp: UISegmentedControl!
    @IBOutlet weak var notesInp: TextView!
    
    @IBAction func saveTask(_ sender: Any) {
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        var completeForm: Bool = true
        var alert: UIAlertController
        //Only potential error source is date is wrong format so only need to check that
        print(startTimeInp.text!)
        if (formatter.date(from: startTimeInp.text!) != nil){
            task!.SetStartDate(date: formatter.date(from: startTimeInp.text!)!)
        }
        else {
            //Invalid format
            completeForm = false
            alert = UIAlertController(title: "Alert", message: "Start date is in wrong format!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action -> Void in}))
            self.present(alert, animated: true, completion: nil)
        }
        
        if (formatter.date(from: endTimeInp.text!) != nil){
            task!.SetEndDate(date: formatter.date(from: endTimeInp.text!)!)
        }
        else {
            //Invalid format
            completeForm = false
            alert = UIAlertController(title: "Alert", message: "End date is in wrong format!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action -> Void in}))
            self.present(alert, animated: true, completion: nil)
        }
        
        if (completeForm){
            task!.SetName(name: taskNameInp.text!)
            task!.SetPriority(enteredPriority: priorityInp.selectedSegmentIndex)
            task!.SetNotes(notes: notesInp.text!)
            taskList!.tableView.reloadData()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Sets details of input form
    func SetDetails(){
        taskNameInp.text = task!.GetName()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        startTimeInp.text = formatter.string(from: task!.GetStartDate())
        endTimeInp.text = formatter.string(from: task!.GetEndDate())
        notesInp.text = task!.GetNotes()
        priorityInp.selectedSegmentIndex = task!.GetPriority()

    }
    
    //Pass data on once form complete 
    func SetTaskInstance(selectedTask: Task?, taskListInstance: TaskList){
        _ = self.view
        task = selectedTask
        taskList = taskListInstance
        wasOriginallyRevisionTask = false
        SetDetails()
    }

}

