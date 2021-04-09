//
//  ViewController.swift
//  Podcast-Player
//
//  Created by Sebastian Tota on 4/9/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let audio = Bundle.main.path(forResource: "podcast", ofType: "mp3")
        
        do  {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audio!))
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [AVAudioSession.CategoryOptions.mixWithOthers])
        } catch {
            print(error)
        }
        
    }

    @IBAction func playButtonPressed(_ sender: UIButton) {
        audioPlayer.play()
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        audioPlayer.pause()
    }
}

