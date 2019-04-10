//
//  AcronymsController.swift
//  App
//
//  Created by kai zhou on 2019/4/4.
//

import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    func boot(router: Router) throws {
//        router.get("api","acronyms", use: getAllHandler)
        
        let acronymsRoutes = router.grouped("api", "acronyms")
        acronymsRoutes.get( use: getAllHandler)
        
        // 1 /api/acronyms
        acronymsRoutes.post(use: createHandler)
        // 2  /api/acronyms/<ACRONYM ID>
        acronymsRoutes.get(Acronym.parameter, use: getHandler)
        // 3 /api/acronyms/ <ACRONYM ID>
        acronymsRoutes.put(Acronym.parameter, use: updateHandler)
        // 4 /api/acronyms/ <ACRONYM ID>
        acronymsRoutes.delete(Acronym.parameter, use: deleteHandler)
        // 5 /api/acronyms/search
        acronymsRoutes.get("search", use: searchHandler)
        // 6 /api/acronyms/first
        acronymsRoutes.get("first", use: getFirstHandler)
        // 7 /api/acronyms/sorted
        acronymsRoutes.get("sorted", use: sortedHandler)
    }
    
    func getAllHandler(_ req:Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
    
    func createHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.content.decode(Acronym.self)
            .flatMap(to: Acronym.self) { acronym in
                return acronym.save(on: req)
        }
        
        
        //        let elf = try req.content.decode(Acronym.self) //EventLoopFuture<Array>
        ////        return elf
        //
        //        let f = elf.flatMap(to: Acronym.self, { (acronym) -> EventLoopFuture<Acronym> in
        //            let a = acronym.save(on: req)
        //            return a
        //        })
        //        return f
        
    }
    
    func getHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Acronym> {
        //flatMap等待两个参数执行完成
        return try flatMap(to: Acronym.self,
                           req.parameters.next(Acronym.self),
                           req.content.decode(Acronym.self)) { (acronym, updatedAcronym) -> Future<Acronym> in
                            //更新
                            acronym.short = updatedAcronym.short
                            acronym.long = updatedAcronym.long
                            //保存并返回
                            return acronym.save(on: req)
        }
        
    }

    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
            return try req.parameters.next(Acronym.self)
                .delete(on: req)
                .transform(to: HTTPStatus.noContent)
    }
    
    func searchHandler(_ req:Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req.query[String.self, at:"term"] else{
            throw Abort(.badRequest, reason: "Missing search term in request")
        }
        //        return  Acronym.query(on: req)
        //                                        .filter(\.short == searchTerm)
        //                                        .all()
        
        // http://localhost:8080/api/acronyms/search?term=Oh+My+God
        return   Acronym.query(on: req).group(.or) { or in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
            }.all()
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<Acronym> {
        // 用map处理unwrap 结果
        return Acronym.query(on: req)
            .first()
            .map(to: Acronym.self, { (acronym) -> Acronym in
                
                guard let acronym = acronym else {
                    throw Abort(.notFound)
                }
                return acronym
            })
    }
    
    func sortedHandler(_ req: Request) throws -> Future<[Acronym]> {
        return  Acronym.query(on: req)
            .sort(\.short, .ascending)
            .all()
    }
}
