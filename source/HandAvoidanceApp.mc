import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class HandAvoidanceApp extends Application.AppBase {

    function initialize() {
        // Field 1 setting
        if (Storage.getValue(1) == null || !(Storage.getValue(1) instanceof Number)) {
            Storage.setValue(1, 1);
        }
        // Field 2 setting
        if (Storage.getValue(2) == null || !(Storage.getValue(2) instanceof Number)) {
            Storage.setValue(2, 2);
        }
        // Field 3 setting
        if (Storage.getValue(3) == null || !(Storage.getValue(3) instanceof Number)) {
            Storage.setValue(3, 3);
        }
        // UTC offest setting
        if (Storage.getValue(4) == null || !(Storage.getValue(4) instanceof Number)) {
            Storage.setValue(4, 4);
        }
        // inverted color setting
        if (Storage.getValue(5) == null || !(Storage.getValue(5) instanceof Boolean)) {
            Storage.setValue(5, false);
        }
        // Big number setting
        if (Storage.getValue(6) == null || !(Storage.getValue(6) instanceof Number)) {
            Storage.setValue(6, 0);
        }
        // Field 4 setting
        if (Storage.getValue(7) == null || !(Storage.getValue(7) instanceof Number)) {
            Storage.setValue(7, 0);
        }
        AppBase.initialize();
    }

    // Return the initial view of your application here
    function getInitialView()  {
        return [ new HandAvoidanceView() ] ;
    }

    public function getSettingsView()  {
        return [new HandAvoidanceSettings(), new HandAvoidanceSettingsDelegate()] ;
    }

    function onSettingsChanged() {
        // System.println("Settings Changed");
    }

}