//
//  UserService.swift
//  Virtual Wallet
//
//  Created by Hasan Sa on 19/04/2018.
//  Copyright © 2018 Hasan Sa. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UserService {
  
  static let shared = UserService()
  
  var isLoggedIn: Bool {
    return Auth.auth().currentUser?.uid != nil
  }
  
  var currentUser: Box<UserModel> = Box(nil) {
    didSet {
      if let user = currentUser.value {
         self.set(user: user)
      }
    }
  }
  
  init() {
    if let uid = Auth.auth().currentUser?.uid {
      getUser(with: uid)
    }
  }
  
  // MARK: - Auth
  
  func login(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
    Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
      guard let user = user, error == nil else {
        completion(false, error)
        return
      }
      self.getUser(with: user.uid)
      completion(true, nil)
    }
  }
  
  func create(username: String, email: String, password: String, user: UserModel,completion: @escaping (Bool) -> Void) {
    Auth.auth().createUser(withEmail: email, password: password) { (authUser, error) in
      guard let authUser = authUser, error == nil else {
        completion(false)
        return
      }
      var userModel = UserModel()
      userModel.userId = authUser.uid
      userModel.username = username
      userModel.address = user.address
      userModel.guid = user.guid
      self.currentUser.value = userModel
      self.set(user: self.currentUser.value!)
      completion(true)
    }
  }
  
  func logout() {
    try? Auth.auth().signOut()
  }
  
  // MARK: - User Actions
  
  func update(transactions: [TransactionModel]) {
    guard let userId = Auth.auth().currentUser?.uid else {
      return
    }
    let dicts: [[String: Any]] = transactions.compactMap {
      if let data = try? JSONEncoder().encode($0),
        let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
        return dict
      }
      return nil
    }
    var ref: DatabaseReference!
    ref = Database.database().reference()
    let transactionsRef = ref.child("users").child(userId).child("transactions")
    transactionsRef.setValue(dicts)
  }
  
}

// MARK: - Private

fileprivate extension UserService {
  func set(user: UserModel) {
    if let data = try? JSONEncoder().encode(user),
      let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
      var ref: DatabaseReference!
      ref = Database.database().reference()
      ref.child("users").child(user.userId).setValue(dict)
    }
  }
  
  func getUser(with id: String) {
    var ref: DatabaseReference!
    ref = Database.database().reference()
    ref.observe(DataEventType.value, with: { (snapshot: DataSnapshot) in
      if let postDict = snapshot.childSnapshot(forPath: "users/\(id)").value as? [String : AnyObject],
        let data = try? JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted),
        let result = try? JSONDecoder().decode(UserModel.self, from: data) {
        self.currentUser.value = result
      }
    })
  }
}
