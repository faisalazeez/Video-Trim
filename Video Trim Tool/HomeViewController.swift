//
//  HomeViewController.swift
//  Video Trim Tool
//
//  Created by Faisal on 25/10/17.
//  Copyright © 2017 Faisal. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UIViewController
{
  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(true)
    self.navigationController?.isNavigationBarHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool)
  {
    super.viewWillDisappear(true)
    self.navigationController?.isNavigationBarHidden = false
  }
  
}
