//
//  VideoMainViewController.swift
//  Video Trim Tool
//
//  Created by Faisal on 25/01/17.
//  Copyright © 2017 Faisal. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import CoreMedia
import AssetsLibrary
import Photos

class VideoMainViewController: UIViewController
{
  var isPlaying = true
  var isSliderEnd = true
  var playbackTimeCheckerTimer: Timer! = nil
  let playerObserver: Any? = nil
  
  let exportSession: AVAssetExportSession! = nil
  var player: AVPlayer!
  var playerItem: AVPlayerItem!
  var playerLayer: AVPlayerLayer!
  var asset: AVAsset!
  
  var url:NSURL! = nil
  var startTime: CGFloat = 0.0
  var stopTime: CGFloat  = 0.0
  var thumbTime: CMTime!
  var thumbtimeSeconds: Int!
  
  var videoPlaybackPosition: CGFloat = 0.0
  var cache:NSCache<AnyObject, AnyObject>!
  var rangeSlider: RangeSlider! = nil

  @IBOutlet weak var layoutContainer: UIView!
  @IBOutlet weak var selectButton: UIButton!
  @IBOutlet weak var videoLayer: UIView!
  @IBOutlet weak var cropButton: UIButton!
  
  @IBOutlet weak var frameContainerView: UIView!
  @IBOutlet weak var imageFrameView: UIView!
  
  @IBOutlet weak var startView: UIView!
  @IBOutlet weak var startTimeText: UITextField!
  
  @IBOutlet weak var endView: UIView!
  @IBOutlet weak var endTimeText: UITextField!
  

  
  override func viewDidLoad()
  {
    
    super.viewDidLoad()
    loadViews()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //Loading Views
  func loadViews()
  {
    //Whole layout view
    layoutContainer.layer.borderWidth = 1.0
    layoutContainer.layer.borderColor = UIColor.white.cgColor
    
    selectButton.layer.cornerRadius = 5.0
    cropButton.layer.cornerRadius   = 5.0
    
    //Hiding buttons and view on load
    cropButton.isHidden         = true
    startView.isHidden          = true
    endView.isHidden            = true
    frameContainerView.isHidden = true
    
    //Style for startTime
    startTimeText.layer.cornerRadius = 5.0
    startTimeText.layer.borderWidth  = 1.0
    startTimeText.layer.borderColor  = UIColor.white.cgColor
    
    //Style for endTime
    endTimeText.layer.cornerRadius = 5.0
    endTimeText.layer.borderWidth  = 1.0
    endTimeText.layer.borderColor  = UIColor.white.cgColor
    
    imageFrameView.layer.cornerRadius = 5.0
    imageFrameView.layer.borderWidth  = 1.0
    imageFrameView.layer.borderColor  = UIColor.white.cgColor
    imageFrameView.layer.masksToBounds = true
    
    player = AVPlayer()

    
    //Allocating NsCahe for temp storage
    cache = NSCache()
  }
  
  //Action for select Video
  @IBAction func selectVideoUrl(_ sender: Any)
  {
    //Selecting Video type
    let myImagePickerController        = UIImagePickerController()
    myImagePickerController.sourceType = .photoLibrary
    myImagePickerController.mediaTypes = [(kUTTypeMovie) as String]
    myImagePickerController.delegate   = self
    myImagePickerController.isEditing  = false
    present(myImagePickerController, animated: true, completion: {  })
  }
  
  //Action for crop video
  @IBAction func cropVideo(_ sender: Any)
  {
    let start = Float(startTimeText.text!)
    let end   = Float(endTimeText.text!)
    cropVideo(sourceURL1: url, startTime: start!, endTime: end!)
  }

}

//Subclass of VideoMainViewController
extension VideoMainViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate
{
  //Delegate method of image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        url = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaURL.rawValue)] as? NSURL
        asset   = AVURLAsset.init(url: url as URL)

        thumbTime = asset.duration
        thumbtimeSeconds      = Int(CMTimeGetSeconds(thumbTime))
        
        viewAfterVideoIsPicked()
        
