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
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var progressUISlider: UISlider!
    
    var timer: Timer?
    var audioPlayer: AVAudioPlayer?
    var episode: Episode!
    var isPlayingBeforeChange: Bool = false
    var isPlaying: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = episode.getTitle()
        loadingActivityIndicatorView.startAnimating()
        loadAudio()
        loadPhoto()
        setProgressViewTimer()
    }
    
    /*
     * Enable the play/pause button
     */
    private func enablePlayerButton() {
        playButton.isEnabled = true
        if let audioPlayer = self.audioPlayer {
            progressUISlider.maximumValue = Float(audioPlayer.duration)
        }
    }
    
    /*
     * Load in the audio file for the chosen episode
     */
    private func loadAudio() {
        episode.getEpisode { (audioPlayer: AVAudioPlayer?) in
            if let audioPlayer = audioPlayer {
                self.audioPlayer = audioPlayer
                DispatchQueue.main.async {
                    do  {
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [])
                        self.loadingActivityIndicatorView.isHidden = true
                        self.enablePlayerButton()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    /*
     * Load in the photo for the chosen epsiode
     */
    private func loadPhoto() {
        episode.getImage { (image: UIImage) in
            DispatchQueue.main.async {
                self.podcastImageView.image = image
            }
        }
    }
    
    /*
     * Set a timer to update the progress view slider
     */
    private func setProgressViewTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(AudioPlayerViewController.updateAudioProgressBar), userInfo: nil, repeats: true)
    }
    
    /*
     * Update the progress bar to the current percentage of the audio file listened to
     */
    @objc func updateAudioProgressBar() {
        if let audioPlayer = self.audioPlayer {
            progressUISlider.setValue(Float(audioPlayer.currentTime), animated: true)
        }
    }
    
    /*
     * Perform actions for 'Play'
     */
    private func play() {
        if let audioPlayer = self.audioPlayer {
            audioPlayer.play()
            playButton.setTitle("Pause", for: .normal)
            self.isPlaying = true
        }
    }
    
    /*
     * Perform actions for 'Pause'
     */
    private func pause() {
        if let audioPlayer = self.audioPlayer {
            audioPlayer.pause()
            playButton.setTitle("Play", for: .normal)
            self.isPlaying = false
        }
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        if self.isPlaying == false {
            play()
        } else {
            pause()
        }
    }
    @IBAction func progressBarTouch(_ sender: Any) {
        if let timer = self.timer {
            self.isPlayingBeforeChange = self.isPlaying
            
            // Pause the audio if not already pause
            pause()
            timer.invalidate()
        }
    }
    @IBAction func progressBarTouchUp(_ sender: Any) {
        setProgressViewTimer()
        
        // Resume audio playing if the audio was playing before seek change
        if self.isPlayingBeforeChange == true {
            play()
        }
    }
    
    @IBAction func progressBarChange(_ sender: Any) {
        if let audioPlayer = self.audioPlayer {
            audioPlayer.currentTime = TimeInterval(progressUISlider.value)
        }
    }
}
