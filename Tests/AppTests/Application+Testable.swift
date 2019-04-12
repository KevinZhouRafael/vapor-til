//
//  Application+Testable.swift
//  AppTests
//
//  Created by kai zhou on 2019/4/12.
//

import Vapor
import App
import FluentPostgreSQL

extension Application{
    static func testable(envArgs:[String]? = nil) throws -> Application{
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing
        
        if let environmentArgs = envArgs{
            env.arguments = environmentArgs
        }
        
        try App.configure(&config, &env, &services)
        let app = try Application(
            config: config,
            environment: env,
            services: services)
        try App.boot(app)
        return app
    }
    
    static func reset() throws{
        let revertEnvironment = ["vapor", "revert", "--all", "-y"]
        try Application.testable(envArgs: revertEnvironment).asyncRun().wait()
    }
    
    func sendRequest<T>(to path:String, method:HTTPMethod, headers: HTTPHeaders = .init(), body:T? = nil) throws -> Response where T:Content {
        let responder = try self.make(Responder.self)
        
        let request = HTTPRequest(method: method, url: URL(string: path)!, headers: headers)
        let wrappedRequest = Request(http: request, using: self)
        
        if let body = body{
            try wrappedRequest.content.encode(body)
        }
        
        return try responder.respond(to: wrappedRequest).wait()
    }
    
    // 没有body的请求
    func sendRequest( to path: String, method: HTTPMethod, headers: HTTPHeaders = .init() ) throws -> Response {
        // 创建 EmptyContent 满足body parameter编译参数
        let emptyContent: EmptyContent? = nil
        return try sendRequest(  to: path, method: method, headers: headers, body: emptyContent)
    }
    
    // 不关心响应的请求
    func sendRequest<T>( to path: String, method: HTTPMethod, headers: HTTPHeaders,data: T ) throws where T: Content {
        _ = try self.sendRequest( to: path, method: method, headers: headers, body: data)
    }
    
    // 把响应Content -> Decodable 的请求
    func getResponse<C, T>( to path: String, method: HTTPMethod = .GET,  headers: HTTPHeaders = .init(), data: C? = nil, decodeTo type: T.Type ) throws -> T where C: Content, T: Decodable {

        let response = try self.sendRequest( to: path, method: method,  headers: headers, body: data)
        //解码
        return try response.content.decode(type).wait()
    }
    // 没有body的，把响应Content -> Decodable 的请求
    func getResponse<T>( to path: String, method: HTTPMethod = .GET, headers: HTTPHeaders = .init(),decodeTo type: T.Type ) throws -> T where T: Decodable {
        
        let emptyContent: EmptyContent? = nil
        return try self.getResponse( to: path, method: method, headers: headers, data: emptyContent, decodeTo: type)
    }
}

struct EmptyContent: Content {
    
}
