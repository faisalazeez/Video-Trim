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
import FDWaveformView


class AudioViewController:UIViewController
{
  var songUrl = NSURL()
  var player: AVAudioPlayer?
  
  @IBOutlet weak var waveFormView: FDWaveformView!
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
  
  @IBAction func playAudio(_ sender: Any)
  {
   player?.play()
  }
  
  @IBAction func pauseAudio(_ sender: Any)
  {
    player?.pause()
  }
  
  @IBAction func stopAudio(_ sender: Any)
  {
    player?.stop()
  }

}

extension AudioViewController:MPMediaPickerControllerDelegate
{
  func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection)
  {
    
    guard let mediaItem = mediaItemCollection.items.first else
    {
      print("No Audio Selected")
      return
    }
    
    songUrl = mediaItem.value(forProperty: MPMediaItemPropertyAssetURL) as! URL as NSURL
    self.waveFormView.audioURL = songUrl as URL
    self.waveFormView.wavesColor = UIColor.white
    
    self.intialiseAudioPlayer(mediaItem: mediaItemCollection.items)
    
    
    mediaPicker.dismiss(animated: true, completion: nil)
  }
  
  func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController)
  {
    mediaPicker.dismiss(animated: true) {}
  }
  
  func intialiseAudioPlayer(mediaItem: [MPMediaItem])
  {
    guard let url = mediaItem.first?.assetURL else { return }
    
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
      try AVAudioSession.sharedInstance().setActive(true)
      
      
      player = try AVAudioPlayer(contentsOf: url)
     // guard let player = player else { return }
      
      let total = player?.duration
      let float = (player?.currentTime)! / total!
      
      
      
    } catch let error {
      print(error.localizedDescription)
    }
    
  }
  
  func trimAudio()
  {
  
  }
  
}
