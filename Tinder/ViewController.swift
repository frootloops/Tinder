//
//  ViewController.swift
//  Tinder
//
//  Created by Arsen Gasparyan on 20/07/15.
//  Copyright © 2015 Arsen Gasparyan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    private var colors = [ UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor() ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationController()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = collectionView.collectionViewLayout as! StackLayout
        layout.willDeleteForegroundItem = {
            print("willDeleteForegroundItem")
            self.colors.removeAtIndex(0)
        }
        layout.didDeleteForegroundItem = {
            print("didDeleteForegroundItem")
            self.colors.append(self.colors[0])
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StackFrame", forIndexPath: indexPath) as! StackFrame
        cell.prepareForUse()

        cell.backgroundColor = colors[indexPath.row]
        
        return cell
    }
    
    private func configureNavigationController() {
        let logo = UIImage(named: "HeaderLogo")!
        navigationItem.titleView = UIImageView(image: logo)
    }
}

