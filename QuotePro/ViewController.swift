//
//  ViewController.swift
//  QuotePro
//
//  Created by Alejandro Zielinsky on 2018-05-23.
//  Copyright © 2018 Alejandro Zielinsky. All rights reserved.
//

import UIKit


protocol QuoteBuilderProtocol
{
    func saveQuote(quote:Quote);
}

class ViewController: UIViewController {

    var quoteView : QuoteView?;
    var currentQuote : Quote?
    var delegate : QuoteBuilderProtocol?

    
    @IBOutlet weak var generateQuoteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let objects = Bundle.main.loadNibNamed("QuoteView", owner: nil, options: [:]),
            let view = objects.first
        {
            quoteView = view as? QuoteView;
            self.view.addSubview(quoteView!);
            setUpConstraints()
        }

        NetworkManager.getQuote { (quote) in
            DispatchQueue.main.async()
            {
                self.currentQuote = quote;
                NetworkManager.getImage(completion: { (img) in
                    self.currentQuote?.photo = img!;
                    self.quoteView?.setupWithQuote(quote: quote)
                })
            }
        }
    }
    
    private func convertViewToImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions((quoteView?.bounds.size)!, (quoteView?.isOpaque)!, 0.0)
        quoteView!.drawHierarchy(in: (quoteView?.bounds)!, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        currentQuote?.snapshotImage = convertViewToImage()
        saveQuote(quote: currentQuote!)
        navigationController?.popViewController(animated: true)
    }
    
    
    func saveQuote(quote:Quote)
    {
        delegate?.saveQuote(quote: quote);
    }
    
    @IBAction func generateQuote(_ sender: UIButton) {
    
        NetworkManager.getQuote { (quote) in
        DispatchQueue.main.async()
            {
                self.currentQuote = quote;
                self.quoteView?.changeQuote(quote: quote);
            }
        }
    }
    
    
    @IBAction func generateImage(_ sender: UIButton)
    {
        NetworkManager.getImage(completion: { (img) in
            self.currentQuote?.photo = img!;
            self.quoteView?.changeImage(img: img!);
                    })
    }
    
    func setUpConstraints()
    {
        quoteView!.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: quoteView!, attribute:
            .leading, relatedBy: .equal, toItem: view,
                            attribute: .leading, multiplier: 1.0,
                            constant: 0).isActive = true;
        
        NSLayoutConstraint(item: quoteView!, attribute:
            .trailing, relatedBy: .equal, toItem: view,
                             attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true;
        
        NSLayoutConstraint(item: quoteView!, attribute: .top, relatedBy: .equal,
                                        toItem: view, attribute: .top, multiplier: 1.0, constant: 0).isActive = true;
        
        NSLayoutConstraint(item: quoteView!, attribute: .bottom, relatedBy: .equal,
                           toItem: generateQuoteButton, attribute: .top, multiplier: 1.0, constant: 0).isActive = true;
    }

}

