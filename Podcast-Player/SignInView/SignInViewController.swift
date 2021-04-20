//
//  SignInViewController.swift
//  Podcast-Player
//
//  Created by Seb Tota on 4/20/21.
//

import UIKit
import Firebase
import GoogleSignIn

class SignInViewController: UIViewController, GIDSignInDelegate {
    
    let LoginSegueIdentifier: String = "LoginSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        if(GIDSignIn.sharedInstance().hasPreviousSignIn()) {
            print("Already signed in")
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        } else {
            print("Not yet signed in")
            GIDSignIn.sharedInstance()?.presentingViewController = self
            GIDSignIn.sharedInstance()?.signIn()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
      if let error = error {
        print("Error signing in with Google")
        print(error)
        return
      }

      guard let authentication = user.authentication else { return }
      let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                        accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { [self] (authResult, error) in
          if let error = error {
            let authError = error as NSError
            return
          }
            print("Signed in")
            self.performSegue(withIdentifier: "LoginViewSegueIdentifier", sender: show)
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
    }
}
