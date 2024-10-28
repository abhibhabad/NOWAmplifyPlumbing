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
  public var venuesID: String
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      passStatus: PassStatus,
      userID: String? = nil,
      purchasedAt: Temporal.DateTime? = nil,
      transactionID: String? = nil,
      listingtableID: String,
      venuesID: String) {
    self.init(id: id,
      passStatus: passStatus,
      userID: userID,
      purchasedAt: purchasedAt,
      transactionID: transactionID,
      listingtableID: listingtableID,
      venuesID: venuesID,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      passStatus: PassStatus,
      userID: String? = nil,
      purchasedAt: Temporal.DateTime? = nil,
      transactionID: String? = nil,
      listingtableID: String,
      venuesID: String,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.passStatus = passStatus
      self.userID = userID
      self.purchasedAt = purchasedAt
      self.transactionID = transactionID
      self.listingtableID = listingtableID
      self.venuesID = venuesID
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}