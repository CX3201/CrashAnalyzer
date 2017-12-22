//
//  File.swift
//  CrashAnalyzer
//
//  Created by abelchen on 2017/12/22.
//  Copyright © 2017年 abelchen. All rights reserved.
//

import Foundation

func shell(launchPath: String, arguments: [String]) -> String
{
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    var output = String(data: data, encoding: String.Encoding.utf8)!
    if output.count > 0 {
        output.removeLast()
    }
    return output
}

func bash(command: String, arguments: [String]) -> String {
    let whichPathForCommand = shell(launchPath: "/bin/bash", arguments: [ "-l", "-c", "which \(command)" ])
    return shell(launchPath: whichPathForCommand, arguments: arguments)
}
