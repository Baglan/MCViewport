//
//  ViewController.swift
//  MCViewport
//
//  Created by Baglan on 2/11/16.
//  Copyright © 2016 Mobile Creators. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class ViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var viewport: MCViewportWithScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        for x in 1...10 {
            for y in 1...1 {
                let item = MyItem()
                item.place(frame: CGRectMake(CGFloat(x) * 110, CGFloat(y) * 110, 100, 100), viewportOffset: CGPointZero, parallax: CGPoint(x: 1.5, y: 1.5))
                item.zIndex = 100
                viewport.addItem(item)
            }
        }
        
        let item = MyControllerItem()
        item.place(frame: CGRect(x: 50, y: 200, width: 200, height: 200))
        item.zIndex = 200
        viewport.addItem(item)
        
        viewport.scrollView.pagingEnabled = true
        viewport.scrollView.directionalLockEnabled = true
        viewport.scrollView.frame = viewport.bounds
        viewport.scrollView.contentSize = CGSizeMake(viewport.bounds.width * 5, viewport.bounds.height * 2)
        viewport.scrollView.alwaysBounceHorizontal = true
        viewport.scrollView.alwaysBounceVertical = true
        
        viewport.setNeedsLayout()
    }
}

class MyItem: MCViewport.ViewItem {
    override func didBecomeVisible() {
        super.didBecomeVisible()
        if let view = view {
            view.backgroundColor = UIColor.redColor()
        }
    }
}

class MyViewController: UIViewController {
    @IBOutlet weak var button: MCButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.action = { _ in
            NSLog("--- tap!")
        }
    }
}

class MyControllerItem: MCViewport.ViewControllerItem {
    override func newViewController() -> UIViewController? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MyViewController")
    }
}
