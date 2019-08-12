//
//  CustomButtons.swift
//  ARBasketBall
//
//  Created by Kirill Mazaev on 05.08.2019.
//  Copyright © 2019 mazaev. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customizeButton()
    }
    
    fileprivate func customizeButton() {
        backgroundColor = UIColor.lightGray
        layer.cornerRadius = 10.0
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.white.cgColor
    }
    
}
