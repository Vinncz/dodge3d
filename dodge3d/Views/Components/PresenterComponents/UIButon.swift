/* Imported from https://github.com/Vinncz/swiftcn-ui */

import SwiftUI

struct UIButton <Content: View> : View {

    enum ButtonType {
        case primary
        case secondary
        case link
        case text
    }
    
    var action: () -> Void = {}
    var role: ButtonRole? = nil
    var image: String = ""
    public var isLoading: Bool = false
    var systemImage: String = "" 
    var size: Size = .normal
    var flex: Bool = false
    var color: Color? = nil
    var content: () -> Content?
    var type: ButtonType = .primary

    init (
        color: Color? = nil,
        flex: Bool = false,
        image: String = "",
        role: ButtonRole? = nil,
        size: Size = .normal,
        systemImage: String = "",
        type: ButtonType = .primary,
        @ViewBuilder content: @escaping () -> Content? = { Text("Button") }
    ) {        
        self.role = role
        self.action = {}
        self.image = image
        self.systemImage = systemImage
        self.size = size
        self.flex = flex
        self.color = color
        self.content = content
        self.type = type
    }
    
    init (
        color: Color? = nil,
        flex: Bool = false,
        image: String = "",
        role: ButtonRole? = nil,
        size: Size = .normal,
        systemImage: String = "",
        type: ButtonType = .primary,
        @ViewBuilder content: @escaping () -> Content? = { Text("Button") },
        action: @escaping () -> Void = {}
    ) {        
        self.role = role
        self.action = action
        self.image = image
        self.systemImage = systemImage
        self.size = size
        self.flex = flex
        self.color = color
        self.content = content
        self.type = type
    }

    var button: some View {
        Button (role: self.role) {
            action()
        } label: {
            HStack (
                spacing: self.size == .small ?
                            PaddingSizes.normal :
                            self.size == .normal ? 
                                PaddingSizes.normal : PaddingSizes.large
            ) {
                if ( !image.isEmpty ) {
                    Image(self.image)
                        .resizable()
                        .frame(
                            maxWidth: 32,
                            maxHeight: 32
                        )
                } else if ( !systemImage.isEmpty ) {
                    Image(systemName: self.systemImage)
                }
                
                content()
            }
                .padding(
                    .horizontal, 
                    self.size == .small ?
                        PaddingSizes.small :
                        self.size == .normal ? 
                            PaddingSizes.normal : PaddingSizes.large
                )
                .padding(
                    .vertical, 
                    self.size == .small ?
                        PaddingSizes.small :
                        self.size == .normal ? 
                            PaddingSizes.normal : PaddingSizes.large
                )
                .frame(
                    maxWidth: self.flex ? .infinity : nil
                )      
        }
        .tint(self.role == nil ? self.color : nil)
    }
    
    var body: some View {
//        Group {
            if ( self.isLoading ) {
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(
                            tint: .primary
                        )
                    )
                
            } else {
                if self.type == .primary {
                    button.buttonStyle(BorderedProminentButtonStyle())
                } else if ( self.type == .secondary ) {
                    button.buttonStyle(BorderedButtonStyle())
                } else if ( self.type == .text ) {
                    button.buttonStyle(PlainButtonStyle())
                } else if ( self.type == .link ) {
                    button
                }
                
            }
            
//        }
    }
}

