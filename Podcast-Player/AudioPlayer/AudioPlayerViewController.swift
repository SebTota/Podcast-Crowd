//
//  AudioPlayerViewController.swift
//  Podcast-Player
//
//  Created by Seb Tota on 4/10/21.
//

import UIKit
import AVFoundation

var audioPlayer: AVAudioPlayer?
var episode: Episode!
var isPlaying: Bool = false

class AudioPlayerViewController: UIViewController {

    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var progressUISlider: UISlider!
    
    var timer: Timer?
    var isPlayingBeforeChange: Bool = false
    var isNewEpsiode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isNewEpsiode == true {
            loadAudio()
        }
        if episode != nil {
            titleLabel.text = episode.getTitle()
            loadingActivityIndicatorView.startAnimating()
            loadPhoto()
            setProgressViewTimer()
            self.loadingActivityIndicatorView.isHidden = true
            self.enablePlayerButton()
            
            if isPlaying == true {
                play()
            }
            
        } else {
            print("Epside is nil")
        }
        isNewEpsiode = false
    }
    
    func setNewEpisode(newEpisode: Episode) {
        isNewEpsiode = true
        episode = newEpisode
    }
    
    /*
     * Enable the play/pause button
     */
    private func enablePlayerButton() {
        playButton.isEnabled = true
        if let audioPlayer = audioPlayer {
            progressUISlider.maximumValue = Float(audioPlayer.duration)
        }
    }
    
    /*
     * Load in the audio file for the chosen episode
     */
    private func loadAudio() {
        episode.getEpisode { (newAudioPlayer: AVAudioPlayer?) in
            audioPlayer = newAudioPlayer
            DispatchQueue.main.async {
                do  {
                    let instance = AVAudioSession.sharedInstance()
                    try instance.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [])
                    try instance.setActive(true, options: [])
                    
                    self.loadingActivityIndicatorView.isHidden = true
                    self.enablePlayerButton()
                } catch {
                    print(error)
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
        if let audioPlayer = audioPlayer {
            progressUISlider.setValue(Float(audioPlayer.currentTime), animated: true)
        }
    }
    
    /*
     * Perform actions for 'Play'
     */
    private func play() {
        if let audioPlayer = audioPlayer {
            audioPlayer.play()
            playButton.setTitle("Pause", for: .normal)
            isPlaying = true
        }
    }
    
    /*
     * Perform actions for 'Pause'
     */
    private func pause() {
        if let audioPlayer = audioPlayer {
            audioPlayer.pause()
            playButton.setTitle("Play", for: .normal)
            isPlaying = false
        }
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        if isPlaying == false {
            play()
        } else {
            pause()
        }
    }
    @IBAction func progressBarTouch(_ sender: Any) {
        if let timer = self.timer {
            self.isPlayingBeforeChange = isPlaying
            
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
        if let audioPlayer = audioPlayer {
            audioPlayer.currentTime = TimeInterval(progressUISlider.value)
        }
    }
}
