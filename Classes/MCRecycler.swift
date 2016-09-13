//
//  MCRecycler.swift
//  MCViewport
//
//  Created by Baglan on 2/11/16.
//  Copyright © 2016 Mobile Creators. All rights reserved.
//

import Foundation

class MCRecycler {
    fileprivate var recycled = [String:[AnyObject]]()
    
    func recycle(_ recyclingKey: String, object: AnyObject) {
        var recycledArray = recycled[recyclingKey] ?? [AnyObject]()
        recycledArray.append(object)
        recycled[recyclingKey] = recycledArray
    }
    
    func recycle(_ object: AnyObject) {
        recycle(String(describing: type(of: object)), object: object)
    }
    
    func dequeue(_ recyclingKey: String) -> AnyObject? {
        return recycled[recyclingKey]?.popLast()
    }
    
    // MARK: - Shared instance
    
    static let sharedInstance = MCRecycler()
}