        let item:AVPlayerItem = AVPlayerItem(asset: asset)
        player                = AVPlayer(playerItem: item)
        playerLayer           = AVPlayerLayer(player: player)
        playerLayer.frame     = videoLayer.bounds
        
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            player.actionAtItemEnd   = AVPlayer.ActionAtItemEnd.none

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnVideoLayer))
        videoLayer.addGestureRecognizer(tap)
        tapOnVideoLayer(tap: tap)
        
        videoLayer.layer.addSublayer(playerLayer)
        player.play()
    }
    
  func viewAfterVideoIsPicked()
  {
    //Rmoving player if alredy exists
    if(playerLayer != nil)
    {
      playerLayer.removeFromSuperlayer()
    }
    
    createImageFrames()
    
    //unhide buttons and view after video selection
    cropButton.isHidden         = false
    startView.isHidden          = false
    endView.isHidden            = false
    frameContainerView.isHidden = false
    
    
    isSliderEnd = true
    startTimeText.text! = "\(0.0)"
    endTimeText.text   = "\(thumbtimeSeconds!)"
    createRangeSlider()
  }
  
  //Tap action on video player
    @objc func tapOnVideoLayer(tap: UITapGestureRecognizer)
  {
    if isPlaying
    {
      player.play()
    }
    else
    {
      player.pause()
    }
    isPlaying = !isPlaying
  }
  

  
  //MARK: CreatingFrameImages
  func createImageFrames()
  {
    //creating assets
    let assetImgGenerate : AVAssetImageGenerator    = AVAssetImageGenerator(asset: asset)
    assetImgGenerate.appliesPreferredTrackTransform = true
    assetImgGenerate.requestedTimeToleranceAfter    = CMTime.zero;
    assetImgGenerate.requestedTimeToleranceBefore   = CMTime.zero;
    
    
    assetImgGenerate.appliesPreferredTrackTransform = true
    let thumbTime: CMTime = asset.duration
    let thumbtimeSeconds  = Int(CMTimeGetSeconds(thumbTime))
    let maxLength         = "\(thumbtimeSeconds)" as NSString

    let thumbAvg  = thumbtimeSeconds/6
    var startTime = 1
    var startXPosition:CGFloat = 0.0
    
    //loop for 6 number of frames
    for _ in 0...5
    {
      
      let imageButton = UIButton()
      let xPositionForEach = CGFloat(imageFrameView.frame.width)/6
      imageButton.frame = CGRect(x: CGFloat(startXPosition), y: CGFloat(0), width: xPositionForEach, height: CGFloat(imageFrameView.frame.height))
      do {
        let time:CMTime = CMTimeMakeWithSeconds(Float64(startTime),preferredTimescale: Int32(maxLength.length))
        let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
        let image = UIImage(cgImage: img)
        imageButton.setImage(image, for: .normal)
      }
      catch
        _ as NSError
      {
        print("Image generation failed with error (error)")
      }
      
      startXPosition = startXPosition + xPositionForEach
      startTime = startTime + thumbAvg
      imageButton.isUserInteractionEnabled = false
      imageFrameView.addSubview(imageButton)
    }
    
  }
  
  //Create range slider
  func createRangeSlider()
  {
    //Remove slider if already present
    let subViews = frameContainerView.subviews
    for subview in subViews{
      if subview.tag == 1000 {
        subview.removeFromSuperview()
      }
    }

    rangeSlider = RangeSlider(frame: frameContainerView.bounds)
    frameContainerView.addSubview(rangeSlider)
    rangeSlider.tag = 1000
    
    //Range slider action
    rangeSlider.addTarget(self, action: #selector(VideoMainViewController.rangeSliderValueChanged(_:)), for: .valueChanged)
    
    let time = DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time) {
      self.rangeSlider.trackHighlightTintColor = UIColor.clear
      self.rangeSlider.curvaceousness = 1.0
    }

  }
  
  //MARK: rangeSlider Delegate
    @objc func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
    player.pause()
    
    if(isSliderEnd == true)
    {
      rangeSlider.minimumValue = 0.0
      rangeSlider.maximumValue = Double(thumbtimeSeconds)
      
      rangeSlider.upperValue = Double(thumbtimeSeconds)
      isSliderEnd = !isSliderEnd

    }

    startTimeText.text = "\(rangeSlider.lowerValue)"
    endTimeText.text   = "\(rangeSlider.upperValue)"
    
    //print(rangeSlider.lowerLayerSelected)
    if(rangeSlider.lowerLayerSelected)
    {
      seekVideo(toPos: CGFloat(rangeSlider.lowerValue))

    }
    else
    {
      seekVideo(toPos: CGFloat(rangeSlider.upperValue))
      
    }
        
    //print(startTime)
  }
  
  
  //MARK: TextField Delegates
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool
  {
    let maxLength     = 3
    let currentString = startTimeText.text! as NSString
    let newString     = currentString.replacingCharacters(in: range, with: string) as NSString
    return newString.length <= maxLength
  }
  
  //Seek video when slide
  func seekVideo(toPos pos: CGFloat) {
    videoPlaybackPosition = pos
    let time: CMTime = CMTimeMakeWithSeconds(Float64(videoPlaybackPosition), preferredTimescale: player.currentTime().timescale)
    player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    
    if(pos == CGFloat(thumbtimeSeconds))
    {
    player.pause()
    }
  }
  
  //Trim Video Function
  func cropVideo(sourceURL1: NSURL, startTime:Float, endTime:Float)
  {
    let manager                 = FileManager.default
    
    guard let documentDirectory = try? manager.url(for: .documentDirectory,
                                                   in: .userDomainMask,
                                                   appropriateFor: nil,
                                                   create: true) else {return}
    guard let mediaType         = "mp4" as? String else {return}
    guard (sourceURL1 as? NSURL) != nil else {return}
    
    if mediaType == kUTTypeMovie as String || mediaType == "mp4" as String
    {
      let length = Float(asset.duration.value) / Float(asset.duration.timescale)
      //print("video length: \(length) seconds")
      
      let start = startTime
      let end = endTime
      //print(documentDirectory)
      var outputURL = documentDirectory.appendingPathComponent("output")
      do {
        try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
        //let name = hostent.newName()
        outputURL = outputURL.appendingPathComponent("1.mp4")
      }catch let error {
        print(error)
      }
      
      //Remove existing file
      _ = try? manager.removeItem(at: outputURL)
      
      guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
      exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
      
      let startTime = CMTime(seconds: Double(start ), preferredTimescale: 1000)
      let endTime = CMTime(seconds: Double(end ), preferredTimescale: 1000)
      let timeRange = CMTimeRange(start: startTime, end: endTime)
      
      exportSession.timeRange = timeRange
      exportSession.exportAsynchronously{
        switch exportSession.status {
        case .completed:
          print("exported at \(outputURL)")
                self.saveToCameraRoll(URL: outputURL as NSURL?)
        case .failed:
            print("failed \(String(describing: exportSession.error))")
          
        case .cancelled:
            print("cancelled \(String(describing: exportSession.error))")
          
        default: break
  }}}}
  
  //Save Video to Photos Library
  func saveToCameraRoll(URL: NSURL!) {
      PHPhotoLibrary.shared().performChanges({
      PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL as URL)
    }) { saved, error in
      if saved {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Cropped video was successfully saved", message: nil, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }        
    }}}
  
}

