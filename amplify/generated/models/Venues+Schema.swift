// swiftlint:disable all
import Amplify
import Foundation

extension Venues {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case venueName
    case venuePhoneNumber
    case venueHours
    case venueImage
    case accountName
    case routingNumber
    case EIN
    case accountNumber
    case ownerFirstName
    case ownerLastName
    case ownerPhoneNumber
    case ownerEmail
    case ListingTables
    case revenueSplit
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let venues = Venues.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
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
      .field(venues.venueHours, is: .optional, ofType: .embeddedCollection(of: Temporal.Time.self)),
      .field(venues.venueImage, is: .optional, ofType: .string),
      .field(venues.accountName, is: .optional, ofType: .string),
      .field(venues.routingNumber, is: .required, ofType: .int),
      .field(venues.EIN, is: .required, ofType: .int),
      .field(venues.accountNumber, is: .required, ofType: .int),
      .field(venues.ownerFirstName, is: .required, ofType: .string),
      .field(venues.ownerLastName, is: .required, ofType: .string),
      .field(venues.ownerPhoneNumber, is: .required, ofType: .string),
      .field(venues.ownerEmail, is: .optional, ofType: .string),
      .hasMany(venues.ListingTables, is: .optional, ofType: ListingTable.self, associatedWith: ListingTable.keys.venuesID),
      .field(venues.revenueSplit, is: .optional, ofType: .double),
      .field(venues.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(venues.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension Venues: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}