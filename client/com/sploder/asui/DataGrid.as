package com.sploder.asui {
    import com.sploder.asui.*;
    
    /**
    * ...
    * @author $(DefaultUser)
    */
    
    
    public class DataGrid extends Cell {

        
        private var _type:String = "datagrid";
        
        private var _cols:Array;
        private var _order:Array;
        private var _ordered:Boolean = false;
        private var _rows:Array;
        private var _cellTypes:Array;
        private var _formatMethods:Array;
        private var _altTagMethods:Array;
        private var _orderedMethod:Function;
        
        private var _widths:Array;
        private var _rowLines:Boolean = false;
        
        private var _rowSpacing:Number = 0;
        private var _cellSpacing:Number = 0;
        
        public var cells:Array;
        
        
        public function DataGrid (container:Sprite, columnKeys:Array, orderedList:Boolean, orderedMethod:Function, columnOrder:Array, rowVals:Array, cellTypes:Array, formatMethods:Array, altTagMethods:Array, columnWidths:Array, width:Number, rowLines:Boolean, rowSpacing:Number, cellSpacing:Number, position:Position, style:Style) {
            
            init (container, columnKeys, orderedList, orderedMethod, columnOrder, rowVals, cellTypes, formatMethods, altTagMethods, columnWidths, width, rowLines, rowSpacing, cellSpacing, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        private function init (container:Sprite, columnKeys:Array, orderedList:Boolean, orderedMethod:Function, columnOrder:Array, rowVals:Array, cellTypes:Array, formatMethods:Array, altTagMethods:Array, columnWidths:Array, width:Number, rowLines:Boolean, rowSpacing:Number, cellSpacing:Number, position:Position, style:Style):void {

            
            super.init(container, _width, NaN, false, false, 0, position, style);
    
            _cols = columnKeys;
            _ordered = (orderedList == true);
            _orderedMethod = orderedMethod;
            _order = columnOrder;
            _rows = rowVals;
            _cellTypes = cellTypes;
            _formatMethods = formatMethods;
            _altTagMethods = altTagMethods;
            
            _widths = columnWidths;
            _rowLines = (rowLines == true);
            _rowSpacing = (!isNaN(rowSpacing)) ? rowSpacing : 0;
            _cellSpacing = (!isNaN(cellSpacing)) ? cellSpacing : 0;
            
            cells = [];
            
        }
        
        //
        //
        public function create ():void {

            
            super.create();
            
            var i:Number;
            var j:Number;
            var k:Number;
            
            var alt:String = "";
            
            var pos:Position = new Position( { margin_right: _cellSpacing, margin_bottom: _rowSpacing }, Position.ALIGN_LEFT, Position.PLACEMENT_FLOAT, Position.CLEAR_NONE );
            var endPos:Position = new Position( { margin_bottom: _rowSpacing }, Position.ALIGN_LEFT, Position.PLACEMENT_FLOAT, Position.CLEAR_RIGHT );
        
            var content:String = "";
            
            // check column widths
            
            var offset:Number = (_ordered) ? 30 + _rowSpacing : 0;
            
            if (_widths == null) {
                
                _widths = [];
                
                for (j = 0; j < _cols.length; j++) _widths[j] = ((_width - offset) / _cols.length) >> 0;
                
            }
            
            if (_order == null) {
                
                _order = [];
                for (j = 0; j < _cols.length; j++) _order[j] = j;
                
            }
            
            // populate
            
            for (j = 0; j < _rows.length; j++) {
    
                cells[j] = [];
                
                if (_ordered) cells[j].push(addChild(new HTMLField(null, (_orderedMethod != null) ? _orderedMethod(j) : "<p>" + (j + 1) + "</p>", 30 + _rowSpacing, false, pos, _style)));              
                        
                for (i = 0; i < _order.length; i++) {
    
                    k = _order[i];
                    
                    alt = (_altTagMethods[k] != undefined) ? _altTagMethods[k](_rows[j][k]) : "";
                    if (String(alt) == "undefined") alt = "";
                    
                    if (_rows[j][k] != null && _rows[j][k] != "null") {
                        
                        content = (_formatMethods[k] != undefined) ? _formatMethods[k](_rows[j][k], j) : String(_rows[j][k]);              
                        
                        if (_cellTypes[k] == "clip") {
                            
                            cells[j].push(addChild(new Clip(null, content, false, _widths[k], 20 + _rowSpacing, Clip.SCALEMODE_CENTER, "", false, alt, (i == _cols.length - 1) ? endPos : pos, _style)));
                            
                        } else {
    
                            content = "<p>" + content + "</p>";
                                
                            cells[j].push(addChild(new HTMLField(null, content, _widths[k], false, (i == _cols.length - 1) ? endPos : pos, _style)));      
                            
                        }
                        
                    }
    
                }
                
                if (_rowLines) addChild(new HRule(null, NaN, new Position( { margin_right: 10, margin_left: (_ordered) ? 30 : 0 } ), _style.clone( { borderWidth: 2 } )));
     
            }
            
            _height = Position.getCellContentHeight(this);
            
        }
        
    }
}
