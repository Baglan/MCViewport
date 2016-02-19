//
//  ViewController.swift
//  MCViewport
//
//  Created by Baglan on 2/11/16.
//  Copyright © 2016 Mobile Creators. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class ViewController: UIViewController {
    @IBOutlet weak var viewport: MCViewportWithScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let verticalPages = 3
        let horizontalPages = 5
        
        for x in 0..<horizontalPages {
            for y in 0..<verticalPages {
                let item = PageIndicator(pageNumber: y * horizontalPages + x)
                item.place(frame: CGRect(x: (viewport.bounds.width - 100) / 2, y: viewport.bounds.height - 120, width: 100, height: 100), viewportOffset: CGPoint(x: viewport.bounds.width * CGFloat(x), y: viewport.bounds.height * CGFloat(y)), parallax: CGPoint(x: 0.4, y: 1))
                item.zIndex = 300
                viewport.addItem(item)
            }
        }
        
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
        viewport.scrollView.alternateDirectionalLockEnabled = true
        viewport.scrollView.frame = viewport.bounds
        viewport.scrollView.contentSize = CGSizeMake(viewport.bounds.width * CGFloat(horizontalPages), viewport.bounds.height * CGFloat(verticalPages))
        viewport.scrollView.alwaysBounceHorizontal = true
        viewport.scrollView.alwaysBounceVertical = true
        
        viewport.scrollView.setContentOffset(CGPoint(x: viewport.bounds.width, y: 0), animated: true)
    }
}

class PageIndicator: MCViewport.ViewItem {
    let pageNumber: Int
    
    init(pageNumber: Int) {
        self.pageNumber = pageNumber
    }
    
    override func willBecomeVisible() {
        super.willBecomeVisible()
        
        guard let label = view as? UILabel else { return }
        label.text = "\(pageNumber)"
    }
    
    override func newView() -> UIView {
        let label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(40)
        label.textAlignment = .Center
        label.text = "!"
        label.layer.borderWidth = 4
        label.layer.borderColor = UIColor.blackColor().CGColor
        label.layer.cornerRadius = 50
        return label
    }
}

class MyItem: MCViewport.ViewItem {
    override func willBecomeVisible() {
        super.willBecomeVisible()
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
