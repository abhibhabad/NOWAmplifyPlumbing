// swiftlint:disable all
import Amplify
import Foundation

public struct Venues: Model {
  public let id: String
  public var venueName: String
  public var venuePhoneNumber: String
  public var venueEmail: String
  public var venueImageKey: String
  public var venueHours: [Temporal.Time]?
  public var accountName: String
  public var EIN: Int
  public var accountNumber: Int
  public var routingNumber: Int
  public var ownerFirstName: String
  public var ownerLastName: String
  public var ownerEmail: String
  public var ListingTables: List<ListingTable>?
  public var ownerPhoneNumber: String
  public var createdBy: String
  public var revenueSplit: Double
  public var daysOfOperation: [Bool]
  public var PassesTables: List<PassesTable>?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      venueName: String,
      venuePhoneNumber: String,
      venueEmail: String,
      venueImageKey: String,
      venueHours: [Temporal.Time]? = nil,
      accountName: String,
      EIN: Int,
      accountNumber: Int,
      routingNumber: Int,
      ownerFirstName: String,
      ownerLastName: String,
      ownerEmail: String,
      ListingTables: List<ListingTable>? = [],
      ownerPhoneNumber: String,
      createdBy: String,
      revenueSplit: Double,
      daysOfOperation: [Bool] = [],
      PassesTables: List<PassesTable>? = []) {
    self.init(id: id,
      venueName: venueName,
      venuePhoneNumber: venuePhoneNumber,
      venueEmail: venueEmail,
      venueImageKey: venueImageKey,
      venueHours: venueHours,
      accountName: accountName,
      EIN: EIN,
      accountNumber: accountNumber,
      routingNumber: routingNumber,
      ownerFirstName: ownerFirstName,
      ownerLastName: ownerLastName,
      ownerEmail: ownerEmail,
      ListingTables: ListingTables,
      ownerPhoneNumber: ownerPhoneNumber,
      createdBy: createdBy,
      revenueSplit: revenueSplit,
      daysOfOperation: daysOfOperation,
      PassesTables: PassesTables,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      venueName: String,
      venuePhoneNumber: String,
      venueEmail: String,
      venueImageKey: String,
      venueHours: [Temporal.Time]? = nil,
      accountName: String,
      EIN: Int,
      accountNumber: Int,
      routingNumber: Int,
      ownerFirstName: String,
      ownerLastName: String,
      ownerEmail: String,
      ListingTables: List<ListingTable>? = [],
      ownerPhoneNumber: String,
      createdBy: String,
      revenueSplit: Double,
      daysOfOperation: [Bool] = [],
      PassesTables: List<PassesTable>? = [],
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.venueName = venueName
      self.venuePhoneNumber = venuePhoneNumber
      self.venueEmail = venueEmail
      self.venueImageKey = venueImageKey
      self.venueHours = venueHours
      self.accountName = accountName
      self.EIN = EIN
      self.accountNumber = accountNumber
      self.routingNumber = routingNumber
      self.ownerFirstName = ownerFirstName
      self.ownerLastName = ownerLastName
      self.ownerEmail = ownerEmail
      self.ListingTables = ListingTables
      self.ownerPhoneNumber = ownerPhoneNumber
      self.createdBy = createdBy
      self.revenueSplit = revenueSplit
      self.daysOfOperation = daysOfOperation
      self.PassesTables = PassesTables
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}