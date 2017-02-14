import Quick
import Nimble
@testable import NarGarNasta

class TripSpec: QuickSpec { override func spec() {

describe("Trip") {
  let dateFormatter = ISO8601DateFormatter()

  describe("init(jsonObject:)") {
    it("initializes location from JSON object") {
      let jsonObject = [
        "departure_time": "2017-02-14T14:00:00Z",
        "arrival_time": "2017-02-14T14:10:00Z"
      ]

      var trip: Trip?
      expect {
        trip = try Trip(jsonObject: jsonObject)
      }.toNot(throwError())

      expect(trip?.departureTime).to(
        equal(dateFormatter.date(from: "2017-02-14T14:00:00Z"))
      )
      expect(trip?.arrivalTime).to(
        equal(dateFormatter.date(from: "2017-02-14T14:10:00Z"))
      )
    }

    context("with missing properties") {
      it("throws .parametersMissing error") {
        expect {
          try Trip(jsonObject: [:])
        }.to(throwError(TripError.parametersMissing))
      }
    }
  }

  describe("==(lhs:rhs:)") {
    it("considers identical trips equal") {
      var lhs: Trip?
      expect {
        lhs = try Trip(jsonObject: [
          "departure_time": "2017-02-14T14:00:00Z",
          "arrival_time": "2017-02-14T14:10:00Z"
        ])
      }.toNot(throwError())

      var rhs: Trip?
      expect {
        rhs = try Trip(jsonObject: [
          "departure_time": "2017-02-14T14:00:00Z",
          "arrival_time": "2017-02-14T14:10:00Z"
        ])
      }.toNot(throwError())

      expect(lhs == rhs).to(beTrue())
    }

    it("considers differening departure times not equal") {
      var lhs: Trip?
      expect {
        lhs = try Trip(jsonObject: [
          "departure_time": "2017-02-14T14:00:00Z",
          "arrival_time": "2017-02-14T14:10:00Z"
        ])
      }.toNot(throwError())

      var rhs: Trip?
      expect {
        rhs = try Trip(jsonObject: [
          "departure_time": "2017-02-14T13:00:00Z",
          "arrival_time": "2017-02-14T14:10:00Z"
        ])
      }.toNot(throwError())

      expect(lhs == rhs).to(beFalse())
    }

    it("considers differening arrival times not equal") {
      var lhs: Trip?
      expect {
        lhs = try Trip(jsonObject: [
          "departure_time": "2017-02-14T14:00:00Z",
          "arrival_time": "2017-02-14T14:10:00Z"
        ])
      }.toNot(throwError())

      var rhs: Trip?
      expect {
        rhs = try Trip(jsonObject: [
          "departure_time": "2017-02-14T14:00:00Z",
          "arrival_time": "2017-02-14T15:00:00Z"
        ])
      }.toNot(throwError())

      expect(lhs == rhs).to(beFalse())
    }
  }
}

} }
