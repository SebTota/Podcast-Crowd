//
//  AudioPlayerViewController.swift
//  Podcast-Player
//
//  Created by Seb Tota on 4/10/21.
//

import UIKit
import AVFoundation

var timer: Timer?
var audioPlayer: AVAudioPlayer?
var episode: Episode!
var isPlaying: Bool = false
var adStartTime: Double?

class AudioPlayerViewController: UIViewController {

    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    let playButtonConf = UIImage.SymbolConfiguration(pointSize: 40.0)
    
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
    
    var isPlayingBeforeChange: Bool = false
    var isNewEpsiode: Bool = false
    var adIntervals: [[Int]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableAdminFeatures()
        
        if isNewEpsiode == true {
            timer?.invalidate()
            disablePlayerButtons()
            resetTimeAndProgressBar()
            titleLabel.text = episode.getTitle()
            loadPhoto()
        }
        
        if episode != nil {
            episode.getAdIntervals { [self] (adIntervals: [[Int]]) in
                self.adIntervals = adIntervals
            }
            
            if isNewEpsiode == true {
                loadAudio()
            } else {
                viewDidLoadContinuePlaying()
            }
        }
        isNewEpsiode = false
    }
    
    func viewDidLoadContinuePlaying() {
        titleLabel.text = episode.getTitle()
        loadPhoto()
        setProgressViewTimer()
        self.enablePlayerButtons()
        
        if isPlaying == true {
            play()
        }
    }
    
    func setNewEpisode(newEpisode: Episode) {
        if episode != nil && episode!.getTitle() == newEpisode.getTitle() {
            return
        }
        audioPlayer?.stop()
        timer?.invalidate()
        isNewEpsiode = true
        episode = newEpisode
    }
    
    /*
     * Enable the audio player buttons
     */
    private func enablePlayerButtons() {
        playButton.isHidden = false
        playButton.isEnabled = true
        backFifteenButton.isEnabled = true
        forwardThirtyButton.isEnabled = true
        if let audioPlayer = audioPlayer {
            progressUISlider.maximumValue = Float(audioPlayer.duration)
        }
    }
    
    /*
     * Disable the audio player buttons
     */
    private func disablePlayerButtons() {
        playButton.isEnabled = false
        backFifteenButton.isEnabled = false
        forwardThirtyButton.isEnabled = false
    }
    
    /*
     * Load in the audio file for the chosen episode
     */
    private func loadAudio() {
        audioPlayer?.stop()
        episode.getEpisode { (newAudioPlayer: AVAudioPlayer?) in
            audioPlayer = newAudioPlayer
            DispatchQueue.main.async {
                do  {
                    let instance = AVAudioSession.sharedInstance()
                    try instance.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [])
                    try instance.setActive(true, options: [])
                    
                    self.updateAudioProgressBar()
                    //self.loadingActivityIndicatorView.isHidden = true
                    self.enablePlayerButtons()
                    self.setProgressViewTimer()
                    self.play()
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
     * Display ad skipping admin buttons if user is admin
     */
    private func enableAdminFeatures() {
        User.userIsAdmin(callback: { [self] (admin: Bool) in
            if admin == true {
                print("User is admin")
                adStartButton.isHidden = false
                adStartButton.isEnabled = true
                adStopButton.isHidden = false
            } else {
                print("User is not admin")
            }
        })
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
     * Reset the time and progress bar to 0
     */
    private func resetTimeAndProgressBar() {
        progressUISlider.setValue(0.0, animated: true)
        timeElapsedLabel.text = secondsToTextDisplay(seconds: 0)
        timeRemainingLabel.text = "-" + secondsToTextDisplay(seconds: 0)
    }
    
    /*
     * Set a timer to update the progress view slider
     */
    private func setProgressViewTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AudioPlayerViewController.updateAudioProgressBar), userInfo: nil, repeats: true)
    }
    
    /*
     * Update the progress bar to the current percentage of the audio file listened to
     */
    @objc func updateAudioProgressBar() {
        if let audioPlayer = audioPlayer {
            let currentTime = Int(audioPlayer.currentTime)
            for i in adIntervals {
                if i[0] <= currentTime {
                    if i[1] > currentTime {
                        audioPlayer.currentTime = Double(i[1])
                        break
                    }
                }
            }
            
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
    
    /*
     * Play button pressed
     */
    @IBAction func playButtonPressed(_ sender: Any) {
        if isPlaying == false {
            play()
        } else {
            pause()
        }
    }
    
    /*
     * Progress button has been touched
     */
    @IBAction func progressBarTouch(_ sender: Any) {
        if let timer = timer {
            self.isPlayingBeforeChange = isPlaying
            
            // Pause the audio if not already pause
            pause()
            timer.invalidate()
        }
    }
    
    private func doneEditingSlider() {
        if let audioPlayer = audioPlayer {
            audioPlayer.currentTime = TimeInterval(progressUISlider.value)
        }
        
        setProgressViewTimer()
        updateAudioProgressBar()
        
        // Resume audio playing if the audio was playing before seek change
        if self.isPlayingBeforeChange == true {
            play()
        }
    }
    
    /*
     * Editing of progress bar finished
     */
    @IBAction func progressBarTouchUp(_ sender: Any) {
        doneEditingSlider()
    }
    
    @IBAction func progressBarTouchUpOutside(_ sender: Any) {
        doneEditingSlider()
    }
    
    /*
     * Progress bar value has changed by user
     */
    @IBAction func progressBarChange(_ sender: Any) {
        if let audioPlayer = audioPlayer {
            timeElapsedLabel.text = secondsToTextDisplay(seconds: Int(progressUISlider.value))
            timeRemainingLabel.text = "-" + secondsToTextDisplay(seconds: Int(audioPlayer.duration) - Int(progressUISlider.value))
        }
    }
    
    /*
     * Fast forward thirty seconds
     */
    @IBAction func forwardThirtyPressed(_ sender: UIButton) {
        forwardThirty()
    }
    
    /*
     * Reverse fifteen seconds
     */
    @IBAction func reverseFifteenPressed(_ sender: Any) {
        reverseFifteen()
    }
    
    /*
     * Ad start button pressed
     */
    @IBAction func adStartPressed(_ sender: Any) {
        if let audioPlayer = audioPlayer {
            adStartTime = audioPlayer.currentTime
            adStopButton.isEnabled = true
        }
    }
    
    /*
     * Ad end button was pressed
     */
    @IBAction func adStopPressed(_ sender: Any) {
        if let start = adStartTime, let audioPlayer = audioPlayer {
            let end = audioPlayer.currentTime
            
            if start >= end {
                return
            }
            
            episode.addAdInterval(start: Int(start), end: Int(end))
            self.adIntervals.append([Int(start), Int(end)])
            adStartTime = nil
            adStopButton.isEnabled = false
        }
    }
    
    /*
     * Reset episode button pressed.
     * Remove all ad intervals associated with this episode
     */
    @IBAction func resetEpisodeButtonPressed(_ sender: Any) {
        if let episode = episode {
            episode.resetAdIntervals()
            self.adIntervals = []
        }
    }
}
