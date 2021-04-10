//
//  AudioPlayerViewController.swift
//  Podcast-Player
//
//  Created by Seb Tota on 4/10/21.
//

import UIKit
import AVFoundation

class AudioPlayerViewController: UIViewController {

    @IBOutlet weak var podcastImageView: UIImageView!
    
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    var episode: Episode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAudio()
    }
    
    private func loadAudio() {
        episode.getEpisode { (audioPlayer: AVAudioPlayer?) in
            if let audioPlayer = audioPlayer {
                self.audioPlayer = audioPlayer
                do  {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [AVAudioSession.CategoryOptions.mixWithOthers])
                } catch {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        audioPlayer.play()
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        audioPlayer.pause()
    }
    
}
