//
//  Networking.swift
//  AlamoPhotoTagger
//
//  Created by Jon Olivet on 10/31/17.
//  Copyright © 2017 Jon Olivet. All rights reserved.
//

import UIKit
import Alamofire

extension ViewController {
  
  func upload(image: UIImage,
              progressCompletion: @escaping (_ percent: Float) -> Void,
              completion: @escaping (_ tags: [String], _ colors: [PhotoColor]) -> Void) {
    guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
      print("Could not get JPEG representation of UIImage")
      return
    }
    
    Alamofire.upload(
      multipartFormData: { multipartFormData in
        multipartFormData.append(imageData,
                                 withName: "imagefile",
                                 fileName: "image.jpg",
                                 mimeType: "image/jpeg")
    },
      with: ImaggaRouter.content,
      encodingCompletion: { encodingResult in
        switch encodingResult {
        case .success(let upload, _, _):
          upload.uploadProgress { progress in
            progressCompletion(Float(progress.fractionCompleted))
          }
          upload.validate()
          upload.responseJSON { response in
            guard response.result.isSuccess else {
              print("Error while uploading file: \(String(describing: response.result.error))")
              completion([String](), [PhotoColor]())
              return
            }
            
            guard let responseJSON = response.result.value as? [String: Any],
              let uploadedFiles = responseJSON["uploaded"] as? [Any],
              let firstFile = uploadedFiles.first as? [String: Any],
              let firstFileID = firstFile["id"] as? String else {
                print("Invalid information received from service")
                completion([String](), [PhotoColor]())
                return
            }
            
            print("Content uploaded with ID: \(firstFileID)")
            
            self.downloadTags(contentID: firstFileID) { tags in
              self.downloadColors(contentID: firstFileID) { colors in
                completion(tags, colors)
              }
            }
          }
        case .failure(let encodingError):
          print(encodingError)
        }
    }
    )
  }
  
  func downloadTags(contentID: String, completion: @escaping ([String]) -> Void) {
    Alamofire.request(ImaggaRouter.tags(contentID))
      .responseJSON { response in
        
        guard response.result.isSuccess else {
          print("Error while fetching tags: \(String(describing: response.result.error))")
          completion([String]())
          return
        }
        
        guard let responseJSON = response.result.value as? [String: Any],
          let results = responseJSON["results"] as? [[String: Any]],
          let firstObject = results.first,
          let tagsAndConfidences = firstObject["tags"] as? [[String: Any]] else {
            print("Invalid tag information received from the service")
            completion([String]())
            return
        }
        
        let tags = tagsAndConfidences.flatMap({ dict in
          return dict["tag"] as? String
        })
        
        completion(tags)
    }
  }
  
  func downloadColors(contentID: String, completion: @escaping ([PhotoColor]) -> Void) {
    Alamofire.request(ImaggaRouter.colors(contentID))
      .responseJSON { response in
        
        guard response.result.isSuccess else {
          print("Error while fetching colors: \(String(describing: response.result.error))")
          completion([PhotoColor]())
          return
        }
        
        guard let responseJSON = response.result.value as? [String: Any],
          let results = responseJSON["results"] as? [[String: Any]],
          let firstResult = results.first,
          let info = firstResult["info"] as? [String: Any],
          let imageColors = info["image_colors"] as? [[String: Any]] else {
            print("Invalid color information received from service")
            completion([PhotoColor]())
            return
        }
        
        let photoColors = imageColors.flatMap({ (dict) -> PhotoColor? in
          guard let r = dict["r"] as? String,
            let g = dict["g"] as? String,
            let b = dict["b"] as? String,
            let closestPaletteColor = dict["closest_palette_color"] as? String else {
              return nil
          }
          
          return PhotoColor(red: Int(r), green: Int(g), blue: Int(b), colorName: closestPaletteColor)
        })
        
        completion(photoColors)
    }
  }
}
