//
//  AuthModel.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 21/12/2022.
//

import Foundation
import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

final class AuthModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmationCode: String = ""
    @Published var signedInEmail: String = ""
    
    @Published var buttonTimer: Timer?
    @Published var buttonTimerCount: Int = 11
    
    enum confirmationCodeError: Error {
        case error(String)
    }
    
    func signUp() async {
        let emailAttribute = AuthUserAttribute(.email, value: email)
        let options = AuthSignUpRequest.Options(userAttributes: [emailAttribute])
        
        do {
            let result = try await Amplify.Auth.signUp(
                username: email,
                password: password,
                options: options
            )
            
            if case let .confirmUser(deliverDetails, _, userId) = result.nextStep {
                print("Delivery details \(String(describing: deliverDetails)) for userId: \(String(describing: userId))")
            } else {
                print("SignUp Complete")
            }
        } catch let error as AuthError {
            print("An error occurred while registering a user: \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func confirmSignUp() async throws {
        startButtonTimeOut()
        do {
            let result = try await Amplify.Auth.confirmSignUp(for: email, confirmationCode: confirmationCode)
            print("Confirm sign up result completed: \(result.isSignUpComplete)")
        } catch let error as AuthError {
            print("An error occurred while confirming sign up: \(error)")
            throw confirmationCodeError.error("An error occurred while confirming sign up: \(error)")
        } catch {
            print("Unexpected error: \(error)")
            throw confirmationCodeError.error("Unexpected error: \(error)")
        }
    }
    
    
    func startButtonTimeOut() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            
            self.buttonTimer  = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                self.buttonTimerCount -= 1
                if self.buttonTimerCount <= 0 {
                    self.buttonTimerCount = 11
                    timer.invalidate()
                }
            }
        }
    }
    
    func signIn() async throws {
        do {
            try await Amplify.DataStore.clear()
            let result = try await Amplify.Auth.signIn(
                username: email,
                password: password
            )
            if result.isSignedIn {
                print("Sign in succeeded")
                await checkStatus()
                
                DispatchQueue.main.async { [weak self] in
                    self?.password = ""
                    self?.confirmationCode = ""
                }
            }
        } catch let error as AuthError {
            print("Sign in failed: \(error)")
            throw confirmationCodeError.error("Sign in failed: \(error)")
        } catch {
            print("Unexpected error: \(error)")
            throw confirmationCodeError.error("Unexpected error: \(error)")
        }
    }
    
    func signOutLocally() async {
        do {
            try await Amplify.DataStore.clear()
        } catch {
            print("DataStore clear method error: \(error)")
        }
        
        let result = await Amplify.Auth.signOut()
        guard let signOutResult = result as? AWSCognitoSignOutResult
        else {
            print("Signout failed")
            return
        }

        print("Local signout successful: \(signOutResult.signedOutLocally)")
        switch signOutResult {
        case .complete:
            // Sign Out completed fully and without errors.
            print("Signed out successfully")

            DispatchQueue.main.async { [weak self] in
                self?.signedInEmail = ""
            }
        case let .partial(revokeTokenError, globalSignOutError, hostedUIError):
            // Sign Out completed with some errors. User is signed out of the device.
            
            if let hostedUIError = hostedUIError {
                print("HostedUI error  \(String(describing: hostedUIError))")
            }

            if let globalSignOutError = globalSignOutError {
                // Optional: Use escape hatch to retry revocation of globalSignOutError.accessToken.
                print("GlobalSignOut error  \(String(describing: globalSignOutError))")
            }

            if let revokeTokenError = revokeTokenError {
                // Optional: Use escape hatch to retry revocation of revokeTokenError.accessToken.
                print("Revoke token error  \(String(describing: revokeTokenError))")
            }

        case .failed(let error):
            // Sign Out failed with an exception, leaving the user signed in.
            print("SignOut failed with \(error)")
        }
    }
    
    func resetPassword(username: String) async {
        do {
            let resetResult = try await Amplify.Auth.resetPassword(for: username)
            switch resetResult.nextStep {
                case .confirmResetPasswordWithCode(let deliveryDetails, let info):
                    print("Confirm reset password with code send to - \(deliveryDetails) \(String(describing: info))")
                case .done:
                    print("Reset completed")
            }
        } catch let error as AuthError {
            print("Reset password failed with error \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func confirmResetPassword(
        username: String,
        newPassword: String,
        confirmationCode: String
    ) async throws {
        do {
            try await Amplify.Auth.confirmResetPassword(
                for: username,
                with: newPassword,
                confirmationCode: confirmationCode
            )
            print("Password reset confirmed")
        } catch let error as AuthError {
            print("Reset password failed with error \(error)")
            throw confirmationCodeError.error("Reset password failed with error \(error)")
        } catch {
            print("Unexpected error: \(error)")
            throw confirmationCodeError.error("Reset password failed with error \(error)")
        }
    }
    
    func checkStatus() async {
        do {
            let sessionResult = try await Amplify.Auth.fetchAuthSession()
            let userResult = try await Amplify.Auth.fetchUserAttributes()
            
            //print(sessionResult)
            print("Username:", userResult[2].value)
            
            DispatchQueue.main.async { [weak self] in
                self?.signedInEmail = sessionResult.isSignedIn ? userResult[2].value : ""
            }
        } catch let error as AuthError {
            print("Check failed: \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
}
