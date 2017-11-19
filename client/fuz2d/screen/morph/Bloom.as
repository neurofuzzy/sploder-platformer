package fuz2d.screen.morph
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import fuz2d.screen.shape.AssetDisplay;

	import fuz2d.screen.shape.ViewSprite;

	/**
	 * ...
	 * @author Geoff
	 */
	public class Bloom extends Morph {
		
		private var _color:ColorTransform;
		protected var _clip:DisplayObject;
		
		private var _offset:Number = 0;
		
		private var _oldX:Number = 0;
		
		public var colorChange:int = 20;
		public var scaleChange:Number = 0.1;
		public var rotationChange:int = 10;
		
		public function Bloom (viewSprite:ViewSprite, morphTime:uint = 990, startNow:Boolean = true) {
			
			super(viewSprite, 990, startNow);
			
			if (_viewSprite.polygon is AssetDisplay && AssetDisplay(viewSprite.polygon).clip != null) {
				
				_clip = AssetDisplay(viewSprite.polygon).clip;
				
				_color = new ColorTransform();
				_color.redMultiplier = _color.blueMultiplier = _color.greenMultiplier = 10;
				
				_clip.transform.colorTransform = _color;
				
			}
			
		}
		
		override protected function doMorph(e:TimerEvent):void 
		{
			
			if (_clip == null || _clip.alpha <= 0) return;
			
			_clip.alpha -= 0.1;
			
			_clip.scaleX += scaleChange;
			_clip.scaleY += scaleChange;
			
			_color = _clip.transform.colorTransform;
			
			_offset += colorChange;
			_color.redOffset = _color.blueOffset = _color.greenOffset = _offset;
			
			_clip.transform.colorTransform = _color;
			
			if (_viewSprite && _viewSprite.dobj) {
				
				if (_oldX != 0) {
					if (_oldX < _viewSprite.dobj.x) _clip.rotation += rotationChange;
					else _clip.rotation -= rotationChange;
				}
				
				_oldX = _viewSprite.dobj.x;
				
			}
			
		}
		
	}
	
}