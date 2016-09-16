//
//  ProtocolExtensions.swift
//  TBEmptyDataSet
//
//  Created by Xin Hong on 15/11/19.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit

public extension TBEmptyDataSetDataSource {
    func imageForEmptyDataSet(_ scrollView: UIScrollView!) -> UIImage? {
        return nil
    }

    func titleForEmptyDataSet(_ scrollView: UIScrollView!) -> NSAttributedString? {
        return nil
    }

    func descriptionForEmptyDataSet(_ scrollView: UIScrollView!) -> NSAttributedString? {
        return nil
    }

    func imageTintColorForEmptyDataSet(_ scrollView: UIScrollView!) -> UIColor? {
        return nil
    }

    func backgroundColorForEmptyDataSet(_ scrollView: UIScrollView!) -> UIColor? {
        return nil
    }

    func verticalOffsetForEmptyDataSet(_ scrollView: UIScrollView!) -> CGFloat {
        return DefaultValues.verticalOffset
    }

    func verticalSpacesForEmptyDataSet(_ scrollView: UIScrollView!) -> [CGFloat] {
        return [DefaultValues.verticalSpace, DefaultValues.verticalSpace]
    }

    func customViewForEmptyDataSet(_ scrollView: UIScrollView!) -> UIView? {
        return nil
    }
}

public extension TBEmptyDataSetDelegate {
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return true
    }

    func emptyDataSetTapEnabled(_ scrollView: UIScrollView!) -> Bool {
        return true
    }

    func emptyDataSetScrollEnabled(_ scrollView: UIScrollView!) -> Bool {
        return false
    }

    func emptyDataSetDidTapView(_ scrollView: UIScrollView!) {

    }

    func emptyDataSetWillAppear(_ scrollView: UIScrollView!) {

    }

    func emptyDataSetDidAppear(_ scrollView: UIScrollView!) {

    }

    func emptyDataSetWillDisappear(_ scrollView: UIScrollView!) {

    }

    func emptyDataSetDidDisappear(_ scrollView: UIScrollView!) {

    }
}
