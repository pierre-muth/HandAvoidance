import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

const options = ["Notifications", "Steps", "Battery", "Time Zone","Heart Rate", "Off"] as Array<String>;
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
    function initialize() {
        BehaviorDelegate.initialize();
    }

    public function onSelect() as Boolean {
        var menu = new SettingsMenu();
        var fieldOption = Storage.getValue(1) as Number;
        menu.addItem(new WatchUi.MenuItem("  Field 1 value", options[fieldOption], 1,  null));
        fieldOption = Storage.getValue(2);
        menu.addItem(new WatchUi.MenuItem("  Field 2 value", options[fieldOption], 2,  null));
        fieldOption = Storage.getValue(3);
        menu.addItem(new WatchUi.MenuItem("  Field 3 value", options[fieldOption], 3,  null));
        fieldOption = Storage.getValue(4);
        menu.addItem(new WatchUi.MenuItem(" Set time zone", Lang.format("$1$", [fieldOption]), 4,  null));

        WatchUi.pushView(menu, new SettingsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
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

    //! Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    //! Handle a menu item being selected
    //! @param menuItem The menu item selected
    public function onSelect(menuItem as MenuItem) as Void {
        if (menuItem instanceof MenuItem) {
            var id = menuItem.getId() as Number;
            if (id < 4) {
                var fieldOption = Storage.getValue(id);
                if (fieldOption >=5) {
                    fieldOption = 0;
                } else {
                    fieldOption++;
                }
                Storage.setValue(id, fieldOption);
                menuItem.setSubLabel(options[fieldOption]);
            } else if (id == 4) {
                var fieldOption = Storage.getValue(id);
                if (fieldOption >=12) {
                    fieldOption = -12;
                } else {
                    fieldOption++;
                }
                Storage.setValue(id, fieldOption);
                menuItem.setSubLabel(Lang.format("$1$", [fieldOption]));
            }
        }
    }
}
    

