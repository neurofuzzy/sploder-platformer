/**
* ...
* @author Default
* @version 0.1
*/

package fuz2d.screen.shape {
	
	
	import com.sploder.data.DataLoader;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import fuz2d.action.physics.Vector2d;
	import fuz2d.library.ObjectFactory;
	import fuz2d.screen.shape.ViewSprite;
	
	import fuz2d.action.physics.MotionObject;
	import fuz2d.model.*;
	import fuz2d.model.environment.*;
	import fuz2d.model.object.*;
	import fuz2d.screen.*;
	import fuz2d.util.*;

	
	public class HealthAssetDisplay extends AssetDisplay {
		
		protected var _healthDisplay:Sprite;
		protected var _healthBar:MovieClip;
		protected var _healthBarWidth:Number;

		//
		//
		public function HealthAssetDisplay (view:View, container:ViewSprite) {
			
			super(view, container);
			
			assign();

		}
		
		//
		//
		override protected function init(view:View, container:ViewSprite):void {
			
			super.init(view, container);
			
		}
		
		//
		//
		protected function assign ():void {
			
			_healthDisplay = _clip["healthmeter"];
			
			if (_healthDisplay != null) {
				_healthDisplay.y = 0 - _clip.height / 2 - 30;
			}
			if (_healthDisplay != null) {
				_healthBar = _healthDisplay["bar"];
				if (_healthBar != null) _healthBarWidth = _healthBar.width;
			}
	
		}
		
		//
		//
	    override protected function draw(g:Graphics, clear:Boolean = true):void {
		
			super.draw(g, clear);
			
			if (_container.objectRef == null) return;

			if (_healthBar != null && _container.objectRef.attribs.health != null) {
				var hw:Number = Math.floor(_container.objectRef.attribs.health * _healthBarWidth);
				if (hw <= 0) {
					_healthDisplay.visible = false;
				} else if (hw != _healthBar.width) {
					_healthBar.width = hw;
					_healthBar.play();
				}
			}
			
			_healthDisplay.scaleX = _clip.scaleX;
			
			if (_healthDisplay.scaleX == -1) {
				_healthDisplay.x = _healthDisplay.width / 2;
			} else {
				_healthDisplay.x = 0 - _healthDisplay.width / 2;
			}
			
		}
		
	}
	
}
