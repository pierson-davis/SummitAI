import SwiftUI

// MARK: - Design System Foundation
// Mountain Experiences Integration - Step 1: Design System & Color Tokens Implementation

struct DesignSystem {
    
    // MARK: - Spacing System (8-pt grid)
    struct Spacing {
        static let xs: CGFloat = 8      // 8pt
        static let sm: CGFloat = 16     // 16pt
        static let md: CGFloat = 24     // 24pt
        static let lg: CGFloat = 32     // 32pt
        static let xl: CGFloat = 40     // 40pt
        static let xxl: CGFloat = 48    // 48pt
        static let xxxl: CGFloat = 56   // 56pt
        static let huge: CGFloat = 64   // 64pt
    }
    
    // MARK: - Corner Radius System
    struct CornerRadius {
        static let small: CGFloat = 12   // For inputs/chips
        static let medium: CGFloat = 16  // For buttons
        static let large: CGFloat = 20   // For cards
        static let xl: CGFloat = 24      // For modals
    }
    
    // MARK: - Shadow System
    struct Shadow {
        static let elevation1 = Shadow(
            color: Color.black.opacity(0.1),
            radius: 2,
            x: 0,
            y: 1
        )
        
        static let elevation2 = Shadow(
            color: Color.black.opacity(0.15),
            radius: 4,
            x: 0,
            y: 2
        )
        
        static let elevation3 = Shadow(
            color: Color.black.opacity(0.2),
            radius: 8,
            x: 0,
            y: 4
        )
        
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - Color Tokens
extension Color {
    
    // MARK: - Surface Colors
    static let surface0 = Color(hex: "#0F1012")      // App background
    static let surfaceElev1 = Color(hex: "#15171A")  // Elevated surfaces
    static let surfaceElev2 = Color(hex: "#1B1E22")  // Higher elevation
    
    // MARK: - Text Colors
    static let textPrimary = Color(hex: "#DEDEDE")   // Primary text
    static let textSecondary = Color(hex: "#A5A5A6") // Secondary text
    static let textTertiary = Color(hex: "#717382")  // Tertiary text
    
    // MARK: - Border Colors
    static let borderMuted = Color(hex: "#5B5C5F")   // Hairlines/dividers
    
    // MARK: - Accent Colors
    static let accent600 = Color(hex: "#1B304B")     // Deep blue accent
    static let accent500 = Color(hex: "#35475E")     // Lighter accent
    
    // MARK: - Overlay Colors
    static let overlay60 = Color.black.opacity(0.60) // Overlays
    static let overlay30 = Color.black.opacity(0.30) // Light overlays
    static let overlay8 = Color.black.opacity(0.08)  // Press states
    
    // MARK: - Utility Colors
    static let white = Color.white
    static let black = Color.black
    
    // MARK: - Status Colors
    static let success = Color(hex: "#4CAF50")
    static let warning = Color(hex: "#FF9800")
    static let error = Color(hex: "#F44336")
    static let info = Color(hex: "#2196F3")
}

// MARK: - Typography System
struct Typography {
    
    // MARK: - Display Styles
    static let displayXL = Font.system(size: 34, weight: .bold, design: .default)
    static let displayL = Font.system(size: 32, weight: .bold, design: .default)
    
    // MARK: - Title Styles
    static let titleXL = Font.system(size: 30, weight: .semibold, design: .default)
    static let titleL = Font.system(size: 28, weight: .semibold, design: .default)
    static let titleM = Font.system(size: 24, weight: .semibold, design: .default)
    static let titleS = Font.system(size: 20, weight: .semibold, design: .default)
    
    // MARK: - Body Styles
    static let bodyL = Font.system(size: 18, weight: .regular, design: .default)
    static let bodyM = Font.system(size: 16, weight: .regular, design: .default)
    static let bodyS = Font.system(size: 14, weight: .regular, design: .default)
    
    // MARK: - Label Styles
    static let labelL = Font.system(size: 14, weight: .medium, design: .default)
    static let labelM = Font.system(size: 13, weight: .medium, design: .default)
    static let labelS = Font.system(size: 12, weight: .medium, design: .default)
    
