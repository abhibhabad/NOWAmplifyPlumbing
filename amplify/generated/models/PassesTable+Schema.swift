// swiftlint:disable all
import Amplify
import Foundation

extension PassesTable {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case passStatus
    case userID
    case purchasedAt
    case transactionID
    case listingtableID
    case venueName
    case listingName
    case listingType
    case listingDescription
    case listingInstructions
    case listingPrice
    case listingStart
    case listingEnd
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let passesTable = PassesTable.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "PassesTables"
    model.syncPluralName = "PassesTables"
    
    model.attributes(
      .index(fields: ["listingtableID"], name: "byListingTable"),
      .primaryKey(fields: [passesTable.id])
    )
    
    model.fields(
      .field(passesTable.id, is: .required, ofType: .string),
      .field(passesTable.passStatus, is: .required, ofType: .enum(type: PassStatus.self)),
      .field(passesTable.userID, is: .optional, ofType: .string),
      .field(passesTable.purchasedAt, is: .optional, ofType: .dateTime),
      .field(passesTable.transactionID, is: .optional, ofType: .string),
      .field(passesTable.listingtableID, is: .required, ofType: .string),
      .field(passesTable.venueName, is: .required, ofType: .string),
      .field(passesTable.listingName, is: .required, ofType: .string),
      .field(passesTable.listingType, is: .required, ofType: .enum(type: ListingType.self)),
      .field(passesTable.listingDescription, is: .required, ofType: .string),
      .field(passesTable.listingInstructions, is: .required, ofType: .string),
      .field(passesTable.listingPrice, is: .required, ofType: .double),
      .field(passesTable.listingStart, is: .required, ofType: .dateTime),
      .field(passesTable.listingEnd, is: .required, ofType: .dateTime),
      .field(passesTable.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(passesTable.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension PassesTable: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}