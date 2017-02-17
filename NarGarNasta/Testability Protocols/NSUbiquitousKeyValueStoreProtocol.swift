import Foundation

protocol NSUbiquitousKeyValueStoreProtocol: class {
  func set(_ anObject: Any?, forKey aKey: String)
  func array(forKey aKey: String) -> [Any]?
  func synchronize() -> Bool
}

extension NSUbiquitousKeyValueStore: NSUbiquitousKeyValueStoreProtocol {}
