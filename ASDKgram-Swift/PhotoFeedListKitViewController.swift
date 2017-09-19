//
//  PhotoFeedListKitViewController.swift
//  ASDKgram-Swift
//
//  Created by Daniel on 2017/9/1.
//  Copyright © 2017年 Calum Harris. All rights reserved.
//

import UIKit
import IGListKit
import AsyncDisplayKit

class PhotoFeedListKitViewController: ASViewController<ASCollectionNode> {
    
    lazy var adapter: IGListAdapter = {
        let listAdapter = IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 0)
        return listAdapter
    }()
    
    var photoFeed: PhotoFeedModel
    var screenSizeForWidth: CGSize = {
        let screenRect = UIScreen.main.bounds
        let screenScale = UIScreen.main.scale
        return CGSize(width: screenRect.size.width * screenScale, height: screenRect.size.width * screenScale)
    }()
    
    init() {
        let flowLayout = UICollectionViewFlowLayout()
        photoFeed = PhotoFeedModel(initWithPhotoFeedModelType: .photoFeedModelTypePopular, requiredImageSize: screenSizeForWidth)
        super.init(node: ASCollectionNode(collectionViewLayout: flowLayout))
        adapter.setASDKCollectionNode(node)
        adapter.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension PhotoFeedListKitViewController: IGListAdapterDataSource {
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        return [DiffUtility.DiffableBox(value: self.photoFeed, identifier: self.photoFeed.diffIdentifier as NSObjectProtocol, equal: ==)]
        
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        if object is DiffUtility.DiffableBox<PhotoFeedModel> {
            return PhotoFeedSectionController()
        }
        
        return IGListSectionController()
    }
    
    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        return nil
    }
}


