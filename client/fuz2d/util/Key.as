/**
* ...
* @author Default
* @version 0.1
*/

package fuz2d.util {
	
    import flash.display.Stage;
    import flash.events.*;
	import flash.ui.Keyboard;
    
    /**
     * The Key class recreates functionality of
     * Key.isDown of ActionScript 1 and 2. Before using
     * Key.isDown, you first need to initialize the
     * Key class with a reference to the stage using
     * its Key.initialize() method. For key
     * codes use the flash.ui.Keyboard class.
     *
     * Usage:
     * Key.initialize(stage);
     * if (Key.isDown(Keyboard.LEFT)) {
     *    // Left key is being pressed
     * }
     */
	
	public class Key extends EventDispatcher {
		
		public static const KEY_DOWN:String = KeyboardEvent.KEY_DOWN;
		public static const KEY_UP:String = KeyboardEvent.KEY_UP;
		
		public static var stage:Stage;
		
        private static var initialized:Boolean = false;  // marks whether or not the class has been initialized
        private static var keysDown:Object = {};  // stores key codes of all keys pressed
		private static var _shiftDown:Boolean = false;
		private static var _ctrlDown:Boolean = false;
		
		public static function get TAB ():uint { return Keyboard.TAB; }
		
		public static function get SPACE ():uint { return Keyboard.SPACE; }
		
		public static function get DELETE ():uint { return Keyboard.DELETE; }
		
        
        /**
         * Initializes the key class creating assigning event
         * handlers to capture necessary key events from the stage
         */
        public static function initialize(stageRef:Stage):void {
			
			stage = stageRef;
			
            if (!initialized) {
				
                // assign listeners for key presses and deactivation of the player
                stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed, false, 0, true);
                stage.addEventListener(KeyboardEvent.KEY_UP, keyReleased, false, 0, true);
                stage.addEventListener(Event.DEACTIVATE, clearKeys, false, 0, true);
                
                // mark initialization as true so redundant
                // calls do not reassign the event handlers
                initialized = true;
				
            }
			
        }
        
        //
		//
        public static function isDown(keyCode:uint, caseSensitive:Boolean = false):Boolean {
			
            if (!initialized) {
				
                // throw an error if isDown is used
                // prior to Key class initialization
                throw new Error("Key class has yet been initialized.");
				
            }
			
			if (!caseSensitive) if (keyCode >= 97 && keyCode <= 122) keyCode -= 32;
			
            return Boolean(keyCode in keysDown);
			
        }
		
        //
		//
        public static function charIsDown(char:String):Boolean {
			
            if (!initialized) {
				
                // throw an error if isDown is used
                // prior to Key class initialization
                throw new Error("Key class has yet been initialized.");
				
            }
			
            return Boolean(char.toUpperCase().charCodeAt(0) in keysDown);
			
        }
		
		//
		//
		public static function match (charCode:int, char:String, caseSensitive:Boolean = false):Boolean { 
			
			if (caseSensitive) {
				
				return (charCode == char.charCodeAt[0]);
				
			} else {
				
				var code:int = (charCode >= 97 && charCode <= 122) ? charCode - 32 : charCode;
				
				return (code == char.toUpperCase().charCodeAt(0));
			
			}
			
		}
        
        //
		//
        private static function keyPressed(event:KeyboardEvent):void {
			
			if (event.shiftKey) _shiftDown = true;
			if (event.ctrlKey) _ctrlDown = true;
            keysDown[event.keyCode] = true;
			
        }
        
        //
		//
        private static function keyReleased(event:KeyboardEvent):void {
			
            if (event.keyCode in keysDown) {
                // delete the property in keysDown if it exists
                delete keysDown[event.keyCode];
            }
			
			if (event.keyCode == Keyboard.SHIFT) {
				_shiftDown = false;
			} else if (event.keyCode == Keyboard.CONTROL) {
				_ctrlDown = false;
			}
			
        }
        
		//
		//
        private static function clearKeys(event:Event):void {
			
            keysDown = {};
			
        }
		
		//
		public static function get shiftKey ():Boolean {
			return _shiftDown;
		}
		
		//
		public static function get ctrlKey ():Boolean {
			return _ctrlDown;
		}
	
		public static function reset ():void {
			
			keysDown = { };
			
		}
	}
	
}
