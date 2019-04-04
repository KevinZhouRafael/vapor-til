import Vapor
import FluentPostgreSQL
//import FluentSQLite

final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    init(short: String, long: String) {
        self.short = short
        self.long = long
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

extension Acronym: Migration {}

//json自动匹配
//{
//    "short": "OMG",
//    "long": "Oh My God"
//}
extension Acronym: Content {}
