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
                        
                        print(feed.rssFeed!.title)
                        
                    case .failure(let error):
                        print(error)
                    }
            }
        }
        
        let audio = Bundle.main.path(forResource: "podcast", ofType: "mp3")
        
        do  {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audio!))
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [AVAudioSession.CategoryOptions.mixWithOthers])
        } catch {
            print(error)
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

