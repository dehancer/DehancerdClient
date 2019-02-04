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
    
    public typealias ResponseType = ResponseHelper
    
    public class ResponseHelper: Response {
        public var method_list: [String:Any] = [:]
        override public func mapping(map: Map) {
            method_list <- map["method_list"]
        }
    }

    public var method: String  { return "help" }
    public var params: Params? {return nil }
    public func response<R>(_ result: ResponsObject) throws -> R  {
        return ResponseHelper(JSON: ["method_list": result]) as! R 
    }
}
