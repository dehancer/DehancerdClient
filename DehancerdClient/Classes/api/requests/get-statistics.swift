//
//  get-common-stat.swift
//  DehancerdClient
//
//  Created by denis svinarchuk on 10/03/2019.
//

import Foundation
import ObjectMapper
import ed25519

internal class get_statistics_request: Request {    
    
    var method: String  { return "get-statistics" }
    
    var params: Params? { return _params }

    class ParamsHelper: Params {
        public var name:String = "common"        
        override public func mapping(map: Map) {
            super.mapping(map: map)
            name <- map["name"]
        }
    }
    
    init(name:String) {
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
