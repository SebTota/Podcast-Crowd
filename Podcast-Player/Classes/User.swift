//
//  User.swift
//  Podcast-Player
//
//  Created by Seb Tota on 4/22/21.
//

import Foundation
import Firebase

var admin: Bool?

class User {
    static func userIsAdmin(callback: @escaping(Bool) -> ()) {
        if let admin = admin {
            callback(admin)
        } else {
            let user = Auth.auth().currentUser
            if user != nil, let email = user!.email {
                print("Email: \(email)")
                let db: DocumentReference = Firestore.firestore().collection("admins").document(email)
                db.getDocument { (document: DocumentSnapshot?, error: Error?) in
                    if let e = error {
                        admin = false
                        callback(false)
                    } else {
                        if let document = document, document.exists {
                            admin = true
                            callback(true)
                        } else {
                            admin = false
                            callback(false)
                        }
                    }
                }
            }
        }
    }
}
