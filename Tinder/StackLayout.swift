//
//  StackLayout.swift
//  Tinder
//
//  Created by Arsen Gasparyan on 20/07/15.
//  Copyright © 2015 Arsen Gasparyan. All rights reserved.
//

import UIKit

class StackLayout: UICollectionViewLayout {
    internal var willDeleteForegroundItem: Void -> Void = { _ in }
    internal var didDeleteForegroundItem: Void -> Void = { _ in }
    
    private var pan: UIPanGestureRecognizer!
    private var snapBehavior: UISnapBehavior!
    private var attachmentBehavior: UIAttachmentBehavior!
    private lazy var center: CGPoint = { [unowned self] in
        let size = self.collectionView!.bounds.size
        return CGPointMake(size.width / 2, size.height / 2)
    }()
    
    private var foregroundStackFrame: StackAttributes!
    private var moveTo: CGPoint!
    
    private lazy var animator: UIDynamicAnimator = { [unowned self] in
        return UIDynamicAnimator(collectionViewLayout: self)
    }()
    
    override func collectionViewContentSize() -> CGSize {
        // print("collectionViewContentSize")
        
        return collectionView!.bounds.size
    }
    
    override func prepareLayout() {
        // print("prepareLayout")
        super.prepareLayout()

        if pan == nil {
            pan = UIPanGestureRecognizer(target: self, action: "didPan:")
            collectionView!.addGestureRecognizer(pan)
        }
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes {
        // print("layoutAttributesForItemAtIndexPath \(indexPath.row)")
        
        let attr = StackAttributes(forCellWithIndexPath: indexPath)
        attr.size = CGSize(width: 300, height: 300)
        attr.zIndex = -indexPath.row
        
        let scale = CGFloat(1 - (Double(indexPath.row) * 0.05))
        attr.transform = CGAffineTransformScale(attr.transform, scale, scale)
        
        let offset = CGFloat(Int(center.y) + 14 * indexPath.row)
        attr.center = CGPointMake(center.x, offset)
        
        return attr
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // print("layoutAttributesForElementsInRect \(rect)")
        var attributes = [StackAttributes]()
        let count = collectionView!.numberOfItemsInSection(0)
        
        if count == 0 { return attributes }
        
        if foregroundStackFrame == nil {
            let mainIndex = NSIndexPath(forItem: 0, inSection: 0)
            foregroundStackFrame = layoutAttributesForItemAtIndexPath(mainIndex) as! StackAttributes
            
            snapBehavior = UISnapBehavior(item: foregroundStackFrame, snapToPoint: foregroundStackFrame.center)
            animator.addBehavior(snapBehavior)
        }
        attributes.append(foregroundStackFrame)
        
        for (var i = 1; i < count; i++) {
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            let attr = layoutAttributesForItemAtIndexPath(indexPath) as! StackAttributes
            attributes.append(attr)
        }
        
        return attributes
    }
    
    internal func didPan(sender: UIPanGestureRecognizer) {
        if foregroundStackFrame == nil { return }
        
        let locaiton = sender.locationInView(collectionView)
        let translation = sender.translationInView(collectionView)
        
        switch pan.state {
        case .Began:
            animator.removeBehavior(self.snapBehavior)
            
            let offset = UIOffset(horizontal: -foregroundStackFrame.center.x + locaiton.x,
                                    vertical: -foregroundStackFrame.center.y + locaiton.y)
            
            attachmentBehavior = UIAttachmentBehavior(item: foregroundStackFrame, offsetFromCenter: offset, attachedToAnchor: locaiton)
            animator.addBehavior(attachmentBehavior)
            
            attachmentBehavior.anchorPoint = locaiton
        case .Changed:
            attachmentBehavior.anchorPoint = locaiton
        case .Cancelled, .Ended:
            animator.removeBehavior(attachmentBehavior)
            
            if abs(translation.x) > 80 {
                moveTo = CGPointMake(copysign(1000, translation.x), 0)
                
                collectionView!.performBatchUpdates({ () in
                    self.foregroundStackFrame = nil
                    self.willDeleteForegroundItem()
                    let indexPath = NSIndexPath(forItem: 0, inSection: 0)
                    self.collectionView!.deleteItemsAtIndexPaths([indexPath])
                }, completion: { (finished) in
                    self.animator.removeBehavior(self.snapBehavior)
                    self.didDeleteForegroundItem()
                })

            } else {
                animator.addBehavior(snapBehavior)
            }
            
            pan.setTranslation(CGPointZero, inView: collectionView)
        default:
            break
        }
    }
    
    
    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = super.finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath)
        
        if itemIndexPath.row == 0 { attr?.center = moveTo }
    
        return attr
    }

}