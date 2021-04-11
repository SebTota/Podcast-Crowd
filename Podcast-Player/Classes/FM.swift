//
//  LocalAndRemoteFileManager.swift
//  Podcast-Player
//
//  Created by Seb Tota on 4/10/21.
//

import Foundation
import UIKit

class LocalAndRemoteFileManager {
    
    /*
     * Check if a file exists in local file storage
     * @param    String     Local path to file
     * @return   Bool       true: file exists in local storage, false: else
     */
    static func checkIfFileExistsInLocalStorage(atPath: String) -> Bool {
        if FileManager.default.fileExists(atPath: atPath) {
            return true
        } else {
            return false
        }
    }
    
    /*
     * Get an image from local file storage
     * @param   String      Path of the image
     * @return  UIImage?    Optional UIImage read from path
     */
    static func getUIImageFromLocalStorage(atPath: String) -> UIImage? {
        return UIImage(contentsOfFile: atPath)
    }
    
    /*
     * Download a file to local storage
     * @param   URL         Path of where the file should be saved locally
     * @param   URL         Remote URL of the file to be downloaded
     * @param   Callback    Callback, passing a bool indicating success or failure of download/save
     */
    static func downloadFileToLocalStorage(toPath: URL, url: URL, callback: @escaping (Bool) -> ()) {
        URLSession.shared.downloadTask(with: url) { location, response, error in
            guard let location = location, error == nil else { return }
            do {
                try FileManager.default.moveItem(at: location, to: toPath)
                print("Downloaded file to local storage")
                callback(true)
            } catch {
                print("Error downloading file")
                print(error)
                callback(false)
            }
        }.resume()
    }
    
}
