//
//  IPService.swift
//  PhoneNumberControl
//
//  Created by Peter Put on 19/02/2024.
//  https://seald-apps.com 


import Foundation
 
class IPService{
    static let shared = IPService()
    private init(){
        
    }
 
    func getCountryCodeFromIP(completion: @escaping (String?) -> Void) {
        let ipURL = URL(string: "https://api.ipify.org")!
        let task = URLSession.shared.dataTask(with: ipURL) { data, response, error in
            guard let data = data, error == nil else {
                print(error ?? "Unknown error")
                completion(nil)
                return
            }
            let ipAddress = String(data: data, encoding: .utf8)
            guard let ip = ipAddress, let geolocationURL = URL(string: "https://api.ipapi.is/?q=\(ip)") else {
                completion(nil)
                return
            }
            let geolocationTask = URLSession.shared.dataTask(with: geolocationURL) { data, response, error in
                guard let data = data, error == nil else {
                    print(error ?? "Unknown error")
                    completion(nil)
                    return
                }
                // Parse the JSON response
                do {
                    let jsonOptions = JSONSerialization.ReadingOptions.allowFragments
                    if let json = try JSONSerialization.jsonObject(with: data, options: jsonOptions) as? [String: Any],
                       let location = json["location"] as? [String: Any],
                       let countryCode = location["country_code"] as? String {
                        completion(countryCode)
                    } else {
                        completion(nil)
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                    completion(nil)
                }
            }
            geolocationTask.resume()
        }
        task.resume()
    }
}

