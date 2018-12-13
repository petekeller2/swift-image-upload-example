//
//  Image.swift
//  image-upload-example
//
//  Created by Peter Keller on 12/10/18.
//  Copyright © 2018 Peter Keller. All rights reserved.
//

import UIKit
import Alamofire

class LocImage {
    
    var _image_desc: String!
    var _lat: Double!
    var _lon: Double!
    var _image_path: String!
    var _created_at: Int!
    var _created: String!
    
    // getters and setters
    var image_desc: String {
        get {
            if _image_desc == nil {
                _image_desc = ""
            }
            return _image_desc
        }
        set {
            _image_desc = image_desc
        }
    }
    
    var lat: Double {
        get {
            if _lat == nil {
                _lat = 0
            }
            return _lat
        }
        set {
            _lat = lat
        }
    }
    
    var lon: Double {
        get {
            if _lon == nil {
                _lon = 0
            }
            return _lon
        }
        set {
            _lon = lon
        }
    }
    
    var image_path: String {
        get {
            if _image_path == nil {
                _image_path = ""
            }
            return _image_path
        }
        set {
            _image_path = image_path
        }
    }
    
    var created_at: Int {
        get {
            if _created_at == nil {
                _created_at = 0
            }
            return _created_at
        }
        set {
            _created_at = created_at
        }
    }
    
    var created: String {
        get {
            if _created == nil {
                _created = ""
            }
            return _created
        }
        set {
            _created = created
        }
    }
    
    // end of getters and setters
    
    init(imageDict: Dictionary<String, AnyObject>) {
        
        if let image_desc = imageDict["image_desc"] as? String {
            self._image_desc = image_desc
        }

        if let image_path = imageDict["image_path"] as? String {
            self._image_path = Constants.url + Constants.imageLocation + image_path
        }
        
        if let created_at = imageDict["created"] as? String {
            
            self._created = created_at
            
            let dfmatter = DateFormatter()
            dfmatter.dateFormat="yyyy-MM-dd hh:mm:ss"
            let date = dfmatter.date(from: created_at)
            let dateStamp:TimeInterval = date?.timeIntervalSince1970 ?? 0
            let dateSt:Int = Int(dateStamp)
            
            self._created_at = dateSt
        }

    }
}
