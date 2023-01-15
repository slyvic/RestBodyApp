//
//  ContentView.swift
//  RestBodyApp
//
//  Created by Putut Yusri Bahtiar on 15/01/23.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView{
                Form {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Mau bangun jam berapa ?")
                            .font(.headline)
                        
                        DatePicker("Enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Desired amount of sleep")
                            .font(.headline)
                        
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Daily Coffee")
                            .font(.headline)
                        
                        Stepper(coffeeAmount == 0 ? "0 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 0...20)
                    }
                }
                .navigationTitle("Rest Body")
                .toolbar{
                    Button("calculate", action: calculatedBedTime)
                }
                .alert(alertTitle, isPresented: $showingAlert) {
                    Button("OK"){}
                } message: {
                    Text(alertMessage)
                }
            }
        }
    func calculatedBedTime() {
        do{
            let config = MLModelConfiguration()
            let model = try restbody(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let predicition = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - predicition.actualSleep
            alertTitle = "Waktu tidur ideal anda.."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
