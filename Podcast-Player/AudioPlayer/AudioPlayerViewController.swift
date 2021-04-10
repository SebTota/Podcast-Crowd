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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    var episode: Episode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = episode.getTitle()
        loadingActivityIndicatorView.startAnimating()
        loadAudio()
        loadPhoto()
    }
    
    private func disablePlayerButtons() {
        playButton.isEnabled = false
        pauseButton.isEnabled = false
    }
    
    private func enablePlayerButton() {
        playButton.isEnabled = true
        pauseButton.isEnabled = true
    }
    
    private func loadAudio() {
        episode.getEpisode { (audioPlayer: AVAudioPlayer?) in
            if let audioPlayer = audioPlayer {
                self.audioPlayer = audioPlayer
                DispatchQueue.main.async {
                    do  {
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [AVAudioSession.CategoryOptions.mixWithOthers])
                        self.loadingActivityIndicatorView.isHidden = true
                        self.enablePlayerButton()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    private func loadPhoto() {
        episode.getImage { (image: UIImage) in
            DispatchQueue.main.async {
                self.podcastImageView.image = image
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
