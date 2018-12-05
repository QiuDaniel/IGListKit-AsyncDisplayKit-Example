//
//  Webservice.swift
//  ASDKgram-Swift
//
//  Created by Calum Harris on 06/01/2017.
//
//  Copyright (c) 2014-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree. An additional grant
//  of patent rights can be found in the PATENTS file in the same directory.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
//   ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// swiftlint:disable force_cast

import UIKit

final class WebService {
	func load<A>(resource: Resource<A>, completion: @escaping (Result<A>) -> ()) {
		URLSession.shared.dataTask(with: resource.url) { data, response, error in
			// Check for errors in responses.
			let result = self.checkForNetworkErrors(data, response, error)
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    completion(resource.parse(data, response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
		}.resume()
	}
}

extension WebService {
	
	fileprivate func checkForNetworkErrors(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<Data> {
		// Check for errors in responses.
		guard error == nil else {
            switch error! {
            case URLError.notConnectedToInternet, URLError.timedOut:
                return .failure(.noInternetConnection)
            default:
                return .failure(.returnedError(error!))
            }
		}
		
		guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            return .failure((.invalidStatusCode("Request returned status code other than 2xx \(String(describing: response))")))
		}
		
		guard let data = data else { return .failure(.dataReturnedNil) }
		
		return .success(data)
	}
}

struct ResponseMetadata {
    let currentPage: Int
    let itemsTotal: Int
    let itemsPerPage: Int
}

extension ResponseMetadata {
    var pagesTotal: Int {
        return itemsTotal / itemsPerPage
    }
}

struct Resource<A> {
	let url: URL
	let parse: (Data, URLResponse?) -> Result<A>
}

extension Resource {
	
    init(url: URL, page:Int, parseResponse: @escaping (ResponseMetadata, Data) -> Result<A>) {
        
        guard let url = URL(string: url.absoluteString.appending("&page=\(page)")) else { fatalError("Malformed URL given") }
		self.url = url
		self.parse = { data, response in
			guard let httpUrlResponse = response as? HTTPURLResponse,
            let xTotalString = httpUrlResponse.allHeaderFields["x-total"] as? String,
            let xTotal = Int(xTotalString),
            let xPerPageString = httpUrlResponse.allHeaderFields["x-per-page"] as? String,
            let xPerPage = Int(xPerPageString)
            else { return .failure(.errorParsingResponse) }
            let metadata = ResponseMetadata(currentPage: page, itemsTotal: xTotal, itemsPerPage: xPerPage)
            return parseResponse(metadata, data)
		}
	}
}

enum Result<T> {
	case success(T)
	case failure(NetworkingErrors)
}

enum NetworkingErrors: Error {
    case errorParsingResponse
	case errorParsingJSON
	case noInternetConnection
	case dataReturnedNil
	case returnedError(Error)
	case invalidStatusCode(String)
	case customError(String)
}
