// swiftlint:disable all
import Amplify
import Foundation

public struct UserTable: Model {
  public let id: String
  public var userId: String?
  public var firstName: String?
  public var lastName: String?
  public var imageKey: String?
  public var userEmail: String?
  public var userPhoneNumber: String?
  public var venueNotifications: Bool?
  public var promotionNotifications: Bool?
  public var emailNotifications: Bool?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      userId: String? = nil,
      firstName: String? = nil,
      lastName: String? = nil,
      imageKey: String? = nil,
      userEmail: String? = nil,
      userPhoneNumber: String? = nil,
      venueNotifications: Bool? = nil,
      promotionNotifications: Bool? = nil,
      emailNotifications: Bool? = nil) {
    self.init(id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      imageKey: imageKey,
      userEmail: userEmail,
      userPhoneNumber: userPhoneNumber,
      venueNotifications: venueNotifications,
      promotionNotifications: promotionNotifications,
      emailNotifications: emailNotifications,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      userId: String? = nil,
      firstName: String? = nil,
      lastName: String? = nil,
      imageKey: String? = nil,
      userEmail: String? = nil,
      userPhoneNumber: String? = nil,
      venueNotifications: Bool? = nil,
      promotionNotifications: Bool? = nil,
      emailNotifications: Bool? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.userId = userId
      self.firstName = firstName
      self.lastName = lastName
      self.imageKey = imageKey
      self.userEmail = userEmail
      self.userPhoneNumber = userPhoneNumber
      self.venueNotifications = venueNotifications
      self.promotionNotifications = promotionNotifications
      self.emailNotifications = emailNotifications
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}