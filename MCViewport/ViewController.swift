//
//  ViewController.swift
//  MCViewport
//
//  Created by Baglan on 2/11/16.
//  Copyright © 2016 Mobile Creators. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var viewport: MCViewport!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    var scrollView = UIScrollView()
    let displayLinker = MCDisplayLinker()
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
        
        viewport.update()
        
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.directionalLockEnabled = true
        scrollView.contentSize = CGSizeMake(view.bounds.width * 2, view.bounds.height * 2)
        scrollView.frame = view.bounds
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = true

        
        view.addGestureRecognizer(scrollView.panGestureRecognizer)
//        view.addSubview(scrollView)
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        viewport.contentTransformation.translation = CGPointMake(-scrollView.contentOffset.x, -scrollView.contentOffset.y)
        viewport.update()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            NSLog("--- hola!")
        }
    }
}

class MyControllerItem: MCViewport.ViewControllerItem {
    override func newViewController() -> UIViewController? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MyViewController")
    }
}
