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

public class CameraProfile: Mappable {
    
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
    public var is_photo_enabled:Bool = false
    public var is_video_enabled:Bool = false
    public var is_published:Bool = false
    public var license_matrix:[LicenseType] = []
    public var vendor_id:String = ""
    public var model_id:String = ""
    public var format_id:String = ""

    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        
        author <- map["author"]
        caption <- map["caption"]
        description <- map["description"]
        id  <- map["id"]
        maintainer <- map["maintainer"]
        revision <- map["revision"]
        tags <- map["tags"]
        is_photo_enabled <- map["is_photo_enabled"]
        is_video_enabled <- map["is_video_enabled"]
        is_published <- map["is_published"]
        license_matrix <- map["license_matrix"]
        vendor_id <- map["vendor_id"]
        model_id <- map["model_id"]
        format_id <- map["format_id"]

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

internal class get_camera_profile_list_request: Request {
    
    public typealias ResponseType = [CameraProfile]

    public var method: String  { return "get-camera-profile-list" }
    public var params: Params? { return _params }
    
    public class ParamsHelper: Params {
        
        public var cuid:String = ""
        public var signature:String = ""
        public var id:String = ""
        public var all = false

        override public func mapping(map: Map) {
            super.mapping(map: map)
            cuid <- map["cuid"]
            signature <- map["signature"]
            id <- map["id"]
            all <- map["all"]
        }
    }
    
    public init(key client_private_key: String,
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
    
    public func response<R>(_ object: ResponsObject) throws -> R  {
        return
            Mapper<CameraProfile>(context: Context(cuid: _params.cuid, signature: _params.signature),
                            shouldIncludeNilValues: true)
            .mapArray(JSONObject: object) as! R
        
    }
    
    private var _params: ParamsHelper = ParamsHelper(JSON: [:])!
}
