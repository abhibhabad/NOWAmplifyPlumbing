// swiftlint:disable all
import Amplify
import Foundation

public struct PassesTable: Model {
  public let id: String
  public var passStatus: PassStatus
  public var userID: String?
  public var purchasedAt: Temporal.DateTime?
  public var transactionID: String?
  public var listingtableID: String
  public var venueName: String
  public var listingName: String
  public var listingType: ListingType
  public var listingDescription: String
  public var listingInstructions: String
  public var listingPrice: Double
  public var listingStart: Temporal.DateTime
  public var listingEnd: Temporal.DateTime
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      passStatus: PassStatus,
      userID: String? = nil,
      purchasedAt: Temporal.DateTime? = nil,
      transactionID: String? = nil,
      listingtableID: String,
      venueName: String,
      listingName: String,
      listingType: ListingType,
      listingDescription: String,
      listingInstructions: String,
      listingPrice: Double,
      listingStart: Temporal.DateTime,
      listingEnd: Temporal.DateTime) {
    self.init(id: id,
      passStatus: passStatus,
      userID: userID,
      purchasedAt: purchasedAt,
      transactionID: transactionID,
      listingtableID: listingtableID,
      venueName: venueName,
      listingName: listingName,
      listingType: listingType,
      listingDescription: listingDescription,
      listingInstructions: listingInstructions,
      listingPrice: listingPrice,
      listingStart: listingStart,
      listingEnd: listingEnd,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      passStatus: PassStatus,
      userID: String? = nil,
      purchasedAt: Temporal.DateTime? = nil,
      transactionID: String? = nil,
      listingtableID: String,
      venueName: String,
      listingName: String,
      listingType: ListingType,
      listingDescription: String,
      listingInstructions: String,
      listingPrice: Double,
      listingStart: Temporal.DateTime,
      listingEnd: Temporal.DateTime,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.passStatus = passStatus
      self.userID = userID
      self.purchasedAt = purchasedAt
      self.transactionID = transactionID
      self.listingtableID = listingtableID
      self.venueName = venueName
      self.listingName = listingName
      self.listingType = listingType
      self.listingDescription = listingDescription
      self.listingInstructions = listingInstructions
      self.listingPrice = listingPrice
      self.listingStart = listingStart
      self.listingEnd = listingEnd
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}