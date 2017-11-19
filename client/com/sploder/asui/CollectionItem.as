package com.sploder.asui {
	
	import com.sploder.asui.*;
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	
	/**
	 * ...
	 * @author ...
	 */
	public class CollectionItem extends Cell {
		
		protected var _oldx:Number = 0;
		protected var _oldy:Number = 0;
		protected var _oldz:Number = 0;
		protected var _oldr:Number = 0;
		
		protected var _newx:Number = 0;
		protected var _newy:Number = 0;
		protected var _newz:Number = 0;
		protected var _newr:Number = 0;
		
		protected var _dragx:Number = 0;
		protected var _dragy:Number = 0;
		
		override public function get x ():Number { return (_isDragging && _collection.allowRemoveOnDrag) ? _dragx : _newx; }
		override public function set x (val:Number):void {
			
			if (!_deleted) {
				_oldx = _mc.x;
				_newx = val;
				startTween();
			}
			
		}
		
		override public function get y ():Number { return (_isDragging && _collection.allowRemoveOnDrag) ? _dragy : _newy; }
		override public function set y (val:Number):void {
			
			if (!_deleted) {
				_oldy = _mc.y;
				_newy = val;
				startTween();
			}
			
		}
		
		override public function get rotation ():Number { return _newr; }
		override public function set rotation (val:Number):void {
			
			if (!_deleted) {
				_oldr = _mc.rotation;
				_newr = val;
				startTween();
			}
	
		}
		
        private var _alt:String = "";
        public function get alt ():String { return _alt; }
        public function set alt (value:String):void { _alt = value; }
        
		protected var _collection:Collection;
		public function get collection():Collection { return _collection; }

		protected var _selected:Boolean = false;
		public function get selected():Boolean { return _selected; }
		public function set selected(value:Boolean):void 
		{
			_selected = value;
			updateClip();
		}
		
		protected var _justSelected:Boolean = false;
		
		protected var _backing:Sprite;
		protected var _highlight:Sprite;
    
        protected var _altTimes:int = 0;
		
		protected var _pressX:Number = 0;
		protected var _pressY:Number = 0;
		
		protected var _isDragging:Boolean = false;
		public function get isDragging():Boolean { return _isDragging; }
		public function set isDragging(value:Boolean):void { 
			_isDragging = value;
			if (_isDragging) {
				_dragx = _mc.x;
				_dragy = _mc.y;
			}
		}
		
		protected var _isTweening:Boolean = false;
		protected var _tweenRate:Number = 3;
		
		protected var _clipContainer:Container;
		
		public function get clip():DisplayObject { return _clipContainer.clip; }
		
		public function set clip(obj:DisplayObject):void {
			
			_clipContainer.clip = obj;
			
			if (_clipContainer.clip != null) {
				
				try {
					
					if (_clipContainer.clip["btn"] is SimpleButton) {
						
						connectSimpleButton(_clipContainer.clip["btn"], true, true);
						
						if (_backing != null) {
							_backing.parent.removeChild(_backing);
							_backing = null;
						}
						
					}
					
					if (_clipContainer.clip["highlight"] != null) {
						
						if (_highlight != null && _highlight.parent != null) _highlight.parent.removeChild(_highlight);
						_highlight = _clipContainer.clip["highlight"];
						_highlight.alpha = 0;
						
					}
				
				} catch (e:Error) {
					
					if (_clipContainer.clip is Sprite) {
						Sprite(_clipContainer.clip).mouseEnabled = false;
						Sprite(_clipContainer.clip).mouseChildren = false;
						_clipContainer.mc.mouseEnabled = _clipContainer.mc.mouseChildren = false;
						_clipContainer.mc.parent.mouseEnabled = false;
					}
					
				}
				
			}
			
			if (_clipContainer.clip.width < _width) _clipContainer.clip.x = Math.floor((_width - _clipContainer.clip.width) / 2);
			if (_clipContainer.clip.height < _height) _clipContainer.clip.y = Math.floor((_height - _clipContainer.clip.height) / 2);
			
		}
		
		public var selectCallback:Function;
		public var activateCallback:Function;
		
		protected var _reference:Object;
		
		public function get reference():Object { return _reference; }
		
		public function set reference(value:Object):void {
			
			_reference = value;

		}
		
		public var idx:int = 0;

		//
		//
		public function CollectionItem (collection:Collection, reference:Object, width:Number, height:Number, position:Position = null, style:Style = null) {
            
            init_CollectionItem (collection, reference, width, height, position, style);
            
            if (_container != null) create();
            
        }
        
        //
        //
        protected function init_CollectionItem (collection:Collection, reference:Object, width:Number, height:Number, position:Position = null, style:Style = null):void {
            
            super.init_Cell(null, width, height, false, false, 0, position, style);

			_collection = collection;
			_reference = reference;
			
			_width = (!isNaN(width)) ? width : clip.width;
			_height = (!isNaN(height)) ? height : clip.height;
			
			_type = "collectionitem";	
     
        }
		
        //
        //
        override public function create ():void {
            
            super.create();
			
			_clipContainer = new Container(null);
			addChild(_clipContainer);

            var backingStyle:Style = _style.clone();
            backingStyle.border = false;
			backingStyle.background = false;
            backingStyle.round = 0;
            
            _backing = new Sprite();
			//DrawingMethods.rect(_backing, true, 0, 0, _width, _height, 0xffffff, 0.2);
			var bgc:Array;
			var bga:Array;
			var bgr:Array;
			if (_style.background) {
				if (_style.bgGradient) {
					bgc = _style.bgGradientColors;
					bgr = _style.bgGradientRatios;
				} else {
					bgc = [_style.backgroundColor];
					bga = [_style.backgroundAlpha];
				}
			} else {
				bgc = [0xffffff];
				bga = [0.2];
			}
			DrawingMethods.roundedRect(_backing, true, 0, 0, _width, _height, "" + _style.round, 
			bgc, bga, bgr, null);  
			
			var bw:Number = Math.max(2, Math.floor(_style.borderWidth / 2));
			
			if (_style.border && _style.borderWidth > 0) {
				DrawingMethods.roundedRect(_backing, false, bw / 2, bw / 2, _width - bw, _height - bw, "" + (_style.round - 1), [0], [0], null, null, _style.borderWidth, _style.borderColor, 0.5);	
			}

			connectButton(_backing, true);
			_mc.addChild(_backing);
			_mc.setChildIndex(_backing, 0);

			if (_collection.showHighlight) {
				_highlight = new Sprite();
				//DrawingMethods.emptyRect(_highlight, true, 0, 0, _width, _height, Math.max(2, Math.floor(_style.borderWidth / 2)), (_collection.useBorderColorOnHighlight) ? _style.borderColor : _style.highlightTextColor, 0.5);
				DrawingMethods.roundedRect(_highlight, true, bw / 2, bw / 2, _width - bw, _height - bw, "" + (_style.round - 1), [0], [0], null, null, _style.borderWidth, (_collection.useBorderColorOnHighlight) ? _style.borderColor : _style.highlightTextColor, 1);
				_highlight.alpha = 0;
				_highlight.mouseEnabled = false;
				_mc.addChild(_highlight);
			}
			
			if (_reference is DisplayObject) {
				
				clip = DisplayObject(_reference);
				
			} else if (_collection.defaultItemComponent) {
				
				_childrenContainer.mouseEnabled = false;
				
				var ref:String = "";
				var icon:String = "";
				var link:String = "";
				if (_reference is String) ref = icon = String(_reference);
				else if (_reference && _reference.title) ref = _reference.title;
				
				_value = ref.toLowerCase().split(" ").join("_");
				if  (_reference.value) _value = _reference.value;
				
				if (_reference && _reference.icon) {
					icon = _reference.icon;
				}
				
				if (_reference && _reference.link) {
					link = _reference.link
				}
				
				switch (_collection.defaultItemComponent) {
					
					case "HTMLField":
					
						var hh:HTMLField = new HTMLField(null, 
							"<p>" + ref + "</p>", 
							_width - _style.padding * 2, 
							false, 
							null, 
							_style);
						addChild(hh);
						hh.x = _style.padding;
						hh.y = _style.padding;
						hh.mouseEnabled = false;
						break;
						
					case "BButton":
					
						var bb:BButton = new BButton(null, 
							ref, 
							Position.ALIGN_LEFT, 
							_width, 
							_height, 
							false, false, false, 
							null,
							_style);
						addChild(bb);
						bb.mouseEnabled = false;
						break;
						
					case "Clip":
					
						var cc:Clip;
						var hh2:HTMLField;
						
						if (_height < _width * 0.75) {
							
							cc = new Clip(null, 
								icon, 
								Clip.EMBED_SMART, 
								Math.min(_width, _height) - _style.padding * 2, 
								Math.min(_width, _height) - _style.padding * 2, 
								Clip.SCALEMODE_FIT, "", false, "", null, _style);
							cc.forceCentered = true;
							if (icon.indexOf("/") != -1) cc.forceBorder = true;
							addChild(cc);
							cc.x = Math.min(_width, _height) / 2;
							cc.y = _height / 2;
							cc.mouseEnabled = false;
							if (ref != icon) {
									hh2 = new HTMLField(null, 
									"<p>" + ref + "</p>", 
									_width - _style.padding * 2, 
									false, 
									null, 
									_style);
								addChild(hh2);
								hh2.x = _style.padding + cc.width / 2 + cc.x;
								hh2.y = cc.y - hh2.height / 2;
								hh2.mouseEnabled = false;
							}
							if (link && link.length > 0) {
								var lb:BButton = new BButton(null, 
									(_reference.credit) ? {text: _reference.credit, icon: Create.ICON_LAUNCH, first: "false"} : Create.ICON_LAUNCH, 
									-1, NaN, 20, false, false, false, 
									new Position( { placement: Position.PLACEMENT_ABSOLUTE} ),
									_style.clone( { background: false, border: 0 } ));
								if (_reference.credit) lb.extraWidth = 5;
								addChild(lb);
								lb.x = _width - _style.padding - lb.width - _style.borderWidth;
								lb.y = _height / 2 - lb.mc.height / 2;
								lb.addEventListener(Component.EVENT_CLICK, function (e:Event):void {
									var urlReq:URLRequest = new URLRequest(link);
									navigateToURL(urlReq, "_blank");
								});
								
							}
							
						} else {
							
							cc = new Clip(null, 
								icon, 
								Clip.EMBED_SMART, 
								_height - _style.padding * 2 - 20, 
								_height - _style.padding * 2 - 20, 
								Clip.SCALEMODE_FIT, "", false, "", null, _style);
							addChild(cc);
							cc.x = _width / 2;
							cc.y = _height / 2 - 8;
							cc.mouseEnabled = false;
							if (ref != icon) {
									hh2 = new HTMLField(null, 
									"<p align=\"center\">" + ref + "</p>", 
									_width, 
									false, 
									null, 
									_style);
								addChild(hh2);
								hh2.x = 0;
								hh2.y = 6 + _height - hh2.height - _style.padding;
								hh2.mouseEnabled = false;
							}	
							
						}
						
						break;
							
				}
				
			}
			
			dispatchEvent(new Event(EVENT_CREATE));
    
        }
		
		//
		//
		protected function updateClip ():void {
			if (_highlight != null) _highlight.alpha = (selected) ? 1 : 0;
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
			
			_mc.x += (_newx - _mc.x) / _tweenRate;
			_mc.y += (_newy - _mc.y) / _tweenRate;
			_mc.rotation += (_newr - _mc.rotation) / _tweenRate;
			
			if (Math.abs(_newx - _mc.x) < 1 && Math.abs(_newy - _mc.y) < 1) {
				_mc.x = _newx;
				_mc.y = _newy;
				_mc.rotation = _newr;
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
		public function moveTo (newx:Number, newy:Number):void {
			
			x = newx;
			y = newy;
			
		}
		
		//
		//
		public function snapToPosition ():void {
			
			_mc.x = _newx;
			_mc.y = _newy;
			_mc.rotation = _newr;
			
		}
		
		//
		//
		//
		public function select ():void {
			selected = true;
			if (_highlight != null) _highlight.alpha = 1;
			active = true;
			if (selectCallback != null) selectCallback.call();
			_tweenRate = 1.5;
		}
		
		//
		//
		//
		public function deselect ():void {
			selected = false;
			if (_highlight != null) _highlight.alpha = 0;
			active = false;
			_tweenRate = 3;
		}
			
		//
		//
		override protected function onPress (e:MouseEvent = null):void {
	
			_pressX = _mc.mouseX;
			_pressY = _mc.mouseY;
			
			if (!deleted && !selected) {
				_collection.selectObject(this);
				_justSelected = true;
			}
				
			// onPress doesn't always fire - found this fix
			_mc.focusRect = false;
			mainStage.focus = _mc;
			
			mainStage.addEventListener(MouseEvent.MOUSE_MOVE, onDrag, false, 0, true);
			mainStage.addEventListener(MouseEvent.MOUSE_UP, onRelease, false, 0, true);
	
		}
		
		//
		//
		protected function onDrag (e:Event):void {
			
			if (_collection.allowDrag) {
				
				if (Math.abs(_mc.mouseX - _pressX) > 10 || Math.abs(_mc.mouseY - _pressY) > 10) {
					
					mainStage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
					Collection.sourceCollection = _collection;
					dispatchEvent(new Event(EVENT_DRAG));
					_isDragging = true;
					if (_collection.allowRemoveOnDrag) _mc.startDrag();
					
				}
			
			}

		}
		
		//
		//
		override protected function onRelease (e:MouseEvent = null):void {
			
			mainStage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
			mainStage.removeEventListener(MouseEvent.MOUSE_UP, onRelease);

			if (!deleted) {

				if (!_isDragging && !_justSelected) _collection.selectObject(this);

				_justSelected = false;
				
			}
			
			if (_isDragging) {
				if (_collection.allowRemoveOnDrag) _mc.stopDrag();
				_isDragging = false;
				dispatchEvent(new Event(EVENT_DROP));
				dispatchEvent(new Event(EVENT_CHANGE));
			}
			
			dispatchEvent(new Event(EVENT_RELEASE));
			
		}
		
		//
		//
		protected function onItemClick (e:Event):void {
			dispatchEvent(new Event(EVENT_CLICK));
		}
		
        //
        //
        override protected function onRollOver(e:MouseEvent = null):void {
			
			super.onRollOver(e);

			_altTimes++;
			
			if (!selected && _highlight != null) _highlight.alpha = 0.4;
			
            if (_alt.length > 0 && _altTimes <= 7) Tagtip.showTag(_alt);
    
        }
        
        //
        //
        override protected function onRollOut(e:MouseEvent = null):void 
		{
			super.onRollOut(e);
			
			if (!selected && _highlight != null) _highlight.alpha = 0;
  
            Tagtip.hideTag();
            
        }
		
	}
	
}