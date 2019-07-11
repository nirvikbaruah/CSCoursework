//
//  Timetable.swift
//  CS Coursework
//
//  Created by Nirvik Baruah on 3/9/18.
//  Copyright © 2018 Nirvik Baruah. All rights reserved.
//

import UIKit
import UserNotifications
import GoogleAPIClientForREST
import GTMOAuth2
import GoogleSignIn

//Daily Timetable class
class Timetable: UITableViewController{

    //Private variables
    var tasks = [Task]()
    //Gets instance of TaskList to access task list
    var taskListReference: TaskList?
    var revisionTasks: RevisionPriorityQueue?
    
    var user: User?

    let userDefaults = UserDefaults.standard
    
    //Taken from https://stackoverflow.com/questions/50227276/obtaining-google-calendar-in-swift
    /// Creates calendar service with current authentication
    fileprivate lazy var calendarService: GTLRCalendarService? = {
        let service = GTLRCalendarService()
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them
        service.shouldFetchNextPages = true
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        service.isRetryEnabled = true
        service.maxRetryInterval = 15
        
        guard let currentUser = GIDSignIn.sharedInstance().currentUser,
            let authentication = currentUser.authentication else {
                return nil
        }
        
        service.authorizer = authentication.fetcherAuthorizer()
        return service
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Get google calendar events first
        getEvents(calendarId: "primary")
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.contentInset = UIEdgeInsets.init(top: 10, left: 0, bottom: 0, right: 0);
        
        updateTable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateTable()
    }
    
    
    //Keeps tasks array consistent across VCs
    //Refreshes tableview once array data changed
    func updateTable(){
        taskListReference = tabBarController?.viewControllers?[0].children[0] as? TaskList
        tasks = taskListReference!.GetTasks()
        user = taskListReference!.GetUser()
        revisionTasks = taskListReference!.GetRevisionTasks()
        
        //Filters elements which are due today so only they appear and removes all revision tasks so fresh
        tasks = tasks.filter { Calendar.current.isDateInToday($0.GetEndDate()) }
        tasks = tasks.sorted(by: { $0.GetStartDate() < $1.GetStartDate() })
        tasks.removeAll(where: {$0 is RevisionTask})
        
        //Only run if revision tasks exist
        if (revisionTasks!.GetCount() > 0){
        //Since my client only wants to do revision tasks in an uninterrupted block of time which is bigger than 30 minutes but smaller than 2 hours, I will iterate through my tasks for the day, find when a block like this exists, and pop a revision task
            
            //Create a copy of revisionTasks array so do not lose original tasks when popping
            //Use copy from NSCopy protocol to allow copy by value
            var taskListCopy = revisionTasks!.copy() as! RevisionPriorityQueue
            
            //Checks that not all tasks are revision tasks
            if (tasks.filter({$0 is RevisionTask}).count < tasks.count){
                //Creates copy of normal tasks to easily access times between tasks
                var normalTasksCopy = [Task]()
                for element in tasks{
                    normalTasksCopy.append(element.copy() as! Task)
                }
                
                //For slotting between start of day and first task
                var timeAvailable = findAvailableTime(startDate: user!.GetStartTime(), endDate: normalTasksCopy[0].GetStartDate())
                if (timeAvailable >= user!.GetMinTaskTime()){
                    taskListCopy = slotTasks(timeAvailable: timeAvailable, startTime: user!.GetStartTime(), taskListCopy: taskListCopy)
                }
                //For tasks in the middle of the day
                if (normalTasksCopy.count > 1){
                    for i in 0...normalTasksCopy.count - 2{
                        timeAvailable = findAvailableTime(startDate: normalTasksCopy[i].GetEndDate(), endDate: normalTasksCopy[i+1].GetStartDate())
                        if (timeAvailable >= user!.GetMinTaskTime()){
                            taskListCopy = slotTasks(timeAvailable: timeAvailable, startTime: normalTasksCopy[i].GetEndDate(), taskListCopy: taskListCopy)
                        }
                    }
                }
                //For slotting between last task and end of day
                timeAvailable = findAvailableTime(startDate: normalTasksCopy.last!.GetEndDate(), endDate: user!.GetEndTime())
                if (timeAvailable >= user!.GetMinTaskTime()){
                    taskListCopy = slotTasks(timeAvailable: timeAvailable, startTime: normalTasksCopy.last!.GetEndDate(), taskListCopy: taskListCopy)
                }
            }
            //Full day is for revision
            else{
                let timeAvailable = findAvailableTime(startDate: user!.GetStartTime(), endDate: user!.GetEndTime())
                tasks.removeAll()
                taskListCopy = slotTasks(timeAvailable: timeAvailable, startTime: user!.GetStartTime(), taskListCopy: taskListCopy)
            }
        }
        scheduleNotifications()
        self.tableView.reloadData()
    }
    
