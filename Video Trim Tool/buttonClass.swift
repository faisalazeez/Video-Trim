//
//  File.swift
//  IBDesignable
//
//  Created by Faisal on 08/06/17.
//  Copyright © 2017 Faisal. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable

open class buttonClass: UIButton {
  
  public override init(frame: CGRect)
  {
    super.init(frame: frame)
  }
  
  public required  init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  @IBInspectable
  public var cornerRadius: CGFloat = 2.0 {
    didSet {
      self.layer.cornerRadius = self.cornerRadius
    }
  }
  
  @IBInspectable var borderWidth: CGFloat = 0 {
    didSet {
      layer.borderWidth = borderWidth
    }
  }
  
  @IBInspectable var borderColor: UIColor? {
    didSet {
      layer.borderColor = borderColor?.cgColor
    }
  }
  
}

