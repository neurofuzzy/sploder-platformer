/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.screen.shape {
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import fuz2d.Fuz2d;
	import fuz2d.library.ObjectFactory;

	import fuz2d.model.*;
	import fuz2d.model.object.*;
	import fuz2d.screen.*;
	import fuz2d.util.Geom2d;
	
	import flash.display.Sprite;
	import flash.utils.*;

	public class ViewButton extends ViewObject {
		
		protected var _rolloverFilter:GlowFilter;

		//
		//
		public function ViewButton (view:View, parentNode:ViewObject = null, objectRef:Object2d = null) {
			
			dobj = new Sprite();
			
			super(view, parentNode, objectRef);
			
			Sprite(dobj).mouseChildren = false;
			Sprite(dobj).mouseEnabled = false;
			Sprite(dobj).tabEnabled = false;
			Sprite(dobj).tabChildren = false;
			Sprite(dobj).buttonMode = false;
			
			if (parentNode != null) Sprite(parentNode.dobj).addChild(dobj);

		}
		
		
		//
		//
		override public function updateGraphics ():void {
			
			if (polygon != null) {
				
				polygon.redraw();
				return;
				
			} else {
				
				if (_objectRef is Biped) {
					
					if (_objectRef.symbolName == "player") {
						polygon = new PlayerDisplay(_view, this);
					} else {
						polygon = new BipedDisplay(_view, this);
					}
					
				} else if (_objectRef is Tile) {
					
					polygon = new AssetDisplay(_view, this);
					
					if (Tile(_objectRef).stampName.length == 0 && 
						Fuz2d.library.getTileDefinition(Tile(_objectRef).definitionID).cap) {
							dobj.opaqueBackground = true;
						}

				} else if (_objectRef is Symbol) {
					
					polygon = new AssetDisplay(_view, this);
					
				} else if (_objectRef is Face) {
					
					polygon = new Polygon(_view, this);
					
				} else if (_objectRef is Line2d) {
					
					polygon = new Line(_view, this);

				} else if (_objectRef is Circle2d) {
					
					polygon = new Circle(_view, this);
					
				} else if (_objectRef is Marker) {
					
					polygon = new Dot(_view, this);
					
				}
				
			}
			
			
			// check for mouse Listeners

			if (!objectRef.clickable && Sprite(dobj).mouseEnabled) {
		
				clickable = false;
				
			} else if (objectRef.clickable && Sprite(dobj).mouseEnabled == false) {
				
				clickable = true;
				
			}
						
		}
		
		//
		//
		override public function hide ():void {
			super.hide();
			Sprite(dobj).graphics.clear();
		}

		
		override public function set clickable (val:Boolean):void {
			
			if (val) {
			
				Sprite(dobj).mouseEnabled = true;
				Sprite(dobj).useHandCursor = true;
				Sprite(dobj).buttonMode = true;
				
				dobj.addEventListener(MouseEvent.MOUSE_DOWN, onPress, false, 0, true);
				dobj.addEventListener(MouseEvent.MOUSE_UP, onRelease, false, 0, true);
				dobj.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
				dobj.addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
				dobj.addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
				dobj.addEventListener(MouseEvent.MOUSE_OUT, onRollOut, false, 0, true);
				
			} else {
				
				Sprite(dobj).mouseEnabled = Sprite(dobj).mouseChildren = Sprite(dobj).doubleClickEnabled = false;
				Sprite(dobj).useHandCursor = false;
				Sprite(dobj).buttonMode = true;
				
				dobj.removeEventListener(MouseEvent.CLICK, onClick);
				dobj.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
				dobj.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				dobj.removeEventListener(MouseEvent.MOUSE_OUT, onRollOut);
				
			}		
			
		}

		//
		//
		public function onPress (e:MouseEvent):void {
			
			try {
				objectRef.onPress(e);
				trace(e.toString());
			} catch (e:Error) { }
			
		}

		//
		//
		public function onRelease (e:MouseEvent):void {
			
			try {
				objectRef.onRelease(e);
				trace(e.toString());
			} catch (e:Error) { }
			
		}
				
		
		//
		//
		public function onClick (e:MouseEvent):void {
			
			try {
				objectRef.onClick(e);
				trace(e.toString());
			} catch (e:Error) { }
			
		}
		
		//
		//
		public function onRollOver (e:MouseEvent):void {
			
			var hSprite:ViewSprite = this;	
			
			if (objectRef.material.opacity == 0 && parentNode != null && parentNode is ViewSprite && ViewSprite(parentNode).objectRef != null) {
				hSprite = ViewSprite(parentNode);
				hSprite.onRollOver(e);
				return;
			}
			
			_rolloverFilter = new GlowFilter(objectRef.computedColor, 0.75, 8, 8, 2, 1);
			dobj.filters = [_rolloverFilter];

			if (objectRef.onRollOver != null) try { objectRef.onRollOver(e); } catch (e:Error) { }
			
		}
		
		//
		//
		public function onRollOut (e:MouseEvent):void {
			
			var hSprite:ViewSprite = this;	
			
			if (objectRef.material.opacity == 0 && parentNode != null && parentNode is ViewSprite && ViewSprite(parentNode).objectRef != null) {
				hSprite = ViewSprite(parentNode);
				hSprite.onRollOut(e);
				return;
			}
			
			dobj.filters = [];
			
			if (objectRef.onRollOut != null) try { objectRef.onRollOut(e); } catch (e:Error) { }
			
		}

	}
	
}
