import Vapor
import Leaf

struct WebsiteController: RouteCollection {
    
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        // /acronyms/<ACRONYM ID>
        router.get("acronyms", Acronym.parameter, use: acronymHandler)
    }

    func indexHandler(_ req: Request) throws -> Future<View> {
//        return try req.view().render("index")
        
//        let context = IndexContext(title: "Homepage")
//        return try req.view().render("index", context)
        
        return  Acronym.query(on: req).all().flatMap(to: View.self, { (acronyms) -> Future<View> in
            let acronymsData = acronyms.isEmpty ? nil: acronyms
            let context = IndexContext(title: "Homepage", acronyms:acronymsData)
            return try req.view().render("index", context)
        })
    }
    
    // 1
    func acronymHandler(_ req: Request) throws -> Future<View> {
        // 2
        return try req.parameters.next(Acronym.self).flatMap(to: View.self) { acronym in
            // 3
                return  acronym.user.get(on: req).flatMap(to: View.self) { user in
                    // 4
                        let context = AcronymContext(title: acronym.short,
                                                     acronym: acronym,
                                                     user: user)
                        return try req.view().render("acronym", context)
                } }
    }
}

struct IndexContext:Encodable{
    let title:String
    let acronyms:[Acronym]?
}

struct AcronymContext:Encodable{
    let title:String
    let acronym:Acronym?
    let user: User
}

