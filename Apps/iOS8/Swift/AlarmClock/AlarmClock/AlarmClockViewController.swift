//
//  ViewController.swift
//  AlarmClock
//
//  Created by Clemens Wagner on 21.06.14.
//  Copyright (c) 2014 Clemens Wagner. All rights reserved.
//

import UIKit

class AlarmClockViewController: UIViewController {
    let kSecondsOfDay:NSTimeInterval = 60.0 * 60.0 * 24.0
    
    @IBOutlet var clockView: ClockView
    @IBOutlet var clockControl: ClockControl
    @IBOutlet var timeLabel: UILabel
    
    var alarmHidden: Bool {
    get {
        return self.clockControl.hidden
    }
    set {
        self.clockControl.hidden = newValue
        self.timeLabel.hidden = newValue
    }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(inAnimated: Bool) {
        super.viewWillAppear(inAnimated)
        updateViews()
    }
    
    override func viewDidAppear(inAnimated: Bool) {
        super.viewDidAppear(inAnimated)
        self.clockView.startAnimation()
    }
    
    override func viewWillDisappear(inAnimated: Bool) {
        self.clockView.stopAnimation()
        super.viewWillDisappear(inAnimated)
    }
    
    func updateViews() {
        let theApplication = UIApplication.sharedApplication()
        let theNotifications:NSArray? = theApplication.scheduledLocalNotifications
        let theNotification:UILocalNotification? = theNotifications?.lastObject as? UILocalNotification
        
        if(theNotification == nil) {
            self.alarmHidden = true;
        }
        else {
            var theTime = theNotification!.fireDate.timeIntervalSinceReferenceDate - self.startTimeOfCurrentDay()
            
            theTime = theTime % (kSecondsOfDay / 2.0)
            self.clockControl.time = theTime < 0 ? theTime + kSecondsOfDay / 2.0 : theTime;
            self.alarmHidden = false
        }
        updateTimeLabel()
    }
    
    @IBAction func updateTimeLabel() {
        let theTime:UInt = UInt(round(self.clockControl.time / 60.0))
        let theMinutes = theTime % 60;
        let theHours = theTime / 60;
        
        self.timeLabel.text = NSString(format:"%d:%02d", theHours, theMinutes)
    }
    
    @IBAction func switchAlarm(inRecognizer:UILongPressGestureRecognizer!) {
        if(inRecognizer.state == UIGestureRecognizerState.Ended) {
            if(self.alarmHidden) {
                let thePoint = inRecognizer.locationInView(self.clockView)
                let theAngle = Double(self.clockView.angleWithPoint(thePoint))
                let theTime = 21600.0 * theAngle / M_PI
                
                self.alarmHidden = false
                self.clockControl.time = theTime
                updateTimeLabel()
            }
            else {
                self.alarmHidden = true
            }
            updateAlarm()
        }
    }
    
    @IBAction func updateAlarm() {
        if(self.alarmHidden) {
            let theApplication = UIApplication.sharedApplication()
            
            theApplication.cancelAllLocalNotifications()
        }
        else {
            createAlarm()
        }
    }
    
    func alarmDate() -> NSDate {
        var theTime:NSTimeInterval = self.startTimeOfCurrentDay() + self.clockControl.time;
        
        while(theTime < NSDate.timeIntervalSinceReferenceDate()) {
            theTime += kSecondsOfDay / 2.0;
        }
        return NSDate(timeIntervalSinceReferenceDate:theTime)
    }
    
    func createAlarm() {
        let theApplication = UIApplication.sharedApplication()
        let theNotification = UILocalNotification()
        let theBody = NSLocalizedString("Wake up", comment:"Alarm message")
        
        theApplication.cancelAllLocalNotifications()
        theNotification.fireDate = alarmDate()
        theNotification.timeZone = NSTimeZone.defaultTimeZone()
        theNotification.alertBody = theBody
        theNotification.soundName = "ringtone.caf"
        theApplication.scheduleLocalNotification(theNotification)
    }
    
    func startTimeOfCurrentDay() -> NSTimeInterval {
        let theCalendar = NSCalendar.currentCalendar()
        let theComponents = theCalendar.components(NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit, fromDate: NSDate())
        let theDate = theCalendar.dateFromComponents(theComponents)
        
        return theDate.timeIntervalSinceReferenceDate
    }
    
    func description() -> NSString {
        return NSString(format:"alarm: %@ (%@)", self.timeLabel.text, self.alarmHidden ? "off" : "on")
    }
    
    func debugDescription() -> NSString {
        return NSString(format:"debug alarm: %@ (%.3fs, %@)", self.timeLabel.text, self.clockControl.time, self.alarmHidden ? "off" : "on")
    }
}

