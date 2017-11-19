/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.screen.shape {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.PixelSnapping;
	import fuz2d.Fuz2d;
	import fuz2d.library.ObjectFactory;
	import fuz2d.screen.BitView;
	
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

	public class ViewLayer extends ViewObject {
	
		public var bitmapData:BitmapData;
		
		protected var _opaque:Boolean = true;
		
		public function get opaque ():Boolean {
			return _opaque;
		}
		
		public function set opaque (value:Boolean):void {
			_opaque = Bitmap(dobj).opaqueBackground = value;
		}

		//
		//
		public function ViewLayer (view:View, parentNode:ViewObject = null, objectRef:Object2d = null, opaque:Boolean = true) {
			
			_opaque = opaque;
			createLayer(view);
			
			super(view, parentNode, objectRef);

			if (parentNode != null) Sprite(parentNode.dobj).addChild(dobj);

		}		
		
		override public function updateGraphics ():void { }

		override public function updateLocation ():void { }
		
		//
		//
		public function setSize(view:View):void {

			bitmapData = new BitmapData(view.innerWidth / BitView.pixelScale, view.innerHeight / BitView.pixelScale, !_opaque, 0);
			if (dobj != null) Bitmap(dobj).bitmapData = bitmapData;
			if (dobj != null) dobj.scaleX = dobj.scaleY = BitView.pixelScale;
			
		}
		
		//
		//
		public function createLayer (view:View):void {
			
			var parent:DisplayObjectContainer;
			if (dobj != null) {
				parent = dobj.parent;
				if (parent != null) parent.removeChild(dobj);
			}
			
			setSize(view);
			
			dobj = new Bitmap(bitmapData, PixelSnapping.ALWAYS, false);
			Bitmap(dobj).opaqueBackground = (_opaque) ? 0 : null;
			if (parent != null) parent.addChild(dobj);

		}
		
		override public function destroy():void 
		{
			super.destroy();
			bitmapData.dispose();
		}

	}
	
}
