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
var adStartTime: Double?

class AudioPlayerViewController: UIViewController {

    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    let playButtonConf = UIImage.SymbolConfiguration(pointSize: 40.0)
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    
    // Progress Slider
    @IBOutlet weak var progressUISlider: UISlider!
    @IBOutlet weak var backFifteenButton: UIButton!
    @IBOutlet weak var forwardThirtyButton: UIButton!
    
    // Buttons
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var adStartButton: UIButton!
    @IBOutlet weak var adStopButton: UIButton!
    
    
    // Labels
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    var timer: Timer?
    var isPlayingBeforeChange: Bool = false
    var isNewEpsiode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        episode.getAdIntervals { (adIntervals: [[Int]]) in
            print(adIntervals)
        }
        
        if isNewEpsiode == true {
            loadAudio()
        }
        if episode != nil {
            titleLabel.text = episode.getTitle()
            updateAudioProgressBar()
            loadingActivityIndicatorView.startAnimating()
            loadPhoto()
            setProgressViewTimer()
            self.loadingActivityIndicatorView.isHidden = true
            self.enablePlayerButtons()
            
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
     * Enable the audio player buttons
     */
    private func enablePlayerButtons() {
        playButton.isEnabled = true
        backFifteenButton.isEnabled = true
        forwardThirtyButton.isEnabled = true
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
                    self.enablePlayerButtons()
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
     * Format an int of seconds to a display string
     * @param   Int     The seconds representation of time
     * @return  String  The display view of the time specified
     */
    private func secondsToTextDisplay(seconds: Int) -> String {
        var time = seconds
        let hours = seconds / 3600
        time -= hours * 3600
        let minutes = time / 60
        time -= minutes * 60
        
        if hours > 0 {
            return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, time)
        } else {
            return String(format: "%0.2d:%0.2d", minutes, time)
        }
    }
    
    /*
     * Set a timer to update the progress view slider
     */
    private func setProgressViewTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AudioPlayerViewController.updateAudioProgressBar), userInfo: nil, repeats: true)
    }
    
    /*
     * Update the progress bar to the current percentage of the audio file listened to
     */
    @objc func updateAudioProgressBar() {
        if let audioPlayer = audioPlayer {
            progressUISlider.setValue(Float(audioPlayer.currentTime), animated: true)
            timeElapsedLabel.text = secondsToTextDisplay(seconds: Int(audioPlayer.currentTime))
            timeRemainingLabel.text = "-" + secondsToTextDisplay(seconds: Int(audioPlayer.duration - audioPlayer.currentTime))
        }
    }
    
    /*
     * Perform actions for 'Play'
     */
    private func play() {
        if let audioPlayer = audioPlayer {
            audioPlayer.play()
            playButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: playButtonConf), for: .normal)
            isPlaying = true
        }
    }
    
    /*
     * Perform actions for 'Pause'
     */
    private func pause() {
        if let audioPlayer = audioPlayer {
            audioPlayer.pause()
            playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: playButtonConf), for: .normal)
            isPlaying = false
        }
    }
    
    /*
     * Move audio forward 30 seconds
     */
    private func forwardThirty() {
        if let audioPlayer = audioPlayer {
            audioPlayer.currentTime = audioPlayer.currentTime + 30
            updateAudioProgressBar()
        }
    }
    
    /*
     * Reverse audio 15 second back in audio player
     */
    private func reverseFifteen() {
        if let audioPlayer = audioPlayer {
            audioPlayer.currentTime = audioPlayer.currentTime - 15
            updateAudioProgressBar()
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
        updateAudioProgressBar()
        
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
    
    @IBAction func forwardThirtyPressed(_ sender: UIButton) {
        forwardThirty()
    }
    
    @IBAction func reverseFifteenPressed(_ sender: Any) {
        reverseFifteen()
    }
    
    @IBAction func adStartPressed(_ sender: Any) {
        if let audioPlayer = audioPlayer {
            adStartTime = audioPlayer.currentTime
            adStopButton.isEnabled = true
        }
    }
    
    @IBAction func adStopPressed(_ sender: Any) {
        if let start = adStartTime, let audioPlayer = audioPlayer {
            let end = audioPlayer.currentTime
            
            if start >= end {
                return
            }
            
            episode.addAdInterval(start: Int(start), end: Int(end))
            adStartTime = nil
            adStopButton.isEnabled = false
        }
    }
    
}
