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

public class Profile: Mappable {
    
    public var author = ""
    public var caption = ""
    public var description = ""
    public var id = ""
    public var maintainer = ""
    public var revision = 0
    public var tags = ""
    public var url:URL?
    public var datetime:Date?
    public var updated_at:Date?
    public var file_size:Int = 0 

    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        
        author <- map["author"]
        caption <- map["caption"]
        description <- map["description"]
        id  <- map["id"]
        maintainer <- map["maintainer"]
        revision <- map["revision"]
        tags <- map["tags"]
        file_size <- map["file_size"]
       
        if let context = map.context as? Context {
            url <- (map["url"], SignedURLTransform(context: context))
        }
        else {
            url <- (map["url"], URLTransform(shouldEncodeURLString: true))
        }
        
        updated_at <- (map["updated_at"], DateTransform())
        datetime <- (map["datetime"], DateTransform())
    }
}

internal class get_profile_list_request: Request {
    
    public typealias ResponseType = [Profile]

    public var method: String  { return "get-profile-list" }
    public var params: Params? { return _params }
    
    public class ParamsHelper: Params {
        
        public var cuid:String = ""
        public var signature:String = ""
        
        override public func mapping(map: Map) {
            super.mapping(map: map)
            cuid <- map["cuid"]
            signature <- map["signature"]
        }
    }
    
    public init(key client_private_key: String, token: String) throws {
        
        let pair = try Pair(fromPrivateKey: client_private_key)
        
        let digest = Digest { (calculator) in
            calculator.append(token)
            calculator.append(pair.publicKey.encode())
        }

        _params.signature = pair.sign(digest).encode() 
        _params.cuid = pair.publicKey.encode()
    }
    
    public func response<R>(_ object: ResponsObject) throws -> R  {
        return
            Mapper<Profile>(context: Context(cuid: _params.cuid, signature: _params.signature),
                            shouldIncludeNilValues: true)
            .mapArray(JSONObject: object) as! R
        
    }
    
    private var _params: ParamsHelper = ParamsHelper(JSON: [:])!
}
