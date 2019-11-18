//
//  user.swift
//  DehancerCommon
//
//  Created by denn nevera on 18/11/2019.
//

import Foundation
import ObjectMapper

public class UserInfo: Params {
    
    public var cuid:String = ""
    public var signature:String = ""
    public var name:String = ""
    public var full_name:String = ""
    public var email:String = ""
    public var client_name:String = ""
    public var client_version:String = ""
    
    override public func mapping(map: Map) {
        super.mapping(map: map)
        
        cuid           <- map["cuid"]
        signature      <- map["signature"]
        
        name           <- map["name"]
        full_name      <- map["full-name"]
        email          <- map["email"]
        client_name    <- map["client-name"]
        client_version <- map["client-version"]
    }
}
