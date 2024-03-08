import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class HandAvoidanceApp extends Application.AppBase {

    function initialize() {
        if (Storage.getValue(1) == null) {
            Storage.setValue(1, false);
        }
        if (Storage.getValue(2) == null) {
            Storage.setValue(2, false);
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