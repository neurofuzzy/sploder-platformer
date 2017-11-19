package com.sploder.asui {
	
    import com.sploder.asui.Cell;
    import com.sploder.asui.Component;
	
	import flash.display.Sprite;
	import flash.display.MovieClip;
    
    /**
    * ...
    * @author $(DefaultUser)
    */
    
    
    public class Position {

        public static const ALIGN_LEFT:int = 1;
        public static const ALIGN_CENTER:int = 2;
        public static const ALIGN_RIGHT:int = 3;
        
        public static const PLACEMENT_NORMAL:int = 4;
        public static const PLACEMENT_FLOAT:int = 5;
        public static const PLACEMENT_FLOAT_RIGHT:int = 6;
        public static const PLACEMENT_ABSOLUTE:int = 7;
        
        public static const CLEAR_NONE:int = 8;
        public static const CLEAR_LEFT:int = 9;
        public static const CLEAR_RIGHT:int = 10;
        public static const CLEAR_BOTH:int = 11;
        
        public static const ORIENTATION_HORIZONTAL:int = 12;
        public static const ORIENTATION_VERTICAL:int = 13;
		
		public static const POSITION_ABOVE:int = 14;
		public static const POSITION_BELOW:int = 15;
		public static const POSITION_RIGHT:int = 16;
		public static const POSITION_LEFT:int = 17;
		
		private var cloneParams:Array = [
			"_align", "_placement", "_clear", "margin", 
			"_margin_top", "_margin_right", "_margin_bottom", 
			"_margin_left", "_top", "_left", "_zindex", 
			"_collapse", "_ignoreContentPadding", "_overflow"
			];
        
        private var _align:int;
        private var _placement:int;
        private var _clear:int;
		private var _overflow:String;
        
		public var defaultPlacement:int = 4;
		
		public function set defaultMargins (val:int):void {
			if (!isNaN(val)) defaultMarginTop = defaultMarginRight = defaultMarginBottom = defaultMarginLeft = val;
		}
		
		public static var defaultMarginTop:int = 0;
		public static var defaultMarginRight:int = 0;
		public static var defaultMarginBottom:int = 0;
		public static var defaultMarginLeft:int = 0;
		
        private var _margin:int;
        private var _margin_top:int;
        private var _margin_right:int;
        private var _margin_bottom:int;
        private var _margin_left:int;
        
        private var _top:int = 0;
        private var _left:int = 0;
        
        private var _zindex:int = 1;
        
        private var _collapse:Boolean = false;
		private var _ignoreContentPadding:Boolean = false;
		
		public function get align():int { return _align; }
		public function set align(value:int):void 
		{
			_align = value;
		}
		
		public function get placement():int { return _placement; }
		public function set placement(value:int):void 
		{
			_placement = value;
		}
		
		public function get clear():int { return _clear; }
		public function set clear(value:int):void 
		{
			_clear = value;
		}
		
		public function get overflow():String { return _overflow; }
		public function set overflow(value:String):void 
		{
			_overflow = value;
		}
		
		public function get margin():int { return _margin; }
		public function set margin(value:int):void 
		{
			_margin = value;
		}
		
		public function get margin_top():int { return _margin_top; }
		public function set margin_top(value:int):void 
		{
			_margin_top = value;
		}
		
		public function get margin_right():int { return _margin_right; }
		public function set margin_right(value:int):void 
		{
			_margin_right = value;
		}
		
		public function get margin_bottom():int { return _margin_bottom; }
		public function set margin_bottom(value:int):void 
		{
			_margin_bottom = value;
		}
		
		public function get margin_left():int { return _margin_left; }
		public function set margin_left(value:int):void 
		{
			_margin_left = value;
		}
		
		public function get top():int { return _top; }
        public function set top(value:int):void { _top = value; }

        public function get left():int { return _left; }
        public function set left(value:int):void { _left = value; }

        public function get zindex():int { return _zindex; }
        public function set zindex(value:int):void { _zindex = value; }
		
		public function get collapse():Boolean { return _collapse; }
		public function set collapse(value:Boolean):void 
		{
			_collapse = value;
		}
		
		public function get ignoreContentPadding():Boolean { return _ignoreContentPadding; }
		public function set ignoreContentPadding(value:Boolean):void { _ignoreContentPadding = value; }
		
        private var _options:Object;
        
        //
        //
        public function Position (options:Object = null, align:int = -1, placement:int = -1, clear:int = -1, margins:Object = null, top:Number = NaN, left:Number = NaN, zindex:Number = NaN, collapse:Boolean = false) {
            
            _options = options;

            _align = (options != null && !isNaN(options.align) && options.align > 0) ? options.align : (align > 0) ? align : ALIGN_LEFT;
            _placement = (options != null && !isNaN(options.placement) && options.placement > 0) ? options.placement : (placement > 0) ? placement : defaultPlacement;
            _clear = (options != null && !isNaN(options.clear) && options.clear > 0) ? options.clear : (clear > 0) ? clear : (_placement == PLACEMENT_FLOAT || _placement == PLACEMENT_FLOAT_RIGHT) ? CLEAR_NONE : CLEAR_BOTH;
    
            _top = (options != null && !isNaN(options.top)) ? options.top : (!isNaN(top)) ? top : _top;
            _left = (options != null && !isNaN(options.left)) ? options.left : (!isNaN(left)) ? left : _left;
            _zindex = (options != null && !isNaN(options.zindex)) ? options.zindex : (!isNaN(zindex)) ? zindex : _zindex;
            _collapse = (options != null && options.collapse == true || collapse == true);
			_overflow = (options != null && options.overflow != undefined) ? options.overflow : "";
			_ignoreContentPadding = (options != null && options.ignoreContentPadding) ? true : false;
    
            if (options != null && options.margins != undefined) margins = options.margins;
            
            if (margins != null) {
                
                if (typeof(margins) == "number") {
                    
                    _margin = _margin_top = _margin_right = _margin_bottom = _margin_left = Number(margins);
                    
                } else {
                    
                    var m:Array;
                    
                    if (typeof(margins) == "string") m = String(margins).split(" ");
                    else m = margins as Array;
                    
                    _margin_top = (!isNaN(m[0])) ? parseInt(m[0]) : 0;
                    _margin_right = (!isNaN(m[1])) ? parseInt(m[1]) : 0;
                    _margin_bottom = (!isNaN(m[2])) ? parseInt(m[2]) : 0;
                    _margin_left = (!isNaN(m[3])) ? parseInt(m[3]) : 0;
                    
                }
            
            } else {
				
				_margin_top = defaultMarginTop;
				_margin_right = defaultMarginRight;
				_margin_bottom = defaultMarginBottom;
				_margin_left = defaultMarginLeft;
				
			}
            
            if (options != null && options.margin_top != undefined) _margin_top = options.margin_top;
            if (options != null && options.margin_right != undefined) _margin_right = options.margin_right;
            if (options != null && options.margin_bottom != undefined) _margin_bottom = options.margin_bottom;
            if (options != null && options.margin_left != undefined) _margin_left = options.margin_left;
            
        }
        
        //
        //
        public function clone (overrides:Object):Position {
            
            var optCopy:Object = { };
            var param:String;
			
            for (param in _options) optCopy[param] = _options[param];
            for (var i:int = 0; i < cloneParams.length; i++ ) {
				param = cloneParams[i];
                if (param.indexOf("_") == 0) {
                    if (this[param] is Array) optCopy[param.split("_").join("")] = this[param].concat();
					else optCopy[param.split("_").join("")] = this[param];
                }
            }
            for (param in overrides) optCopy[param] = overrides[param];
            return new Position(optCopy);
            
        }
        
        //
        //
        public static function arrangeContent (cell:Cell, clear:Boolean = false):void {
            
			if (!cell.position.ignoreContentPadding && 
				cell.collapse && 
				cell.lastArrangedChildIndex == -1) cell.lastArrangedChildY = cell.style.padding;
			
            if (clear) {
                cell.lastArrangedChildIndex = -1;
                cell.lastArrangedChildX = 0;
                cell.lastArrangedChildY = 0;
            }
            
            var prevChild:Component;
            var child:Component;
            var ypos:Number = cell.lastArrangedChildY;
            var rowItems:Array = [];
                
            for (var i:int = cell.lastArrangedChildIndex + 1; i < cell.childNodes.length; i++) {
                
                child = cell.childNodes[i];
   
                if (prevChild == null || child.position.placement != prevChild.position.placement || child.position.clear == CLEAR_LEFT || child.position.clear == CLEAR_BOTH || prevChild.position.clear == CLEAR_RIGHT || prevChild.position.clear == CLEAR_BOTH) {
                    
                    if (rowItems.length > 0) {
                        if ((child.position.clear == CLEAR_NONE || child.position.clear == CLEAR_RIGHT) && (prevChild.position.clear == CLEAR_NONE || prevChild.position.clear == CLEAR_LEFT)) {
                            alignRow(cell, rowItems, cell.position.align);
                        } else {
                            ypos += alignRow(cell, rowItems, cell.position.align);
                            cell.lastArrangedChildY = ypos;
                            cell.lastArrangedChildIndex = i - 1;
                        }
                        rowItems = [];
                    }
                    
                }
                
                switch (child.position.placement) {
        
                    case PLACEMENT_FLOAT:
                
                        child.x = child.position.margin_left;
                        child.y = child.position.margin_top + ypos;
                        rowItems.push(child);
                        break;
                        
                    case PLACEMENT_FLOAT_RIGHT:
                    
                        child.x = cell.width - child.width - cell.position.margin_right;
                        child.y = child.position.margin_top + ypos;
                        rowItems.push(child);
                        break;              
                        
                    case PLACEMENT_ABSOLUTE:
                    
                        child.x = child.position.left;
                        child.y = child.position.top;
						
                        break;
                        
                    case PLACEMENT_NORMAL:
                    
                        switch (cell.position.align) {
                            case Position.ALIGN_LEFT:
                                child.x = child.position.margin_left;
                                break;
                            case Position.ALIGN_CENTER:
                                child.x = Math.floor(cell.width * 0.5 - child.width * 0.5);
                                break;
                            case Position.ALIGN_RIGHT:
                                child.x = cell.width - child.width;
                                break;
                        }
                        child.y = child.position.margin_top + ypos;
                        ypos += child.position.margin_top + child.height + child.position.margin_bottom;
                        cell.lastArrangedChildY = ypos;
                        cell.lastArrangedChildIndex = i;
                        break;
                        
                }
                
                prevChild = child;
                
            }
            
            if (rowItems.length > 0) alignRow(cell, rowItems, cell.position.align);
            
            if (cell.sortChildNodes) zSort(cell);
    
        }
        
        //
        //
        private static function alignRow (cell:Cell, children:Array, alignment:Number):Number {
            
            var child:Component;
            var xpos:Number = cell.lastArrangedChildX;
            var height:Number = 0;
            var margin_bottom:Number = -20;
            var yoffset:Number = 0;
			var i:int;
            
            if (children[0].position.placement == PLACEMENT_FLOAT_RIGHT) alignment = ALIGN_RIGHT;
    
            switch (alignment) {
                
                case ALIGN_CENTER:
                
                    var totalWidth:Number = 0;
                    
                    for (i = children.length - 1; i >= 0; i--) {
                        child = children[i];
                        totalWidth += child.width + Math.max(child.position.margin_right, child.position.margin_left);
                    }
                    
                    totalWidth -= Math.max(child.position.margin_right, child.position.margin_left);
                    
                    xpos = Math.floor(cell.width * 0.5 - totalWidth * 0.5);
                    
                    // xpos set, now continue to ALIGN_LEFT ...

                case ALIGN_LEFT:
                default:
					
                    for (i = 0; i < children.length; i++) {
                        
                        child = children[i];
                        
                        child.x = child.position.margin_left + xpos;
						child.y += yoffset;
						
                        xpos += child.position.margin_left + child.width + child.position.margin_right;

                        if (cell.wrap && child.x + child.width > child.parentCell.width) {
                            child.x = child.position.margin_left;
                            xpos = child.position.margin_left + child.width + child.position.margin_right;
                            child.y += child.height + child.position.margin_bottom + child.position.margin_top;
                            yoffset += child.height + child.position.margin_bottom + child.position.margin_top;
                        }
                        
                        height = Math.max(yoffset + child.height, height);
                        margin_bottom = Math.max(child.position.margin_bottom, margin_bottom);
                        
                    }
                    
                    break;
                
                case ALIGN_RIGHT:
                
                    xpos = cell.width;
    
                    for (i = children.length - 1; i >= 0; i--) {
                        
                        child = children[i];
                        child.x = xpos - child.width - child.position.margin_right;
                        xpos -= child.position.margin_left + child.width + child.position.margin_right; 
                        height = Math.max(child.height, height);
                        margin_bottom = Math.max(child.position.margin_bottom, margin_bottom);
                        
                    }
                
                    break;
                    
            }
            
            return height + margin_bottom;
            
        }
        
        private static function zSort (cell:Cell):void {

            
            var zChildren:Array = cell.childNodes.concat();
            
            zChildren.sort(function (a:Component, b:Component):Number {
                
                if (a.zindex < b.zindex) return -1;
                else if (a.zindex > b.zindex) return 1;
                else return 0;
                
                });
                
            var cclip:Sprite;
            var pclip:Sprite;
            
            for (var i:int = zChildren.length - 1; i > 0; i--) {
                
                cclip = Sprite(zChildren[i].mc);
                pclip = Sprite(zChildren[i - 1].mc);
    
                cclip.parent.setChildIndex(cclip, i);
                
            }       
            
        }
        
        //
        //
        public static function getCellContentWidth (cell:Cell):Number {
            
            var width:Number = 0;
            
            for (var i:int = cell.childNodes.length - 1; i >= 0; i--) {
 				
				width = Math.floor(Math.max(width, Component(cell.childNodes[i]).x + Component(cell.childNodes[i]).width));
 
            }
            
            return width;
            
        }
        
        //
        //
        public static function getCellContentHeight (cell:Cell):Number {
            
			if (cell.childNodes.length == 0) return 0;
			
            var height:Number = 0;
            var childNum:Number = cell.childNodes.length - 1;
            var lastChild:Component = cell.childNodes[childNum];
			
            while (lastChild.position.placement == Position.PLACEMENT_ABSOLUTE && childNum > 0) {
            
                childNum--;
                lastChild = cell.childNodes[childNum];
            
            }
            
            if (lastChild != null) {
                
                height = Math.floor(lastChild.y + lastChild.height + lastChild.position.margin_bottom);
				if (cell.collapse) {
					if (cell.position.ignoreContentPadding) {
						height = cell.contents.height - cell.style.padding - cell.style.borderWidth * 2;
					} else {
						height += lastChild.style.padding;
					}
				}
                
            }
            
            if (isNaN(height)) height = 0;
           
            return height;
            
        }
        
    }
}
