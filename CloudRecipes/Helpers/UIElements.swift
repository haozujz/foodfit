//
//  UIElements.swift
//  scrap
//
//  Created by Joseph Zhu on 8/1/2023.
//

import SwiftUI
import UIKit

struct FlatLinkStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct CustomTextField: View {
    @Binding var value: String
    let placeholder: String
    let isSecure: Bool
    let imageName: String
    let color: String
    let opacity: CGFloat

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width:20, height: 20)
                    .foregroundColor(Color(color)).opacity(opacity)
                    .font(.system(size:20, weight: .semibold))
                
                if isSecure {
                    SecureField(placeholder, text: $value)
                        .padding(.leading, 12)
                        .font(.system(size:20, weight: .semibold))
                        .frame(height: 45)
                        .foregroundColor(Color(color))
                        .disableAutocorrection(true)
                } else {
                    TextField(placeholder, text: $value)
                        .padding(.leading, 12)
                        .font(.system(size:20, weight: .semibold))
                        .frame(height: 45)
                        .foregroundColor(Color(color))
                        .disableAutocorrection(true)
                }
            }
            
            Divider()
                .frame(height: 1.2)
                .background(Color(color))
        }
    }
}

struct CustomTextField2: View {
    @Binding var value: String
    let placeholder: String
    
    var body: some View {
        TextField(placeholder, text: $value)
            .font(.title3)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .frame(height: 38)
            .background(.white)
            .cornerRadius(16)
            .shadow(radius: 3)
    }
}

struct CustomNumberField: View {
    @Binding var value: Int
    let units: String?
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField("", value: $value, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .font(.title3)
                .padding()
                .frame(width: 100)
                .frame(height: 38)
                .background(.white)
                .cornerRadius(12)
                .shadow(radius: 3)
            
            Text(units ?? "")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.trailing, 6)
                .padding(.top, 2)
        }
    }
}

struct CustomButtonLabel: View {
    let text: String
    let textColor: String
    let bgColor: String
    
    var body: some View {
        Text(text)
            .fontWeight(.bold)
            .foregroundColor(Color(textColor))
            .frame(height: 58)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(Color(bgColor))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.gray, lineWidth: 2)
            )
    }
}

struct LabelledDivider: View {
    let label: String
    let color: String
    
    var body: some View {
        HStack {
            line.padding(.trailing, 20)
            Text(label).foregroundColor(Color(color)).lineLimit(1).fixedSize().padding(.bottom, 5)
            line.padding(.leading, 20)
        }
        
    }
    
    var line: some View {
        VStack {
            Divider().background(Color(color))
        }
    }
}
