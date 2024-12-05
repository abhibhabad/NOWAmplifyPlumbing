//
//  ContentView.swift
//  AmplifyPlumbing
//
//  Created by Abhi Bhabad on 4/24/24.
import SwiftUI
import Amplify
import AWSPluginsCore


struct ContentView: View {
    @State private var venueID: String = "6E9907ED-987D-4B08-B36E-D3D8125AF780"
    @State private var venueName: String = "Updated Venue Name"
    @State private var venuePhoneNumber: String = "8609788837"
    @State private var venueEmail: String = "beaudinjacob@gmail.com"
    @State private var venueImage: String = "https://example.com/venue-image.jpg"
    @State private var accountName: String = "Jake's Venmo"
    @State private var stringAccountNumber: String = "12345678"
    @State private var stringRoutingNumber: String = "987654321"
    @State private var stringEIN: String = "123456789"
    
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isSignedIn: Bool = false
    @State private var signInMessage: String = ""

    
    
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Listing Details")) {
                    TextField("Venue Name", text: $venueName)
                }
                
                Button("Update Venue") {
                    Task{
                        await updateVenueInformation()
                    }
                }
                
                Button("VENUES") {
                    Task {
                        try await fetchAllVenues()
                    }
                }
                Button("USERS") {
                    Task {
                        try await fetchUserInformation(for: "34FBA246-DBC3-4E07-8B8A-CA670B563B60")
                    }
                }
                Button("PASSES") {
                    Task {
                        try await fetchUserPasses(for: "8408c418-6051-7093-5d7e-bd3f974db8fd")
                    }
                }
                
                Button("PASSES") {
                    Task {
                        try await fetchPassInfo(for: "200EA13A-BF02-49EB-8A66-07E047FB182A")
                    }
                }
                
                
                Button("Redeem Pass") {
                    Task {
                        try await redeemPass(for: "84159F08-F109-4942-BD6E-15603A3B765F")
                    }
                }
                
                Button("Update User Info") {
                    Task {
                        try await updateUserInformation()
                    }
                }
                
                Button("Fetch venues") {
                    Task {
                        try await venueListings(for:"01BCC303-3B54-4190-A328-916F7E661B7C")
                    }
                }
                
                Button("Query Venue by Userid") {
                    Task {
                        try await fetchVenuesForUser(userID: "f4e8a468-4011-7050-ef47-96a9984c56f6")
                    }
                }
                
                Button("Fetch listings by venue") {
                    Task {
                        try await fetchListingsForVenue(venueID:"682C460D-3E8F-4A24-94F3-979780DE42A4")
                    }
                }
                
                Button("Fetch venue by venueid") {
                    Task {
                        try await fetchVenueByID(venueID:"682C460D-3E8F-4A24-94F3-979780DE42A4")
                    }
                }
                
                Button("Create user") {
                    Task {
                        do {
                            try await createUserEntry2(
                                userId: "TEST",
                                firstName: "TEST",
                                lastName: "TEST",
                                userEmail: "TEST",
                                userPhoneNumber: "TEST"
                            )
                        } catch {
                            print("Failed to create user:", error)
                        }
                    }
                }
                
                Button("Fetch listing and toggle") {
                    Task {
                       
                        try await deleteListing(id:  "8BA8B1E2-2AA5-45F9-9798-E5FCA74FA553")
                    }
                }
                
                Button("Invoke") {
                    Task {
                        await invokeCreateVenueLambda()
                    }
                }

                
                
            }
            
            VStack {
                
                Button(action: {
                    Task{
                        await fetchAnalytics()
                    }
                }) {
                    Text("Fetch Analytics")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            VStack {
                        if isSignedIn {
                            Text("Signed in successfully!")
                                .font(.headline)
                                .padding()

                            Text("Venue ID: \(venueID)")
                                .padding()

                            Button(action: {
                                Task {
                                    await logout()
                                }
                            }) {
                                Text("Log Out")
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        } else {
                            VStack {
                                TextField("Username", text: $username)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()

                                SecureField("Password", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()

                                Button(action: {
                                    Task {
                                        await signIn(username: username, password: password)
                                    }
                                }) {
                                    Text("Sign In")
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    Task{
                                        await logout()
                                    }
                                }) {
                                    Text("logout")
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }

                                Text(signInMessage)
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                    }
            
        }}
    
    func updateVenueInformation() async {
        do {
            // Fetch the venue from DataStore using the provided venueID
            let fetchedVenues = try await Amplify.DataStore.query(Venues.self, byId: venueID)
            
            if var venueToSave = fetchedVenues {
                
                // Update the venue properties with public variables
                venueToSave.venueName = venueName
                venueToSave.venuePhoneNumber = venuePhoneNumber
                venueToSave.venueEmail = venueEmail
                venueToSave.accountName = accountName
                venueToSave.accountNumber = Int(stringAccountNumber) ?? 0
                venueToSave.routingNumber = Int(stringRoutingNumber) ?? 0
                venueToSave.EIN = Int(stringEIN) ?? 0
                venueToSave.updatedAt = Temporal.DateTime(Date())
                
                // Save the updated venue back to DataStore
                do {
                    let savedVenue = try await Amplify.DataStore.save(venueToSave)
                    print("Venue updated successfully: \(savedVenue)")
                } catch {
                    print("Error saving venue: \(error)")
                }
            } else {
                print("Failed to fetch venue with ID: \(venueID)")
            }
        } catch {
            print("Error fetching venue: \(error)")
        }
    }

    func fetchAnalytics() async {
        let venueID = "6E9907ED-987D-4B08-B36E-D3D8125AF780"  // Replace with actual venueID
        let timeframe = "week" // Possible values: "day", "week", "month", "all"
        
        let jsonPayload: [String: Any] = ["venueID": venueID, "timeframe": timeframe]
        
        do {
            // Convert the payload to JSON data
            let jsonData = try JSONSerialization.data(withJSONObject: jsonPayload, options: [])
            
            // Create a REST request
            let request = RESTRequest(
                apiName: "SendVenueWelcomeEmailAPI",  // Ensure this matches the API name in amplifyconfiguration.json
                path: "/analytics/v1",  // Replace with the correct API path
                body: jsonData
            )
            
            // Make an asynchronous POST request using Amplify API
            let response = try await Amplify.API.post(request: request)
            
            // Parse the response data
            if let jsonString = String(data: response, encoding: .utf8) {
                print("Lambda function invoked successfully: \(jsonString)")
            } else {
                print("Failed to parse response.")
            }
            
        } catch let apiError as APIError {
            // Handle specific Amplify API errors
            print("API Error: \(apiError)")
            
        } catch let jsonError {
            // Handle JSON serialization errors
            print("Error serializing JSON payload: \(jsonError)")
            
        } catch {
            // Handle any other errors
            print("An unexpected error occurred: \(error)")
        }
    }
    
    struct PaymentIntentResponse: Codable {
        let clientSecret: String
    }
    
    struct LambdaResponse: Codable {
        let clientSecret: String?
        let error: String?
    }
    
    // Calls the lambda that generates a client secret which can be passed to the ApplePayModel
        func invokePaymentLambda(listingID: String, quantity: Int) async -> String? {
            let requestPayload: [String: Any] = [
                "listingId": listingID,
                "listingAmount": quantity
            ]

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: requestPayload, options: [])
                let response = try await Amplify.API.post(request: .init(path: "/stripeGetClientSecret/v1", body: jsonData))
                print(response)
                print("1")

                if let jsonString = String(data: response, encoding: .utf8) {
                    print("Lambda function invoked successfully: \(jsonString)")
                    print("2")

                    // Parse JSON response and extract "clientSecret"
                    if let data = jsonString.data(using: .utf8),
                       let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let clientSecret = json["clientSecret"] as? String {
                            print(clientSecret)
                            print("3")
                            return clientSecret  // Return the client secret
                    } else {
                        print("4")
                        print("Failed to extract clientSecret from JSON.")
                        return nil
                    }
                } else {
                    print("5")
                    print("Failed to parse response.")
                    return nil
                }
            } catch let apiError as APIError {
                // Handle Amplify API-specific errors
                switch apiError {
                case .httpStatusError(let statusCode, _):
                    // Print the status code only
                    if statusCode == 501 {
                        return "LISTINGEXPIRED"
                    } else if statusCode == 502 {
                        return "LISTINGINACTIVE"
                    } else {
                        return "UNKNOWN"
                    }
                default:
                    // If it's any other APIError case, print a generic message
                    return "API Error: \(apiError.errorDescription)"
                }
            } catch {
                print("6")
                print("Error invoking lambda: \(error.localizedDescription)")
                return nil
            }
        }

    
    
    
    func invokeLambda() async {
        // 1. Set up the request payload
        let requestPayload: [String: Any] = [
            "listingId": "B0C85BBD-7C19-4893-A931-2B0BE1309DE2",
            "listingAmount": 1
        ]
        
        // 2. Call the REST API using Amplify
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestPayload, options: [])
            let responseData = try await Amplify.API.post(request: .init(path: "/stripeGetClientSecret/v1", body: jsonData))
            
            
            if let jsonResponse = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                    
                    // Check if the response contains a client secret (successful response)
                
                    if let clientSecret = jsonResponse["clientSecret"] as? String {
                        print("Client secret: \(clientSecret)")
                    }
                    // Check if the response contains an error (error response)
                    else if let error = jsonResponse["error"] as? String {
                        print("Error from Lambda: \(error)")
                    } else {
                        print("Unexpected response format")
                    }
                } else {
                    print("Failed to decode response data as JSON")
                }
                
            } catch let apiError as APIError {
                // Handle Amplify API-specific errors
                switch apiError {
                case .httpStatusError(let statusCode, _):
                    // Print the status code only
                    print(statusCode)
                default:
                    // If it's any other APIError case, print a generic message
                    print("API Error: \(apiError.errorDescription)")
                }
            } catch {
                // Handle general errors
                print("Error during API request: \(error.localizedDescription)")
            }

        
    }
    
    
    
    func signIn(username: String, password: String) async {
            print("Attempting sign in...")
            do {
                let signInResult = try await Amplify.Auth.signIn(username: username, password: password)
                
                print(signInResult)
                
                if signInResult.isSignedIn {
                    print("Sign in succeeded")
                    
                } else {
                    // Check the next step in the authentication flow
                    switch signInResult.nextStep {
                    case .confirmSignInWithNewPassword:
                        print("User needs to set a new password")
                        // Navigate to ForceNewPassword view
                    default:
                        print("Unhandled next step: \(signInResult.nextStep)")
                    }
                }
            } catch let error as AuthError {
                print("Sign in failed \(error)")
            } catch {
                print("Unexpected error: \(error)")
            }
        }
    
    func logout() {
            Task {
                do {
                    try await Amplify.Auth.signOut()
                } catch {
                    print("Failed to logout", error)
                }
            }
        }
    
    func fetchAllVenues() async {
        do {
            let result = try await Amplify.API.query(request: .list(Venues.self))
            
            switch result {
            case .success(let venuesList):
                let venues = venuesList.elements// Extract the array of venues
                print("Fetched venues:", venues)
                // Now you can work with `venues`, which is an array of `Venues` objects

            case .failure(let error):
                print("Failed to fetch venues:", error)
            }
            
        } catch {
            print("An error occurred:", error.localizedDescription)
        }
    }
    
    func fetchUserInformation(for userID: String) async -> UserTable? {
        do {
            // Create a request for querying the UserTable with a specific userID predicate
            let request = GraphQLRequest<UserTable>.list(UserTable.self, where: UserTable.keys.id.eq(userID))
            
            let result = try await Amplify.API.query(request: request)
            
            switch result {
            case .success(let userList):
                // Extract the array of users and return the first matching user
                let users = userList.elements
                return users.first
                
            case .failure(let error):
                print("Failed to fetch user:", error)
                return nil
            }
            
        } catch {
            print("An error occurred:", error.localizedDescription)
            return nil
        }
    }
    
    func fetchUserPasses(for userID: String) async -> [PassesTable]? {
        do {
            // Create a request for querying PassesTable with specific predicates for userID and passStatus
            let request = GraphQLRequest<PassesTable>.list(
                PassesTable.self,
                where: PassesTable.keys.userID.eq(userID) &&
                       PassesTable.keys.passStatus.eq("PURCHASED")
            )
            
            let result = try await Amplify.API.query(request: request)
            
            switch result {
            case .success(let passesList):
                // Extract the array of passes and return it
                print("success")
                let passes = passesList.elements
                
                print(passes)
                return passes
                
            case .failure(let error):
                print("Failed to fetch passes:", error)
                return nil
            }
            
        } catch {
            print("An error occurred:", error.localizedDescription)
            return nil
        }
    }
    
    // Used to filter listings by 1 month date range so the view doesnt stutter from loading too many listings at once
        // Sets start of search range
    func getStartOfCurrentDay() throws -> Temporal.DateTime {
        // Get the beginning of the current day as a Date object
        let startOfDay = Calendar.current.startOfDay(for: Date())
        
        // Convert the Date object to an ISO 8601 string
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoString = formatter.string(from: startOfDay)
        
        // Convert the ISO 8601 string into a Temporal.DateTime (can throw an error)
        return try Temporal.DateTime(iso8601String: isoString)
    }

    // Sets end of search range
    func getEndOfDayOneMonthFromNow() throws -> Temporal.DateTime {
        // Get the current date and add 1 month to it
        guard let oneMonthFromNow = Calendar.current.date(byAdding: .month, value: 1, to: Date()) else {
            throw NSError(domain: "DateErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to calculate the date one month from now."])
        }
        
        // Get the end of the day (11:59:59 PM) for that date
        var components = Calendar.current.dateComponents([.year, .month, .day], from: oneMonthFromNow)
        components.hour = 23
        components.minute = 59
        components.second = 59
        guard let endOfDay = Calendar.current.date(from: components) else {
            throw NSError(domain: "DateErrorDomain", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to calculate the end of day."])
        }
        
        // Convert the end of the day to an ISO 8601 string
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoString = formatter.string(from: endOfDay)
        
        // Convert the ISO 8601 string into a Temporal.DateTime (can throw an error)
        return try Temporal.DateTime(iso8601String: isoString)
    }
    
    func venueListings(for venueID: String) async -> [ListingTable]? {
        do {
            
            // Declare the range variables as optionals
            var rangeStart: Temporal.DateTime?
            var rangeEnd: Temporal.DateTime?

            // Set start of query date range
            do {
                rangeStart = try getStartOfCurrentDay()
                print("Start of current day: \(String(describing: rangeStart))")
            } catch {
                print("Error calculating start of day: \(error.localizedDescription)")
                return nil // Exit early if there's an error
            }
            
            // Set end of query date range
            do {
                rangeEnd = try getEndOfDayOneMonthFromNow()
                print("End of the day one month from now: \(String(describing: rangeEnd))")
            } catch {
                print("Error calculating end of day: \(error.localizedDescription)")
                return nil // Exit early if there's an error
            }
            
            // Ensure that rangeStart and rangeEnd are not nil before creating the predicate
            guard let start = rangeStart, let end = rangeEnd else {
                print("Date range is invalid.")
                return nil
            }
            
            
            // Create a request for querying PassesTable with specific predicates for userID and passStatus
            let request = GraphQLRequest<ListingTable>.list(
                ListingTable.self,
                where: ListingTable.keys.venuesID.eq(venueID) &&
                ListingTable.keys.isActive.eq(true) &&
                ListingTable.keys.listingStart.between(start: start, end: end)
                
            )
            
            let result = try await Amplify.API.query(request: request)
            
            switch result {
            case .success(let passesList):
                // Extract the array of passes and return it
                print("success")
                let passes = passesList.elements
                
                print(passes)
                return passes
                
            case .failure(let error):
                print("Failed to fetch passes:", error)
                return nil
            }
            
        } catch {
            print("An error occurred:", error.localizedDescription)
            return nil
        }
    }
    
    func fetchPassInfo(for passID: String) async -> PassesTable? {
        do {
            // Create a request for querying PassesTable with a specific passID predicate
            let request = GraphQLRequest<PassesTable>.list(
                PassesTable.self,
                where: PassesTable.keys.id.eq(passID)
            )
            
            let result = try await Amplify.API.query(request: request)
            
            switch result {
            case .success(let passList):
                // Extract the array of passes and return the first matching pass
                print(passList.elements.first)
                return passList.elements.first
                
            case .failure(let error):
                print("Failed to fetch pass info:", error)
                return nil
            }
            
        } catch {
            print("An error occurred:", error.localizedDescription)
            return nil
        }
    }
    

    func redeemPass(for selectedPassID: String) async {
        do {
            // Step 1: Query the current _version of the pass
            let status = PassStatus.redeemed
            let query = """
            query GetPassVersion($id: ID!) {
              getPassesTable(id: $id) {
                id
                passStatus
                _version
              }
            }
            """
            let queryVariables: [String: Any] = ["id": selectedPassID]
            let queryRequest = GraphQLRequest<JSONValue>(document: query, variables: queryVariables, responseType: JSONValue.self)

            let queryResult = try await Amplify.API.query(request: queryRequest)
            
            var currentVersion: Int?
            switch queryResult {
            case .success(let data):
                if case let .object(fields) = data["getPassesTable"],
                   let version = fields["_version"]?.intValue {
                    currentVersion = version
                } else {
                    print("Failed to retrieve version.")
                    return
                }
            case .failure(let error):
                print("Error fetching current version:", error)
                return
            }
            
            // Ensure we have the current version
            guard let version = currentVersion else {
                print("No version found, cannot proceed with update.")
                return
            }

            // Step 2: Update the pass status with the correct _version
            let mutation = """
            mutation UpdatePassStatus($id: ID!, $passStatus: PassStatus!, $_version: Int!) {
              updatePassesTable(input: { id: $id, passStatus: $passStatus, _version: $_version }) {
                id
                passStatus
                _version
              }
            }
            """
            let mutationVariables: [String: Any] = ["id": selectedPassID, "passStatus": status.rawValue, "_version": version]
            let mutationRequest = GraphQLRequest<JSONValue>(document: mutation, variables: mutationVariables, responseType: JSONValue.self)

            let mutationResult = try await Amplify.API.mutate(request: mutationRequest)
            
            switch mutationResult {
            case .success(let data):
                print("Update response:", data)
            case .failure(let error):
                print("Error updating pass:", error)
            }
            
        } catch {
            print("An error occurred:", error.localizedDescription)
        }
    }
    
    let userID = "246834e8-6061-7001-64bc-ec3b1786a91e"
    let fullName = "NEW ANDY"
    let phoneNumber = "8608798849"
    let newImage = false
    let userImageKey = "public/C87F3A37-2CF2-4AB5-AD7F-FC44762A83FD.jpg"
    
    
    

    func updateUserInformation() async {
        do {
            // Step 1: Query the user to get the current _version and other data
            let query = """
            query GetUser($userId: String!) {
              listUserTables(filter: { userId: { eq: $userId } }) {
                items {
                  id
                  firstName
                  lastName
                  imageKey
                  _version
                }
              }
            }
            """
            let queryVariables: [String: Any] = ["userId": userID]
            let queryRequest = GraphQLRequest<JSONValue>(document: query, variables: queryVariables, responseType: JSONValue.self)

            let queryResult = try await Amplify.API.query(request: queryRequest)
            
            print(queryResult)
            
            var userID: String?
            var currentVersion: Int?
            
            switch queryResult {
            case .success(let data):
                if case let .object(root) = data["listUserTables"],
                   case let .array(items) = root["items"],
                   let firstUser = items.first,
                   case let .object(userFields) = firstUser,
                   let id = userFields["id"]?.stringValue,
                   let version = userFields["_version"]?.intValue {
                    userID = id
                    currentVersion = version
                } else {
                    print("Failed to retrieve user data.")
                    return
                }
            case .failure(let error):
                print("Error fetching user data:", error)
                return
            }

            // Ensure we have the user ID and version
            guard let id = userID, let version = currentVersion else {
                print("User not found or missing version, cannot proceed with update.")
                return
            }
            
            // Step 2: Split the full name into first and last names
            let components = fullName.split(separator: " ")
            let firstName = String(components.first ?? "")
            let lastName = components.dropFirst().joined(separator: " ")

            // Step 3: Update the user information with the correct _version
            let mutation = """
            mutation UpdateUser($id: ID!, $firstName: String!, $lastName: String!, $userPhoneNumber: String, $imageKey: String, $_version: Int!) {
              updateUserTable(input: { id: $id, firstName: $firstName, lastName: $lastName, userPhoneNumber: $userPhoneNumber, imageKey: $imageKey, _version: $_version }) {
                id
                firstName
                lastName
                userPhoneNumber
                imageKey
                _version
              }
            }
            """
            var mutationVariables: [String: Any] = [
                "id": id,
                "firstName": firstName,
                "lastName": lastName,
                "userPhoneNumber": phoneNumber,
                "_version": version
            ]
            
            if newImage {
                mutationVariables["imageUrl"] = userImageKey
            }
            
            let mutationRequest = GraphQLRequest<JSONValue>(document: mutation, variables: mutationVariables, responseType: JSONValue.self)

            let mutationResult = try await Amplify.API.mutate(request: mutationRequest)
            
            switch mutationResult {
            case .success(let data):
                print("User updated successfully:", data)
            case .failure(let error):
                print("Error updating user:", error)
            }
            
        } catch {
            print("An error occurred:", error.localizedDescription)
        }
    }
    

    func createUserEntry(
        userId: String,
        firstName: String?,
        lastName: String?,
        userEmail: String?,
        userPhoneNumber: String?
    ) async {
        // Construct the input dictionary directly for the mutation
        let input: [String: Any] = [
            "userId": userId,
            "firstName": firstName ?? "",
            "lastName": lastName ?? "",
            "userEmail": userEmail ?? "",
            "userPhoneNumber": userPhoneNumber ?? ""
        ]

        // Construct the GraphQL mutation request using JSONValue response type
        let request = GraphQLRequest<JSONValue>(
            document: """
            mutation CreateUser($input: CreateUserTableInput!) {
                createUserTable(input: $input) {
                    id
                    userId
                    firstName
                    lastName
                    userEmail
                    userPhoneNumber
                    createdAt
                    updatedAt
                }
            }
            """,
            variables: ["input": input],
            responseType: JSONValue.self
        )

        // Execute the mutation
        do {
            let result = try await Amplify.API.mutate(request: request)
            switch result {
            case .success(let jsonValue):
                print("User created successfully with response: \(jsonValue)")
            case .failure(let error):
                print("Failed to create user:", error)
            }
        } catch {
            print("Error performing mutation:", error.localizedDescription)
        }
    }
    
    
    func createUserEntry2(
        userId: String,
        firstName: String?,
        lastName: String?,
        userEmail: String?,
        userPhoneNumber: String?
    ) async {
        // Construct the input dictionary directly for the mutation
        var user = UserTable(
            userId: userId,
            firstName: firstName,
            lastName: lastName,
            userEmail: userEmail,
            userPhoneNumber: userPhoneNumber
        )
        
        do {
                let result = try await Amplify.API.mutate(request: .create(user))
                switch result {
                case .success(let todo):
                    print("Successfully created user: \(todo)")
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            } catch let error as APIError {
                print("Failed to create todo: ", error)
            } catch {
                print("Unexpected error: \(error)")
            }
    }
    
    func fetchVenuesForUser(userID: String) async -> [Venues]? {
        do {
            // Create a request for querying the VenuesTable with a predicate for `createdBy` field
            let predicate = Venues.keys.createdBy.eq(userID)
            let request = GraphQLRequest<Venues>.list(Venues.self, where: predicate)
            
            // Perform the query using Amplify API
            let result = try await Amplify.API.query(request: request)
            
            switch result {
            case .success(let venueList):
                // Extract the array of venues and return it
                let venues = venueList.elements
                print(venues)
                return venues
                
            case .failure(let error):
                print("Failed to fetch venues:", error)
                return nil
            }
            
        } catch {
            print("An error occurred:", error.localizedDescription)
            return nil
        }
    }
    
    func fetchListingsForVenue(venueID: String) async -> [ListingTable]? {
        do {
            // Create a request for querying the ListingTable by `venuesID`
            let predicate = ListingTable.keys.venuesID.eq(venueID)
            let request = GraphQLRequest<ListingTable>.list(ListingTable.self, where: predicate)
            
            // Perform the query using Amplify API
            let result = try await Amplify.API.query(request: request)
            
            switch result {
            case .success(let listingList):
                // Filter out listings where `deletedAt` is not nil
                let listings = listingList.elements.filter { $0.deletedAt == nil }
                print(listings.count)
                return listings
                
            case .failure(let error):
                print("Failed to fetch listings:", error)
                return nil
            }
            
        } catch {
            print("An error occurred:", error.localizedDescription)
            return nil
        }
    }
    

    func fetchVenueByID(venueID: String) async -> Venues? {
        do {
            // Create a request for querying the VenuesTable with a specific `venueID` predicate
            let predicate = Venues.keys.id.eq(venueID)
            let request = GraphQLRequest<Venues>.list(Venues.self, where: predicate)
            
            // Perform the query using Amplify API
            let result = try await Amplify.API.query(request: request)
            
            switch result {
            case .success(let venueList):
                // Extract the array of venues and return the first matching venue
                let venues = venueList.elements
                print(venues.first)
                return venues.first
                
            case .failure(let error):
                print("Failed to fetch venue:", error)
                return nil
            }
            
        } catch {
            print("An error occurred:", error.localizedDescription)
            return nil
        }
    }
    

    func fetchListingByID(listingID: String) async -> ListingTable? {
        do {
            // Create a request for querying the ListingTable with a specific `listingID` predicate
            let predicate = ListingTable.keys.id.eq(listingID)
            let request = GraphQLRequest<ListingTable>.list(ListingTable.self, where: predicate)
            
            // Perform the query using Amplify API
            let result = try await Amplify.API.query(request: request)
            
            switch result {
            case .success(let listingList):
                // Extract the array of listings and return the first matching listing
                let listings = listingList.elements
                return listings.first
                
            case .failure(let error):
                print("Failed to fetch listing:", error)
                return nil
            }
            
        } catch {
            print("An error occurred:", error.localizedDescription)
            return nil
        }
    }
    
    struct UpdateListingResponse: Codable {
        let id: String
        let isActive: Bool
    }
    
    
    private func toggleListingActive(for listingID: String) async {
        do {
            // Step 1: Query the current _version of the listing
            let query = """
            query GetListingVersion($id: ID!) {
              getListingTable(id: $id) {
                id
                isActive
                _version
              }
            }
            """
            let queryVariables: [String: Any] = ["id": listingID]
            let queryRequest = GraphQLRequest<JSONValue>(document: query, variables: queryVariables, responseType: JSONValue.self)

            let queryResult = try await Amplify.API.query(request: queryRequest)

            var currentVersion: Int?
            var isActive: Bool?

            switch queryResult {
            case .success(let data):
                if case let .object(fields) = data["getListingTable"] {
                    // Safely extract the _version
                    if let versionValue = fields["_version"], case let .number(version) = versionValue {
                        currentVersion = Int(version)
                    }
                    
                    // Safely extract isActive status
                    if let isActiveValue = fields["isActive"], case let .boolean(activeStatus) = isActiveValue {
                        isActive = activeStatus
                    }
                } else {
                    print("Failed to retrieve version or isActive status.")
                    return
                }
            case .failure(let error):
                print("Error fetching current version:", error)
                return
            }

            // Ensure we have the current version and isActive status
            guard let version = currentVersion, let currentIsActive = isActive else {
                print("No version or isActive status found, cannot proceed with update.")
                return
            }

            // Step 2: Toggle the isActive status and update the listing with the correct _version
            let updatedIsActive = !currentIsActive
            let mutation = """
            mutation UpdateListing($id: ID!, $isActive: Boolean!, $_version: Int!) {
              updateListingTable(input: { id: $id, isActive: $isActive, _version: $_version }) {
                id
                isActive
                _version
              }
            }
            """
            let mutationVariables: [String: Any] = [
                "id": listingID,
                "isActive": updatedIsActive,
                "_version": version
            ]
            let mutationRequest = GraphQLRequest<JSONValue>(document: mutation, variables: mutationVariables, responseType: JSONValue.self)

            let mutationResult = try await Amplify.API.mutate(request: mutationRequest)

            switch mutationResult {
            case .success(let data):
                print("Listing updated successfully:", data)
            case .failure(let error):
                print("Error updating listing:", error)
            }

        } catch {
            print("An error occurred:", error.localizedDescription)
        }
    }



    private func deleteListing(id: String) async -> Bool {
        do {
            // Step 1: Query the current _version of the listing
            let query = """
            query GetListingVersion($id: ID!) {
              getListingTable(id: $id) {
                id
                _version
              }
            }
            """
            let queryVariables: [String: Any] = ["id": id]
            let queryRequest = GraphQLRequest<JSONValue>(document: query, variables: queryVariables, responseType: JSONValue.self)

            let queryResult = try await Amplify.API.query(request: queryRequest)

            var currentVersion: Int?

            switch queryResult {
            case .success(let data):
                if case let .object(fields) = data["getListingTable"] {
                    // Safely extract the _version value
                    if let versionValue = fields["_version"], case let .number(version) = versionValue {
                        currentVersion = Int(version)
                    }
                } else {
                    print("Failed to retrieve version.")
                    return false
                }
            case .failure(let error):
                print("Error fetching current version:", error)
                return false
            }

            // Ensure we have the current version
            guard let version = currentVersion else {
                print("No version found, cannot proceed with delete.")
                return false
            }

            // Step 2: Update the `deletedAt` attribute and set `isActive` to false
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let currentDate = dateFormatter.string(from: Date())

            let mutation = """
            mutation UpdateListing($id: ID!, $deletedAt: AWSDateTime!, $isActive: Boolean!, $_version: Int!) {
              updateListingTable(input: { id: $id, deletedAt: $deletedAt, isActive: $isActive, _version: $_version }) {
                id
                deletedAt
                isActive
                _version
              }
            }
            """
            let mutationVariables: [String: Any] = [
                "id": id,
                "deletedAt": currentDate,
                "isActive": false,
                "_version": version
            ]
            let mutationRequest = GraphQLRequest<JSONValue>(document: mutation, variables: mutationVariables, responseType: JSONValue.self)

            let mutationResult = try await Amplify.API.mutate(request: mutationRequest)

            switch mutationResult {
            case .success(let data):
                print("Listing deleted successfully:", data)
                return true
            case .failure(let error):
                print("Error deleting listing:", error)
                return false
            }

        } catch {
            print("An error occurred:", error.localizedDescription)
            return false
        }
    }
    
    
    func editListingQuantity(listing: ListingTable, newTotalPasses: Int, completion: @escaping (Result<Bool, Error>) -> Void) async {
        do {
            // Step 1: Query the current _version of the listing
            let query = """
            query GetListingVersion($id: ID!) {
              getListingTable(id: $id) {
                id
                _version
                totalPasses
              }
            }
            """
            let queryVariables: [String: Any] = ["id": listing.id]
            let queryRequest = GraphQLRequest<JSONValue>(document: query, variables: queryVariables, responseType: JSONValue.self)

            let queryResult = try await Amplify.API.query(request: queryRequest)

            var currentVersion: Int?

            switch queryResult {
            case .success(let data):
                if case let .object(fields) = data["getListingTable"] {
                    // Safely extract the _version value
                    if let versionValue = fields["_version"], case let .number(version) = versionValue {
                        currentVersion = Int(version)
                    }
                } else {
                    print("Failed to retrieve version.")
                    completion(.failure(NSError(domain: "VersionError", code: -1, userInfo: nil)))
                    return
                }
            case .failure(let error):
                print("Error fetching current version:", error)
                completion(.failure(error))
                return
            }

            // Ensure we have the current version
            guard let version = currentVersion else {
                print("No version found, cannot proceed with update.")
                completion(.failure(NSError(domain: "VersionError", code: -1, userInfo: nil)))
                return
            }

            // Step 2: Update the totalPasses field with the correct _version
            let mutation = """
            mutation UpdateListing($id: ID!, $totalPasses: Int!, $_version: Int!) {
              updateListingTable(input: { id: $id, totalPasses: $totalPasses, _version: $_version }) {
                id
                totalPasses
                _version
              }
            }
            """
            let mutationVariables: [String: Any] = [
                "id": listing.id,
                "totalPasses": newTotalPasses,
                "_version": version
            ]
            let mutationRequest = GraphQLRequest<JSONValue>(document: mutation, variables: mutationVariables, responseType: JSONValue.self)

            let mutationResult = try await Amplify.API.mutate(request: mutationRequest)

            switch mutationResult {
            case .success:
                print("Listing updated successfully")
                completion(.success(true))
            case .failure(let error):
                print("Error updating listing:", error)
                completion(.failure(error))
            }

        } catch {
            print("An error occurred:", error.localizedDescription)
            completion(.failure(error))
        }
    }
    
    
    func invokeCreateVenueLambda() async {
        let path = "/createVenue"
        let request = RESTRequest(
            path: path,
            headers: [
                "Content-Type": "application/json"
            ],
            body: Data() // You can add a JSON body if needed
        )

        do {
            let response = try await Amplify.API.post(request: request)
            if let jsonString = String(data: response, encoding: .utf8) {
                print("Lambda response:", jsonString ?? "No response body")
            } else {
                print("No response body")
            }
        } catch {
            print("Failed to invoke Lambda:", error)
        }
    }


    
    


    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}

