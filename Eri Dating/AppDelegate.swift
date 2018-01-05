//
//  AppDelegate.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 28/11/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FacebookCore
import FBSDKLoginKit
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    var window: UIWindow?

    var FirebaseAuth:Auth!
    
    var activeUser:User!
   
    // To log out from Facebook
     var loginManager:FBSDKLoginManager?
    
    private lazy var checkInternetConnection: Void = {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.checkConnection()
        })
    }()
    
    // For Firebase Notifications
    func setupFirebaseMessaging(application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()

        
        Messaging.messaging().delegate = self
        
    }

    @objc func uploadStoredToken() {
        if let retrievedToken = UserDefaults.standard.value(forKey: "User_Notification_Token") as? String {
            attemptToStoreFirebaseToken(token: retrievedToken)
        }
    }
    func attemptToStoreFirebaseToken(token:String) {
        if let uid = Auth.auth().currentUser?.uid {
            Users.updateUserFirebaseNotificationToken(uid: uid, token: token)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("Connected"), object: nil)
            //print("Stored notification token")
        } else {
            UserDefaults.standard.setValue(token, forKey: "User_Notification_Token")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.addObserver(self, selector: #selector(uploadStoredToken), name: NSNotification.Name.init("Connected"), object: nil)
            //print("Awaiting connectivity to store Notification token")
        }
    }
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        //print("(didRefresh) Firebase registration token: \(fcmToken)")
        attemptToStoreFirebaseToken(token: fcmToken)
        
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //print("Data came through:")
        //print(userInfo)
        // Not necessary as app receives the notification and presents the alert to user as it should.
    }
    
    func application(received remoteMessage: MessagingRemoteMessage) {
        //print("Message:", remoteMessage.description)
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        //print("Firebase registration token: \(fcmToken)")
        attemptToStoreFirebaseToken(token: fcmToken)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        
        //print("didReceiveToken:", fcmToken)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // User is already on the app, no notification necessary.
        //print("MESSAGE: ", notification)
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        /*
        print(deviceToken.description)
        print("@@@@@@@@@@@@@@@@@@@@")
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print(deviceTokenString)*/
        
       // print("didRegisterForRemote:", deviceToken)
        
    }
    // For Facebook Login
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let fbHandle = SDKApplicationDelegate.shared.application(app, open: url, options: options)
        
        return fbHandle
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupFirebaseMessaging(application: application)
        // For Facebook Login
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        
        FirebaseApp.configure()
        FirebaseAuth = Auth.auth()

        _ = checkInternetConnection
        
        addFirebaseStateListener()
        
        return true
    }
   
    func addFirebaseStateListener() {
        FirebaseAuth.addStateDidChangeListener { (auth, user) in
            if(user != nil) {
                if(self.activeUser != user) { // Done to prevent multiple viewcontrollers from being presented.
                    
                    self.activeUser = user
                    self.setOnline()
                    if UserDefaults.standard.value(forKey: "FBRegistrationProcess") as? Bool != true {
                        
                        if UserDefaults.standard.value(forKey: "NewlyRegistered") as? Int == 1 {
                            self.showMyProfileVC()
                            UserDefaults.standard.removeObject(forKey: "NewlyRegistered")
                            UserDefaults.standard.synchronize()
                        } else {
                            self.showMain()
                        }
                    NotificationCenter.default.post(name: NSNotification.Name.init("Connected"), object: nil)
                }
                }
            } else if user == nil {
                if self.loginManager != nil {
                    self.loginManager?.logOut()
                }
                self.showLogin()
            }
        }
    }
    func setOnline() {
        if let uid = Auth.auth().currentUser?.uid {
            let connectedUsersRef = Database.database().reference().child("connected_users")
        
            connectedUsersRef.onDisconnectUpdateChildValues([uid:false] as [String:Bool])
            connectedUsersRef.updateChildValues([uid:true] as [String:Bool])
        }
    }
    func setOffline() {
        if let uid = Auth.auth().currentUser?.uid {
            let connectedUsersRef = Database.database().reference().child("connected_users")
            
            connectedUsersRef.updateChildValues([uid:false] as [String:Bool])
        }
    }
    

    var noConnectionTimer:Timer?
    func presentCustom(viewController:UIViewController) {
        if let navController = self.window?.rootViewController as? UINavigationController {
            navController.visibleViewController?.present(viewController, animated: true, completion: nil)
            return
        }
        if let sourceViewController = self.window?.rootViewController {
            sourceViewController.present(viewController, animated: true, completion: nil)
            return
        }
    }
    var alertController:UIAlertController?
    @objc func showNoConnectionError() {
        alertController = UIAlertController.init(title: "No Internet Connection", message: "Unable to connect to server, \nPlease make sure you are connected to WiFi or a 3G/4G network", preferredStyle: .alert)
        
        alertController?.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (action) in
            self.checkConnectionAfterShortWait()
        }))
        
        alertController?.addAction(UIAlertAction(title: "Close app", style: .destructive, handler: { (action) in
            exit(0)
        }))
        self.presentCustom(viewController: alertController!)
    }
    
    func checkConnectionAfterShortWait() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.checkConnectionOnce()
        }
    }

    func removeCheckConnectionDialog() {
        alertController?.dismiss(animated: true, completion: nil)
    }
    
    func checkConnection() {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                self.noConnectionTimer?.invalidate()
                self.removeCheckConnectionDialog()
                self.enableUserInteraction()
                self.setOnline()
            } else {
                self.noConnectionTimer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(self.showNoConnectionError), userInfo: nil, repeats: false)
                self.disableUserInteraction()
            }
        })
    }
    
    func disableUserInteraction() {
        self.window?.rootViewController?.view.isUserInteractionEnabled = false
    }
    func enableUserInteraction() {
        self.window?.rootViewController?.view.isUserInteractionEnabled = true
    }
    
    var checkConnectionCount:Int = 0
    func checkConnectionOnce() {
        let connectedReference = Database.database().reference(withPath: ".info/connected")
        
        connectedReference.observeSingleEvent(of: .value, with: { (snapshot) in
            if let connected = snapshot.value as? Bool {
                if connected == true {
                    self.noConnectionTimer?.invalidate()
                    self.enableUserInteraction()
                    self.setOnline()
                    self.removeCheckConnectionDialog()
                } else {
                    if self.checkConnectionCount == 0 {
                        self.checkConnectionCount += 1
                        self.checkConnectionOnce()
                        print("Checking connection again.")
                    } else {
                        self.disableUserInteraction()
                        self.noConnectionTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.showNoConnectionError), userInfo: nil, repeats: false)
                    }
                }
            } else {
                self.disableUserInteraction()
                self.noConnectionTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.showNoConnectionError), userInfo: nil, repeats: false)
            }
        })
        
    }
    

    func signOut() {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        }
        catch let SignOutError {
            print("Error signing out: %@", SignOutError)
        }
    }
    
    func showMain() {
        //isMainActive = true
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let myStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let mainTabBarController = myStoryboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
            return
        }
        
        
        self.window?.rootViewController = mainTabBarController
        self.window?.makeKeyAndVisible()
    }
    func showMyProfileVC() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        
        let myStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let mainTabBarController = myStoryboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
            return
        }
        mainTabBarController.selectedIndex = 2
        
        self.window?.rootViewController = mainTabBarController
        
        self.window?.makeKeyAndVisible()
        
    }
    
    func showLogin() {
        if let windowRestorationID = self.window?.rootViewController?.restorationIdentifier {
            if windowRestorationID == "LoginNavigationController" {
                return
            }
        }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let myStoryboard = UIStoryboard.init(name: "Main", bundle: nil)

        let navigationController:UINavigationController = myStoryboard.instantiateViewController(withIdentifier: "LoginNavigationController") as! UINavigationController
        
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
    
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Eri_Dating")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

