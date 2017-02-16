import XCTest
import Foundation
@testable import NarGarNasta

class URLSessionDataTaskDouble: URLSessionDataTaskProtocol {
  let url: URL
  let response: (Data?, URLResponse?, Error?)
  let completionHandler: (Data?, URLResponse?, Error?) -> Void

  fileprivate init(
    url: URL,
    response: (Data?, URLResponse?, Error?),
    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
  ) {
    self.url = url
    self.response = response
    self.completionHandler = completionHandler
  }

  func resume() {
    completionHandler(response.0, response.1, response.2)
  }
}

class URLSessionDouble: URLSessionProtocol {
  var queuedResponses = [(Data?, URLResponse?, Error?)]()
  var lastDataTask: URLSessionDataTaskDouble?

  func dataTask(
    with url: URL,
    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
  ) -> URLSessionDataTaskProtocol {
    guard let response = queuedResponses.popLast() else {
      XCTFail("No responses queued for request to URLSessionDouble.")
      fatalError(
        "No responses queued for request to URLSessionDouble, can't continue " +
        "safely."
      )
    }

    let dataTask = URLSessionDataTaskDouble(
      url: url,
      response: response,
      completionHandler: completionHandler
    )
    lastDataTask = dataTask
    return dataTask
  }
}
