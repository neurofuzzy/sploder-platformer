package fuz2d.model.object 
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import fuz2d.library.EmbeddedLibrary;
	import fuz2d.model.material.Material;
	import fuz2d.util.Geom2d;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class TurretSymbol extends Symbol
	{
		
		protected var _turretAxis:Point;
		protected var _turretLength:Number = 0;
		
		protected var _turretAngle:Number = 0;
		public function get turretAngle():Number { return _turretAngle; }
		public function set turretAngle(value:Number):void 
		{
			_turretAngle = Geom2d.normalizeAngle(value);
			
			_launchPoint.x = _turretAxis.x + Math.sin(_turretAngle) * _turretLength;
			_launchPoint.y = _turretAxis.y + Math.cos(_turretAngle) * _turretLength;

		}
		
		protected var _launchPoint:Point;
		public function get launchPoint():Point { return _launchPoint; }
		
		
		public function TurretSymbol(symbolName:String, library:EmbeddedLibrary, material:Material = null, parentObject:Point2d = null, x:Number = 0, y:Number = 0, z:Number = 0, rotation:Number = 0, scaleX:Number = 1, scaleY:Number = 1, cacheAsBitmap:Boolean = false, castShadow:Boolean = true, receiveShadow:Boolean = true, controlled:Boolean = false, overlay:Boolean = false, rectnames:Array = null) 
		{
			super(symbolName, library, material, parentObject, x, y, z, rotation, scaleX, scaleY, cacheAsBitmap, castShadow, receiveShadow, controlled, overlay, rectnames);
			
		}
		
		override protected function initSymbol():void 
		{
			super.initSymbol();
			
			_turretAxis = new Point();
			
			if (clip["turret"]) {
				var c:Sprite = Sprite(clip["turret"]);
				_turretAxis = new Point();
				_turretAxis.x = c.x;
				_turretAxis.y = 0 - c.y;
				var d:Rectangle = c.getRect(c.parent);
				var m:Number = 0.5;
				if (Math.abs(d.y - c.y) > d.height * 0.75) m = 1;
				_turretLength = Math.max(c.width, c.height) * m;
			}
			
			_launchPoint = new Point();
			turretAngle = 0;
			
		}
		
	}

}