//
//  TitledLineChartV2.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 31/1/2023.
//

import SwiftUI
import Charts

struct TitledLineChartNative: View {
    let title: String
    let subtitle: String
    let values: [Int]
    let lineWidth: CGFloat
    let targetVal: Int
    let startDate: String
    let endDate: String
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.title3)
                    .opacity(0.6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 12)
            .padding(.top, 12)
            
            
            ZStack {
                Chart {
                    ForEach(Array(zip(values.indices, values)), id: \.0) { i, v in
                        LineMark(
                            x: .value("", i),
                            y: .value("", v)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color("accent3"))
                        .lineStyle(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                        .symbol() {
                            if i == values.count - 1 {
                                Circle()
                                    .fill(Color("accent3"))
                                    .frame(width: lineWidth * 20.0 / 8.0, height: lineWidth * 20.0 / 8.0)
                            }
                        }
                    }
                    
                    RuleMark(
                        y: .value("T", targetVal)
                    )
                    .foregroundStyle(.black.opacity(0.6))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .annotation {
                        Text("\(targetVal)")
                            .foregroundStyle(.black.opacity(0.6))
                            .font(.system(size: 16))
                            .padding(.trailing, 300)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(width: 340, height: 200)
                .padding(.horizontal, 6)
                
                LineChart
                    .foregroundColor(.black.opacity(0.6))
                    .frame(width: 340, height: 200)
                    .padding(.horizontal, 6)
                    .clipped()
            }
        }
        .background(Color.gray.opacity(0.2))
        .cornerRadius(16)
        .padding(.vertical)
    }
    
    private var LineChart: some View {
        ZStack {
            HStack {
                Text("\(startDate)")
                    .padding(.leading, 4)
                Spacer()
                Text("\(endDate)")
                    .padding(.trailing, 4)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 8)
        }
    }
}

//struct TitledLineChartNative_Previews: PreviewProvider {
//    static var previews: some View {
//        TitledLineChartNative()
//    }
//}
