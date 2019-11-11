//
//  JsonRpc.swift
//  dehancerd-client
//
//  Created by denn on 04/02/2019.
//  Copyright © 2019 Dehacer. All rights reserved.
//

import Foundation
import ObjectMapper

public enum ResponseCode:Int {
    case parseError            = -32700
    case invalidRequest        = -32600
    case methodNotFound        = -32601
    case invalidParams         = -32602
    case internalError         = -32603
    case serverErrorStart      = -32099
    case serverErrorEnd       = -32000
    case unknownErrorCode      = -32001
    
    case notAuthorized         = -40001
    case accessForbidden       = -40003
    case clientNotRegistered   = -40004
    case profileNotFound       = -40005
}

public enum Result<T> {
    case success(object:T,responseId:Int)
    case error(Error)
}

public class Response:Mappable {
    public required init?(map: Map) {}
    public func mapping(map: Map) {}
}

public class Params:Mappable {
    public required init?(map: Map) {}
    public func mapping(map: Map) {}
}

public protocol Request {
    
    typealias ResponsObject = Any
    associatedtype ResponseType//:Response
    
    var method:String {get}
    var params:Params? {get}
    func response<R>(_ object: ResponsObject) throws -> R
}


public class JsonRpc {
    
    public enum Errors:Error {
        case response(responseId:Int, code:ResponseCode, message:String)
        case parse(responseId:Int, code:ResponseCode, message:String)
    }
    
    let timeout:TimeInterval 
    
    public init (base url:URL, timeout:TimeInterval = 60) {
        self.url = url
        self.timeout = timeout
    }
    
    public func send<T:Request>(request object: T,
                                complete: @escaping ((Result<T.ResponseType>) -> ())) {

        let id = nextId
        let methodName = object.method
        let params = Mapper().toJSON(object.params ?? Params(JSON: [:])!)
       
        let json
            = ["jsonrpc":"2.0",
               "method":methodName,
               "params": params,
               "id": "\(id)"] as [String : Any]
        
        do {
                        
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            var r = URLRequest(url: url, 
                               cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                               timeoutInterval: self.timeout)
            
            r.httpMethod = "POST"
            r.httpBody = data            
            
            URLSession(configuration: .default).dataTask(with: r) {
                
                data, response, error in                         
                
                if let error = error {
                    complete(Result.error(error))
                    return
                }
                
                do {
                    if let data = data {
                        
                        let d = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                        
                        let retId = Int("\(d["id"] ?? "-1")") ?? -1
                                                
                        if let e =  d["error"] as? [String: Any] {        
                            let code = e["code"] as? Int ?? ResponseCode.internalError.rawValue
                            let responseCode = ResponseCode(rawValue: code) ?? .internalError
                            complete(Result.error(Errors.response(responseId: retId, 
                                                                  code:  responseCode, 
                                                                  message:  e["message"] as? String ?? "Unkown error")))
                        }
                        else if let result = d["result"] {
                            
                            let o:T.ResponseType = try object.response(result)
                            let r = Result.success(object: o, responseId: retId)
                            complete(r)
                            
                            
                        }
                        else {
                            complete(Result.error(Errors.response(responseId: retId, 
                                                                  code: ResponseCode.serverErrorEnd, 
                                                                  message:  String.localizedStringWithFormat("Null responsed data"))))
                        }
                    }
                    else {
                        let description = String
                            .localizedStringWithFormat("Response for method %@ could not be parsed", methodName)               
                        
                        complete(Result.error(Errors.parse(responseId: id, 
                                                           code: ResponseCode.parseError, 
                                                           message: description)))
                    }
                }
                    
                catch {
                    complete(Result.error(error))
                }
                
                }.resume()
        }
        catch {
            complete(Result.error(error))
        }
    }
    
    private var nextId:Int {
        let lock = NSLock()
        lock.lock()
        defer {
            lock.unlock()
        }
        JsonRpc.idCounter += 1
        return JsonRpc.idCounter;
    }
    private var url:URL
    private static var idCounter:Int = 0
}
