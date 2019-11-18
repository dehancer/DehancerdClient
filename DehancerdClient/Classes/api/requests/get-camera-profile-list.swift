//
//  get-camera-profile-list.swift
//  DehancerdClient
//
//  Created by denn nevera on 13/10/2019.
//

import Foundation

import Foundation
import ObjectMapper
import ed25519
import DehancerCommon


internal class get_camera_profile_list_request: Request {
    
    typealias ResponseType = [CameraProfile]

    var method: String  { return "get-camera-profile-list" }
    var params: Params? { return _params }
    
    class ParamsHelper: Params {
        
        var cuid:String = ""
        var signature:String = ""
        var id:String = ""
        var all = false

        override func mapping(map: Map) {
            super.mapping(map: map)
            cuid <- map["cuid"]
            signature <- map["signature"]
            id <- map["id"]
            all <- map["all"]
        }
    }
    
    init(key client_private_key: String,
                token: String,
                id: String = "",
                all: Bool = false
    ) throws {
        
        let pair = try Pair(fromPrivateKey: client_private_key)
        
        let digest = Digest { (calculator) in
            calculator.append(token)
            calculator.append(pair.publicKey.encode())
        }

        _params.signature = pair.sign(digest).encode()
        _params.cuid = pair.publicKey.encode()
        _params.id = id
        _params.all = all
    }
    
    func response<R>(_ object: ResponsObject) throws -> R  {
        return
            Mapper<CameraProfile>(context: Context(cuid: _params.cuid, signature: _params.signature),
                            shouldIncludeNilValues: true)
            .mapArray(JSONObject: object) as! R
        
    }
    
    private var _params: ParamsHelper = ParamsHelper(JSON: [:])!
}
