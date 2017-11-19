package com.sploder.builder 
{
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CreatorHelp {
		
		public static var textfield:TextField;
		protected static var _help:Dictionary;
		
		//
		//
		public static function prompt (msg:String):void {
			
			if  (textfield != null) textfield.text = msg;
			
		}
		
		//
		//
		public static function assignButtonHelp (button:SimpleButton, helpText:String):void {
			
			if (_help == null) _help = new Dictionary(true);
			
			_help[button] = helpText;
			
			if (!button.hasEventListener(MouseEvent.ROLL_OVER)) {
				
				button.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
				button.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
				button.addEventListener(MouseEvent.MOUSE_OUT, onRollOut);
				
			}
			
		}
		
		//
		//
		protected static function onRollOver (e:MouseEvent):void {
			
			if (_help[e.target] != null && textfield != null) textfield.text = _help[e.target];
			
		}
		
		//
		//
		protected static function onRollOut (e:MouseEvent):void {
			
			textfield.text = "";
			
		}
		
	}
	
}