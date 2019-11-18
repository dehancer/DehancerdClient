//
//  statistics.swift
//  DehancerCommon
//
//  Created by denn nevera on 18/11/2019.
//

import Foundation
import ObjectMapper

public class CommonStat: Mappable {
    
    public var all_users = 0
    public var launched = 0
    public var files = 0
      
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        all_users <- map["all_users"]
        launched <- map["launched"]
        files <- map["files"]
    }
}
