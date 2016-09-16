//
//  TBEmptyDataSet.swift
//  TBEmptyDataSet
//
//  Created by Xin Hong on 15/11/19.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit

public protocol TBEmptyDataSetDataSource: NSObjectProtocol {
    func imageForEmptyDataSet(_ scrollView: UIScrollView!) -> UIImage?
    func titleForEmptyDataSet(_ scrollView: UIScrollView!) -> NSAttributedString?
    func descriptionForEmptyDataSet(_ scrollView: UIScrollView!) -> NSAttributedString?

    func imageTintColorForEmptyDataSet(_ scrollView: UIScrollView!) -> UIColor?
    func backgroundColorForEmptyDataSet(_ scrollView: UIScrollView!) -> UIColor?

    func verticalOffsetForEmptyDataSet(_ scrollView: UIScrollView!) -> CGFloat
    func verticalSpacesForEmptyDataSet(_ scrollView: UIScrollView!) -> [CGFloat]

    func customViewForEmptyDataSet(_ scrollView: UIScrollView!) -> UIView?
}

public protocol TBEmptyDataSetDelegate: NSObjectProtocol {
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool
    func emptyDataSetTapEnabled(_ scrollView: UIScrollView!) -> Bool
    func emptyDataSetScrollEnabled(_ scrollView: UIScrollView!) -> Bool

    func emptyDataSetDidTapView(_ scrollView: UIScrollView!)

    func emptyDataSetWillAppear(_ scrollView: UIScrollView!)
    func emptyDataSetDidAppear(_ scrollView: UIScrollView!)
    func emptyDataSetWillDisappear(_ scrollView: UIScrollView!)
    func emptyDataSetDidDisappear(_ scrollView: UIScrollView!)
}

// MARK: - UIScrollView Extension
extension UIScrollView: UIGestureRecognizerDelegate {
    // MARK: - Properties
    public var emptyDataSetDataSource: TBEmptyDataSetDataSource? {
        get {
            let container = objc_getAssociatedObject(self, &AssociatedKeys.emptyDataSetDataSource) as? WeakObjectContainer
            return container?.object as? TBEmptyDataSetDataSource
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.emptyDataSetDataSource, WeakObjectContainer(object: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                if self is UITableView {
                    UITableView.tb_swizzleTableViewReloadData()
                    UITableView.tb_swizzleTableViewEndUpdates()
                }
                if self is UICollectionView {
                    UICollectionView.tb_swizzleCollectionViewReloadData()
                    UICollectionView.tb_swizzleCollectionViewPerformBatchUpdates()
                }
            } else {
                handlingInvalidEmptyDataSet()
            }
        }
    }

    public var emptyDataSetDelegate: TBEmptyDataSetDelegate? {
        get {
            let container = objc_getAssociatedObject(self, &AssociatedKeys.emptyDataSetDelegate) as? WeakObjectContainer
            return container?.object as? TBEmptyDataSetDelegate
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.emptyDataSetDelegate, WeakObjectContainer(object: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                handlingInvalidEmptyDataSet()
            }
        }
    }

    public var emptyDataViewVisible: Bool {
        if let emptyDataView = objc_getAssociatedObject(self, &AssociatedKeys.emptyDataView) as? EmptyDataView {
            return !emptyDataView.isHidden
        }
        return false
    }

