package com.sploder.asui {
	
    import com.sploder.asui.*;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import flash.display.Sprite;
    
    /**
    * ...
    * @author $(DefaultUser)
    */
    
    public class HRule extends Component {

		public var dotted:Boolean = false;
		
        //
        //
        public function HRule(container:Sprite = null, width:Number = NaN, position:Position = null, style:Style = null) {
            
            init_HRule (container, width, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        private function init_HRule (container:Sprite = null, width:Number = NaN, position:Position = null, style:Style = null):void {
            
            super.init(container, position, style);
			
			_type = "hrule";
            
            _width = width;
            _height = Math.max(1, Math.floor(_style.borderWidth * 0.5));
            
        }
        
        //
        //
        override public function create ():void {
            
            super.create();
  
            if (isNaN(_width)) _width = _parentCell.width - _position.margin_left - _position.margin_right;
    
			if (!dotted) {
					
				DrawingMethods.rect(_mc, true, 0, 0, _width, _height, ColorTools.getTintedColor(_style.borderColor, _style.backgroundColor, 0.5));
            
			} else {
				
				var bmp:Bitmap = new Bitmap();
				bmp.bitmapData = new BitmapData(_width, 1, true, 0);
				
				for (var i:int = 0; i <= bmp.bitmapData.width; i += 2) bmp.bitmapData.setPixel32(i, 0, 0x99000000 + _style.borderColor);
				
				_mc.addChild(bmp);
				
			}
            
        }
        
    }
}
