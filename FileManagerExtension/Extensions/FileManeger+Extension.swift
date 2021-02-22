//
//  FileManeger+Extension.swift
//  FileManagerExtension
//
//  Created by 郑红 on 2021/1/28.
//  Copyright © 2021 com.zhenghong. All rights reserved.
//

import UIKit

protocol FileManagerKey {
}

protocol FileManagerDecoder {
    func decode<T>(data: Data) -> T
}

protocol FileManagerEncoder {
    func encode<T>(model: T) -> Data
}



extension FileManager {
    struct Path {
        var location: String
    }
    
    enum Directory: String {
        case Library
        case Caches = "Library/Caches"
        case Temp = "tmp"
        case Documents
    }
    
     func path(directory: Directory, path: String...) -> Path? {
        let pathStr = path.reduce("") { (result, str) -> String in
            let traim = str.trimmingCharacters(in: .whitespacesAndNewlines)
            if traim.isEmpty {
                return result
            }
            return "\(result)/\(traim)"
        }
        if pathStr.isEmpty {
            return nil
        }
        let home = NSHomeDirectory()
        let location = home.appending("/\(directory.rawValue)\(pathStr)")
        if !fileExists(atPath: location) {
            try? createDirectory(atPath: location, withIntermediateDirectories: true, attributes: nil)
        }
        return Path(location: location)
    }
}

extension FileManager.Path {
    var data: Data? {
        let url = URL(fileURLWithPath: location)
        if let data = try? Data(contentsOf: url) {
            return data
        }
        return nil
    }
    
    var image: UIImage? {
        return UIImage(contentsOfFile: location)
    }
    
    var string: String {
        guard let data = self.data else {
            return ""
        }
        
        
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func decode<T: Codable>(type: T.Type) -> T? {
        guard let data = data else {
            return nil
        }
        let code = JSONDecoder()
        return try? code.decode(type, from: data)
    }
    
}