    fileprivate var emptyDataView: EmptyDataView! {
        var emptyDataView = objc_getAssociatedObject(self, &AssociatedKeys.emptyDataView) as? EmptyDataView
        if emptyDataView == nil {
            emptyDataView = EmptyDataView(frame: frame)
            emptyDataView!.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            emptyDataView!.isHidden = true

            emptyDataView!.tapGesture = UITapGestureRecognizer(target: self, action: #selector(UIScrollView.didTapEmptyDataView(_:)))
            emptyDataView!.tapGesture.delegate = self
            emptyDataView!.addGestureRecognizer(emptyDataView!.tapGesture)
            setEmptyDataView(emptyDataView!)
        }
        return emptyDataView!
    }

    // MARK: - Setters
    fileprivate func setEmptyDataView(_ emptyDataView: EmptyDataView?) {
        objc_setAssociatedObject(self, &AssociatedKeys.emptyDataView, emptyDataView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    // MARK: - DataSource getters
    fileprivate func emptyDataSetImage() -> UIImage? {
        return emptyDataSetDataSource?.imageForEmptyDataSet(self)
    }

    fileprivate func emptyDataSetTitle() -> NSAttributedString? {
        return emptyDataSetDataSource?.titleForEmptyDataSet(self)
    }

    fileprivate func emptyDataSetDescription() -> NSAttributedString? {
        return emptyDataSetDataSource?.descriptionForEmptyDataSet(self)
    }

    fileprivate func emptyDataSetImageTintColor() -> UIColor? {
        return emptyDataSetDataSource?.imageTintColorForEmptyDataSet(self)
    }

    fileprivate func emptyDataSetBackgroundColor() -> UIColor? {
        return emptyDataSetDataSource?.backgroundColorForEmptyDataSet(self)
    }

    fileprivate func emptyDataSetVerticalOffset() -> CGFloat {
        return emptyDataSetDataSource?.verticalOffsetForEmptyDataSet(self) ?? DefaultValues.verticalOffset
    }

    fileprivate func emptyDataSetVerticalSpaces() -> [CGFloat] {
        return emptyDataSetDataSource?.verticalSpacesForEmptyDataSet(self) ?? [DefaultValues.verticalSpace, DefaultValues.verticalSpace]
    }

    fileprivate func emptyDataSetCustomView() -> UIView? {
        return emptyDataSetDataSource?.customViewForEmptyDataSet(self)
    }

    // MARK: - Delegate getters
    fileprivate func emptyDataSetShouldDisplay() -> Bool {
        return emptyDataSetDelegate?.emptyDataSetShouldDisplay(self) ?? true
    }

    fileprivate func emptyDataSetTapEnabled() -> Bool {
        return emptyDataSetDelegate?.emptyDataSetTapEnabled(self) ?? true
    }

    fileprivate func emptyDataSetScrollEnabled() -> Bool {
        return emptyDataSetDelegate?.emptyDataSetScrollEnabled(self) ?? false
    }

    // MARK: - Public
    public func updateEmptyDataSetIfNeeded() {
        reloadEmptyDataSet()
    }

    // MARK: - View events
    func didTapEmptyDataView(_ sender: AnyObject) {
        emptyDataSetDelegate?.emptyDataSetDidTapView(self)
    }

    fileprivate func emptyDataSetWillAppear() {
        emptyDataSetDelegate?.emptyDataSetWillAppear(self)
    }

    fileprivate func emptyDataSetDidAppear() {
        emptyDataSetDelegate?.emptyDataSetDidAppear(self)
    }

    fileprivate func emptyDataSetWillDisappear() {
        emptyDataSetDelegate?.emptyDataSetWillDisappear(self)
    }

    fileprivate func emptyDataSetDidDisappear() {
        emptyDataSetDelegate?.emptyDataSetDidDisappear(self)
    }

    // MARK: - Helper
    fileprivate func emptyDataSetAvailable() -> Bool {
        if let _ = emptyDataSetDataSource {
            return isKind(of: UITableView.self) || isKind(of: UICollectionView.self) || isKind(of: UIScrollView.self)
        }
        return false
    }

    fileprivate func cellsCount() -> Int {
        var count = 0
        if let tableView = self as? UITableView {
            if let dataSource = tableView.dataSource {
                if dataSource.responds(to: TableViewSelectors.numberOfSections) {
                    let sections = dataSource.numberOfSections!(in: tableView)
                    for section in 0..<sections {
                        count += dataSource.tableView(tableView, numberOfRowsInSection: section)
                    }
                }
            }
        } else if let collectionView = self as? UICollectionView {
            if let dataSource = collectionView.dataSource {
                if dataSource.responds(to: CollectionViewSelectors.numberOfSections) {
                    let sections = dataSource.numberOfSections!(in: collectionView)
                    for section in 0..<sections {
                        count += dataSource.collectionView(collectionView, numberOfItemsInSection: section)
                    }
                }
            }
        }

        return count
    }

    fileprivate func handlingInvalidEmptyDataSet() {
        emptyDataSetWillDisappear()

        emptyDataView.resetEmptyDataView()
        emptyDataView.removeFromSuperview()
        setEmptyDataView(nil)
        isScrollEnabled = true

        emptyDataSetDidDisappear()
    }

    // MARK: - UIGestureRecognizer delegate
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view?.isEqual(EmptyDataView) == true {
            return emptyDataSetTapEnabled()
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isEqual(emptyDataView.tapGesture) || otherGestureRecognizer.isEqual(emptyDataView.tapGesture) {
            return true
        }

        return false
    }

    // MARK: - Reload
    // swiftlint:disable function_body_length
    fileprivate func reloadEmptyDataSet() {
        if !emptyDataSetAvailable() {
            return
        }

        if !emptyDataSetShouldDisplay() || cellsCount() > 0 {
            if emptyDataViewVisible {
                handlingInvalidEmptyDataSet()
            }
            return
        }

        emptyDataSetWillAppear()

        if emptyDataView.superview == nil {
            if (self is UITableView || self is UICollectionView) && subviews.count > 1 {
                insertSubview(emptyDataView, at: 0)
            } else {
                addSubview(emptyDataView)
            }
        }
        emptyDataView.resetEmptyDataView()

        emptyDataView!.verticalOffset = emptyDataSetVerticalOffset()
        emptyDataView!.verticalSpaces = emptyDataSetVerticalSpaces()

        if let customView = emptyDataSetCustomView() {
            emptyDataView.customView = customView
        } else {
            if let image = emptyDataSetImage() {
                if let imageTintColor = emptyDataSetImageTintColor() {
                    emptyDataView!.imageView.image = image.withRenderingMode(.alwaysTemplate)
                    emptyDataView!.imageView.tintColor = imageTintColor
                } else {
                    emptyDataView!.imageView.image = image.withRenderingMode(.alwaysOriginal)
                }
            }

            if let title = emptyDataSetTitle() {
                emptyDataView.titleLabel.attributedText = title
            }

            if let description = emptyDataSetDescription() {
                emptyDataView.descriptionLabel.attributedText = description
            }
        }

        emptyDataView.backgroundColor = emptyDataSetBackgroundColor()
        emptyDataView.isHidden = false
        emptyDataView.clipsToBounds = true
        emptyDataView.tapGesture.isEnabled = emptyDataSetTapEnabled()
        isScrollEnabled = emptyDataSetScrollEnabled()

        emptyDataView.setConstraints()
        emptyDataView.layoutIfNeeded()

        emptyDataSetDidAppear()
    }

    // MARK: - Method swizzling
    fileprivate class func tb_swizzleMethod(_ originalSelector: Selector, swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

        let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }

    fileprivate class func tb_swizzleTableViewReloadData() {
        struct EmptyDataSetSwizzleToken {
            static var onceToken: Int = 0
        }
        dispatch_once(&EmptyDataSetSwizzleToken.onceToken) {
            let originalSelector = TableViewSelectors.reloadData
            let swizzledSelector = Selectors.tableViewSwizzledReloadData

            tb_swizzleMethod(originalSelector, swizzledSelector: swizzledSelector)
            print(#function)
        }
    }

    fileprivate class func tb_swizzleTableViewEndUpdates() {
        struct EmptyDataSetSwizzleToken {
            static var onceToken: Int = 0
        }
        dispatch_once(&EmptyDataSetSwizzleToken.onceToken) {
            let originalSelector = TableViewSelectors.endUpdates
            let swizzledSelector = Selectors.tableViewSwizzledEndUpdates

            tb_swizzleMethod(originalSelector, swizzledSelector: swizzledSelector)
            print(#function)
        }
    }

    fileprivate class func tb_swizzleCollectionViewReloadData() {
        struct EmptyDataSetSwizzleToken {
            static var onceToken: Int = 0
        }
        dispatch_once(&EmptyDataSetSwizzleToken.onceToken) {
            let originalSelector = CollectionViewSelectors.reloadData
            let swizzledSelector = Selectors.collectionViewSwizzledReloadData

            tb_swizzleMethod(originalSelector, swizzledSelector: swizzledSelector)
            print(#function)
        }
    }

    fileprivate class func tb_swizzleCollectionViewPerformBatchUpdates() {
        struct EmptyDataSetSwizzleToken {
            static var onceToken: Int = 0
        }
        dispatch_once(&EmptyDataSetSwizzleToken.onceToken) {
            let originalSelector = CollectionViewSelectors.performBatchUpdates
            let swizzledSelector = Selectors.collectionViewSwizzledPerformBatchUpdates

            tb_swizzleMethod(originalSelector, swizzledSelector: swizzledSelector)
            print(#function)
        }
    }

    func tb_tableViewSwizzledReloadData() {
        tb_tableViewSwizzledReloadData()
        reloadEmptyDataSet()
    }

    func tb_tableViewSwizzledEndUpdates() {
        tb_tableViewSwizzledEndUpdates()
        reloadEmptyDataSet()
    }

    func tb_collectionViewSwizzledReloadData() {
        tb_collectionViewSwizzledReloadData()
        reloadEmptyDataSet()
    }

    func tb_collectionViewSwizzledPerformBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?) {
        tb_collectionViewSwizzledPerformBatchUpdates(updates) { [weak self](completed) in
            completion?(completed)
            self?.reloadEmptyDataSet()
        }
    }
}
