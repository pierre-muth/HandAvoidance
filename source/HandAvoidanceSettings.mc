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
        dc.drawText(dc.getWidth() / 2, 10, Graphics.FONT_SMALL, "settings\nstart/back", Graphics.TEXT_JUSTIFY_CENTER);
    }

}

class HandAvoidanceSettingsDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    public function onSelect() as Boolean {
        var menu = new SettingsMenu();
        menu.addItem(new WatchUi.ToggleMenuItem("Settings1", null, 1, true, null));
        menu.addItem(new WatchUi.ToggleMenuItem("Settings2", null, 2, true, null));
        menu.addItem(new WatchUi.ToggleMenuItem("Settings3", null, 3, true, null));
        menu.addItem(new WatchUi.ToggleMenuItem("Settings4", null, 4, true, null));

        WatchUi.pushView(menu, new SettingsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    public function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

}

class SettingsMenu extends WatchUi.Menu2 {
    //! Constructor
    public function initialize() {
        Menu2.initialize({:title=>"Settings"});
    }
}

//! Input handler for the app settings menu
class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    //! Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    //! Handle a menu item being selected
    //! @param menuItem The menu item selected
    public function onSelect(menuItem as MenuItem) as Void {
        

    }
}
    