    //Function to slot tasks in a given time period
    //Algorithm:
    //1. Set task Start Time
    //2. Add timePerTask to start time and set this date as end time
    //3. Check if still within users day
    //4. If so, start time = end time
    //5. Pop task
    //6. Loop for the smallest of either numRevTasksToDo or number of revision tasks
    func slotTasks(timeAvailable: Int, startTime: Date, taskListCopy: RevisionPriorityQueue) -> RevisionPriorityQueue{
        let minTaskTime = user!.GetMinTaskTime()
        let maxTaskTime = user!.GetMaxTaskTime()
        let breakTime = user!.GetMinBreakTime() * 2
        var numRevTasksToDo = taskListCopy.GetCount()
        if (numRevTasksToDo > 0 && timeAvailable >= minTaskTime + breakTime){
            var timePerTask = timeAvailable / numRevTasksToDo
            while ((timePerTask > maxTaskTime + breakTime || timePerTask < minTaskTime + breakTime) && numRevTasksToDo > 1){
                numRevTasksToDo -= 1
                timePerTask = timeAvailable / numRevTasksToDo
            }
            //Check if successful in dividing time - otherwise just allocate max/min time per task
            if (timePerTask > maxTaskTime + breakTime){
                timePerTask = min(timeAvailable, maxTaskTime + breakTime)
                numRevTasksToDo = taskListCopy.GetCount()
            }
            else if (timePerTask < minTaskTime + breakTime){
                timePerTask = max(timeAvailable, minTaskTime + breakTime)
                numRevTasksToDo = 1
            }
            //Add half the break time in minutes at start for break
            var taskStartTime = combineDateWithTime(date: Date(), time: startTime.addingTimeInterval(Double((breakTime/2) * 60)))
            //Take away half the break time as half the break time used at start and end for break
            var taskEndTime = taskStartTime!.addingTimeInterval(Double((timePerTask - (breakTime)) * 60))
            for _ in 1...numRevTasksToDo{
                taskListCopy.Peek()!.SetStartDate(date: taskStartTime!)
                taskListCopy.Peek()!.SetEndDate(date: taskEndTime)
                tasks.append(taskListCopy.Pop())
                //Add 5 minutes between tasks as break
                //Take away 5 minutes at end as total time per task includes break
                //Multiply by 60 to convert minutes to seconds
                taskStartTime = taskEndTime.addingTimeInterval(Double((breakTime/2) * 60))
                taskEndTime = taskStartTime!.addingTimeInterval(Double((timePerTask - (breakTime)) * 60))
            }
        }
        //Must sort after every slotting as can add any number of tasks so not a case of simple swapping of elements
        tasks = tasks.sorted(by: { $0.GetStartDate() < $1.GetStartDate() })
        return taskListCopy
    }
    
    //Finds how many minutes free between two dates
    func findAvailableTime(startDate: Date, endDate: Date) -> Int{
        var time: Int
        let calendar = Calendar.current
        let startTime = calendar.dateComponents([.hour, .minute], from: startDate)
        let endTime = calendar.dateComponents([.hour, .minute], from: endDate)
        time = max(0, calendar.dateComponents([.minute], from: startTime, to: endTime).minute!)
        return time
    }
    
