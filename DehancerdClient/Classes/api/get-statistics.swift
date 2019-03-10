//
//  get-common-stat.swift
//  DehancerdClient
//
//  Created by denis svinarchuk on 10/03/2019.
//

import Foundation
import ObjectMapper
import ed25519

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

internal class get_statistics_request: Request {    
    
    public var method: String  { return "get-statistics" }
    
    public var params: Params? { return _params }

    public class ParamsHelper: Params {        
        public var name:String = "common"        
        override public func mapping(map: Map) {
            super.mapping(map: map)
            name <- map["name"]
        }
    }
    
    public init(name:String) {
        _params.name = name
    }
    
    func response<R>(_ object: ResponsObject) throws -> R {
        if let o = object as? [String:Any] {
            switch o["id"] as! String {
            case "common":
                if let result = o["state"] as? [String:Any] {
                    return Mapper<CommonStat>().map(JSON: result) as! R
                }
            default:
                throw JsonRpc.Errors.parse(responseId: -1, code: ResponseCode.parseError, message: "Unknown statistics")
            }
        }
        throw JsonRpc.Errors.parse(responseId: -1, code: ResponseCode.parseError, message: "Unknown response object type")
    }
    
    typealias ResponseType = Mappable//[String:Any]
    
    private var _params: ParamsHelper = ParamsHelper(JSON: ["name":"common"])!

}
