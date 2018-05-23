//
//  NetworkManager.swift
//  QuotePro
//
//  Created by Alejandro Zielinsky on 2018-05-23.
//  Copyright © 2018 Alejandro Zielinsky. All rights reserved.
//

import Foundation
import UIKit

struct QuoteAPI : Codable {
    
    let quoteText: String
    let quoteAuthor: String
    let quoteLink: String
}

class NetworkManager
{
    static func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    static func downloadImage(url: URL,completion: @escaping (UIImage?) -> Void)
    {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                let img = UIImage(data: data);
                completion(img);
            }
        }
    }
    
    static func getImage(completion: @escaping (UIImage?) -> Void)
    {
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a URLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        

        guard var URL = URL(string: "https://picsum.photos/200/300/") else {return}
        let URLParams = [
            "random": "null",
            ]
        URL = URL.appendingQueryParameters(URLParams)
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        
       
        downloadImage(url: URL) { (img) in
            completion(img)
        }
    }
    
    static func getQuote(completion: @escaping (Quote) -> Void)
    {
        let sessionConfig = URLSessionConfiguration.default

        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        guard var url = URL(string: "http://api.forismatic.com/api/1.0/") else {return}
        let URLParams = [
            "method": "getQuote",
            "lang": "en",
            "format": "json",
            ]
        url = url.appendingQueryParameters(URLParams)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Headers
        
        request.addValue("__cfduid=d78ad7df6099c848d2882462fe02f02061527085958", forHTTPHeaderField: "Cookie")
        
        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
            
            let decoder = JSONDecoder()
            let quoteAPI = try! decoder.decode(QuoteAPI.self, from: data!)
            let quote = Quote(quote: quoteAPI.quoteText, author: quoteAPI.quoteAuthor, link: quoteAPI.quoteLink)
            completion(quote);
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
     */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}

extension URL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new URL.
     */
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString)!
    }
}

