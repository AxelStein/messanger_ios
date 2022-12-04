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
    
    func load(url: URL, id: Int64, width: Int = -1, height: Int = -1, completion: @escaping (Int64, UIImage?) -> Void) {
        if let cached = cache.object(forKey: url as AnyObject) as? UIImage {
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
                self.cache.setObject(resized, forKey: url as AnyObject, cost: data.count)
                DispatchQueue.main.async {
                    completion(id, resized)
                }
            } else {
                self.cache.setObject(image, forKey: url as AnyObject, cost: data.count)
                DispatchQueue.main.async {
                    completion(id, image)
                }
            }
        }
        tasks[url] = task
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
