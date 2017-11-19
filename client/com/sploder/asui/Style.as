package com.sploder.asui {
	
    import com.sploder.asui.ColorTools;
    
	import flash.text.StyleSheet;
	import flash.system.Capabilities;
    
    
    public class Style {
        
        private var _styleSheet:StyleSheet;
		
		public static const DEFAULT_HTML_FONT:String = "Verdana, Helvetica, Arial";
        
        private var css:String;
		
		private var cloneParams:Array = [
			"_textColor", "_titleColor", "_linkColor", 
			"_hoverColor", "_inverseTextColor", "_buttonTextColor", "_backgroundColor", 
			"_inputColorA", "_inputColorB", "_borderColor", 
			"_backgroundAlpha", "_buttonColor", "_buttonBorderColor", "_selectedButtonColor", "_selectedButtonBorderColor", 
			"_borderAlpha", "_maskColor", "_maskAlpha", 
			"_unselectedColor", "_unselectedTextColor", "_unselectedBorderColor", "_inactiveColor", 
			"_inactiveTextColor", "_haloColor", "_highlightTextColor", 
			"_gradient", "_background", "_border", "_bgGradient", 
			"_bgGradientColors", " _bgGradientRatios", "_bgGradientHeight", 
			"_padding", "_round", "_borderWidth", "_buttonDropShadow", "_fontSize", 
			"_titleFontSize", "_buttonFontSize", "_embedFonts", "_font",  
			"_fonts", "_buttonFont", "_titleFont", "_htmlFont"
			];
		
        private var _textColor:Number = 0xcccccc;
        private var _titleColor:Number = 0xffec00;
        private var _linkColor:Number = 0xffec00;
        private var _hoverColor:Number = 0xffff33;
        private var _inverseTextColor:Number = 0xffffff;
		private var _buttonTextColor:Number = 0xffffff;
        private var _backgroundColor:Number = 0x000000;
		private var _inputColorA:Number = 0x000000;
		private var _inputColorB:Number = 0x333333;
		private var _borderColor:Number = 0x999999;
        private var _backgroundAlpha:Number = 1;
        private var _buttonColor:Number = 0x660066;
        private var _buttonBorderColor:Number = -1;
		private var _selectedButtonColor:Number = -1;
		private var _selectedButtonBorderColor:Number = -1;
		private var _borderAlpha:Number = 1;
		private var _maskColor:Number = 0x000000;
		private var _maskAlpha:Number = 0.5;
        private var _unselectedColor:Number = 0x330033;
        private var _unselectedTextColor:Number = 0x666666;
		private var _unselectedBorderColor:Number = -1;
        private var _inactiveColor:Number = 0x330033;
        private var _inactiveTextColor:Number = 0x666666;
        private var _haloColor:Number = 0xff9900;
        private var _highlightTextColor:Number = 0xffcc00;
        
        private var _gradient:Boolean = true;
        private var _background:Boolean = true;
        private var _border:Boolean = true;
		
		private var _bgGradient:Boolean = false;
		private var _bgGradientColors:Array = [0xffffff, 0xeeeeee];
		private var _bgGradientRatios:Array = [0, 255];
		private var _bgGradientHeight:int = 0;
        
        private var _padding:Number = 6;
        private var _round:Number = 8;
        private var _borderWidth:Number = 4;
		private var _buttonDropShadow:Boolean = false;
        
        private var _fontSize:Number = 12;
        private var _titleFontSize:Number = 15;
		private var _buttonFontSize:Number = 12;
        
        private var _embedFonts:Boolean = false;
        private var _font:String = "Verdana";
        private var _fonts:Array = ["Verdana", "Tahoma", "Arial"];
		private var _buttonFont:String = "";
		private var _titleFont:String = "";
        private var _htmlFont:String = "Verdana, Helvetica, Arial";
        
        public function get textColor():Number { return _textColor; }
        public function set textColor(value:Number):void { 

            _textColor = value; 
            _inverseTextColor = ColorTools.getInverseColor(_textColor);
            updateColors();
            updateCSS();
        }
        
        public function get titleColor():Number { return _titleColor; }
        public function set titleColor(value:Number):void { 

            _titleColor = value;
            updateColors();
            updateCSS();
        }
        
        public function get linkColor():Number { return _linkColor; }
        public function set linkColor(value:Number):void {

            _linkColor = value;
            updateColors();
            updateCSS();
        }
    
        public function get hoverColor():Number { return _hoverColor; }
        public function set hoverColor(value:Number):void {

            _hoverColor = value;
            updateCSS();
        }
        
        public function get backgroundColor():Number { return _backgroundColor; }
        public function set backgroundColor(value:Number):void {

            _backgroundColor = value;
            updateColors();
            updateCSS();
        }
		
		
		public function get inputColorA():Number { return _inputColorA; }
		public function set inputColorA(value:Number):void { _inputColorA = value; }
		
		public function get inputColorB():Number { return _inputColorB; }
		public function set inputColorB(value:Number):void { _inputColorB = value; }
		
        public function get borderColor():Number { return (!isNaN(_borderColor)) ? _borderColor : _textColor; }
        public function set borderColor(value:Number):void { 

            _borderColor = value;
            updateColors();
        }
        
        public function get buttonColor():Number { return _buttonColor; }
        public function set buttonColor(value:Number):void { 

            _buttonColor = value;
            updateColors();
        }
		
		public function get buttonBorderColor():Number { return (_buttonBorderColor != -1) ? _buttonBorderColor : ColorTools.getTintedColor(_buttonColor, 0, 0.2); }
		public function set buttonBorderColor(value:Number):void { _buttonBorderColor = value; }
		
		public function get selectedButtonColor():Number { return (_selectedButtonColor != -1) ? _selectedButtonColor : _inverseTextColor; }
		public function set selectedButtonColor(value:Number):void { _selectedButtonColor = value; }
		
		public function get selectedButtonBorderColor():Number { return (_selectedButtonBorderColor != -1) ? _selectedButtonBorderColor : _inverseTextColor; }
		public function set selectedButtonBorderColor(value:Number):void { _selectedButtonBorderColor = value; }
		
		
		public function get borderAlpha():Number { return _borderAlpha; }
		public function set borderAlpha(value:Number):void  {
			_borderAlpha = value;
		}
		
		public function get maskColor():Number { return _maskColor; }
		public function set maskColor(value:Number):void {
			_maskColor = value;
		}
		
		public function get maskAlpha():Number { return _maskAlpha; }
		public function set maskAlpha(value:Number):void {
			_maskAlpha = value;
		}
 
        
        public function get inverseTextColor():Number { return _inverseTextColor; } 
        public function set inverseTextColor(value:Number):void { _inverseTextColor = value; }

        
        public function get gradient():Boolean { return _gradient; }
        public function set gradient(value:Boolean):void { _gradient = value; }

        
        public function get background():Boolean { return _background; }
        public function set background(value:Boolean):void { _background = value; }

        
        public function get backgroundAlpha():Number { return _backgroundAlpha; }
        public function set backgroundAlpha(value:Number):void { _backgroundAlpha = value; }    

        
        public function get border():Boolean { return _border; }
        public function set border(value:Boolean):void { 
			_border = value;
			if (!_border) _borderWidth = 0;
		}

        
        public function get padding():Number { return _padding; }
        public function set padding(value:Number):void { _padding = value; }

        
        public function get round():Number { return _round; }
        public function set round(value:Number):void { _round = value; }

        
        public function get borderWidth():Number { return _borderWidth; }
        public function set borderWidth(value:Number):void { _borderWidth = value;  }
		
		
		public function get buttonDropShadow():Boolean { return _buttonDropShadow; }
		public function set buttonDropShadow(value:Boolean):void { _buttonDropShadow = value; }

        
        public function get fontSize():Number { return _fontSize; }
        public function set fontSize(value:Number):void { 

            _fontSize = value;
            updateCSS();
        }
        
        public function get titleFontSize():Number { return _titleFontSize; }
        public function set titleFontSize(value:Number):void { _titleFontSize = value; }
		
		
		public function get buttonFontSize():Number { return _buttonFontSize; }
		public function set buttonFontSize(value:Number):void { _buttonFontSize = value; }
        
		
        public function get inactiveColor():Number { return _inactiveColor; }
        public function set inactiveColor(value:Number):void { _inactiveColor = value; }

        
        public function get inactiveTextColor():Number { return _inactiveTextColor; }
        public function set inactiveTextColor(value:Number):void { _inactiveTextColor = value; }

        
        public function get unselectedColor():Number { return _unselectedColor; }
        public function set unselectedColor(value:Number):void { _unselectedColor = value; }

        
        public function get unselectedTextColor():Number { return _unselectedTextColor; }
        public function set unselectedTextColor(value:Number):void { _unselectedTextColor = value; }

        
        public function get styleSheet():StyleSheet { return _styleSheet; }
        public function set styleSheet(value:StyleSheet):void { _styleSheet = value; }

        
        public function get haloColor():Number { return _haloColor; }
        public function set haloColor(value:Number):void { _haloColor = value; }

        
        public function get embedFonts():Boolean { return _embedFonts; }
        public function set embedFonts(value:Boolean):void { _embedFonts = value; }

        
        public function get font():String { return _font; }
        public function set font(value:String):void { _font = value; }

		public function get titleFont():String { return (_titleFont.length > 0) ? _titleFont : _font; }
		public function set titleFont(value:String):void {
			_titleFont = value;
		}
		
		public function get buttonFont():String { return (_buttonFont.length > 0) ? _buttonFont : _font; }
		public function set buttonFont(value:String):void {
			_buttonFont = value;
		}

        public function setFont (idx:Number):void { if (_fonts[idx] != null) _font = _fonts[idx]; }

        
        public function getFontsAsString ():String { return _font + ", " + _fonts.join(", "); }
        
        public function get htmlFont():String { return _htmlFont; }
        public function set htmlFont(value:String):void { 

            _htmlFont = value;
            updateCSS();
        }
        
        public function get highlightTextColor():Number { return _highlightTextColor; }
        public function set highlightTextColor(value:Number):void { _highlightTextColor = value; }
		
		public function get bgGradient():Boolean { return _bgGradient; }
		public function set bgGradient(value:Boolean):void { _bgGradient = value; }
		
		public function get bgGradientColors():Array { return _bgGradientColors; }
		public function set bgGradientColors(value:Array):void { _bgGradientColors = value; }
		
		public function get bgGradientRatios():Array { return _bgGradientRatios; }
		public function set bgGradientRatios(value:Array):void { _bgGradientRatios = value; }
		
		public function get bgGradientHeight():int { return _bgGradientHeight; }
		public function set bgGradientHeight(value:int):void { _bgGradientHeight = value; }
		
		public function get buttonTextColor():Number { return (_buttonTextColor != -1) ? _buttonTextColor : _inverseTextColor; }
		public function set buttonTextColor(value:Number):void 
		{
			_buttonTextColor = value;
		}
		
		public function get unselectedBorderColor():Number { return _unselectedBorderColor; }
		public function set unselectedBorderColor(value:Number):void 
		{
			_unselectedBorderColor = value;
		}
		

        private var _options:Object;    
        
        //
        //
        public function Style (options:Object = null) {
            
            init(options);
            
        }
        
        //
        //
        private function init (options:Object = null):void {

            _options = (options != null) ? options : { };
            
            for (var param:String in options) {
				if (this[param] != undefined) this[param] = options[param] else debug ("WARNING: " + param + " does not exist in ui.Style");
			}
            
            if (_options.haloColor == undefined) _haloColor = ColorTools.getTintedColor(ColorTools.getInverseColor(_buttonColor), _backgroundColor, 0.2);
            if (_options.inactiveTextColor == undefined) _inactiveTextColor = ColorTools.getDesaturatedColor(ColorTools.getTintedColor(_inactiveColor, _inverseTextColor, 0.6));
            if (_options.unselectedTextColor == undefined) _unselectedTextColor = ColorTools.getTintedColor(_inverseTextColor, _buttonColor, 0.3);
            if (_options.unselectedColor == undefined) _unselectedColor = ColorTools.getTintedColor(_buttonColor, _borderColor, 0.25);
           
            if (_styleSheet == null) _styleSheet = new StyleSheet();
            
            updateCSS();
           
            if (Capabilities.os.indexOf("Mac") == -1) {
               
                _fonts = ["Verdana", "Arial", "Tahoma"];
                
            } else {
                
                _fonts = ["Verdana", "Monaco", "Geneva"];
                
            }
            
        }
        
        //
        //
        private function updateColors ():void {
    
            if (_options.haloColor == undefined) _haloColor = ColorTools.getTintedColor(ColorTools.getInverseColor(_buttonColor), _backgroundColor, 0.2);
            if (_options.inactiveTextColor == undefined)  inactiveTextColor = ColorTools.getTintedColor(_inactiveColor, 0x000000, 0.6);
            if (_options.unselectedTextColor == undefined) _unselectedTextColor = ColorTools.getTintedColor(_inverseTextColor, _buttonColor, 0.3);
            if (_options.unselectedColor == undefined) _unselectedColor = ColorTools.getTintedColor(_buttonColor, _borderColor, 0.25);
            if (_options.hoverColor == undefined) _hoverColor = ColorTools.getTintedColor(_linkColor, 0xffffff, 0.3);
            
        }
        
        
        //
        //
        private function updateCSS ():void {
            
			if (_styleSheet == null) _styleSheet = new StyleSheet();
			
            var tColor:String = ColorTools.numberToHTMLColor(_titleColor);
            var txtColor:String = ColorTools.numberToHTMLColor(_textColor);
            var lColor:String = ColorTools.numberToHTMLColor(_linkColor);
            var hColor:String = ColorTools.numberToHTMLColor(_hoverColor);
            var nColor:String = ColorTools.numberToHTMLColor(ColorTools.getTintedColor(textColor, backgroundColor, 0.5));
     		var tnColor:String = ColorTools.numberToHTMLColor(ColorTools.getTintedColor(_titleColor, backgroundColor, 0.2));
           
			css = "";
            
            css += "h1 { font-family: " + _htmlFont + "; font-weight: bold; font-size: " + Math.min(18, titleFontSize * 2) + "px; color: " + tColor + "; leading: " + (Math.ceil(Math.min(18, titleFontSize * 2) / 3)) + "px; } ";      
            css += "h2 { font-family: " + _htmlFont + "; font-weight: bold; font-size: " + (titleFontSize + 6) + "px; color: " + tColor + "; leading: " + (Math.ceil((titleFontSize + 6) / 3)) + "px; } ";       
            css += "h3 { font-family: " + _htmlFont + "; font-weight: bold; font-size: " + (titleFontSize) + "px; color: " + tColor + "; leading: " + (Math.ceil(titleFontSize / 3)) + "px; } ";
            css += "h4 { font-family: " + _htmlFont + "; font-weight: bold; font-size: " + (Math.ceil((fontSize + titleFontSize) / 2)) + "px; color: " + tColor + "; leading: " + (Math.ceil((fontSize + titleFontSize) / 6)) + "px; } ";
            css += "h5 { font-weight: bold; font-size: 11px; leading: 0; color: " + tnColor + "; } ";
			css += "p { font-family: " + _htmlFont + "; font-weight: normal; font-size: " + fontSize + "px; color: " + txtColor + "; leading: 2px; } ";
            css += "a { font-weight: bold; color: " + lColor + "; text-decoration: underline; } ";
            css += "a:hover { font-weight: bold; color: " + hColor + "; textDecoration: underline; } ";
            css += ".litelink { font-weight: bold; color: " + lColor + "; text-decoration: none; } ";
            css += ".litelink:hover { font-weight: bold; color: " + hColor + "; textDecoration: none; } ";
			css += ".center { text-align: center; }";
			
            css += ".note { font-family: Monaco, " + _htmlFont + "; font-weight: normal; font-size: " + Math.max(12, _fontSize - 2) + "px; color: " + nColor + "; leading: 0px; } ";
            css += ".numeric { font-family: Monaco, Lucida Sans Unicode," + _htmlFont + "; font-weight: normal; font-size: " + Math.max(12, _fontSize - 2) + "px; color: " + txtColor + "; leading: 2px; } ";
           
            if (!_styleSheet.parseCSS(css)) debug("CSS error!");
            
        }
        
        //
        //
        public function clone (overrides:Object = null):Style {
            
            var optCopy:Object = { };
            var param:String;
			
            for (param in _options) optCopy[param] = _options[param];
            for (var i:int = 0; i < cloneParams.length; i++ ) {
				param = cloneParams[i];
                if (param.indexOf("_") == 0) {
					if (this[param] is Array) optCopy[param] = this[param].concat();
					else optCopy[param.split("_").join("")] = this[param];
                }
            }
			
			if (overrides != null) {
				for (param in overrides) optCopy[param] = overrides[param];
				for (param in overrides) optCopy["_" + param] = overrides[param];
			}
			
            return new Style(optCopy);
            
        }
        
        //
        //
        private function debug (msg:String):void {

            
            //trace(msg);
            
        }
        
    }
}
