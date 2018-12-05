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
    
    lazy var adapter: ListAdapter = {
        let listAdapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
        return listAdapter
    }()
    var photoFeed = PhotoFeedModel(photoFeedModelType: .photoFeedModelTypePopular)
    
    // Lifecycle
    
    init() {
        let flowLayout = UICollectionViewFlowLayout()

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

extension PhotoFeedListKitViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [DiffUtility.DiffableBox(value: self.photoFeed, identifier: self.photoFeed.diffIdentifier as NSObjectProtocol, equal: ==) as ListDiffable]
        
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is DiffUtility.DiffableBox<PhotoFeedModel> {
            return PhotoFeedSectionController()
        }
        
        return ListSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}


