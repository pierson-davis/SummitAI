import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var username = ""
    @State private var email = ""
    @State private var displayName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingSignIn = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "mountain.2.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Join SummitAI")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Start your expedition today")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Form
                    VStack(spacing: 16) {
                        CustomTextField(
                            title: "Username",
                            text: $username,
                            icon: "person"
                        )
                        
                        CustomTextField(
                            title: "Email",
                            text: $email,
                            icon: "envelope",
                            keyboardType: .emailAddress
                        )
                        
                        CustomTextField(
                            title: "Display Name",
                            text: $displayName,
                            icon: "person.circle"
                        )
                        
                        CustomSecureField(
                            title: "Password",
                            text: $password,
                            icon: "lock"
                        )
                        
                        CustomSecureField(
                            title: "Confirm Password",
                            text: $confirmPassword,
                            icon: "lock.fill"
                        )
                    }
                    .padding(.horizontal, 32)
                    
                    // Error message
                    if let errorMessage = userManager.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal, 32)
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        Button(action: signUp) {
                            HStack {
                                if userManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Create Account")
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.orange)
                            .cornerRadius(25)
                        }
                        .disabled(userManager.isLoading || !isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.6)
                        
                        // Social sign up buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                userManager.signInWithApple()
                            }) {
                                HStack {
                                    Image(systemName: "applelogo")
                                        .font(.title2)
                                    Text("Sign in with Apple")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.black)
                                .cornerRadius(25)
                            }
                            
                            Button(action: signUpWithGoogle) {
                                HStack {
                                    Image(systemName: "globe")
                                    Text("Continue with Google")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue)
                                .cornerRadius(25)
                            }
                        }
                        
                        Button(action: { showingSignIn = true }) {
                            Text("Already have an account? Sign In")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSignIn) {
            SignInView()
        }
        .onChange(of: userManager.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                dismiss()
            }
        }
    }
    
    private var isFormValid: Bool {
        !username.isEmpty &&
        !email.isEmpty &&
        !displayName.isEmpty &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    private func signUp() {
        userManager.signUp(
            username: username,
            email: email,
            displayName: displayName,
            password: password
        )
    }
    
    private func signUpWithApple() {
        userManager.signInWithApple()
    }
    
    private func signUpWithGoogle() {
        userManager.signInWithGoogle()
    }
}

struct SignInView: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "mountain.2.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Welcome Back")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Continue your expedition")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // Form
                    VStack(spacing: 16) {
                        CustomTextField(
                            title: "Email",
                            text: $email,
                            icon: "envelope",
                            keyboardType: .emailAddress
                        )
                        
                        CustomSecureField(
                            title: "Password",
                            text: $password,
                            icon: "lock"
                        )
                        
                        Button(action: {}) {
                            Text("Forgot Password?")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal, 32)
                    
                    // Error message
                    if let errorMessage = userManager.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal, 32)
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        Button(action: signIn) {
                            HStack {
                                if userManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Sign In")
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.orange)
                            .cornerRadius(25)
                        }
                        .disabled(userManager.isLoading || email.isEmpty || password.isEmpty)
                        .opacity((email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                        
                        // Social sign in buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                userManager.signInWithApple()
                            }) {
                                HStack {
                                    Image(systemName: "applelogo")
                                        .font(.title2)
                                    Text("Sign in with Apple")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.black)
                                .cornerRadius(25)
                            }
                            
                            Button(action: signInWithGoogle) {
                                HStack {
                                    Image(systemName: "globe")
                                    Text("Continue with Google")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue)
                                .cornerRadius(25)
                            }
                        }
                        
                        Button(action: { showingSignUp = true }) {
                            Text("Don't have an account? Sign Up")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
        }
        .onChange(of: userManager.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                dismiss()
            }
        }
    }
    
    private func signIn() {
        userManager.signIn(email: email, password: password)
    }
    
    private func signInWithApple() {
        userManager.signInWithApple()
    }
    
    private func signInWithGoogle() {
        userManager.signInWithGoogle()
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 20)
                
                TextField(title, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .keyboardType(keyboardType)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct CustomSecureField: View {
    let title: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 20)
                
                SecureField(title, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(UserManager())
}
