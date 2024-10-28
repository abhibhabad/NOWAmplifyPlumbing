// swiftlint:disable all
import Amplify
import Foundation

public enum PassStatus: String, EnumPersistable {
  case purchased = "PURCHASED"
  case redeemed = "REDEEMED"
  case expired = "EXPIRED"
}