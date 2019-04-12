//import FluentSQLite
import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
//Environment set by Vapor Cloud
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
//    try services.register(FluentSQLiteProvider())
    try services.register(FluentPostgreSQLProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

//    // Configure a SQLite database
//    let sqlite = try SQLiteDatabase(storage: .memory)
////    let sqlite = try SQLiteDatabase(storage: .file(path: "TILAPPdb.sqlite"))
//
////     Register the configured SQLite database to the database config.
//    var databases = DatabasesConfig()
//    databases.add(database: sqlite, as: .sqlite)
//    services.register(databases)

    //Create // docker run --name postgres -e POSTGRES_DB=vapor -e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres
    //docker ps
//docker run postgress
    
    //docker run --name postgres-test -e POSTGRES_DB=vapor-test  -e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password  -p 5433:5432 -d postgres
    //brew services start postgres 
    var databases = DatabasesConfig()
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    //支持测试环境。
    let databaseName:String
    let databasePort:Int
    if env == .testing {
        databaseName = "vapor-test"
        if let testPort = Environment.get("DATABASE_PORT") {
            databasePort = Int(testPort) ?? 5433
        } else {
            databasePort = 5433
        }
    }else{
        databaseName = Environment.get("DATABASE_DB") ?? "vapor"
        databasePort = 5432
    }

    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: hostname,
        port: databasePort,
        username: username,
        database: databaseName,
        password: password)

    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    services.register(databases)
    
    // Configure migrations
    var migrations = MigrationConfig()
//    migrations.add(model: Acronym.self, database: .sqlite)
    migrations.add(model: User.self, database: .psql) //必须先创建User。由于有外键。
    migrations.add(model: Acronym.self, database: .psql)
    migrations.add(model: Category.self, database: .psql) //添加新表，重启服务就可以实现。
    migrations.add(model: AcronymCategoryPivot.self, database: .psql)
    services.register(migrations)
    
    //数据库变动时候，migrationConfig 和 revertCommand都无效？
    var commandConfig = CommandConfig.default()
//    commandConfig.use(RevertCommand.self, as: "revert")
    commandConfig.useFluentCommands()
    services.register(commandConfig)
    
}
