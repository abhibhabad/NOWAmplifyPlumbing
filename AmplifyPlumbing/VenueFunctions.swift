//
//  VenueFunctions.swift
//  AmplifyPlumbing
//
//  Created by Abhi Bhabad on 7/5/24.
//

import Foundation
import Amplify



func createVenue(venue: Venues, completion: @escaping (Result<Bool, Error>) -> Void) async {
    do {
        let savedVenue = try await Amplify.DataStore.save(venue)
        print("Saved item: \(savedVenue)")
    } catch let error as DataStoreError {
        print("Error creating item: \(error)")
    } catch {
        print("Unexpected error: \(error)")
    }
}
