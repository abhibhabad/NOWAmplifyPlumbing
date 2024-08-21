//
//  ListingFunctions.swift
//  AmplifyPlumbing
//
//  Created by Abhi Bhabad on 6/19/24.
//

import Amplify
import Foundation
import SwiftUI


/// Creates a listing and associated passes with a predefined pass status.
/// - Parameters:
///   - listing: The listing to be created.
///   - passCount: The number of passes to create for this listing.
///   - completion: The completion handler that handles the result.

func fetchListing(id: String) async -> [ListingTable] {
    let predicate = ListingTable.keys.id.eq(id)
    do {
        let listing = try await Amplify.DataStore.query(ListingTable.self, where: predicate)
        return listing
    } catch {
        print("Error fetching listing with id \(id): \(error)")
        return []
    }
}

func deleteListing(listing: ListingTable) async {
    var updatedlisting = listing
    updatedlisting.deletedAt = Temporal.DateTime(Date())
    do {
        let deletedListing = try await Amplify.DataStore.save(updatedlisting)
    } catch {
        print("Error")
    }
}


func createListingWithPasses(listing: ListingTable, passCount: Int, completion: @escaping (Result<Bool, Error>) -> Void) async{
    // First, save the listing
    do {
        if listing.listingType.rawValue == "COVER" {
            let savedListing = try await Amplify.DataStore.save(listing)
        } else {
            let savedListing = try await Amplify.DataStore.save(listing)
            let passStatus = PassStatus.available
            await createPassesForListing(listingId: savedListing.id, passCount: passCount, passStatus: passStatus, venueName: savedListing.venueName, listingName: savedListing.listingName, listingType: savedListing.listingType, listingDescription: savedListing.description, listingInstructions: savedListing.instructions, listingPrice: Float(savedListing.listingPrice), listingStart: savedListing.listingStart, listingEnd: savedListing.listingEnd, completion: completion)
            print("Saved item: \(savedListing)")
        }
    } catch let error as DataStoreError {
        print("Error creating item: \(error)")
    } catch {
        print("Unexpected error: \(error)")
    }

}



/// Creates passes associated with a given listing ID.
/// - Parameters:
///   - listingId: The ID of the listing for which passes are created.
///   - passCount: The number of passes to create.
///   - passStatus: The initial status of the passes.
///   - completion: The completion handler that handles the result.
private func createPassesForListing(listingId: String, passCount: Int, passStatus: PassStatus, venueName: String, listingName: String, listingType: ListingType, listingDescription: String, listingInstructions: String, listingPrice: Float, listingStart: Temporal.DateTime, listingEnd: Temporal.DateTime, completion: @escaping (Result<Bool, Error>) -> Void) async {
    var passes: [PassesTable] = []
    for _ in 0..<passCount {
        let pass = PassesTable(passStatus: passStatus, listingtableID: listingId, venueName: venueName, listingName: listingName, listingType: listingType, listingDescription: listingDescription, listingInstructions: listingInstructions, listingPrice: Double(listingPrice), listingStart: listingStart, listingEnd: listingEnd)
        passes.append(pass)
    }
    
    // Save all passes asynchronously
    await savePasses(passes: passes, completion: completion)
}

/// Recursively saves passes to the database.
/// - Parameters:
///   - passes: The passes to be saved.
///   - completion: The completion handler to call when all passes are saved or an error occurs.
private func savePasses(passes: [PassesTable], completion: @escaping (Result<Bool, Error>) -> Void) async {
    guard !passes.isEmpty else {
        completion(.success(true))
        return
    }
    
    var remainingPasses = passes
    let passToSave = remainingPasses.removeFirst()
    
    do {
        let savedPass = try await Amplify.DataStore.save(passToSave)
        print("Saved pass: \(savedPass)")
        await savePasses(passes: remainingPasses, completion: completion)
    } catch let error as DataStoreError {
        print("Error creating item: \(error)")
    } catch {
        print("Unexpected error: \(error)")
    }
    
}

func fetchCurrentUser() {
    do{
        let currentuser = try Amplify.Auth.getCurrentUser
    } catch {
        print("Unexpected error: \(error)")
    }
}



func fetchActiveLisitings(for venueID: String, completion: @escaping (Result<[ListingTable], Error>) -> Void) async {
    
    let predicate = ListingTable.keys.venuesID.eq(venueID).and(ListingTable.keys.isActive.eq(true))
    
    do {
        var listings = try await Amplify.DataStore.query(ListingTable.self, where: predicate)
        
        var validActiveListings: [ListingTable] = []
        let currentTime = Temporal.DateTime(Date())
        
        for var listing in listings {
            if listing.listingEnd > currentTime {
                validActiveListings.append(listing)
            } else {
                // If the listing's end time has passed, set it as inactive
                listing.isActive = false
                do{
                    try await Amplify.DataStore.save(listing)
                    print("Listing \(listing.id) updated to inactive.")
                } catch{
                    print("Failed to update listing \(listing.id): \(error)")
                }
            }
        }
        let listingArray = validActiveListings.map { listing in
            print(listing.listingName)
            return [listing.listingName, listing.venueName]
        }
    } catch {
        print("failure")
    }
}


func editListing(
    listing: ListingTable,
    newTotalPasses: Int,
    completion: @escaping (Result<Bool, Error>) -> Void
) async {
    do {
        // Step 1: Disable the listing
        var updatedListing = listing
        updatedListing.isActive = false
        
        // Save the disabled listing
        try await Amplify.DataStore.save(updatedListing)
        
        // Step 2: Calculate passes to add or remove
        let currentTotalPasses = listing.totalPasses
        let passesToModify = newTotalPasses - currentTotalPasses
        
        if passesToModify > 0 {
            // Add passes
            await createPassesForListing(
                listingId: listing.id,
                passCount: passesToModify,
                passStatus: .available, // Assuming new passes start as available
                venueName: listing.venueName,
                listingName: listing.listingName,
                listingType: listing.listingType,
                listingDescription: listing.description,
                listingInstructions: listing.instructions,
                listingPrice: Float(listing.listingPrice),
                listingStart: listing.listingStart,
                listingEnd: listing.listingEnd,
                completion: completion
            )
        } else if passesToModify < 0 {
            // Remove passes
            let passesToRemove = abs(passesToModify)
            let availablePasses = try await fetchAvailablePasses(for: listing.id)
            
            guard availablePasses.count >= passesToRemove else {
                completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Not enough available passes to remove."])))
                return
            }
            
            for i in 0..<passesToRemove {
                try await Amplify.DataStore.delete(availablePasses[i])
            }
        }
        
        // Step 3: Update the listing's totalPasses
        updatedListing.totalPasses = newTotalPasses
        try await Amplify.DataStore.save(updatedListing)
        
        // Step 4: Re-enable the listing
        updatedListing.isActive = true
        try await Amplify.DataStore.save(updatedListing)
        
        completion(.success(true))
        print("Listing updated successfully")
    } catch {
        print("Error updating listing: \(error)")
        completion(.failure(error))
    }
}

private func fetchAvailablePasses(for listingId: String) async throws -> [PassesTable] {
    let passes = try await Amplify.DataStore.query(PassesTable.self, where: PassesTable.keys.listingtableID.eq(listingId).and(PassesTable.keys.passStatus.eq(PassStatus.available)))
    return passes
}




