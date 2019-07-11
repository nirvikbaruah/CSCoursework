//
//  ProfilePage.swift
//  CS Coursework
//
//  Created by Nirvik Baruah on 3/9/18.
//  Copyright © 2018 Nirvik Baruah. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GTMOAuth2
import GoogleSignIn
import AudioToolbox

class ProfilePage: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var googleSigninButton: GIDSignInButton!
    
    var taskListReference: TaskList?
    var user: User?
    let userDefaults = UserDefaults.standard
    @IBOutlet weak var welcomeGreetingLabel: UILabel!
    @IBOutlet weak var completedTasksLabel: UITextView!
    @IBOutlet weak var totalTasksLabel: UITextView!
    @IBOutlet weak var incompleteTasksLabel: UITextView!
    
    func initGoogle() {
        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = "750611619941-1s590l62jchq9g8o2if1sp6c3oufvttg.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/calendar"]
        GIDSignIn.sharedInstance().uiDelegate = self 
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initGoogle()
        GIDSignIn.sharedInstance().signIn()
        //Create + button in top right
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(ProfilePage.TapEdit(_:)))
        loadLatestUser()
    }

    override func viewDidAppear(_ animated: Bool) {
        loadLatestUser()
        updateValues()
        
    }

    func loadLatestUser(){
        taskListReference = tabBarController?.viewControllers?[0].children[0] as? TaskList
        user = taskListReference!.GetUser()
    }

    func updateValues(){
        //If logged in, set profile name to google name
        let currentUser = GIDSignIn.sharedInstance().currentUser
        if (currentUser != nil){
            user!.SetUserName(name: currentUser!.profile.name)
            googleSigninButton.isHidden = true
        } else{
            googleSigninButton.isHidden = false
        }
        
        welcomeGreetingLabel.text = "Welcome, " + user!.GetUserName() + "!"
        completedTasksLabel.text = String(user!.GetNumTasksDone())
        totalTasksLabel.text = String(user!.GetNumTasksAdded())
        //Can't have negative number so use a max statement
        incompleteTasksLabel.text = String(taskListReference!.GetTasks().count)
        
        //Write User attributes to memory so not lost
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: user!)
        userDefaults.set(encodedData, forKey: "user")
        userDefaults.synchronize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Perform segue when click + button
    @objc func TapEdit(_ sender: UIBarButtonItem)
    {
        AudioServicesPlaySystemSound(1306)
        performSegue(withIdentifier: "editProfileSegue", sender: sender)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editProfileSegue"{
            if let navController = segue.destination as? UINavigationController {
                if let childVC = navController.topViewController as? EditProfileViewController {
                    childVC.SetDetails(userInstance: user!)
                }
            }
        }
    }

}
