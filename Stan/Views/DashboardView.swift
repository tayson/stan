//
//  DashboardView.swift
//  Stan
//
//  Created by Tayson Nguyen on 2023-12-13.
//

import SwiftUI
import Charts

struct DashboardView: View {
    enum Modal: Hashable, Identifiable {
        case addEntry
        case changeStartDate(Date)
        case changeEndDate(Date)
        var id: Self { self }
    }
    @StateObject private var navigation = Navigation<Never, Modal>()
    
    @EnvironmentObject private var store: ModelStore
    
    @State private var startDate: Date
    @State private var endDate: Date
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    init() {
        let now = Date()
        self._endDate = State(wrappedValue: now)
        
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)!
        self._startDate = State(wrappedValue: monthAgo)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    Button {
                        navigation.modal = .changeStartDate(startDate)
                    } label: {
                        Text(startDate, formatter: dateFormatter)
                            .frame(maxWidth: .infinity)
                    }
                    
                    Image(systemName: "arrow.forward")
                        .padding(.horizontal, 5)

                    Button {
                        navigation.modal = .changeEndDate(endDate)
                    } label: {
                        Text(endDate, formatter: dateFormatter)
                            .frame(maxWidth: .infinity)
                    }
                }
                .font(.footnote)
                .buttonStyle(.bordered)
                .padding()
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Balance")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        let amount = NSNumber(value: store.balance(startDate: startDate, endDate: endDate))
                        Text("\(amount, formatter: currencyFormatter)")
                            .fontWeight(.bold)
                        
                        Chart(store.transactions(startDate: startDate, endDate: endDate), id: \.self) {
                            BarMark(x: .value("Date", $0.day), y: .value("Amount", $0.amount))
                                .foregroundStyle(.blue)
                        }
                    }
                    .frame(height: 200)
                    .padding()
                }
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
                .padding()
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Income")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        let amount = NSNumber(value: store.income(startDate: startDate, endDate: endDate))
                        Text("\(amount, formatter: currencyFormatter)")
                            .fontWeight(.bold)
                        
                        Chart(store.transactions(startDate: startDate, endDate: endDate, type: .income), id: \.self) {
                            BarMark(x: .value("Date", $0.day), y: .value("Amount", $0.amount))
                                .foregroundStyle(.pink)
                        }
                    }
                    .frame(height: 200)
                    .padding()
                }
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
                .padding()
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Expenses")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        let amount = NSNumber(value: store.expenses(startDate: startDate, endDate: endDate))
                        Text("\(amount, formatter: currencyFormatter)")
                            .fontWeight(.bold)
                        
                        Chart(store.transactions(startDate: startDate, endDate: endDate, type: .expense), id: \.self) {
                            BarMark(x: .value("Date", $0.day), y: .value("Amount", $0.amount))
                                .foregroundStyle(.yellow)
                        }
                    }
                    .frame(height: 200)
                    .padding()
                }
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
                .padding()
                
            }
            .navigationTitle("Dashboard")
            .overlay(alignment: .bottomTrailing) {
                Button {
                    navigation.modal = .addEntry
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                }
                .padding()
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
            }
            .task {
                if store.transactions.isEmpty {
                    do {
                        try await store.refreshTransactions()
                    } catch {
                        print(error)
                    }
                }
            }
            .onChange(of: store.transactions.count) { _ in
                // change endDate or you won't see newly added entry 
                endDate = Date()
            }
            .sheet(item: $navigation.modal) {
                switch $0 {
                case .addEntry:
                    AddEntryView()
                        .presentationDetents([.medium])
                case let .changeStartDate(date):
                    CalendarView(date: date, selectedDate: { startDate = $0 })
                        .presentationDetents([.medium])
                case let .changeEndDate(date):
                    CalendarView(date: date, selectedDate: { endDate = $0 })
                        .presentationDetents([.medium])
                }
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(ModelStore())
    }
}
