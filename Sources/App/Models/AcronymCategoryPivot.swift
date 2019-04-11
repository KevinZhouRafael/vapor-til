//
//  AcronymCategoryPivot.swift
//  App
//
//  Created by kai zhou on 2019/4/11.
//

import Foundation
import FluentPostgreSQL

final class AcronymCategoryPivot: PostgreSQLUUIDPivot{
    var id: UUID?
    var acronymID: Acronym.ID
    var categoryID: Category.ID
    
    typealias Left = Acronym
    typealias Right = Category
    
    static let leftIDKey: LeftIDKey = \.acronymID
    static let rightIDKey: RightIDKey = \.categoryID
    
    init(_ acronymID: Acronym.ID, _ categoryID: Category.ID) {
        self.acronymID = acronymID
        self.categoryID = categoryID
    }
}

extension AcronymCategoryPivot: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>{
        
        //创建外键约束，如何不删除库，只更新库？？？
        return Database.create(self, on: connection, closure: { (builder) in
            try addProperties(to: builder) //Use addProperties(to:) to add all the fields to the database.
             builder.reference(from: \.acronymID, to: \Acronym.id)
             builder.reference(from: \.categoryID, to: \Category.id)
        })
    }
}
