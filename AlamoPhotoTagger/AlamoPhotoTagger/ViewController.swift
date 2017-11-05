//
//  ViewController.swift
//  AlamoPhotoTagger
//
//  Created by Jon Olivet on 10/31/17.
//  Copyright © 2017 Jon Olivet. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate {

  @IBOutlet var takePictureButton: UIButton!
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var progressView: UIProgressView!
  @IBOutlet var activityIndicatorView: UIActivityIndicatorView!

  fileprivate var tags: [String]?
  fileprivate var colors: [PhotoColor]?
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
  
    guard !UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
  
    takePictureButton.setTitle("Select Photo", for: .normal)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    imageView.image = nil
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowResults" {
      let controller = segue.destination as! TagsColorsViewController
      controller.tags = tags
      controller.colors = colors
    }
  }
  
  // MARK: - Actions
  @IBAction func takePicture(_ sender: UIButton) {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = false
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      picker.sourceType = .camera
    } else {
      picker.sourceType = .photoLibrary
      picker.modalPresentationStyle = .fullScreen
    }
    
    present(picker, animated: true)
  }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
    guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
      print("Info did not have the required UIImage for the Original Image")
      dismiss(animated: true)
      return
    }
    
    imageView.image = image
    
    takePictureButton.isHidden = true
    progressView.progress = 0.0
    progressView.isHidden = false
    activityIndicatorView.startAnimating()
    
    upload(
      image: image,
      progressCompletion: { [unowned self] percent in
        self.progressView.setProgress(percent, animated: true)
      },
      completion: { [unowned self] tags, colors in
        self.takePictureButton.isHidden = false
        self.progressView.isHidden = true
        self.activityIndicatorView.stopAnimating()
        
        self.tags = tags
        self.colors = colors
        
        self.performSegue(withIdentifier: "ShowResults", sender: self)
    })
    
    dismiss(animated: true)
  }
}


