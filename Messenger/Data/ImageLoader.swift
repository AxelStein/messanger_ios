//
//  PhotoLoader.swift
//  Messenger
//
//  Created by Александр Шерий on 19.12.2022.
//

import Foundation
import UIKit

let imageLoader = ImageLoader()

class ImageLoader {
    private let cache = NSCache<AnyObject, AnyObject>()
    private var tasks = [URL: URLSessionDataTask]()
    
    func contains(url: URL, conversion: String = "") -> Bool {
        let key = url.path + conversion
        return cache.object(forKey: key as AnyObject) != nil
    }
    
    func load(url: URL, id: Int64, conversion: String = "", width: Int = -1, height: Int = -1, completion: @escaping (Int64, UIImage?) -> Void) {
        let key = url.path + conversion
        if let cached = cache.object(forKey: key as AnyObject) as? UIImage {
            tasks.removeValue(forKey: url)
            completion(id, cached)
            return
        }
        
        let token = getAuthToken()
        var request = URLRequest(url: url)
        if let token = token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, res, err in
            DispatchQueue.main.async {
                self.tasks.removeValue(forKey: url)
            }
            guard let data = data,
                  let image = UIImage(data: data),
                  err == nil else {
                DispatchQueue.main.async {
                    completion(id, nil)
                }
                return
            }
            
            if width > 0 && height > 0 {
                let resized = image.resized(to: CGSize(width: width, height: height))
                self.cache.setObject(resized, forKey: key as AnyObject, cost: data.count)
                DispatchQueue.main.async {
                    completion(id, resized)
                }
            } else {
                self.cache.setObject(image, forKey: key as AnyObject, cost: data.count)
                DispatchQueue.main.async {
                    completion(id, image)
                }
            }
        }
        tasks[url] = task
        if conversion == "tiny_placeholder" {
            task.priority = URLSessionDataTask.highPriority
        }
        task.resume()
    }
    
    func cancel(for url: URL) {
        if let task = tasks[url] {
            task.cancel()
            tasks.removeValue(forKey: url)
        }
    }
    
    private func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: DefaultsKeys.authToken)
    }
}
