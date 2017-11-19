/**
* ...
* @author Default
* @version 0.1
*/

package fuz2d.screen.shape {

	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import fuz2d.action.physics.Vector2d;
	import fuz2d.library.ObjectFactory;
	import fuz2d.screen.shape.ViewSprite;
	
	import fuz2d.model.*;
	import fuz2d.model.environment.*;
	import fuz2d.model.object.*;
	import fuz2d.screen.*;
	import fuz2d.util.*;

	
	public class SegDisplay extends AssetDisplay {
		
		protected var _seg:SegSymbol;
		
		protected var _body:Sprite;
		protected var _foot_lt:MovieClip;
		protected var _foot_rt:MovieClip;
		protected var _legs:MovieClip;

		protected var _lean:Number = 0;
		protected var _legX:Number = 0;
		protected var _legY:Number = 0;
		
		protected var _ltV:Vector2d;
		protected var _rtV:Vector2d;
		protected var _ltP:Point;
		protected var _rtP:Point;
		
		protected var _ltF:Point;
		protected var _rtF:Point;
		
		protected var _ltFc:Point;
		protected var _rtFc:Point;
		
		//
		//
		public function SegDisplay (view:View, container:ViewSprite) {
			
			_seg = SegSymbol(container.objectRef);
			
			super(view, container);
			
			_container.objectRef.zSortChildNodes = false;
			
			assign();

		}
		
		//
		//
		override protected function init(view:View, container:ViewSprite):void {
			
			super.init(view, container);
			
			_ltV = new Vector2d();
			_rtV = new Vector2d();
			_ltP = new Point();
			_rtP = new Point();
			_ltF = new Point();
			_rtF = new Point();
			_ltFc = new Point();
			_rtFc = new Point();
			
		}
		
		//
		//
		protected function assign ():void {
			
			_body = _clip["body"];
			_foot_lt = _clip["foot_lt"];
			_foot_rt = _clip["foot_rt"];
			_legs = _clip["legs"];
			
			_legX = _foot_rt.x;
			_legY = _foot_rt.y;
			
		}
		
		//
		//
	    override protected function draw(g:Graphics, clear:Boolean = true):void {
		
			super.draw(g, clear);
			
			if (_container.objectRef == null) return;
			
			updateStance();

		}

		public function updateStance ():void {

			_ltF.x += (_seg.footPointLeft.x - _ltF.x) * 0.3;
			_ltF.y += (_seg.footPointLeft.y - _ltF.y) * 0.3;

			_rtF.x += (_seg.footPointRight.x - _rtF.x) * 0.3;
			_rtF.y += (_seg.footPointRight.y - _rtF.y) * 0.3;
			
			if (Geom2d.squaredDistanceBetweenPoints(_seg.footPointLeft, _ltF) < 500) {
				_ltF.x = _seg.footPointLeft.x;
				_ltF.y = _seg.footPointLeft.y;
				_container.objectRef.attribs.leftSnap = true;
			} else {
				_container.objectRef.attribs.leftSnap = false;
			}
			
			if (Geom2d.squaredDistanceBetweenPoints(_seg.footPointRight, _rtF) < 500) {
				_rtF.x = _seg.footPointRight.x;
				_rtF.y = _seg.footPointRight.y;		
				_container.objectRef.attribs.rightSnap = true;
			} else {
				_container.objectRef.attribs.rightSnap = false;
			}
			
			var g:Graphics = _legs.graphics;
			var ang:Number;
			
			_ltV.alignToPoint(_seg.footPointLeft);
			_ltV.scaleBy(0.5);
			_ltV.alignPoint(_ltP);
			ang = Math.atan2(_ltP.x, _ltP.y);
			_ltV.scaleBy(Math.min(2, 1 / (_ltV.squareMagnitude / 5000)));
			if (Math.abs(_ltV.x) < 50) _ltV.scaleBy(_ltV.x / 50);
			if (_ltV.x > 0) _ltV.rotate(Geom2d.HALFPI);
			else _ltV.rotate(0 - Geom2d.HALFPI);
			_ltV.x += _ltP.x;
			_ltV.y += _ltP.y;
			
			_rtV.alignToPoint(_seg.footPointRight);
			_rtV.scaleBy(0.5);
			_rtV.alignPoint(_rtP);
			ang = Math.atan2(_rtP.x, _rtP.y);
			_rtV.scaleBy(Math.min(2, 1 / (_rtV.squareMagnitude / 5000)));
			if (Math.abs(_rtV.x) < 50) _rtV.scaleBy(_rtV.x / 50);
			if (_rtV.x > 0) _rtV.rotate(Geom2d.HALFPI);
			else _rtV.rotate(0 - Geom2d.HALFPI);
			_rtV.x += _rtP.x;
			_rtV.y += _rtP.y;
			
			var attribs:Object = _container.objectRef.attribs;
			
			g.clear();
			
			if (attribs.rightHit) {
				g.moveTo(0, 0);
				g.lineStyle(36, 0xffffff, 0.2 + Math.random() * 0.5);
				g.curveTo(_rtV.x, 0 - _rtV.y, _rtF.x, 0 - _rtF.y);
			}
			if (attribs.leftHit) {
				g.moveTo(0, 0);
				g.lineStyle(36, 0xffffff, 0.2 + Math.random() * 0.5);
				g.curveTo(_ltV.x, 0 - _ltV.y, _ltF.x, 0 - _ltF.y);
			}
			
			g.moveTo(0, 0);
			g.lineStyle(18, 0xffffff, 0.2);
			g.curveTo(_rtV.x, 0 - _rtV.y, _rtF.x, 0 - _rtF.y);
			g.moveTo(0, 0);
			g.lineStyle(18, 0xffffff, 0.2);
			g.curveTo(_ltV.x, 0 - _ltV.y, _ltF.x, 0 - _ltF.y);
			
			g.moveTo(0, 0);
			g.lineStyle(12, 0x333333, 1);
			if (attribs.rightHit) g.lineStyle(12, 0xffffff, 1);
			g.curveTo(_rtV.x, 0 - _rtV.y, _rtF.x, 0 - _rtF.y);
			g.moveTo(0, 0);
			g.lineStyle(12, 0x333333, 1);
			if (attribs.leftHit) g.lineStyle(12, 0xffffff, 1);
			g.curveTo(_ltV.x, 0 - _ltV.y, _ltF.x, 0 - _ltF.y);
			
			_foot_lt.x = _ltF.x;
			_foot_lt.y = 0 - _ltF.y;
			_foot_rt.x = _rtF.x;
			_foot_rt.y = 0 - _rtF.y;
			
			if (!isNaN(attribs.xv)) {
				_body.rotation = (0 - attribs.xv) * 0.1;
			}
			
		}
		
		override public function destroy():void {

			super.destroy();
			
		}
	
	}
	
}
