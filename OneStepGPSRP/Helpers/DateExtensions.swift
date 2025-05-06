//
//  DateExtensions.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 5/4/25.
//
import Foundation

extension Date {
    /// Return string value from Date to current Date
    func timeToCurrentDateDHMS() -> String {
        let currentDate = Date()
        let calendar = Calendar.current
        var resultString: String = ""
        
        let diffDateComponents =  calendar.dateComponents([.day, .hour, .minute, .second], from: self, to: currentDate)
        
      
        let days  = (diffDateComponents.day ?? 0)
        let hours = (diffDateComponents.hour ?? 0)
        let mins = (diffDateComponents.minute ?? 0)
        let secs = (diffDateComponents.second ?? 0)
        
        if (days) > 0 {
            resultString.append("\(days)d ")
        }
        
        if (hours) > 0 {
            resultString.append("\(hours)h ")
        }
        
        if (mins) > 0 {
            resultString.append("\(mins)m ")
            
        }
        
        if days == 0 && hours == 0 && secs > 0 {
            resultString.append("\(secs)s")
            
        } else if days+hours+mins == 0 {
            resultString.append("\(secs)s")
        }
        
        return resultString
    }
}
