//
//  viewClass.swift
//  IBDesignable
//
//  Created by Faisal on 08/06/17.
//  Copyright © 2017 Faisal. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable

open class viewClass:UIView
{
  public override init(frame: CGRect)
  {
    super.init(frame: frame)
  }
  
  public required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
  }
  
  @IBInspectable var fillColor: UIColor? {
    didSet{
      self.backgroundColor = self.fillColor
    }
    }
  
  @IBInspectable var borderWidth: CGFloat = 0 {
    didSet{
      self.layer.borderWidth = self.borderWidth
    }
  }
  
  @IBInspectable var borderColor: UIColor? {
    didSet{
      self.layer.borderColor = borderColor?.cgColor
    }
  }
  
  @IBInspectable var cornerRadius: CGFloat = 0 {
    didSet{
      self.layer.cornerRadius = self.cornerRadius
    }
  }
  
}
