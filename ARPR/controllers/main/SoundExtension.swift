//
//  SoundExtension.swift
//  ARPR
//
//  Created by 瀬戸川将夫 on 2022/03/28.
//

extension ViewController {
    // 音声再生
    func playSound(soundName:String) {
        do{
            try seManager.playSound(soundName: soundName)
        } catch {
            print(error)
        }
    }
}
