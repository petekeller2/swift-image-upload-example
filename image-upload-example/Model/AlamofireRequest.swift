//
//  AlamofireRequest.swift
//  image-upload-example
//
//  Created by Peter Keller on 12/11/18.
//  Copyright © 2018 Peter Keller. All rights reserved.
//

import Alamofire

class AlamofireRequest: RequestProtocol {

    var _url: String!
    var _requestData: Dictionary<String, Any>!
    
    // getters and setters
    var url: String {
        get {
            if _url == nil {
                _url = ""
            }
            return _url
        }
        set {
            _url = url
        }
    }
    
    var requestData: Dictionary<String, Any> {
        get {
            if _requestData == nil {
                _requestData = [String: Any]()
            }
            return _requestData
        }
        set {
            _requestData = requestData
        }
    }
    // end of getters and setters
    
    init(url: String, requestData: Dictionary<String, Any>) {
        self._url = url
        self._requestData = requestData
    }

    func getRequest() -> Any {
        return Alamofire.request(self.url).responseJSON
    }
    
    func postRequest() -> Any {
        let headers = ["Content-Type": "application/json"]
        return Alamofire.request(self.url, method: .post, parameters: self.requestData, encoding: JSONEncoding.default, headers: headers).responseJSON
    }
    
}
    
    
