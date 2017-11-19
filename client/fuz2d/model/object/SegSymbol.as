package fuz2d.model.object 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import fuz2d.action.physics.MotionObject;
	import fuz2d.library.EmbeddedLibrary;
	import fuz2d.model.material.Material;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class SegSymbol extends Symbol
	{
		
		public var bearingFoot:Point;
		public var nonBearingFoot:Point;

		public var footPointRight:Point;
		public var footPointLeft:Point;
		
		public var boarded:Boolean = false;
		
		public function SegSymbol (symbolName:String, library:EmbeddedLibrary, material:Material = null, parentObject:Point2d = null, x:Number = 0, y:Number = 0, z:Number = 0, rotation:Number = 0, scaleX:Number = 1, scaleY:Number = 1, cacheAsBitmap:Boolean = false, castShadow:Boolean = true, receiveShadow:Boolean = true, controlled:Boolean = false, overlay:Boolean = false, rectnames:Array = null) 
		{
			super(symbolName, library, material, parentObject, x, y, z, rotation, scaleX, scaleY, cacheAsBitmap, castShadow, receiveShadow, controlled, overlay, rectnames);
				
			footPointRight = new Point();
			footPointLeft = new Point();
			bearingFoot = footPointRight;
			nonBearingFoot = footPointLeft;
			
		}
		
		//
		//
		public function switchFeet ():void {
			
			var tmp:Point;
			
			tmp = bearingFoot;
			bearingFoot = nonBearingFoot;
			nonBearingFoot = tmp;

		}
		
	}

}