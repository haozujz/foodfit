//
//  WaveHeader.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 8/1/2023.
//

import SwiftUI

struct WaveHeader: Shape {
    var yOffset: CGFloat = 0.5
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 20))
        path.addCurve(to: CGPoint(x: rect.minX, y: rect.maxY),
                      control1: CGPoint(x: rect.maxX * 0.75, y: rect.maxY * (1 - yOffset)),
                      control2: CGPoint(x: rect.maxX * 0.25, y: rect.maxY * (1 + yOffset)))
        path.closeSubpath()
        
        return path
    }
}
