//
//  AudioViewController.swift
//  Video Trim Tool
//
//  Created by Faisal on 26/10/17.
//  Copyright © 2017 Faisal. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

class AudioViewController:UIViewController
{
  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  @IBAction func selectAudioAction(_ sender: Any)
  {
    let mediaPicker = MPMediaPickerController(mediaTypes: .music)
    mediaPicker.delegate = self
    self.present(mediaPicker, animated: true, completion: { _ in })
  }

}

extension AudioViewController:MPMediaPickerControllerDelegate
{
  func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection)
  {
    print("asdasdasdad")
  }
  
  func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController)
  {
    mediaPicker.dismiss(animated: true) {}
  }
  
}
