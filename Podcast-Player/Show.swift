//
//  Show.swift
//  Podcast-Player
//
//  Created by Sebastian Tota on 4/9/21.
//

import Foundation

class Show {
    
    private var title: String
    private var description: String
    private var episodes: [Episode] = []
    
    init(title: String, description: String, episodes: [Episode]?) {
        self.title = title
        self.description = description
        
        if let episodes = episodes {
            self.episodes = episodes
        }
    }
    
}
