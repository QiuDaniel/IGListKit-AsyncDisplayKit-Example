//
//  Diffable.swift
//  ASDKgram-Swift
//
//  Created by Daniel on 2017/9/19.
//  Copyright © 2017年 Calum Harris. All rights reserved.
//

import UIKit
import IGListKit

public protocol Diffable: Equatable {

    var diffIdentifier: String { get }
}

public struct DiffUtility {
    public struct DiffResult {
        public typealias Move = (from: Int, to: Int)
        public var inserts: IndexSet
        public var deletes: IndexSet
        public var updates: IndexSet 
        public let moves: [Move]
        
        public let oldIndexForID: (_ id: String) -> Int
        public let newIndexForID: (_ id: String) -> Int
    }
    
    public static func diff<T: Diffable>(originalItems: [T], newItems: [T]) -> DiffResult {
        let old = originalItems.map({ DiffableBox(value: $0, identifier: $0.diffIdentifier as NSObjectProtocol, equal: ==) })
        let new = newItems.map({ DiffableBox(value: $0, identifier: $0.diffIdentifier as NSObjectProtocol, equal: ==) })
        let result = IGListDiff(old, new, .equality)
        
        let inserts = result.inserts
        let deletes = result.deletes
        let updates = result.updates
        
        let moves: [DiffResult.Move] = result.moves.map({ (from: $0.from, to: $0.to) })
        
        let oldIndexForID: (_ id: String) -> Int = { id in
            return result.oldIndex(forIdentifier: NSString(string: id))
        }
        let newIndexForID: (_ id: String) -> Int = { id in
            return result.newIndex(forIdentifier: NSString(string: id))
        }
        return DiffResult(inserts: inserts, deletes: deletes, updates: updates, moves: moves, oldIndexForID: oldIndexForID, newIndexForID: newIndexForID)
    }
    
    public final class DiffableBox<T: Diffable>: IGListDiffable {
        
        let value: T
        let identifier: NSObjectProtocol
        let equal: (T, T) -> Bool
        
        init(value: T, identifier: NSObjectProtocol, equal: @escaping(T, T) -> Bool) {
            self.value = value
            self.identifier = identifier
            self.equal = equal
        }
        
        // IGListDiffable
        
        public func diffIdentifier() -> NSObjectProtocol {
            return identifier
        }
        
        public func isEqual(toDiffableObject object: IGListDiffable?) -> Bool {
            if let other = object as? DiffableBox<T> {
                return equal(value, other.value)
            }
            return false
        }
    }
}
