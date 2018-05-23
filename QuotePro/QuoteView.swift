//
//  QuoteView.swift
//  QuotePro
//
//  Created by Alejandro Zielinsky on 2018-05-23.
//  Copyright © 2018 Alejandro Zielinsky. All rights reserved.
//

import UIKit

class QuoteView: UIView {
    
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setupWithQuote(quote:Quote)
    {
        quoteLabel.text = quote.quoteText;
        authorLabel.text = quote.quoteAuthor;
        imageView.image = quote.photo;
    }
    
    func changeImage(img:UIImage)
    {
      imageView.image = img;
    }
    
    func changeQuote(quote:Quote)
    {
        quoteLabel.text = quote.quoteText;
        authorLabel.text = quote.quoteAuthor;
    }

}
