//
//  ContentView.swift
//  AmplifyPlumbing
//
//  Created by Abhi Bhabad on 4/24/24.
import SwiftUI
import Amplify

struct ContentView: View {
    @State private var listingName = ""
    @State private var listingType = "" // Example: "Concert", "Sports", etc.
    @State private var listingStart = Date()
    @State private var listingEnd = Date()
    @State private var totalPasses = ""
    @State private var description = ""
    @State private var instructions = "Show this pass to the doorman. Do not redeem prior to speaking with the doorman."
    @State private var listingPrice = Float()
    @State private var isActive = true
    
    @State private var resultMessage = ""
    
    @State private var listingIdToPurchase = ""
    @State private var userId = "beaudinjacob@gmail.com"
    
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var phonenumber: String = ""
    @State private var password: String = ""
    @State private var email: String = ""
    @State private var confirmationCode: String = ""
    @State private var message: String = ""
    @State private var needsConfirmation: Bool = false
    
    @State private var venueName: String = ""
    @State private var venueAddress: String = ""
    @State private var venuePhoneNumber: String = ""
    @State private var venueState: String = ""
    @State private var venueZip: Int = 0
    @State private var venueCity: String = ""
    @State private var venueHours: [Temporal.Time] = []
    @State private var venueImage: String = ""
    @State private var accountName: String = ""
    @State private var routingNumber: Int = 0
    @State private var EIN: Int = 0
    @State private var accountNumber: Int = 0
    @State private var ownerFirstName: String = ""
    @State private var ownerLastName: String = ""
    @State private var ownerPhoneNumber: String = ""
    @State private var ownerEmail: String = ""
    @State private var vmessage: String = ""
    
    @State private var passquery: String = ""
    
