// swiftlint:disable all
import Amplify
import Foundation

extension Venues {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case venueName
    case venuePhoneNumber
    case venueEmail
    case venueImageKey
    case venueHours
    case accountName
    case EIN
    case accountNumber
    case routingNumber
    case ownerFirstName
    case ownerLastName
    case ownerEmail
    case ListingTables
    case ownerPhoneNumber
    case createdBy
    case revenueSplit
    case daysOfOperation
    case PassesTables
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let venues = Venues.keys
    
    model.authRules = [
      rule(allow: .private, provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "Venues"
    model.syncPluralName = "Venues"
    
    model.attributes(
      .primaryKey(fields: [venues.id])
    )
    
    model.fields(
      .field(venues.id, is: .required, ofType: .string),
      .field(venues.venueName, is: .required, ofType: .string),
      .field(venues.venuePhoneNumber, is: .required, ofType: .string),
      .field(venues.venueEmail, is: .required, ofType: .string),
      .field(venues.venueImageKey, is: .required, ofType: .string),
      .field(venues.venueHours, is: .optional, ofType: .embeddedCollection(of: Temporal.Time.self)),
      .field(venues.accountName, is: .required, ofType: .string),
      .field(venues.EIN, is: .required, ofType: .int),
      .field(venues.accountNumber, is: .required, ofType: .int),
      .field(venues.routingNumber, is: .required, ofType: .int),
      .field(venues.ownerFirstName, is: .required, ofType: .string),
      .field(venues.ownerLastName, is: .required, ofType: .string),
      .field(venues.ownerEmail, is: .required, ofType: .string),
      .hasMany(venues.ListingTables, is: .optional, ofType: ListingTable.self, associatedWith: ListingTable.keys.venuesID),
      .field(venues.ownerPhoneNumber, is: .required, ofType: .string),
      .field(venues.createdBy, is: .required, ofType: .string),
      .field(venues.revenueSplit, is: .required, ofType: .double),
      .field(venues.daysOfOperation, is: .required, ofType: .embeddedCollection(of: Bool.self)),
      .hasMany(venues.PassesTables, is: .optional, ofType: PassesTable.self, associatedWith: PassesTable.keys.venuesID),
      .field(venues.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(venues.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension Venues: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}