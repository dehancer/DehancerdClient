//
//  help.swift
//  dehancerd-client
//
//  Created by denn on 04/02/2019.
//  Copyright © 2019 Dehacer. All rights reserved.
//

import Foundation
import ObjectMapper

internal class help: Request {
    
    typealias ResponseType = ResponseHelper
    
    class ResponseHelper: Response {
        public var method_list: [String:Any] = [:]
        override public func mapping(map: Map) {
            method_list <- map["method_list"]
        }
    }

    var method: String  { return "help" }
    var params: Params? {return nil }
    func response<R>(_ result: ResponsObject) throws -> R  {
        return ResponseHelper(JSON: ["method_list": result]) as! R 
    }
}
