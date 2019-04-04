import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    router.post("api","acronyms") { (req) -> Future<Acronym> in
        
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
    
    router.get("api","acronyms", use: { req in
        return Acronym.query(on: req).all()
    })
    
    //  /api/acronyms/<ID>
    router.get("api","acronyms",Acronym.parameter) { (req) -> Future<Acronym> in
        return try req.parameters.next(Acronym.self)
    }
    
    router.put("api","acronyms",Acronym.parameter) { (req) -> Future<Acronym> in
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
    
    router.delete("api","acronyms",Acronym.parameter) { (req) -> Future<HTTPStatus> in
        return try req.parameters.next(Acronym.self)
                                                .delete(on: req)
                                                .transform(to: HTTPStatus.noContent)
    }
    
    router.get("api","acronyms","search") { (req) -> Future<[Acronym]> in
        guard let searchTerm = req.query[String.self, at:"term"] else{
            throw Abort(.badRequest, reason: "Missing search term in request")
        }
//        return  Acronym.query(on: req)
//                                        .filter(\.short == searchTerm)
//                                        .all()
        
        // http://localhost:8080/api/acronyms/search?term=Oh+My+God
        return  Acronym.query(on: req).group(.or) { or in
             or.filter(\.short == searchTerm)
             or.filter(\.long == searchTerm)
        }.all()
        
    }
    
    router.get("api","acronyms","first") { (req) -> Future<Acronym> in
        
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
    
    router.get("api", "acronyms", "sorted") { req -> Future<[Acronym]> in
        
        return  Acronym.query(on: req)
                                        .sort(\.short, .ascending)
                                        .all()
    }
}
