//
//  camera.swift
//  DehancerCommon
//
//  Created by denn nevera on 18/11/2019.
//

import Foundation
import ObjectMapper
import DehancerCommon

public class Vendor: Mappable {
    
    public var          id = ""
    public var        name = ""
    public var    caption  = ""
    public var description = ""
    
    public init(name: String) {
        self.id = name.lowercased().replacingOccurrences(of: " ", with: "-")
        self.name = name
    }
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        caption <- map["caption"]
        description <- map["description"]
    }
}

public class Format: Mappable {
    public var description = ""
    public var          id = ""
    public var        name = ""
    public var    revision = -1
    public var  types:[String] = []
    public var   vendor_id = ""
    
    public init(vendor id:String, name: String) {
        self.vendor_id = id
        self.name = name
        self.id = self.vendor_id + ":" + name.lowercased().replacingOccurrences(of: " ", with: "-")
    }
    
    public required init?(map: Map) {}

    public func mapping(map: Map) {
        description <- map["description"]
        id <- map["id"]
        name <- map["name"]
        revision <- map["revision"]
        types <- map["types"]
        vendor_id <- map["vendor_id"]
    }
}

public class CameraProfileReference: Mappable {
    
    public var   format_id = ""
    public var   url:URL?
    
    public init() {}
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        format_id <- map["format_id"]
        if let context = map.context as? Context {
            url <- (map["url"], SignedURLTransform(context: context))
        }
        else {
            url <- (map["url"], URLTransform(shouldEncodeURLString: true))
        }
    }
}

public class Model: Mappable {
    public var description = ""
    public var          id = ""
    public var        name = ""
    public var     caption = ""
    public var   profiles:[CameraProfileReference] = []
    public var  formats:[String] = []
    public var   vendor_id = ""
    
    public init(vendor id: String, name: String) {
        self.vendor_id = id
        self.name = name
        self.id = self.vendor_id + ":" + name.lowercased().replacingOccurrences(of: " ", with: "-")
    }
    
    public required init?(map: Map) {}

    public func mapping(map: Map) {
        description <- map["description"]
        id <- map["id"]
        name <- map["name"]
        caption <- map["caption"]
        profiles <- map["profiles"]
        formats <- map["formats"]
        vendor_id <- map["vendor_id"]
    }
}

public class CameraReferences: Mappable {
    
    public var formats:[Format] = []
    public var models:[Model]  = []
    public var vendors:[Vendor]  = []

    public init() {}

    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        
        formats <- map["camera_formats"]
        models <- map["camera_models"]
        vendors <- map["camera_vendors"]
    }
}

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
