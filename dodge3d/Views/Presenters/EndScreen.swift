//
//  EndScreen.swift
//  dodge3d
//
//  Created by Nafis-Macbook on 28/04/24.
//

import SwiftUI

struct EndScreen: View {
    var highScore:Int = 20
    var recentScore:Int = 10
    
    var body: some View {
        ZStack {
            ContentManagement(
                manages: []
            )
            
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                Spacer(minLength: 150)
                
//                Button(action: {}){
//                    print("test")
//                }label: {
//                    Image("replay_button")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 250)
//                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                        .clipShape(RoundedRectangle(cornerRadius: 30))
//                }
                Button(action:{}) {
                    NavigationLink(destination: Canvas()) {
                        Image("replay_button")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    VStack{
                        // kalo di EndScreen ini buat ngeliat previous match score
                        Text("🔫:")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                        Text("\(recentScore)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(GameConfigs.neonBlue)
                    }
                    Spacer()
                    
                    VStack{
                        // kalo di EndScreen ini buat ngeliat previous match score
                        Text("🔝:")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                        Text("\(highScore)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(GameConfigs.neonPink)
                    }
                    Spacer()
                }
                .padding(.top)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    EndScreen()
}
