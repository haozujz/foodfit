//
//  TitledLineChart.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 29/1/2023.
//

import SwiftUI

// For IOS <16.0
struct TitledLineChart: View {
    let title: String
    let subtitle: String
    let values: [Int?]
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
            
            LineChart
                .foregroundColor(.black.opacity(0.6))
                .frame(width: 340, height: 200)
                .padding(.horizontal, 6)
                .clipped()
        }
        .background(Color.gray.opacity(0.2))
        .cornerRadius(16)
        .padding(.vertical)
    }
    
    private var LineChart: some View {
        ZStack {
            GeometryReader { proxy in
                let width = proxy.size.width
                let height = proxy.size.height
                
                let maxVal = ([CGFloat(values.compactMap{ $0 }.max() ?? 0), CGFloat(targetVal)].max() ?? 100) * 1.2
                let maxWidth = width - 20
                
                let points: [CGPoint] = values.enumerated().compactMap { i, val in
                    guard let val = val else { return nil }
                    
                    let x =  (CGFloat(i) / CGFloat(values.count - 1)) * maxWidth
                    let y = (CGFloat(val) / maxVal) * height
                    return CGPoint(x: x, y: -y + height)
                }

                var savedPt: CGPoint = .zero
                let controlPoints: [CGPoint] = points.enumerated().compactMap { i, pt in
                    let previousPt = savedPt
                    savedPt = pt
                    if i == 0 { return nil }
                    
                    return CGPoint.controlPointForPoints(p1: previousPt, p2: pt)
                }
                
                ZStack {
                    DashedLine()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .frame(height: 2)
                        .position(x: width / 2, y: (CGFloat(targetVal) / maxVal) * -height + height)
                    
                    Text("\(targetVal)")
                        .font(.system(size: 16))
                        .position(y: (CGFloat(targetVal) / maxVal) * -height + height - 12)
                        .padding(.leading, 18)
                    
                    Path { path in
                        path.move(to: .zero)
                        
//                        Chart with quad curves
                        points.enumerated().forEach { i, pt in
                            if i == 0 {
                                path.move(to: pt)
                            } else {
                                path.addQuadCurve(to: pt, control: controlPoints[i - 1])
                            }
                        }
                        
//                    Chart with straight lines
//                    path.addLines(points)
//                    path.move(to: CGPoint(x: points.last.x + 200, y: points.last.y))
                    }
                    .stroke(Color("accent3"), style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                    
                    Circle()
                        .fill(Color("accent3"))
                        .frame(width: 20, height: 20)
                        .position(x: points.last!.x, y: points.last!.y)
                }
            }
            
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
    
    private struct DashedLine: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            return path
        }
    }
}

struct TitledLineChart_Previews: PreviewProvider {
    static var previews: some View {
        TitledLineChart(title: "Active Calories", subtitle: "kcal", values: [120, 800, 30, nil, 251, 400, nil, nil, 100], targetVal: 600, startDate: "Jan 01", endDate: "Dec 12")
    }
}
