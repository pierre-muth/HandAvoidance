import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

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
        dc.drawText(dc.getWidth() / 2, 5, Graphics.FONT_SMALL, "Settings\nstart / back", Graphics.TEXT_JUSTIFY_CENTER);
    }

}

class HandAvoidanceSettingsDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    public function onSelect() as Boolean {
        var menu = new SettingsMenu();
        var boolean = Storage.getValue(1) ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem(" Field 1", "Notif. / T.Zone", 1, boolean, null));
        boolean = Storage.getValue(2) ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem(" Field 2", "Step. / H.Rate", 2, boolean, null));

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
        if (menuItem instanceof ToggleMenuItem) {
            Storage.setValue(menuItem.getId() as Number, menuItem.isEnabled());
        }
    }
}
    

