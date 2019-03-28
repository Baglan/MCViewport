//
//  MCRecycler.swift
//  MCViewport
//
//  Created by Baglan on 2/11/16.
//  Copyright © 2016 Mobile Creators. All rights reserved.
//

import Foundation

/// Class pfor keeping track of reusable recycled objects
class MCRecycler {
    
    /// The recycled objects
    fileprivate var recycled = [String:[AnyObject]]()
    
    /// Recycle an object
    /// - Parameter recyclingKey: The key to keep track of the iobject
    /// - Parameter object: The object to recycle
    func recycle(_ recyclingKey: String, object: AnyObject) {
        var recycledArray = recycled[recyclingKey] ?? [AnyObject]()
        recycledArray.append(object)
        recycled[recyclingKey] = recycledArray
    }
    
    /// Recycle an object
    ///
    /// An object type description will be used as a key
    ///
    /// - Parameter object: The object to recycle
    func recycle(_ object: AnyObject) {
        recycle(String(describing: type(of: object)), object: object)
    }
    
    /// Dequeue an object
    /// - Parameter recyclingKey: The key that refers to an object
    /// - Returns: An object associated with the key, if any
    func dequeue(_ recyclingKey: String) -> AnyObject? {
        return recycled[recyclingKey]?.popLast()
    }
    
    // MARK: - Shared instance
    
    /// The shared instance
    static let sharedInstance = MCRecycler()
}
