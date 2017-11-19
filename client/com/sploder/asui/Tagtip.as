package com.sploder.asui {
    
	import flash.display.Graphics;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
    
    public class Tagtip {

        private static var _mc:Sprite;
		private static var _mcBg:Sprite;
		private static var _mcBgShadow:Sprite;
        private static var _container:Sprite;
		
		private static var _stage:Stage;
        private static var _width:Number = 150;
		private static var _initialized:Boolean;
        
        private static var _tipFormat:TextFormat;
        private static var _tipText:TextField;
        
        private static var cornerRadius:Number;
        private static var arrowRadius:Number;
        private static var padding:Number;
        
        private static var bkgdColor:Number;
        private static var borderColor:Number;
        private static var borderThickness:Number;
        private static var border:Boolean = false;
        private static var textColor:Number;
        
        private static var showTime:Number = 0;
        private static var fontName:String = "Verdana";
        private static var fontSize:Number = 10;
        private static var embed:Boolean = false;
        private static var heightOffset:Number;
        
        public static var showing:Boolean = false;
		public static var active:Boolean = true;
		
		public static var showMaxTime:Number = 8000;
		public static var showDelay:Number = 1000;
		private static var showInterval:Number;
    
        //
        //
        public static function initialize (stage:Stage):void {
  
			if (_initialized) return;
			
			_stage = stage;
			_container = new Sprite();
			_container.mouseEnabled = _container.mouseChildren = false;
			_stage.addChild(_container);

			cornerRadius = 4;
			arrowRadius = 10;
			padding = 4;

			heightOffset = -4;
			bkgdColor = 0x333333;
			border = true;
			borderColor = 0x666666;
			textColor = 0xffffff;
			borderThickness = 2;
			
			_mc = new Sprite();
			_mc.mouseEnabled = _mc.mouseChildren = false;
			_container.addChild(_mc);

			makeTextField();
			
			_mc.visible = false;
			
			_initialized = true;
            
        }
        
        public static function destroy():void {

            if (_mc != null && _container != null && _container.getChildIndex(_mc) != -1) _container.removeChild(_mc);
			
        }
    
        //
        //
        // RENDERTEXT creates a textfield for a text node
        private static function makeTextField ():void {

    
            _tipFormat = new TextFormat();
            _tipFormat.align = "center";
            _tipFormat.font = fontName;
            _tipFormat.size = fontSize;
            _tipFormat.color = textColor;
            
			_tipText = new TextField();
			_tipText.width = _width;
			_tipText.height = parseInt(_tipFormat.size as String);
			_mc.addChild(_tipText);
			
            _tipText.embedFonts = embed;
            _tipText.selectable = false;
            _tipText.multiline = true;
            _tipText.wordWrap = true;
            _tipText.autoSize = "center";
			_tipText.mouseEnabled = false;
            _tipText.text = "";
            
            _tipText.setTextFormat(_tipFormat);
    
        }
    
        //
        //
        // DRAWTAG draws the text tag for the point
        private static function drawTag ():void {

            if (!_mc) return;
    
            var textOffset:Number = _tipText.y - 2;
            var textWidth:Number = _tipText.width + padding + 10;
            var textHeight:Number = _tipText.height + padding;
            var iconWidth:Number = arrowRadius;
            var iconHeight:Number = arrowRadius;
            var xOffset:Number = Math.max(0 - (_container.mouseX - 20) + _tipText.width / 2,Math.min(0,(_stage.stageWidth) - (_container.mouseX + 20) - _tipText.width / 2));
    
            _tipText.x = xOffset - _tipText.width / 2;
    
            if (_mcBg == null) {
				_mcBgShadow = new Sprite();
				_mcBgShadow.mouseEnabled = false;
				_mc.addChild(_mcBgShadow);
				_mcBg = new Sprite();
				_mcBg.mouseEnabled = false;
				_mc.addChild(_mcBg);
            } else {
                _mcBg.graphics.clear();
				_mcBgShadow.graphics.clear();
            }
    
			var g:Graphics;
			
			g = _mcBg.graphics;
			
            g.beginFill(bkgdColor, 1);
                
            if (border == true) {
                g.lineStyle(borderThickness, borderColor, 1, true);
            }
			
			var o:Number = Math.max(xOffset - _tipText.width / 2 + 4, Math.min(0, xOffset + _tipText.width / 2 - 4));
            
            g.moveTo(xOffset + 0 - textWidth / 2 + cornerRadius, textOffset)
            g.lineTo(xOffset + textWidth / 2 - cornerRadius, textOffset);
            g.curveTo(xOffset + textWidth / 2, textOffset, xOffset + textWidth / 2, textOffset + cornerRadius);
            g.lineTo(xOffset + textWidth / 2, textOffset + cornerRadius);
            g.lineTo(xOffset + textWidth / 2, textOffset + textHeight - cornerRadius);
            g.curveTo(xOffset + textWidth / 2, textOffset + textHeight, xOffset + textWidth / 2 - cornerRadius, textOffset + textHeight);
            g.lineTo(xOffset + textWidth / 2 - cornerRadius, textOffset + textHeight);
                
            // arrow
            g.lineTo(iconWidth / 2 + o, textOffset + textHeight);
            g.lineTo(0 + o, 0);
            g.lineTo(0 - iconWidth / 2 + o, textOffset + textHeight);
                 
            g.lineTo(xOffset + 0 - textWidth / 2 + cornerRadius, textOffset + textHeight);
            g.curveTo(xOffset + 0 - textWidth / 2, textOffset + textHeight, xOffset + 0 - textWidth / 2, textOffset + textHeight - cornerRadius);
            g.lineTo(xOffset + 0 - textWidth / 2, textOffset + textHeight - cornerRadius);
            g.lineTo(xOffset + 0 - textWidth / 2, textOffset + cornerRadius);
            g.curveTo(xOffset + 0 - textWidth / 2, textOffset, xOffset + 0 - textWidth / 2 + cornerRadius, textOffset);
            g.lineTo(xOffset + 0 - textWidth / 2 + cornerRadius, textOffset);
                
            g.endFill();
    
            // draw shadow
            _mcBgShadow.x = _mcBgShadow.y = 4;
			
			g = _mcBgShadow.graphics;
    
            g.beginFill(0x000000, 0.1);
                
            g.moveTo(xOffset + 0 - textWidth / 2 + cornerRadius, textOffset)
            g.lineTo(xOffset + textWidth / 2 - cornerRadius, textOffset);
            g.curveTo(xOffset + textWidth / 2, textOffset, xOffset + textWidth / 2, textOffset + cornerRadius);
            g.lineTo(xOffset + textWidth / 2, textOffset + cornerRadius);
            g.lineTo(xOffset + textWidth / 2, textOffset + textHeight - cornerRadius);
            g.curveTo(xOffset + textWidth / 2, textOffset + textHeight, xOffset + textWidth / 2 - cornerRadius, textOffset + textHeight);
            g.lineTo(xOffset + textWidth / 2 - cornerRadius, textOffset + textHeight);
                
			
            // arrow
            g.lineTo(iconWidth / 2 + o, textOffset + textHeight);
            g.lineTo(0 + o, 0);
            g.lineTo(0 - iconWidth / 2 + o, textOffset + textHeight);
                 
            g.lineTo(xOffset + 0 - textWidth / 2 + cornerRadius, textOffset + textHeight);
            g.curveTo(xOffset + 0 - textWidth / 2, textOffset + textHeight, xOffset + 0 - textWidth / 2, textOffset + textHeight - cornerRadius);
            g.lineTo(xOffset + 0 - textWidth / 2, textOffset + textHeight - cornerRadius);
            g.lineTo(xOffset + 0 - textWidth / 2, textOffset + cornerRadius);
            g.curveTo(xOffset + 0 - textWidth / 2, textOffset, xOffset + 0 - textWidth / 2 + cornerRadius, textOffset);
            g.lineTo(xOffset + 0 - textWidth / 2 + cornerRadius, textOffset);
                
            g.endFill();
			
			_mc.setChildIndex(_tipText, 2);
    
        }
    
        //
        //
        public static function showTag (theText:String, now:Boolean = false):void {    

            if (!_mc) return;
			if (!active) return;
			
			if (showInterval > 0) {
				clearInterval(showInterval);
				showInterval = 0;
			}
			
			_container.parent.setChildIndex(_container, _container.parent.numChildren - 1);

            if (!showing && theText.length > 0 && theText != "undefined") {
                
                showing = true;
                
				_tipText.text = theText;
                _tipText.setTextFormat(_tipFormat);
                _tipText.y = 0 - (_tipText.height + 10);
                
                _mc.x = _container.mouseX;
                _mc.y = _container.mouseY;
                
                drawTag();
                _mc.visible = false;
                _mc.alpha = 1;
                
                showTime = getTimer();
				_mc.addEventListener(Event.ENTER_FRAME, followMouse, false, 0, true);
				
				showInterval = setInterval(showDelayed, now ? 10 : showDelay);
                
            } else {
                
                hideTag();
                
            }
            
        }
		
		protected static function showDelayed ():void {
			
			_mc.visible = true;
			
		}
    
        //
        //
        public static function hideTag ():void {

			if (showing) {
				
				if (showInterval > 0) {
					clearInterval(showInterval);
					showInterval = 0;
				}
					
				if (!_mc) return;
				
				showing = false;
				_mc.visible = false;
				_mc.alpha = 1;
				
				_mc.removeEventListener(Event.ENTER_FRAME, followMouse);
				
			}
    
        }
        
        //
        //
        public static function followMouse (e:Event):void {
     
            if (!_mc) return;
            
            _mc.x = _container.mouseX >> 0;
            _mc.y = (_container.mouseY + heightOffset) >> 0;
			
			_mc.scaleY = _tipText.scaleY = 1;
			_tipText.y = 0 - (_tipText.height + 10);
			
            drawTag();
			
			if (_container.mouseY > 40) {
				_mc.scaleY = _tipText.scaleY = 1;
				_tipText.y = 0 - (_tipText.height + 10);
			} else {
				_mc.scaleY = _tipText.scaleY = -1;
				_tipText.y = -10;
				_mc.y += 20;
			}

            if (getTimer() - showTime > showMaxTime) {
                _mc.alpha = Math.max(0, 100 - (((getTimer() - showTime) - showMaxTime) / 5)) / 100;
                if (_mc.alpha <= 0) {
                    hideTag();
                }
            }
            
        }
		
		public static function connectButton (b:SimpleButton, alt:String = "", now:Boolean = false):void {
			
			b.addEventListener(MouseEvent.MOUSE_OVER, function (e:MouseEvent):void { Tagtip.showTag(alt, now); }, false, 0, true);
			b.addEventListener(MouseEvent.MOUSE_OUT, function (e:MouseEvent):void { Tagtip.hideTag(); }, false, 0, true);
			
		}
        
    
    }
}
