//
//  TaskList.swift
//  CS Coursework
//
//  Created by Nirvik Baruah on 3/9/18.
//  Copyright © 2018 Nirvik Baruah. All rights reserved.
//

import UIKit
import GoogleSignIn
import GTMOAuth2
import GoogleAPIClientForREST
import AudioToolbox

//TaskList class
class TaskList: UITableViewController, GIDSignInUIDelegate {

    //Declare private variables
    //Arrays to manage both types of tasks
    var tasks = [Task]()
    var revisionTasks = RevisionPriorityQueue()
    var user: User?
    
    var inputTask:String!
    var newTaskAdded:Bool!
    var startDate: Date!
    var endDate: Date!
    var priority: Int!
    var taskNotes: String!
    var isRevisionTask: Bool!
    var wentThroughForm: Bool = false
    var clickedTaskNotes:String?
    var clickedTaskTitle:String?
    var clickedTaskDates:String?
    var clickedTaskPriority:String?
    
    var selectedTask: Task?
    
    //Gets reference to second VC so that can call methods on second table
    var dailyTimetable : Timetable?
    
    let userDefaults = UserDefaults.standard
    
    //Interface to change variables in this class
    func SetNewTaskDetails(newTask: String!, newStartDate: Date!, newEndDate: Date!, newPriority: Int!, newNotes: String!, isRevisionInp: Bool!){
        inputTask = newTask
        startDate = newStartDate
        endDate = newEndDate
        priority = newPriority
        taskNotes = newNotes
        isRevisionTask = isRevisionInp
        wentThroughForm = true
    }
        
