//
//  PX500Convenience.swift
//  ASDKgram-Swift
//
//  Created by Calum Harris on 08/01/2017.
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

import Foundation

func parsePopularPage(withURL: URL, page: Int) -> Resource<PopularPageModel> {

    let parse = Resource<PopularPageModel>(url: withURL, page: page) { metaData, jsonData in
        do {
            let photos = try JSONDecoder().decode([PhotoModel].self, from: jsonData)
            return .success(PopularPageModel(metaData: metaData, photos: photos))
        } catch {
            return .failure(.errorParsingJSON)
        }
	}

	return parse
}
