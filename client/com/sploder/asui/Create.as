package com.sploder.asui {
	
	import com.sploder.asui.*;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import flash.display.Graphics;
    import flash.display.Sprite;
	import flash.text.TextField;
    
    public class Create {

        public static const ICON_ARROW_LEFT:Array = [ -0.2, -0.5, 0.4, 0, -0.2, 0.5];
        public static const ICON_ARROW_RIGHT:Array = [ 0.2, -0.5, -0.4, 0, 0.2, 0.5];
		public static const ICON_DOUBLE_ARROW_LEFT:Array = [-0.5, 0.48, -0.02, 0, -0.5, -0.49, -0.5, 0.48, 0.01, 0.48, 0.5, 0, 0.01, -0.49, 0.01, 0.48];
		public static const ICON_DOUBLE_ARROW_RIGHT:Array = [0.01, 0, 0.5, 0.48, 0.5, -0.49, 0.01, 0, -0.5, 0, -0.02, 0.48, -0.02, -0.49, -0.5, 0];
      	public static const ICON_ARROW_UP:Array = [ -0.5, 0.3, 0, -0.3, 0.5, 0.3];
        public static const ICON_ARROW_DOWN:Array = [ -0.5, -0.3, 0, 0.3, 0.5, -0.3];
		public static const ICON_BACK_ARROW:Array = [-0.42, -0.09, -0.42, -0.09, -0.09, -0.42, 0.04, -0.3, -0.16, -0.09, 0.49, -0.09, 0.49, 0.09, -0.16, 0.09, 0.04, 0.29, -0.09, 0.41, -0.51, -0.01, -0.42, -0.09];
        public static const ICON_NEXT_ARROW:Array = [0.15, -0.09, -0.5, -0.09, -0.5, 0.09, 0.15, 0.09, -0.05, 0.29, 0.08, 0.41, 0.5, -0.01, 0.41, -0.09, 0.41, -0.09, 0.08, -0.42, -0.05, -0.3, 0.15, -0.09];
		public static const ICON_IN_ARROW:Array = [0.26, -0.28, 0.49, -0.28, 0.49, 0.5, 0.33, 0.5, 0.33, 0.5, -0.27, 0.5, -0.27, 0.26, 0.1, 0.26, -0.5, -0.34, -0.34, -0.5, 0.26, 0.09, 0.26, -0.28];
		public static const ICON_OUT_ARROW:Array = [0.49, -0.5, 0.33, -0.5, 0.33, -0.5, -0.27, -0.5, -0.27, -0.27, 0.1, -0.27, -0.5, 0.33, -0.34, 0.5, 0.26, -0.1, 0.26, 0.27, 0.49, 0.26, 0.49, -0.5];
		public static const ICON_CHECK:Array = [0.5, -0.2, -0.1, 0.4, -0.5, 0, -0.3, -0.2, -0.1, 0, 0.3, -0.4, 0.5, -0.2];
        public static const ICON_PLUS:Array = [0.12, -0.5, 0.12, -0.12, 0.5, -0.12, 0.5, 0.12, 0.12, 0.12, 0.12, 0.5, -0.12, 0.5, -0.12, -0.12, -0.5, -0.12, -0.5, 0.12, -0.12, 0.12, -0.12, -0.5];
        public static const ICON_MINUS:Array = [ -0.5, -0.12, 0.5, -0.12, 0.5, 0.12, -0.5, 0.12];
		public static const ICON_EDIT:Array = [0.25, -0.5, 0.5, -0.25, -0.25, 0.5, -0.5, 0.5, -0.5, 0.25, 0.25, -0.5];
		public static const ICON_COPY:Array =  [-0.28, -0.5, -0.28, -0.28, -0.5, -0.28, -0.5, 0.5, 0.27, 0.5, 0.27, 0.27, 0.5, 0.27, 0.5, -0.5, -0.28, -0.5, -0.28, -0.17, -0.28, 0.27, 0.16, 0.27, 0.16, 0.38, -0.39, 0.38, -0.39, -0.17, -0.28, -0.17];
		
		public static const ICON_PLAY:Array = [ -0.3, -0.5, 0.5, 0, -0.3, 0.5];
		public static const ICON_PAUSE:Array = [-0.1, -0.5, -0.1, 0.5, -0.5, 0.5, -0.5, -0.5, -0.1, -0.5, 0.5, -0.5, 0.5, 0.5, 0.1, 0.5, 0.1, -0.5, 0.5, -0.5];
		public static const ICON_CLOSE:Array = [0.5, -0.5, 0.5, -0.31, 0.18, 0, 0.345, 0.165, 0.35, 0.165, 0.5, 0.315, 0.5, 0.5, 0.31, 0.5, 0, 0.18, -0.095, 0.28, -0.095, 0.28, -0.315, 0.5, -0.5, 0.5, -0.5, 0.315, -0.18, 0, -0.28, -0.095, -0.28, -0.095, -0.5, -0.31, -0.5, -0.5, -0.315, -0.5, -0.145, -0.325, -0.145, -0.325, 0, -0.18, 0.31, -0.5, 0.5, -0.5];
		public static const ICON_NEXTTRACK:Array = [0.5, 0.45, 0.5, -0.46, 0.4, -0.46, 0.4, -0.04, -0.05, -0.46, -0.05, -0.04, -0.5, -0.46, -0.5, 0.45, -0.05, 0.04, -0.05, 0.45, 0.4, 0.04, 0.4, 0.45, 0.5, 0.45];
        public static const ICON_PREVTRACK:Array = [0.5, -0.46, 0.5, 0.45, 0.04, 0.04, 0.04, 0.45, -0.41, 0.04, -0.41, 0.45, -0.5, 0.45, -0.5, -0.46, -0.41, -0.46, -0.41, -0.04, 0.04, -0.46, 0.04, -0.04, 0.5, -0.46];
		public static const ICON_FASTFORWARD:Array = [ -0.5, 0.47, -0.03, 0.04, -0.03, 0.47, 0.5, 0, -0.03, -0.48, -0.03, -0.05, -0.5, -0.48, -0.5, 0.47];
		public static const ICON_REWIND:Array = [0.5, -0.48, 0.5, 0.47, 0.02, 0.04, 0.02, 0.47, -0.5, 0, 0.02, -0.48, 0.02, -0.05, 0.5, -0.48];
		public static const ICON_LAUNCH:Array = [ 0, -0.25, -0.25, -0.5, 0.5, -0.5, 0.5, 0.25, 0.25, 0, -0.25, 0.5, -0.5, 0.25,];
		//
        //
        public static function button (mc:Sprite, _label:Object, textAlign:Number = -1, width:Number = NaN, height:Number = NaN, tabMode:Boolean = false, groupMode:Boolean = false, toggleMode:Boolean = false, toggledLabel:Object = null, style:Style = null, forceWidth:Boolean = false, extraWidth:int = 0, droop:Boolean = false):Sprite {
            
            if (style == null) style = new Style();
			
			var textLabel:String;
			var icon:Object;
			var first:Boolean;
			
			var textLabelToggled:String;
			var iconToggled:Object;
			
			if (typeof(_label) == "string") textLabel = _label as String;
			else {
				textLabel = (_label.text != null) ? _label.text : "";
				icon = (_label.icon != null) ? _label.icon : null;
				first = (_label.first != null) ? _label.first != "false" : true;
			}
			
			textLabelToggled = textLabel;
			iconToggled = icon;
			
			if (typeof(toggledLabel) == "string") textLabelToggled = toggledLabel as String;
			else if (toggledLabel != null) {
				textLabelToggled = (toggledLabel.text != null) ? toggledLabel.text : textLabel;
				iconToggled = (toggledLabel.icon != null) ? toggledLabel.icon : icon;
			}

            var cornerRoundness:String = String(style.round);
			
			if (textAlign == -1) textAlign = Position.ALIGN_CENTER;
            if (tabMode) cornerRoundness = cornerRoundness + " " + cornerRoundness + " 0 0";
    
            var button:Sprite = new Sprite();
			button.name = "btn";
            var button_tf:TextField;
            var button_btn:Sprite = new Sprite();
			button_btn.name = "button_btn";
			button_btn.buttonMode = true;
            var button_inactive:Sprite = new Sprite();
			button_inactive.name = "button_inactive";
            var button_tf_inactive:TextField;
            var button_selected:Sprite = new Sprite();
			button_selected.name = "button_selected";
            var button_tf_selected:TextField;
    
            var g:Sprite = mc;
    
            var temp:Array = cornerRoundness.split(" ");
            for (var i:int = 0; i < temp.length; i++) temp[i] = (parseInt(temp[i]) > 0) ? parseInt(temp[i]) - style.borderWidth : 0;
            var innerRoundness:String = temp.join(" ");
    
			mc.addChild(button);
        
            button_tf = newText(textLabel, "_buttontext", button, style, (groupMode) ? style.unselectedTextColor : style.buttonTextColor, style.buttonFontSize, false, true);
        
			var twidth:Number = button_tf.width;
			
			button_tf.text = textLabel;
			twidth = Math.max(twidth, button_tf.width);
			
            if (isNaN(width)) width = twidth + style.padding * 3 + Math.max(8, style.borderWidth * 2);
            else if (!forceWidth) width = Math.max(width, twidth + style.padding * 3 + Math.max(8, style.borderWidth * 2) - 2);
            
			width += extraWidth;
			
			width = Math.floor(width);
			
            if (isNaN(height)) height = button_tf.height + style.padding + style.borderWidth * 2;
            else height = Math.max(height, button_tf.height + style.padding + style.borderWidth * 2 - 2);
    
            if (textAlign == Position.ALIGN_LEFT) button_tf.x = style.padding;
            else if (textAlign == Position.ALIGN_RIGHT) button_tf.x = width - button_tf.width - style.padding;   
            else button_tf.x = Math.floor((width - button_tf.width) * 0.5);
            
            button_tf.y = Math.floor((height - button_tf.height) * 0.5);
            
            g = button;
            
            var vpad:Number = 0;
            if (tabMode) vpad = style.borderWidth;
    
            if (style.border) DrawingMethods.roundedRect(g, false, 0, 0, width, height - vpad, cornerRoundness, [(style.unselectedBorderColor > -1) ? style.unselectedBorderColor : style.buttonBorderColor], [style.backgroundAlpha], [1]);
            if (style.background) DrawingMethods.roundedRect(g, false, style.borderWidth, style.borderWidth, width - style.borderWidth * 2, height - style.borderWidth * 2, innerRoundness, [(groupMode) ? style.unselectedColor : style.buttonColor], [style.backgroundAlpha], [1]);
            if (style.gradient) DrawingMethods.roundedRect(g, false, style.borderWidth, style.borderWidth, width - style.borderWidth * 2, height - style.borderWidth * 2, innerRoundness, [0xffffff, 0xffffff, 0x000000, 0x000000], [0.40, 0.15, 0, 0.10], [0, 128, 128, 255]);
    
			button.addChild(button_btn);

			var htf:TextField;
			
            g = button_btn;
            if (style.background || style.border || style.gradient || !style.embedFonts) {
				DrawingMethods.roundedRect(g, false, style.borderWidth, style.borderWidth, width - style.borderWidth * 2, height - style.borderWidth * 2, innerRoundness, [0xffffff], [20], [1]);
			} else {
				DrawingMethods.roundedRect(g, false, 0, 0, width, height, innerRoundness, [0xffffff], [0], [1]);
				htf = newText(textLabel, "_buttontext", button_btn, style,  0xffffff, style.buttonFontSize, false, true);
				htf.mouseEnabled = false;
				htf.x = button_tf.x;
				htf.y = button_tf.y;
				htf.alpha = 1.5;
			}
            button_btn.alpha = 0;
              
			button.addChild(button_selected);

            g = button_selected;
			
			var dp:int = (droop) ? style.borderWidth : 0;
			
			if (!toggleMode) {
				
				if (style.border) DrawingMethods.roundedRect(g, false, 0, 0, width, dp + height - vpad, cornerRoundness, [style.selectedButtonBorderColor], [style.backgroundAlpha], [1]);
				if (style.background) DrawingMethods.roundedRect(g, false, style.borderWidth, style.borderWidth, width - style.borderWidth * 2, dp + height - style.borderWidth * 2, innerRoundness, [style.buttonColor], [style.backgroundAlpha], [1]);
				if (style.gradient) DrawingMethods.roundedRect(g, false, style.borderWidth, style.borderWidth, width - style.borderWidth * 2, dp + height - style.borderWidth * 2, innerRoundness, [0xffffff, 0xffffff, 0x000000, 0x000000], [0.4, 0.15, 0, 0.10], [0, 128, 128, 255]);
				button_tf_selected = newText(textLabel, "_buttontext", button_selected, style, (groupMode) ? style.buttonTextColor : style.inverseTextColor, style.buttonFontSize, false, true);
				button_tf_selected.x = button_tf.x;
				button_tf_selected.y = button_tf.y;
				button_selected.visible = false;   
				
			} else {
				
				if (style.border) DrawingMethods.roundedRect(g, false, 0, 0, width, dp + height - vpad, cornerRoundness, [style.buttonBorderColor], [style.backgroundAlpha], [1]);
				if (style.background) DrawingMethods.roundedRect(g, false, style.borderWidth, style.borderWidth, width - style.borderWidth * 2, dp + height - style.borderWidth * 2, innerRoundness, [ColorTools.getTintedColor(style.buttonColor, 0x000000, 0.2)], [style.backgroundAlpha], [1]);
				if (style.gradient) DrawingMethods.roundedRect(g, false, style.borderWidth, style.borderWidth, width - style.borderWidth * 2, dp + height - style.borderWidth * 2, innerRoundness, [0x000000, 0x000000, 0xffffff, 0xffffff], [0.2, 0, 0.1, 0.2], [0, 128, 128, 255]);
				button_tf_selected = newText((textLabelToggled.length > 0) ? textLabelToggled : textLabel, "_buttontext", button_selected, style, style.inverseTextColor, style.buttonFontSize, false, true);
				if (textAlign == Position.ALIGN_LEFT) button_tf_selected.x = style.padding;
				else if (textAlign == Position.ALIGN_RIGHT) button_tf_selected.x = width - button_tf_selected.width - style.padding;   
				else button_tf_selected.x = Math.floor((width - button_tf_selected.width) * 0.5);
				button_tf_selected.y = button_tf.y;
				button_selected.visible = false;  				
				
			}
    
   
            button.addChild(button_inactive);
			
            g = button_inactive;
            if (style.border) DrawingMethods.roundedRect(g, false, 0, 0, width, height - vpad, cornerRoundness, [ColorTools.getTintedColor(style.inactiveColor, 0, 0.25)], [style.backgroundAlpha], [1]);
            if (style.background) DrawingMethods.roundedRect(g, false, style.borderWidth, style.borderWidth, width - style.borderWidth * 2, height - style.borderWidth * 2, innerRoundness, [style.inactiveColor], [style.backgroundAlpha], [1]);
			if (style.gradient) DrawingMethods.roundedRect(g, false, style.borderWidth, style.borderWidth, width - style.borderWidth * 2, height - style.borderWidth * 2, innerRoundness, [0xffffff, 0xffffff, 0x000000, 0x000000], [0.40, 0.15, 0, 0.10], [0, 128, 128, 255]);
			button_tf_inactive = newText(textLabel, "_buttontext", button_inactive, style, style.inactiveTextColor, style.buttonFontSize, false, true);
			button_tf_inactive.x = button_tf.x;
            button_tf_inactive.y = button_tf.y;
            button_inactive.visible = false;
			
			if (toggleMode) button.setChildIndex(button_btn, 3);
			
			if (style.buttonDropShadow) mc.filters = [new DropShadowFilter(4, 45, 0, 0.2, 4, 4, 1, 2)];
			
			if (icon != null && icon is Array) {
				
				var ics1:Sprite = new Sprite();
				ics1.mouseEnabled = false;
				ics1.name = "icon";
				newIcon(iconToggled as Array, ics1, style.buttonTextColor, 1, style);
				var icon_aspect:Number = ics1.width / ics1.height;
				
				if (icon_aspect <= 1) {
					ics1.height = button_tf.height * 0.5;
					ics1.width = ics1.height * icon_aspect;
				} else {
					ics1.width = button_tf.height * 0.5;
					ics1.height = ics1.width / icon_aspect;					
				}
				
				if (first) {
					if (textAlign == Position.ALIGN_CENTER) {
						ics1.x = button_tf.x - button_tf.height / 4;
						button_tf.x += button_tf.height / 4;
					} else {
						ics1.x = button_tf.x + ics1.width / 2;
						button_tf.x += ics1.x + ics1.width / 2 + style.padding / 2;
					}
				} else {
					if (textAlign == Position.ALIGN_CENTER) {
						ics1.x = button_tf.x + button_tf.width + button_tf.height / 4;
						button_tf.x -= button_tf.height / 4;
					} else {
						ics1.x = button.width - Math.max(10, style.padding + style.round);
					}
				}
				button_tf_inactive.x = button_tf_selected.x = button_tf.x;

				ics1.y = button_tf.y + button_tf.height / 2;
				if (groupMode) button_selected.addChild(ics1);
				else button.addChild(ics1);
				
				var ics2:Sprite = new Sprite();
				ics2.mouseEnabled = false;
				ics2.name = "icon_inactive";
				newIcon(icon as Array, ics2, groupMode ? style.unselectedTextColor : style.inactiveTextColor, 1, style);
				icon_aspect = ics2.width / ics2.height;
				ics2.height = button_tf_inactive.height * 0.65;
				
				if (icon_aspect <= 1) {
					ics2.height = button_tf.height * 0.5;
					ics2.width = ics2.height * icon_aspect;
				} else {
					ics2.width = button_tf.height * 0.5;
					ics2.height = ics2.width / icon_aspect;					
				}
				
				ics2.x = ics1.x
				ics2.y = ics1.y;
				if (!groupMode) ics2.visible = false;
				mc.addChild(ics2);
				
				if (htf != null) {
					
					var ics3:Sprite = new Sprite();
					ics3.mouseEnabled = false;
					ics3.name = "icon_button";
					newIcon(icon as Array, ics3, 0xffffff, 1, style);
					
					ics3.x = ics2.x;
					ics3.y = ics2.y;
					ics3.width = ics2.width;
					ics3.height = ics2.height;
					
					htf.x = button_tf.x;
					htf.y = button_tf.y;

					ics3.alpha = 1.5;

					button_btn.addChild(ics3);
				
				}
				
				button.setChildIndex(button_btn, button.numChildren - 1);
				
			}
            
            return button;
    
        }
        
        //
        //
        public static function hitArea (mc:Sprite, icon:Array, width:Number, height:Number, toggleMode:Boolean = false, toggledIcon:Array = null, style:Style = null, forceSquare:Boolean = true, tabSide:int = -1):Sprite {
            
            if (style == null) style = new Style();
			
			var rounding:String = style.round.toString();
			var innerRounding:String = Math.max(0, style.round - style.borderWidth).toString();
			if (forceSquare) rounding = innerRounding = "0";
			else if (tabSide >= 0) {
				switch (tabSide) {
					case Position.POSITION_ABOVE:
						rounding = "0 0 " + rounding + " " + rounding;
						innerRounding = "0 0 " + innerRounding + " " + innerRounding;
						break;
					case Position.POSITION_RIGHT:
						rounding = rounding + " 0 0 " + rounding;
						innerRounding = innerRounding + " 0 0 " + innerRounding;
						break;
					case Position.POSITION_BELOW:
						rounding = rounding + " " + rounding + " 0 0";
						innerRounding = innerRounding + " " + innerRounding + " 0 0";
						break;
					case Position.POSITION_LEFT:
						rounding = "0 " + rounding + " " + rounding + " 0";
						innerRounding = "0 " + innerRounding + " " + innerRounding + " 0";
						break;
				}
			}
           
            var button:Sprite = new Sprite();
			button.name = "btn";
            var button_btn:Sprite = new Sprite();
			button_btn.name = "button_btn";
			button_btn.buttonMode = true;
            var button_inactive:Sprite = new Sprite();
			button_inactive.name = "button_inactive";
            var button_selected:Sprite = new Sprite();
			button_selected.name = "button_selected";
		
            var g:Sprite = mc;
    
            mc.addChild(button);
			
			g = button;
			
			var icn:Sprite;
        
            if (style.border) DrawingMethods.roundedRect(g, false, 0, 0, width, height, rounding, [(style.unselectedBorderColor != -1) ? style.unselectedBorderColor : style.buttonBorderColor], [style.backgroundAlpha], [1]);
            if (style.background) DrawingMethods.roundedRect(g, false, style.borderWidth, style.borderWidth, width - style.borderWidth * 2, height - style.borderWidth * 2, innerRounding, [style.unselectedColor], [style.backgroundAlpha], [1]);
            else DrawingMethods.rect(g, false, 0, 0, width, height, 0x000000, 0);
			if (style.gradient) DrawingMethods.roundedRect(g, false, style.borderWidth, style.borderWidth, width - style.borderWidth * 2, height - style.borderWidth * 2, innerRounding, [0xffffff, 0xffffff, 0x000000, 0x000000], [0.4, 0.15, 0, 0.10], [0, 128, 128, 255]);
			if (icon != null) {
				icn = newIcon(icon, button, style.buttonTextColor, 1, style);
				icn.name = "icon";
			}
            
			button.addChild(button_btn);
            
            g = button_btn;

			if (style.background || style.border || style.gradient || icon == null) {
				DrawingMethods.roundedRect(g, false, style.borderWidth, style.borderWidth, width - style.borderWidth * 2, height - style.borderWidth * 2, innerRounding, [0xffffff], [20], [1]);
			} else {
				DrawingMethods.roundedRect(g, false, 0, 0, width, height, rounding, [0xffffff], [0], [1]);
				icn = newIcon(icon, g, 0xffffff, 1, style);
				icn.mouseEnabled = false;
				icn.alpha = 1.5;
			}
			
        	button_btn.alpha = 0;
			
            button.addChild(button_selected);
			
            g = button_selected;
			
			if (!toggleMode) {
				
				if (style.border) DrawingMethods.roundedRect(g, false, 0, 0, width, height, rounding, [style.buttonBorderColor], [style.backgroundAlpha], [1]);
				if (style.background || style.selectedButtonColor > -1) DrawingMethods.roundedRect(g, false, style.borderWidth, style.borderWidth, width - style.borderWidth * 2, height - style.borderWidth * 2, innerRounding, [(style.selectedButtonColor == -1) ? style.buttonColor : style.selectedButtonColor], [style.backgroundAlpha], [1]);
				else DrawingMethods.rect(g, false, 0, 0, width, height, 0x000000, 0);
				if (style.gradient) DrawingMethods.roundedRect(g, false, style.borderWidth, style.borderWidth, width - style.borderWidth * 2, height - style.borderWidth * 2, innerRounding, [0xffffff, 0xffffff, 0x000000, 0x000000], [0.4, 0.15, 0, 0.10], [0, 128, 128, 255]);
				if (icon != null) {
					icn = newIcon((toggledIcon != null) ? toggledIcon : icon, g, style.buttonTextColor, 1, style);
					icn.name = "icon_selected";
				}
				
			} else {
				
				if (style.border) DrawingMethods.roundedRect(g, false, 0, 0, width, height, rounding, [style.buttonBorderColor], [style.backgroundAlpha], [1]);
				if (style.background) DrawingMethods.roundedRect(g, false, style.borderWidth, style.borderWidth, width - style.borderWidth * 2, height - style.borderWidth * 2, innerRounding, [style.buttonColor], [style.backgroundAlpha], [1]);
				else DrawingMethods.rect(g, false, 0, 0, width, height, 0x000000, 0);
				if (style.gradient) DrawingMethods.roundedRect(g, false, style.borderWidth, style.borderWidth, width - style.borderWidth * 2, height - style.borderWidth * 2, innerRounding, [0x000000, 0x000000, 0xffffff, 0xffffff], [0.2, 0, 0.1, 0.2], [0, 128, 128, 255]);
				if (icon != null) {
					icn = newIcon((toggledIcon != null) ? toggledIcon : icon, g, style.buttonTextColor, 1, style);
					icn.name = "icon_selected";
				}
							
			}
            
            button_selected.visible = false;           
    
            button.addChild(button_inactive);

            g = button_inactive;
			DrawingMethods.rect(g, false, 0, 0, width, height, 0x000000, 0);
            if (style.border) DrawingMethods.roundedRect(g, false, style.borderWidth, style.borderWidth, width - style.borderWidth * 2, height - style.borderWidth * 2, innerRounding, [style.inactiveColor], [style.backgroundAlpha], [1]);
            //if (style.gradient) DrawingMethods.roundedRect(g, false, style.borderWidth, style.borderWidth, width - style.borderWidth * 2, height - style.borderWidth * 2, innerRounding, [0xffffff, 0xffffff, 0x000000, 0x000000], [0.2, 0.15, 0, 0.10], [0, 128, 128, 255]);
			if (icon != null) {
				icn = newIcon(icon, g, style.inactiveTextColor, 1, style);
				icn.name = "icon_inactive";
			}
            
            button_inactive.visible = false;

			if (toggleMode) button.setChildIndex(button_btn, 2);
			
			if (style.buttonDropShadow) mc.filters = [new DropShadowFilter(4, 45, 0, 0.2, 4, 4, 1, 2)];
			
			button.setChildIndex(button_btn, button.numChildren - 1);
			
            return button;
    
        }
		
		public static function dragArea (mc:Sprite, width:Number, height:Number, style:Style):void {
			
			var g:Graphics = mc.graphics;
			g.clear();
			
			g.beginFill(0, 0);
			g.drawRect(0, 0, width, height);
			
			var bumpColor:Number = ColorTools.getTintedColor(style.backgroundColor, 0xffffff, 0.2);
			var shadColor:Number = ColorTools.getTintedColor(style.backgroundColor, 0x000000, 0.4);
			
			for (var j:int = 0; j < height; j += 4) {
				
				for (var i:int = 0; i < width; i += 4) {
					
					g.beginFill(bumpColor, 1);
					g.drawRect(i, j, 3, 3);
					g.beginFill(shadColor, 1);
					g.drawRect(i + 2, j, 1, 3);
					g.drawRect(i, j + 2, 2, 1);
					
				}
				
			}
			
			
		}
        
        //
        //
        public static function newText (text:String, id:String, container:Sprite, style:Style, color:Number = NaN, size:Number = NaN, html:Boolean = false, button:Boolean = false):TextField {
            
            if (isNaN(color)) color = style.textColor;
            if (isNaN(size)) size = (button) ? style.buttonFontSize : style.fontSize;
    
            var tf:TextField = new TextField();
			tf.width = 200;
			tf.height = 10;
			tf.name = id;
			container.addChild(tf);
			
            tf.autoSize = TextFieldAutoSize.LEFT;
            tf.embedFonts = style.embedFonts;
            
            if (html) {
                tf.htmlText = text;
            } else {
                tf.text = text;
            }

            tf.selectable = false;
            tf.setTextFormat(new TextFormat((button) ? style.buttonFont : style.font, size, color, true));
			tf.defaultTextFormat = new TextFormat((button) ? style.buttonFont : style.font, size, color, true);
			if (style.embedFonts) tf.antiAliasType = AntiAliasType.ADVANCED;
            tf.textColor = color;
			
            return tf;
        
        }
        
        //
        //
        public static function inputText (text:String, id:String, container:Sprite, width:Number, height:Number, style:Style):TextField {
            
            var tf:TextField = newText(text, id, container, style);
            
            tf.selectable = true;
            tf.multiline = false;
            tf.wordWrap = false;
            
            tf.type = "input";
            tf.autoSize = TextFieldAutoSize.LEFT;
            
			if (style.embedFonts) {
				tf.setTextFormat(new TextFormat(style.font, style.fontSize, style.textColor, false, false, false, "", "", "left"));
				tf.defaultTextFormat = new TextFormat(style.font, style.fontSize, style.textColor, false, false, false, "", "", "left");
				tf.embedFonts = true;
			} else {
				tf.setTextFormat(new TextFormat("_sans", style.fontSize, style.textColor, false, false, false, "", "", "left"));
				tf.defaultTextFormat = new TextFormat("_sans", style.fontSize, style.textColor, false, false, false, "", "", "left");
			}
			
			tf.text = "TEMPj'|";
			
			var tfHeight:int = Math.ceil(tf.height);

            tf.autoSize = TextFieldAutoSize.NONE;
			
			tf.text = "";
			
            if (!isNaN(width) && width > 0) {
                tf.width = width;
            }
            
            if (!isNaN(height) && height > 0) {
                tf.height = height;
            } else {
                tf.height = tfHeight + 2 + style.borderWidth * 2;
            }
            
            return tf;
            
        }
        
        //
        //
        public static function newIcon (points:Array, mc:Sprite, color:Number, alpha:Number = 1, parentStyle:Style = null, scale:Number = 1):Sprite {
            
            var icon:Sprite = new Sprite();
			icon.name = "icon";
			mc.addChild(icon);
            icon.mouseEnabled = false;
            
            icon.x = mc.width * 0.5;
            icon.y = mc.height * 0.5;
            
            var g:Graphics = icon.graphics;
            
			if (parentStyle == null) parentStyle = new Style();
			
			var dimX:Number = (mc.width - parentStyle.borderWidth * 2) * scale;
			var dimY:Number = (mc.height - parentStyle.borderWidth * 2) * scale;

			if (dimX <= 1) dimX = 10;
			if (dimY <= 1) dimY = 10;
			
			dimX = dimY = Math.max(22, Math.min(dimX, dimY));
			

            if (points.length > 2) {
                
                g.beginFill(color, alpha);
                g.moveTo(points[0] * dimX * 0.5, points[1] * dimY * 0.5);
                
                for (var i:int = 2; i < points.length; i+=2) {
                    g.lineTo(points[i] * dimX * 0.5, points[i + 1] * dimY * 0.5);
                }
                
                g.endFill();
                
            }
			
			return icon;
            
        }
		
		//
		//
		public static function background (mc:Sprite, width:Number, height:Number, style:Style = null, border:Boolean = false, round:Number = -1):void {
			
			if (style == null) style = Component.globalStyle;
			
			var b:Number = (border) ? style.borderWidth : 0;
			var r:Number = (round == -1) ? style.round : round;
			
            if (border) DrawingMethods.roundedRect(mc, false, 0, 0, width, height, r.toString(), [style.borderColor], [style.borderAlpha], [1]);
            if (style.background && !style.bgGradient) DrawingMethods.roundedRect(mc, false, b, b, width - b * 2, height - b * 2, Math.max(0, r - b).toString(), [style.backgroundColor], [style.backgroundAlpha], [1]);
            else if (style.background && style.bgGradient) {
				var m:Matrix = null;
				if (style.bgGradientHeight > 0) {
					m = new Matrix();
					m.createGradientBox(width - b * 2, style.bgGradientHeight, 90 * (Math.PI / 180), b, b);
				}
				DrawingMethods.roundedRect(mc, false, b, b, width - b * 2, height - b * 2, Math.max(0, r - b).toString(), style.bgGradientColors, [style.backgroundAlpha], style.bgGradientRatios, m);
			}
			
		}
 
    }
	
}
