import Toybox.WatchUi;
import Toybox.Graphics;

class SecondHandDrawable extends WatchUi.Drawable {

    private var _color, _xCoord, _yCoord;
    private var _visible = false;

    public function initialize(params) {
        // You should always call the parent's initializer and
        // in this case you should pass the params along as size
        // and location values may be defined.
        Drawable.initialize(params);

        // Get any extra values you wish to use out of the params Dictionary
        _color = params.get(:color);
        _xCoord = params.get(:x);
        _yCoord = params.get(:y);
    }

    function draw(dc as Dc) as Void {
        if (_visible) {
            dc.setColor(_color, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(_xCoord, _yCoord, 6);
        }
    }

    function setLocation(x as $.Toybox.Lang.Numeric, y as $.Toybox.Lang.Numeric) as Void {
        _xCoord = x;
        _yCoord = y;
    }

    function setColor(color as  Toybox.Lang.Number) as Void {
        _color = color;
    }

    function setVisible(visibility as  Toybox.Lang.Boolean) as Void {
        _visible = visibility;
    }
}