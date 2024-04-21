//
//  Date.swift
//  MetaPowerGirl
//
//  Created by 石勇 on 2023/6/3.
//

import Foundation

extension Date
{
    func toString(dateFormat format: String ) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
        
    }
    
}