    override func viewDidAppear(_ animated: Bool) {
        if(inputTask != nil && startDate != nil && endDate != nil && priority != nil && taskNotes != nil){
            var noDateOverlap: Bool = false
            for task in tasks{
                //Do not run if revision task
                if (task is RevisionTask == false && isRevisionTask == false){
                    //Algorithm taken from Ian Nelson on https://stackoverflow.com/questions/325933/determine-whether-two-date-ranges-overlap
                    if (startDate <= task.GetEndDate() && task.GetStartDate() <= endDate){
                        noDateOverlap = true
                        break
                    }
                }
            }
            //Alert if date clash
            if(noDateOverlap){
                let alert = UIAlertController(title: "Alert", message: "You already have a task during this time period!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action -> Void in}))
                self.present(alert, animated: true, completion: nil)
            }
            //Check if end time is before start time - if so present alert
            else if (endDate < startDate){
                let alert = UIAlertController(title: "Alert", message: "Task end time must be after start time!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action -> Void in}))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                addTask(title: inputTask, startDate: startDate, endDate: endDate, priority: priority, notes: taskNotes, isRevisionTask: isRevisionTask)
                dailyTimetable!.updateTable()
            }
        }
        else if wentThroughForm{
            let alert = UIAlertController(title: "Alert", message: "Not all fields complete!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action -> Void in}))
            self.present(alert, animated: true, completion: nil)
        }
        wentThroughForm = false
        
        //Serialise and save data to user defaults
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: tasks)
        userDefaults.set(encodedData, forKey: "tasks")
        userDefaults.synchronize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        inputTask = nil
        newTaskAdded = nil
        startDate = nil
        endDate = nil
        isRevisionTask = nil
        wentThroughForm = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsets.init(top: 10, left: 0, bottom: 0, right: 0);
        
        var decoded  = userDefaults.object(forKey: "tasks") as! Data?
        if(decoded != nil){
            let decodedTasks = NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! [Task]
            tasks = decodedTasks
            
            for element in tasks{
                if (element is RevisionTask){
                    revisionTasks.Push(task: element as! RevisionTask)
                }
            }
        }
        
        decoded  = userDefaults.object(forKey: "user") as! Data?
        if(decoded != nil){
            let decodedUser = NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! User
            user = decodedUser
        } else{
            //Default values if no user
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let startDate = formatter.date(from: "08:00")
            let endDate = formatter.date(from: "20:00")
            
            user = User(name: "User", startTime: startDate!, endTime: endDate!, minBreakTime: 10, minTaskTime: 30, maxTaskTime: 120)
        }

        //Gets reference to instance of daily timetable object
        dailyTimetable = tabBarController?.viewControllers?[1].children[0] as? Timetable
        
        //Create + button in top right
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(TaskList.TapAddItem(_:)))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    //Format custom cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_task", for: indexPath) as! CustomTableViewCell
        let newTask = tasks[indexPath.row]
        cell.cellTitle?.text = newTask.GetName()
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "dd/MM/yyyy"
        var strDate = dateFormatter.string(from: newTask.GetEndDate() as Date)
        cell.cellDetail?.text = strDate
        
        strDate = dateFormatter.string(from: newTask.GetStartDate() as Date)
        cell.cellStartDate?.text = strDate
        
        if newTask is RevisionTask{
            //Only display end date if revision task
            cell.cellStartDate?.text = ""
            cell.cellHyphen.text = ""
            strDate = dateFormatter.string(from: (newTask as! RevisionTask).GetFinalDeadline() as Date)
            cell.cellDetail?.text = strDate
            cell.cellBackground.backgroundColor = hexStringToUIColor(hex: "#999999")
        }
        else if (newTask.GetPriority() == 0){
            cell.cellBackground.backgroundColor = hexStringToUIColor(hex: "#58d68d")
        }
        else if (newTask.GetPriority() == 1){
            cell.cellBackground.backgroundColor = hexStringToUIColor(hex: "#f39c12")
        }
        else if (newTask.GetPriority() == 2){
            cell.cellBackground.backgroundColor = hexStringToUIColor(hex: "#ed532d")
        }
        else{
            cell.cellBackground.backgroundColor = hexStringToUIColor(hex: "#ff0000")
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func addTask(title: String, startDate: Date, endDate: Date, priority: Int, notes: String, isRevisionTask: Bool){
        //Check if append normal Task object or a RevisionTask object
        if (isRevisionTask){
            tasks.append(RevisionTask(taskName: title, start: startDate, end: endDate, final: endDate, taskNotes: notes, isFinished: false, priority: priority))
            RevisionTask.SetUser(newUser: user!)
            //Push to priority queue
            revisionTasks.Push(task: tasks.last as! RevisionTask)
        } else{
            //Push to normal queue
            tasks.append(Task(taskName: title, startDate: startDate, endDate: endDate, taskNotes: notes, isFinished: false, priority: priority))
        }
        let indexPath = IndexPath(row: tasks.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .left)
        //Increments static user variable for num tasks done
        user!.IncrementTasksAdded()
    }
    
    //Perform segue when click + button
    @objc func TapAddItem(_ sender: UIBarButtonItem)
    {
        AudioServicesPlaySystemSound(1306)
        performSegue(withIdentifier: "tapNewItem", sender: sender)
    }
    //Pass current instance of TaskList to AddTaskView class
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "tapNewItem"{
            if let navController = segue.destination as? UINavigationController {
                if let childVC = navController.topViewController as? AddTaskViewController {
                    childVC.SetTaskListInstance(obj: self)
                }
            }
        }
        //Set details in view task VC
        else if segue.identifier == "openViewTask"{
            if let navController = segue.destination as? UINavigationController {
                if let childVC = navController.topViewController as? DetailsViewController {
                    if let newTaskNotes = clickedTaskNotes{
                        if let newTaskTitle = clickedTaskTitle{
                            if let newTaskDate = clickedTaskDates{
                                if let newTaskPriority = clickedTaskPriority{
                                    if (newTaskNotes == "Task Notes"){
                                        childVC.SetModalText(newNotes: "None", newTitle: newTaskTitle, newDate: newTaskDate, newPriority: newTaskPriority)
                                    }
                                    else{
                                        childVC.SetModalText(newNotes: newTaskNotes, newTitle: newTaskTitle, newDate: newTaskDate, newPriority: newTaskPriority)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        //Set details in edit task VC
        else if segue.identifier == "editTaskSegue"{
            if let navController = segue.destination as? UINavigationController {
                if let childVC = navController.topViewController as? EditTaskViewController {
                    childVC.SetTaskInstance(selectedTask: selectedTask, taskListInstance: self)
                }
            }
        }
    }
    
    //Getter methods
    func GetNumTasks() -> Int{
        return tasks.count
    }
    func GetTaskAtRow(row: Int) -> Task{
        return tasks[row]
    }
    
    func GetTasks() -> [Task]{
        return tasks
    }
    
    func GetUser() -> User?{
        return user
    }
    
    func GetRevisionTasks() -> RevisionPriorityQueue{
        return revisionTasks
    }
    
    //For table cell deletion on swipe
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Function to delete row at index path
    func deleteTask(indexPath: IndexPath){
        let deletedTask = tasks[indexPath.row]
        tasks.remove(at: indexPath.row)
        if (deletedTask is RevisionTask){
            revisionTasks.Delete(task: deletedTask as! RevisionTask)
        }
        
        tableView.deleteRows(at: [indexPath], with: .top)
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: tasks)
        userDefaults.set(encodedData, forKey: "tasks")
        userDefaults.synchronize()
        
        //Updates other tables in app
        dailyTimetable!.updateTable()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.row < tasks.count
        {
            deleteTask(indexPath: indexPath)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Added to main thread so no delay in presenting UI element
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(1306)
            //Alert user so can choose what task action to carry out
            let alert = UIAlertController()
            alert.addAction(UIAlertAction(title: "View Task", style: .default, handler: { action in
                //Set variables so can pass to next VC in prepareforsegue method
                self.clickedTaskNotes = self.tasks[indexPath.row].GetNotes()
                self.clickedTaskTitle = self.tasks[indexPath.row].GetName()
                //Formatter to convert date to string
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd HH:mm"
                self.clickedTaskDates = formatter.string(from: self.tasks[indexPath.row].GetStartDate()) + " - " + formatter.string(from: self.tasks[indexPath.row].GetEndDate())
                //Convert priority to text
                if (self.tasks[indexPath.row].GetPriority() == 0){
                    self.clickedTaskPriority = "Low"
                } else if (self.tasks[indexPath.row].GetPriority() == 1){
                    self.clickedTaskPriority = "Medium"
                } else if (self.tasks[indexPath.row].GetPriority() == 2){
                    self.clickedTaskPriority = "High"
                } else{
                    self.clickedTaskPriority = "Google Calendar Task"
                }
                
                self.performSegue(withIdentifier: "openViewTask",sender: self)
            }))
            alert.addAction(UIAlertAction(title: "Edit Task", style: .default, handler: { action in
                self.selectedTask = self.tasks[indexPath.row]
                self.performSegue(withIdentifier: "editTaskSegue",sender: self)}))
            alert.addAction(UIAlertAction(title: "Mark As Complete", style: .default, handler: { action in
                    self.user!.IncrementTasksDone()
                    self.deleteTask(indexPath: indexPath)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action -> Void in}))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

