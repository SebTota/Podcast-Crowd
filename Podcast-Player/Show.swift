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
    private var imageUrl: URL?
    private var description: String
    private var episodes: [Episode] = []
    
    init(title: String, description: String, imageUrl: URL?) {
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
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                // self.podcastImage.image = UIImage(data: data)
            }
        }
    }
    
    func setEpisodes(episodes: [Episode]) {
        self.episodes = episodes
    }
}
