// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "6a9166133be48fa427977390e8b82f10"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: UserTable.self)
    ModelRegistry.register(modelType: PassesTable.self)
    ModelRegistry.register(modelType: ListingTable.self)
    ModelRegistry.register(modelType: Venues.self)
  }
}