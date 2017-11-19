package com.sploder.asui {
    
	import com.sploder.asui.*;
    
	import flash.display.Sprite;
	import flash.events.Event;
	
    /**
    * ...
    * @author $(DefaultUser)
    */
    
    
    public class Slider extends Cell {

        protected var _orientation:int;
        
        protected var _backing:BButton;
        protected var _dragger:BButton;
        protected var _snap:int = 0;
        
		protected var _sliderValue:Number;
		
        public function get sliderValue ():Number { 
            
            if (_snap > 0) return Math.round(_sliderValue * _snap) / _snap;
            else return _sliderValue; 
        
        }
        
        public function set sliderValue (value:Number):void {
            
            value = Math.min(1, Math.max(0, value));
            
            if (_orientation == Position.ORIENTATION_HORIZONTAL) _sliderValue = _dragger.valueX = value;
            else _sliderValue = _dragger.valueY = value;
			
			if (form != null && name.length > 0) form[name] = value;
            
        }
        
        private var _ratio:Number = 1;
        public function get ratio():Number { return _ratio; }
        public function set ratio (r:Number):void {
            
            _ratio = Math.min(1, Math.max(0, r));
            
            if (_orientation == Position.ORIENTATION_HORIZONTAL) _dragger.resize(Math.max(_height, Math.ceil(_width * _ratio)), _height);
            else _dragger.resize(_width, Math.max(_width, Math.ceil(_height * _ratio)));
            
        }
		
		public var showGradient:Boolean = false;

        //
        //
        public function Slider (container:Sprite, width:Number, height:Number, orientation:int = 13, snap:int = 0, position:Position = null, style:Style = null) {
            
            init_Slider(container, width, height, orientation, snap, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        private function init_Slider (container:Sprite, width:Number, height:Number, orientation:int = 13, snap:int = 0, position:Position = null, style:Style = null):void {

            super.init_Cell(container, _width, _height, false, false, 0, position, style);
            
			_type = "slider";
			
            _orientation = orientation;
            _width = width;
            _height = height;
            _snap = snap;
			
        }
        
        //
        //
        override public function create ():void {
            
            super.create();
			
            var backingStyle:Style = _style.clone({ gradient: false });
			
			if (!showGradient) {
				backingStyle.border = false;
				backingStyle.borderWidth = 0;
				backingStyle.round = 0;
				backingStyle.backgroundColor = _style.buttonColor;
				backingStyle.backgroundAlpha = 50;
			} else {
				_border = true;
				backingStyle.background = false;
				backingStyle.border = false;
				background = true;
			}
            
            _backing = BButton(addChild(new BButton(null, "", -1, _width, _height, false, false, true, null, backingStyle)));
            _backing.addEventListener(EVENT_PRESS, onSliderClick);
    
            var draggerStyle:Style = _style.clone();
            draggerStyle.borderWidth = 2;
            draggerStyle.borderColor = ColorTools.getTintedColor(_style.buttonColor, _style.backgroundColor, 0.75);
            draggerStyle.backgroundColor = _style.buttonColor;
            
            _dragger = BButton(addChild(new BButton(null, "", -1, _width, _height, false, false, true, null, draggerStyle)));
            _dragger.addEventListener(EVENT_CHANGE, onSliderMove);
            _dragger.addEventListener(EVENT_RELEASE, onSliderRelease);
    
        }
        
        //
        //
        public function onSliderClick (e:Event):void {

            
            if (_orientation == Position.ORIENTATION_HORIZONTAL) {
            
                if (_mc.mouseX < _dragger.x) _dragger.valueX -= _dragger.width / width;
                else if (_mc.mouseX > _dragger.x + _dragger.width) _dragger.valueX += _dragger.width / width;
                
                _sliderValue = _dragger.valueX;
                
            } else {
                
                if (_mc.mouseY < _dragger.y) _dragger.valueY -= _dragger.height / height;
                else if (_mc.mouseY > _dragger.y + _dragger.height) _dragger.valueY += _dragger.height / height;
                 
                _sliderValue = _dragger.valueY;
                
            }
            
            dispatchEvent(new Event(EVENT_CHANGE));
            
        }
        
        //
        //
        public function onSliderMove (e:Event):void {
            
            if (_orientation == Position.ORIENTATION_HORIZONTAL) _sliderValue = BButton(e.target).valueX;
            else _sliderValue = BButton(e.target).valueY;
            
            dispatchEvent(new Event(EVENT_CHANGE));
			
        }
        
        //
        //
        public function onSliderRelease (e:Event):void {
    
            if (_snap > 0) sliderValue = Math.round(_sliderValue * _snap) / _snap;
            
        }
        
    }
}
