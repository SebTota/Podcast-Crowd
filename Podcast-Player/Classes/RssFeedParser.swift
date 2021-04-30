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
    var imageUrl: URL?
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
                if let imageUrl = URL(string: imageUrl) {
                    self.imageUrl = imageUrl
                    self.show = Show(title: t, showUrl: url, description: d, imageUrl: imageUrl, showId: t.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)
                }
            }
        }
    }
    
    private func encodeString(str: String) -> String? {
        return str.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)?.replacingOccurrences(of: "%", with: "--|--")
    }
    
    private func parseEpisodes() {
        if let rssFeed = self.rssFeed, let show = self.show, let imageUrl = self.imageUrl {
            if let items = rssFeed.items {
                
                var episodes: [Episode] = []
                
                for item in items {
                    if let t = item.title, let d = item.description, let audioUrl = item.enclosure?.attributes?.url! {
                        episodes.append(Episode(title: t, audioUrl: URL(string: audioUrl)!, photoUrl: imageUrl, description: d, showId: show.getShowId()))
                    }
                }
                
                show.setEpisodes(episodes: episodes)
            }
        }
    }
    
}