    // MARK: - Caption Styles
    static let caption = Font.system(size: 11, weight: .regular, design: .default)
}

// MARK: - Line Height System
struct LineHeight {
    static let displayXL: CGFloat = 44
    static let displayL: CGFloat = 40
    static let titleXL: CGFloat = 38
    static let titleL: CGFloat = 34
    static let titleM: CGFloat = 30
    static let titleS: CGFloat = 26
    static let bodyL: CGFloat = 26
    static let bodyM: CGFloat = 24
    static let bodyS: CGFloat = 20
    static let labelL: CGFloat = 20
    static let labelM: CGFloat = 18
    static let labelS: CGFloat = 16
    static let caption: CGFloat = 14
}

// MARK: - Component Base Styles
struct ComponentStyles {
    
    // MARK: - Card Styles
    struct Card {
        static let background = Color.surfaceElev1
        static let cornerRadius = DesignSystem.CornerRadius.large
        static let shadow = DesignSystem.Shadow.elevation1
        static let padding = DesignSystem.Spacing.md
    }
    
    // MARK: - Input Styles
    struct Input {
        static let background = Color.surfaceElev1
        static let cornerRadius = DesignSystem.CornerRadius.small
        static let borderColor = Color.borderMuted
        static let borderWidth: CGFloat = 1
        static let height: CGFloat = 52
        static let padding = DesignSystem.Spacing.sm
    }
    
    // MARK: - Button Styles
    struct Button {
        static let primaryBackground = Color.accent600
        static let secondaryBackground = Color.surfaceElev2
        static let cornerRadius = DesignSystem.CornerRadius.medium
        static let height: CGFloat = 48
        static let padding = DesignSystem.Spacing.sm
    }
    
    // MARK: - Chip Styles
    struct Chip {
        static let background = Color.surfaceElev2
        static let selectedBackground = Color.accent600
        static let cornerRadius = DesignSystem.CornerRadius.small
        static let height: CGFloat = 32
        static let padding = DesignSystem.Spacing.sm
    }
    
    // MARK: - Press States
    struct PressState {
        static let overlay = Color.overlay8
        static let duration: Double = 0.1
    }
    
    // MARK: - Focus Rings
    struct FocusRing {
        static let color = Color.accent500
        static let width: CGFloat = 2
        static let offset: CGFloat = 2
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers for Design System
extension View {
    
    // MARK: - Card Modifier
    func cardStyle() -> some View {
        self
            .background(ComponentStyles.Card.background)
            .cornerRadius(ComponentStyles.Card.cornerRadius)
            .shadow(
                color: ComponentStyles.Card.shadow.color,
                radius: ComponentStyles.Card.shadow.radius,
                x: ComponentStyles.Card.shadow.x,
                y: ComponentStyles.Card.shadow.y
            )
            .padding(ComponentStyles.Card.padding)
    }
    
    // MARK: - Input Modifier
    func inputStyle() -> some View {
        self
            .frame(height: ComponentStyles.Input.height)
            .padding(.horizontal, ComponentStyles.Input.padding)
            .background(ComponentStyles.Input.background)
            .cornerRadius(ComponentStyles.Input.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: ComponentStyles.Input.cornerRadius)
                    .stroke(ComponentStyles.Input.borderColor, lineWidth: ComponentStyles.Input.borderWidth)
            )
    }
    
    // MARK: - Button Modifier
    func buttonStyle(isPrimary: Bool = true) -> some View {
        self
            .frame(height: ComponentStyles.Button.height)
            .padding(.horizontal, ComponentStyles.Button.padding)
            .background(isPrimary ? ComponentStyles.Button.primaryBackground : ComponentStyles.Button.secondaryBackground)
            .foregroundColor(.white)
            .cornerRadius(ComponentStyles.Button.cornerRadius)
    }
    
