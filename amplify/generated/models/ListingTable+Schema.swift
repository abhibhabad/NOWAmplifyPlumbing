// swiftlint:disable all
import Amplify
import Foundation

extension ListingTable {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case listingName
    case listingType
    case listingStart
    case listingEnd
    case totalPasses
    case passesSold
    case instructions
    case description
    case createdAt
    case createdBy
    case PassesTables
    case venuesID
    case venueName
    case isActive
    case listingPrice
    case deletedAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let listingTable = ListingTable.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "ListingTables"
    model.syncPluralName = "ListingTables"
    
    model.attributes(
      .index(fields: ["venuesID"], name: "byVenues"),
      .primaryKey(fields: [listingTable.id])
    )
    
    model.fields(
      .field(listingTable.id, is: .required, ofType: .string),
      .field(listingTable.listingName, is: .required, ofType: .string),
      .field(listingTable.listingType, is: .required, ofType: .enum(type: ListingType.self)),
      .field(listingTable.listingStart, is: .required, ofType: .dateTime),
      .field(listingTable.listingEnd, is: .required, ofType: .dateTime),
      .field(listingTable.totalPasses, is: .required, ofType: .int),
      .field(listingTable.passesSold, is: .required, ofType: .int),
      .field(listingTable.instructions, is: .required, ofType: .string),
      .field(listingTable.description, is: .required, ofType: .string),
      .field(listingTable.createdAt, is: .required, ofType: .dateTime),
      .field(listingTable.createdBy, is: .required, ofType: .string),
      .hasMany(listingTable.PassesTables, is: .optional, ofType: PassesTable.self, associatedWith: PassesTable.keys.listingtableID),
      .field(listingTable.venuesID, is: .required, ofType: .string),
      .field(listingTable.venueName, is: .required, ofType: .string),
      .field(listingTable.isActive, is: .required, ofType: .bool),
      .field(listingTable.listingPrice, is: .required, ofType: .double),
      .field(listingTable.deletedAt, is: .optional, ofType: .dateTime),
      .field(listingTable.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension ListingTable: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}