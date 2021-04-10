//
//  ViewController.swift
//  Podcast-Player
//
//  Created by Sebastian Tota on 4/10/21.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    @IBOutlet weak var showsTableView: UITableView!
    
    let showsTableViewCellName: String = "ShowsTableViewCell"
    let showsTableViewCellReusableIdentifier: String = "ShowsTableViewCell"

    var showRssFeeds = ["https://feeds.megaphone.fm/stufftheydontwantyoutoknow"]
    var shows: [Show] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initShowsTableView()
    }
    
    private func initShowsTableView() {
        showsTableView.rowHeight = 80.0
        showsTableView.delegate = self
        showsTableView.dataSource = self
    }
    
    private func createShows() {
    }
    
    
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
                 case .failure(let error):
                     print(error)
                 }
         }
     }
    
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = showsTableView.dequeueReusableCell(withIdentifier: showsTableViewCellReusableIdentifier, for: indexPath) as! ShowsTableViewCell
        

        //let show = shows[indexPath.item]
        // row.titleLabel.text = show.getTitle()

        row.title.text = ""
        
        return row
    }
}
