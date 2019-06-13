//
//  ViewController.swift
//  CrashAnalyzer
//
//  Created by abelchen on 16/5/20.
//  Copyright © 2016年 abelchen. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var symbolPathField: NSTextField!
    @IBOutlet var inputTextView: DragFileTextView!
    @IBOutlet var outputTextView: DragFileTextView!
    @IBOutlet weak var inputScrollView: SyncScrollView!
    @IBOutlet weak var outputScrollView: SyncScrollView!
    @IBOutlet weak var use64Bits: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.inputTextView.font = NSFont(name: "HelveticaNeue", size: 16)
        self.outputTextView.font = NSFont(name: "HelveticaNeue", size: 16)
        
        self.inputScrollView.syncWithScrollView(self.outputScrollView)
        self.outputScrollView.syncWithScrollView(self.inputScrollView)
    }
    
    @IBAction func analysisButtonClick(_ sender: AnyObject) {
        // 符号表路径
        let symbolPath = self.symbolPathField.stringValue
        if(symbolPath.isEmpty){
            return
        }
        let fileUrl = NSURL(fileURLWithPath: symbolPath)
        
        // App名
        let appName = fileUrl.lastPathComponent?.prefix(upTo: (fileUrl.lastPathComponent?.range(of: ".")?.lowerBound)!)
        
        if(appName == nil){
            return
        }

        // 崩溃日志
        let log:NSMutableString = NSMutableString(string: inputTextView.string)
        
        // 查找App字段，格式 appName 0x12341238 0x12312 + 124213123
        do{
            let symbolReg = try NSRegularExpression(pattern: appName! + "\\s+(\\S+)\\s+(\\S+)\\s+\\+\\s+(\\S+)", options: .caseInsensitive)
            
            while(true){
                if let result = symbolReg.firstMatch(in: log as String, options: .withoutAnchoringBounds, range: NSMakeRange(0, log.length)) {
                    if(result.numberOfRanges != 4){
                        break
                    }
                    // 解析地址
                    let addressStr:NSString = log.substring(with: result.range(at: 1)) as NSString
                    var baseStr:NSString = log.substring(with: result.range(at: 2)) as NSString
                    let offsetStr:NSString = log.substring(with: result.range(at: 3)) as NSString
                    // 判断cup类型
                    var cpuStr = "armv7"
                    if(use64Bits.state == NSControl.StateValue(1)){
                        cpuStr = "arm64"
                    }
                    // 基址需要计算
                    if(baseStr.isEqual(to: appName!)){
                        var address:UInt64 = 0
                        var offset:UInt64 = 0
                        Scanner(string: addressStr as String).scanHexInt64(&address)
                        Scanner(string: offsetStr as String).scanUnsignedLongLong(&offset)
                        let base:UInt64 = address - offset
                        baseStr = NSString(format: "0x%qx", base)
                    }
                    // 解析
                    let output = bash(command: "xcrun", arguments: ["atos","-arch",cpuStr,"-o",symbolPath+"/Contents/Resources/DWARF/"+appName!,"-l",baseStr as String,addressStr as String])
                    
                    log.replaceCharacters(in: result.range, with: output)
                }else{
                    break
                }
            }
        }catch{
            return
        }
        
        outputTextView.string = log as String
    }
}

