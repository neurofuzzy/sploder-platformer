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
	public class Mech extends Symbol
	{
		
		public static const FACING_RIGHT:uint = 1;
		public static const FACING_LEFT:uint = 2;
		
		public static const STATE_IDLE:String = "z_idle";
		public static const STATE_PUNCHING:String = "z_punching";
		
		protected var _facing:uint = 1;
		public function get facing():uint { return _facing; }
		public function set facing(value:uint):void {  
			if (value != _facing) {
				_facing = value;
				updateStance();
			}
		}
		
		public var bearingFoot:Point;
		public var nonBearingFoot:Point;
		public var bearingX:Number = 0;
		public var footPointRight:Point;
		public var footPointLeft:Point;
		
		public var boarded:Boolean = false;
		
		public function Mech(symbolName:String, library:EmbeddedLibrary, material:Material = null, parentObject:Point2d = null, x:Number = 0, y:Number = 0, z:Number = 0, rotation:Number = 0, scaleX:Number = 1, scaleY:Number = 1, cacheAsBitmap:Boolean = false, castShadow:Boolean = true, receiveShadow:Boolean = true, controlled:Boolean = false) 
		{
			super(symbolName, library, material, parentObject, x, y, z, rotation, scaleX, scaleY, cacheAsBitmap, castShadow, receiveShadow, controlled);
				
			footPointRight = new Point();
			footPointLeft = new Point();
			bearingX = point.x;
			bearingFoot = footPointRight;
			nonBearingFoot = footPointLeft;

			updateStance();
			
		}
		
		//
		//
		public function updateStance ():void {
			
			if (!_simObject) return;

			var tmp:Point;
			
			switch (_facing) {
				
				case FACING_LEFT:
				
					if (bearingX > xpos + bearingFoot.x) {
						
						if (bearingFoot.x > 50) {
							
							tmp = bearingFoot;
							bearingFoot = nonBearingFoot;
							nonBearingFoot = tmp;
							bearingX = xpos + bearingFoot.x;
							
							attribs.stepped = true;
							attribs.switchedfeet = true;
							
						}
					
					} else {
						
						if (bearingFoot.x < -50) {
							
							tmp = bearingFoot;
							bearingFoot = nonBearingFoot;
							nonBearingFoot = tmp;
							bearingX = xpos + bearingFoot.x;
							
							attribs.stepped = true;
							attribs.switchedfeet = true;
							
						}						
						
					}
			
					bearingFoot.x = bearingX - xpos;
					bearingFoot.y = 0;
					
					nonBearingFoot.x = 0 - bearingFoot.x;
					nonBearingFoot.y = -20;
					
					break;
				
				case FACING_RIGHT:
				
					if (bearingX < xpos - bearingFoot.x) {
						
						if (bearingFoot.x > 50) {
							
							tmp = bearingFoot;
							bearingFoot = nonBearingFoot;
							nonBearingFoot = tmp;
							bearingX = xpos - bearingFoot.x;
							
							attribs.stepped = true;
							attribs.switchedfeet = true;
							
							
						}
				
					} else {
						
						if (bearingFoot.x < -50) {
							
							tmp = bearingFoot;
							bearingFoot = nonBearingFoot;
							nonBearingFoot = tmp;
							bearingX = xpos - bearingFoot.x;
							
							attribs.stepped = true;
							attribs.switchedfeet = true;
							
						}
						
					}
					
					bearingFoot.x = xpos - bearingX;
					bearingFoot.y = 0;
					
					nonBearingFoot.x = 0 - bearingFoot.x;
					nonBearingFoot.y = -20;
					
					break;
					
			}
			
			if (Math.abs(MotionObject(_simObject).velocity.x) < 10) {
				nonBearingFoot.y = bearingFoot.y = 0;
			}
			
			bearingFoot.x = Math.max( -51, Math.min(51, bearingFoot.x));
			nonBearingFoot.x = Math.max( -51, Math.min(51, nonBearingFoot.x));
			
		}
		
	}

}