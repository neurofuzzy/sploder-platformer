package fuz2d.screen.shape 
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import fuz2d.screen.View;

	/**
	 * ...
	 * @author Geoff
	 */
	public class DeathDisplay extends Polygon {
		
		protected var _clip:DisplayObject;
		public function get clip():DisplayObject { return _clip; }
		public function set clip(value:DisplayObject):void {
			
			if (_clip != null) return;
			
			_clip = value;
			Sprite(_container.dobj).addChild(_clip);
			
			_color = new ColorTransform();
			_color.redMultiplier = _color.blueMultiplier = _color.greenMultiplier = 10;
			
			_clip.transform.colorTransform = _color;
	

		}
		
		private var _color:ColorTransform;
		
		private var _offset:Number = 0;
		
		public function DeathDisplay (view:View, container:ViewSprite) {
			
			super(view, container);
			
		}
		
		override protected function draw(g:Graphics, clear:Boolean = true):void 
		{
			if (_clip != null) {
				
				if (_clip.alpha <= 0) {
					_container.objectRef.destroy();
					return;
				}
				
				_clip.alpha -= 0.1;
				
				_clip.scaleX += 0.1;
				_clip.scaleY += 0.1;
				
				_color = _clip.transform.colorTransform;
				
				_offset += 20;
				_color.redOffset = _color.blueOffset = _color.greenOffset = _offset;
				
				_clip.transform.colorTransform = _color;
			
			}
			
		}
		
	}
	
}