import Vapor
import FluentPostgreSQL
//import FluentSQLite

final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    
    var userID: User.ID
    

    
    init(short: String, long: String, userID: User.ID) {
        self.short = short
        self.long = long
        self.userID = userID
    }
}

//方式一
//extension Acronym: Model {
//    typealias Database = SQLiteDatabase
//    typealias ID = Int
//    public static var idKey: IDKey = \Acronym.id
//}

//方式二
//extension Acronym: SQLiteModel {}
extension Acronym: PostgreSQLModel {}

extension Acronym: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>{
        //Create the table for Acronym in the database.
        return Database.create(self, on: connection, closure: { (builder) in
            //Use addProperties(to:) to add all the fields to the database
            try addProperties(to: builder)
            builder.reference(from: \.userID, to:\User.id)
        })
    }
}

//json自动匹配
//{
//    "short": "OMG",
//    "long": "Oh My God"
//}
extension Acronym: Content {}

extension Acronym: Parameter {} //数据库查询,路由参数。

extension Acronym{
    var user: Parent<Acronym, User> {
        return parent(\.userID)
    }
}

extension Acronym{
    var categories: Siblings<Acronym,Category,AcronymCategoryPivot> {
        return siblings()
    }
}