    // MARK: - Chip Modifier
    func chipStyle(isSelected: Bool = false) -> some View {
        self
            .frame(height: ComponentStyles.Chip.height)
            .padding(.horizontal, ComponentStyles.Chip.padding)
            .background(isSelected ? ComponentStyles.Chip.selectedBackground : ComponentStyles.Chip.background)
            .foregroundColor(isSelected ? .white : .textPrimary)
            .cornerRadius(ComponentStyles.Chip.cornerRadius)
    }
    
    // MARK: - Press State Modifier
    func pressState() -> some View {
        self
            .scaleEffect(1.0)
            .onTapGesture {
                withAnimation(.easeInOut(duration: ComponentStyles.PressState.duration)) {
                    // Add press state animation here if needed
                }
            }
    }
    
    // MARK: - Focus Ring Modifier
    func focusRing() -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: ComponentStyles.FocusRing.offset + ComponentStyles.Input.cornerRadius)
                    .stroke(ComponentStyles.FocusRing.color, lineWidth: ComponentStyles.FocusRing.width)
                    .offset(x: -ComponentStyles.FocusRing.offset, y: -ComponentStyles.FocusRing.offset)
                    .frame(
                        width: ComponentStyles.FocusRing.width * 2 + ComponentStyles.Input.cornerRadius * 2,
                        height: ComponentStyles.FocusRing.width * 2 + ComponentStyles.Input.cornerRadius * 2
                    )
            )
    }
}

// MARK: - Typography Modifiers
extension View {
    
    func displayXLStyle() -> some View {
        self
            .font(Typography.displayXL)
            .lineSpacing(LineHeight.displayXL - 34)
    }
    
    func titleLStyle() -> some View {
        self
            .font(Typography.titleL)
            .lineSpacing(LineHeight.titleL - 28)
    }
    
    func bodyMStyle() -> some View {
        self
            .font(Typography.bodyM)
            .lineSpacing(LineHeight.bodyM - 16)
    }
    
    func labelSStyle() -> some View {
        self
            .font(Typography.labelS)
            .lineSpacing(LineHeight.labelS - 12)
    }
}

// MARK: - Accessibility Modifiers
extension View {
    
    func accessibleTapTarget() -> some View {
        self
            .frame(minWidth: 44, minHeight: 44)
    }
    
    func accessibleText() -> some View {
        self
            .foregroundColor(.textPrimary)
            .accessibilityLabel(self)
    }
}

// MARK: - Design System Preview
struct DesignSystem_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            
            // Color Tokens Preview
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Color Tokens")
                    .titleLStyle()
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Rectangle()
                        .fill(Color.surface0)
                        .frame(width: 40, height: 40)
                        .cornerRadius(DesignSystem.CornerRadius.small)
                    
                    Rectangle()
                        .fill(Color.surfaceElev1)
                        .frame(width: 40, height: 40)
                        .cornerRadius(DesignSystem.CornerRadius.small)
                    
                    Rectangle()
                        .fill(Color.accent600)
                        .frame(width: 40, height: 40)
                        .cornerRadius(DesignSystem.CornerRadius.small)
                }
            }
            .cardStyle()
            
            // Typography Preview
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Typography")
                    .titleLStyle()
                    .foregroundColor(.textPrimary)
                
                Text("Display XL")
                    .displayXLStyle()
                    .foregroundColor(.textPrimary)
                
                Text("Title L")
                    .titleLStyle()
                    .foregroundColor(.textPrimary)
                
                Text("Body M")
                    .bodyMStyle()
                    .foregroundColor(.textSecondary)
                
                Text("Label S")
                    .labelSStyle()
                    .foregroundColor(.textTertiary)
            }
            .cardStyle()
            
            // Component Styles Preview
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Component Styles")
                    .titleLStyle()
                    .foregroundColor(.textPrimary)
                
                Button("Primary Button") {}
                    .buttonStyle(isPrimary: true)
                
                Button("Secondary Button") {}
                    .buttonStyle(isPrimary: false)
                
                HStack {
                    Text("Chip")
                        .chipStyle()
                    
                    Text("Selected Chip")
                        .chipStyle(isSelected: true)
                }
            }
            .cardStyle()
            
            Spacer()
        }
        .padding()
        .background(Color.surface0)
        .preferredColorScheme(.dark)
    }
}
