//
//  PassFunctions.swift
//  AmplifyPlumbing
//
//  Created by Abhi Bhabad on 6/25/24.
//

import Amplify
import Foundation

/// Attempts to purchase a pass for a given listing ID by a specified user.
/// - Parameters:
///   - listingId: The identifier for the listing whose pass needs to be purchased.
///   - userId: The user ID of the purchaser.
func purchasePass(listingId: String, userId: String) async throws {
    // Define the predicate to find an available pass
    let predicate = PassesTable.keys.listingtableID.eq(listingId)
        .and(PassesTable.keys.passStatus.eq(PassStatus.available.rawValue))
        .and(PassesTable.keys.userID.eq(nil)) // Ensure the pass has not been claimed

    do {
        // Query for an available pass
        let passes = try await Amplify.DataStore.query(PassesTable.self, where: predicate)
        guard let passToPurchase = passes.first else {
            throw PassError.noAvailablePasses
        }

        // Update the pass details
        var updatedPass = passToPurchase
        updatedPass.passStatus = .purchased
        updatedPass.userID = userId
        updatedPass.purchasedAt = Temporal.DateTime.now()

        // Save the updated pass
        try await Amplify.DataStore.save(updatedPass)
        
        let listing = try await Amplify.DataStore.query(ListingTable.self, byId: listingId)
                if var updatedListing = listing {
                    updatedListing.passesSold += 1  // Increment the passesSold count
                    // Save the updated listing
                    try await Amplify.DataStore.save(updatedListing)
                } else {
                    throw PassError.listingNotFound
                }
        
    } catch {
        // Handle errors that occurred during querying or saving
        throw error
    }
}


func redeemPass(passid:String) async throws {
    let predicate = PassesTable.keys.id.eq(passid)
        .and(PassesTable.keys.passStatus.eq(PassStatus.purchased.rawValue))
        //.and(PassesTable.keys.userID.eq("")) if u wanna add user id to query
    
    do {
        let pass = try await Amplify.DataStore.query(PassesTable.self, where: predicate) //find the pass
        guard let purchasedPass = pass.first else{
            throw PassError.listingNotFound //pass not found error (have to define this ourselves
        }
        var redeemedPass = purchasedPass
        redeemedPass.passStatus = .redeemed //toggle status to redeemed
        
        try await Amplify.DataStore.save(redeemedPass) //save the changes
    }
}

/// Custom error types for pass purchasing
enum PassError: Error, LocalizedError {
    case noAvailablePasses
    case listingNotFound
    case passNotFound
    
    var errorDescription: String? {
        switch self {
        case .noAvailablePasses:
            return "There are no available passes for this listing."
        case .listingNotFound:
            return "The listing associated with this pass was not found."
        case .passNotFound:
            return "im gay"
        }
    }
}

