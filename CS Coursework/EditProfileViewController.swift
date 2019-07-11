//
//  AddTaskViewController.swift
//  CS Coursework
//
//  Created by Nirvik Baruah on 21/9/18.
//  Copyright © 2018 Nirvik Baruah. All rights reserved.
//

import UIKit
import AudioToolbox

class EditProfileViewController: UIViewController {
    var user: User?
    
    @IBOutlet weak var nameInp: TextField!
    @IBOutlet weak var revisionStartTimeInp: TextField!
    @IBOutlet weak var revisionEndTimeInp: TextField!
    @IBOutlet weak var taskBreakTimeInp: TextField!
    @IBOutlet weak var minTaskTimeInp: TextField!
    @IBOutlet weak var maxTaskTimeInp: TextField!
    
    //Event once save button clicked
    @IBAction func saveClick(_ sender: Any) {
        var completeForm: Bool = true
        let formatter = DateFormatter()
        var alert: UIAlertController
        formatter.dateFormat = "HH:mm"
        AudioServicesPlaySystemSound(1306)
        //Only potential error source is with date so only need to check that
        if (formatter.date(from: revisionStartTimeInp.text!) != nil){
            user!.SetStartTime(time: formatter.date(from: revisionStartTimeInp.text!)!)
        }
        else{
            completeForm = false
            alert = UIAlertController(title: "Alert", message: "Start time is in wrong format!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action -> Void in}))
            self.present(alert, animated: true, completion: nil)
        }
        
        if (formatter.date(from: revisionEndTimeInp.text!) != nil){
            user!.SetEndTime(time: formatter.date(from: revisionEndTimeInp.text!)!)
        }
        else{
            completeForm = false
            alert = UIAlertController(title: "Alert", message: "End time is in wrong format!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action -> Void in}))
            self.present(alert, animated: true, completion: nil)
        }
        
        if completeForm{
            user!.SetUserName(name: nameInp.text!)
            user!.SetMinBreakTime(time: Int(taskBreakTimeInp.text!)!)
            user!.SetMinTaskTime(time: Int(minTaskTimeInp.text!)!)
            user!.SetMaxTaskTime(time: Int(maxTaskTimeInp.text!)!)
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
    
    func SetDetails(userInstance: User){
        //Load view hierarchy first
        _ = self.view
        user = userInstance
        //Sets placeholder text on inputs
        nameInp.text = user!.GetUserName()
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "HH:mm"
        
        revisionStartTimeInp.text = dateFormatter.string(from: user!.GetStartTime())
        revisionEndTimeInp.text = dateFormatter.string(from: user!.GetEndTime())
        taskBreakTimeInp.text = String(user!.GetMinBreakTime())
        minTaskTimeInp.text = String(user!.GetMinTaskTime())
        maxTaskTimeInp.text = String(user!.GetMaxTaskTime())
    }
}
