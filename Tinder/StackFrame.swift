//
//  StackFrame.swift
//  Tinder
//
//  Created by Arsen Gasparyan on 20/07/15.
//  Copyright © 2015 Arsen Gasparyan. All rights reserved.
//

import UIKit

class StackFrame: UICollectionViewCell {
    private let grayColor = UIColor(red: 163.0/255.0, green: 163.0/255.0, blue: 163.0/255.0, alpha: 1)
    
    internal func prepareForUse() {
        layer.borderWidth = 1
        layer.borderColor = grayColor.CGColor
        layer.cornerRadius = 5
    }
    
}
