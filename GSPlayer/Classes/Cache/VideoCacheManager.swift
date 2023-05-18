//
//  VideoCacheManager.swift
//  GSPlayer
//
//  Created by Gesen on 2019/4/20.
//  Copyright © 2019 Gesen. All rights reserved.
//

import Foundation

private let directory = NSTemporaryDirectory().appendingPathComponent("GSPlayer")

public enum VideoCacheManager {
    
    public static var remainingCache:UInt64 = 1048576
    public static func cachedFilePath(for url: URL) -> String {
        return directory
            .appendingPathComponent(url.absoluteString.md5)
            .appendingPathExtension(url.pathExtension)!
    }
    
    public static func cachedConfiguration(for url: URL) throws -> VideoCacheConfiguration {
        return try VideoCacheConfiguration
            .configuration(for: cachedFilePath(for: url))
    }
    
    public static func calculateCachedSize() -> UInt {
        let fileManager = FileManager.default
        let resourceKeys: Set<URLResourceKey> = [.totalFileAllocatedSizeKey]
        
        let fileContents = (try? fileManager.contentsOfDirectory(at: URL(fileURLWithPath: directory), includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)) ?? []
        
        return fileContents.reduce(0) { size, fileContent in
            guard
                let resourceValues = try? fileContent.resourceValues(forKeys: resourceKeys),
                resourceValues.isDirectory != true,
                let fileSize = resourceValues.totalFileAllocatedSize
                else { return size }
            
            return size + UInt(fileSize)
        }
    }
    
    public static func getAvailableDiskSpace() -> UInt64? {
        do {
            let fileURL = URL(fileURLWithPath: directory)
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: fileURL.path)
            if let freeSize = attributes[.systemFreeSize] as? NSNumber {
                return freeSize.uint64Value
            }
        } catch {
            print("Error: \(error)")
        }
        
        return nil
    }
    
//    @available(iOS 11.0, *)
//    public static func calculateRemainingCachedSize() -> UInt {
//        if remainingCache < 1024
//        {
//            return remainingCache
//        }
//        let fileManager = FileManager.default
//        let resourceKeys: Set<URLResourceKey> = [.volumeAvailableCapacityForImportantUsageKey]
//
//        let fileContents = (try? fileManager.contentsOfDirectory(at: URL(fileURLWithPath: directory), includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)) ?? []
//        guard let firstContent = fileContents.first else {
//            remainingCache = 0
//            return remainingCache}
////        let fileContentsFirst = [firstContent]
//        return fileContents.lazy.reduce(0) { size, fileContent in
////            guard
////                let resourceValues = try? fileContent.resourceValues(forKeys: resourceKeys),
////                resourceValues.isDirectory != true,
////                let fileSize = resourceValues.volumeAvailableCapacityForImportantUsage
////                else {
////                remainingCache = size
////                return size }
//            return size
//        }
//    }
    
    public static func cleanAllCache() throws {
        let fileManager = FileManager.default
        let fileContents = try fileManager.contentsOfDirectory(atPath: directory)
        
        for fileContent in fileContents {
            let filePath = directory.appendingPathComponent(fileContent)
            try fileManager.removeItem(atPath: filePath)
        }
    }
    
}
