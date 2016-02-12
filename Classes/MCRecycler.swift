//
//  MCRecycler.swift
//  MCViewport
//
//  Created by Baglan on 2/11/16.
//  Copyright © 2016 Mobile Creators. All rights reserved.
//

import Foundation

class MCRecycler {
    private var recycled = [String:[AnyObject]]()
    
    func recycle(recyclingKey: String, object: AnyObject) {
        var recycledArray = recycled[recyclingKey] ?? [AnyObject]()
        recycledArray.append(object)
        recycled[recyclingKey] = recycledArray
    }
    
    func recycle(object: AnyObject) {
        recycle(String(object.dynamicType), object: object)
    }
    
    func dequeue(recyclingKey: String) -> AnyObject? {
        return recycled[recyclingKey]?.popLast()
    }
    
    // MARK: - Shared instance
    
    static let sharedInstance = MCRecycler()
}