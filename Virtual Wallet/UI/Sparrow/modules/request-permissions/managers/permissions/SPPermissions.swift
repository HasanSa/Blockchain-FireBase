// The MIT License (MIT)
// Copyright © 2017 Ivan Vorobei (hello@ivanvorobei.by)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import AVFoundation
import UserNotifications
import Photos
import MapKit
import EventKit
import Contacts

class SPCameraPermission: SPPermissionInterface {
    
    func isAuthorized(completion: @escaping (Bool) -> Void) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.authorized {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func request(withComlectionHandler complectionHandler: @escaping ()->()?) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
            finished in
            DispatchQueue.main.async {
                complectionHandler()
            }
        })
    }
}

class SPNotificationPermission: SPPermissionInterface {
    
  func isAuthorized(completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
        completion(false)
      }
    }
    
    func request(withComlectionHandler complectionHandler: @escaping ()->()?) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                DispatchQueue.main.async {
                    complectionHandler()
                }
            }
        }
      
            // early iOS support
        else {
          UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
          DispatchQueue.main.async {
            complectionHandler()
          }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
}

class SPPhotoLibraryPermission: SPPermissionInterface {
    
    func isAuthorized(completion: @escaping (Bool) -> Void) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func request(withComlectionHandler complectionHandler: @escaping ()->()?) {
        PHPhotoLibrary.requestAuthorization({
            finished in
            DispatchQueue.main.async {
                complectionHandler()
            }
        })
    }
}

class SPMicrophonePermission: SPPermissionInterface {
    
    func isAuthorized(completion: @escaping (Bool) -> Void) {
        if AVAudioSession.sharedInstance().recordPermission() == .granted {
            completion(true)
        }
        completion(false)
    }
    
    func request(withComlectionHandler complectionHandler: @escaping ()->()?) {
        AVAudioSession.sharedInstance().requestRecordPermission {
            granted in
            DispatchQueue.main.async {
                complectionHandler()
            }
        }
    }
}


class SPCalendarPermission: SPPermissionInterface {
    
    func isAuthorized(completion: @escaping (Bool) -> Void) {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        switch (status) {
        case EKAuthorizationStatus.authorized:
            completion(true)
        default:
            completion(false)
        }
    }
    
    func request(withComlectionHandler complectionHandler: @escaping ()->()?) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            DispatchQueue.main.async {
                complectionHandler()
            }
        })
    }
}

class SPLocationPermission: SPPermissionInterface {
    
    var type: SPLocationType
    
    enum SPLocationType {
        case Always
        case WhenInUse
        case AlwaysWithBackground
    }
    
    init(type: SPLocationType) {
        self.type = type
    }
    
    func isAuthorized(completion: @escaping (Bool) -> Void) {
        
        let status = CLLocationManager.authorizationStatus()
        
        switch self.type {
        case .Always:
            if status == .authorizedAlways {
                completion(true)
            } else {
                completion(false)
            }
        case .WhenInUse:
            if status == .authorizedWhenInUse {
                completion(true)
            } else {
                completion(false)
            }
        case .AlwaysWithBackground:
            if status == .authorizedAlways {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func request(withComlectionHandler complectionHandler: @escaping ()->()?) {
        
        switch self.type {
        case .Always:
            if SPRequestPermissionAlwaysAuthorizationLocationHandler.shared == nil {
                SPRequestPermissionAlwaysAuthorizationLocationHandler.shared = SPRequestPermissionAlwaysAuthorizationLocationHandler()
            }
            
            SPRequestPermissionAlwaysAuthorizationLocationHandler.shared!.requestPermission { (authorized) in
                DispatchQueue.main.async {
                    complectionHandler()
                    SPRequestPermissionAlwaysAuthorizationLocationHandler.shared = nil
                }
            }
            break
        case .WhenInUse:
            if SPRequestPermissionWhenInUseAuthorizationLocationHandler.shared == nil {
                SPRequestPermissionWhenInUseAuthorizationLocationHandler.shared = SPRequestPermissionWhenInUseAuthorizationLocationHandler()
            }
            
            SPRequestPermissionWhenInUseAuthorizationLocationHandler.shared!.requestPermission { (authorized) in
                DispatchQueue.main.async {
                    complectionHandler()
                    SPRequestPermissionWhenInUseAuthorizationLocationHandler.shared = nil
                }
            }
            break
        case .AlwaysWithBackground:
            if SPRequestPermissionLocationWithBackgroundHandler.shared == nil {
                SPRequestPermissionLocationWithBackgroundHandler.shared = SPRequestPermissionLocationWithBackgroundHandler()
            }
            
            SPRequestPermissionLocationWithBackgroundHandler.shared!.requestPermission { (authorized) in
                DispatchQueue.main.async {
                    complectionHandler()
                    SPRequestPermissionLocationWithBackgroundHandler.shared = nil
                }
            }
            break
        }
    }
}

class SPContactsPermission: SPPermissionInterface {
    
    func isAuthorized(completion: @escaping (Bool) -> Void) {
        if #available(iOS 9.0, *) {
            let status = CNContactStore.authorizationStatus(for: .contacts)
            if status == .authorized {
                completion(true)
            } else {
                completion(false)
            }
        } else {
            let status = ABAddressBookGetAuthorizationStatus()
            if status == .authorized {
                completion(true)
            } else {
                completion(false)
            }
        }
        
    }
    
    func request(withComlectionHandler complectionHandler: @escaping ()->()?) {
        if #available(iOS 9.0, *) {
           let store = CNContactStore()
            store.requestAccess(for: .contacts, completionHandler: { (granted, error) in
                DispatchQueue.main.async {
                    complectionHandler()
                }
            })
        } else {
            let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
            ABAddressBookRequestAccessWithCompletion(addressBookRef) {
                (granted: Bool, error: CFError?) in
                DispatchQueue.main.async() {
                    complectionHandler()
                }
            }
        }
    }
}

class SPRemindersPermission: SPPermissionInterface {
    
    func isAuthorized(completion: @escaping (Bool) -> Void) {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.reminder)
        switch (status) {
        case EKAuthorizationStatus.authorized:
            completion(true)
        default:
            completion(false)
        }
    }
    
    func request(withComlectionHandler complectionHandler: @escaping ()->()?) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: EKEntityType.reminder, completion: {
            (accessGranted: Bool, error: Error?) in
            DispatchQueue.main.async {
                complectionHandler()
            }
        })
    }
}

class SPBluetoothPermission: SPPermissionInterface {
    
    func isAuthorized(completion: @escaping (Bool) -> Void) {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.reminder)
        switch (status) {
        case EKAuthorizationStatus.authorized:
            completion(true)
        default:
            completion(false)
        }
    }
    
    func request(withComlectionHandler complectionHandler: @escaping ()->()?) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: EKEntityType.reminder, completion: {
            (accessGranted: Bool, error: Error?) in
            DispatchQueue.main.async {
                complectionHandler()
            }
        })
    }
}

