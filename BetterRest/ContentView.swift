//
//  ContentView.swift
//  BetterRest
//
//  Created by Michel Henrique Hoekstra on 07/07/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    private static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }

    @State private var sleepAmount = 4.0
    @State private var wakeUpDate = defaultWakeTime
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            Form {
                VStack(spacing: 15) {
                    Text("When do you want to wake up?")
                        .font(.headline)

                    DatePicker("Please enter a time", selection: $wakeUpDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()

                    Text("Desired amount of sleep")
                        .font(.headline)

                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    Text("Daily coffee intake")
                        .font(.headline)

                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                }
                .padding()
            }
            .navigationTitle("BetterRest")
            .toolbar(content: {
                Button("Calculate", action: calculateBedtime)
            })
        }
        .alert(alertTitle, isPresented: $showingAlert, actions: {}, message: { Text(alertMessage) })
    }

    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: wakeUpDate)
            let hours = (dateComponents.hour ?? 0) * 60 * 60
            let minutes = (dateComponents.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hours + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))

            let sleepTime = wakeUpDate - prediction.actualSleep

            alertTitle = "Your ideal bedtime is…"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            showingAlert = true
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            showingAlert = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
