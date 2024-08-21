// swiftlint:disable all
import Amplify
import Foundation

public struct UserTable: Model {
  public let id: String
  public var userId: String?
  public var firstName: String?
  public var lastName: String?
  public var imageUrl: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      userId: String? = nil,
      firstName: String? = nil,
      lastName: String? = nil,
      imageUrl: String? = nil) {
    self.init(id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      imageUrl: imageUrl,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      userId: String? = nil,
      firstName: String? = nil,
      lastName: String? = nil,
      imageUrl: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.userId = userId
      self.firstName = firstName
      self.lastName = lastName
      self.imageUrl = imageUrl
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}