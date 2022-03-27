//
//  RecordingExtension.swift
//  ARPR
//
//  Created by 瀬戸川将夫 on 2022/03/27.
//

import UIKit
import ReplayKit

extension ViewController :  RPPreviewViewControllerDelegate {
     // 録画開始・録画停止ボタン押下時
        @IBAction func switchRecording(_ sender: Any) {
            print("record")
            if RPScreenRecorder.shared().isRecording  {
                // 録画停止処理
                print("record stop")
                RPScreenRecorder.shared().stopRecording(handler: { (previewController, error) in
                    if let previewController = previewController {
                        previewController.previewControllerDelegate = self
                        DispatchQueue.main.async {
                            self.present(previewController, animated: true, completion: nil)
                        }
                    } else {
                        print("error stopping recording (was it running?)")
                    }
                })
                self.switchShowBarButton(ishow: true)
            } else{
                // 録画開始処理
                print("record start")
                RPScreenRecorder.shared().isMicrophoneEnabled = true
                RPScreenRecorder.shared().startRecording(handler: { (error) in
                    if let error = error {
                        debugPrint(#function, "recording something failed", error)
                    }
                })
    
                self.switchShowBarButton(ishow: false)
            }
        }
    
        func switchShowBarButton(ishow:Bool){
            let barButtonColor = UIColor.init(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
            if ishow {
                self.switchRecordButton.setTitle("録画", for: .normal)
                self.addQaButton.isEnabled = true
                self.addQaButton.tintColor = barButtonColor
                self.resetQaButton.isEnabled = true
                self.resetQaButton.tintColor = barButtonColor
                self.initializeButton.isEnabled = true
                self.initializeButton.tintColor = barButtonColor
            } else{
                self.switchRecordButton.setTitle("停止", for: .normal)
                self.addQaButton.isEnabled = false
                self.addQaButton.tintColor = UIColor.clear
                self.resetQaButton.isEnabled = false
                self.resetQaButton.tintColor = UIColor.clear
                self.initializeButton.isEnabled = false
                self.initializeButton.tintColor = UIColor.clear
            }
    
        }
    
        // 録画プレビューのキャンセル処理
        func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
            DispatchQueue.main.async { [unowned previewController] in
                previewController.dismiss(animated: true, completion: nil)
            }
        }
    
}
