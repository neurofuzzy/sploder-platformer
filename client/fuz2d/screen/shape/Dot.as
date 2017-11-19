/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2007 Geoffrey P. Gaudreault
* 
*/

package fuz2d.screen.shape {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import fuz2d.model.environment.*;
	import fuz2d.model.object.*;
	import fuz2d.screen.*;
	import fuz2d.util.Geom2d;
	
	import flash.display.Graphics;
	
	public class Dot extends Polygon {
			
		protected var _label:TextField;
		protected var _format:TextFormat;
		
		protected var _size:Number;
		
		override public function get adjustedColor():uint { return 0xffffff; }
		
		//
		//
		public function Dot (view:View, container:ViewSprite) {
			
			super(view, container);
			
			_size = Marker(_container.objectRef).markerSize;
			
			View.mainStage.addEventListener(Event.ENTER_FRAME, onFrame);
			
				
		}
		
		//
		//
		override public function setPoints ():Boolean {
			
			_screenPoints = [];
			
			if (_container.objectRef.parentObject != null) {
				if (_view.objectSprites[_container.objectRef.parentObject] != null) {
					_container.dobj.x = ViewSprite(_view.objectSprites[_container.objectRef.parentObject]).dobj.x;
					_container.dobj.y = ViewSprite(_view.objectSprites[_container.objectRef.parentObject]).dobj.y;
				}
			}

			_container.screenPt = _view.translate2d(_container.objectRef);

			return true;

		}
		
		//
		//
		public function onFrame (e:Event):void {
			draw(Sprite(_container.dobj).graphics);
		}
		
		//
		//
		override protected function draw (g:Graphics, clear:Boolean = true):void	{
			
			if (clear) g.clear();
			
			//if (setPoints()) {

				_size = Marker(_container.objectRef).markerSize;

				if (_size < 10) {
					g.beginFill(adjustedColor, _container.objectRef.material.opacity);
					g.beginFill(0x00ffff, 1);
				} else {
					g.lineStyle(3, adjustedColor, _container.objectRef.material.opacity * 0.5);
				}
				
				g.drawCircle(0, 0, _size);

				g.endFill();
				
				if (_container.objectRef.material.glow) {
					//_glow.draw();
				}
				
			//}
			
			if (_label == null) {
				
				_label = new TextField();
				_label.autoSize = "center";
				_label.textColor = adjustedColor;
				_format = new TextFormat("_sans");
				_format.align = "center";
				_label.setTextFormat(_format);
				Sprite(_container.dobj).addChild(_label);

			} 
			
			_label.text = Marker(_container.objectRef).label;
			_label.textColor = adjustedColor;
			_label.x = 0 - _label.width / 2;
			_label.y = 0 - _label.height - _size - 5;
			_label.setTextFormat(_format);		
			
			if (Marker(_container.objectRef).alwaysOnTop) {
				_container.objectRef.idx = 50;
				_container.objectRef.z = 50;
			}
			
		}
		
	}
	
}
