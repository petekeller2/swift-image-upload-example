//
//  RequestProtocol.swift
//  image-upload-example
//
//  Created by Peter Keller on 12/11/18.
//  Copyright © 2018 Peter Keller. All rights reserved.
//

import UIKit

protocol RequestProtocol {
    var url: String { get set }
    var requestData: Dictionary<String, Any> { get set }

    func getRequest() -> Any
    func postRequest() -> Any
}
