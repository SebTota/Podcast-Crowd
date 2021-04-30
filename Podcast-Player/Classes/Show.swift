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
    private var showUrl: URL
    private var showId: String
    private var photoUrl: URL
    private var photoPath: URL
    private var description: String
    private var episodes: [Episode] = []
    
    var getImageSemaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    init(title: String, showUrl: URL, description: String, imageUrl: URL, showId: String) {
        self.title = title
        self.showUrl = showUrl
        self.description = description
        self.photoUrl = imageUrl
        self.showId = showId
        
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let baseDir = documentsDirectoryURL.appendingPathComponent(showId)
        self.photoPath = baseDir.appendingPathComponent(photoUrl.lastPathComponent)
        self.getImage { (image: UIImage) in }
    }
    
    func getShowUrl() -> URL {
        return showUrl
    }
    
    func getShowId() -> String {
        return showId
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
    
    /*
     * Retrieve the image for this episode
     */
    func getImage(callback: @escaping (UIImage) -> ()) {
        getImageSemaphore.wait()
        if LocalAndRemoteFileManager.checkIfFileExistsInLocalStorage(atPath: self.photoPath.path) {
            self.getImageSemaphore.signal()
            callback(LocalAndRemoteFileManager.getUIImageFromLocalStorage(atPath: self.photoPath.path)!)
        } else {
            LocalAndRemoteFileManager.downloadFileToLocalStorage(toPath: self.photoPath, url: self.photoUrl) { (success: Bool) in
                self.getImageSemaphore.signal()
                if success == true {
                    print("Downloaded epsiode image to local storage")
                    callback(LocalAndRemoteFileManager.getUIImageFromLocalStorage(atPath: self.photoPath.path)!)
                } else {
                    print("Couldn't download episode image to local storage")
                    callback(UIImage())
                }
            }
        }
    }
    
    func setEpisodes(episodes: [Episode]) {
        self.episodes = episodes
    }
}
