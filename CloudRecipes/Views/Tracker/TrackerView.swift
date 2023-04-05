//
//  TrackerView.swift
//  scrap
//
//  Created by Joseph Zhu on 10/1/2023.
//

import SwiftUI

struct TrackerView: View {
    @EnvironmentObject private var recipesModel: RecipesModel
    @EnvironmentObject private var plansModel: PlansModel
    @EnvironmentObject private var trackerModel: TrackerModel
    
    @State private var selectedRange: SelectedRange = .oneWeek
    @State private var startDate: String = (Calendar.current.date(byAdding: .day, value: -6, to: Date.now) ?? Date.now).formatted(.dateTime.day().month())
    @State private var endDate: String = Date.now.formatted(.dateTime.day().month())
    
    enum SelectedRange: String, CaseIterable {
        case oneWeek = "1w"
        case oneMonth = "1m"
        case threeMonths = "3m"
        case sixMonths = "6m"
    }
    
    var arraySuffixAndLineWidth: (Int, CGFloat) {
        switch selectedRange {
        case .oneWeek: return (7, 8.0)
        case .oneMonth: return (getNumberOfDaysForLastMonth(), 7.0)
        case .threeMonths: return (92, 6.0)
        case .sixMonths: return (trackerModel.activeCaloriesValues.count, 5.0)
        }
    }
    
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color("accent3"))
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.white)], for: .selected)
    }
    
    var body: some View {
        ZStack {
            Color("bg")
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack {
                
                ScrollView(.vertical, showsIndicators: false) {
                    Spacer(minLength: 52)
                    
                    
//                    if #available(iOS 16, *) {
                    TitledLineChartNative(title: "Active Calories", subtitle: "kcal", values: trackerModel.activeCaloriesValues.suffix(arraySuffixAndLineWidth.0), lineWidth: arraySuffixAndLineWidth.1, targetVal: 600, startDate: startDate, endDate: endDate)
                        TitledLineChartNative(title: "Protein", subtitle: "g", values: trackerModel.proteinValues.suffix(arraySuffixAndLineWidth.0), lineWidth: arraySuffixAndLineWidth.1, targetVal: 120, startDate: startDate, endDate: endDate)
                        TitledLineChartNative(title: "Carbs", subtitle: "g", values: trackerModel.carbsValues.suffix(arraySuffixAndLineWidth.0), lineWidth: arraySuffixAndLineWidth.1, targetVal: 200, startDate: startDate, endDate: endDate)
                        TitledLineChartNative(title: "Fat", subtitle: "g", values: trackerModel.fatValues.suffix(arraySuffixAndLineWidth.0), lineWidth: arraySuffixAndLineWidth.1, targetVal: 40, startDate: startDate, endDate: endDate)
//                    } else {
//                        TitledLineChart(title: "Active Calories", subtitle: "kcal", values: [nil, 800, 30, nil, 251, 400, nil, nil, 100], targetVal: 600, startDate: startDate, endDate: endDate)
//                        TitledLineChart(title: "Protein", subtitle: "g", values: [20, nil, 60, nil, 300, 40, nil, 500], targetVal: 120, startDate: startDate, endDate: endDate)
//                        TitledLineChart(title: "Carbs", subtitle: "g", values: [220, nil, 50, 0, 40, 100], targetVal: 200, startDate: startDate, endDate: endDate)
//                        TitledLineChart(title: "Fat", subtitle: "g", values: [60, nil, 50, 0, 40, 60], targetVal: 40, startDate: startDate, endDate: endDate)
//                    }
                }
            }
            .padding(.horizontal)
            
            Picker("Choose time range", selection: $selectedRange) {
                ForEach(SelectedRange.allCases, id: \.self) { range in
                    Text(range.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 10)
            .padding(.horizontal)
            .onChange(of: selectedRange) { r in
                switch r {
                case .oneWeek:
                    guard let date = Calendar.current.date(byAdding: .day, value: -6, to: Date.now) else {return}
                    startDate = date.formatted(.dateTime.day().month())
                case .oneMonth:
                    guard var date = Calendar.current.date(byAdding: .month, value: -1, to: Date.now) else {return}
                    date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
                    startDate = date.formatted(.dateTime.day().month())
                case .threeMonths:
                    guard var date = Calendar.current.date(byAdding: .month, value: -3, to: Date.now) else {return}
                    date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
                    startDate = date.formatted(.dateTime.day().month())
                case .sixMonths:
                    guard var date = Calendar.current.date(byAdding: .month, value: -6, to: Date.now) else {return}
                    date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
                    startDate = date.formatted(.dateTime.day().month())
                }
            }
        }
        .onChange(of: [plansModel.updateCounter, recipesModel.updateCounter]) { _ in
            trackerModel.getValuesForGraph(plans: plansModel.plans, recipes: recipesModel.recipes)
        }
    }
    
    private func getNumberOfDaysForLastMonth() -> Int {
        if let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date.now) {
            let numberOfDays = Calendar.current.dateComponents([.day], from: oneMonthAgo, to: Date.now)
            return numberOfDays.day! + 1
        }
        return 30
    }
}

struct TrackerView_Previews: PreviewProvider {
    static var previews: some View {
        TrackerView()
    }
}
