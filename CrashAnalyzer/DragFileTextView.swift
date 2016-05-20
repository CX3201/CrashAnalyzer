//
//  DragFileTextView.swift
//  CrashAnalyzer
//
//  Created by abelchen on 16/5/20.
//  Copyright © 2016年 abelchen. All rights reserved.
//

import Cocoa

class DragFileTextView: NSTextView {
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        if let path = NSURL(fromPasteboard: sender.draggingPasteboard()) {
            do{
                let content = try NSString(contentsOfURL:path, encoding:NSUTF8StringEncoding)
                self.string = content as String
                return true
            }catch{
                return false
            }
        }
        return false
    }
}