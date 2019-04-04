import Vapor

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
        
       
        let elf = try req.content.decode(Acronym.self) //EventLoopFuture<Array>
//        return elf
        
        let f = elf.flatMap(to: Acronym.self, { (acronym) -> EventLoopFuture<Acronym> in
            let a = acronym.save(on: req)
            return a
        })
        return f
    }
    
}
