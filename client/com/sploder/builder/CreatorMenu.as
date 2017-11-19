package com.sploder.builder 
{
	
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setInterval;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CreatorMenu {
		
		protected var _creator:Creator;
		protected var _container:Sprite;
		
		protected var _saveEnabled:Boolean = false;
		protected var _saveAsEnabled:Boolean = false;
		protected var _publishEnabled:Boolean = false;
		
		protected var _saveToggle:MovieClip;
		protected var _saveAsToggle:MovieClip;
		protected var _publishToggle:MovieClip;
		protected var _testMenu:Sprite;
		protected var _testMenuInterval:Number;
		
		public function get saveEnabled():Boolean { return _saveEnabled; }
		public function set saveEnabled(value:Boolean):void 
		{
			_saveEnabled = value;
			_saveToggle.gotoAndStop(_saveEnabled ? 2 : 1);
			_saveToggle["btn"].visible = _saveEnabled;
			
		}
		
		public function get saveAsEnabled():Boolean { return _saveAsEnabled; }
		public function set saveAsEnabled(value:Boolean):void 
		{
			_saveAsEnabled = value;
			_saveAsToggle.gotoAndStop(_saveAsEnabled ? 2 : 1);
			_saveAsToggle["btn"].visible = _saveAsEnabled;
		}
		
		public function get publishEnabled():Boolean { return _publishEnabled; }
		public function set publishEnabled(value:Boolean):void 
		{
			_publishEnabled = value;
			_publishToggle.gotoAndStop(_publishEnabled ? 2 : 1);
			_publishToggle["btn"].visible = _publishEnabled;
		}
		

		//
		//
		public function CreatorMenu(creator:Creator, container:Sprite) {
			
			init(creator, container);
			
		}
		
		//
		//
		protected function init (creator:Creator, container:Sprite):void {
			
			_creator = creator;
			_container = container;

			var button:SimpleButton;
	
			for (var i:int = 0; i < _container.numChildren; i++) {
				
				if (_container.getChildAt(i) is SimpleButton) {
					
					button = _container.getChildAt(i) as SimpleButton;
					button.addEventListener(MouseEvent.CLICK, onButtonClick);
					
				}
				
				if (_container.getChildAt(i) is MovieClip) {
					
					MovieClip(_container.getChildAt(i)).gotoAndStop(1);
					
					if (_container.getChildAt(i)["btn"] != null && _container.getChildAt(i)["btn"] is SimpleButton) {
						
						button = _container.getChildAt(i)["btn"];
						button.addEventListener(MouseEvent.CLICK, onButtonClick);
						
					}
					
					switch (_container.getChildAt(i).name) {
						
						case "savetoggle":
							_saveToggle = _container.getChildAt(i) as MovieClip;
							break;
						case "saveastoggle":
							_saveAsToggle = _container.getChildAt(i) as MovieClip;
							break;
						case "publishtoggle":
							_publishToggle = _container.getChildAt(i) as MovieClip;
							break;
						case "testmenu":
							_testMenu = _container.getChildAt(i) as MovieClip;
							_testMenu.visible = false;
							for (var j:int = 0; j < _testMenu.numChildren; j++) {
								if (_testMenu.getChildAt(j) is SimpleButton) { 
									button = _testMenu.getChildAt(j) as SimpleButton;
									button.addEventListener(MouseEvent.CLICK, onButtonClick);
								}
							}
							break;
		
					}
					
				}
				
			}

		}
		
		//
		//
		protected function onButtonClick (e:MouseEvent):void {
			
			var buttonName:String = e.target.name;
			
			if (buttonName == "btn") buttonName = e.target.parent.name;
			
			switch (buttonName) {
				
				case "newproject":
					requestNewProject();
					break;
					
				case "loadproject":
					
					requestLoadProject();
					break;
				
				case "savetoggle":
					if (_saveEnabled) _creator.project.requestSaveProject();
					break;
					
				case "saveastoggle":
					if (_saveAsEnabled) _creator.project.requestSaveProjectAs();
					break;

				case "testproject":
				
					var vparts:Array = Capabilities.version.split(" ")[1].split(",");
	
					if (parseInt(vparts[0]) < 10 && parseInt(vparts[2]) < 45) {
						_creator.ddserver.show("Testing will not work in this version of the Flash player.", '<a href="http://get.adobe.com/flashplayer/">CLICK HERE TO UPGRADE</a>');
					} else {
						showTestMenu();
					}
					break;
					
				case "testgame":
					hideTestMenu();
					_creator.project.testProject();
					break;
					
				case "testlevel":
					hideTestMenu();
					_creator.project.testProject(null, true);
					break;
					
				case "publishtoggle":
					hideTestMenu();
					if (_publishEnabled) _creator.project.publishGame();
					break;
				
			}
	
		}
		
		public function watchTestMenu ():void {
			
			if (_testMenu.mouseY > 120 || _testMenu.mouseX < -20 || _testMenu.mouseX > 160) {
				clearInterval(_testMenuInterval);
				_testMenu.visible = false;
			}
			
		}
		
		protected function hideTestMenu ():void {
			clearInterval(_testMenuInterval);
			_testMenu.visible = false;
		}
		
		protected function showTestMenu ():void {
			clearInterval(_testMenuInterval);
			_testMenu.visible = true;
			_testMenuInterval = setInterval(watchTestMenu, 250);
		}
		
		protected function requestNewProject ():void {
			
			if (Creator.playfield.objects.length > 1) {
				
				_creator.ddconfirm.show("Creating a new game will erase any unsaved game you are working on.");
				_creator.ddconfirm.addEventListener(CreatorDialogue.EVENT_CONFIRM, _creator.project.newProject);
				_creator.ddconfirm.addEventListener(CreatorDialogue.EVENT_CANCEL, _creator.project.newProject);
				
			} else {
				
				_creator.project.newProject();
				
			}
			
		}
		
		protected function requestLoadProject ():void {
			
			_creator.ddmanager.title = "Load a Platformer Game";
			_creator.ddmanager.mode = CreatorManager.MODE_LOAD;
			
			if (!_creator.demo && Creator.playfield.objects.length > 1) {
				
				_creator.ddconfirm.show("Loading an existing game will erase any unsaved game you are working on.");
				_creator.ddconfirm.addEventListener(CreatorDialogue.EVENT_CONFIRM, _creator.ddmanager.loadList);
				_creator.ddconfirm.addEventListener(CreatorDialogue.EVENT_CANCEL, _creator.ddmanager.loadList);

				
			} else {
				
				_creator.ddmanager.loadList();
				
			}
			
		}
	
	}
	
}