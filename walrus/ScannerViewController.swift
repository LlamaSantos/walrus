//
//  ScannerViewController.swift
//  walrus
//
//  Created by James White on 12/23/14.
//  Copyright (c) 2014 James White. All rights reserved.
//

import Foundation
import AVFoundation

protocol ScannerDelegate {
    func scanCompletion(value :String)
}

class ScannerViewController : UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIWebViewDelegate {

//    @IBOutlet weak var viewPreview : UIView?
//    @IBOutlet weak var lblStatus : UILabel?
//    @IBOutlet weak var bbitemStart : UIBarButtonItem?
    @IBOutlet var webView : UIWebView?
    var captureSession : AVCaptureSession?
    var videoPreviewLayer : AVCaptureVideoPreviewLayer?
    var isReading : Bool = false
    var delegate : ScannerDelegate?
    
    func startStopReading(){
        if (self.isReading){
            print("Currently reading, please wait until the scan is finished.")
            
        } else {
            self.startReading()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isReading = false
        self.captureSession = nil
        self.webView = nil
        
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
            self.startStopReading()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startReading() -> Bool {
        self.isReading = true
        var error : NSError?
        
        var captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if let input = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error) as? AVCaptureDeviceInput {
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)

            var captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            var queue : dispatch_queue_t = dispatch_queue_create("capture_queue", nil)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: queue)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            let bounds = self.view.layer.bounds
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.bounds = bounds
            videoPreviewLayer?.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
            
            self.view.layer.addSublayer(videoPreviewLayer)
            captureSession?.startRunning()

        } else {
            println("Error: \(error!.description)")
            self.isReading = false
            return false
        }
        
        
        return true
    }
    
    func getImage(url: String){
        var url = NSURL(string: url.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
        var request = NSURLRequest(URL: url!)

        dispatch_async(dispatch_get_main_queue(), {() -> Void in
            self.webView = UIWebView()
            self.webView?.delegate = self
            self.webView?.loadRequest(request)
        })
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        var result = webView.stringByEvaluatingJavaScriptFromString("document.getElementById(\"receipt\").src")
        
        
        
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
            print(result)
            self.dismissViewControllerAnimated(true, completion: nil)
            self.delegate?.scanCompletion(result!)
        })
        
    }
    
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if (metadataObjects.count > 0 && self.isReading) {
            if let metadataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if metadataObject.type == AVMetadataObjectTypeQRCode {
                    
                    self.isReading = false
                    
                    getImage(metadataObject.stringValue)
                    
                    self.videoPreviewLayer?.removeFromSuperlayer()
                    
                    println("QR Code: \(metadataObject.stringValue)")
                    
                }
            }
        }
    }
}