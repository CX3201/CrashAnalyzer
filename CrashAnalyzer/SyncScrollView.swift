//
//  SyncScrollView.swift
//  CrashAnalyzer
//
//  Created by abelchen on 16/5/20.
//  Copyright © 2016年 abelchen. All rights reserved.
//

import Cocoa

public class SyncScrollView : NSScrollView {
    
    var syncScrollView: NSScrollView?
    
    
    public func syncWithScrollView(scrollView: NSScrollView) {
        removeSyncNotification()
        let contentView = scrollView.contentView
        contentView.postsBoundsChangedNotifications = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SyncScrollView.boundsChanged(_:)), name: NSViewBoundsDidChangeNotification, object: contentView)
    }
    
    func removeSyncNotification() {
        if(syncScrollView != nil) {
            let contentView = syncScrollView!.contentView
            NSNotificationCenter.defaultCenter().removeObserver(self, name:NSViewBoundsDidChangeNotification, object: contentView)
            syncScrollView = nil;
        }
    }
    
    func boundsChanged(notification: NSNotification) {
        let contentView = notification.object as! NSClipView
        let changedOrigin = contentView.documentVisibleRect.origin
        var point = contentView.bounds.origin
        point.y = changedOrigin.y
        self.contentView.scrollToPoint(point)
        reflectScrolledClipView(self.contentView)
    }
}