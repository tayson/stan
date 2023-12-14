//
//  CalendarView.swift
//  Stan
//
//  Created by Tayson Nguyen on 2023-12-14.
//

import SwiftUI

struct CalendarView: View {
    typealias SelectedDate = (Date) -> Void
    var selectedDate: SelectedDate?
    
    @Environment(\.dismiss) private var dismiss
    @State private var date: Date

    init(date: Date, selectedDate: SelectedDate? = nil) {
        self._date = State(wrappedValue: date)
        self.selectedDate = selectedDate
    }
    
    var body: some View {
        VStack {
            DatePicker("", selection: $date, in: ...Date.now, displayedComponents: [.date])
                .datePickerStyle(.graphical)
            
            Spacer()
            
            Button {
                selectedDate?(date)
                dismiss()
                
            } label: {
                Text("Submit")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
            
            Button("Cancel") {
                dismiss()
            }
        }
        .padding()
    }
}
