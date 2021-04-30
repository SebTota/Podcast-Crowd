//
//  NewRssFeedViewController.swift
//  Podcast-Player
//
//  Created by Seb Tota on 4/29/21.
//

import UIKit

class NewRssFeedViewController: UIViewController {
    
    @IBOutlet weak var rssFeedInput: UITextField!
    
    var feedUrls: [String] = []
    var callbackClosure: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let feeds: [String] = UserDefaults.standard.value(forKey: "feeds") as? [String] {
            feedUrls = feeds
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        callbackClosure?()
    }
    
    
    @IBAction func rssFeedInputBoxPrimaryAction(_ sender: Any) {
        if let inputText = rssFeedInput.text, URL(string: inputText) != nil, !feedUrls.contains(inputText) {
            print("Adding RSS Feed: \(inputText)")
            feedUrls.append(inputText)
            UserDefaults.standard.setValue(feedUrls, forKey: "feeds")
            dismiss(animated: true, completion: nil)
        }
    }
    
}
