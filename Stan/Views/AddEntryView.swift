//
//  AddEntryView.swift
//  Stan
//
//  Created by Tayson Nguyen on 2023-12-13.
//

import SwiftUI

struct AddEntryView: View {
    @EnvironmentObject private var store: ModelStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var type: Transaction.Kind = .expense
    @State private var amount: Double = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Add Entry")
                    .fontWeight(.bold)
                    .padding()
                
                VStack(alignment: .leading) {
                    Text("Type")
                        .font(.footnote.bold())
                    
                    Menu {
                        Button {
                            type = .expense
                        } label: {
                            Text("Expense")
                        }
                        
                        Button {
                            type = .income
                        } label: {
                            Text("Income")
                        }
                    } label: {
                        HStack {
                            Text(type.rawValue.capitalized)
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .foregroundStyle(.gray)
                        .background(Color(white: 0.95))
                        .cornerRadius(10)
                    }
                }
                .padding(.bottom)
                
                VStack(alignment: .leading) {
                    Text("Amount")
                        .font(.footnote.bold())
                    
                    TextField("", value: $amount, format: .currency(code: "USD"))
                        .padding()
                        .foregroundStyle(.gray)
                        .background(Color(white: 0.95))
                        .cornerRadius(10)
                        .keyboardType(.decimalPad)
                }

                Spacer()
                
                Button {
                    Task {
                        try await store.add(transaction: Transaction(type: type, amount: amount))
                        dismiss()
                    }
                    
                } label: {
                    Text("Submit")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
                
                Button("Never Mind") {
                    dismiss()
                }
            }
            .padding()
        }
    }
}
