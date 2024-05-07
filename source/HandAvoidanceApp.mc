import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class HandAvoidanceApp extends Application.AppBase {

    function initialize() {
        if (Storage.getValue(1) == null || !(Storage.getValue(1) instanceof Number)) {
            Storage.setValue(1, 1);
        }
        if (Storage.getValue(2) == null || !(Storage.getValue(2) instanceof Number)) {
            Storage.setValue(2, 2);
        }
        if (Storage.getValue(3) == null || !(Storage.getValue(3) instanceof Number)) {
            Storage.setValue(3, 3);
        }
        if (Storage.getValue(4) == null || !(Storage.getValue(4) instanceof Number)) {
            Storage.setValue(4, 4);
        }
        AppBase.initialize();
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new HandAvoidanceView() ] as Array<Views>;
    }

    public function getSettingsView() as Array<Views or InputDelegates>? {
        return [new HandAvoidanceSettings(), new HandAvoidanceSettingsDelegate()] as Array<Views or InputDelegates>;
    }

}