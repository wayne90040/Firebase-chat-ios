//
//  AppDelegate.swift
//  ios-FirebaseChat
//
//  Created by Wei Lun Hsu on 2020/11/1.
//

/*
import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

*/

// Swift // // AppDelegate.swift

// Add Facebook login

import UIKit
import FBSDKCoreKit
import GoogleSignIn
import Firebase



@UIApplicationMain
class AppDelegate:UIResponder, UIApplicationDelegate {
    
    
    /// App 啟動時,執行的第一個 function 可以在這裡去跟server拉資料更新使用者狀態或更新檔......等
    func application( _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) -> Bool {
        ApplicationDelegate.shared.application( application, didFinishLaunchingWithOptions: launchOptions )
        
        // Firebase
        FirebaseApp.configure()
        
        // Google
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        
        return true
        
    }
    
    
    func application( _ app:UIApplication, open url:URL, options: [UIApplication.OpenURLOptionsKey :Any] = [:] ) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        // Google Sign In
        return GIDSignIn.sharedInstance().handle(url)
    }
}


// MARK:- GIDSignInDelegate
/// https://firebase.google.com/docs/auth/ios/google-signin#swift_5
/// https://www.youtube.com/watch?v=gkRHb7JmXEQ&t=1064s

extension AppDelegate: GIDSignInDelegate{
    
    // Google 登入完成時觸發
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        guard let user = user, error == nil else {
            if let error = error{
                print("Failed to sign in with Google: \(error)")
            }
            return
        }
        
        guard let auth = user.authentication else {
            print("Failed to Get Authentication")
            return
        }
        
        // MARK: 檢查 Database 有無重複
        DatabaseManager.shared.userExists(with: user.profile.email, completion: { exist in
            if !exist{
                // add to database
                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: user.profile.givenName,
                                                                    lastName: user.profile.familyName,
                                                                    emailAdress: user.profile.email))
            }
            
            let credentail = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
            
            FirebaseAuth.Auth.auth().signIn(with: credentail, completion: { (result, error) in
                guard result != nil, error == nil else{
                    print("Failed Log in with Google")
                    return
                }
                 
                
                print("Success Log in with Google")
                /// 成功登入 發送通知
                NotificationCenter.default.post(name: .didLogInNotification, object: nil)
                
            })
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("didDisconnectWith")
    }

}




