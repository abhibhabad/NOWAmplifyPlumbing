// swiftlint:disable all
import Amplify
import Foundation

public struct Venues: Model {
  public let id: String
  public var venueName: String
  public var venuePhoneNumber: String
  public var venueHours: [Temporal.Time]?
  public var venueImage: String?
  public var accountName: String?
  public var routingNumber: Int
  public var EIN: Int
  public var accountNumber: Int
  public var ownerFirstName: String
  public var ownerLastName: String
  public var ownerPhoneNumber: String
  public var ownerEmail: String?
  public var ListingTables: List<ListingTable>?
  public var revenueSplit: Double?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      venueName: String,
      venuePhoneNumber: String,
      venueHours: [Temporal.Time]? = nil,
      venueImage: String? = nil,
      accountName: String? = nil,
      routingNumber: Int,
      EIN: Int,
      accountNumber: Int,
      ownerFirstName: String,
      ownerLastName: String,
      ownerPhoneNumber: String,
      ownerEmail: String? = nil,
      ListingTables: List<ListingTable>? = [],
      revenueSplit: Double? = nil) {
    self.init(id: id,
      venueName: venueName,
      venuePhoneNumber: venuePhoneNumber,
      venueHours: venueHours,
      venueImage: venueImage,
      accountName: accountName,
      routingNumber: routingNumber,
      EIN: EIN,
      accountNumber: accountNumber,
      ownerFirstName: ownerFirstName,
      ownerLastName: ownerLastName,
      ownerPhoneNumber: ownerPhoneNumber,
      ownerEmail: ownerEmail,
      ListingTables: ListingTables,
      revenueSplit: revenueSplit,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      venueName: String,
      venuePhoneNumber: String,
      venueHours: [Temporal.Time]? = nil,
      venueImage: String? = nil,
      accountName: String? = nil,
      routingNumber: Int,
      EIN: Int,
      accountNumber: Int,
      ownerFirstName: String,
      ownerLastName: String,
      ownerPhoneNumber: String,
      ownerEmail: String? = nil,
      ListingTables: List<ListingTable>? = [],
      revenueSplit: Double? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.venueName = venueName
      self.venuePhoneNumber = venuePhoneNumber
      self.venueHours = venueHours
      self.venueImage = venueImage
      self.accountName = accountName
      self.routingNumber = routingNumber
      self.EIN = EIN
      self.accountNumber = accountNumber
      self.ownerFirstName = ownerFirstName
      self.ownerLastName = ownerLastName
      self.ownerPhoneNumber = ownerPhoneNumber
      self.ownerEmail = ownerEmail
      self.ListingTables = ListingTables
      self.revenueSplit = revenueSplit
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}