package com.sploder.builder.ui 
{
	import com.sploder.builder.Creator;
	import com.sploder.builder.CreatorMain;
	import com.sploder.builder.Styles;
	import com.sploder.asui.Component;
	import com.sploder.asui.DialogueBox;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Dialogue extends EventDispatcher
	{
		public static var currentDialogue:Dialogue;
		
		protected var _creator:Creator;
		
		protected var _width:int;
		protected var _height:int;
		protected var _title:String = "";
		protected var _buttons:Array;
		
		public var scroll:Boolean = false;
		public var round:Number = 0;
		public var contentPadding:int = 20;
		
		protected var _contentCreated:Boolean = false;
		
		public var dbox:DialogueBox;
		
		public function Dialogue (creator:Creator, width:int = 300, height:int = 300, title:String = "Title", buttons:Array = null) 
		{
			init(creator, width, height, title, buttons);
		}
		
		protected function init (creator:Creator, width:int = 300, height:int = 300, title:String = "Title", buttons:Array = null):void {
			
			_creator = creator;
			_width = width;
			_height = height;
			_title = title;
			
			if (buttons) _buttons = buttons;
			else _buttons = ["CANCEL", "APPLY"];
			
		}
		
		public function create ():void {
			
			dbox = new DialogueBox(null, 
				_width, _height, 
				_title, 
				_buttons,
				scroll, round,
				Styles.dialoguePosition,
				Styles.dialogueStyle);
					
			dbox.contentPadding = contentPadding;
			dbox.contentBottomMargin = 40;
				
		}
		
		protected function getSettings ():void {
			
		}
		
		protected function applyChanges ():void {
			
		}
		
		protected function onClick (e:Event):void {
			
		}
		
		public function show ():void {
			
			if (currentDialogue) currentDialogue.hide();
			_creator.ddGraphics.hide();
			_creator.ddLevelName.hide();
			currentDialogue = this;
			
			getSettings();
			dbox.show();
			
		}
		
		public function hide ():void {
			
			dbox.hide();
			CreatorMain.mainStage.focus = Component.mainStage;
			
		}
		
	}

}