/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.screen.shape {
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import fuz2d.Fuz2d;
	import fuz2d.library.ObjectFactory;

	import fuz2d.model.object.*;
	import fuz2d.screen.*;
	import fuz2d.util.Geom2d;
	
	import flash.display.Sprite;

	public class ViewObject {
		
		protected var _view:View;
		public function get view ():View { return _view; }
		
		public var dobj:DisplayObject;
		protected var _parentDobj:DisplayObjectContainer;
		
		protected var _parentNode:ViewObject;
		public function get parentNode ():ViewObject { return _parentNode; }
		
		protected var _objectRef:Object2d;
		public function get objectRef ():Object2d { return _objectRef; }

		public var screenPt:ScreenPoint;
		public function get screenDist ():Number { return (_objectRef != null) ? _objectRef.zDepth : 1; }

		public var polygon:Polygon;
	
		public function get screenX ():Number { return dobj.x - dobj.parent.x; }
		public function get screenY ():Number { return dobj.y - dobj.parent.y; }
		
		public function set playing (value:Boolean):void {
			
			if (polygon is AssetDisplay) AssetDisplay(polygon).playing = value;
			
		}
		
		public function get zSort ():Boolean { return _objectRef.zSortChildNodes; }
		
		public var childNodes:Array;
		
		protected var _cache:Boolean = false;
		
		protected var _oldX:int;
		protected var _oldY:int;
		protected var _oldR:Number;
		
		//
		//
		public function ViewObject (view:View, parentNode:ViewObject = null, objectRef:Object2d = null) {
			
			super();
			
			_view = view;
			
			if (objectRef == null) {
				_objectRef = new Object2d(null, 0, 0, 0, 1);
			} else {
				_objectRef = objectRef;
			}
			
			if (_view.isMain) _objectRef.viewObject = this;
			
			if (parentNode != null) _parentNode = parentNode;
			
			updatePt();
			
			childNodes = [];
			
			clickable = false;
			
		}
		
		//
		//
		protected function updatePt ():void {
			
			screenPt = _view.translate2d(_objectRef, screenPt);

		}
		
		//
		//
		public function updateGraphics ():void {
			
						
		}
		
		//
		//
		public function updateLocation ():void {
			
			if (_objectRef == null) {
				destroy();
				return;
			}
			
			if (_oldX == _objectRef.x && _oldY == _objectRef.y && _oldR == _objectRef.rotation) return;
			
			updatePt();
			
			if (screenPt == null) {
				_oldX = _oldY = NaN;
				return;
			}
			
			if (_parentNode != null) {
				
				if (_parentNode.screenPt != null) {
					dobj.x = screenPt.x - _parentNode.screenPt.x;
					dobj.y = screenPt.y - _parentNode.screenPt.y;
				} else {
					dobj.x = screenPt.x;
					dobj.y = screenPt.y;	
				}

			} else {
				
				dobj.x = screenPt.x;
				dobj.y = screenPt.y;	
				
			}
			
			_oldX = _objectRef.x;
			_oldY = _objectRef.y;
			_oldR = _objectRef.rotation;
			
			if (!(_objectRef is Tile)) dobj.rotation = _objectRef.rotation * Geom2d.rtd;
			
		}
		
		//
		//
		public function addChildNode (vo:ViewObject):void {
			
			childNodes.push(vo);

		}
		
		//
		//
		public function removeChildNode (vo:ViewObject):Boolean {
			
			var idx:int = childNodes.indexOf(vo);
			
			if (idx != -1) {
				childNodes.splice(idx, 1);
				return true;
			} else {
				return false;
			}
			
		}
		
		//
		//
		public function destroy ():void {
			
			if (_parentNode != null) {
				
				if (_parentNode.parentNode == null) {
					_view.numSprites--;
				}
				
				delete _view.objectSprites[objectRef];
				
				_parentNode.removeChildNode(this);
				
				_parentNode = null;
				
			}
			
			if (polygon != null) {
				polygon.clear();
				polygon.destroy();
				polygon = null;
			}
			
			if (_objectRef != null) _objectRef.destroy();
			_objectRef = null;
			
			if (dobj != null) {
				if (dobj.parent != null) dobj.parent.removeChild(dobj);
				if (dobj is Bitmap) Bitmap(dobj).bitmapData = null;
				dobj = null;
			}
				
			
		}
		
		//
		//
		public function hide ():void {
			if (dobj.visible) {
				dobj.visible = false;
				if (_parentNode != null) {
					_parentDobj = dobj.parent;
					_parentNode.removeChildNode(this);
				}
			}
		}
		
		//
		//
		public function show ():void {
			if (!dobj.visible) {
				dobj.visible = true;
				_parentNode.addChildNode(this);
			}
		}
		
		public function set clickable (val:Boolean):void {
	
		}
		
		//
		//
		public function add (symbolName:String, self_illuminate:Boolean = false, z:int = -1, pt:Point = null):void {
			
			if (z == -1) z = 10;
			
			ObjectFactory.effect(_objectRef, symbolName, self_illuminate, z, pt);
			
		}
		
	}
	
}
