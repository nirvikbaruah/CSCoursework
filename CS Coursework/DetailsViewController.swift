//
//  DetailsViewController.swift
//  CS Coursework
//
//  Created by Nirvik Baruah on 15/11/18.
//  Copyright © 2018 Nirvik Baruah. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    //Output references
    @IBOutlet weak var taskTitle: UINavigationItem!
    @IBOutlet weak var taskNotes: UITextView!
    @IBOutlet weak var taskDate: UITextView!
    @IBOutlet weak var taskPriority: UITextView!
    
    //Change view controller outputs
    func SetModalText(newNotes: String, newTitle: String, newDate: String, newPriority: String){
        //Force view to refresh so that it is added to hierarchy and IBOutlets are set
        let _  = self.view
        taskNotes.text = newNotes
        taskTitle.title = newTitle
        taskDate.text = newDate
        taskPriority.text = newPriority
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
