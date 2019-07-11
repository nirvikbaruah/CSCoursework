//
//  AddTaskViewController.swift
//  CS Coursework
//
//  Created by Nirvik Baruah on 21/9/18.
//  Copyright © 2018 Nirvik Baruah. All rights reserved.
//

import UIKit
import AudioToolbox

class AddTaskViewController: UIViewController {
    
    //Private variables
    var taskList : TaskList?
    var formComplete: Bool = true
    
    //Inputs
    @IBOutlet var AddTaskController: UIView!
    @IBOutlet weak var taskTitleInp: TextField!
    @IBOutlet weak var priorityInp: UISegmentedControl!
    
    @IBOutlet weak var taskNotesInp: UITextView!
    @IBOutlet weak var startDateInp: TextField!
    private var startDate: Date?
    private var startDatePicker: UIDatePicker?
    @IBOutlet weak var endDateInp: TextField!
    private var endDate: Date?
    private var endDatePicker: UIDatePicker?
    
    @IBOutlet weak var revisionToggleInp: UISwitch!
    
    @IBAction func revisionTaskToggled(_ sender: Any) {
        if revisionToggleInp.isOn{
            //Disable start date input if revision task selected
            startDateInp.isEnabled = false
            startDateInp.allowsEditingTextAttributes = false
            startDateInp.backgroundColor = UIColor.lightGray
            startDateInp.textColor = UIColor.white
            startDateInp.text = "N/A"
        }
        else{
            startDateInp.isEnabled = true
            startDateInp.allowsEditingTextAttributes = true
            startDateInp.backgroundColor = nil
            startDateInp.textColor = UIColor.lightGray
            startDateInp.text = "Start Date"
        }
    }
    //Set instance of TaskList
    func SetTaskListInstance(obj: TaskList){
        taskList = obj
    }
    
    @IBAction func SaveClick(_ sender: Any) {
        AudioServicesPlaySystemSound(1306)
        if formComplete{
            performSegue(withIdentifier: "ReturnTaskList", sender: sender)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //Creates DatePicker which will open when textField pressed
        startDatePicker = UIDatePicker()
        startDatePicker?.datePickerMode = .dateAndTime
        //Adds done button to DatePicker
        let startToolbar = UIToolbar().ToolbarPiker(mySelect: #selector(AddTaskViewController.startDateChange(gestureRecognizer:)))
        startDateInp.inputAccessoryView = startToolbar
        //Dismiss if click viewcontroller
        let startTapGesture = UITapGestureRecognizer(target: self, action: #selector(AddTaskViewController.startDateChange(gestureRecognizer:)))
        //Bind tapGesture to current view
        view.addGestureRecognizer(startTapGesture)
        //Binds datePicker to textField
        startDateInp.inputView = startDatePicker
        
        //Creates DatePicker which will open when textField pressed
        endDatePicker = UIDatePicker()
        endDatePicker?.datePickerMode = .dateAndTime
        //Adds done button to DatePicker
        let endToolbar = UIToolbar().ToolbarPiker(mySelect: #selector(AddTaskViewController.endDateChange(gestureRecognizer:)))
        endDateInp.inputAccessoryView = endToolbar
        //Dismiss if click viewcontroller
        let endTapGesture = UITapGestureRecognizer(target: self, action: #selector(AddTaskViewController.endDateChange(gestureRecognizer:)))
        //Bind tapGesture to current view
        view.addGestureRecognizer(endTapGesture)
        //Binds datePicker to textField
        endDateInp.inputView = endDatePicker
    }
    
    @objc func startDateChange(gestureRecognizer: UITapGestureRecognizer){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        startDateInp.text = dateFormatter.string(from: startDatePicker!.date)
        startDate = startDatePicker!.date
        view.endEditing(true)
    }
    
    @objc func endDateChange(gestureRecognizer: UITapGestureRecognizer){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        endDateInp.text = dateFormatter.string(from: endDatePicker!.date)
        endDate = endDatePicker!.date
        view.endEditing(true)
    }
    
    //Pass data back to task list view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ReturnTaskList"
        {
            //Check state of user input toggle switch
            if (revisionToggleInp.isOn){
                taskList?.SetNewTaskDetails(newTask: taskTitleInp.text, newStartDate: Date(), newEndDate: endDate, newPriority: priorityInp.selectedSegmentIndex, newNotes: taskNotesInp.text, isRevisionInp: true)
            } else{
                taskList?.SetNewTaskDetails(newTask: taskTitleInp.text, newStartDate: startDate, newEndDate: endDate, newPriority: priorityInp.selectedSegmentIndex, newNotes: taskNotesInp.text, isRevisionInp: false)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
//From https://stackoverflow.com/questions/28048469/add-a-done-button-within-a-pop-up-datepickerview-in-swift
extension UIToolbar {
    
    func ToolbarPiker(mySelect : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}
