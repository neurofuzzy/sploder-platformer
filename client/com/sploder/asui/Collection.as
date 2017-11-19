package com.sploder.asui {
	
	import adobe.utils.CustomActions;
	import com.sploder.asui.*;
	import com.sploder.util.ObjectEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.SimpleButton;
	import flash.events.KeyboardEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import flash.display.Stage;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Collection extends Cell {
		
		public static const EVENT_ADD_MEMBER:String = "add_member";
		public static const EVENT_ADD_START:String = "add_complete";
		public static const EVENT_ADD_COMPLETE:String = "add_complete";
		public static const EVENT_DELETE:String = "delete";
		public static const EVENT_RESTORE:String = "restore";
		public static const EVENT_LIST_CHANGE:String = "list_change";
		public static const EVENT_CLEAR:String = "list_clear";
		
		// modes
		public var allowRemoveOnDrag:Boolean = false;
		public var useRotateEffectOnDrag:Boolean = false;
		public var useBorderColorOnHighlight:Boolean = false;
		public var allowDrag:Boolean = false;
		public var allowRearrange:Boolean = false;
		public var allowDelete:Boolean = true;
		public var allowMultiSelect:Boolean = false;
		public var usePagingDisplay:Boolean = false;
		public var useBorderWidthInBlanks:Boolean = true;
		public var useCircularBlanks:Boolean = false;
		public var autoResize:Boolean = false;
		public var resizeScale:Number = 1;
		public var showHighlight:Boolean = true;
		public var useSnap:Boolean = false
		public var ignoreVisibility:Boolean = false;
		public var allowKeyboardEvents:Boolean = true;
		
		public static var selectedCollection:Collection;
		public static var sourceCollection:Collection;
		public static var destCollection:Collection;
		public static var destIndex:int;
		
		protected var _currentPage:int = 1;
		public function get currentPage():int { return _currentPage; }
		
		public function get totalPages ():int {
			return Math.ceil(_members.length / _itemsPerPage);
		}
		
		protected var _pageWidth:int;
		protected var _pageX:int = 0;
		protected var _itemsPerPage:int = 0;
		protected var _itemsPerRow:int = 0;
		
		protected var _members:Array;
		public function get members():Array { return _members; }
		
		protected var _masterCollection:Collection;
		public function get masterCollection():Collection { return _masterCollection; }
		
		public function set masterCollection(value:Collection):void {
			
			if (_masterCollection != null) {
				_masterCollection.removeEventListener(EVENT_ADD_MEMBER, onMasterAdd);
				_masterCollection.removeEventListener(EVENT_LIST_CHANGE, onMasterChange);
				_masterCollection.removeEventListener(EVENT_DELETE, onMasterDelete);
				_masterCollection.removeEventListener(EVENT_RESTORE, onMasterRestore);
				_masterCollection.removeEventListener(EVENT_CLEAR, onMasterClear);
			}
			
			_masterCollection = value;
			
			if (_masterCollection != null) {
				_masterCollection.addEventListener(EVENT_ADD_MEMBER, onMasterAdd);
				_masterCollection.addEventListener(EVENT_LIST_CHANGE, onMasterChange);
				_masterCollection.addEventListener(EVENT_DELETE, onMasterDelete);
				_masterCollection.addEventListener(EVENT_RESTORE, onMasterRestore);
				_masterCollection.addEventListener(EVENT_CLEAR, onMasterClear);
				onMasterChange();
			} else {
				clear();
			}
			
		}
		
		protected var clipboard:Array;
		
		protected var _memberRefs:Dictionary;
		
		protected var _newItems:Array;
		
		protected var _populating:Boolean = false;
		
		public function set membersMouseEnabled (value:Boolean):void {
			for each (var child:Component in childNodes) child.mouseEnabled = value;
		}
		
		protected var _selectedMembers:Array;
		public function get selectedMembers():Array { return _selectedMembers; }
		
		protected var _selectionIndex:int = -1;
		public function get selectionIndex():int { return _selectionIndex; }

		protected var _memberPosition:Position;
		
		protected static var selectBox:Sprite;
		protected var _selectDrag:Boolean = false;
		protected var _isDragging:Boolean = false;
		protected var _isSelecting:Boolean = false;
		
		protected var _isTweening:Boolean = false;
		protected var _tweenRate:Number = 3;
		
		protected static var dragContainer:Sprite;
		protected static var dragGhost:Sprite;
		protected static var dragGhostSnapshot:Bitmap;
		
		public var dropPoint:Point;
		
		protected var markerContainer:Sprite;
		
		protected var _backgroundButton:Sprite;
		
		override public function get contentWidth():Number { 
			return super.contentWidth + _spacing; 
		}
		
        override public function get width ():uint {
           
            if (_width == 0) return _mc.width;
            else return Math.max(_startWidth, _width + _spacing);
            
        }
        
        override public function get height ():uint {
            
            if (_height == 0) return _mc.height;
            else return Math.max(_startHeight, _height + _spacing);
            
        }
		
		protected var _memberWidth:int = 100;
		public function get memberWidth():int { return _memberWidth; }
		protected var _memberHeight:int = 100;
		public function get memberHeight():int { return _memberHeight; }
		
		protected var _rowLength:int = 5;
		protected var _spacing:int = 20;
		protected var _startWidth:Number;
		protected var _startHeight:Number;
		protected var _totalWidth:Number;
		protected var _totalHeight:Number;
		protected var _newScale:Number;
		protected var _rescaling:Boolean = false;
		
		protected var _mouseXold:Number = 0;
		protected var _mouseYold:Number = 0;
		
		public var itemScale:Number = 1;
		
		public var itemListener:Function;
		
		public var defaultItemComponent:String;
		public var defaultItemStyle:Style;

		//
		//
		public function Collection (container:Sprite = null, width:Number = NaN, height:Number = NaN, memberWidth:Number = 100, memberHeight:Number = 100, spacing:int = 10, position:Position = null, style:Style = null) {
            
            init_Collection (container, width, height, memberWidth, memberHeight, spacing, position, style);
			
            if (_container != null) create();
            
        }
		
		//
		//
		protected function init_Collection (container:Sprite, width:Number = NaN, height:Number = NaN, memberWidth:Number = 100, memberHeight:Number = 100, spacing:int = 10, position:Position = null, style:Style = null):void {
			
			super.init_Cell(container, width, height, false, false, 0, position, style);
			 
			_type = "collection";	
			
			dropPoint = new Point();

			if (isNaN(height)) _collapse = true;
			
			_memberWidth = memberWidth;
			_memberHeight = memberHeight;
			_spacing = spacing;
			_memberPosition = new Position(null, Position.ALIGN_LEFT, Position.PLACEMENT_FLOAT, Position.CLEAR_NONE, _spacing / 2);
			_rowLength = Math.max(1, Math.floor(_width / (_memberWidth + _spacing * 2)));
			
			_pageWidth = _width;
			_itemsPerPage = Math.floor(_width / (_memberWidth + _spacing)) * Math.floor(_height / (_memberHeight + _spacing));
			_itemsPerRow = Math.floor(_pageWidth / (_memberWidth + _spacing));
			
			_members = [];
			_selectedMembers = [];
			_memberRefs = new Dictionary(true);
			_newItems = [];
			clipboard = [];
			
			Key.initialize(mainStage);
			mainStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			mainStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			
		}
		
		//
		//
		override public function create():void {
			
			super.create();
			
			_startWidth = _width;
			_startHeight = _height;
			
			if (selectBox == null) {
				
				selectBox = new Sprite();
				selectBox.visible = false;
				
				var g:Graphics = selectBox.graphics;
				
				g.lineStyle(1, _style.highlightTextColor, 1, true, LineScaleMode.NONE);
				g.beginFill(_style.highlightTextColor, 0.25);
				g.drawRect(0, 0, 100, 100);
				
				Component.mainStage.addChild(selectBox);
				
			}
			
			if (dragContainer == null) {
				
				dragContainer = new Sprite();
				dragContainer.name = "_collection_dragcontainer";
				Component.mainStage.addChild(dragContainer);
				
				dragGhost = new Sprite();
				dragContainer.addChild(dragGhost);
				
				dragGhostSnapshot = new Bitmap();
				dragGhost.addChild(dragGhostSnapshot);

			}
			
			_backgroundButton = new Sprite();
			_backgroundButton.graphics.beginFill(0x000000, 0);
			_backgroundButton.graphics.drawRect(0, 0, _width, _height);
			_backgroundButton.addEventListener(MouseEvent.MOUSE_DOWN, onSelectWindowStart);
			_mc.addChild(_backgroundButton);
			_mc.setChildIndex(_backgroundButton, 0);
			
			markerContainer = new Sprite();
			_mc.addChild(markerContainer);
			
			_bkgd.mouseEnabled = false;
			
		}
		
		//
		//
		public function getItem (key:Object):CollectionItem {
			
			if (_memberRefs[key] is CollectionItem) return _memberRefs[key] as CollectionItem;
			else if (_memberRefs[key] is Array) return _memberRefs[key][0];

			return null;
			
		}
	
		//
		//
		protected function saveMembers (members:Array):void {
			
			clipboard = [];
			
			for each (var member:CollectionItem in members) {
				
				if (_members.indexOf(member) >= 0) clipboard.unshift( { member: member, index: _members.indexOf(member) } );
				
			}
			
			clipboard.sortOn("index");
			
		}
		
		//
		//
		protected function restoreMembers ():void {
			
			var item:Object;
			var member:CollectionItem;
			var restoredMembers:Array = [];
			
			var references:Array = [];
			
			while (clipboard.length > 0) {
				
				item = clipboard.shift();
				member = item.member;
				member.deleted = false;
				references.push(member.reference);
				addChild(member);
				setItemReference(member.reference, member);
				_members.splice(item.index, 0, item.member);

				restoredMembers.push(member);
				
			}
			
			dispatchEvent(new ObjectEvent(EVENT_RESTORE, false, false, references));
			selectMembers(restoredMembers);
			arrange();
			
		}
	
		
		//
		//
		public function addMembers (items:Array, startIndex:int = -1, clear:Boolean = false, snap:Boolean = false):Array {
			
			var newMembers:Array = [];
			
			if (useSnap) snap = true;
			
			if (clear) {
				this.clear();
				_newItems = [];
			}
				
			deselectObjects();

			if (items[0] is CollectionItem) for (var i:int = 0; i < items.length; i++) items[i] = CollectionItem(items[i]).reference;
			
			_newItems = _newItems.concat(items);
			
			if (startIndex == -1 && items.length > 500) {
				
				if (!_populating) {
					
					dispatchEvent(new Event(EVENT_ADD_START));
					_populating = true;
					
					mainStage.addEventListener(Event.ENTER_FRAME, populate);
					
				}
				
			} else {
				
				var idx:int = startIndex;
				
				while (_newItems.length > 0) {
					newMembers.push(addMember(_newItems.shift(), idx, snap));
					if (idx != -1) idx++;
				}
				
				deselectObjects();
				
				if (startIndex != -1) selectObjects(startIndex, startIndex + items.length - 1);
				
				dispatchEvent(new Event(EVENT_ADD_COMPLETE));
				
			}
			
			return newMembers;

		}
		
		//
		//
		public function removeMembers (members:Array):void {
				
			deselectObjects();
			var i:int;
			
			saveMembers(members);
			
			for (i = members.length - 1; i >= 0; i--) {
				
				if (members[i] is CollectionItem) CollectionItem(members[i]).deleted = true;
				removeChild(CollectionItem(members[i]), false);
				
				if (_memberRefs[CollectionItem(members[i]).reference] is CollectionItem) {
					
					_memberRefs[CollectionItem(members[i]).reference] = null;
					
				} else if (_memberRefs[CollectionItem(members[i]).reference] is Array) {
					
					var ma:Array = _memberRefs[CollectionItem(members[i]).reference] as Array;
					if (ma.indexOf(members[i]) != -1) ma.splice(ma.indexOf(members[i]), 1);
					if (ma.length == 0) _memberRefs[CollectionItem(members[i]).reference] = null;
					else if (ma.length == 1) _memberRefs[CollectionItem(members[i]).reference] = ma[0];
					
				}
				
			}
			
			var member:CollectionItem;
			
			for (i = members.length - 1; i >= 0; i--) {
				member = members[i];
				splice(_members.indexOf(member), 1, null, false);
				member.deleted = true;
			}
	
		}
		
		public function addAlts (alts:Array):void {
			
			for (var i:int = 0; i < alts.length; i++) {
				if (_members[i]) CollectionItem(_members[i]).alt = alts[i];
			}
			
		}
		
		//
		//
		// SELECTOBJECTS selects objects in range
		public function selectMembers (members:Array):void {
			
			deselectObjects();
			
			if (members.length > 0) {

				for (var i:Number = 0; i < members.length; i++) {
					
					if (_members.indexOf(members[i]) != -1) {
						_selectedMembers.push(members[i]);
						CollectionItem(members[i]).selected = true;
					}
				}

			}
			
			if (selectedCollection != null && selectedCollection != this) selectedCollection.deselectObjects();
			selectedCollection = this;
			
		}
		
		//
		//
		protected function populate (e:Event):void {
			
			if (_newItems.length > 0) {
				
				addMember(_newItems.shift());
				
			} else {
				
				_populating = false;
				mainStage.removeEventListener(Event.ENTER_FRAME, populate);
				dispatchEvent(new Event(EVENT_ADD_COMPLETE));
				
			}
			
		}

		//
		//
		protected function addMember (item:Object, index:int = -1, snap:Boolean = false):CollectionItem {
			
			var member:CollectionItem;
			var ds:Style = (defaultItemStyle) ? defaultItemStyle : _style;
			
			member = new CollectionItem(this, item, _memberWidth, _memberHeight, _memberPosition, ds);
			if (itemListener != null) member.addEventListener(EVENT_CREATE, itemListener);
			if (itemListener != null) member.addEventListener(EVENT_CHANGE, itemListener);
			if (itemListener != null) member.addEventListener(EVENT_REMOVE, itemListener);
			
			addChild(member);

			member.addEventListener(Component.EVENT_CLICK, onMemberClick);
			member.addEventListener(Component.EVENT_DRAG, startDrag);
			member.addEventListener(Component.EVENT_DROP, stopDrag);
				
			setItemReference(item, member);
				
			_members.push(member);

			selectObject(member);
			
			if (index >= 0) placeSelectionAt(index, true);

			arrange(snap);
			
			if (usePagingDisplay) {
				
			}
			
			dispatchEvent(new ObjectEvent(EVENT_ADD_MEMBER, false, false, member.reference));
			
			return member;
	
		}
		
		//
		//
		protected function setItemReference (item:Object, member:CollectionItem):void {
			
			if (_memberRefs[item] == null) {
				_memberRefs[item] = member;
			} else {
				if (_memberRefs[item] is CollectionItem) {
					_memberRefs[item] = [_memberRefs[item], member];
				} else {
					var refmembers:Array = _memberRefs[item] as Array;
					refmembers.push(member);
				}
			}			
			
		}
		
		//
		//
		public function updateView ():void {
			
			arrange();
			
		}
		
		//
		//
		//
		protected function arrange (snap:Boolean = false):void {
			
			var member:CollectionItem;
			
			if (useSnap) snap = true;
			
			_childNodes = _members.concat();
			
			if (autoResize) {
				
				resize();
				dispatchEvent(new Event(EVENT_CHANGE));
				
			} else {
				
				if (usePagingDisplay) {
					
					_width = totalPages * _pageWidth + 10;
					
					var page:int;
					var row:int;
					var col:int;
					var i:int;
					
					for (i = 0; i < _members.length; i++) {
						
						member = members[i];
						
						page = Math.floor(i / _itemsPerPage);
						col = i % _itemsPerRow;
						row = Math.floor((i % _itemsPerPage) / _itemsPerRow);
						member.x = _spacing / 2 + _pageWidth * page + (_memberWidth + _spacing) * col;
						member.y = _spacing / 2 + (_memberHeight + _spacing) * row;
						
					}

					_width = Position.getCellContentWidth(this);
					
					var g:Graphics = _childrenContainer.graphics;
					
					g.clear();
					
					if (_members.length % _itemsPerPage != 0) {
						
						var blanks:int = _itemsPerPage - (_members.length % _itemsPerPage);

						for (i = _members.length; i < _members.length + blanks; i++) {
							
							member = members[i];
							
							page = Math.floor(i / _itemsPerPage);
							col = i % _itemsPerRow;
							row = Math.floor((i % _itemsPerPage) / _itemsPerRow);
							g.beginFill(_style.borderColor, 0.10);
							
							var bdWidth:int = (useBorderWidthInBlanks) ? _style.borderWidth : 0;
							
							if (!useCircularBlanks) {
								
								g.drawRect(
									_spacing / 2 + _pageWidth * page + (_memberWidth + _spacing) * col - bdWidth * itemScale,
									_spacing / 2 + (_memberHeight + _spacing) * row - bdWidth * itemScale,
									_memberWidth + bdWidth * 2 * itemScale,
									_memberHeight + bdWidth * 2 * itemScale
									);
								
							} else {
								
								g.drawCircle(
									_memberWidth / 2 + _spacing / 2 + _pageWidth * page + (_memberWidth + _spacing) * col - bdWidth * itemScale,
									_memberHeight / 2 + _spacing / 2 + (_memberHeight + _spacing) * row - bdWidth * itemScale,
									((_memberWidth - 4) + bdWidth * 2 * itemScale) / 2
									);
	
							}
							
						}						
						
					} else {
						
						g.clear();
						
					}
					
					if (resizeScale != 1) _mc.scaleX = _mc.scaleY = resizeScale;
					
				} else {

					Position.arrangeContent(this, true);
					
				}

				for each (member in _members) {
					if (useRotateEffectOnDrag) member.rotation = 0;
					if (snap) member.snapToPosition();
				}
				
				if (!_wrap) {
					_rowLength = Math.max(1, _members.length);
					_width = Position.getCellContentWidth(this);
				}
				
				if (_collapse) {
					_height = Position.getCellContentHeight(this);
				}

				if (_selectedMembers.length > 0) checkSelectionVisibility(_selectedMembers[0]);
				else dispatchEvent(new Event(EVENT_CHANGE));
				
			}

			dispatchEvent(new Event(EVENT_LIST_CHANGE));
			
		}
		
        //
        //
        //
        protected function resize ():void {

			var i:int;
			
			if (_members.length == 0) return;
			
        	_rowLength = Math.max(1, _members.length);
            
            if (_members.length > 3) {
                
				var sq:Number;
				
				sq = Math.round(Math.sqrt(_members.length) * _width / _height);

				if (_width / _height > 0.7 && _width / _height < 1.3 && Math.sqrt(_members.length) % 1 == 0) {
					sq = Math.sqrt(_members.length);
				}
				
				_rowLength = Math.max(1, sq);

            }
			
            _totalWidth = (_memberWidth + _spacing) * (_rowLength - 1);
            _totalHeight = 0;
            
            if (_rowLength > 0) {
                _totalHeight = (_memberHeight + _spacing) * (Math.ceil(_members.length / _rowLength) - 1);
            }
            
            for (i = 0; i < _members.length; i++) {
                
				var member:CollectionItem = _members[i];
				
				if (!member.deleted) {
					
					member.x = (_memberWidth + _spacing) * (i % _rowLength) - _totalWidth / 2 - _memberWidth / 2;
					member.y = (_memberHeight + _spacing) * Math.floor(i / _rowLength) - _totalHeight / 2 - _memberHeight / 2;
					member.rotation = 0;
					if (member.mc != null && member.mc.parent != null) {
						member.mc.parent.setChildIndex(member.mc, Math.min(i, member.mc.parent.numChildren - 1));
					}
					
				}

            }
			
            _childrenContainer.x = _startWidth / 2;
			_childrenContainer.y = _startHeight / 2;
			
			_newScale = Math.min(1, Math.min(((_width - _memberWidth - _spacing * 2) / _totalWidth), ((_height - _memberHeight - _spacing * 2) / _totalHeight)));
            _newScale *= resizeScale;
            if (!_rescaling) Component.mainStage.addEventListener(Event.ENTER_FRAME, zoom);
            
        }
		
		//
		//
		protected function zoom (e:Event):void {
			
			var c:Sprite = _childrenContainer;
			c.scaleX += (_newScale - c.scaleX) / 3;
            c.scaleY += (_newScale - c.scaleY) / 3;
			
			if (Math.abs(_newScale - c.scaleX) < 1) {
				c.scaleX = c.scaleY = _newScale;
				Component.mainStage.removeEventListener(Event.ENTER_FRAME, zoom);
				_rescaling = false;
			}
			
			dragContainer.scaleX = markerContainer.scaleX = c.scaleX;
			dragContainer.scaleY = markerContainer.scaleY = c.scaleY;
			
		}
		
		//
		//
		public function checkSelectionVisibility (member:CollectionItem):void {
			
			if (ignoreVisibility) return;
			
			if (_members.indexOf(member) >= 0) {
				
				if (usePagingDisplay) {
					
					var pageNum:int = Math.floor(_members.indexOf(member) / _itemsPerPage);
					
					gotoPage(pageNum);
					
				} else if (_wrap) {
					
					var contentHeight:Number = Position.getCellContentHeight(this);
					
					_parentCell.contentY = 0 - member.y + _height / 2 - _memberHeight / 2;
					
				} else {
					
					var contentWidth:Number = Position.getCellContentWidth(this);
					
					if (member.x > 0 - _parentCell.contentX + _startWidth - _memberWidth) {
						_parentCell.contentX = 0 - member.x + _startWidth - _memberWidth - _spacing;
					} else if (member.x < 0 - _parentCell.contentX) {
						_parentCell.contentX = 0 - member.x + _spacing;
					}
					
				}
			
			}

			dispatchEvent(new Event(EVENT_CHANGE));
			
		}
		
		//
		//
		//
		protected function getIndexFromPosition (x:Number, y:Number):int {
			
			var newIndex:int;
			
			if (autoResize) {
				
				var totalWidth:Number = (_memberWidth + _spacing) * (_rowLength - 1);
				var totalHeight:Number = 0;
				
				if (_rowLength > 0) {
					totalHeight = (_memberHeight + _spacing) * (Math.ceil(_members.length / _rowLength) - 1);
				}
				
				newIndex = Math.round((y + totalHeight / 2) / (_memberHeight + _spacing)) * _rowLength;
				newIndex += Math.min(_rowLength, Math.max(0, Math.ceil((x + totalWidth / 2) / (_memberWidth + _spacing))));
				
			} else {

				if (_rowLength > 1) {
					x -= _memberWidth / 2;
					y -= _memberHeight / 2;
				}
				x /= _memberWidth + _spacing * 2;
				y /= _memberHeight + _spacing * 2;

				if (_rowLength == 1) newIndex = Math.floor(y) * _rowLength;
				else newIndex = Math.round(y) * _rowLength;
				
				if (!_wrap) newIndex = 0;
				
				newIndex += Math.min(_rowLength, Math.ceil(x));

			}
			
			newIndex = Math.min(_members.length, Math.max(0, newIndex));
			
			return newIndex;
			
		}
		
		
		/*
		--------------------------------------------------------------------------
		ARRAY PASSTHROUGH METHODS
		--------------------------------------------------------------------------
		*/
		
		//
		//
		//
		protected function push (member:CollectionItem):uint {
			var i:uint = _members.push(member);
			addChild(member);
			arrange();
			return i;
		}
		
		//
		//
		//
		protected function unshift (member:CollectionItem):uint {
			var i:uint = _members.unshift(member);
			addChild(member);
			arrange();
			return i;
		}
			
		//
		//
		//
		protected function pop (keepClips:Boolean):CollectionItem {
			var member:CollectionItem = _members.pop();
			if (keepClips != true) removeChild(member);
			arrange();
			return member;
		}
		
		//
		//
		//
		protected function shift (keepClips:Boolean):CollectionItem {
			var member:CollectionItem = _members.shift();
			if (keepClips != true) removeChild(member);
			arrange();
			return member;
		}
		
		//
		//
		//
		protected function slice(startIndex:Number, endIndex:Number):Array {
			return _members.slice(startIndex, endIndex);
		}
		
		//
		//
		//
		protected function splice(startIndex:Number, deleteCount:Number, value:Object, keepClips:Boolean):Array {
			
			if (startIndex == -1) return null;
			
			var m:Array;
			var i:int;
			
			if (value == null) {
				m = _members.splice(startIndex, deleteCount);
			} else {
				//_root.debug2 += "adding member " + value[0]._mc + " back into array\n";
				m = _members.splice(startIndex, deleteCount, value[0]);
				for (i = 0; i < _members.length; i++) {
					//_root.debug2 += i + ": " + _members[i]._mc + "\n";
				}
			}
			
			//_root.debug2 += "splicing at " + startIndex + "\n";
			
			if (keepClips != true && deleteCount > 0) {
				for (i = 0; i < m.length; i++) {
					//trace(m[i], m[i].collection.name);
					removeChild(m[i], false);
				}
			}
			
			//_root.debug2 += "new members length is " + _members.length + "\n";
			arrange();
			return m;
			
		}

		//
		//
		//
		protected function concat (value:Object):Array {
			return _members.concat(value);
		}
		
		//
		//
		//
		protected function join (delimiter:String):String {
			return _members.join(delimiter);
		}
		
		//
		//
		//
		override public function toString ():String {
			
			var memberStrings:Array = [];
			
			for (var i:int = 0; i < _members.length; i++) {
				
				if (CollectionItem(_members[i]).reference != null) {
					
					if (CollectionItem(_members[i]).reference is String) memberStrings.push(CollectionItem(_members[i]).reference);
					else if (CollectionItem(_members[i]).reference["toString"] is Function) memberStrings.push(CollectionItem(_members[i]).reference.toString());
				
				}
				
			}
			
			return memberStrings.toString();
			
		}
		
		//
		//
		//
		protected function reverse ():void {
			_members.reverse();
			arrange();
		}

		//
		//
		//
		protected function sort(compareFunction:Object, options:Number):Array {
			var m:Array = _members.sort(compareFunction, options);
			arrange();
			return m;
		}
		
		//
		//
		//
		protected function sortOn(fieldName:Object, options:Number):Array {
			var m:Array = _members.sortOn(fieldName, options);
			arrange();
			return m;
		}
		
		
		/*
		--------------------------------------------------------------------------
		INTERACTIVITY METHODS
		--------------------------------------------------------------------------
		*/		
		
		//
		//
		protected function onKeyDown (e:KeyboardEvent):void {
			
			if (!allowKeyboardEvents) return;
			
			if (e.charCode == 97 && e.ctrlKey && allowMultiSelect) selectObjects();
			if (e.charCode == 100 && e.ctrlKey) deselectObjects();
			
			if (_selectedMembers.length > 0) {
				
				if (e.keyCode == Keyboard.SPACE) {
					if (CollectionItem(_selectedMembers[0]).activateCallback != null) {
						CollectionItem(_selectedMembers[0]).activateCallback();
					}
				}

				if (allowRearrange) {
					
					if (e.keyCode == Keyboard.RIGHT) {
						if (e.shiftKey) placeSelectionAt(_members.length);
						else placeSelectionAt(_members.indexOf(_selectedMembers[_selectedMembers.length - 1]) + 2);
					}
					
					if (e.keyCode == Keyboard.LEFT) {
						if (e.shiftKey) placeSelectionAt(0);
						else placeSelectionAt(_members.indexOf(_selectedMembers[0]) - 1);
					}
					
					if (e.keyCode == Keyboard.UP) {
						if (e.shiftKey) placeSelectionAt(0);
						else placeSelectionAt(_members.indexOf(_selectedMembers[0]) - _rowLength);
					}
					
					if (e.keyCode == Keyboard.DOWN) {
						if (e.shiftKey) placeSelectionAt(_members.length);
						else placeSelectionAt(_members.indexOf(_selectedMembers[_selectedMembers.length - 1]) + _rowLength + 1);
					}
				
				} else {
					
					var memberToSelect:CollectionItem;
					
					if (e.keyCode == Keyboard.RIGHT) {
						if (_members.indexOf(_selectedMembers[0]) < _members.length - 1) memberToSelect = _members[Math.min(_members.length - 1, _members.indexOf(_selectedMembers[0]) + 1)];
					}
					
					if (e.keyCode == Keyboard.LEFT) {
						if (_members.indexOf(_selectedMembers[0]) > 0) memberToSelect = _members[Math.max(0, _members.indexOf(_selectedMembers[0]) - 1)];
					}
					
					if (e.keyCode == Keyboard.UP) {
						memberToSelect = _members[Math.max(0, _members.indexOf(_selectedMembers[0]) - _rowLength)];
					}
					
					if (e.keyCode == Keyboard.DOWN) {
						memberToSelect = _members[Math.min(_members.length - 1, _members.indexOf(_selectedMembers[0]) + _rowLength)];
					}
					
					if (memberToSelect != null && memberToSelect != _selectedMembers[0]) {
						selectObject(memberToSelect);
						if (memberToSelect.selectCallback != null) memberToSelect.selectCallback();
					}
					
				}
				
			}

		}
		
		
		//
		//
		protected function onKeyUp (e:KeyboardEvent):void {

			if (!allowRearrange || !allowKeyboardEvents) return;
			
			if (_selectedMembers.length > 0) {
				
				if (e.keyCode == Keyboard.BACKSPACE) {
					_selectedMembers.reverse();
					placeSelectionAt(_members.indexOf(_selectedMembers[_selectedMembers.length - 1]) + 1);
				}
				
				if (e.keyCode == Keyboard.DELETE) {
					deleteSelectedObjects();
					mainStage.focus = this.mc;
				}
				
			}
			
			if (clipboard != null && clipboard.length > 0) {
				
				if (e.charCode == 122 && e.ctrlKey) restoreMembers();
			}
			
		}
		
		//
		//
		protected function onMemberClick (e:Event):void {
			
			var member:CollectionItem = CollectionItem(e.target);
			
			selectObject(member);
			
		}
		
		//
		//
		public function selectPrevious (e:MouseEvent = null):void {
			
			var memberToSelect:CollectionItem;
			
			if (_selectedMembers.length > 0) memberToSelect = _members[Math.max(0, _members.indexOf(_selectedMembers[0]) - 1)];
			
			if (memberToSelect != null) {
				selectObject(memberToSelect);
				if (memberToSelect.selectCallback != null) memberToSelect.selectCallback();
			}
			
		}
		
		//
		//
		public function selectNext (e:MouseEvent = null):void {
	
			var memberToSelect:CollectionItem;
			
			if (_selectedMembers.length > 0) memberToSelect = _members[Math.min(_members.length - 1, _members.indexOf(_selectedMembers[0]) + 1)];
			
			if (memberToSelect != null) {
				selectObject(memberToSelect);
				if (memberToSelect.selectCallback != null) memberToSelect.selectCallback();
			}
			
		}
		
		//
		//
		public function trackDraggedItem (e:Event):void {
			//trace("item dragged");
			startDrag(e);
		}
		
		//
		//
		public function endTrackDraggedItem (e:Event):void {
			//trace("item dropped");
			stopDrag(e);
		}
		
		//
		//
		//
		override protected function startDrag (e:Event):void {
			
			var pt:Point;
			
			if (_isDragging) return;
			if (sourceCollection == this) dispatchEvent(new Event(EVENT_DRAG));
			else deselectObjects();
			
			destCollection = null;
			
			mainStage.addEventListener(MouseEvent.MOUSE_MOVE, dragFollow, false, 0, true);
			if (allowRearrange) mainStage.addEventListener(Event.ENTER_FRAME, checkHover, false, 0, true);
			
			_isDragging = true;
			_mouseXold = _mc.mouseX;
			_mouseYold = _mc.mouseY;
			
			membersMouseEnabled = false;
			
			var member:CollectionItem;
			
			if (sourceCollection == this) {
				
				if (allowRemoveOnDrag || useRotateEffectOnDrag) {
					
					if (mainStage.getChildIndex(dragContainer) < mainStage.numChildren - 1) mainStage.setChildIndex(dragContainer, mainStage.numChildren - 1);
					
					pt = new Point(0, 0);
					pt = _childrenContainer.localToGlobal(pt);

					dragContainer.x = pt.x;
					dragContainer.y = pt.y;
					dragContainer.scaleX = _childrenContainer.scaleX;
					dragContainer.scaleY = _childrenContainer.scaleY;

					for (var i:int = _selectedMembers.length - 1; i >= 0; i--) {
						
						member = _selectedMembers[i];
						if (useRotateEffectOnDrag) member.rotation = 10 - Math.random() * 20;
						dragContainer.addChild(member.mc);
						member.isDragging = true;
						
					}
					
				} else {
					
					for each (member in _members) member.hide();
					for each (member in _selectedMembers) member.show();
					
					if (dragGhostSnapshot != null && dragGhostSnapshot.bitmapData != null) dragGhostSnapshot.bitmapData.dispose();
					
					dragGhostSnapshot.bitmapData = new BitmapData(Math.min(mainStage.stageWidth, _width), Math.min(mainStage.stageHeight, _height), true, 0x00000000);
					
					pt = new Point(0, 0);
					pt = _mc.globalToLocal(pt);
					pt.x = Math.max(0, pt.x);
					pt.y = Math.max(0, pt.y);
					
					var m:Matrix = new Matrix(1, 0, 0, 1, 0 - pt.x, 0 - pt.y);
					var cr:Rectangle = new Rectangle(0, 0, Math.min(mainStage.stageWidth, _width), Math.min(mainStage.stageHeight, _height));
					
					dragGhostSnapshot.bitmapData.draw(_mc, m, new ColorTransform(), null, cr);
					dragGhost.visible = true;
					dragGhost.alpha = 0.5;
					dragGhost.x = dragContainer.mouseX;
					dragGhost.y = dragContainer.mouseY;
					dragGhostSnapshot.x = 0 - _mc.mouseX + pt.x;
					dragGhostSnapshot.y = 0 - _mc.mouseY + pt.y;
					
					for each (member in _members) member.show();
					
				}
			
			}
			
		}
		
		//
		//
		//
		override protected function stopDrag (e:Event):void {
			
			dropPoint.x = _mc.mouseX;
			dropPoint.y = _mc.mouseY;
			dropPoint = _mc.localToGlobal(dropPoint);
			
			if (sourceCollection == this) dispatchEvent(new Event(EVENT_DROP));
			
			mainStage.removeEventListener(MouseEvent.MOUSE_MOVE, dragFollow);
			mainStage.removeEventListener(Event.ENTER_FRAME, checkHover);
			
			if (allowRemoveOnDrag || useRotateEffectOnDrag) {
				
				for each (var member:CollectionItem in _selectedMembers) {
					
					_childrenContainer.addChild(member.mc);
					member.isDragging = false;
					
				}
				
			} else {
				
				if (dragGhostSnapshot != null && dragGhostSnapshot.bitmapData != null) dragGhostSnapshot.bitmapData.dispose();
				dragGhost.visible = false;
				
			}
			
			membersMouseEnabled = true;
			
			if (_isDragging) {
				
				_isDragging = false;
				
				if (allowRearrange && _mc.mouseX > -10 && _mc.mouseY > -10 && 
					_mc.mouseX - 10 < width && _mc.mouseY - 10 < height) {

					var newIndex:Number = getIndexFromPosition(_childrenContainer.mouseX, _childrenContainer.mouseY);
					
					placeSelectionAt(newIndex);
					
				} else {
					
					arrange();
					
				}

			}
			
			markerContainer.graphics.clear();
			
		}
		

		//
		//
		protected function dragFollow (e:MouseEvent):void {
			
			if (_selectedMembers.length > 0) {
				
				if (allowRemoveOnDrag || useRotateEffectOnDrag) {
					
					for (var i:Number = 0; i < _selectedMembers.length; i++) {
						if (useRotateEffectOnDrag) {
							CollectionItem(_selectedMembers[i]).x = dragContainer.mouseX + Math.sin(i) * ((_selectedMembers.length - i) * 5) - _memberWidth / 2;
							CollectionItem(_selectedMembers[i]).y = dragContainer.mouseY + Math.cos(i) * ((_selectedMembers.length - i) * 5) - _memberHeight / 2;
						} else {
							CollectionItem(_selectedMembers[i]).x = dragContainer.mouseX + i * 10 - _memberWidth / 2;
							CollectionItem(_selectedMembers[i]).y = dragContainer.mouseY + i * 10 - _memberHeight / 2;
						}
					}
				
				} else {
					
					dragGhost.x = dragContainer.mouseX;
					dragGhost.y = dragContainer.mouseY;
					
				}
			
			}
			
			if (allowRearrange) drawPlacementMarker();
			
			dropPoint.x = _mc.mouseX;
			dropPoint.y = _mc.mouseY;
			dropPoint = _mc.localToGlobal(dropPoint);
			dispatchEvent(new Event(Component.EVENT_MOVE));
			
		}
		
		//
		//
		protected function drawPlacementMarker ():void {
			
			if (_mc.mouseX > -10 && _mc.mouseX < width - 10 && _mc.mouseY > -10 && _mc.mouseY - 10 < height) {
				
				destCollection = this;
				
				markerContainer.x = _childrenContainer.x;
				markerContainer.y = _childrenContainer.y;
				
				var g:Graphics = markerContainer.graphics;
				
				g.clear();
				
				if (_members.length <= 1) return;
				
				g.beginFill(_style.linkColor, 1);
				
				var pos:int = getIndexFromPosition(_childrenContainer.mouseX, _childrenContainer.mouseY);
				
				var xpos:int = 0;
				var ypos:int = 0;
				
				if (autoResize) {
					xpos = (_memberWidth + _spacing) * (pos % _rowLength) - (_totalWidth / 2 + _memberWidth / 2 + _spacing / 2);
					ypos = (_memberHeight + _spacing) * Math.floor(pos / _rowLength) - (_totalHeight / 2 + _memberHeight / 2 + _spacing);
				} else if (_wrap) {
					xpos = (pos % _rowLength) * (_memberWidth + _spacing) - 1;
					ypos = Math.floor(pos / _rowLength) * (_memberHeight + _spacing);
				} else {
					xpos = pos * (_memberWidth + _spacing * 2) - 1;
				}
				
				if (autoResize || _wrap) {
					
					if (ypos > (pos % _rowLength) * (_memberWidth + _spacing * 2)) {
						
						xpos += _rowLength * (_memberWidth + _spacing);
						ypos -= _memberHeight + _spacing;
						
					} else if (pos % _rowLength == 0 && pos > 0) {
						
						var xpos2:int = xpos + _rowLength * (_memberWidth + _spacing);
						var ypos2:int = ypos - _memberHeight - _spacing;
						var pt1:Point = new Point(xpos - _childrenContainer.mouseX, ypos - _childrenContainer.mouseY);
						var pt2:Point = new Point(xpos2 - _childrenContainer.mouseX, ypos2 - _childrenContainer.mouseY);
						
						if (Math.abs(pt1.length) > Math.abs(pt2.length)) {
							xpos = xpos2;
							ypos = ypos2;
						}
						
					}
				}
				
				if (_rowLength <= 1) {
					xpos = 0;
					ypos = pos * (_memberHeight + _spacing);
				}
					
				if (_members.length > 0 && _members[0] is CollectionItem) {
					xpos += CollectionItem(_members[0]).position.margin_left;
					if (_rowLength > 1) xpos -= _spacing / 2;
				}
				
				g.beginFill(useBorderColorOnHighlight ? _style.borderColor : _style.highlightTextColor);

				if (_rowLength == 1 && _wrap) g.drawRect(xpos, ypos - 1, _memberWidth, 2);
				else g.drawRect(xpos, ypos + (_spacing / 2), 2, _memberHeight);
				
				destIndex = pos;
			
			} else if (destCollection == this) {
				
				destCollection = null;
				_childrenContainer.graphics.clear();
				
			}			
			
		}
		
		//
		//
		protected function checkHover (e:Event):void {
			
			if (Math.abs(_mouseXold - _mc.mouseX) + Math.abs(_mouseYold - _mc.mouseY) < 4) {
				
				if (_wrap) {
					if (_mc.mouseY > -20 && _mc.mouseY < 20 && _mc.mouseX >= 0 && _mc.mouseX <= _width) dispatchEvent(new Event(EVENT_HOVER_START));
					if (_mc.mouseY < _height + 20 && _mc.mouseY > _height - 20 && _mc.mouseX >= 0 && _mc.mouseX <= _width) dispatchEvent(new Event(EVENT_HOVER_END));
				} else {
					if (_mc.mouseX > -20 && _mc.mouseX < 20 && _mc.mouseY >= 0 && _mc.mouseY <= _height) dispatchEvent(new Event(EVENT_HOVER_START));
					if (_mc.mouseX < _width + 20 && _mc.mouseX > _width - 20 && _mc.mouseY >= 0 && _mc.mouseY <= _height) dispatchEvent(new Event(EVENT_HOVER_END));				
				}
			
			}
			
			_mouseXold = _mc.mouseX;
			_mouseYold = _mc.mouseY;
			
		}
		
		
		/*
		--------------------------------------------------------------------------
		GENERIC SELECTION HANDLERS
		--------------------------------------------------------------------------
		*/
		
		//
		//
		protected function onSelectWindowStart (e:MouseEvent):void {
			
			if (!allowMultiSelect) return;
			
			membersMouseEnabled = false;
			
			Component.mainStage.addEventListener(MouseEvent.MOUSE_UP, onSelectWindowStop);
			Component.mainStage.addEventListener(MouseEvent.MOUSE_MOVE, onSelectWindow);
			
			selectBox.x = mainStage.mouseX;
			selectBox.y = mainStage.mouseY;
			selectBox.visible = true;
			
			_isSelecting = true;
			_selectDrag = false;
			
			onSelectWindow(e);
			
		}
		
		//
		//
		protected function onSelectWindow (e:MouseEvent):void {
			
			selectBox.scaleX = (mainStage.mouseX - selectBox.x) / 100;
			selectBox.scaleY = (mainStage.mouseY - selectBox.y) / 100;
			selectBox.visible = true;
			selectBox.alpha = (selectBox.alpha == 1) ? 0.75 : 1;
			
			_selectDrag = true;
			
			// check selection
			deselectObjects();
			
			for (var i:Number = 0; i < _members.length; i++) {
				if (CollectionItem(_members[i]).clip != null) {
					if (selectBox.hitTestObject(CollectionItem(_members[i]).clip)) {
						selectObject(_members[i]);
					}
				} else {
					if (selectBox.hitTestObject(CollectionItem(_members[i]).mc)) {
						selectObject(_members[i]);
					}					
				}
			}

			
		}
		
		//
		//
		protected function onSelectWindowStop (e:MouseEvent):void {
			
			for each (var child:Component in childNodes) child.mouseEnabled = true;
			
			Component.mainStage.removeEventListener(MouseEvent.MOUSE_MOVE, onSelectWindow);
			Component.mainStage.removeEventListener(MouseEvent.MOUSE_UP, onSelectWindowStop);
			
			selectBox.width = selectBox.height = 100;
			selectBox.visible = false;
			
			_isSelecting = true;
			_selectDrag = false;
			
			setSelectionStartIndex();
			dispatchEvent(new Event(EVENT_SELECT));
			
		}

		//
		//
		//
		public function placeSelectionAt (newIndex:Number, snap:Boolean = false):void {
			
			var i:int;
			
			if (_selectedMembers.length == _members.length) {
				_selectedMembers.reverse();
			}
			
			var spliceBuffer:Array = [];
			
			for (i = 0; i < _selectedMembers.length; i++) {
				// trace("splicing member " + _members.indexOf(_selectedMembers[i]));
				var idx:int = _members.indexOf(_selectedMembers[i]);
				if (idx < newIndex) {
					newIndex--;
				}
				spliceBuffer.push(splice(idx, 1, null, true));
			}
			
			if (newIndex > _members.length) newIndex = _members.length;
			newIndex = Math.max(newIndex, 0);
			
			for (i = 0; i < spliceBuffer.length; i++) {
				splice(newIndex, 0, spliceBuffer[i], true);
				newIndex++;
			}
			
			arrange(snap);
			
		}
		
		//
		//
		// ORDER is compare function for Sorting Shots
		protected function selectionOrder (a:CollectionItem, b:CollectionItem):Number {
			
			var n1:int = _members.indexOf(a);
			var n2:int = _members.indexOf(b);
			if (n1 < n2) {
				return -1;
			} else if (n1 > n2) {
				return 1;
			} else {
				return 0;
			}
			
		}

		
		//
		//
		// SELECTOBJECTS selects objects in range
		public function selectObjects (start:int = -1, end:int = -1):void {
			
			deselectObjects();
			
			if (_members.length > 0) {
				
				if (start == -1) {
					start = 0;
					if (end == -1) end = _members.length - 1;
				}
				
				if (end == -1) end = start;

				//trace("selection start is " + start + " end is " + end);
				
				for (var i:Number = start; i <= end; i++) {
					//trace("selecting object " + i);
					_selectedMembers.push(_members[i]);
					if (_members[i] is CollectionItem) CollectionItem(_members[i]).select();
				}
				
				//_members[i-1].select();
				
			}
			
			if (selectedCollection != null && selectedCollection != this) selectedCollection.deselectObjects();
			selectedCollection = this;
			
			setSelectionStartIndex();
			dispatchEvent(new Event(EVENT_SELECT));
			
		}

		
		//
		//
		// DESELECTOBJECTS deselects objects in range
		public function deselectObjects (start:int = -1, end:int = -1):void {
			
			if (!allowDelete) return;
			
			if (_selectedMembers.length > 0) {
				
				if (start == -1) {
					start = 0;
					if (end == -1) {
						end = _selectedMembers.length - 1;
						// trace("END IS " + end);
					}
				}
				
				if (end == -1) {
					end = start;
				}
				
				//trace("deselection start is " + start + " end is " + end);
				
				for (var i:Number = start; i <= end; i++) {
					//trace("deselecting object " + i);
					if (_selectedMembers[i] is CollectionItem) CollectionItem(_selectedMembers[i]).deselect();
				}
				
				// trace("splicing from " + start + ", " + ((end + 1) - start) + " objects");
				
				_selectedMembers.splice(start, (end + 1) - start);
			
			}
			
			setSelectionStartIndex();
			dispatchEvent(new Event(EVENT_SELECT));
				
		}

		
		//
		//
		// SELECTOBJECT sets the object to active, and deactivates current active object
		public function selectObject (member:CollectionItem):void {
			
			var start:int;
			var end:int;

			// if no object reference provided, select all shots
			if (member == null && CollectionItem(_members[0].multiselect)) {
				
				selectObjects();
				
			} else {
				
				if (Key.shiftKey && allowMultiSelect) {
					
					if (_selectedMembers.length > 0) {
						start = _members.indexOf(_selectedMembers[0]);
					} else {
						start = _members.indexOf(member);
					}
					
					end = _members.indexOf(member);
					
					if (start < end) {
						selectObjects(start, end);
					} else {
						selectObjects(end, start);
					}
					
					member.select();
					
				} else if ((Key.ctrlKey || _selectDrag) && allowMultiSelect) {
					
					if (member.selected) {

						for (var i:int = 0; i < _selectedMembers.length; i++) {
							if (_selectedMembers[i] == member) {
								// trace("splicing " + member);
								_selectedMembers.splice(i,1);
							}
						}

						member.deselect();
						
					} else {
						
						_selectedMembers.push(member);
						member.select();
						
					}
					
				} else {
					
					if (member.selected) {

						deselectObjects();
						
					} else {
						
						selectObjects(_members.indexOf(member));
						
					}
					
				}
				
			}
			// trace("selection length is " + _selectedMembers.length);
			_selectedMembers.sort(selectionOrder);
			
			if (selectedCollection != null && selectedCollection != this) selectedCollection.deselectObjects();
			selectedCollection = this;
			
			setSelectionStartIndex();
			
			if (!_isSelecting) {
				dispatchEvent(new Event(EVENT_SELECT));
			}

		}
		
		protected function setSelectionStartIndex ():void {
			
			_selectionIndex = (_selectedMembers.length > 0) ? _members.indexOf(_selectedMembers[0]) : -1;
			
		}
		
		//
		//
		//
		public function deleteSelectedObjects ():void {
			
			var references:Array = []
			
			for (var i:int = 0; i < _selectedMembers.length; i++) {
				references.push(CollectionItem(_selectedMembers[i]).reference);
			}
			
			removeMembers(_selectedMembers.concat());
			
			_selectedMembers = [];
			
			dispatchEvent(new ObjectEvent(EVENT_DELETE, false, false, references));
			dispatchEvent(new Event(EVENT_LIST_CHANGE));
			
			setSelectionStartIndex();
			dispatchEvent(new Event(EVENT_SELECT));
		
		}
		
		//
		//
		protected function onMasterAdd (e:ObjectEvent):void {

			if (getItem(e.relatedObject) == null) addMembers([e.relatedObject]);
			
		}
		
		//
		//
		protected function onMasterChange (e:Event = null):void {
			
			for (var i:int = 0; i < _masterCollection.members.length; i++) {
				
				var ref:Object = CollectionItem(_masterCollection.members[i]).reference;
				
				if (ref != null) {
					
					var member:CollectionItem = getItem(ref);
					
					if (member != null) {
						member.idx = i;
					} else {
						member = addMember(ref);
						member.idx = i;
					}
					
				}
				
			}
			
			_members.sortOn("idx", Array.NUMERIC);
			
			arrange();
			
		}
		
		//
		//
		protected function onMasterDelete (e:ObjectEvent):void {
			
			var members:Array = [];
			
			for each (var ref:Object in e.relatedObject) {
				
				var member:CollectionItem = getItem(ref);
				
				if (member != null) members.push(member);
				
			}
			
			if (members.length > 0) removeMembers(members);
			
		}
		
		//
		//
		protected function onMasterRestore (e:ObjectEvent):void {
			
			restoreMembers();
			
		}
		
		//
		//
		protected function onMasterClear (e:Event):void {
			
			clear();
			
		}

		//
		//
		public function prevPage (e:Event):void {
		
			if (usePagingDisplay) {
				
				if (_currentPage > 1) {
					
					_currentPage--;
					_pageX = 0 - _pageWidth * (_currentPage - 1);
					startTween();
					
				}
				
			}
			
		}
		
		//
		//
		public function nextPage (e:Event):void {
			
			if (usePagingDisplay) {
				
				if (_currentPage < totalPages) {
					
					_currentPage++;
					_pageX = 0 - _pageWidth * (_currentPage - 1);
					startTween();
					
				}
				
			}
			
		}
		
		//
		//
		public function gotoPage (pageNum:int):void {
			
			if (usePagingDisplay) {

				if (pageNum > 0 && pageNum <= totalPages) {

					_currentPage = pageNum;
					_pageX = 0 - _pageWidth * (pageNum - 1);
					startTween();
					
				}
			
			}

		}
		
		//
		//
		public function gotoItemPage (member:CollectionItem):void {
			
			if (usePagingDisplay && member != null) {
				
				var idx:int = _members.indexOf(member);
					
				if (idx >= 0) {
					
					var page:int = idx / _itemsPerPage + 1;
					gotoPage(page);
					
				}
			
			}
			
		}
		
		//
		//
		protected function startTween ():void {
			
			if (!_isTweening) {
				mainStage.addEventListener(Event.ENTER_FRAME, tween);
				_isTweening = true;
			}
			
		}
		
		//
		//
		protected function tween (e:Event):void {
			
			if (_deleted) {
				stopTween();
				return;
			}
			
			_childrenContainer.x += (_pageX - _childrenContainer.x) / _tweenRate;

			if (Math.abs(_pageX - _childrenContainer.x) < 1) {
				_childrenContainer.x = _pageX;
				stopTween();
			}
	
		}

		//
		//
		protected function stopTween ():void {
			
			mainStage.removeEventListener(Event.ENTER_FRAME, tween);
			_isTweening = false;
			
		}
		
		
		//
		//
		override public function clear():void {
			
			super.clear();
			_members = [];
			_selectedMembers = [];
			clipboard = [];
			
			dispatchEvent(new Event(EVENT_CLEAR));
			dispatchEvent(new Event(EVENT_LIST_CHANGE));
		
		}

		//
		//
		override public function destroy():Boolean {
			
			return super.destroy();
			
			if (masterCollection != null) masterCollection = null;
			if (sourceCollection == this) sourceCollection = null;
			if (destCollection == this) destCollection = null;
			
			_backgroundButton.removeEventListener(MouseEvent.MOUSE_DOWN, onSelectWindowStart);
			mainStage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			
		}
		
	}
	
}