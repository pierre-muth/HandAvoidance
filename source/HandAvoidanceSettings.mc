import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

const fieldsOptions = ["Notifications", "Steps", "Battery day", "Battery %", "Time Zone","Heart Rate", "Floor Climbed", "Off"] as Array<String>;
const dateOptions = ["Day in big", "Day+Seconds always", "Day+Seconds low power", "Off"] as Array<String>;
const field4Options = ["Off", "Seconds always", "Seconds low power", "Weather now", "Weather next Hour", "Weather Today"] as Array<String>;

//! Initial app settings view
class HandAvoidanceSettings extends WatchUi.View {

    //! Constructor
    public function initialize() {
       View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, 1, Graphics.FONT_SMALL, "Press start and\nnavigate with\n\n\nstart/back\nup/down", Graphics.TEXT_JUSTIFY_CENTER);
    }

}

class HandAvoidanceSettingsDelegate extends WatchUi.BehaviorDelegate {
    var initialView as $.HandAvoidanceView? = null;

    function initialize(view as HandAvoidanceView) {
        initialView = view;
        BehaviorDelegate.initialize();
    }

    public function onSelect() as Boolean {
        var menu = new SettingsMenu();
        var setting = Storage.getValue(1) as Number;
        menu.addItem(new WatchUi.MenuItem("  Field 1", fieldsOptions[setting], 1,  null));
        setting = Storage.getValue(2) as Number;
        menu.addItem(new WatchUi.MenuItem("  Field 2", fieldsOptions[setting], 2,  null));
        setting = Storage.getValue(3) as Number;
        menu.addItem(new WatchUi.MenuItem("  Field 3", fieldsOptions[setting], 3,  null));
        setting = Storage.getValue(4) as Number;
        menu.addItem(new WatchUi.MenuItem(" Time zone", Lang.format("$1$", [setting]), 4,  null));
        setting = Storage.getValue(5) as Boolean;
        menu.addItem(new WatchUi.MenuItem(" Invert colors", Lang.format("$1$", [setting]), 5,  null));
        setting = Storage.getValue(6) as Number;
        menu.addItem(new WatchUi.MenuItem(" Date field", dateOptions[setting], 6,  null));
        setting = Storage.getValue(7) as Number;
        menu.addItem(new WatchUi.MenuItem(" Field 4", field4Options[setting], 7,  null));

        WatchUi.pushView(menu, new SettingsMenuDelegate(initialView), WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

}

class SettingsMenu extends WatchUi.Menu2 {
    //! Constructor
    public function initialize() {
        Menu2.initialize({:title=>"Settings"});
    }
}

//! Input handler for the settings menu
class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
var initialView as $.HandAvoidanceView? = null;
    //! Constructor
    public function initialize(view as HandAvoidanceView) {
        initialView = view;
        Menu2InputDelegate.initialize();
    }

    //! Handle a menu item being selected
    //! @param menuItem The menu item selected
    public function onSelect(menuItem as MenuItem) as Void {
        if (menuItem instanceof MenuItem) {
            var id = menuItem.getId() as Number;
            if (id < 4) {
                var fieldSetting = Storage.getValue(id);
                if (fieldSetting >=7) {
                    fieldSetting = 0;
                } else {
                    fieldSetting++;
                }
                Storage.setValue(id, fieldSetting);
                menuItem.setSubLabel(fieldsOptions[fieldSetting]);
            } else if (id == 4) {
                var fieldSetting = Storage.getValue(id);
                if (fieldSetting >=12) {
                    fieldSetting = -12;
                } else {
                    fieldSetting++;
                }
                Storage.setValue(id, fieldSetting);
                menuItem.setSubLabel(Lang.format("$1$", [fieldSetting]));
            } else if (id == 5) {
                var invertSetting = Storage.getValue(id) as Boolean;
                invertSetting = !invertSetting;
                Storage.setValue(id, invertSetting);
                menuItem.setSubLabel(Lang.format("$1$", [invertSetting]));
            } else if (id == 6) {
                var bigNumberDateSetting = Storage.getValue(id);
                if (bigNumberDateSetting >=3) {
                    bigNumberDateSetting = 0;
                } else {
                    bigNumberDateSetting++;
                }
                Storage.setValue(id, bigNumberDateSetting);
                menuItem.setSubLabel(dateOptions[bigNumberDateSetting]);
            } else if (id == 7) {
                var field4Setting = Storage.getValue(id);
                if (field4Setting >=5) {
                    field4Setting = 0;
                } else {
                    field4Setting++;
                }
                Storage.setValue(id, field4Setting);
                menuItem.setSubLabel(field4Options[field4Setting]);
            }

            initialView.onSettingsChanged();
        }
    }
}
    

