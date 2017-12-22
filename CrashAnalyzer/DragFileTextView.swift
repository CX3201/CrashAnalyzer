//
//  DragFileTextView.swift
//  CrashAnalyzer
//
//  Created by abelchen on 16/5/20.
//  Copyright © 2016年 abelchen. All rights reserved.
//

import Cocoa

class DragFileTextView: NSTextView {

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let path = NSURL(from: sender.draggingPasteboard()) {
            do{
                let content = try String(contentsOf:path.filePathURL!, encoding:String.Encoding.utf8)
                self.string = content
                return true
            }catch{
                return false
            }
        }
        return false
    }
}
