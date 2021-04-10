//
//  Episode.swift
//  Podcast-Player
//
//  Created by Sebastian Tota on 4/9/21.
//

import Foundation
import AVFoundation

class Episode {
    
    private var title: String
    private var audioUrl: URL
    private var audioPath: URL
    private var description: String
    
    init(title: String, audioUrl: URL, description: String, showTitle: String) {
        self.title = title
        self.description = description
        self.audioUrl = audioUrl
        
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // self.audioPath = documentsDirectoryURL.appendingPathComponent(showTitle)
        self.audioPath = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
    }
    
    func getTitle() -> String {
        return self.title
    }
    
    func getDescription() -> String {
        return self.description
    }
    
    /*
     * Download the audio file for this episode to local storage
     */
    private func downloadEpisode(callback: @escaping (Bool) -> ()) {
        URLSession.shared.downloadTask(with: self.audioUrl) { location, response, error in
            guard let location = location, error == nil else { return }
            do {
                print("Downloaded episode to local storage")
                try FileManager.default.moveItem(at: location, to: self.audioPath)
                callback(true)
            } catch {
                print("Error downloading episode")
                print(error)
                callback(false)
            }
        }.resume()
    }
    
    /*
     * Check if the audio file for this episode exists in local storage
     * @param   Bool    true: file exists in local storage, false: file doesn't exist in local storage
     */
    private func checkIfEpisodeExists() -> Bool {
        if FileManager.default.fileExists(atPath: audioPath.path) {
            return true
        } else {
            return false
        }
    }
    
    /*
     * Read the audio file for this episode from local storage
     */
    private func getEpisodeFromLocalStorage() -> AVAudioPlayer? {
        do {
            let audioPlayer: AVAudioPlayer = try AVAudioPlayer(contentsOf: audioPath)
            return audioPlayer
        } catch {
            return nil
        }
    }
    
    /*
     * Retrieve the audio for this episode
     */
    func getEpisode(callback: @escaping (AVAudioPlayer?) -> ()) {
        if checkIfEpisodeExists() == true {
            callback(self.getEpisodeFromLocalStorage())
        } else {
            downloadEpisode { (success: Bool) in
                if success == true {
                    callback(self.getEpisodeFromLocalStorage())
                } else {
                    callback(nil)
                }
            }
        }
    }
    
}
