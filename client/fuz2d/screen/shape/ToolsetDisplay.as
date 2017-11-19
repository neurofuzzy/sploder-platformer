package fuz2d.screen.shape {
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import fuz2d.Fuz2d;
	import fuz2d.model.environment.OmniLight;
	import fuz2d.model.object.Biped;
	import fuz2d.model.object.Toolset;
	import fuz2d.screen.View;
	import fuz2d.util.Geom2d;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class ToolsetDisplay {
		
		protected var _container:ViewSprite;
		protected var _parentClip:Sprite;
		protected var _toolset:Toolset;
		
		protected var _facing:uint = 0;
		public function get facing():uint { return _facing; }
		public function set facing(value:uint):void 
		{
			if (value != _facing) {
				_facing = value;
				_facingChanged = true;
			}
		}
		
		protected var _facingChanged:Boolean = false;
		
		protected var _tool:Sprite;
		public function get tool():Sprite { return _tool; }
		
		
		
		protected var _displayIndex:int = -1;
		
		protected var _prevRefPt:Point;
		protected var _controlPoint:Point;
		protected var _endPoint:Point;
		protected var _smoothedEndPoint:Point;
		protected var _isWhip:Boolean = false;
		protected var m:Matrix;
		
		//
		//
		public function ToolsetDisplay (container:ViewSprite, parentClip:Sprite, toolset:Toolset) {
			
			init(container, parentClip, toolset);
			
		}
		
		//
		//
		protected function init (container:ViewSprite, parentClip:Sprite, toolset:Toolset):void {
			
			_container = container;
			_parentClip = parentClip;
			_toolset = toolset;	
			
			_prevRefPt = new Point();
			_controlPoint = new Point();
			_endPoint = new Point();
			_smoothedEndPoint = new Point();
			
			m = new Matrix();
			m.createGradientBox(250, 100, 0);
			
			if (_toolset.tools == null) return;
			
			for (var i:int = 0; i < _toolset.tools.length; i++) {
				
				if (_parentClip[_toolset.tools[i]] is Sprite)
				{
					Sprite(_parentClip[_toolset.tools[i]]).visible = false;
				}
				
			}
			
			if (_parentClip[_toolset.toolname] is Sprite) _tool = _parentClip[_toolset.toolname];
			
			if (_tool != null) {
				
				_tool.visible = true;

				update();
				
			}
			
		}
		
		//
		//
		protected function alignRefPt (pt:Point, useToolTip:Boolean = true):Point {
			
			var noParent:Boolean = false;
			
			if (_container.dobj.parent == null) {
							
				Fuz2d.mainInstance.view.container.addChild(_container.dobj);
				noParent = true;
				
			}
			
			pt = Sprite(_container.dobj.parent).localToGlobal(pt);
			
			if (useToolTip) pt = Sprite(_tool["tooltip"]).globalToLocal(pt);
			else pt = _tool.globalToLocal(pt);
				
			if (noParent) _container.dobj.parent.removeChild(_container.dobj);	
			
			return pt;
			
		}
		
		//
		//
		public function update ():void {
						
			if (_tool != null) {
				_tool.visible = _toolset.visible;
			}
			
			if (_tool != null && _toolset.toolLights[_tool.name] != null) {
				OmniLight(_toolset.toolLights[_tool.name]).brightness = 0.85 + Math.random() * 0.15;
			}
			
			var g:Graphics;
			var refPt:Point;
			
			if (_tool && _tool["swing"] != null && _container.objectRef.attribs.swing) {
				_container.objectRef.attribs.swing = false;
				_tool["swing"].play();
			}
			
			if (_tool != null && _tool.name == "grapple") {

				if (_toolset.toolHitPoint != null) {
					
					refPt = new Point(_toolset.toolHitPoint.x, 0 - _toolset.toolHitPoint.y);
					
					if (_tool["tooltip"] != null) {
						
						g = Sprite(_tool["tooltip"]).graphics;
						g.clear();
						
						refPt = alignRefPt(refPt);
	
					} else {
						
						g = _tool.graphics;
						g.clear();
						
						refPt = alignRefPt(refPt, false);
						
					}
					
					g.moveTo(0, 0);
					g.lineStyle(6 / View.scale, 0x00ff00, 0.8 + Math.random() * 0.2);
					g.lineTo(refPt.x, refPt.y);
					
					if (_toolset.toolLights[_tool.name] != null) OmniLight(_toolset.toolLights[_tool.name]).brightness = 0.4 + Math.random() * 0.15;
		
				} else {
					
					if (_tool["tooltip"] != null) Sprite(_tool["tooltip"]).graphics.clear();
					else _tool.graphics.clear();
					
					if (_toolset.toolLights[_tool.name] != null) OmniLight(_toolset.toolLights[_tool.name]).brightness = 0;
					
				}
				
			}
			
			if (_tool != null && _tool.name == "blaster") {

				if (_toolset.toolHitPoint != null) {
					
					refPt = new Point(_toolset.toolHitPoint.x, 0 - _toolset.toolHitPoint.y);
					
					if (_tool["tooltip"] != null) {
						
						g = Sprite(_tool["tooltip"]).graphics;
						g.clear();
						
						refPt = alignRefPt(refPt);
						
					} else {
						
						g = _tool.graphics;
						g.clear();
						
						refPt = alignRefPt(refPt, false);
						
					}
					
					g.moveTo(0, 0);
					g.beginFill(0xff33ff, 1);
					g.drawCircle(0, 0, 10);
					g.endFill();
					g.lineStyle(6 / View.scale, 0xcc00ff, 0.7 + Math.random() * 0.5);
					g.lineTo(refPt.x, refPt.y);
					g.moveTo(0, 0);
					g.lineStyle(2, 0xff66ff);
					g.lineTo(refPt.x, refPt.y);
					
					if (_toolset.toolLights[_tool.name] != null) OmniLight(_toolset.toolLights[_tool.name]).brightness = 0.4 + Math.random() * 0.15;
		
				} else {
					
					if (_tool["tooltip"] != null) Sprite(_tool["tooltip"]).graphics.clear();
					else _tool.graphics.clear();
					
					if (_toolset.toolLights[_tool.name] != null) OmniLight(_toolset.toolLights[_tool.name]).brightness = 0;
					
				}
				
			}
			
			if (_tool != null && _tool.name == "whip") {
				
				if (_toolset.tooltip != null) {
					
					var snap:Boolean = false;
										
					refPt = new Point(_toolset.tooltip.x, 0 - _toolset.tooltip.y);
					
					var offset:Number = 1;
					
					if (_isWhip && !_facingChanged) {
						//offset = Geom2d.distanceBetweenPoints(refPt, _prevRefPt);
						offset = Geom2d.horizontalDistanceBetweenPoints(refPt, _prevRefPt);
						if (offset > -1 && offset < 0) offset = -1; 
						else if (offset < 1 && offset > 0) offset = 1;
					}
					
					if (_container.objectRef.attribs.whipping) {
						offset = 100;
						snap = true;
						refPt.y = 0 - _container.objectRef.y;
					} else if (offset < 50) {
						offset = 0 - offset; 
					} else {
						offset *= 0.5;
					}
					
					if (facing == Biped.FACING_LEFT) {
						offset = 0 - offset;
					}

					_controlPoint.x = refPt.x;
					_controlPoint.y = refPt.y;
					_endPoint.x = refPt.x + offset * 2.5;
					_endPoint.y = refPt.y;
					
					_prevRefPt.x = refPt.x;
					_prevRefPt.y = refPt.y;
					
					if (!(_prevRefPt.x == 0 && _prevRefPt.y == 0)) {
						
						if (_tool["whiplash"] != null) {
							
							g = Sprite(_tool["whiplash"]).graphics;
							
							refPt = alignRefPt(refPt);
							_controlPoint = alignRefPt(_controlPoint);
							_controlPoint.x += 100;
							_endPoint = alignRefPt(_endPoint);
							_endPoint.y += 200 / Math.max(1, Math.abs(offset));
							
							_smoothedEndPoint.x += (_endPoint.x - _smoothedEndPoint.x) * 0.3;
							_smoothedEndPoint.y += (_endPoint.y - _smoothedEndPoint.y) * 0.3;
							
							if (snap || !_isWhip || _facingChanged) {
								_smoothedEndPoint.x = _endPoint.x;
								_smoothedEndPoint.y = _endPoint.y;							
							}
						
							g.clear();
							g.moveTo(0, 0);
							var a:Number = 0.4 + Math.random() * 0.2;
							g.lineStyle(24 / View.scale, 0xff0000, a);
							g.curveTo(_controlPoint.x, _controlPoint.y, _smoothedEndPoint.x, _smoothedEndPoint.y);
							g.moveTo(0, 0);
							g.lineStyle(8 / View.scale, 0xff0000, a + 0.4);
							g.curveTo(_controlPoint.x, _controlPoint.y, _smoothedEndPoint.x, _smoothedEndPoint.y);
							
							if (snap) {
								
								g.lineGradientStyle(GradientType.LINEAR, [0xff0000, 0xffffff], [1, 1], [0, 255], m);
								g.moveTo(0, 0);
								g.curveTo(_controlPoint.x, _controlPoint.y, _smoothedEndPoint.x, _smoothedEndPoint.y);
								
								
								_endPoint.x = _container.objectRef.x;
								_endPoint.x += offset * 2.5;
								_endPoint.y = _container.objectRef.y;
								_container.objectRef.attribs.snapPoint = _endPoint.clone();
								
							}
							
						}
						
					} else {
						
						_smoothedEndPoint.x = _endPoint.x;
						_smoothedEndPoint.y = _endPoint.y;
						
					}
					
				}
				
				_isWhip = true;
				
			} else {
				
				_isWhip = false;
				
			}

			if (_displayIndex != _toolset.toolIndex) {
				
				if (_tool != null)  {
					_tool.visible = false;
					if (_tool["tooltip"] != null) Sprite(_tool["tooltip"]).graphics.clear();
					else _tool.graphics.clear();
				}
				
				_container.objectRef.attribs.swing = false;
				
				if (_parentClip[_toolset.toolname] is Sprite) _tool = _parentClip[_toolset.toolname];

				if (_tool != null) {
					
					_tool.visible = _toolset.visible;
					_displayIndex = _toolset.toolIndex;
					
					var mc:MovieClip;
					
					if (_toolset.toolIllums[_tool.name] != null && _toolset.toolIllums[_tool.name].length > 0) {
						
						mc = _tool[_toolset.toolIllums[_tool.name]];
						
						if (mc != null) mc.transform.colorTransform = new ColorTransform(2, 2, 2);
						
					}
					
					_container.view.forceRender();
					
				} 

			}
			
			if (_toolset.activeClip != null) {
				Sprite(_tool[_toolset.activeClip]).visible = _toolset.active;
				OmniLight(_toolset.toolLights[_tool.name]).enabled = _toolset.active;
			}
			
			if (_toolset.action == "aim" && _toolset.spawn == "spear") {
				_tool.visible = _toolset.active;
			}
			
			_facingChanged = false;
			
			if (_container.objectRef.graphic > 0 && _container.objectRef.symbolName != "player")
			{
				if (_tool is MovieClip) MovieClip(_tool).gotoAndStop(2);
			}
			
		}
		
	}
	
}