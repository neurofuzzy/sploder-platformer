package com.sploder.asui 
{
	import com.sploder.builder.Creator;
	import com.sploder.asui.Cell;
	import com.sploder.asui.Clip;
	import com.sploder.asui.HTMLField;
	import com.sploder.asui.Position;
	import com.sploder.asui.Style;
	import com.sploder.asui.Tween;
	import com.sploder.asui.TweenManager;
	import flash.display.InteractiveObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author ...
	 */
	public class Prompt extends Sprite
	{
		public static var mainInstance:Prompt;
		public static var buttonTexts:Dictionary;
		public static var defaultMessage:String = "";
		public static var permaMessage:String = "";
		
		public static var tweener:TweenManager;
		
		protected var _cell:Cell;
		protected var _message:HTMLField;
		
		public var style:Style;
		
		public var tween:Boolean = true;
		public var promptWidth:int = 580;
		public var promptHeight:int = 45;
		public var promptRound:int = 0;
		public var promptTopMargin:int = 22;
		public var align:String = "center";
		
		public function Prompt () 
		{
			super();
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		protected function init (e:Event = null):void {
			
			if (e) stage.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			if (tweener == null) tweener = new TweenManager(true);
			
			_cell = new Cell(this, promptWidth, promptHeight, true, false, promptRound, null, style);
			_cell.mouseEnabled = false;
			_message = new HTMLField(null, '<p align="' + align + '">Watch this space for instructions as you use the game creator.</p>', promptWidth, false, new Position( { margin_top: promptTopMargin } ), style);
			_cell.addChild(_message);
			if (tween) _cell.y = 0 - _cell.height;
			
			mainInstance = this;
			
		}
		
		public function show (message:String):void {
			
			if (message.length) {
				_message.value =  '<p align="' + align + '"><b>' + message + '</b></p>';
			}
			
			if (tween) {
				
				tweener.removeTweensOnObject(_cell);
				tweener.createTween(_cell, "y", _cell.y, 0, 0.5, 
					false, false, 0, 0, 
					Tween.EASE_OUT, Tween.STYLE_CUBIC, 
					null, hide);
				
			}
			
		}
		
		public function hide (tween:Tween = null):void {
			
			if (tween) {
				tweener.removeTweensOnObject(_cell);
				tweener.createTween(_cell, "y", _cell.y, 0 - _cell.height, 0.5, 
					false, false, 0, (tween) ? 3 : 0, 
					Tween.EASE_IN, Tween.STYLE_CUBIC);
			} else {
				_message.value = "";
			}
			
		}
		
				
		public static function prompt (message:String = ""):void {
			
			if (permaMessage.length) {
				mainInstance.show(permaMessage);
				return;
			}
			
			if (mainInstance && message.length) mainInstance.show(message);
			else if (mainInstance && defaultMessage.length) mainInstance.show(defaultMessage);
			else if (mainInstance) mainInstance.hide();
			
		}
		
		public static function connectButton (button:InteractiveObject, text:String):void {
			
			if (button) {
				
				button.addEventListener(MouseEvent.ROLL_OVER, onButtonOver, false, 0, true);
				button.addEventListener(MouseEvent.ROLL_OUT, onButtonOut), false, 0, true;
				
				if (buttonTexts == null) buttonTexts = new Dictionary(true);
				
				buttonTexts[button] = text;
			
			}
			
		}
		
		public static function onButtonOver (e:MouseEvent):void {
			
			if (buttonTexts[e.target]) prompt(buttonTexts[e.target]);
			
		}
		
		public static function onButtonOut (e:MouseEvent):void {
			
			if (permaMessage.length) {
				mainInstance.show(permaMessage);
				return;
			}
			
			if (mainInstance && defaultMessage.length) mainInstance.show(defaultMessage);
			else if (mainInstance) mainInstance.hide();
			
		}
		
	}

}