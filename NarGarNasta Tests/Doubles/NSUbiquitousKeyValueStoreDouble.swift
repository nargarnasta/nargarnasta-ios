@testable import NarGarNasta

class NSUbiquitousKeyValueStoreDouble: NSUbiquitousKeyValueStoreProtocol {
  var valueDictionary = [String: [Any]]()
  var nextValueDictionary: [String: [Any]]?

  func set(_ anObject: Any?, forKey aKey: String) {
    guard let array = anObject as? [Any] else {
      fatalError("Extend NSUbiquitousKeyValueStoreDouble to use more types")
    }
    valueDictionary[aKey] = array
  }

  func array(forKey aKey: String) -> [Any]? {
    return valueDictionary[aKey]
  }

  func synchronize() -> Bool {
    if let nextValueDictionary = nextValueDictionary {
      valueDictionary = nextValueDictionary
      self.nextValueDictionary = nil
    }
    return true
  }
}
