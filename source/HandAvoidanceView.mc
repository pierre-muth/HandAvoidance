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

    // x, y panel coordinate, justification, icon offset, for each 4 watch quadrants
    const q0 = [95, 3, Graphics.TEXT_JUSTIFY_LEFT, 18];
    const q1 = [95, 105, Graphics.TEXT_JUSTIFY_LEFT, 18];
    const q2 = [80, 105, Graphics.TEXT_JUSTIFY_RIGHT, -18];
    const q3 = [80, 3, Graphics.TEXT_JUSTIFY_RIGHT, -18];
    
    // group 1 (date) and group 2 (3 fields) coordinates to avoid watch hands
    // group 3 might be below hours hand (less intrusive than minutes)
    // .---------.
    // | q3 | q0 |
    // |----o----|
    // | q2 | q1 |
    // '---------'
    // coordinates index is (min/15)+(((hour%12)/3)*4);

    const coordinates = [
                        [q3, q1, q2],   //e.g. 02:10
                        [q3, q2, q0],   //e.g. 02:20
                        [q3, q1, q0],   //e.g. 02:40
                        [q2, q1, q0],   //e.g. 02:50

                        [q3, q2, q1],   //e.g. 04:10
                        [q2, q0, q3],   //e.g. 04:20
                        [q3, q0, q1],   //e.g. 04:40
                        [q2, q0, q1],   //e.g. 04:50

                        [q3, q1, q2],   //e.g. 08:10
                        [q3, q0, q2],   //e.g. 08:20
                        [q3, q1, q0],   //e.g. 08:40
                        [q1, q0, q2],   //e.g. 08:50
                        
                        [q1, q2, q3],   //e.g. 10:10
                        [q0, q2, q3],   //e.g. 10:20
                        [q0, q1, q3],   //e.g. 10:40
                        [q0, q2, q1]    //e.g. 10:50
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

    var isSleeping = false;

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

    // The user has just looked at their watch. Timers and animations may be started here.
	function onExitSleep() {
		// System.println("onExitSleep");
        isSleeping = false;
	}
	// Terminate any active timers and prepare for slow updates.
	function onEnterSleep() {
		// System.println("onEnterSleep");
        isSleeping = true;
	}

    // Update a portion of the screen.
    function onPartialUpdate(dc as Graphics.Dc) as Void {
        // System.println("onPartialUpdate");
        // if we display seconds on field 4
        if( Storage.getValue(7) == 1 ) {
            var now = System.getClockTime();
            var coordinatesIdx = (now.min/15)+(((now.hour%12)/3)*4);
            var x3 = coordinates[coordinatesIdx][2][0];
            var y3 = coordinates[coordinatesIdx][2][1];
            var j3 = coordinates[coordinatesIdx][2][2];
            var invertColor = Storage.getValue(5) as Boolean;
            var xOffest = 12;
            if (j3 == Graphics.TEXT_JUSTIFY_RIGHT) {
                xOffest = -59;
            }
            dc.setClip(x3+xOffest, y3+26, 48, 34);
            var textColor = Graphics.COLOR_WHITE;
            var bgColor = Graphics.COLOR_BLACK;
            if (invertColor) {
                textColor = Graphics.COLOR_BLACK;
                bgColor = Graphics.COLOR_WHITE;
            }
            dc.setColor(bgColor, bgColor);
            dc.fillRectangle(x3+xOffest, y3+26, 48, 34);
            var view = View.findDrawableById("Field4Label") as Text;
            view.setColor(textColor);
            view.setLocation(x3, y3+10);
            view.setJustification(j3);
            view.setText(" " + now.sec.format("%02d")+" ");
            view.draw(dc);
        }
        // if we display seconds on date field
        if( Storage.getValue(6) == 1 ) {
            var now = System.getClockTime();
            var coordinatesIdx = (now.min/15)+(((now.hour%12)/3)*4);
            var x1 = coordinates[coordinatesIdx][0][0];
            var y1 = coordinates[coordinatesIdx][0][1];
            var j1 = coordinates[coordinatesIdx][0][2];
            var invertColor = Storage.getValue(5) as Boolean;
            var xOffest = 0;
            if (j1 == Graphics.TEXT_JUSTIFY_RIGHT) {
                xOffest = -49;
            }
            dc.setClip(x1+xOffest, y1+26, 48, 34);
            var textColor = Graphics.COLOR_WHITE;
            var bgColor = Graphics.COLOR_BLACK;
            if (invertColor) {
                textColor = Graphics.COLOR_BLACK;
                bgColor = Graphics.COLOR_WHITE;
            }
            dc.setColor(bgColor, bgColor);
            dc.fillRectangle(x1+xOffest, y1+26, 48, 34);
            var view = View.findDrawableById("DayNumberLabel") as Text;
            view.setColor(textColor);
            view.setLocation(x1, y1+10);
            view.setJustification(j1);
            view.setText(now.sec.format("%02d"));
            view.draw(dc);
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        
        //------------ Compute values ------------

        // Get the settings
        var field1option = Storage.getValue(1);
        var field2option = Storage.getValue(2);
        var field3option = Storage.getValue(3);
        var utcOffset = Storage.getValue(4);
        var invertColor = Storage.getValue(5) as Boolean;
        var dateFieldOption = Storage.getValue(6);
        var field4option = Storage.getValue(7);

        // get today
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        
        // Determine coordinate for hands avoidance
        var coordinatesIdx = (today.min/15)+(((today.hour%12)/3)*4);
        var x1 = coordinates[coordinatesIdx][0][0];
        var y1 = coordinates[coordinatesIdx][0][1];
        var j1 = coordinates[coordinatesIdx][0][2];
        
        var x2 = coordinates[coordinatesIdx][1][0];
        var y2 = coordinates[coordinatesIdx][1][1];
        var j2 = coordinates[coordinatesIdx][1][2];
        var o2 = coordinates[coordinatesIdx][1][3];

        var x3 = coordinates[coordinatesIdx][2][0];
        var y3 = coordinates[coordinatesIdx][2][1];
        var j3 = coordinates[coordinatesIdx][2][2];
        
        // Make the strings for dates
        var bigNumberDateString = "";
        var dateString = "";
        if (dateFieldOption == 0) {
            dateString = dayofweek[(today.day_of_week-1)%7];
            bigNumberDateString = today.day.format("%2d");
        } else if(dateFieldOption == 1 || dateFieldOption == 2) {
            dateString = dayofweek[(today.day_of_week-1)%7]+ today.day.format("%2d");
            if (!isSleeping) {
                bigNumberDateString = today.sec.format("%02d");
            }
        }

        // Make the string for field 4
        var field4BigString = "";
        if (field4option == 1 || field4option == 2) {
            if (!isSleeping) {
                field4BigString = " " + today.sec.format("%02d")+" ";
            }
        }

        // get UTC info
        var todayUTC = Gregorian.utcInfo(Time.now(), Time.FORMAT_MEDIUM);
        var timeZoneHour = (todayUTC.hour + utcOffset)%24;
        var utcString =  Lang.format("$1$:$2$", [timeZoneHour.format("%02d"), todayUTC.min.format("%02d")]);
        var utcIconString = "H";

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

        // Set colors according inverted setting 
        var textColor = Graphics.COLOR_WHITE;
        if (invertColor) { textColor = Graphics.COLOR_BLACK; }

        //------------ drawing ------------
        
        dc.clearClip();
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
        view.setText(bigNumberDateString);

        // draw field 4 
        view = View.findDrawableById("Field4Label") as Text;
        view.setColor(textColor);
        view.setLocation(x3, y3+10);
        view.setJustification(j3);
        view.setText(field4BigString);

        // draw field 1 ["Notifications", "Steps", "Battery", "Time Zone","Heart Rate", "Off"]
        view = View.findDrawableById("Field1Icon") as Text;
        view.setColor(textColor);
        view.setLocation(x2, y2);
        view.setJustification(j2);
        if (field1option == 0) { view.setText(notificationIconString); }
        else if (field1option == 1) { view.setText(stepIconString); }
        else if (field1option == 2) { view.setText(batteryIconString); }
        else if (field1option == 3) { view.setText(utcIconString); }
        else if (field1option == 4) { view.setText(heartRateIconString); }
        else { view.setText(""); }

        view = View.findDrawableById("Field1Label") as Text;
        view.setColor(textColor);
        view.setLocation(x2+o2, y2);
        view.setJustification(j2);
        if (field1option == 0) { view.setText(notificationString); }
        else if (field1option == 1) { view.setText(stepString); }
        else if (field1option == 2) { view.setText(batteryString); }
        else if (field1option == 3) { view.setText(utcString); }
        else if (field1option == 4) { view.setText(heartRateString); }
        else { view.setText(""); }

        // draw field 2 ["Notifications", "Steps", "Battery", "Time Zone","Heart Rate", "Off"]
        view = View.findDrawableById("Field2Icon") as Text;
        view.setColor(textColor);
        view.setLocation(x2, y2+20);
        view.setJustification(j2);
        if (field2option == 0) { view.setText(notificationIconString); }
        else if (field2option == 1) { view.setText(stepIconString); }
        else if (field2option == 2) { view.setText(batteryIconString); }
        else if (field2option == 3) { view.setText(utcIconString); }
        else if (field2option == 4) { view.setText(heartRateIconString); }
        else { view.setText(""); }

        view = View.findDrawableById("Field2Label") as Text;
        view.setColor(textColor);
        view.setLocation(x2+o2, y2+20);
        view.setJustification(j2);
        if (field2option == 0) { view.setText(notificationString); }
        else if (field2option == 1) { view.setText(stepString); }
        else if (field2option == 2) { view.setText(batteryString); }
        else if (field2option == 3) { view.setText(utcString); }
        else if (field2option == 4) { view.setText(heartRateString); }
        else { view.setText(""); }

        // draw field 3 ["Notifications", "Steps", "Battery", "Time Zone","Heart Rate", "Off"]
        view = View.findDrawableById("Field3Icon") as Text;
        view.setColor(textColor);
        view.setLocation(x2, y2+40);
        view.setJustification(j2);
        if (field3option == 0) { view.setText(notificationIconString); }
        else if (field3option == 1) { view.setText(stepIconString); }
        else if (field3option == 2) { view.setText(batteryIconString); }
        else if (field3option == 3) { view.setText(utcIconString); }
        else if (field3option == 4) { view.setText(heartRateIconString); }
        else { view.setText(""); }

        view = View.findDrawableById("Field3Label") as Text;
        view.setColor(textColor);
        view.setLocation(x2+o2, y2+40);
        view.setJustification(j2);
        if (field3option == 0) { view.setText(notificationString); }
        else if (field3option == 1) { view.setText(stepString); }
        else if (field3option == 2) { view.setText(batteryString); }
        else if (field3option == 3) { view.setText(utcString); }
        else if (field3option == 4) { view.setText(heartRateString); }
        else { view.setText(""); }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

    }
    
    function updateLabel(view as View) {

    }

    function updateIcon(view as View) {

    }
}
