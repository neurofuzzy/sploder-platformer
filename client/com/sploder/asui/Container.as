package com.sploder.asui {
	
    import com.sploder.asui.*;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;

	import flash.display.DisplayObject;
	import flash.display.Sprite;

    /**
    * ...
    * @author $(DefaultUser)
    */
    
    
    public class Container extends Component {
        
        private var _alt:String = "";
        public function get alt ():String { return _alt; }
        public function set alt (value:String):void { _alt = value; }
		
		protected var _clip:DisplayObject;
		public function get clip():DisplayObject { return _clip; }
		
		public function set clip(obj:DisplayObject):void {
			if (_clip != null && _clip.parent == _mc) _mc.removeChild(_clip);
			_clip = obj;
			if (_clip is DisplayObject) _mc.addChild(_clip);
		}

        protected var _altTimes:int = 0;
		
        //
        //
        public function Container(container:Sprite, clip:DisplayObject = null, altTag:String = "", position:Position = null, style:Style = null) {
            
            init_Container (container, clip, altTag, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        private function init_Container (container:Sprite, clip:DisplayObject = null, altTag:String = "", position:Position = null, style:Style = null):void {
            
            super.init(container, position, style);

			_type = "container";
			
			_clip = clip;
			
			if (_clip != null) {
				_width = _clip.width;
				_height = _clip.height;
			}
    
            if (altTag.length > 0) _alt = altTag;
            
        }
        
        //
        //
        override public function create ():void {
            
            super.create();
            
			if (_clip != null) _mc.addChild(_clip);

			if (_clip != null && _clip["btn"] != undefined) {
				if (_clip["btn"] is SimpleButton) connectSimpleButton(_clip["btn"]);
				if (_clip["btn"] is Sprite) connectButton(_clip["btn"]);
			}
            
        }
        
        //
        //
        override protected function onRollOver(e:MouseEvent = null):void {
			
			super.onRollOver(e);

			_altTimes++;
			
            if (_alt.length > 0 && _altTimes <= 7) Tagtip.showTag(_alt);
    
        }
        
        //
        //
        override protected function onRollOut(e:MouseEvent = null):void 
		{
			super.onRollOut(e);
  
            Tagtip.hideTag();
            
        }
   
    }
	
}