    @State private var passToRedeem: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Listing Details")) {
                    TextField("Listing Name", text: $listingName)
                    TextField("Listing Type", text: $listingType)
                    DatePicker("Start Date", selection: $listingStart, displayedComponents: .date)
                    DatePicker("End Date", selection: $listingEnd, displayedComponents: .date)
                    TextField("Total Passes", text: $totalPasses)
                    TextField("Description", text: $description)
                    Toggle("Is Active", isOn: $isActive)
                }
                
                Button("Create Listing with Passes") {
                    Task{
                        await createListingWithPasses()
                    }
                }
                .disabled(listingName.isEmpty || listingType.isEmpty || totalPasses.isEmpty)
                
                Section(header: Text("Purchase Pass")) {
                    TextField("Listing ID to Purchase", text: $listingIdToPurchase)
                    Button("Purchase Pass") {
                        Task {
                            await purchasePass()
                        }
                    }
                    .disabled(listingIdToPurchase.isEmpty)
                }
                
                Text(resultMessage)
                    .foregroundColor(.green)
            }
            
            Form {
                Section(header: Text("Sign Up")) {
                    TextField("Name", text: $name)
                    TextField("Username", text: $username)
                    TextField("Email", text: $email)
                    TextField("Phone", text: $phonenumber)
                    SecureField("Password", text: $password)
                    Button("Sign Up") {
                        signUp()
                    }
                }
                
                if needsConfirmation {
                    Section(header: Text("Confirm Sign Up")) {
                        TextField("Confirmation Code", text: $confirmationCode)
                        Button("Confirm") {
                            confirmSignUp()
                        }
                    }
                }
                
                Section(header: Text("Sign In")) {
                    TextField("Username", text: $username)
                    SecureField("Password", text: $password)
                    Button("Sign In") {
                        signIn()
                    }
                }
                
                Section {
                    Button("Sign Out") {
                        signOut()
                    }
                }
            }
            
            Form {
                Section(header: Text("Venue Information")) {
                    TextField("Venue Name", text: $venueName)
                    TextField("Venue Address", text: $venueAddress)
                    TextField("Venue City", text: $venueCity)
                    TextField("Venue State", text: $venueState)
                    TextField("Venue Phone Number", text: $venuePhoneNumber)
                    TextField("Venue Image URL", text: $venueImage)
                    TextField("Account Name", text: $accountName)
                    TextField("Routing Number", value: $routingNumber, formatter: NumberFormatter())
                    TextField("EIN", value: $EIN,  formatter: NumberFormatter())
                    TextField("Account Number", value: $accountNumber,  formatter: NumberFormatter())
                    TextField("Owner First Name", text: $ownerFirstName)
                    TextField("Owner Last Name", text: $ownerLastName)
                    TextField("Owner Phone Number", text: $ownerPhoneNumber)
                    TextField("Owner Email", text: $ownerEmail)
                }
                
                Button("Save Venue") {
                    Task {
                        await saveVenue()
                    }
                }
                
                Button("Query Venues") {
                    Task {
                        await fetchVenues()
                    }
                }
                
                
            }
            
            Form {
                Section(header: Text("Passes Querying")) {
                    TextField("UserID", text: $passquery)
                    TextField("passid to redeem", text: $passToRedeem)
                }
                
                Button("query passes") {
                    Task {
                        await fetchPasses(byUserId: passquery){ result in
                            switch result {
                            case .success(let passes):
                                print("Fetched Passes: \(passes)")
                            case .failure(let error):
                                print("Failed to fetch passes with error: \(error)")
                            }
                        }
                    }
                    
                    
                }
                
                Button("Query Venues") {
                    Task {
                        await fetchVenues()
                    }
                }
                
                Button("query listings") {
                    Task {
                        await fetchActiveLisitings(for: "43C22999-4712-458B-BC33-0BE6D545998A"){ result in
                            switch result {
                            case .success(let passes):
                                print("Fetched Passes: \(passes)")
                            case .failure(let error):
                                print("Failed to fetch passes with error: \(error)")
                            }
                        }
                    }
                    
                    
                }
                
                Button("redeem") {
                    
                    print("redeeming...")
                    Task {
                        try await redeemPass(passid: passToRedeem)
                    }
                }
                
            }
            
        }}
    
    private func createListingWithPasses() async {
        guard let totalPassesInt = Int(totalPasses), totalPassesInt > 0 else {
            resultMessage = "Invalid number of passes. Please enter a valid number."
            return
        }
        
        let newListing = ListingTable(
            id: UUID().uuidString,
            listingName: listingName,
            listingType: ListingType(rawValue: listingType) ?? .cover, // Assuming .other as default
            listingStart: Temporal.DateTime(listingStart),
            listingEnd: Temporal.DateTime(listingEnd),
            totalPasses: totalPassesInt,
            passesSold: 0, // Initial value
            instructions: instructions,
            description: description,
            createdAt: Temporal.DateTime(Date()),
            createdBy: "UserID", // Assuming a fixed user ID for simplicity
            venuesID: "43C22999-4712-458B-BC33-0BE6D545998A", //Hard coded venue id
            venueName: "Venue Name",
            isActive: isActive,
            listingPrice: 20.00
        )
        
        let passStatus = PassStatus.available // Assuming a predefined status
        await AmplifyPlumbing.createListingWithPasses(listing: newListing, passCount: totalPassesInt) { result in
            switch result {
            case .success(_):
                resultMessage = "Listing and passes successfully created."
            case .failure(let error):
                resultMessage = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func purchasePass() async {
        do {
            try await AmplifyPlumbing.purchasePass(listingId: listingIdToPurchase, userId: userId)
            DispatchQueue.main.async {
                resultMessage = "Pass successfully purchased."
            }
        } catch {
            DispatchQueue.main.async {
                resultMessage = "Failed to purchase pass: \(error.localizedDescription)"
            }
        }
    }
    
    func signUp() {
        AuthService.signUp(name: name, username: username, password: password, email: email, phone: phonenumber) { result in
            DispatchQueue.main.async {
                switch result {
                case "Confirm your email":
                    needsConfirmation = true
                default:
                    message = result
                }
            }
        }
    }
    
    func confirmSignUp() {
        AuthService.confirmSignUp(username: username, confirmationCode: confirmationCode) { result in
            DispatchQueue.main.async {
                message = result
                if result == "Email confirmation successful" {
                    needsConfirmation = false
                }
            }
        }
    }
    
    func signIn() {
        AuthService.signIn(username: username, password: password) { result in
            DispatchQueue.main.async {
                message = result
            }
        }
    }
    
    func signOut() {
        AuthService.signOut() { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    message = "Sign out successful"
                case .failure(let error):
                    message = "Sign out failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func saveVenue() async {
        let newVenue = Venues(
            venueName: venueName,
            venuePhoneNumber: venuePhoneNumber,
            venueHours: venueHours,
            venueImage: venueImage,
            accountName: accountName,
            routingNumber: routingNumber,
            EIN: EIN,
            accountNumber: accountNumber,
            ownerFirstName: ownerFirstName,
            ownerLastName: ownerLastName,
            ownerPhoneNumber: ownerPhoneNumber,
            ownerEmail: ownerEmail
        )
        
        await createVenue(venue: newVenue) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    message = "Venue saved successfully!"
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    message = "Failed to save venue: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func fetchVenues() async {
        do {
            let venues = try await Amplify.DataStore.query(Venues.self)
            // result will be of type [Post]
            
            let venuesArray = venues.map { venue in
                return (id: venue.id, name: venue.venueName, hours: venue.venueHours, imageUrl: venue.venueImage)
            }
            print("Venues: \(venuesArray)")
        } catch let error as DataStoreError {
            print("Error on query() for type Post - \(error)")
        } catch {
            print("Unexpected error \(error)")
        }
    }
    
    func fetchPasses(byUserId userId: String, completion: @escaping (Result<[[String]], Error>) -> Void) async {
        let predicate = PassesTable.keys.userID == userId
        
        do {
            var passes = try await Amplify.DataStore.query(PassesTable.self, where: predicate)
            // result will be of type [Post]
            
            //find expired passes
            var updatedPasses = await expirePasses(passesArray: passes)
            passes = updatedPasses
        
            let passesArray = passes.map { pass in
                return [pass.id, pass.listingtableID, pass.purchasedAt?.iso8601String, pass.passStatus, pass.venueName, pass.listingName, pass.listingType]
            }
            print("Passes: \(passesArray)")
        } catch let error as DataStoreError {
            print("Error on query() for type Passes - \(error)")
        } catch {
            print("Unexpected error \(error)")
        }
    }
    
    func expirePasses(passesArray: [PassesTable]) async -> [PassesTable] {
        let currentDateTime = Temporal.DateTime.now()
        var updatedPassesArray = passesArray
        
        for (index, pass) in passesArray.enumerated() {
            if pass.passStatus == .purchased && pass.listingEnd < currentDateTime {
                var updatedPass = pass
                updatedPass.passStatus = .expired
                
                do {
                    updatedPassesArray[index] = updatedPass
                    try await Amplify.DataStore.save(updatedPass)
                    print("Pass \(updatedPass.id) status updated to expired")
                } catch {
                    print("Failed to update pass \(updatedPass.id): \(error)")
                }
            }
        }
        
        return updatedPassesArray
        
        
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
