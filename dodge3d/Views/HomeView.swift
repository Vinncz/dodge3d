//
//  HomeView.swift
//  dodge3d
//
//  Created by Jonathan Aaron Wibawa on 27/04/24.
//

import SwiftUI

struct HomeView: View {
    
    var neonBlue: Color = Color(red: 0.38, green: 0.86, blue: 0.96)
    var neonPink: Color = Color(red: 1.0, green: 0.0, blue: 0.67)
    
    var body: some View {
        ZStack{
            Rectangle()
                .foregroundColor(.black.opacity(0.85))
                .ignoresSafeArea()
            
            VStack{
                Title(title1: "DODGE", title2: "3D", color1: neonBlue, color2: neonPink)
                
                Button{
                    print("test")
                }label: {
                    Image("play")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                        .padding(EdgeInsets(top: 70, leading: 0, bottom: 0, trailing: 0))
                }
                
                Spacer()
                
                VStack{
                    Text("Your Top Score:")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(neonBlue)
                    Text("20")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(neonPink)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    HomeView()
}

struct Title: View {
    
    var title1, title2: String
    var color1, color2: Color
    
    var body: some View {
        VStack {
            Text(title1)
                .foregroundColor(color1)
                .shadow(color: color1, radius: 15)
            Text(title2)
                .foregroundColor(color2)
                .shadow(color: color2, radius: 15)
        }
        .font(.system(size: 40))
        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
        .padding()
    }
}
