//
//  DismissSegue.swift
//  CS Coursework
//
//  Created by Nirvik Baruah on 5/10/18.
//  Copyright © 2018 Nirvik Baruah. All rights reserved.
//

import UIKit

class DismissSegue: UIStoryboardSegue {
    override func perform() {
        self.source.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
