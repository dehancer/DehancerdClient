//
//  profile.swift
//  DehancerCommon
//
//  Created by denn nevera on 18/11/2019.
//

import Foundation
import ObjectMapper

public class Profile: Mappable {
    
    public var id = ""
    public var revision = 0
    public var caption = ""
    public var description = ""
    public var author = ""
    public var maintainer = ""
    public var tags = ""
    public var url:URL?
    public var datetime:Date?
    public var updated_at:Date?
    public var file_size:Int = 0
    public var is_published:Bool = false
    public var is_photo_enabled:Bool = false
    public var is_video_enabled:Bool = false

    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        
        author              <- map["author"]
        caption             <- map["caption"]
        description         <- map["description"]
        id                  <- map["id"]
        maintainer          <- map["maintainer"]
        revision            <- map["revision"]
        tags                <- map["tags"]
        file_size           <- map["file_size"]
        is_published        <- map["is_published"]
        is_photo_enabled    <- map["is_photo_enabled"]
        is_video_enabled    <- map["is_video_enabled"]

        if let context = map.context as? Context {
            url <- (map["url"], SignedURLTransform(context: context))
        }
        else {
            url <- (map["url"], URLTransform(shouldEncodeURLString: true))
        }
        
        updated_at  <- (map["updated_at"], DateTransform())
        datetime    <- (map["datetime"], DateTransform())
    }
}
