package fuz2d.screen.morph
{
	import fuz2d.action.physics.CompoundObject;
	import fuz2d.model.object.Object2d;
	import fuz2d.screen.shape.ViewObject;
	import fuz2d.screen.shape.ViewSprite;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * ...
	 * @author Geoff
	 */
	public class Morph extends Sprite {

		protected var _viewSprite:ViewSprite;
		protected var timer:Timer;
		
		public var destroyParent:Boolean = true;

		public function Morph (viewSprite:ViewSprite, morphTime:uint = 990, startNow:Boolean = true) {
			
			super();
			
			init(viewSprite, morphTime, startNow);
			
	
		}
		
		protected function init (viewSprite:ViewSprite, morphTime:uint = 990, startNow:Boolean = true):void {
			
			_viewSprite = viewSprite;
			_viewSprite.addMorph(this);
			
			timer = new Timer(33, Math.ceil(morphTime / 33));
			timer.addEventListener(TimerEvent.TIMER, doMorph);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, completeMorph);

			if (startNow) startMorph();
			
		}
		
		public function startMorph ():void {

			if (!timer.running) timer.start();
			
		}

		protected function doMorph (e:TimerEvent):void {

		}
		
		protected function completeMorph (e:TimerEvent):void {
			
			if (parent != null) parent.removeChild(this);
			timer = null;
			
			if (destroyParent) _viewSprite.destroy();

		}
		
	}

}