//
//  PhotoFeedTableNodeController.swift
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

import AsyncDisplayKit

class PhotoFeedTableNodeController: ASViewController<ASTableNode> {
	
    private lazy var activityIndicator: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .gray)
    }()
    var photoFeed = PhotoFeedModel(photoFeedModelType: .photoFeedModelTypePopular)
    
    // MARK: LifeCycle
	
    init() {
		super.init(node: ASTableNode())
		navigationItem.title = "ASDK"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		node.allowsSelection = false
		node.view.separatorStyle = .none
		node.dataSource = self
		node.delegate = self
        node.leadingScreensForBatching = 2.5
		navigationController?.hidesBarsOnSwipe = true
        node.view.addSubview(activityIndicator)
	}
	
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bounds = node.bounds
        activityIndicator.frame.origin = CGPoint(x: (bounds.width - activityIndicator.frame.width) / 2.0, y: (bounds.height - activityIndicator.frame.height) / 2.0)
        
    }
	
	func fetchNewBatchWithContext(_ context: ASBatchContext?) {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
		
		photoFeed.updateNewBatchOfPopularPhotos() { additions, connectionStatus in
			switch connectionStatus {
			case .connected:
				self.activityIndicator.stopAnimating()
				self.addRowsIntoTableNode(newPhotoCount: additions)
				context?.completeBatchFetching(true)
			case .noConnection:
				self.activityIndicator.stopAnimating()
                context?.completeBatchFetching(true)
			}
		}
	}
	
	func addRowsIntoTableNode(newPhotoCount newPhotos: Int) {
		let indexRange = (photoFeed.numberOfItems - newPhotos..<photoFeed.numberOfItems)
		let indexPaths = indexRange.map { IndexPath(row: $0, section: 0) }
		node.insertRows(at: indexPaths, with: .none)
	}
}

extension PhotoFeedTableNodeController: ASTableDataSource, ASTableDelegate {
	
	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		return photoFeed.numberOfItems
	}
	
	func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
		let photo = photoFeed.itemAtIndexPath(indexPath)
		let nodeBlock: ASCellNodeBlock = { 
			return PhotoTableNodeCell(photoModel: photo)
		}
		return nodeBlock
	}
	
	func shouldBatchFetchForCollectionNode(collectionNode: ASCollectionNode) -> Bool {
		return true
	}
	
	func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
		fetchNewBatchWithContext(context)
	}
}
