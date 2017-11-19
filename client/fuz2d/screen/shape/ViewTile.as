/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.screen.shape {
	
	import com.sploder.util.Textures;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import fuz2d.Fuz2d;
	import fuz2d.library.ObjectFactory;
	
	import fuz2d.model.object.Object2d;
	import fuz2d.model.object.Tile;
	import fuz2d.screen.View;
	import fuz2d.screen.shape.ViewObject;
	
	import fuz2d.util.ColorTools;
	import fuz2d.util.Geom2d;
	
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class ViewTile extends ViewObject {
		
		protected var _colorTransform:ColorTransform;
		protected var _cachedTintColor:int = -1;
		
		//
		//
		public function ViewTile (view:View, parentNode:ViewObject = null, objectRef:Object2d = null) {
			
			addTile(objectRef as Tile);
			
			super(view, parentNode, objectRef);

			if (parentNode != null && parentNode.dobj is DisplayObjectContainer) {
				DisplayObjectContainer(parentNode.dobj).addChild(dobj);
			}

		}		
		
		override public function updateGraphics ():void { 
			
			if (!_view.fastDraw && _objectRef.material.self_illuminate != true) {
				
				var ocolor:Number = _objectRef.tintColor;
				
				if (ocolor != _cachedTintColor) {
					
					_colorTransform = dobj.transform.colorTransform;
					_cachedTintColor = ocolor;

					_colorTransform.redOffset = ColorTools.getRedComponent(ocolor) - 255;
					_colorTransform.greenOffset = ColorTools.getGreenComponent(ocolor) - 255;
					_colorTransform.blueOffset = ColorTools.getBlueComponent(_cachedTintColor) - 255;

					dobj.transform.colorTransform = _colorTransform;
					
					/*
					_colorTransform = dobj.transform.colorTransform;
					
					trace((ocolor >> 16) - 255, (ocolor >> 8 & 0xff) - 255, (ocolor & 0xff) - 255);
					
					_colorTransform.redOffset = (ocolor >> 16) - 255;
					_colorTransform.greenOffset = (ocolor >> 8 & 0xff) - 255;
					_colorTransform.blueOffset = (ocolor & 0xff) - 255;
					
					dobj.transform.colorTransform = _colorTransform;
					
					_cachedTintColor = ocolor;
					*/
				}
				
			}	
			
		}

		override public function updateLocation ():void { }
				
		//
		//
		public function addTile (tile:Tile):void {
			
			var parent:DisplayObjectContainer;
			if (dobj != null) {
				parent = dobj.parent;
				if (parent != null) parent.removeChild(dobj);
			}
			
			
		    if (tile.graphic > 0) drawGraphic(tile);
			if (dobj == null) dobj = tile.clipAsBitmap;
			dobj.x = tile.x;
			dobj.y = 0 - tile.y;
			dobj.x -= dobj.width * 0.5 / View.scale;
			dobj.y -= dobj.height * 0.5 / View.scale;
			
			dobj.scaleX = dobj.scaleY = 1 / View.scale;
			
			if (tile.graphic == 0 && tile.stampName.length == 0 && 
				Fuz2d.library.getTileDefinition(tile.definitionID).cap) {
					dobj.opaqueBackground = true;
				}
				
			if (parent != null) parent.addChild(dobj);

		}
		
		protected function drawGraphic (tile:Tile):Boolean
		{
			var bd:BitmapData;
			if (tile != null && tile.graphic > 0) {
				
				bd = Textures.getScaledBitmapData(tile.graphic + "_" + tile.graphic_version, 8, 0, this);
				
				if (bd) {
					
					var m:Matrix = new Matrix();
					var g:Graphics;
					var s:Shape;
					
					if (dobj == null)
					{
						s = new Shape();
						dobj = s;
						if (tile.scale != 1 && tile.scale != 0) s.scaleX = s.scaleY = tile.scale;
						g = s.graphics;
					}
					
					if (g != null)
					{
						g.clear();
						var w:Number = tile.clipAsBitmap.width;
						var h:Number = tile.clipAsBitmap.height;
						m.createBox(w / (bd.width), h / (bd.height), 0);
						g.beginBitmapFill(bd, m, true, true);
						g.drawRect(0, 0, w, h);
						g.endFill();
						
						return true;
					} else {
						trace("graphic is null");
					}
				} else {
					trace("graphic must not be loaded yet");
					
				}
			}
			
			return false;
		}

	}
	
}
