//
//  AmplifyPlumbingApp.swift
//  AmplifyPlumbing
//
//  Created by Abhi Bhabad on 4/24/24.
//
import Amplify
import AWSDataStorePlugin
import SwiftUI
import AWSAPIPlugin
import AWSCognitoAuthPlugin

@main
struct AmplifyPlumbingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        do {
            // AmplifyModels is generated in the previous step
            let dataStorePlugin = AWSDataStorePlugin(modelRegistration: AmplifyModels())
            try Amplify.add(plugin: dataStorePlugin)
            //try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            print("Amplify configured with DataStore and Auth plugin")
        } catch {
            print("Failed to initialize Amplify with \(error)")
        }
        
        
    }
    
        
    
}
