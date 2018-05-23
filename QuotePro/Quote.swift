//
//  Quote.swift
//  QuotePro
//
//  Created by Alejandro Zielinsky on 2018-05-23.
//  Copyright © 2018 Alejandro Zielinsky. All rights reserved.
//

import Foundation
import UIKit

class Quote
{
    var quoteText: String = ""
    var quoteAuthor: String = ""
    var quoteLink: String = ""
    
    var snapshotImage:UIImage?
    
    var photo = UIImage()
    
    init(quote:String,author:String,link:String)
    {
        quoteText = quote;
        quoteAuthor = author;
        quoteLink = link;
    }
}
