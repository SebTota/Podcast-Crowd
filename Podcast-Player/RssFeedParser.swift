//
//  FeedParser.swift
//  Podcast-Player
//
//  Created by Sebastian Tota on 4/10/21.
//

import UIKit
import AVFoundation
import FeedKit

class RssFeedParser {
    
    var url: URL
    var rssFeed: RSSFeed?
    var show: Show?
    
    init(url: URL) {
        self.url = url
    }
    
    func parseFeed(callback: @escaping (Show?) -> ()) {
        let parser = FeedParser(URL: self.url)
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            
            switch result {
                case .success(let feed):
                    self.rssFeed = feed.rssFeed
                    self.parseShow()
                    self.parseEpisodes()
                case .failure(let error):
                    print(error)
            }
            DispatchQueue.main.async {
                print("Returning show from parsing")
                callback(self.show)
            }
         }
    }
    
    private func parseShow() {
        if let rssFeed = self.rssFeed {
            if let t = rssFeed.title, let d = rssFeed.description, let imageUrl = rssFeed.image?.url {
                self.show = Show(title: t, description: d, imageUrl: URL(string: imageUrl))
            }
        }
    }
    
    private func parseEpisodes() {
        if let rssFeed = self.rssFeed, let show = self.show {
            if let items = rssFeed.items {
                
                var episodes: [Episode] = []
                
                for item in items {
                    if let t = item.title, let d = item.description, let audioUrl = item.enclosure?.attributes?.url! {
                        episodes.append(Episode(title: t, audioUrl: URL(string: audioUrl)!, description: d, showTitle: show.getTitle()))
                    }
                }
                
                show.setEpisodes(episodes: episodes)
            }
        }
    }
    
}