    //Format custom cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_task", for: indexPath) as! CustomTableViewCell
        let newTask = tasks[indexPath.row]
        cell.dailyListTitle?.text = newTask.GetName()
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "h:mm a"
        var strDate = dateFormatter.string(from: newTask.GetEndDate() as Date)
        cell.dailyListDetail?.text = strDate
        
        strDate = dateFormatter.string(from: newTask.GetStartDate() as Date)
        cell.dailyListStartDate?.text = strDate
        
        if newTask is RevisionTask{
            cell.dailyListBackground.backgroundColor = hexStringToUIColor(hex: "#999999")
        }
        else if (newTask.GetPriority() == 0){
            cell.dailyListBackground.backgroundColor = hexStringToUIColor(hex: "#58d68d")
        }
        else if (newTask.GetPriority() == 1){
            cell.dailyListBackground.backgroundColor = hexStringToUIColor(hex: "#f39c12")
        }
        else if (newTask.GetPriority() == 2){
            cell.dailyListBackground.backgroundColor = hexStringToUIColor(hex: "#ed532d")
        }
        else{
            cell.dailyListBackground.backgroundColor = hexStringToUIColor(hex: "#ff0000")
        }
        
        cell.selectionStyle = .none
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    //Function to combine date with time
    //Taken from https://gist.github.com/justinmfischer/0a6edf711569854c2537
    func combineDateWithTime(date: Date, time: Date) -> Date?{
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)

        
        var mergedComponments = DateComponents()
        mergedComponments.year = dateComponents.year
        mergedComponments.month = dateComponents.month
        mergedComponments.day = dateComponents.day
        mergedComponments.hour = timeComponents.hour
        mergedComponments.minute = timeComponents.minute
        mergedComponments.second = timeComponents.second
        
        return calendar.date(from: mergedComponments)
    }
    
    //Schedules notifications depending on start time
    @objc func scheduleNotifications() {
        let center = UNUserNotificationCenter.current()
        //Remove all previous requests
        center.removeAllPendingNotificationRequests()

        for task in tasks{
            let content = UNMutableNotificationContent()
            content.title = task.GetName()
            content.body = "New task started!"
            content.categoryIdentifier = "alarm"
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = Calendar.current.component(.hour, from: task.GetStartDate())
            dateComponents.minute = Calendar.current.component(.minute, from: task.GetStartDate())
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
    }
    
    //Get events from calendar
    func getEvents(calendarId: String) {
        guard let service = self.calendarService else {
            return
        }
        
        //add wrong task
        //add normal task for 5 minutes after
        //show profile page
        //show timetable
        //edit task
        //mark task as complete
        //show profile
        
        //add revision task
        //show daily timetable
        //add revision task
        //show daily timetable
        //shutdown app
        //show timetable
        //shutdown app
        //show alert
        
        //Only get events from now until a week later
        let startDateTime = GTLRDateTime(date: Calendar.current.startOfDay(for: Date()))
        let endDateTime = GTLRDateTime(date: Date().addingTimeInterval(60*60*24*7))
        let eventsListQuery = GTLRCalendarQuery_EventsList.query(withCalendarId: calendarId)
        eventsListQuery.timeMin = startDateTime
        eventsListQuery.timeMax = endDateTime
        
        _ = service.executeQuery(eventsListQuery, completionHandler: { (ticket, result, error) in
            guard error == nil, let items = (result as? GTLRCalendar_Events)?.items else {
                return
            }
            
            for item in items{
                var isNew = true
                let taskName = item.summary
                let startTime = item.start!.dateTime!.date
                let endTime = item.end!.dateTime!.date
                let priority = 3
                for prevItems in self.taskListReference!.GetTasks(){
                    if prevItems.GetName() == taskName{
                        isNew = false
                        break
                    }
                }
                if isNew{
                    self.taskListReference?.addTask(title: taskName!, startDate: startTime, endDate: endTime, priority: priority, notes: "Task Notes", isRevisionTask: false)
                }
            }
            
            if items.count > 0{
                let alert = UIAlertController(title: "Alert", message: "Google Calendar tasks synced with task list!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action -> Void in}))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
}

