import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;

class HandAvoidanceView extends WatchUi.WatchFace {

    // x, y coordinate, justification, icon offset, for each 4 watch quadrants
    const q0 = [95, 1, Graphics.TEXT_JUSTIFY_LEFT, 20];
    const q1 = [95, 105, Graphics.TEXT_JUSTIFY_LEFT, 20];
    const q2 = [80, 105, Graphics.TEXT_JUSTIFY_RIGHT, -20];
    const q3 = [80, 1, Graphics.TEXT_JUSTIFY_RIGHT, -20];
    
    // group 1 and group 2 coordinates to avoid watch hands
    const coordinates = [
                        [q3, q2],
                        [q3, q2],
                        [q3, q1],
                        [q2, q1],

                        [q3, q2],
                        [q3, q0],
                        [q3, q0],
                        [q2, q0],

                        [q3, q1],
                        [q3, q0],
                        [q3, q0],
                        [q1, q0],
                        
                        [q1, q2],
                        [q0, q2],
                        [q0, q1],
                        [q1, q2]
                        ];

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Get the date
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateString = Lang.format("$1$", [today.day_of_week]);
        var dayString = Lang.format("$1$", [today.day]);

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

        // Get notifications count
        var settings = System.getDeviceSettings();
        var notifCountString = settings.notificationCount.format("%i");

        // Get step count
        var info = ActivityMonitor.getInfo();
        var stepCountString = info.steps.format("%i");

        // drawing
        var view;

        // draw the date
        view = View.findDrawableById("DateLabel") as Text;
        view.setLocation(x1, y1);
        view.setJustification(j1);
        view.setText(dateString);
        view = View.findDrawableById("DayNumberLabel") as Text;
        view.setLocation(x1, y1+15);
        view.setJustification(j1);
        view.setText(dayString);

        // draw notifications count
        view = View.findDrawableById("NotifIcon") as Text;
        view.setLocation(x2, y2);
        view.setJustification(j2);
        view.setText("F");
        view = View.findDrawableById("NotifLabel") as Text;
        view.setLocation(x2+o2, y2);
        view.setJustification(j2);
        view.setText(notifCountString);

        //draw step count
        view = View.findDrawableById("StepIcon") as Text;
        view.setLocation(x2, y2+20);
        view.setJustification(j2);
        view.setText("E");
        view = View.findDrawableById("StepLabel") as Text;
        view.setLocation(x2+o2, y2+20);
        view.setJustification(j2);
        view.setText(stepCountString);

        // draw the battery info
        view = View.findDrawableById("BatteryIcon") as Text;
        view.setLocation(x2, y2+40);
        view.setJustification(j2);
        if (batteryPercentage > 80 ) {view.setText("A");}
        else if (batteryPercentage > 60 ) {view.setText("B");}
        else if (batteryPercentage > 30 ) {view.setText("C");}
        else {view.setText("D");}
        view = View.findDrawableById("BatteryLabel") as Text;
        view.setLocation(x2+o2, y2+40);
        view.setJustification(j2);
        view.setText(batteryString);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
