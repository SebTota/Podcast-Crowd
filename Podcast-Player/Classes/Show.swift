//
//  Show.swift
//  Podcast-Player
//
//  Created by Sebastian Tota on 4/9/21.
//

import Foundation
import UIKit

class Show {
    
    private var title: String
    private var imageUrl: URL
    private var description: String
    private var episodes: [Episode] = []
    
    init(title: String, description: String, imageUrl: URL) {
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
    }
    
    func getTitle() -> String {
        return self.title
    }
    
    func getDescription() -> String {
        return self.description
    }
    
    func getNumEpisodes() -> Int {
        return self.episodes.count
    }
    
    func getEpisode(index: Int) -> Episode {
        return self.episodes[index]
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func getImage(callback: @escaping (UIImage) -> ()) {
        print("Download Started")
        getData(from: self.imageUrl) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? self.imageUrl.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                callback(UIImage(data: data)!)
            }
        }
    }
    
    func setEpisodes(episodes: [Episode]) {
        self.episodes = episodes
    }
}
