//
//  HomeView.swift
//  dodge3d
//
//  Created by Jonathan Aaron Wibawa on 27/04/24.
//

import SwiftUI

struct HomeView: View {
    var highScore:Int = 20
    
    var body: some View {
        ZStack{
            Rectangle()
                .foregroundColor(.black.opacity(0.4))
                .ignoresSafeArea()
            
            VStack{
//              Title(title1: "DODGE", title2: "3D", color1: neonPink, color2: neonPink)
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                Spacer()
                
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
                    // ini buat highest score achieved by the user
                    // gw mikirnya si pake SwiftData buat storenya
                    Text("🔝:")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    Text("\(highScore)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(GameConfigs.neonPink)
                }
                .padding(.top)
                
                
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
