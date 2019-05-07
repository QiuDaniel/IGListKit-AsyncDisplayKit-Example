//
//  PhotoFeedSectionController.swift
//  ASDKgram-Swift
//
//  Created by Daniel on 2017/9/18.
//  Copyright © 2017年 Calum Harris. All rights reserved.
//

import UIKit
import AsyncDisplayKit


class PhotoFeedSectionController: ASCollectionSectionController, ASSectionController {
    
    var photoFeed = PhotoFeedModel(photoFeedModelType: .photoFeedModelTypePopular)


    override func didUpdate(to object: Any) {
        if let other = object as? DiffUtility.DiffableBox<PhotoFeedModel> {
            photoFeed = other.value
            if photoFeed.photos.count > 0 {
                self.setItmes(newItems: photoFeed.photos, animated: false)
            }
        }       
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = ASIGListSectionControllerMethods.cellForItem(at: index, sectionController: self)
        return cell
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return ASIGListSectionControllerMethods .sizeForItem(at: index)
    }
    
    override func didSelectItem(at index: Int) {
        
    }
    
    // MARK: - ASSectionController
    
    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        let photo = photoFeed.itemAtIndexPath(IndexPath(row: index, section: 0))
        let nodeBlock: ASCellNodeBlock = { 
            let node = PhotoTableNodeCell(photoModel: photo)
            return node
        }
        return nodeBlock

    }
    
    func nodeForItem(at index: Int) -> ASCellNode {
        let photo = photoFeed.itemAtIndexPath(IndexPath(row: index, section: 0))
        let node = PhotoTableNodeCell(photoModel: photo)
        return node
    }
    
    func beginBatchFetch(with context: ASBatchContext) {
        DispatchQueue.main.async {
            self.fetchNewBatchWithContext(context)
        }
    }
    
    // MARK: - Data
    func fetchNewBatchWithContext(_ context: ASBatchContext?)  {
        photoFeed.updateNewBatchOfPopularPhotos(additionsAndConnectionStatusCompletion: { [weak self] (additions, connectionStatus) in
            guard let `self` = self else { return }
            switch connectionStatus {
            case .connected:
                self.setItmes(newItems: self.photoFeed.photos, animated: false, completion: {
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

extension PhotoFeedSectionController: ListSupplementaryViewSource {
    func supportedElementKinds() -> [String] {
        return [UICollectionView.elementKindSectionHeader]
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        return ASIGListSupplementaryViewSourceMethods.viewForSupplementaryElement(ofKind: elementKind, at: index, sectionController: self)
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        return ASIGListSupplementaryViewSourceMethods.sizeForSupplementaryView(ofKind:elementKind, at:index)
    }
}
