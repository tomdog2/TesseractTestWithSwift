//
//  ViewController.swift
//  TesseractTest
//
//  Created by 田中賢治 on 2015/04/23.
//  Copyright (c) 2015年 田中賢治. All rights reserved.
//

import UIKit

class ViewController: UIViewController, G8TesseractDelegate {
    
    var imageView: UIImageView = UIImageView()
    var label: UILabel = UILabel()
    
    var adjustedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, 300)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = UIImage(named: "OCR-Sample-Japanese")
        
        label.frame = CGRectMake(0, 300,  self.view.frame.size.width, 200)
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        label.numberOfLines = 0
        label.text = "Analyzing..."
        
        self.view.addSubview(imageView)
        self.view.addSubview(label)
        
        var image = UIImage(named: "OCR-Sample-Japanese")
        
        //文字を読みやすくするため、白黒にする
        var ciImage = CIImage(image: image)
        
        var ciFilter = CIFilter(name: "CIColorMonochrome")
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        ciFilter.setValue(CIColor(red: 0.75, green: 0.75, blue: 0.75), forKey: kCIInputColorKey)
        ciFilter.setValue(NSNumber(float: 1.0), forKey: kCIInputIntensityKey)
        
        var ciContext = CIContext(options: nil)
        var cgImage: CGImageRef = ciContext.createCGImage(ciFilter.outputImage, fromRect: ciFilter.outputImage.extent())
        
        // 文字解析対象の画像の色、コントラストを調整したものを変数に保存する
        adjustedImage = UIImage(CGImage: cgImage)
        
        imageView.image = adjustedImage
        
        analyze()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func analyze() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            var tesseract = G8Tesseract(language: "jpn")
            tesseract.delegate = self
            tesseract.image = self.adjustedImage
            tesseract.recognize()
        
            self.label.text = tesseract.recognizedText
        
            println(tesseract.recognizedText)
        })
    }
    
    func shouldCancelImageRecognitionForTesseract(tesseract: G8Tesseract!) -> Bool {
        return false; // return true if you need to interrupt tesseract before it finishes
    }
}
