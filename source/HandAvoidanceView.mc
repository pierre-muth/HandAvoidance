import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;
import Toybox.Application.Storage;
import Toybox.Weather;

class HandAvoidanceView extends WatchUi.WatchFace {

    //for each 4 watch quadrants: x, y panel coordinate, justification, icon offset, x, y of 4th field
    const q0 = [95, 3, Graphics.TEXT_JUSTIFY_LEFT, 18, 110, 0];
    const q1 = [95, 105, Graphics.TEXT_JUSTIFY_LEFT, 18, 110, 110];
    const q2 = [80, 105, Graphics.TEXT_JUSTIFY_RIGHT, -18, 20, 110];
    const q3 = [80, 3, Graphics.TEXT_JUSTIFY_RIGHT, -18, 20, 0];
    
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

    var daysOftheWeek as Array<String> = dayofweekENG;
    var secondsFontGray as Graphics.FontType? = null;
    var secondsFontFull as Graphics.FontType? = null;
    var isSleeping = false;

    var settingField1 as Number = 0;
    var settingField2 as Number = 0;
    var settingField3 as Number = 0;
    var settingTimeZone as Number = 0;
    var settingInvertColors as Boolean = false;
    var settingDateField as Number = 0;
    var settingField4 as Number = 0;

    var watchTemperatureUnit as System.UnitsSystem = System.UNIT_METRIC;
    var watchLanguage as System.Language = System.LANGUAGE_ENG;

    var bigNumberDateString = "";
    var dateString = "";
    var field4BigString = "";
    var timeZoneIconString = "H";
    var timeZoneString = "";
    var batteryIconString = "D";
    var batteryString = "";
    var batteryPercentageString = "";
    var notificationIconString = "F";
    var notificationString = "";
    var stepIconString = "E";
    var stepString = ""; 
    var floorIconString = "I";
    var floorString = "";
    var heartRateIconString = "G";
    var heartRateString = "";
    var weatherIconString = "";
    var weatherTempString = "";

