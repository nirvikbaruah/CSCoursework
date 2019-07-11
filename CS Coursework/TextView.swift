//
//  TextView.swift
//  CS Coursework
//
//  Created by Nirvik Baruah on 29/11/18.
//  Copyright © 2018 Nirvik Baruah. All rights reserved.
//

import UIKit

class TextView: UITextView, UITextViewDelegate{
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.delegate = self
        self.text = "Task Notes"
        self.textColor = UIColor.lightGray
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.textColor == UIColor.lightGray {
            self.text = nil
            self.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.text.isEmpty {
            self.text = "Task Notes"
            self.textColor = UIColor.lightGray
        }
    }
}
