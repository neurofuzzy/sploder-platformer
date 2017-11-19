package com.sploder.texturegen_internal
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	
	public class TextureRenderingJob
	{	
		public var bitmapData:BitmapData;
		public var finished:Boolean;
		public var canceled:Boolean;
		public var autoApply:Boolean;
		public var highQuality:Boolean;
		public var transparent:Boolean;
		public var borderType:int;
		public var destinationRect:Rectangle;
		public var destinationPoint:Point;
		public var destination:BitmapData;
		public var attribs:TextureAttributes;
		
		public function TextureRenderingJob():void
		{
		}
		
		public function initWithProperties(attribs:TextureAttributes, destination:BitmapData, destinationRect:Rectangle, borderType:int = 0, transparent:Boolean = false, highQuality:Boolean = false, autoApply:Boolean = true):*
		{
			this.attribs = attribs.copy();
			this.destination = destination;
			this.destinationRect = destinationRect;
			this.destinationPoint = new Point(destinationRect.x, destinationRect.y);
			this.borderType = borderType;
			this.transparent = transparent;
			this.highQuality = highQuality;
			this.autoApply = autoApply;
			
			bitmapData = new BitmapData(Math.floor(destinationRect.width), Math.floor(destinationRect.height), transparent, 0);
			
			return this;
		}

		public function finish():void
		{
			if (finished)
				return;
			if (autoApply)
				apply();
			finished = true;
		}
		
		public function cancel():void
		{
			canceled = true;
		}
		
		public function apply():void
		{
			if (!finished)
			{
				destination.copyPixels(bitmapData, bitmapData.rect, destinationPoint);
				finished = true;
			}
		}	
		
		public function destroy():void
		{
			if (finished && bitmapData != null)
			{
				bitmapData.dispose();
				bitmapData = null;
			}
		}
	}
}
