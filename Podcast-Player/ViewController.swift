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
                            
                            if let url = first.enclosure?.attributes?.url, let description = first.description, let title = first.title {
                                
                                let episode = Episode(title: title, audioUrl: URL(string: url)!, description: description, showTitle: "test")
                                episode.getEpisode { (audioPlayer: AVAudioPlayer?) in
                                    DispatchQueue.main.async() {
                                        if let audioPlayer = audioPlayer {
                                            self.audioPlayer = audioPlayer
                                            print("Ready to play audio")
                                            do {
                                                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [AVAudioSession.CategoryOptions.mixWithOthers])
                                            } catch {
                                                print(error)
                                            }
                                        } else {
                                            print("Error downloading file")
                                        }
                                    }
                                }
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


    @IBAction func playButtonPressed(_ sender: UIButton) {
        audioPlayer.play()
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        audioPlayer.pause()
    }
}

