//
//  SummaryView.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 29/1/2023.
//

import SwiftUI

struct SummaryView: View {
    @Binding var totalKcalEaten: Int
    @Binding var totalKcalBurned: Int
    @Binding var totalProtein: Int
    @Binding var totalCarbs: Int
    @Binding var totalFat: Int
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("\(totalKcalEaten)")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Eaten")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                CustomCircularProgressBar(val1: totalKcalBurned, val2: totalKcalEaten)
                    .padding()
                
                VStack {
                    Text("\(totalKcalBurned)")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Burned")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            
            HStack {
                VStack(spacing: 2.0) {
                    Text("Protein")
                        .font(.title3)
                        .fontWeight(.semibold)
                    CustomProgressBar(value: totalProtein, max: 120)
                    Text("\(totalProtein) / 120g")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                VStack(spacing: 2.0) {
                    Text("Carbs")
                        .font(.title3)
                        .fontWeight(.semibold)
                    CustomProgressBar(value: totalCarbs, max: 200)
                    Text("\(totalCarbs) / 200g")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                VStack(spacing: 2.0) {
                    Text("Fat")
                        .font(.title3)
                        .fontWeight(.semibold)
                    CustomProgressBar(value: totalFat, max: 40)
                    Text("\(totalFat) / 40g")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
        }
        .foregroundColor(.white)
        .padding(.vertical)
        .background(Color("accent3"))
        .cornerRadius(20.0)
    }
}

private struct CustomProgressBar: View {
    let progress: CGFloat
    
    init(value: Int, max: Int) {
        progress = (CGFloat(value) / CGFloat(max))
    }
    
    var body: some View {
        ZStack(alignment: . leading) {
            RoundedRectangle(cornerRadius: 4.0)
                .fill(.white.opacity(0.4))
            RoundedRectangle(cornerRadius: 4.0)
                .fill(progress > 1.0 ? .red : .white)
                .frame(width: progress * 100, height: 6.0)
        }
        .frame(width: 100.0, height: 6.0)
        .cornerRadius(4.0)
        .clipped()
        .padding(8.0)
    }
}

private struct CustomCircularProgressBar: View {
    let progress1: CGFloat
    let progress2: CGFloat
    let netKcal: Int
    
    init(val1: Int, val2: Int) {
        let total = CGFloat(val1 + val2)
        progress1 = CGFloat(val1) / total
        progress2 = CGFloat(val2) / total
        netKcal = val1 - val2
    }
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: progress1)
                .stroke(Color("accent2"), lineWidth: 8)
                .rotationEffect(.degrees(-90))
            Circle()
                .trim(from: 0, to: progress2)
                .stroke(Color.white, lineWidth: 8)
                .rotationEffect(.degrees(-90))
                .scaleEffect(CGSize(width: -1.0, height: 1.0))
            VStack {
                Text("\(netKcal)")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("Active Kcal")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
        }
        .frame(width: 132, height: 132)
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView(totalKcalEaten: .constant(20), totalKcalBurned: .constant(20), totalProtein: .constant(20), totalCarbs: .constant(20), totalFat: .constant(20))
    }
}
