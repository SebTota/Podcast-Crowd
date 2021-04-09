//
//  ViewController.swift
//  Podcast-Player
//
//  Created by Sebastian Tota on 4/9/21.
//

import UIKit
import AVFoundation
import FeedKit

class ViewController: UIViewController {
    
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    @IBOutlet weak var podcastImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let feedURL = URL(string: "https://feeds.megaphone.fm/stufftheydontwantyoutoknow")
        
        let parser = FeedParser(URL: feedURL!)
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            DispatchQueue.main.async {
                switch result {
                    case .success(let feed):
                        let photoURL = URL(string: feed.rssFeed!.image!.url!)!
                        self.downloadImage(from: photoURL)
                        
//                        if let feed = feed.rssFeed {
//                            print(feed.items)
//
//                            if let items = feed.items {
//                                for item in items {
//                                    if let enclosure = item.enclosure {
//                                        print(enclosure)
//                                        if let att = enclosure.attributes {
//                                            print(att)
//                                        }
//                                        if let url = enclosure.attributes?.url {
//                                            print(url)
//                                        }
//                                    }
//                                }
//                            }
//                        }
                        
                        if let first = feed.rssFeed?.items?.first {
                            if let url = first.enclosure?.attributes?.url {
                                print(url)
                                self.downloadAudio2(url: URL(string: url))
                            }
                        }
                        
                    
                        
                        //print(item!.title!)
                        //print(item!.link!)
                        //self.downloadAudio(from: URL(string: item!.link!)!)
                        
                        print(feed.rssFeed!.title!)
                        
                    case .failure(let error):
                        print(error)
                    }
            }
        }
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
                self.podcastImage.image = UIImage(data: data)
            }
        }
    }
    
    func downloadAudio(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print("Download finished")
            DispatchQueue.main.async {
                
                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("podcastTestFile")
                try? data.write(to: path)
                
                do  {
                
                    let audio = try Bundle.main.path(forResource: String(contentsOf: path), ofType: "mp3")
                    self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audio!))
                    // self.audioPlayer = try AVAudioPlayer(data: data)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [AVAudioSession.CategoryOptions.mixWithOthers])
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func downloadAudio2(url: URL?) {
        if let audioUrl = url {

            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)

            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                
                
                do  {
                    //let audio = try Bundle.main.path(forResource: String(contentsOf: destinationUrl), ofType: "mp3")
                    self.audioPlayer = try AVAudioPlayer(contentsOf: destinationUrl)
                    // self.audioPlayer = try AVAudioPlayer(data: data)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [AVAudioSession.CategoryOptions.mixWithOthers])
                } catch {
                    print(error)
                }

            } else {

                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl) { location, response, error in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                        
                        do  {
                            //let audio = try Bundle.main.path(forResource: String(contentsOf: destinationUrl), ofType: "mp3")
                            self.audioPlayer = try AVAudioPlayer(contentsOf: destinationUrl)
                            // self.audioPlayer = try AVAudioPlayer(data: data)
                            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [AVAudioSession.CategoryOptions.mixWithOthers])
                        } catch {
                            print(error)
                        }
                        
                    } catch {
                        print(error)
                    }
                }.resume()
            }
            
            
            
            
        }

    }


    @IBAction func playButtonPressed(_ sender: UIButton) {
        audioPlayer.play()
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        audioPlayer.pause()
    }
}

