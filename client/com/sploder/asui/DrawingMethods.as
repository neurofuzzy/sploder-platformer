package com.sploder.asui {
    
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
    
    public class DrawingMethods {

    
        /**
         * Method: roundedRect
         * Draws a rounded rectangle inside the movieclip
         * 
         * @param   mc the movieclip in which to draw
         * @param   clear erase any drawing in the mc
         * @param   x the x coordinate
         * @param   y the y coordinate
         * @param   boxWidth width of rectangle
         * @param   boxHeight height of rectangle
         * @param   cornerRadius corner radius of one corner or CSS-style space-separated string of 4 corners T R B L (optional)
         * @param   colors array of colors to use in the fill (optional)
         * @param   alphas array of alphas to use in the fill (optional)
         * @param   percentages array of percentages to use in the fill (optional)
         * @param   matrix a matrix object to use for the gradient (optional)
         * @param   lineThickness line thickness (optional)
         * @param   lineColor line color (optional)
         * @param   lineAlpha transparency of line (optional)
         */
        
         
        public static function roundedRect (mc:Sprite, clear:Boolean = true, x:Number = 0, y:Number = 0, boxWidth:Number = 100, boxHeight:Number = 100, cornerRadius:String = "0", colors:Array = null, alphas:Array = null, percentages:Array = null, matrix:Matrix = null, lineThickness:Number = 0, lineColor:Number = 0x000000, lineAlpha:Number = 1):void {
                
			var g:Graphics = mc.graphics;
			
            var cornerRadii:Array = new Array();
    
            var cornerT:Number = 0;
            var cornerR:Number = 0;
            var cornerB:Number = 0;
            var cornerL:Number = 0;
            
            if (clear != false) g.clear();
            
            // validate values
            
            var i:Number;
            
            if (colors.length < 1) colors = [0x000000];
			
            if (alphas == null) alphas = [];
			
            if (alphas.length != colors.length) {
                alphas = [];
                for (i = 0; i < colors.length; i++) {
                    alphas.push(1);
                }
            }
			
			if (percentages == null) percentages = [];
            
            if (percentages.length != colors.length) {
                percentages = [];
                for (i = 0; i < colors.length; i++) {
                    percentages.push((i / (colors.length - 1)) * 255);
                }           
            }
    
            if (cornerRadius == null || cornerRadius == "") cornerRadius = "0";
    
            cornerRadii = cornerRadius.split(" ");
            cornerT = parseInt(cornerRadii[0]);
            cornerR = (cornerRadii[1] == undefined) ? cornerT : parseInt(cornerRadii[1]);
            cornerB = (cornerRadii[2] == undefined) ? cornerT : parseInt(cornerRadii[2]);
            cornerL = (cornerRadii[3] == undefined) ? cornerR : parseInt(cornerRadii[3]);
    
            x = (!isNaN(x)) ? x : 0;
            y = (!isNaN(y)) ? y : 0;
            if (isNaN(boxWidth)) boxWidth = mc.width;
            if (isNaN(boxHeight)) boxHeight = mc.height;
            
            if (!isNaN(lineThickness) && lineThickness > 0) {
                if (isNaN(lineColor) || lineColor == 0) lineColor = 0x000000;
                if (isNaN(lineAlpha) || lineAlpha == 0) lineAlpha = 1;
                g.lineStyle(lineThickness, lineColor, lineAlpha);
            }
    
            if (colors.length == 1) {
                
                // solid fill
                //
                g.beginFill(colors[0], alphas[0]);
                
            } else {
                
                // gradient fill
                //
                if (matrix == null) {
					matrix = new Matrix();
					matrix.createGradientBox(boxWidth, boxHeight, 90 * (Math.PI / 180), x, y);
				}
				g.beginGradientFill("linear", colors, alphas, percentages, matrix);
                
            }
    
            //
            if (cornerT > 0) {
                g.moveTo(x + cornerT, y);
            } else {
                g.moveTo(x, y);
            }
            
            if (cornerR > 0) {
                g.lineTo(x + boxWidth-cornerR, y);
                g.curveTo(x + boxWidth, y, x + boxWidth, y + cornerR);
                g.lineTo(x + boxWidth, y + cornerR);
            } else {
                g.lineTo(x + boxWidth, y);
            }
            
            if (cornerB > 0) {
                g.lineTo(x + boxWidth, y + boxHeight-cornerB);
                g.curveTo(x + boxWidth, y + boxHeight, x + boxWidth - cornerB, y + boxHeight);
                g.lineTo(x + boxWidth - cornerB, y + boxHeight);
            } else {
                g.lineTo(x + boxWidth, y + boxHeight);
            }
            
            if (cornerL > 0) {
                g.lineTo(x + cornerL, y + boxHeight);
                g.curveTo(x, y + boxHeight, x, y + boxHeight - cornerL);
                g.lineTo(x, y + boxHeight-cornerL);
            } else {
                g.lineTo(x, y + boxHeight);
            }
            
            if (cornerT > 0) {
                g.lineTo(x, y + cornerT);
                g.curveTo(x, y, x + cornerT, y);
                g.lineTo(x + cornerT, y);
            } else {
                g.lineTo(x, y);
            }
            
            g.endFill();
            
        }
        
        /**
         * Method: emptyRect
         * Draws a rectangle with a hole in the middle
         * 
         * @param   mc the movieclip in which to draw
         * @param   clear erase any drawing in the mc
         * @param   x the x coordinate
         * @param   y the y coordinate
         * @param   boxWidth width of rectangle
         * @param   boxHeight height of rectangle
         * @param   thickness thickness of rectangle edges
         * @param   fillColor the color of the rect
         */
        
         
        public static function emptyRect (mc:Sprite, clear:Boolean = true, x:Number = 0, y:Number = 0, boxWidth:Number = 100, boxHeight:Number = 100, thickness:Number = 0, fillColor:Number = 0x000000, fillAlpha:Number = 1):void {
                
			var g:Graphics = mc.graphics;
			
            if (clear != false) g.clear();
            
            // validate values
    
            x = (!isNaN(x)) ? x : 0;
            y = (!isNaN(y)) ? y : 0;
            if (isNaN(boxWidth)) boxWidth = mc.width;
            if (isNaN(boxHeight)) boxHeight = mc.height;
    
            if (isNaN(fillColor)) fillColor = 0x000000;
            if (isNaN(fillAlpha)) fillAlpha = 1;
            if (isNaN(thickness)) thickness = 1;
    
            g.beginFill(fillColor, fillAlpha);
    
            g.moveTo(x, y);
            g.lineTo(x + boxWidth, y);
            g.lineTo(x + boxWidth, y + boxHeight);
            g.lineTo(x, y + boxHeight);
            g.lineTo(x, y);
            
            g.lineTo(x + thickness, y + thickness);
            g.lineTo(x + boxWidth - thickness, y + thickness);
            g.lineTo(x + boxWidth - thickness, y + boxHeight - thickness);
            g.lineTo(x + thickness, y + boxHeight - thickness);
            g.lineTo(x + thickness, y + thickness);
            
            g.endFill();
            
        }
        
        //
        //
        public static function rect (mc:Sprite, clear:Boolean = true, x:Number = 0, y:Number = 0, boxWidth:Number = 100, boxHeight:Number = 100, fillColor:Number = 0x000000, fillAlpha:Number = 1):void {
               
			var g:Graphics = mc.graphics;
			
            if (clear != false) g.clear();
            
            x = (!isNaN(x)) ? x : 0;
            y = (!isNaN(y)) ? y : 0;
            if (isNaN(boxWidth)) boxWidth = mc.width;
            if (isNaN(boxHeight)) boxHeight = mc.height;
    
            if (isNaN(fillColor)) fillColor = 0x000000;
            if (isNaN(fillAlpha)) fillAlpha = 100;
    
            g.beginFill(fillColor, fillAlpha);
    
            g.moveTo(x, y);
            g.lineTo(x + boxWidth, y);
            g.lineTo(x + boxWidth, y + boxHeight);
            g.lineTo(x, y + boxHeight);
            g.lineTo(x, y);
            
            g.endFill();
            
        }
        
        //
        //
        public static function circle (mc:Sprite, clear:Boolean = true, x:Number = 0, y:Number = 0, radius:Number = 10, accuracy:Number = 1, fillColor:Number = 0x000000, fillAlpha:Number = 1, lineThickness:Number = 0, lineColor:Number = 0x000000, lineAlpha:Number = 1):void {

            var g:Graphics = mc.graphics;
			
            if (clear != false) g.clear();
            if (radius == 0 || isNaN(radius)) return;
            
            if (isNaN(fillColor)) fillColor = 0x000000;
            if (isNaN(fillAlpha)) fillAlpha = 100;
            if (isNaN(lineColor)) lineColor = 0x000000;
            if (isNaN(lineThickness)) lineThickness = 0;
            
            if (lineThickness > 0) {
                g.lineStyle(lineThickness, lineColor, 100);
            } else {
                g.lineStyle();
            }
    
            g.beginFill(fillColor, fillAlpha);
            
            g.drawCircle(x, y, radius);
            
            g.endFill();
            
        }
    
    }
}
