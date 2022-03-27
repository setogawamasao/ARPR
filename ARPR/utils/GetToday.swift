//
//  GetToday.swift
//  ARPR
//
//  Created by 瀬戸川将夫 on 2022/03/27.
//

import Foundation

// 本日日付取得処理
func getToday() -> String{
    let dt = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy/MM/dd", options: 0, locale: Locale(identifier: Locale.preferredLanguages.first!))
    return dateFormatter.string(from: dt)
}
