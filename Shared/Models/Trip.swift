import Foundation

enum TripError: Error {
  case parametersMissing, dateFormatInvalid
}

struct Trip: Equatable {
  let departureTime: Date
  let arrivalTime: Date

  init(jsonObject: [String: Any]) throws {
    guard
      let departureTimeString = jsonObject["departure_time"] as? String,
      let arrivalTimeString = jsonObject["arrival_time"] as? String
    else {
      throw TripError.parametersMissing
    }

    self.departureTime = try Trip.dateFromISO8601String(departureTimeString)
    self.arrivalTime = try Trip.dateFromISO8601String(arrivalTimeString)
  }

  private static func dateFromISO8601String(
    _ iso8601String: String
  ) throws -> Date {
    if let date = ISO8601DateFormatter().date(from: iso8601String) {
      return date
    } else {
      throw TripError.dateFormatInvalid
    }
  }

  static func ==(lhs: Trip, rhs: Trip) -> Bool {
    return (
      lhs.departureTime == rhs.departureTime &&
        lhs.arrivalTime == rhs.arrivalTime
    )
  }
}