#Preview {
    ScrollView {
        VStack (alignment: .leading) {
            Text("Buttons")
                .font(.system(size: 36))
                .bold()
                .padding(.top, 64)
            
            HStack {
                Text("Primary")
                
                Spacer()
                
//                Button("Tap me!", systemImage: "hand.tap.fill") {
//                    // things that'll run when pressed
//                }
//                    .padding()
//                    .background(
//                        Color.mint,
//                        in: RoundedRectangle(
//                            cornerSize: CGSize(width: 12, height: 12)
//                        )
//                    )
//                    .foregroundColor(.black)
//                    // don't forget custom color for dark/light mode!
//                
//                Spacer()
                
                
                UIButton (
                    systemImage: "hand.tap.fill"
                ) {
                    Text("Tap me!")
                        .bold()
                }
                
            }
            
            HStack {
                Text("Icon-only Primary")
                
                Spacer()
                
                UIButton (
                    systemImage: "hand.tap.fill"
                ) {} action: {
                    print("Hand was tapped!")
                }
                
            }
            
            HStack {
                Text("Secondary")
                
                Spacer()
                
                UIButton (
                    systemImage: "hand.tap.fill", 
                    type: .secondary
                ) {
                    Text("Tap me!")
                        .bold()
                } action: {
                    
                }
                
            }
            
            HStack {
                Text("Icon-only Secondary")
                
                Spacer()
                
                UIButton (
                    flex: false,
                    systemImage: "hand.tap.fill", 
                    type: .secondary
                ) {}
            }
            
            HStack {
                Text("Link")
                
                Spacer()
                
                UIButton (
                    systemImage: "hand.tap.fill", 
                    type: .link
                ) {
                    Text("Tap me!")
                        .bold()
                }
            }        
            
            HStack {
                Text("Icon-only Link")
                
                Spacer()
                
                UIButton (
                    systemImage: "hand.tap.fill", 
                    type: .link
                ) {}
            }
            
            HStack {
                Text("Text")
                
                Spacer()
                
                UIButton (
                    systemImage: "hand.tap.fill", 
                    type: .text
                ) {
                    Text("Tap me!")
                        .bold()
                }
            }     
            
            HStack {
                Text("Icon-only Text")
                
                Spacer()
                
                UIButton (
                    systemImage: "hand.tap.fill", 
                    type: .text
                ) {}
            }
            
            HStack {
//                Text("Colorful Button")
//                
//                Spacer()
                
                UIButton (
                    flex: true,
                    role: .destructive,
                    systemImage: "hand.tap.fill"
                ) {
                    Text("Tap me!")
                        .bold()
                }
                
            }
            
            HStack {
                Text("Large Button")
                
                Spacer()
                
                UIButton (
                    size: .large,
                    systemImage: "hand.tap.fill", 
                    type: .primary
                ) {
                    Text("Tap me!")
                        .bold()
                }
            }
            
            HStack {
                Text("Small Button")
                
                Spacer()
                
                UIButton (
                    size: .small,
                    systemImage: "hand.tap.fill", 
                    type: .primary
                ) {
                    Text("Tap me!")
                        .bold()
                }
            }
            
            HStack {
                Text("Primary with Role")
                
                Spacer()
                
                UIButton (
                    role: .destructive,
                    systemImage: "hand.tap.fill", 
                    type: .primary
                ) {
                    Text("Tap me!")
                        .bold()
                }
            }
            
            HStack {
                Text("Secondary with Role")
                
                Spacer()
                
                UIButton (
                    role: .destructive,
                    systemImage: "hand.tap.fill", 
                    type: .secondary
                ) {
                    Text("Tap me!")
                        .bold()
                }
            }      
            
            HStack {
                Text("Link with Role")
                
                Spacer()
                
                UIButton (
                    role: .destructive,
                    systemImage: "hand.tap.fill", 
                    type: .link
                ) {
                    Text("Tap me!")
                        .bold()
                }
            }
            
            HStack {
                Text("Image Primary")
                
                Spacer()
                
                UIButton (
                    image: "good boi", 
                    type: .primary
                ) {
                    Text("Tap me!")
                        .bold()
                }
            }            
            
            HStack {
                Text("Image Secondary")
                
                Spacer()
                
                UIButton (
                    image: "good boi", 
                    type: .secondary
                ) {
                    Text("Tap me!")
                        .bold()
                }
            }
            
            HStack {
                Text("Image Link")
                
                Spacer()
                
                UIButton (
                    image: "good boi", 
                    type: .link
                ) {
                    Text("Tap me!")
                        .bold()
                }
            }
            
            HStack {
                Text("Image Text")
                
                Spacer()
                
                UIButton (
                    image: "good boi", 
                    type: .text
                ) {
                    Text("Tap me!")
                        .bold()
                }
            }
            
        }
        .padding(.all, 24)
    }
}

//struct DefaultButtonStyle: ViewModifier {
//    @Environment(\.colorScheme) var colorScheme
//    
//    var baloon : Bool
//    
//    func body(content: Content) -> some View {
//        content
//            
//            .padding(.vertical, PaddingSizes.medium * 5)
//            .padding(.horizontal, PaddingSizes.medium * 2)
//            .frame(maxWidth: baloon ? .infinity : nil)
//            .clipShape(RoundedRectangle(cornerRadius: 99))
//    }
//}
//
//struct uiButton: View {
//    var label : String
//    var action: () -> Void = {}
//    var baloon: Bool = false
//
//    var body: some View {
//        Button ( action: action ) {
//            Text(label)
//        }
//            .buttonStyle(.borderedProminent)
//            .modifier(DefaultButtonStyle(baloon: baloon))
//    }
//}
//
//struct uiButton_Previews: PreviewProvider {
//    static var previews: some View {
//        HStack {
//            uiButton(
//                label: "Tweet"
//                ,action: { 
//                    print("I'm pushed!") 
//                }
//                ,baloon: true
//            )
//            Text("                                      ")
//        }
//    }
//}
//


