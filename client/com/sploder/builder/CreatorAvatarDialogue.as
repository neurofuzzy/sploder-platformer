package com.sploder.builder 
{
	import com.sploder.asui.BButton;
	import com.sploder.asui.CheckBox;
	import com.sploder.asui.ColorPicker;
	import com.sploder.asui.Component;
	import com.sploder.asui.Create;
	import com.sploder.asui.Position;
	import com.sploder.asui.Slider;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import mx.core.ButtonAsset;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CreatorAvatarDialogue extends CreatorDialogue {
		
		private var _choices:Array;
		private var _heads:Array;
		private var _currentChoice:Sprite;
		private var _currentChoiceNum:int = 0;
		
		//
		public function CreatorAvatarDialogue(creator:Creator, container:Sprite) {
			
			super(creator, container);

		}
		
		//
		//
		override protected function init (creator:Creator, container:Sprite):void {
			
			super.init(creator, container);
			
			_choices = [];
			_heads = [];
			
			var choice:Sprite;
			var head:MovieClip;
			
			for (var i:int = 0; i < 9; i++) {
				
				choice = _container.getChildByName("avatar" + i) as Sprite;
				choice.getChildByName("selected").visible = false;
				choice.addEventListener(MouseEvent.CLICK, onChoice);
				_choices.push(choice);
				
				head = Creator.creatorlibrary.getDisplayObject("playerhead") as MovieClip;
				head.gotoAndStop(1);
				if (head.getChildByName("g2c")) MovieClip(head.getChildByName("g2c")).gotoAndStop(i * 5 + 1);
				head.scaleX = head.scaleY = 0.42;
				head.x = choice.x;
				head.y = choice.y + head.height * 0.45;
				head.mouseEnabled = head.mouseChildren = false;
				_container.addChild(head);
				_heads.push(head);
				
			}
			
			updateSettings();
			
			hide();
			
		}
		
		//
		//
		private function onChoice (e:MouseEvent):void {
			
			var choice_num:int = _choices.indexOf(e.currentTarget);
			
			if (choice_num >= 0)
			{
				if  (_currentChoice != null) _currentChoice.getChildByName("selected").visible = false;
				_currentChoice = _choices[choice_num];
				_currentChoice.getChildByName("selected").visible = true;
				_currentChoiceNum = choice_num;
			}
			
		}
		
		
		//
		//
		override protected function applySettings ():void {
			
			Creator.levels.avatar = _currentChoiceNum;
			Creator.playfield.player.setAvatar(_currentChoiceNum);
		}
		
		//
		//
		override public function updateSettings ():void {
			
			if (Creator.levels != null) _currentChoiceNum = Creator.levels.avatar;
			else _currentChoiceNum = 0;
			
			if  (_currentChoice != null) _currentChoice.getChildByName("selected").visible = false;
			_currentChoice = _choices[_currentChoiceNum];
			_currentChoice.getChildByName("selected").visible = true;
		}
		
		//
		//
		override public function show(msg:String = null, servermsg:String = null):void {
			
			super.show(msg, servermsg);
			
			updateSettings();
			
		}

	}
	
}