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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.inputTextView.font = NSFont(name: "HelveticaNeue", size: 16)
        self.outputTextView.font = NSFont(name: "HelveticaNeue", size: 16)
        
        self.inputScrollView.syncWithScrollView(self.outputScrollView)
        self.outputScrollView.syncWithScrollView(self.inputScrollView)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func shell(launchPath: String, arguments: [String]) -> String
    {
        let task = NSTask()
        task.launchPath = launchPath
        task.arguments = arguments
        
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: NSUTF8StringEncoding)!
        if output.characters.count > 0 {
            return output.substringToIndex(output.endIndex.advancedBy(-1))
            
        }
        return output
    }
    
    func bash(command: String, arguments: [String]) -> String {
        let whichPathForCommand = shell("/bin/bash", arguments: [ "-l", "-c", "which \(command)" ])
        return shell(whichPathForCommand, arguments: arguments)
    }
    
    @IBAction func analysisButtonClick(sender: AnyObject) {
        // 符号表路径
        let symbolPath = self.symbolPathField.stringValue
        if(symbolPath.isEmpty){
            return
        }
        let fileUrl = NSURL(fileURLWithPath: symbolPath)
        
        // App名
        let appName = fileUrl.lastPathComponent?.substringToIndex((fileUrl.lastPathComponent?.rangeOfString(".")?.startIndex)!)
        
        if(appName == nil){
            return
        }

        // 崩溃日志
        let log:NSMutableString = NSMutableString(string: inputTextView.string ?? "")
        
        // 查找App字段，格式 appName 0x12341238 0x12312 + 124213123
        do{
            let symbolReg = try NSRegularExpression(pattern: appName! + "\\s*(0x[0-9|a-z|A-Z]*)\\s*(0x[0-9|a-z|A-Z]*)\\s*\\+\\s*(\\d*)", options: .CaseInsensitive)
            
            while(true){
                if let result = symbolReg.firstMatchInString(log as String, options: .WithoutAnchoringBounds, range: NSMakeRange(0, log.length)) {
                    if(result.numberOfRanges != 4){
                        break
                    }
                    // 解析地址
                    let addressStr:NSString = log.substringWithRange(result.rangeAtIndex(1))
                    let baseStr:NSString = log.substringWithRange(result.rangeAtIndex(2))
                    // 判断cup类型
                    var cpuStr = "armv7"
                    if(addressStr.length == 18){
                        cpuStr = "arm64"
                    }
                    // 解析
                    let output = bash("xcrun", arguments: ["atos","-arch",cpuStr,"-o",symbolPath+"/Contents/Resources/DWARF/"+appName!,"-l",baseStr as String,addressStr as String])
                    
                    log.replaceCharactersInRange(result.range, withString: output)
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

