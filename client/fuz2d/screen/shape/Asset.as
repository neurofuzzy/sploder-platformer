/**
* ...
* @author Default
* @version 0.1
*/

package fuz2d.screen.shape {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import fuz2d.Fuz2d;
	import fuz2d.screen.shape.AssetDisplay;
	import fuz2d.screen.shape.ViewSprite;
	import fuz2d.TimeStep;
	

	public class Asset extends MovieClip {
		
		protected var _displayContainer:AssetDisplay;
		protected var _container:ViewSprite;
		
		protected var _timed:Boolean = false;
		protected var _mspf:Number;
		protected var _frameTime:uint;
		protected var _skipFrames:Boolean = false;
		
		protected var _timer:Timer;
		protected var _maxLife:Number = 0;
		
		//
		//
		public function Asset () {
			
			_mspf = 1000 / Fuz2d.frameRate;
			_frameTime = TimeStep.realTime;
			
		}
		
		//
		//
		public function setContainer (displayContainer:AssetDisplay, container:ViewSprite):void {
			
			_displayContainer = displayContainer;
			_container = container;
			
			_displayContainer.redraw();
			
			if (_timed) {
				if (_maxLife > 0) {
					_timer = new Timer(_maxLife, 1);
					_timer.addEventListener(TimerEvent.TIMER, complete, false, 0, true);
					_timer.start();
				}
				addEventListener(Event.ENTER_FRAME, onFrame, false, 0, true);
			}
			
		}
		
		//
		//
		protected function onFrame (e:Event):void {
			
			if (_skipFrames) {
				
				if (this) {
					
					var mc:MovieClip;
					var skipNum:uint;
					var ts:int = TimeStep.realTime;
					
					if (ts - _frameTime >= _mspf * 2) {
						
						skipNum = ((ts - _frameTime) / _mspf) >> 0;

						var i:uint = numChildren;
						
						while (i--) {
							mc = MovieClip(e.target.getChildAt(i));
							mc.gotoAndPlay((mc.currentFrame + skipNum) % mc.totalFrames);
						}
					
					}
					
					_frameTime = ts;
					
				}
			
			}
			
		}
		
		//
		//
		protected function stopOnFrame ():void {
			removeEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		//
		//
		protected function stopTimer ():void {
			if (_timer != null) {
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, complete);
				if (_timer.running) _timer.stop();
			}
		}
		
		//
		//
		protected function complete (e:TimerEvent):void {
			
			trace("timer complete!");
			destroy();
			
		}
		
		//
		//
		public function destroy ():void {
			
			stopOnFrame();
			stopTimer();
			
			if (_container != null) {
				
				if (_container.objectRef != null) {
					_container.objectRef.destroy();
				}
				
				_container.removeChild(this);
				_container.destroy();
				delete this;

			}			
			
		}
		
	}
	
}
