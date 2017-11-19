package com.sploder.builder 
{
	
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CreatorButtons {
		
		public static const MODE_SELECT:int = 1;
		public static const MODE_PAN:int = 2;
		
		protected var _creator:Creator;
		protected var _container:Sprite;
		
		protected var _deleteToggle:MovieClip;
		public function get deleteToggle():MovieClip { return _deleteToggle; }
		
		protected var _zoomInToggle:MovieClip;
		public function get zoomInToggle():MovieClip { return _zoomInToggle; }
		
		protected var _zoomOutToggle:MovieClip;
		public function get zoomOutToggle():MovieClip { return _zoomOutToggle; }

		protected var _zoomAllToggle:MovieClip;
		public function get zoomAllToggle():MovieClip { return _zoomAllToggle; }
		
		protected var _navSelectToggle:MovieClip;
		public function get navSelectToggle():MovieClip { return _navSelectToggle; }
		
		protected var _navPanToggle:MovieClip;
		public function get navPanToggle():MovieClip { return _navPanToggle; }
		
		protected var _picker:SimpleButton;
	

		//
		//
		public function CreatorButtons(creator:Creator, container:Sprite) {
			
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
					
					if (button.name == "picker") {
						_picker = _container.getChildAt(i) as SimpleButton;
						CreatorHelp.assignButtonHelp(_picker, "Click to edit your game background and colors.");
					}
					
					if (button.name == "texture") {
						_picker = _container.getChildAt(i) as SimpleButton;
						CreatorHelp.assignButtonHelp(_picker, "Click to open the Tile Explorer.");
					}
					
				}
				
				if (_container.getChildAt(i) is MovieClip) {

					MovieClip(_container.getChildAt(i)).gotoAndStop(1);
					
					if (_container.getChildAt(i)["btn"] != null && _container.getChildAt(i)["btn"] is SimpleButton) {

						button = _container.getChildAt(i)["btn"];
						button.addEventListener(MouseEvent.CLICK, onButtonClick);
						
					}
					
					switch (_container.getChildAt(i).name) {
						
						case "zoomin":
							_zoomInToggle = _container.getChildAt(i) as MovieClip;
							CreatorHelp.assignButtonHelp(_zoomInToggle["btn"], "Click to zoom in to your playfield.");
							break;
						case "zoomout":
							_zoomOutToggle = _container.getChildAt(i) as MovieClip;
							CreatorHelp.assignButtonHelp(_zoomOutToggle["btn"], "Click to zoom your playfield out.");
							break;
						case "zoomall":
							_zoomAllToggle = _container.getChildAt(i) as MovieClip;
							CreatorHelp.assignButtonHelp(_zoomAllToggle["btn"], "Click to see all of your playfield.");
							break;
						case "navselect":
							_navSelectToggle = _container.getChildAt(i) as MovieClip;
							CreatorHelp.assignButtonHelp(_navSelectToggle["btn"], "Click to make dragging the mouse draw a window that selects multiple objects.");
							break;
						case "navpan":
							_navPanToggle = _container.getChildAt(i) as MovieClip;
							CreatorHelp.assignButtonHelp(_navPanToggle["btn"], "Click to make dragging the mouse move the playfield.");
							break;
						case "deletetoggle":
							_deleteToggle = _container.getChildAt(i) as MovieClip;
							CreatorHelp.assignButtonHelp(_deleteToggle["btn"], "Click to delete the selected object.");
							break;
		
					}
					
				}
				
			}

		}
		
		//
		//
		public function setSelectionListeners ():void {
			
			Creator.playfield.selection.addEventListener(CreatorSelection.SELECTED, onSelection);	
			
		}
		
		//
		//
		protected function onButtonClick (e:MouseEvent):void {
			
			var buttonName:String = e.target.name;

			if (buttonName == "btn") buttonName = e.target.parent.name;

			switch (buttonName) {
				
				case "zoomin":
					if (_zoomInToggle.currentFrame == 2) Creator.navigator.zoomMap(1);
					break;
				case "zoomout":
					if (_zoomOutToggle.currentFrame == 2) Creator.navigator.zoomMap(0);
					break;
				case "zoomall":
					if (_zoomAllToggle.currentFrame == 2) Creator.navigator.zoomFull();
					break;
				case "deletetoggle":
					if (_deleteToggle.currentFrame == 2) Creator.playfield.removeObjects();
					break;
				case "navselect":
					setNavMode(MODE_SELECT);
					break;
				case "navpan":
					setNavMode(MODE_PAN);
					break;	
				case "picker":
					_creator.ddenvironment.show();
					break;
				case "texture":
					_creator.ddtexture.show();
					break;
				
			}
	
		}
		
        //
        //
        //
        public function deleteEnable ():void {

            _deleteToggle.gotoAndStop(2);
			SimpleButton(_deleteToggle["btn"]).mouseEnabled = true;
            
        }
        
        //
        //
        //
        public function deleteDisable ():void {
            
            _deleteToggle.gotoAndStop(1);
			SimpleButton(_deleteToggle["btn"]).mouseEnabled = false;
            
        }
		
		//
		//
		protected function onSelection (e:Event):void { 
			
			if (Creator.playfield.selection.objects.length > 0) {
					
				deleteEnable();
					
			} else {
				
				deleteDisable();
				
			}
			
		}
		
		//
		//
		public function setNavMode (mode:int):void {
			
			switch (mode) {
				
				case MODE_PAN:
				
					_navSelectToggle.gotoAndStop(2);
					_navPanToggle.gotoAndStop(1);
					Creator.navigator.active = true;
					Creator.playfield.selection.active = false;
					CreatorHelp.assignButtonHelp(Creator.navigator.navButton, "Drag to move the playfield, double-click to switch modes");
					break;
				
				case MODE_SELECT:
				
					_navSelectToggle.gotoAndStop(1);
					_navPanToggle.gotoAndStop(2);
					Creator.navigator.active = false;
					Creator.playfield.selection.active = true;
					CreatorHelp.assignButtonHelp(Creator.navigator.navButton, "Drag a window to select objects, double-click to switch modes");
					break;
				
				
			}
			
		}
		
		//
		//
		public function toggleNavMode (e:MouseEvent):void {
			
			if (Creator.navigator.active) {
				setNavMode(MODE_SELECT);
				CreatorHelp.prompt("Drag a window to select objects, double-click to switch modes");
			} else {
				setNavMode(MODE_PAN);
				CreatorHelp.prompt("Drag to move the playfield, double-click to switch modes");
			}
	
		}
	
	}
	
}