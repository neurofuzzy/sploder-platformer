package com.sploder.builder 
{
	
	import com.sploder.asui.Cell;
	import com.sploder.asui.Container;
	import com.sploder.asui.Position;
	import com.sploder.asui.ScrollBar;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.sploder.builder.CreatorFactory;
	import fuz2d.library.EmbeddedLibrary;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CreatorObjectTray {
		
		protected var _creator:Creator;
		
		protected var _container:Sprite;
		protected var _contentContainer:Sprite;
		protected var _categoriesClip:MovieClip;
		protected var _currentCategory:Cell;
		
		protected var _contents:Object;
		
		protected var _contentCell:Cell;
		
		public function get clip():Sprite { return _container; }
		
		protected const types:Array = ["block", "blockbehind", "hazard", "tool", "powerup", "trigger", "player"];
		protected const categories:Array = ["block", "blockbehind", "hazard", "powerup", "powerup", "trigger", "none"];

		protected var _adders:Array = [];
		public function get adders():Array { return _adders; }
				
		//
		//
		public function CreatorObjectTray(creator:Creator, container:Sprite) {
			
			init(creator, container);
			
		}
		
		//
		//
		protected function init (creator:Creator, container:Sprite):void {
			
			_creator = creator;
			_container = container;
			_contents = { };
			
			rigUI();
			populate();
			
		}
		
		//
		//
		protected function rigUI ():void {
			
			var i:int;
			var contentClip:Cell;
			var contentSB:ScrollBar;
			
			_contentContainer = _container["content"];
			_categoriesClip = _container["categories"];
			
			_contentCell = new Cell(_container, 138, 360);
			
			for (i = 0; i < categories.length; i++) {
				
				if (_contents[categories[i]] == null) {
					
					contentClip = new Cell(null, 104, 360, false, false, 0, new Position({ placement: Position.PLACEMENT_ABSOLUTE }) );
					contentClip.name = categories[i];
					
					_contentCell.addChild(contentClip);
					
					_contents[categories[i]] = contentClip;
					
					contentSB = new ScrollBar();
					_contentCell.addChild(contentSB);
					contentSB.targetCell = contentClip;
					
					if (i == 0) {
						_currentCategory = contentClip;
					} else {
						contentClip.hide();
					}
					
				}
				
			}
			
			
			for (i = 0; i < _categoriesClip.numChildren; i++) {
				
				if (_categoriesClip.getChildAt(i) is SimpleButton) {
					
					SimpleButton(_categoriesClip.getChildAt(i)).addEventListener(MouseEvent.CLICK, onCategoryClick);
					CreatorHelp.assignButtonHelp(SimpleButton(_categoriesClip.getChildAt(i)), "Click to view and add objects in this category.");
					
				}
				
			}
			
			
			
			
		}
		
		//
		//
		protected function populate ():void {
			
			var pcat:String;
			var panel:Cell;
			var clip:CreatorObjectAdder;
			
			for each (var pobj:XML in CreatorFactory.objects) {
				
				pcat = categories[types.indexOf(String(pobj..@ctype))];
					
				if (pcat != "none" && _contents[pcat] != null) {
					
					panel = _contents[pcat] as Cell;
					clip = new CreatorObjectAdder(_creator, pobj);
					clip.name = pobj.@id;
					clip.version = (pobj.@version != undefined) ? parseInt(pobj.@version) : 1;
					_adders.push(clip);
					
					panel.addChild(new Container(null, clip, pobj.@calt, new Position( { margin_left: 10 } )));				
					
				}
				
			}
			
		}
		
		//
		//
		protected function onCategoryClick (e:MouseEvent):void {
			
			if (_currentCategory != null) _currentCategory.hide();
			
			_categoriesClip.gotoAndStop(e.target.name);
			_currentCategory = _contents[e.target.name] as Cell;

			_currentCategory.show();
			
		}
		
		//
		//
		public function updateAdders ():void {
			
			for each (var adder:CreatorObjectAdder in _adders) {
				
				if ((adder.unique && Creator.levels.hasObjectWithIDs([adder.id])) ||
					(adder.uniquegroup != null && Creator.levels.hasObjectWithIDs(adder.uniquegroup))) {
						
					adder.active = false;
					
					if (adder.unique) adder.check.visible = true;
					else if (Creator.levels.hasObjectWithIDs([adder.id])) adder.check.visible = true;
					
				} else {
					
					adder.active = true;
					
				}
				
			}
			
		}
		
		//
		//
		public function updateTextureAdders (val:String, back:Boolean = false):void {
			
			for each (var adder:CreatorObjectAdder in _adders) {
				
				if (adder.back == back) adder.updateTexture(val);
				
			}
			
		}
		

	}
	
}