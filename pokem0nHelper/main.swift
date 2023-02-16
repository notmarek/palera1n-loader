//
//  main.swift
//  pokem0nHelper
//
//  Created by Lakhan Lothiyi on 12/11/2022.
//
// This code belongs to Amy While and is from https://github.com/elihwyma/Pogo/blob/main/PogoHelper/main.swift

import Foundation
import ArgumentParser
import SWCompression

struct Strap: ParsableCommand {
    @Option(name: .shortAndLong, help: "The path to the .tar file you want to strap with")
    var input: String?
    
    @Flag(name: .shortAndLong, help: "Remove the bootstrap")
    var remove: Bool = false
    
    @Flag(name: .shortAndLong, help: "Does trollstore uicache")
    var uicache: Bool = false

    mutating func run() throws {
        NSLog("[pokem0n helper] Spawned!")
        guard getuid() == 0 else { fatalError() }
        
        if uicache {
            uicacheTool()
        } else if let input = input {
            strapTool(input)
        }
    }
    
    
    func uicacheTool() {
        
    }
    
    func strapTool(_ input: String) {
        NSLog("[pokem0n helper] Attempting to install \(input)")
        let dest = "/"
        do {
            try autoreleasepool {
                let data = try Data(contentsOf: URL(fileURLWithPath: input))
                let container = try TarContainer.open(container: data)
                NSLog("[pokem0n helper] Opened Container")
                for entry in container {
                    do {
                        var path = entry.info.name
                        if path.first == "." {
                            path.removeFirst()
                        }
                        if path == "/" || path == "/var" {
                            continue
                        }
                        path = path.replacingOccurrences(of: "", with: dest)
                        switch entry.info.type {
                        case .symbolicLink:
                            var linkName = entry.info.linkName
                            if !linkName.contains("/") || linkName.contains("..") {
                                var tmp = path.split(separator: "/").map { String($0) }
                                tmp.removeLast()
                                tmp.append(linkName)
                                linkName = tmp.joined(separator: "/")
                                if linkName.first != "/" {
                                    linkName = "/" + linkName
                                }
                                linkName = linkName.replacingOccurrences(of: "", with: dest)
                            } else {
                                linkName = linkName.replacingOccurrences(of: "", with: dest)
                            }
                            NSLog("[pokem0n helper] \(entry.info.linkName) at \(linkName) to \(path)")
                            try FileManager.default.createSymbolicLink(atPath: path, withDestinationPath: linkName)
                        case .directory:
                            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
                        case .regular:
                            guard let data = entry.data else { continue }
                            try data.write(to: URL(fileURLWithPath: path))
                        default:
                            NSLog("[pokem0n helper] Unknown Action for \(entry.info.type)")
                        }
                        var attributes = [FileAttributeKey: Any]()
                        attributes[.posixPermissions] = entry.info.permissions?.rawValue
                        attributes[.ownerAccountName] = entry.info.ownerUserName
                        var ownerGroupName = entry.info.ownerGroupName
                        if ownerGroupName == "staff" && entry.info.ownerUserName == "root" {
                            ownerGroupName = "wheel"
                        }
                        attributes[.groupOwnerAccountName] = ownerGroupName
                        do {
                            try FileManager.default.setAttributes(attributes, ofItemAtPath: path)
                        } catch {
                            continue
                        }
                    } catch {
                        NSLog("[pokem0n helper] error \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            NSLog("[pokem0n helper] Failed with error \(error.localizedDescription)")
            return
        }
        NSLog("[pokem0n helper] Strapped to \(dest)")
        var attributes = [FileAttributeKey: Any]()
        attributes[.posixPermissions] = 0o755
        attributes[.ownerAccountName] = "mobile"
        attributes[.groupOwnerAccountName] = "mobile"
        do {
            try FileManager.default.setAttributes(attributes, ofItemAtPath: "/var/mobile")
        } catch {
            NSLog("[pokem0n helper] thats wild")
        }
    }
}

Strap.main()