    function initialize() {
        onSettingsChanged();
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {

        setLayout(Rez.Layouts.WatchFaceLayout(dc));

        var watchSettings = System.getDeviceSettings();
        watchLanguage = watchSettings.systemLanguage;
        if(watchLanguage == System.LANGUAGE_ENG) { daysOftheWeek = dayofweekENG; }
        if(watchLanguage == System.LANGUAGE_GRE) { daysOftheWeek = dayofweekGRE; }
        if(watchLanguage == System.LANGUAGE_CHS) { daysOftheWeek = dayofweekCHS; }
        if(watchLanguage == System.LANGUAGE_CHT) { daysOftheWeek = dayofweekCHS; }
        if(watchLanguage == System.LANGUAGE_FRE) { daysOftheWeek = dayofweekFRE; }
        if(watchLanguage == System.LANGUAGE_JPN) { daysOftheWeek = dayofweekJPN; }
        if(watchLanguage == System.LANGUAGE_KOR) { daysOftheWeek = dayofweekKOR; }
        if(watchLanguage == System.LANGUAGE_UKR) { daysOftheWeek = dayofweekUKR; }
        if(watchLanguage == System.LANGUAGE_RUS) { daysOftheWeek = dayofweekRUS; }
        if(watchLanguage == System.LANGUAGE_POL) { daysOftheWeek = dayofweekPOL; }
        if(watchLanguage == System.LANGUAGE_DEU) { daysOftheWeek = dayofweekDEU; }
        if(watchLanguage == System.LANGUAGE_ITA) { daysOftheWeek = dayofweekITA; }
        if(watchLanguage == System.LANGUAGE_SPA) { daysOftheWeek = dayofweekSPA; }

        secondsFontGray = WatchUi.loadResource(Rez.Fonts.bigNumberEmptyFont) as Graphics.FontType;
        secondsFontFull = WatchUi.loadResource(Rez.Fonts.bigNumberFont) as Graphics.FontType;

        watchTemperatureUnit = watchSettings.temperatureUnits;
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
        if (settingField4 == 1) {
            var now = System.getClockTime();
            var coordinatesIdx = (now.min/15)+(((now.hour%12)/3)*4);
            var x3 = coordinates[coordinatesIdx][2][4];
            var y3 = coordinates[coordinatesIdx][2][5];
            var textColor = Graphics.COLOR_WHITE;
            var bgColor = Graphics.COLOR_BLACK;
            if (settingInvertColors) {
                textColor = Graphics.COLOR_BLACK;
                bgColor = Graphics.COLOR_WHITE;
            }
            dc.setClip(x3, y3+16, 48, 34);
            dc.setColor(bgColor, bgColor);
            dc.fillRectangle(x3, y3+16, 48, 34);
            dc.setColor(textColor, bgColor);
            dc.drawText(x3, y3, secondsFontGray, now.sec.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT);
        }
        // if we display seconds on date field
        if (settingDateField == 1) {
            var now = System.getClockTime();
            var coordinatesIdx = (now.min/15)+(((now.hour%12)/3)*4);
            var x1 = coordinates[coordinatesIdx][0][0];
            var y1 = coordinates[coordinatesIdx][0][1];
            var j1 = coordinates[coordinatesIdx][0][2];
            var xOffest = 0;
            if (j1 == Graphics.TEXT_JUSTIFY_RIGHT) {
                xOffest = -49;
            }
            var textColor = Graphics.COLOR_WHITE;
            var bgColor = Graphics.COLOR_BLACK;
            if (settingInvertColors) {
                textColor = Graphics.COLOR_BLACK;
                bgColor = Graphics.COLOR_WHITE;
            }
            dc.setClip(x1+xOffest, y1+10+16, 48, 34);
            dc.setColor(bgColor, bgColor);
            dc.fillRectangle(x1+xOffest, y1+10+16, 48, 34);
            dc.setColor(textColor, bgColor);
            dc.drawText(x1+xOffest, y1+10, secondsFontFull, now.sec.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        //------------ Compute values ------------

        // get now time
        var timeNOW = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        
        // Determine coordinate for hands avoidance
        var coordinatesIdx = (timeNOW.min/15)+(((timeNOW.hour%12)/3)*4);
        var x1 = coordinates[coordinatesIdx][0][0];
        var y1 = coordinates[coordinatesIdx][0][1];
        var j1 = coordinates[coordinatesIdx][0][2];
        
        var x2 = coordinates[coordinatesIdx][1][0];
        var y2 = coordinates[coordinatesIdx][1][1];
        var j2 = coordinates[coordinatesIdx][1][2];
        var o2 = coordinates[coordinatesIdx][1][3];

        var x3 = coordinates[coordinatesIdx][2][4];
        var y3 = coordinates[coordinatesIdx][2][5];

        var xw = coordinates[coordinatesIdx][2][0];
        var yw = coordinates[coordinatesIdx][2][1];
        var jw = coordinates[coordinatesIdx][2][2];
        
        // Make the strings for dates
        if (settingDateField == 0) {
            dateString = daysOftheWeek[(timeNOW.day_of_week-1)%7];
            bigNumberDateString = timeNOW.day.format("%2d");
        } else if(settingDateField == 1) {
            dateString = daysOftheWeek[(timeNOW.day_of_week-1)%7] + timeNOW.day.format("%2d");
            bigNumberDateString = timeNOW.sec.format("%02d");
        } else if(settingDateField == 2) {
            dateString = daysOftheWeek[(timeNOW.day_of_week-1)%7] + timeNOW.day.format("%2d");
            if (!isSleeping) {
                bigNumberDateString = timeNOW.sec.format("%02d");
            } else {
                bigNumberDateString = "";
            }
        } else {
            bigNumberDateString = "";
            dateString = "";
        }

        // Make the Second string for field 4
        if (settingField4 == 1) {
                field4BigString = timeNOW.sec.format("%02d");
        } else if (settingField4 == 2){
            if (!isSleeping) {
                field4BigString = timeNOW.sec.format("%02d");
            } else {
                field4BigString = "";
            }
        } else {
            field4BigString = "";
        }

        // Make Time Zone string
        if (settingField1 == 4 || settingField2 == 4 || settingField3 == 4) {
            var todayUTC = Gregorian.utcInfo(Time.now(), Time.FORMAT_MEDIUM);
            var timeZoneHour = (todayUTC.hour + settingTimeZone)%24;
            timeZoneString =  Lang.format("$1$:$2$", [timeZoneHour.format("%02d"), todayUTC.min.format("%02d")]);
        }

        // get battery info in days
        if (settingField1 == 2 || settingField2 == 2 || settingField3 == 2) {
            var sys = System.getSystemStats();
            batteryString = sys.batteryInDays.format("%.0f")+"d";
            var batteryPercentage = sys.battery;
            if (batteryPercentage > 80 ) {batteryIconString = "A";}
            else if (batteryPercentage > 60 ) {batteryIconString = "B";}
            else if (batteryPercentage > 21 ) {batteryIconString = "C";}
            else {batteryIconString = "D";}
        }

        // get battery info in %
        if (settingField1 == 3 || settingField2 == 3 || settingField3 == 3) {
            var sys = System.getSystemStats();
            var batteryPercentage = sys.battery;
            batteryPercentageString = batteryPercentage.format("%i")+"%";
            if (batteryPercentage > 80 ) {batteryIconString = "A";}
            else if (batteryPercentage > 60 ) {batteryIconString = "B";}
            else if (batteryPercentage > 21 ) {batteryIconString = "C";}
            else {batteryIconString = "D";}
        }

        // Get notifications count
        if (settingField1 == 0 || settingField2 == 0 || settingField3 == 0) {
            var settings = System.getDeviceSettings();
            notificationString = settings.notificationCount.format("%i");
        }

        // Get step count
        if (settingField1 == 1 || settingField2 == 1 || settingField3 == 1) {
            var info = ActivityMonitor.getInfo();
            stepString = info.steps.format("%i");
        }

        // Get floor count
        if (settingField1 == 6 || settingField2 == 6 || settingField3 == 6) {
            var info = ActivityMonitor.getInfo();
            floorString = info.floorsClimbed.format("%i");
        }

        // Get heart rate
        if (settingField1 == 5 || settingField2 == 5 || settingField3 == 5) {
            var info2 = Activity.getActivityInfo();
            if (info2 != null && info2.currentHeartRate != null) {
                heartRateString = info2.currentHeartRate.format("%i");
            } else {
                heartRateString = "n.a.";
            }
        }

        // Make the strings for weather info
        if (settingField4 == 3 || settingField4 == 4 || settingField4 == 5){
            var weather = Weather.getCurrentConditions();
            if (settingField4 == 4){
                weather = Weather.getHourlyForecast()[0];
            } else if (settingField4 == 5){
                weather = Weather.getDailyForecast()[0];
            }

            var condition = weather.condition;
            weatherIconString = "f";
            if (condition == Weather.CONDITION_CLEAR) {
                weatherIconString = "j";
            }
            if (condition == Weather.CONDITION_CLOUDY || condition == Weather.CONDITION_MOSTLY_CLOUDY) {
                weatherIconString = "a";
            }
            if (condition == Weather.CONDITION_RAIN || condition == Weather.CONDITION_RAIN_SNOW || condition == Weather.CONDITION_HEAVY_RAIN
                || condition == Weather.CONDITION_HEAVY_RAIN_SNOW || condition == Weather.CONDITION_FREEZING_RAIN  ) {
                weatherIconString = "g";
            }
            if (condition == Weather.CONDITION_LIGHT_RAIN || condition == Weather.CONDITION_LIGHT_RAIN_SNOW || condition == Weather.CONDITION_LIGHT_SHOWERS 
                || condition == Weather.CONDITION_SCATTERED_SHOWERS) {
                weatherIconString = "b";
            }
            if (condition == Weather.CONDITION_SNOW || condition == Weather.CONDITION_ICE_SNOW || condition == Weather.CONDITION_HEAVY_SNOW 
                || condition == Weather.CONDITION_LIGHT_SNOW ) {
                weatherIconString = "h";
            }
            if (condition == Weather.CONDITION_FOG || condition == Weather.CONDITION_MIST ) {
                weatherIconString = "c";
            }
            if (condition == Weather.CONDITION_THUNDERSTORMS || condition == Weather.CONDITION_TROPICAL_STORM || condition == Weather.CONDITION_TORNADO ) {
                weatherIconString = "i";
            }

            if (settingField4 == 3 || settingField4 == 4) {
                if (watchTemperatureUnit == System.UNIT_STATUTE) {
                    weatherTempString = (32+(weather.temperature * 1.8)).format("%i") + ")";
                } else {
                    weatherTempString = weather.temperature.format("%i") + "(";
                }
            }

            if (settingField4 == 5){
                if (watchTemperatureUnit == System.UNIT_STATUTE) { 
                    var minT = (32+(weather.lowTemperature * 1.8)).format("%i");
                    var maxT = (32+(weather.highTemperature * 1.8)).format("%i");
                    weatherTempString =  minT + "'" + maxT + ")";
                } else {
                    var minT = weather.lowTemperature.format("%i");
                    var maxT = weather.highTemperature.format("%i");
                    weatherTempString =  minT + "'" + maxT + "(";
                }
            }
        } else {
            weatherIconString = "";
            weatherTempString = "";
        }

        // Set colors according inverted setting 
        var textColor = Graphics.COLOR_WHITE;
        if (settingInvertColors) { textColor = Graphics.COLOR_BLACK; }

        //------------ drawing ------------
        
        dc.clearClip();
        var view;

        // paint the background in white if inverted colors
        view = View.findDrawableById("BackgroundShape");
        view.setVisible(settingInvertColors);

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
        view.setLocation(x3, y3);
        view.setJustification(Graphics.TEXT_JUSTIFY_LEFT);
        view.setText(field4BigString);
        
        // draw Weather
        view = View.findDrawableById("WeatherLabel") as Text;
        view.setColor(textColor);
        view.setLocation(xw, yw);
        view.setJustification(jw);
        view.setText(weatherTempString);
        view = View.findDrawableById("WeatherIcon") as Text;
        view.setColor(textColor);
        view.setLocation(xw, yw+17);
        view.setJustification(jw);
        view.setText(weatherIconString);

        // draw field 1  ["Notifications", "Steps", "Battery day", "Battery %", "Time Zone","Heart Rate", "Floor Climbed", "Off"]
        view = View.findDrawableById("Field1Icon") as Text;
        view.setColor(textColor);
        view.setLocation(x2, y2);
        view.setJustification(j2);
        if (settingField1 == 0) { view.setText(notificationIconString); }
        else if (settingField1 == 1) { view.setText(stepIconString); }
        else if (settingField1 == 2) { view.setText(batteryIconString); }
        else if (settingField1 == 3) { view.setText(batteryIconString); }
        else if (settingField1 == 4) { view.setText(timeZoneIconString); }
        else if (settingField1 == 5) { view.setText(heartRateIconString); }
        else if (settingField1 == 6) { view.setText(floorIconString); }
        else { view.setText(""); }

        view = View.findDrawableById("Field1Label") as Text;
        view.setColor(textColor);
        view.setLocation(x2+o2, y2);
        view.setJustification(j2);
        if (settingField1 == 0) { view.setText(notificationString); }
        else if (settingField1 == 1) { view.setText(stepString); }
        else if (settingField1 == 2) { view.setText(batteryString); }
        else if (settingField1 == 3) { view.setText(batteryPercentageString); }
        else if (settingField1 == 4) { view.setText(timeZoneString); }
        else if (settingField1 == 5) { view.setText(heartRateString); }
        else if (settingField1 == 6) { view.setText(floorString); }
        else { view.setText(""); }

        // draw field 2  ["Notifications", "Steps", "Battery day", "Battery %", "Time Zone","Heart Rate", "Floor Climbed", "Off"]
        view = View.findDrawableById("Field2Icon") as Text;
        view.setColor(textColor);
        view.setLocation(x2, y2+20);
        view.setJustification(j2);
        if (settingField2 == 0) { view.setText(notificationIconString); }
        else if (settingField2 == 1) { view.setText(stepIconString); }
        else if (settingField2 == 2) { view.setText(batteryIconString); }
        else if (settingField2 == 3) { view.setText(batteryIconString); }
        else if (settingField2 == 4) { view.setText(timeZoneIconString); }
        else if (settingField2 == 5) { view.setText(heartRateIconString); }
        else if (settingField2 == 6) { view.setText(floorIconString); }
        else { view.setText(""); }

        view = View.findDrawableById("Field2Label") as Text;
        view.setColor(textColor);
        view.setLocation(x2+o2, y2+20);
        view.setJustification(j2);
        if (settingField2 == 0) { view.setText(notificationString); }
        else if (settingField2 == 1) { view.setText(stepString); }
        else if (settingField2 == 2) { view.setText(batteryString); }
        else if (settingField2 == 3) { view.setText(batteryPercentageString); }
        else if (settingField2 == 4) { view.setText(timeZoneString); }
        else if (settingField2 == 5) { view.setText(heartRateString); }
        else if (settingField2 == 6) { view.setText(floorString); }
        else { view.setText(""); }

        // draw field 3 ["Notifications", "Steps", "Battery day", "Battery %", "Time Zone","Heart Rate", "Floor Climbed", "Off"]
        view = View.findDrawableById("Field3Icon") as Text;
        view.setColor(textColor);
        view.setLocation(x2, y2+40);
        view.setJustification(j2);
        if (settingField3 == 0) { view.setText(notificationIconString); }
        else if (settingField3 == 1) { view.setText(stepIconString); }
        else if (settingField3 == 2) { view.setText(batteryIconString); }
        else if (settingField3 == 3) { view.setText(batteryIconString); }
        else if (settingField3 == 4) { view.setText(timeZoneIconString); }
        else if (settingField3 == 5) { view.setText(heartRateIconString); }
        else if (settingField3 == 6) { view.setText(floorIconString); }
        else { view.setText(""); }

        view = View.findDrawableById("Field3Label") as Text;
        view.setColor(textColor);
        view.setLocation(x2+o2, y2+40);
        view.setJustification(j2);
        if (settingField3 == 0) { view.setText(notificationString); }
        else if (settingField3 == 1) { view.setText(stepString); }
        else if (settingField3 == 2) { view.setText(batteryString); }
        else if (settingField3 == 3) { view.setText(batteryPercentageString); }
        else if (settingField3 == 4) { view.setText(timeZoneString); }
        else if (settingField3 == 5) { view.setText(heartRateString); }
        else if (settingField3 == 6) { view.setText(floorString); }
        else { view.setText(""); }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

    }

    function onSettingsChanged(){
        // System.println("The View register a settings Change");
        settingField1 = Storage.getValue(1) as Number;
        settingField2 = Storage.getValue(2) as Number;
        settingField3 = Storage.getValue(3) as Number;
        settingTimeZone = Storage.getValue(4) as Number;
        settingInvertColors = Storage.getValue(5) as Boolean;
        settingDateField = Storage.getValue(6) as Number;
        settingField4 = Storage.getValue(7) as Number;
    }
}

// Receives watch face events
class HandAvoidanceDelegate extends WatchUi.WatchFaceDelegate {
    private var initialView as HandAvoidanceView;

    //! Constructor
    //! @param view The analog view
    public function initialize(view as HandAvoidanceView) {
        WatchFaceDelegate.initialize();
        initialView = view;
    }

    //! The onPowerBudgetExceeded callback is called by the system if the
    //! onPartialUpdate method exceeds the allowed power budget. If this occurs,
    //! the system will stop invoking onPartialUpdate each second, so we notify the
    //! view here to let the rendering methods know they should not be rendering a
    //! second hand.
    //! @param powerInfo Information about the power budget
    public function onPowerBudgetExceeded(powerInfo as WatchFacePowerInfo) as Void {
        // System.println("Average execution time: " + powerInfo.executionTimeAverage);
        // System.println("Allowed execution time: " + powerInfo.executionTimeLimit);
    }
}
