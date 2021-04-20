//
//  Episode.swift
//  Podcast-Player
//
//  Created by Sebastian Tota on 4/9/21.
//

import Foundation
import AVFoundation
import UIKit
import Firebase

class Episode {
    
    private var title: String
    private var audioUrl: URL
    private var photoUrl: URL
    private var audioPath: URL
    private var photoPath: URL
    private var showId: String
    private var description: String
    
    private var db: DocumentReference
    
    init(title: String, audioUrl: URL, photoUrl: URL, description: String, showId: String) {
        self.title = title
        self.description = description
        self.photoUrl = photoUrl
        self.audioUrl = audioUrl
        self.showId = showId
        
        self.db = Firestore.firestore().collection("podcasts").document(showId).collection("episodes").document(audioUrl.lastPathComponent)
        
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let baseDir = documentsDirectoryURL.appendingPathComponent(showId)
        self.audioPath = baseDir.appendingPathComponent(audioUrl.lastPathComponent)
        self.photoPath = baseDir.appendingPathComponent(photoUrl.lastPathComponent)
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
        autoreleasepool {
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
    }
    
    /*
     * Retrieve the image for this episode
     */
    func getImage(callback: @escaping (UIImage) -> ()) {
        autoreleasepool {
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
    
    /*
     * Add a new ad interval
     */
    func addAdInterval(start: Int, end: Int) {
        let addObj: [String: Int] = ["start": start, "end":end]
        db.updateData(["ads": FieldValue.arrayUnion([addObj])]) { (error: Error?) in
            if let e = error {
                print("Error adding new ad interval to database")
                print(e)
            } else {
                print("Added ad interval to database")
            }
        }
    }
    
    /*
     * Get all ad intervals for this episode
     */
    func getAdIntervals(callback: @escaping ([[Int]]) -> ()) {
        db.getDocument { (document: DocumentSnapshot?, error: Error?) in
            if let e = error {
                print("Error retreiving ad intervals for episode")
                print(e)
                callback([])
            } else {
                if let document = document, document.exists, let dbArr = document.get("ads") as? [[String: Int]] {
                    var adIntervals: [[Int]] = []
                    for adInterval in dbArr {
                        if let s = adInterval["start"], let e = adInterval["end"] {
                            adIntervals.append([s, e])
                        }
                    }
                    adIntervals.sort { ($0[0] as Int) < ($1[0] as Int) }
                    callback(adIntervals)
                } else {
                    print("Document does not exist")
                    callback([])
                }
            }
        }
    }
}
