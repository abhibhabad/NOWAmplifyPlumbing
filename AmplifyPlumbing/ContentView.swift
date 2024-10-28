//
//  ContentView.swift
//  AmplifyPlumbing
//
//  Created by Abhi Bhabad on 4/24/24.
import SwiftUI
import Amplify

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
                
                Button("BANG") {
                    Task{
                        //await invokeLambda()
                        print(await invokePaymentLambda(listingID: "A633B1C5-2A91-4FE2-808E-A89D6CE77A1C", quantity: 1))
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

    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
