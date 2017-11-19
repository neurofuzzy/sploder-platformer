package com.sploder.texturegen_internal {
	
	import com.sploder.texturegen_internal.util.ThreadedQueue;
	import flash.display.BitmapData;
	import flash.utils.getTimer;
	
	public class TextureRenderingQueue extends ThreadedQueue {
		
		public function TextureRenderingQueue():void {
			super();
		}
		
		public function renderImmediately(obj:TextureRenderingJob):void {
			this.doTask(obj);
		}
		
		protected override function doTask(_tmp_obj:* ):Boolean
		{
			var now:Number = getTimer();
			
			var obj:TextureRenderingJob = _tmp_obj;
			var renderer:TextureRendering = new TextureRendering().initWithAttributes(obj.attribs);
			var bd:flash.display.BitmapData = obj.bitmapData;
			if (!obj.canceled) renderer.generate(obj.borderType);
			//trace("geom:", getTimer() - now);
			if(!obj.canceled) renderer.setBorderRegions(obj.borderType);
			//trace("border:", getTimer() - now);
			if (!obj.canceled) renderer.renderToBitmap(bd, obj.highQuality, obj.borderType);
			//trace("render:", getTimer() - now);
			if (!obj.canceled) renderer.postProcessBitmap(bd);
			//trace("postprocess:", getTimer() - now);
			//trace("---");
			obj.finish();
			renderer.destroy();
			renderer = null;
			return true;
		}
		
		public function hasJobWithBitmapData (bd:BitmapData):Boolean
		{
			for each (var job:TextureRenderingJob in _requestObjects)
			{
				if (job.destination == bd) return true;
			}
			return false;
		}
		
		public override function init():* {
			super.init();
			TextureRenderingQueue.mainInstance = this;
			return this;
		}
		
		public static var mainInstance:TextureRenderingQueue;
	}
}
