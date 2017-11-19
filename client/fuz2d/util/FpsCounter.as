/**
* ...
* @author Default
* @version 0.1
*/

package fuz2d.util  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import flash.events.Event;
	import fuz2d.Fuz2d;
	import fuz2d.model.Model;
	import fuz2d.screen.View;

	public class FpsCounter extends MovieClip {
		
		[Embed(source = "../assets/fpscounter.swf", symbol = "FpsCounterSymbol")]
		private const Visuals:Class;
		
		public var fps:Number = 0;
		public var av:Number = 30;
		public var count:Number = 1;
		public var timer:Number = getTimer();
		
		public var cur_fps:TextField;
		public var av_fps:TextField;
		public var mem_usage:TextField;
		public var num_obj:TextField;
		public var num_vs:TextField;
		
		public var model:Model;
		public var view:View;
		
		private var _visuals:Sprite;
		
		//
		//
		public function FpsCounter(model:Model, view:View) {
			
			super();
			
			this.model = model;
			this.view = view;
			
			_visuals = new Visuals();
			addChild(_visuals);
			
			cur_fps = TextField(_visuals["cur_fps"]);
			av_fps = TextField(_visuals["av_fps"]);
			mem_usage = TextField(_visuals["mem_usage"]);
			num_obj = TextField(_visuals["num_obj"]);
			num_vs = TextField(_visuals["num_vs"]);
			
			addEventListener(Event.ENTER_FRAME, updateFPS, false, 0, true);
			
		}

		//
		//
		public function updateFPS (e:Event):void {
			
			if (model != null && view != null) {
				
				fps = 1000 / (getTimer() - timer);
				timer = getTimer();
				av = ((av * count) + fps) / (count + 1);
				count++;
				
				cur_fps.text = (fps >> 0) + "";
				av_fps.text = (av >> 0) + "";
				
				if (av > 0) Fuz2d.fps = av;
				else trace("FPS ERROR:", alpha, count, timer, getTimer());
				
				if (count > 300) {
					count = 0;
				}
				
				mem_usage.text = Number( System.totalMemory / 1024 / 1024 ).toFixed( 2 ) + 'MB';
				num_obj.text = "0: " + model.objects.length.toString();
				num_vs.text = "1: " + view.numSprites.toString();
				
			}
			
		}
		
		//
		//
		public function end ():void {
			
			model = null;
			view = null;
			removeEventListener(Event.ENTER_FRAME, updateFPS);
			if (parent != null) parent.removeChild(this);
			
		}
		
	}
	
}
