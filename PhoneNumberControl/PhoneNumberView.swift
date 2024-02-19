//
//  PhoneNumberView.swift
//  https://seald-apps.com 

import Foundation
import SwiftUI
import Combine
extension Bundle {
	func decode<T: Decodable>(_ file: String) -> T {
		guard let url = self.url(forResource: file, withExtension: nil) else {
			fatalError("Failed to locate \(file) in bundle.")
		}
		guard let data = try? Data(contentsOf: url) else {
			fatalError("Failed to load \(file) from bundle.")
		}
		let decoder = JSONDecoder()
		guard let loaded = try? decoder.decode(T.self, from: data) else {
			fatalError("Failed to decode \(file) from bundle.")
		}
		return loaded
	}
}
struct CPData: Codable, Identifiable {
	let id: String
	let name: String
	let flag: String
	let code: String
	let dial_code: String
	let pattern: String
	let limit: Int
	
	static let allCountry: [CPData] = Bundle.main.decode("CountryNumbers.json")
	
}
struct PhoneNumberView: View {
	@State var presentSheet = false
	@Binding var countryCode:String
	@State var countryFlag : String = "🇺🇸"
	@State var countryPattern : String = "### ### ####"
	@State var countryLimit : Int = 17
	@State var mobPhoneNumber:String = ""

	@Binding var fullNumber:String
	@State private var searchCountry: String = ""
	@Environment(\.colorScheme) var colorScheme
	@FocusState private var keyIsFocused: Bool
	
	let countries: [CPData] = Bundle.main.decode("CountryNumbers.json")
	
	func extractCountryCode(from number: String) -> String? {
		let knownCountryCodes =  countries.map { $0.dial_code }
		for countryCode in knownCountryCodes.sorted(by: { $0.count > $1.count }) {
			if number.hasPrefix(countryCode) {
				return countryCode
			}
		}
		return nil
	}
	
	func setAllProperties(){
	 
		if countryCode == "00"{
			let detectedCountryCode = extractCountryCode(from: fullNumber)
			if detectedCountryCode != nil {
				countryCode = detectedCountryCode!
			}
		}
		let country  = countries.filter({ $0.dial_code == countryCode})
		if country.count != 0 {
			mobPhoneNumber = fullNumber.replacingOccurrences(of: countryCode, with: "")
			countryFlag = country[0].flag
			countryPattern = country[0].pattern
			countryLimit = country[0].limit
		}
	}
	
	var body: some View {
		GeometryReader { geo in
			VStack {
				HStack {
					Button {
						presentSheet = true
						keyIsFocused = false
					} label: {
						Text("\(countryFlag) \(countryCode)")
							.padding(10)
							.frame(minWidth: 80, minHeight: 47)
							.background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
							.foregroundColor(foregroundColor)
					}
					
					TextField("", text: $mobPhoneNumber)
						.placeholder(when: mobPhoneNumber.isEmpty) {
							Text(LocalizedStringKey("mobile"))
								.foregroundColor(.secondary)
						}
						.focused($keyIsFocused)
						.keyboardType(.phonePad)
						.onReceive(Just(mobPhoneNumber)) { _ in
							if mobPhoneNumber.hasPrefix("0") {
								mobPhoneNumber.removeFirst()
							}
							applyPatternOnNumbers(&mobPhoneNumber, pattern: countryPattern, replacementCharacter: "#")
							let trimmed =   mobPhoneNumber.replacingOccurrences(of: " ", with: "")
							fullNumber = (countryCode + trimmed )
							
						}
						.padding(10)
						.frame(minWidth: 80, minHeight: 47)
						.background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
				}
			}
			.onAppear(){
				setAllProperties()
			}
			.animation(.easeInOut(duration: 0.6), value: keyIsFocused)
			.padding(.horizontal)
			.sheet(isPresented: $presentSheet) {
				NavigationView {
					List(filteredResorts) { country in
						HStack {
							Text(country.flag)
							Text(country.name)
								.font(.headline)
							Spacer()
							Text(country.dial_code)
								.foregroundColor(.secondary)
						}
						.onTapGesture {
							self.countryFlag = country.flag
							self.countryCode = country.dial_code
							self.countryPattern = country.pattern
							self.countryLimit = country.limit
							presentSheet = false
							searchCountry = ""
						}
					}
					.listStyle(.plain)
					.searchable(text: $searchCountry, prompt: String(localized:"country"))
				}
				.presentationDetents([.medium, .large])
			}
			.presentationDetents([.medium, .large])
		}
	}
	
	var filteredResorts: [CPData] {
		if searchCountry.isEmpty {
			return countries
		} else {
			return countries.filter { $0.name.contains(searchCountry) }
		}
	}
	
	var foregroundColor: Color {
		if colorScheme == .dark {
			return Color(.white)
		} else {
			return Color(.black)
		}
	}
	
	var backgroundColor: Color {
		if colorScheme == .dark {
			return Color(.systemGray5)
		} else {
			return Color(.systemGray6)
		}
	}
	
	func applyPatternOnNumbers(_ stringvar: inout String, pattern: String, replacementCharacter: Character) {
		var pureNumber = stringvar.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
		for index in 0 ..< pattern.count {
			guard index < pureNumber.count else {
				stringvar = pureNumber
				return
			}
			let stringIndex = String.Index(utf16Offset: index, in: pattern)
			let patternCharacter = pattern[stringIndex]
			guard patternCharacter != replacementCharacter else { continue }
			pureNumber.insert(patternCharacter, at: stringIndex)
		}
		stringvar = pureNumber
	}
}

extension View {
	func placeholder<Content: View>(
		when shouldShow: Bool,
		alignment: Alignment = .leading,
		@ViewBuilder placeholder: () -> Content) -> some View {
			
			ZStack(alignment: alignment) {
				placeholder().opacity(shouldShow ? 1 : 0)
				self
			}
		}
}


