// swiftlint:disable all
import Amplify
import Foundation

public enum ListingType: String, EnumPersistable {
  case cover = "COVER"
  case event = "EVENT"
  case lineskip = "LINESKIP"
}