//
//  Episode.swift
//  Podcast-Player
//
//  Created by Sebastian Tota on 4/9/21.
//

import Foundation
import AVFoundation
import UIKit

class Episode {
    
    private var title: String
    private var audioUrl: URL
    private var photoUrl: URL
    
    private var audioPath: URL
    private var photoPath: URL
    
    private var description: String
    
    init(title: String, audioUrl: URL, photoUrl: URL, description: String, showTitle: String) {
        self.title = title
        self.description = description
        self.photoUrl = photoUrl
        self.audioUrl = audioUrl
        
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.audioPath = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
        self.photoPath = documentsDirectoryURL.appendingPathComponent(photoUrl.lastPathComponent)
    }
    
    func getTitle() -> String {
        return self.title
    }
    
    func getDescription() -> String {
        return self.description
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
        if LocalAndRemoteFileManager.checkIfFileExistsInLocalStorage(atPath: self.audioPath.path) == true {
            callback(self.getEpisodeFromLocalStorage())
        } else {
            LocalAndRemoteFileManager.downloadFileToLocalStorage(toPath: self.audioPath, url: self.audioUrl) { (success: Bool) in
                if success == true {
                    callback(self.getEpisodeFromLocalStorage())
                } else {
                    callback(nil)
                }
            }
        }
    }
    
    func getImage(callback: @escaping (UIImage) -> ()) {
        if LocalAndRemoteFileManager.checkIfFileExistsInLocalStorage(atPath: self.photoPath.path) {
            callback(LocalAndRemoteFileManager.getUIImageFromLocalStorage(atPath: self.photoPath.path)!)
        } else {
            LocalAndRemoteFileManager.downloadFileToLocalStorage(toPath: self.photoPath, url: self.photoUrl) { (success: Bool) in
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
}
