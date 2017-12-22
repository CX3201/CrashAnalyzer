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
    
    
    public func syncWithScrollView(_ scrollView: NSScrollView) {
        removeSyncNotification()
        let contentView = scrollView.contentView
        contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(self, selector: #selector(SyncScrollView.boundsChanged(_:)), name: NSView.boundsDidChangeNotification, object: contentView)
    }
    
    func removeSyncNotification() {
        if(syncScrollView != nil) {
            let contentView = syncScrollView!.contentView
            NotificationCenter.default.removeObserver(self, name:NSView.boundsDidChangeNotification, object: contentView)
            syncScrollView = nil;
        }
    }
    
    @objc func boundsChanged(_ notification: NSNotification) {
        let contentView = notification.object as! NSClipView
        let changedOrigin = contentView.documentVisibleRect.origin
        var point = contentView.bounds.origin
        point.y = changedOrigin.y
        self.contentView.scroll(to: point)
        reflectScrolledClipView(self.contentView)
    }
}
