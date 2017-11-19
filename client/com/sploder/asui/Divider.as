package com.sploder.asui {
	
	import flash.display.Sprite;
    
    /**
    * ...
    * @author $(DefaultUser)
    */
    
    public class Divider extends Component {

		protected var _vertical:Boolean = true;
		
        //
        //
        public function Divider(container:Sprite = null, width:Number = NaN, height:Number = NaN, vertical:Boolean = true, position:Position = null, style:Style = null) {
            
            init_Divider (container, width, height, vertical, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        private function init_Divider (container:Sprite = null, width:Number = NaN, height:Number = NaN, vertical:Boolean = true, position:Position = null, style:Style = null):void {
            
            super.init(container, position, style);
			
			_type = "divider";
            
			_vertical = vertical;

			if (_vertical) {
				
				_width = Math.max(2, Math.floor(_style.borderWidth));
				_height = height;
				if (_position != null && _position.placement == Position.PLACEMENT_NORMAL) {
					_position = _position.clone( { placement: Position.PLACEMENT_FLOAT, clear: Position.CLEAR_NONE } );
				} else if (_position == null) {
					_position = new Position(null, -1, Position.PLACEMENT_FLOAT, Position.CLEAR_NONE);
				}
				
			} else {
	
				_width = width;
				_height = Math.max(2, Math.floor(_style.borderWidth));
				if (_position != null && _position.clear != Position.CLEAR_BOTH) {
					_position = _position.clone( { clear: Position.CLEAR_BOTH } );
				} else if (_position == null) {
					_position = new Position(null, -1, Position.PLACEMENT_NORMAL, Position.CLEAR_BOTH);
				}
				
			}
            
        }
        
        //
        //
        override public function create ():void {
            
            super.create();
            
            if (isNaN(_height) || _height == 0) _height = _parentCell.height - _position.margin_top - _position.margin_bottom;

			if (_style.borderWidth == 0) {
				
				DrawingMethods.rect(_mc, true, 0, 0, _width / 2, _height, 0x000000, 0.4);
				DrawingMethods.rect(_mc, false, _width / 2, 0, _width / 2, _height, 0xffffff, 0.4);
				
			} else {
				
				DrawingMethods.rect(_mc, true, 0, 0, _width, _height, ColorTools.getTintedColor(_style.borderColor, _style.backgroundColor, 0.5));
				
			}
			
			
            
        }
        
    }
}
