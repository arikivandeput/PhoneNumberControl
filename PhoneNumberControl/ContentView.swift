//
//  ContentView.swift
//  PhoneNumberControl
//
//  Created by Peter Put on 19/02/2024.
//  https://seald-apps.com 

import SwiftUI

struct ContentView: View {
    @State var country_code:String = "+1"
    @State var mobile:String = ""
    var body: some View {
        VStack {
           
            Text("Enter your phone number")
            PhoneNumberView(countryCode: $country_code, countryFlag: "🇺🇸", countryPattern: "### ### ####", countryLimit: 17,fullNumber:$mobile)
                .frame(height:47)
            Button("Show results in console") {
                print("country code: \(country_code)")
                print("mobile: \(mobile)")
            }
            
        }
        .onAppear(){
            //MARK: determine country code
            if UserDefaults.standard.string(forKey: "kCountyCode") != nil {
                let countries: [CPData] = Bundle.main.decode("CountryNumbers.json")
                let country = countries.filter({ $0.code ==    UserDefaults.standard.string(forKey: "kCountyCode")})
                if country.count != 0 {
                    self.country_code = country[0].dial_code
                } else {
                    self.country_code = "+1"
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
