// swiftlint:disable all
import Amplify
import Foundation

extension UserTable {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case userId
    case firstName
    case lastName
    case imageKey
    case userEmail
    case userPhoneNumber
    case venueNotifications
    case promotionNotifications
    case emailNotifications
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let userTable = UserTable.keys
    
    model.authRules = [
      rule(allow: .private, provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "UserTables"
    model.syncPluralName = "UserTables"
    
    model.attributes(
      .primaryKey(fields: [userTable.id])
    )
    
    model.fields(
      .field(userTable.id, is: .required, ofType: .string),
      .field(userTable.userId, is: .optional, ofType: .string),
      .field(userTable.firstName, is: .optional, ofType: .string),
      .field(userTable.lastName, is: .optional, ofType: .string),
      .field(userTable.imageKey, is: .optional, ofType: .string),
      .field(userTable.userEmail, is: .optional, ofType: .string),
      .field(userTable.userPhoneNumber, is: .optional, ofType: .string),
      .field(userTable.venueNotifications, is: .optional, ofType: .bool),
      .field(userTable.promotionNotifications, is: .optional, ofType: .bool),
      .field(userTable.emailNotifications, is: .optional, ofType: .bool),
      .field(userTable.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(userTable.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension UserTable: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}