package com.sploder.builder
{
	import com.sploder.asui.Library;
	import com.sploder.asui.Position;
	import com.sploder.asui.Style;
	import flash.text.Font;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class Styles 
	{
		
		protected static var _initialized:Boolean = false;
		
		public static var containerStyle:Style;
		public static var backgroundStyle:Style;
		public static var mainStyle:Style;
		public static var menuStyle:Style;
		public static var playfieldStyle:Style;
		public static var trayStyle:Style;
		public static var trayItemStyle:Style;
		public static var chromelessStyle:Style;
		public static var dialogueStyle:Style;
		public static var promptStyle:Style;
		
		public static var previewStyle:Style;
		
		public static var dialoguePosition:Position;
		public static var panelPosition:Position;
		public static var promptPosition:Position;
		public static var floatPosition:Position;
		public static var absPosition:Position;
		
		//
		//
		public static function initializeFonts (library:Library):void {
			
			var font:Class;
			font = library.getFont("myriad");
			Font.registerFont(font);
			font = library.getFont("myriad_bold");
			Font.registerFont(font);
			
		}
		
		//
		//
		public static function initialize ():void {
			
			if (!_initialized) {

				dialoguePosition = new Position(null, 
					-1,
					-1,
					-1, 
					null, 0, 0, 1000);
					
				panelPosition = new Position(null, 
					Position.ALIGN_CENTER, 
					Position.PLACEMENT_ABSOLUTE, 
					Position.CLEAR_BOTH, 
					null, 70, 30);
				
				promptPosition = new Position(null,
					Position.ALIGN_CENTER,
					Position.PLACEMENT_ABSOLUTE,
					Position.CLEAR_BOTH,
					null, 70, 110, -1);
					
				floatPosition = new Position(null, 
					Position.ALIGN_LEFT, 
					Position.PLACEMENT_FLOAT);
					
				absPosition = new Position(null,
					Position.ALIGN_LEFT,
					Position.PLACEMENT_ABSOLUTE);
				
				_initialized = true;
				
				containerStyle = new Style();
				containerStyle.backgroundColor = 0x7e2954;
				containerStyle.borderWidth = 0;
				
				backgroundStyle = new Style();
				backgroundStyle.backgroundColor = 0x993366;
				backgroundStyle.borderWidth = 0;
				backgroundStyle.selectedButtonBorderColor = 0x993366;
				
				mainStyle = new Style();
				mainStyle.buttonColor = 0x0099ff;
				mainStyle.backgroundColor = 0x993366;
				mainStyle.borderColor = 0xff66cc;
				mainStyle.textColor = 0x000000;
				mainStyle.titleColor = 0xffffff;
				mainStyle.linkColor = 0xffec00
				mainStyle.font = mainStyle.titleFont = "Myriad Web";
				mainStyle.fontSize = 16;
				mainStyle.titleFontSize = 24;
				mainStyle.round = 0;
				mainStyle.buttonFont = "Myriad Web Bold";
				mainStyle.buttonFontSize = 16;
				mainStyle.padding = 10;
				mainStyle.buttonDropShadow = true;
				mainStyle.embedFonts = true;
				
				menuStyle = new Style();
				menuStyle.font = menuStyle.buttonFont = menuStyle.titleFont = "Myriad Web Bold";
				menuStyle.embedFonts = true;
				menuStyle.bgGradient = true;
				menuStyle.buttonColor = 0x990099;
				menuStyle.buttonTextColor = 0xffffff;
				menuStyle.inactiveColor = 0x990099;
				menuStyle.inactiveTextColor = 0xee00ee;
				menuStyle.bgGradientColors = [0xcc00cc, 0x660066];
				menuStyle.borderWidth = 0;
				menuStyle.buttonFontSize = 18;
				menuStyle.round = 0;
				
				playfieldStyle = new Style();
				playfieldStyle.bgGradient = true;
				playfieldStyle.bgGradientColors = [0x4B5576, 0x353C53, 0x566187];
				playfieldStyle.bgGradientHeight = 480;
				playfieldStyle.bgGradientRatios = [0, 180, 240];
				
				trayStyle = new Style();
				trayStyle.font = trayStyle.buttonFont = trayStyle.titleFont = "Myriad Web Bold";
				trayStyle.embedFonts = true;
				trayStyle.backgroundColor = 0x565F87;
				trayStyle.buttonColor = 0x003399;
				trayStyle.unselectedColor = 0;
				trayStyle.buttonTextColor = 0xffffff;
				trayStyle.unselectedTextColor = 0x999999;
				trayStyle.selectedButtonColor = 0x003399;
				trayStyle.inactiveColor = 0;
				trayStyle.border = false;
				trayStyle.buttonFontSize = 12;
				trayStyle.round = 0;
				trayStyle.padding = 8;
				
				trayItemStyle = new Style();
				trayItemStyle.fontSize = 11;
				trayItemStyle.backgroundAlpha = 0.1;
				trayItemStyle.backgroundColor = 0xffffff;
				trayItemStyle.borderWidth = 2;
				trayItemStyle.gradient = true;
				
				chromelessStyle = new Style();
				chromelessStyle.background = false;
				chromelessStyle.border = false;
				chromelessStyle.font = "Myriad Web Bold";
				chromelessStyle.buttonFontSize = 14;
				chromelessStyle.gradient = false;
				chromelessStyle.buttonTextColor = 0xffec00;
				chromelessStyle.embedFonts = true;
				chromelessStyle.padding = 0;
				chromelessStyle.inactiveTextColor = 0x660033;

				dialogueStyle = new Style();
				dialogueStyle.bgGradient = true;
				dialogueStyle.bgGradientColors = [0x333333, 0];
				dialogueStyle.borderColor = 0x666666;
				dialogueStyle.borderWidth = 2;
				dialogueStyle.maskColor = 0;
				dialogueStyle.maskAlpha = 0.25;
				dialogueStyle.round = 0;
				dialogueStyle.textColor = 0x999999;
				dialogueStyle.highlightTextColor = 0xffffff;
				dialogueStyle.titleColor = 0xcccccc;
				dialogueStyle.buttonColor = 0x990099;
				dialogueStyle.buttonTextColor = 0xffffff;
				dialogueStyle.inputColorA = 0x000000;
				dialogueStyle.inputColorB = 0x333333;
				dialogueStyle.font = "Myriad Web";
				dialogueStyle.titleFont = "Myriad Web Bold";
				dialogueStyle.buttonFont = "Myriad Web Bold";
				dialogueStyle.fontSize = 14;
				dialogueStyle.titleFontSize = 20;
				dialogueStyle.embedFonts = true;
				dialogueStyle.haloColor = 0xff9900;
				
				promptStyle = new Style();
				promptStyle.backgroundColor = 0;
				promptStyle.backgroundAlpha = 0.2;
				promptStyle.borderWidth = 2;
				promptStyle.linkColor = 0xff88ee;
				promptStyle.textColor = promptStyle.inverseTextColor = 
					promptStyle.inactiveTextColor = promptStyle.unselectedTextColor = 0xcccccc;
				promptStyle.fontSize = 10;
				promptStyle.font = "_sans";
				
				previewStyle = new Style();
				setPreviewDefaults();

			}
			
		}
		
		public static function setPreviewDefaults ():void {
			
			previewStyle.backgroundColor = 0x333333;
			previewStyle.borderColor = 0xffffff;
			previewStyle.highlightTextColor = 0xffffff;
			previewStyle.borderWidth = 6;
			previewStyle.textColor = -1;
			previewStyle.linkColor = -1;
			
		}
		
	}
	
}