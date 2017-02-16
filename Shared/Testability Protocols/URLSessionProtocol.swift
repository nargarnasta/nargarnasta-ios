import Foundation

protocol URLSessionDataTaskProtocol: class {
  func resume()
}

protocol URLSessionProtocol: class {
  func dataTask(
    with url: URL,
    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
  ) -> URLSessionDataTaskProtocol
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

extension URLSession: URLSessionProtocol {
  func dataTask(
    with url: URL,
    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
  ) -> URLSessionDataTaskProtocol {
    let dataTask: URLSessionDataTask = self.dataTask(
      with: url,
      completionHandler: completionHandler
    )
    return dataTask as URLSessionDataTaskProtocol
  }
}
