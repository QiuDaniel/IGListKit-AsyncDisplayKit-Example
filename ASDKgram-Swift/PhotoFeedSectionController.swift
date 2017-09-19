//
//  PhotoFeedSectionController.swift
//  ASDKgram-Swift
//
//  Created by Daniel on 2017/9/18.
//  Copyright © 2017年 Calum Harris. All rights reserved.
//

import UIKit
import AsyncDisplayKit


class PhotoFeedSectionController: ASCollectionSectionController, ASSectionController, IGListSectionType {
    
    var photoFeed: PhotoFeedModel?

    // MARK: - IGListSectionType

    func didUpdate(to object: Any) {
        if let other = object as? DiffUtility.DiffableBox<PhotoFeedModel> {
            photoFeed = other.value
            if let photos = photoFeed?.photos {
                self.setItmes(newItems: photos, animated: false)
            }
        }       
    }
    
    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = ASIGListSectionControllerMethods.cellForItem(at: index, sectionController: self)
        return cell
    }
    
    func sizeForItem(at index: Int) -> CGSize {
        return ASIGListSectionControllerMethods .sizeForItem(at: index)
    }
    
    func didSelectItem(at index: Int) {
        
    }
    
    // MARK: - ASSectionController
    
    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        let photo = photoFeed?.photos[index]
        let nodeBlock: ASCellNodeBlock = { _ in
            let node = PhotoTableNodeCell(photoModel: photo!)
            return node
        }
        return nodeBlock

    }
    
    func beginBatchFetch(with context: ASBatchContext) {
        DispatchQueue.main.async {
            self.fetchNewBatchWithContext(context)
        }
    }
    
    // MARK: - Data
    func fetchNewBatchWithContext(_ context: ASBatchContext?)  {
        if let photoFeed = photoFeed {
            photoFeed.updateNewBatchOfPopularPhotos(additionsAndConnectionStatusCompletion: { (additions, connectionStatus) in
                switch connectionStatus {
                case .connected:
                    self.setItmes(newItems: photoFeed.photos, animated: false, completion: {
                        context?.completeBatchFetching(true)
                    })
                case .noConnection:
                    if context != nil {
                        context!.completeBatchFetching(true)
                    }
                    break
                }

            })
        }
    }
    
}

extension PhotoFeedSectionController: IGListSupplementaryViewSource {
    func supportedElementKinds() -> [String] {
        return [UICollectionElementKindSectionHeader]
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        return ASIGListSupplementaryViewSourceMethods.viewForSupplementaryElement(ofKind: elementKind, at: index, sectionController: self)
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        return ASIGListSupplementaryViewSourceMethods.sizeForSupplementaryView(ofKind:elementKind, at:index)
    }
}
