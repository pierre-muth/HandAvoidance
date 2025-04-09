import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;
import Toybox.Application.Storage;

class HandAvoidanceView extends WatchUi.WatchFace {

    // x, y coordinate, justification, icon offset, for each 4 watch quadrants
    const q0 = [95, 1, Graphics.TEXT_JUSTIFY_LEFT, 18];
    const q1 = [95, 105, Graphics.TEXT_JUSTIFY_LEFT, 18];
    const q2 = [80, 105, Graphics.TEXT_JUSTIFY_RIGHT, -18];
    const q3 = [80, 1, Graphics.TEXT_JUSTIFY_RIGHT, -18];
    
    // group 1 and group 2 coordinates to avoid watch hands

    const coordinates = [
                        [q3, q1],
                        [q3, q2],
                        [q3, q1],
                        [q2, q1],

                        [q3, q2],
                        [q2, q0],
                        [q3, q0],
                        [q2, q0],

                        [q3, q1],
                        [q3, q0],
                        [q3, q1],
                        [q1, q0],
                        
                        [q1, q2],
                        [q0, q2],
                        [q0, q1],
                        [q0, q2]
                        ];

    const dayofweekENG = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];     
    const dayofweekGRE = ["Κυρ", "Δευ", "Τρι", "Τετ", "Πέμ", "Παρ", "Σαβ"];
    const dayofweekCHS = ["日", "一", "二", "三", "四", "五", "六"]; 
    const dayofweekFRE = ["Dim", "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam"];  
    const dayofweekJPN = ["日", "月", "火", "水", "木", "金", "土"]; 
    const dayofweekKOR = ["일", "월", "화", "수", "목", "금", "토"];
    const dayofweekUKR = ["Нд", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"];
    const dayofweekRUS = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"];
    const dayofweekPOL = ["Nie", "Pn", "Wt", "Śr", "Cz", "Pt", "So"];  
    const dayofweekDEU = ["So.", "Mo.", "Di.", "Mi.", "Do.", "Fr.", "Sa."];  
    const dayofweekITA = ["Dom", "Lun", "Mar", "Mer", "Gio", "Ven", "Sab"];  
    const dayofweekSPA = ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"];  

    var dayofweek = dayofweekENG;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFaceLayout(dc));
        var watchSettings = System.getDeviceSettings();
        var watchLanguage = watchSettings.systemLanguage;
        if(watchLanguage == System.LANGUAGE_ENG) { dayofweek = dayofweekENG; }
        if(watchLanguage == System.LANGUAGE_GRE) { dayofweek = dayofweekGRE; }
        if(watchLanguage == System.LANGUAGE_CHS) { dayofweek = dayofweekCHS; }
        if(watchLanguage == System.LANGUAGE_CHT) { dayofweek = dayofweekCHS; }
        if(watchLanguage == System.LANGUAGE_FRE) { dayofweek = dayofweekFRE; }
        if(watchLanguage == System.LANGUAGE_JPN) { dayofweek = dayofweekJPN; }
        if(watchLanguage == System.LANGUAGE_KOR) { dayofweek = dayofweekKOR; }
        if(watchLanguage == System.LANGUAGE_UKR) { dayofweek = dayofweekUKR; }
        if(watchLanguage == System.LANGUAGE_RUS) { dayofweek = dayofweekRUS; }
        if(watchLanguage == System.LANGUAGE_POL) { dayofweek = dayofweekPOL; }
        if(watchLanguage == System.LANGUAGE_DEU) { dayofweek = dayofweekDEU; }
        if(watchLanguage == System.LANGUAGE_ITA) { dayofweek = dayofweekITA; }
        if(watchLanguage == System.LANGUAGE_SPA) { dayofweek = dayofweekSPA; }

    }

    // //! The user has just looked at their watch. Timers and animations may be started here.
	// function onExitSleep() {
	// 	System.println("Exiting Sleep");
	// }
	// //! Terminate any active timers and prepare for slow updates.
	// function onEnterSleep() {
	// 	System.println("Entering Sleep");
	// }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Get the date
        // var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        // var dateString = Lang.format("$1$", [today.day_of_week]);
        // System.println(dateString+", "+today.day_of_week);
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateString = dayofweek[(today.day_of_week-1)%7];
        var dayString = Lang.format("$1$", [today.day]);
        var todayUTC = Gregorian.utcInfo(Time.now(), Time.FORMAT_MEDIUM);
        var offset = Storage.getValue(4);
        var timeZoneHour = (todayUTC.hour + offset)%24;
        var utcString =  Lang.format("$1$:$2$", [timeZoneHour.format("%02d"), todayUTC.min.format("%02d")]);
        var utcIconString = "H";

        // Determine coordinate for hands avoidance
        var coordinatesIdx = (today.min/15)+(((today.hour%12)/3)*4);
        var x1 = coordinates[coordinatesIdx][0][0];
        var y1 = coordinates[coordinatesIdx][0][1];
        var j1 = coordinates[coordinatesIdx][0][2];
        var o1 = coordinates[coordinatesIdx][0][3];
        var x2 = coordinates[coordinatesIdx][1][0];
        var y2 = coordinates[coordinatesIdx][1][1];
        var j2 = coordinates[coordinatesIdx][1][2];
        var o2 = coordinates[coordinatesIdx][1][3];

        // get battery info
        var sys = System.getSystemStats();
        var batteryString = sys.batteryInDays.format("%.0f")+"d";
        var batteryPercentage = sys.battery;
        var batteryIconString = "D";
        if (batteryPercentage > 80 ) {batteryIconString = "A";}
        else if (batteryPercentage > 60 ) {batteryIconString = "B";}
        else if (batteryPercentage > 21 ) {batteryIconString = "C";}
        else {batteryIconString = "D";}

        // Get notifications count
        var settings = System.getDeviceSettings();
        var notificationString = settings.notificationCount.format("%i");
        var notificationIconString = "F";

        // Get step count
        var info = ActivityMonitor.getInfo();
        var stepString = info.steps.format("%i");
        var stepIconString = "E";

        // Get heart rate
        var info2 = Activity.getActivityInfo();
        var heartRateString = "n.a.";
        if (info2 != null && info2.currentHeartRate != null) {
            heartRateString = info2.currentHeartRate.format("%i");
        }
        var heartRateIconString = "G";

        // Get the config
        var field1value = Storage.getValue(1);
        var field2value = Storage.getValue(2);
        var field3value = Storage.getValue(3);

        var invertColor = Storage.getValue(5) as Boolean;
        var textColor = Graphics.COLOR_WHITE;
        if (invertColor) { textColor = Graphics.COLOR_BLACK; }

        //// drawing
        var view;

        // paint the background in white if inverted colors
        view = View.findDrawableById("BackgroundShape");
        view.setVisible(invertColor);

        // draw the date
        view = View.findDrawableById("DateLabel") as Text;
        view.setColor(textColor);
        view.setLocation(x1, y1);
        view.setJustification(j1);
        view.setText(dateString);

        view = View.findDrawableById("DayNumberLabel") as Text;
        view.setColor(textColor);
        view.setLocation(x1, y1+10);
        view.setJustification(j1);
        view.setText(dayString);

        // draw field 1 ["Notifications", "Steps", "Battery", "Time Zone","Heart Rate", "Off"]
        view = View.findDrawableById("Field1Icon") as Text;
        view.setColor(textColor);
        view.setLocation(x2, y2);
        view.setJustification(j2);
        if (field1value == 0) { view.setText(notificationIconString); }
        else if (field1value == 1) { view.setText(stepIconString); }
        else if (field1value == 2) { view.setText(batteryIconString); }
        else if (field1value == 3) { view.setText(utcIconString); }
        else if (field1value == 4) { view.setText(heartRateIconString); }
        else { view.setText(""); }

        view = View.findDrawableById("Field1Label") as Text;
        view.setColor(textColor);
        view.setLocation(x2+o2, y2);
        view.setJustification(j2);
        if (field1value == 0) { view.setText(notificationString); }
        else if (field1value == 1) { view.setText(stepString); }
        else if (field1value == 2) { view.setText(batteryString); }
        else if (field1value == 3) { view.setText(utcString); }
        else if (field1value == 4) { view.setText(heartRateString); }
        else { view.setText(""); }

        // draw field 2 ["Notifications", "Steps", "Battery", "Time Zone","Heart Rate", "Off"]
        view = View.findDrawableById("Field2Icon") as Text;
        view.setColor(textColor);
        view.setLocation(x2, y2+20);
        view.setJustification(j2);
        if (field2value == 0) { view.setText(notificationIconString); }
        else if (field2value == 1) { view.setText(stepIconString); }
        else if (field2value == 2) { view.setText(batteryIconString); }
        else if (field2value == 3) { view.setText(utcIconString); }
        else if (field2value == 4) { view.setText(heartRateIconString); }
        else { view.setText(""); }

        view = View.findDrawableById("Field2Label") as Text;
        view.setColor(textColor);
        view.setLocation(x2+o2, y2+20);
        view.setJustification(j2);
        if (field2value == 0) { view.setText(notificationString); }
        else if (field2value == 1) { view.setText(stepString); }
        else if (field2value == 2) { view.setText(batteryString); }
        else if (field2value == 3) { view.setText(utcString); }
        else if (field2value == 4) { view.setText(heartRateString); }
        else { view.setText(""); }

        // draw field 3 ["Notifications", "Steps", "Battery", "Time Zone","Heart Rate", "Off"]
        view = View.findDrawableById("Field3Icon") as Text;
        view.setColor(textColor);
        view.setLocation(x2, y2+40);
        view.setJustification(j2);
        if (field3value == 0) { view.setText(notificationIconString); }
        else if (field3value == 1) { view.setText(stepIconString); }
        else if (field3value == 2) { view.setText(batteryIconString); }
        else if (field3value == 3) { view.setText(utcIconString); }
        else if (field3value == 4) { view.setText(heartRateIconString); }
        else { view.setText(""); }

        view = View.findDrawableById("Field3Label") as Text;
        view.setColor(textColor);
        view.setLocation(x2+o2, y2+40);
        view.setJustification(j2);
        if (field3value == 0) { view.setText(notificationString); }
        else if (field3value == 1) { view.setText(stepString); }
        else if (field3value == 2) { view.setText(batteryString); }
        else if (field3value == 3) { view.setText(utcString); }
        else if (field3value == 4) { view.setText(heartRateString); }
        else { view.setText(""); }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

    }
    
    function updateLabel(view as View) {

    }

    function updateIcon(view as View) {

    }
}
