// swiftlint:disable all
import Amplify
import Foundation

public struct ListingTable: Model {
  public let id: String
  public var listingName: String
  public var listingType: ListingType
  public var listingStart: Temporal.DateTime
  public var listingEnd: Temporal.DateTime
  public var totalPasses: Int
  public var passesSold: Int
  public var instructions: String
  public var description: String
  public var createdAt: Temporal.DateTime
  public var createdBy: String
  public var PassesTables: List<PassesTable>?
  public var venuesID: String
  public var venueName: String
  public var isActive: Bool
  public var listingPrice: Double
  public var deletedAt: Temporal.DateTime?
  public var isExpired: Bool
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      listingName: String,
      listingType: ListingType,
      listingStart: Temporal.DateTime,
      listingEnd: Temporal.DateTime,
      totalPasses: Int,
      passesSold: Int,
      instructions: String,
      description: String,
      createdAt: Temporal.DateTime,
      createdBy: String,
      PassesTables: List<PassesTable>? = [],
      venuesID: String,
      venueName: String,
      isActive: Bool,
      listingPrice: Double,
      deletedAt: Temporal.DateTime? = nil,
      isExpired: Bool) {
    self.init(id: id,
      listingName: listingName,
      listingType: listingType,
      listingStart: listingStart,
      listingEnd: listingEnd,
      totalPasses: totalPasses,
      passesSold: passesSold,
      instructions: instructions,
      description: description,
      createdAt: createdAt,
      createdBy: createdBy,
      PassesTables: PassesTables,
      venuesID: venuesID,
      venueName: venueName,
      isActive: isActive,
      listingPrice: listingPrice,
      deletedAt: deletedAt,
      isExpired: isExpired,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      listingName: String,
      listingType: ListingType,
      listingStart: Temporal.DateTime,
      listingEnd: Temporal.DateTime,
      totalPasses: Int,
      passesSold: Int,
      instructions: String,
      description: String,
      createdAt: Temporal.DateTime,
      createdBy: String,
      PassesTables: List<PassesTable>? = [],
      venuesID: String,
      venueName: String,
      isActive: Bool,
      listingPrice: Double,
      deletedAt: Temporal.DateTime? = nil,
      isExpired: Bool,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.listingName = listingName
      self.listingType = listingType
      self.listingStart = listingStart
      self.listingEnd = listingEnd
      self.totalPasses = totalPasses
      self.passesSold = passesSold
      self.instructions = instructions
      self.description = description
      self.createdAt = createdAt
      self.createdBy = createdBy
      self.PassesTables = PassesTables
      self.venuesID = venuesID
      self.venueName = venueName
      self.isActive = isActive
      self.listingPrice = listingPrice
      self.deletedAt = deletedAt
      self.isExpired = isExpired
      self.updatedAt = updatedAt
  }
}