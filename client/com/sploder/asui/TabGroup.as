package com.sploder.asui {
	
    import com.sploder.asui.*;
	import flash.display.Sprite;
	import flash.events.Event;
    
    /**
    * ...
    * @author $(DefaultUser)
    */
    
    
    public class TabGroup extends Cell {
        
        private var _textLabels:Array;
        private var _tabs:Object;
		private var _alts:Array;
        private var _buttonSize:Number;
		private var _vertical:Boolean = false;
        
        private var _defaultTabIndex:Number;
        private var _activeTab:BButton;
		
		public var clipMode:Boolean = false;
		public var clipScale:Number = -1;
		public var textAlign:int = Position.ALIGN_LEFT;
		public var droop:Boolean = false;
        
        public function get activeTab():BButton { return _activeTab; }
    
        public function get tabs():Object { return _tabs; }
		
		override public function set value(val:String):void 
		{
			if (_tabs[StringUtils.clean(val)]) activateTab(null, BButton(_tabs[StringUtils.clean(val)]));
		}
        
        
        //
        //
        public function TabGroup (container:Sprite, textLabels:Array, alts:Array, defaultTabIndex:Number = 0, size:Number = NaN, vertical:Boolean = false, position:Position = null, style:Style = null) {
            
            init_TabGroup(container, textLabels, alts, defaultTabIndex, size, vertical, position, style);
           
            if (_container != null) create();
            
        }
        
        //
        //
        private function init_TabGroup (container:Sprite, textLabels:Array, alts:Array, defaultTabIndex:Number = 0, size:Number = NaN, vertical:Boolean = false, position:Position = null, style:Style = null):void {
            
            super.init_Cell(container, 0, 0, false, false, 0, position, style);
			
			_type = "tabgroup";

			_style = _style.clone( { buttonDropShadow: false } );
            _textLabels = textLabels;
			_alts = alts;
            _defaultTabIndex = defaultTabIndex;
            _buttonSize = size;
			_vertical = vertical;
            _tabs = [];
    
        }
        
        //
        //
        override public function create ():void {
     
            super.create();
            
            if (_parentCell != null) {
                _width = _parentCell.width;
            }

            var i:Number;
            
            var tabsPos:Position;
			var tabStyle:Boolean;
			var buttonTextAlign:int = Position.ALIGN_CENTER;
			
			if (!_vertical) {
				tabsPos = new Position(null, Position.ALIGN_LEFT, Position.PLACEMENT_FLOAT, Position.CLEAR_NONE, 0);
				tabStyle = true;
			} else {
				tabsPos = new Position( { margin_bottom: _position.margin_bottom / 2 } , Position.ALIGN_CENTER, Position.PLACEMENT_NORMAL, Position.CLEAR_BOTH);
				_position = _position.clone( { align: Position.ALIGN_CENTER } );
				tabStyle = false;
				buttonTextAlign = Position.ALIGN_LEFT;
			}
			
			var bheight:Number;
			var bwidth:Number;
			
			if (!_vertical) {
				bwidth = NaN;
				bheight = _buttonSize;
			} else {
				bwidth = _buttonSize;
				bheight = NaN;
			}
           
            for (i = 0; i < _textLabels.length; i++) {
				
                var bb:BButton;
				if (!clipMode) {
					bb = new BButton(null, _textLabels[i], textAlign, bwidth, bheight, tabStyle, true, false, tabsPos, _style, droop);
				} else {
					bb = new ClipButton(null, _textLabels[i], "", clipScale, _buttonSize, _buttonSize, 10, tabStyle, true, false, false, tabsPos, _style, droop);
					if (i > 0) {
						addChild(new Divider(null, _vertical ? _buttonSize : 1, _vertical ? 1 : _buttonSize, !_vertical, tabsPos, _style));
					}
				}
				if (_alts && _alts[i]) bb.alt = _alts[i];
                _tabs.push(bb);
				_tabs[StringUtils.clean(_textLabels[i])] = bb;
				bb.forceWidth = _vertical;
				addChild(bb);
                
            }
            
            _height = 0;
            
            for (i = 0; i < _tabs.length; i++) {
                
                BButton(_tabs[i]).addEventListener(EVENT_CLICK, activateTab);
                _height = Math.max(_height, BButton(_tabs[i]).height);
                
            }          
            
			if (_parentCell != null) {
            	_width = _parentCell.width - _position.margin_left - _position.margin_right;
            	_height = _parentCell.height - _position.margin_top - _position.margin_bottom;
			} else {
				_width = mainStage.stageWidth;
				_height = 0;
			}
    
			collapse = true;
            Position.arrangeContent(this);
			
			if (clipMode) {
				_width = Position.getCellContentWidth(this);
				_height = _buttonSize;
			} else {
				_width = Position.getCellContentWidth(this);
				_height = Position.getCellContentHeight(this);
			}
			
            if (_defaultTabIndex >= 0 && _defaultTabIndex < _textLabels.length) {
                BButton(_tabs[_defaultTabIndex]).select();
                _activeTab = BButton(_tabs[_defaultTabIndex]);
            }

        }
        
        //
        //
        public function activateTab (e:Event = null, tab:BButton = null):void {
            
			var bb:BButton;
			
			if (e && e.target) bb = BButton(e.target);
			else if (tab) bb = tab;
			else return;
			
			var changed:Boolean = (_activeTab != bb);
			
            for (var i:int = 0; i < _tabs.length; i++) if (_tabs[i] != bb) BButton(_tabs[i]).deselect();
            
            _activeTab = bb;
    
            _activeTab.select();
			
			_value = _activeTab.value;
            
            dispatchEvent(new Event(EVENT_CLICK));
			if (changed) dispatchEvent(new Event(EVENT_CHANGE));
            
        }
        
        //
        //
        public function getTabByLabel (textLabel:String):BButton {
            
            for (var i:int = 0; i < _tabs.length; i++) if (BButton(_tabs[i]).textLabel == textLabel) return BButton(_tabs[i]);
    
            return null;
            
        }
        
        //
        //
        public function select (tab:Object):void {
            
			if (tab) {
				var tabIndex:String = String(tab);
		
				for (var tabRef:String in _tabs) if (tabRef != tabIndex) BButton(_tabs[tabRef]).deselect();
				
				_activeTab = BButton(_tabs[tabIndex]);
				
				_activeTab.select();
				
				value = _activeTab.value;
				
				dispatchEvent(new Event(EVENT_CLICK)); 
			}
            
        }
        
    }
}
