//
//  get-profile-list.swift
//  dehancerd-client
//
//  Created by denn on 05/02/2019.
//  Copyright © 2019 Dehacer. All rights reserved.
//

import Foundation
import ObjectMapper
import ed25519


internal class get_film_profile_list_request: Request {
    
    typealias ResponseType = [Profile]

    var method: String  { return "get-film-profile-list" }
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
            Mapper<Profile>(context: Context(cuid: _params.cuid, signature: _params.signature),
                            shouldIncludeNilValues: true)
            .mapArray(JSONObject: object) as! R
        
    }
    
    private var _params: ParamsHelper = ParamsHelper(JSON: [:])!
}
