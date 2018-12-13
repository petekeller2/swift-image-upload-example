//
//  RequestFactory.swift
//  image-upload-example
//
//  Created by Peter Keller on 12/11/18.
//  Copyright © 2018 Peter Keller. All rights reserved.
//

class RequestFactory {
    
    func create(type: RequestImplementation, url: String, requestData: Dictionary<String, Any>) -> RequestProtocol {
        switch type {
        case .alamofire:
            return AlamofireRequest(url: url, requestData: requestData)
        }
    }
}
