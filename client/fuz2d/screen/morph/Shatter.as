package fuz2d.screen.morph
{

	import fuz2d.action.physics.CompoundObject;
	import fuz2d.model.object.Object2d;
	import fuz2d.screen.shape.AssetDisplay;
	import fuz2d.screen.shape.ViewObject;
	import fuz2d.screen.shape.ViewSprite;
	import fuz2d.util.delaunay.Delaunay;
	import fuz2d.util.delaunay.XYZ;
	import fuz2d.util.Geom2d;
	import fuz2d.util.PolyWrap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import fuz2d.TimeStep;

	/**
	 * ...
	 * @author Geoff
	 */
	public class Shatter extends Morph {

		public var fragments:Array;
		
		protected var force:Point;
		protected var contact:Point;
		
		protected var explosionScale:Number;

		protected var vectors:Dictionary;
		
		protected var hullOffset:int = 0;
		
		protected var gravPt:Point;
		
		public function Shatter (viewSprite:ViewSprite, doExplode:Boolean = true, explosionFactor:Number = 1, shatterForce:Point = null, contactPoint:Point = null, color:uint = 0xffffff) {
			
			var shatterClip:Sprite = Sprite(viewSprite.dobj);

			vectors = new Dictionary();
			
			if (!doExplode) hullOffset = Math.max(shatterClip.width, shatterClip.height) / 10;
			
			if (contactPoint != null) {
				var myPoint:Point = shatterClip.localToGlobal(contactPoint);
				if (shatterClip.hitTestPoint(myPoint.x, myPoint.y, true)) contact = contactPoint;
			}
			
			if (shatterForce != null) force = shatterForce;
			else force = new Point(0, 0);
			
			Geom2d.rotatePoint(force, 0 - viewSprite.objectRef.rotation);
			
			gravPt = new Point(0, 10);
			Geom2d.rotatePoint(gravPt, 0 - viewSprite.objectRef.rotation);
			
			var onStage:Boolean = true;
			if (shatterClip.parent == null) {
				onStage = false;
				viewSprite.view.stage.addChild(shatterClip);
			}
			
			doShatter(shatterClip, color);

			if (!onStage) shatterClip.parent.removeChild(shatterClip);

			if (viewSprite.polygon is AssetDisplay) {
				if (AssetDisplay(viewSprite.polygon).clip != null) {
					AssetDisplay(viewSprite.polygon).clip.visible = false;
				}
			}

			if (doExplode) {
				explosionScale = 100 / Math.max(shatterClip.width, shatterClip.height);
				explosionScale *= explosionFactor;
			}
			
			super(viewSprite, 990, doExplode);
			
			if (_viewSprite.objectRef && _viewSprite.objectRef.simObject) {
				if (_viewSprite.objectRef.simObject is CompoundObject) {
					var subs:Array = CompoundObject(_viewSprite.objectRef.simObject).subObjects;
					for each (var subobj:Object2d in subs) {
						var sv:ViewObject = _viewSprite.view.objectSprites[subobj];
						if (sv && sv is ViewSprite) {
							var sh:Shatter = new Shatter(ViewSprite(sv), doExplode, explosionFactor, shatterForce, contactPoint);
						}
					}
				}
			}
	
		}
		
		override public function startMorph():void 
		{

			var pt:Point = new Point();
			
			for each (var shape:Shape in fragments) {

				pt.x = (contact != null) ? 0 - contact.x * 0.5 + shape.x : shape.x;
				pt.y = (contact != null) ? 0 - contact.y * 0.5 + shape.y : shape.y;
				shape.alpha = 2;
				vectors[shape] = new Point((pt.x / 4 + force.x) * explosionScale * (Math.random() + 0.5), (pt.y / 4 + force.y) * explosionScale * (Math.random() + 0.5));
				
			}
			
			super.startMorph();
			
		}
		
		public function scaleFragments (scale:Number = 1):void {
			
			for each (var shape:Shape in fragments) {
				
				shape.scaleX = shape.scaleY = scale;

			}
			
		}
		
		override protected function doMorph(e:TimerEvent):void 
		{	
			
			if (_viewSprite == null || _viewSprite.dobj == null || _viewSprite.dobj.alpha <= 0) return;
			
			for each (var shape:Shape in fragments) {
				
				shape.x += vectors[shape].x;
				shape.y += vectors[shape].y;
				vectors[shape].x += gravPt.x;
				vectors[shape].y += gravPt.y;
				vectors[shape].x *= 0.95;
				vectors[shape].y *= 0.95;
				shape.scaleX *= 0.98;
				shape.scaleY *= 0.98;
				shape.rotation += (vectors[shape].x + vectors[shape].y);
				shape.alpha *= 0.95;
				
			}
			
		}
		
		override protected function completeMorph(e:TimerEvent):void 
		{
			super.completeMorph(e);
	
			vectors = null;

		}		

		protected function doShatter (clip:Sprite, color:uint = 0xffffff):void {
			
			var time:int = TimeStep.realTime;
			
			var wrap:PolyWrap = new PolyWrap(clip, 2, 2, 3, hullOffset);

			var points:Array = wrap.getBoundingPoints();
			
			if (contact != null) {
				
				points.push(contact);
				
			} else {
				
				var dist:Number = Math.min(clip.width / 2, clip.height / 2);
				dist *= 0.7;
				points.push(Point.polar(dist, 20 * Math.PI / 180));
				dist *= 0.8;
				points.push(Point.polar(dist, 140 * Math.PI / 180));
				dist *= 0.8;
				points.push(Point.polar(dist, 260 * Math.PI / 180));
				
			}
			
			
			
			points.sortOn("x", Array.NUMERIC);
			
			var XYZs:Array = [];
			var i:int;
			
			for (i = 0; i < points.length; i++) {
				
				XYZs.push(new XYZ(points[i].x, points[i].y));
				
			}
			
			var triangles:Array = Delaunay.triangulate(XYZs);

			fragments = Delaunay.drawDelaunay(triangles, XYZs, this, color);

		}
		
	}

}