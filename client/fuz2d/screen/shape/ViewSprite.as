/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.screen.shape {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import fuz2d.Fuz2d;
	import fuz2d.library.ObjectFactory;
	import fuz2d.screen.morph.Morph;
	import fuz2d.screen.shape.ViewObject;

	import fuz2d.model.object.*;
	import fuz2d.screen.View;

	import flash.display.Sprite;

	public class ViewSprite extends ViewObject {
		
		protected var _morphing:Boolean = false;
		//
		//
		public function ViewSprite (view:View, parentNode:ViewObject = null, objectRef:Object2d = null) {
			
			dobj = new Sprite();
			dobj.cacheAsBitmap = false;
			
			super(view, parentNode, objectRef);
			
			Sprite(dobj).mouseChildren = false;
			Sprite(dobj).mouseEnabled = false;
			Sprite(dobj).tabEnabled = false;
			Sprite(dobj).tabChildren = false;

			if (parentNode != null && parentNode.dobj is DisplayObjectContainer) {
				DisplayObjectContainer(parentNode.dobj).addChild(dobj);
			}

		}	
		
		public function rebuild ():void
		{
			if (polygon != null) polygon.destroy();
			polygon = null;
			updateGraphics();
		}
		
		//
		//
		override public function updateGraphics ():void {
		
			if (_objectRef.deleted) {
				destroy();
				return;
			}
			
			if (polygon != null) {
				
				if (!_morphing) polygon.redraw();
				return;
				
			} else {
				
				if (_objectRef is Biped) {
					
					if (_objectRef.symbolName == "player") {
						polygon = new PlayerDisplay(_view, this);
					} else {
						polygon = new BipedDisplay(_view, this);
					}
					
					_objectRef.zSortChildNodes = false;
				
				} else if (_objectRef is TurretSymbol && _objectRef.symbolName.length > 0) {
					
					polygon = new TurretAssetDisplay(_view, this);		
						
				} else if (_objectRef is Mech && _objectRef.symbolName.length > 0) {
					
					polygon = new MechDisplay(_view, this);
					
				} else if (_objectRef is SegSymbol && _objectRef.symbolName.length > 0) {
					
					polygon = new SegDisplay(_view, this);
					
				} else if (_objectRef is Symbol && _objectRef.symbolName.length > 0) {
					
					if (_objectRef.attribs.showHealth) {
						polygon = new HealthAssetDisplay(_view, this);
					} else {
						polygon = new AssetDisplay(_view, this);
					}
					
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
						
		}
		
		public function addMorph (m:Morph):void {
			
			_morphing = true;
			
			Sprite(dobj).addChild(m);

		}
		
		override public function addChildNode(vo:ViewObject):void {
			super.addChildNode(vo);
			Sprite(dobj).addChild(vo.dobj);
		}
		
		override public function removeChildNode(vo:ViewObject):Boolean {
			return super.removeChildNode(vo);
			Sprite(dobj).removeChild(vo.dobj);
		}
		
		
		//
		//
		override public function hide ():void {
			super.hide();
			Sprite(dobj).graphics.clear();
		}
		
	}
	
}
