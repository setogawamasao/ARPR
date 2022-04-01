//
//  SEManager.swift
//  ARPR
//
//  Created by 瀬戸川将夫 on 2022/03/21.
//

import UIKit
import AVFoundation
class SEManager: NSObject , AVAudioPlayerDelegate{

    //シングルとして使う
    static let sharedInstance = SEManager()
    var soundArray = NSMutableArray()
    
    override init() {
        super.init()
    }
    
    func playSound(soundName : String) throws {
        //サウンドファイルのパスを作ります。
        let soundPath :String = (Bundle.main.path(forAuxiliaryExecutable:soundName)! as NSString) as String
        
        do {
            //AVAudioPlayerのインスタンスを作成
            let  player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundPath))
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
            try AVAudioSession.sharedInstance().setActive(true)
            
            //配列に収納
            soundArray.insert (player, at: 0)
            //デリゲートを設定
            player.delegate = self
            //音を鳴らします。
            player.play()
            
        } catch {
            print("サウンドエラー",error)
        }
        
    }
    
    //音が鳴り終わったら呼ばれるデリゲート
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //鳴り終わったインスタンスを削除
        soundArray.remove(player)
        print("サウンド残り",soundArray.count)
    }
    
}

