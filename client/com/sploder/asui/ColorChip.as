package com.sploder.asui {
	
    import com.sploder.asui.*;
	import flash.display.Graphics;
	
	import flash.display.Sprite;
    
    /**
    * ...
    * @author $(DefaultUser)
    */
    
    public class ColorChip extends Component {

		protected var _chip:Sprite;
		protected var _color:int;
		
		public function get color():int { return _color; }
		
		public function set color(value:int):void 
		{
			_color = value;
			draw();
		}
		
        //
        //
        public function ColorChip(container:Sprite = null, color:int = 0x000000, width:Number = NaN, height:Number = NaN, position:Position = null, style:Style = null) {
            
            init_ColorChip (container, color, width, height, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        private function init_ColorChip (container:Sprite = null, color:int = 0x000000, width:Number = NaN, height:Number = NaN, position:Position = null, style:Style = null):void {
            
            super.init(container, position, style);
			
			_type = "colorchip";
            
            _width = (!isNaN(width)) ? width : 16;
            _height = (!isNaN(width)) ? height : 16;
			
			_color = color;
            
        }
        
        //
        //
        override public function create ():void {
            
            super.create();
			
			_chip = new Sprite();
			_mc.addChild(_chip);
			
			draw();
 
        }
		
		//
		//
		protected function draw ():void {
			
			var g:Graphics = _chip.graphics;
			
			g.beginFill(_style.borderColor, 1);
			g.drawRect(0, 0, _width, _height);
			g.endFill();
			
			g.beginFill(_color, 1);
			g.drawRect(2, 2, _width - 4, _height - 4);
			g.endFill();
			
		}
        
    }
	
}
