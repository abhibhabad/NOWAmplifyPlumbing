import Foundation
import Amplify

struct AuthService {
    
    static func fetchCurrentUserAttributes(completion: @escaping (Result<[AuthUserAttribute], Error>) -> Void) {
            Task {
                do {
                    let attributes = try await Amplify.Auth.fetchUserAttributes()
                    completion(.success(attributes))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    
    static func signUp(name: String, username: String, password: String, email: String, phone: String, completion: @escaping (String) -> Void) {
        Task {
            do {
                let signUpResult = try await Amplify.Auth.signUp(username: username, password: password, options: .init(userAttributes: [AuthUserAttribute(.name, value: name), AuthUserAttribute(.email, value: email), AuthUserAttribute(.phoneNumber, value: phone)]))
                switch signUpResult.nextStep {
                case .done:
                    completion("Sign up complete")
                case .confirmUser:
                    completion("Confirm your email")
                }
            } catch {
                completion("Sign up failed: \(error.localizedDescription)")
            }
        }
    }
    
    static func signIn(username: String, password: String, completion: @escaping (String) -> Void) {
        Task {
            do {
                let signInResult = try await Amplify.Auth.signIn(username: username, password: password)
                if signInResult.isSignedIn {
                    completion("Sign in successful")
                } else {
                    completion("Sign in failed")
                }
            } catch {
                completion("Sign in failed: \(error.localizedDescription)")
            }
        }
    }
    
    static func confirmSignUp(username: String, confirmationCode: String, completion: @escaping (String) -> Void) {
        Task {
            do {
                let confirmSignUpResult = try await Amplify.Auth.confirmSignUp(for: username, confirmationCode: confirmationCode)
                if confirmSignUpResult.isSignUpComplete {
                    completion("Email confirmation successful")
                } else {
                    completion("Email confirmation failed")
                }
            } catch {
                completion("Email confirmation failed: \(error.localizedDescription)")
            }
        }
    }
    
    static func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
            Task {
                do {
                    try await Amplify.Auth.signOut()
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    
}
