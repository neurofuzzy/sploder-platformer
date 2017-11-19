package com.sploder.builder {
	
	import com.sploder.builder.*;
	import com.sploder.builder.CreatorFactory;
	import com.sploder.geom.Geom2d;
	import com.sploder.texturegen_internal.TextureAttributes;
	import com.sploder.texturegen_internal.TextureRendering;
	import com.sploder.util.Cleanser;
	import com.sploder.util.Textures;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	

    
    public class CreatorPlayfieldObject extends MovieClip {
		private var border:int;

        public var _playfield:CreatorPlayfield;
        public var playfield:CreatorPlayfield;
        
        public var id:uint;
		public var type:String = "";
        public var unique:Boolean = false;
		public var uniquegroup:Array;

		public var tile:Boolean = false;
		public var tileID:int = 0;
		public var tileRotation:int = 0;
		public var stampName:String;
		public var tileBack:Boolean = false;
		public var tileDefID:String = "";
		public var tileScale:int = 1;
		public var lastTileUpdate:int = 0;
		
		public var graphic:int = 0;
		public var graphic_animation:int = 0;
		public var graphic_version:int = 0;
		public var keepSymbolWithGraphic:Boolean;
		
		public var textureAttribs:TextureAttributes;
		
		protected var _lastTileMap:Array;
		protected var _lastAttribs:String;

		public var originalWidth:Number = 0;
		public var originalHeight:Number = 0;
		public var boundsWidth:Number = 0;
		public var boundsHeight:Number = 0;
		public var graphicWidth:Number = 0;
		public var graphicHeight:Number = 0;
		
		protected var _rotatable:Boolean = false;
		public function get rotatable():Boolean { return _rotatable; }
		
		protected var _limitRotate:Boolean = false;
		public function get limitRotate():Boolean { return _limitRotate; }
		
		override public function get rotation():Number { return super.rotation; }
		
		override public function set rotation(value:Number):void 
		{
			super.rotation = value;
			if (_editButton != null) _editButton.rotation = 0 - rotation;
		}
		
		protected var _permanent:Boolean = false;
		public function get permanent():Boolean { return _permanent; }
		
		protected var _textEntry:Boolean = false;
		public function get textEntry():Boolean { return _textEntry; }
		
		protected var _textField:TextField;
		protected var _linkPrompt:MovieClip;

		public var dataArray:Array;
		
		public var zz:int = 0;
		
		protected var _selectable:Boolean = true;
		public function get selectable():Boolean { return _selectable; }
		public function set selectable(value:Boolean):void 
		{
			_selectable = value;
			if (_symbolClip is Sprite) {
				Sprite(_symbolClip).mouseEnabled = _selectable;
			}
		}

        public var radius:Number = 0;
        
        public var btn:SimpleButton;

        public var validIcon:MovieClip;
        public var dropValid:Boolean = false;
        public var canHaveGraphic:Boolean = false;
        
        public var handles:MovieClip;

        public var boundsMC:MovieClip;
        public var edgesMC:MovieClip;
        
        public var _lastx:Number = 0;
        public var _lasty:Number = 0;
		public var _lastMouseX:Number = 0;
		public var _lastMouseY:Number = 0;
    
		protected var _controlClip:Sprite;
		protected var _rotator:SimpleButton;
		protected var _editButton:SimpleButton;
		protected var _avatarButton:SimpleButton;
		protected var _avatarEditable:Boolean;
		protected var _dragger:MovieClip;
		protected var _draggerButton:SimpleButton;
		protected var _hasDragger:Boolean = false;
		protected var _symbolClip:DisplayObject;
		
		public function get mc ():MovieClip {
			
			if (_symbolClip is MovieClip) return MovieClip(_symbolClip);
			
			return null;
			
		}
		
		public function get symbolClip():DisplayObject 
		{
			return _symbolClip;
		}

		protected var _selected:Boolean = false;
		protected var _dragging:Boolean = false;
		protected var _rotating:Boolean = false;
		protected var _draggerDragging:Boolean = false;
		
		public var snap:Boolean = true;
		

        //
        //
        //
        public function CreatorPlayfieldObject (playfield:CreatorPlayfield, symbolClip:DisplayObject, id:int, x:Number = 0, y:Number = 0, z:int = 0, rotation:Number = 0, tileID:int = 0, data:Array = null, graphic:int = 0, graphic_version:int = 0, graphic_animation:int = 0) {
            
            super();
            init(playfield, symbolClip, id, x, y, z, rotation, tileID, data, graphic, graphic_version, graphic_animation);
            
        }
    
        //
        //
        //
        protected function init (playfield:CreatorPlayfield, symbolClip:DisplayObject, id:int, x:Number = 0, y:Number = 0, z:int = 0, rotation:Number = 0, tileID:int = 0, data:Array = null, graphic:int = 0, graphic_version:int = 0, graphic_animation:int = 0):void {
            
            _playfield = playfield;
			
			this.id = id;
			this.type = CreatorFactory.getObjType(id + "");
			
			_controlClip = Creator.UIlibrary.getDisplayObject("playfieldObjectSymbol") as Sprite;
			_rotator = MovieClip(_controlClip)["rotate"];
			_editButton = MovieClip(_controlClip)["edit"];
			_avatarButton = MovieClip(_controlClip)["avatar"];
			_symbolClip = symbolClip;
			
			_avatarEditable = (id == 1);
			_avatarButton.visible = false;
			
			if (_playfield.creator.project.version < 2) {
				_rotator.visible = false;
				_avatarEditable = false;
			}
			
			if (_symbolClip == null) {
				remove();
				return;
			}
			
			if (CreatorFactory.isTextureBlock(id + ""))
			{
				tileBack = CreatorFactory.tileBack(id + "");
				border = 0;
				if (data == null || data.length == 0) textureAttribs = new TextureAttributes().init();
				else textureAttribs = new TextureAttributes().initWithData(data[0]);
				updateTexture(_symbolClip as Bitmap, true);
				_symbolClip.x = _symbolClip.y = -60;
			}
			
			var textureScale:Number = 1;
			
			if (_symbolClip is Sprite) {

				if (Sprite(_symbolClip).getChildByName("texture") != null) {
					Sprite(_symbolClip).removeChild(Sprite(_symbolClip).getChildByName("texture"));
				}
				
				if (Sprite(_symbolClip).getChildByName("message") is TextField) {
					_textField = Sprite(_symbolClip).getChildByName("message") as TextField;
				}
				
				if (Sprite(_symbolClip).getChildByName("linkprompt") is MovieClip) {
					_linkPrompt = Sprite(_symbolClip).getChildByName("linkprompt") as MovieClip;
				}
				
			}
			
			addChild(_symbolClip);
			
			if (CreatorFactory.getLinkable(id)) {
				
				_dragger = Creator.creatorlibrary.getDisplayObject("link_creator") as MovieClip
				_controlClip.addChild(_dragger);
				
				if (_dragger["btn"] != null) _draggerButton = _dragger["btn"];
				
				if (_draggerButton != null) {
					
					_draggerButton.addEventListener(MouseEvent.MOUSE_DOWN, startDragger);
					CreatorHelp.assignButtonHelp(_draggerButton, "Click and drag to move this link onto a linkable switch.");
					_hasDragger = true;
					
				}
				
			}
			
			originalWidth = boundsWidth = _symbolClip.width;
			originalHeight = boundsHeight = _symbolClip.height;
			
			if (_symbolClip is Sprite && Sprite(_symbolClip).getChildByName("bounds")) {
				var b:Sprite = Sprite(_symbolClip).getChildByName("bounds") as Sprite;
				originalWidth = boundsWidth = b.width;
				originalHeight = boundsHeight = b.height;
			}
			
			if (_symbolClip is Sprite && Sprite(_symbolClip).getChildByName("g")) {
				var g:Sprite = Sprite(_symbolClip).getChildByName("g") as Sprite;
				if (g.width > 0) graphicWidth = g.width;
				if (g.height > 0) graphicHeight = g.height;
				canHaveGraphic = true;
				keepSymbolWithGraphic = true;
			}
			
			if (!canHaveGraphic) canHaveGraphic = CreatorFactory.getCacheAsBitmap(id + "");
			if (!canHaveGraphic && (type == "biped" || type == "mech")) canHaveGraphic = true;
			
			if (!canHaveGraphic)
			{
				var allowed_ids:Array = [20, 21, 43, 44, 45, 46, 47, 287];
				if (allowed_ids.indexOf(id) != -1) canHaveGraphic = true;
			}
			
			addChild(_controlClip);
			
			
			snap = CreatorFactory.getSnap(id + "");
			_rotatable = CreatorFactory.getRotatable(id);
			_limitRotate = CreatorFactory.getLimitRotate(id);
			_textEntry = CreatorFactory.getTextEntry(id);
			_rotator.visible = _rotatable;
			_editButton.visible = _textEntry;
			
			this.zz = z;
			this.rotation = rotation;
			
			tile = CreatorFactory.isTile(id + "");
			
			if (tile) {
				this.tileID = (tileID > 0) ? tileID : CreatorFactory.tileID(id + "");
				tileScale = CreatorFactory.tileScale(id + "");
				stampName = CreatorFactory.stampName(id + "");
				tileRotation = CreatorFactory.tileRotation(id + "");
				tileBack = CreatorFactory.tileBack(id + "");
				tileDefID = CreatorFactory.tileDefID(id + "", this.tileID, tileBack, tileScale);
				//trace("TILE ID", tileDefID, tileID, tileScale);
			}

			if (id == 1) unique = true;
			
			dataArray = data;
			
			this.graphic = graphic;
			this.graphic_version = graphic_version;
			this.graphic_animation = graphic_animation;
            
            btn = _controlClip["btn"];
			validIcon = _controlClip["valid"];
			validIcon.visible = false;
            handles = _controlClip["handles"];
			handles.visible = false;
			
			btn.doubleClickEnabled = true;
			btn.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
            btn.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			CreatorHelp.assignButtonHelp(btn, "Click to select this object");
			
            radius = (boundsWidth / 2);
            
			handles.scaleX = boundsWidth / 100;
            handles.scaleY = boundsHeight / 100;

            btn.scaleX = handles.scaleX;
			btn.scaleY = handles.scaleY;
			
			_rotator.x = originalWidth / 2 + 20;
			_rotator.y = 0 - originalHeight / 2 - 20;
			_editButton.x = _rotator.x;
			_editButton.y = 0 - _rotator.y;
			
			_playfield.selection.addEventListener(SelectionEvent.SELECT, activate);
			_playfield.selection.addEventListener(SelectionEvent.DESELECT, deactivate);
			if (_rotatable) {
				
				_rotator.addEventListener(MouseEvent.MOUSE_DOWN, startRotate);
				_rotator.addEventListener(MouseEvent.MOUSE_UP, stopRotate);
				
				CreatorHelp.assignButtonHelp(_rotator, "Click and drag to rotate this object.");
				
			}
			
			if (_textEntry) {
				
				_editButton.addEventListener(MouseEvent.CLICK, editText);
				CreatorHelp.assignButtonHelp(_editButton, "Click to edit the text message for this block.");
				if (_textField) _textField.text = getData(0);
				
			}
			
			if (_avatarEditable) {
				_avatarButton.addEventListener(MouseEvent.CLICK, editAvatar);
			}
			
			place(x, y);
			
			_playfield.selection.addEventListener(SelectionEvent.STARTDRAG, startMove);
			_playfield.selection.addEventListener(SelectionEvent.DRAG, move);
			_playfield.selection.addEventListener(SelectionEvent.STOPDRAG, stopMove);
			_playfield.selection.addEventListener(SelectionEvent.DROP, onDrop);
			_playfield.selection.addEventListener(SelectionEvent.CLONE, clone);
			
			if (!_playfield.populating) _playfield.selection.select(this);

			if (_hasDragger && dataArray != null && dataArray.length > 1) {
				
				_dragger.x = parseInt(getData(1));
				_dragger.y = 0 - parseInt(getData(2));
				
				if (!_playfield.populating) drawDraggerLine();
				
			}
			
			if (this.graphic > 0) updateGraphics();
 
        }
		
		public function getClipAsBitmap (source:Boolean = false):Bitmap {
			
			var tileMap:Array = null;	
			
			tileMap = [0, 0, 0, 0, 1, 0, 0, 0, 0];
			
			if (!_playfield.populating && !_playfield.clearing) {
				
				var neighbors:Array = _playfield.map.getNeighborsOf(this, false);
				
				var ox:int = 0;
				var oy:int = 0;
				
				var idx:int = 0;
				
				for each (var neighbor:CreatorPlayfieldObject in neighbors) {
					
					if (neighbor.tile && neighbor.tileDefID == tileDefID) {
						
						ox = (neighbor.x - x) / CreatorPlayfield.GRID_WIDTH;
						oy = (neighbor.y - y) / CreatorPlayfield.GRID_HEIGHT;
						ox /= _symbolClip.width / CreatorPlayfield.GRID_WIDTH;
						oy /= _symbolClip.height / CreatorPlayfield.GRID_HEIGHT;
						
						if (Math.abs(ox) <= 1 && Math.abs(oy) <= 1) {

							idx = 4 + (oy * 3) + ox;
							tileMap[idx] = 1;
						
						}
						
						if (source && neighbor != this) neighbor.updateClip();
						
					}
					
				}
			
			}
			
			if (_lastTileMap) {
				var res:Boolean = true;
				var i:int = _lastTileMap.length;
				while (i--) {
					if (_lastTileMap[i] != tileMap[i]) {
						res = false;
						break;
					}
				}
				if (res) {
					return _symbolClip as Bitmap;
				}
			}
			_lastTileMap = tileMap;
			return Creator.creatorlibrary.getTileAsBitmap(tileDefID, tileMap, stampName, rotation, tileBack);
			
		}
		
		
		private function updateTexture (b:Bitmap, source:Boolean = false):void {
			
			if (textureAttribs == null) return;
			
			if (dataArray == null ) dataArray = [];
			dataArray[0] = textureAttribs.serialize();
			
			if (tileBack)
			{
				Creator.creatorlibrary.updateTexture(b, textureAttribs, 120, TextureRendering.BORDER_TYPE_ALL);	
				return;
			}
			
			var tileMap:Array = null;	
			
			tileMap = [0, 0, 0, 0, 1, 0, 0, 0, 0];
			
			if (!_playfield.populating && !_playfield.clearing) {
				
				var neighbors:Array = _playfield.map.getNeighborsOf(this, false, true, null, 1);
				
				var ox:int = 0;
				var oy:int = 0;
				
				var idx:int = 0;
				
				for each (var neighbor:CreatorPlayfieldObject in neighbors) {
					
					if (neighbor.textureAttribs != null && !neighbor.tileBack) {
						
						ox = (neighbor.x - x < 0) ? Math.floor((neighbor.x - x) / 120) : Math.ceil((neighbor.x - x) / 120);
						oy = (neighbor.y - y < 0) ? Math.floor((neighbor.y - y) / 120) : Math.ceil((neighbor.y - y) / 120);
						
						
						if (Math.abs(ox) <= 1 && Math.abs(oy) <= 1)
						{
							idx = 4 + (oy * 3) + ox;
							tileMap[idx] = 1;
						}
						
						if (source && neighbor != this) neighbor.updateClip();
						
					}
					
				}
			
			}
			
			if (_lastTileMap && _lastAttribs == textureAttribs.serialize()) {
				var res:Boolean = true;
				var i:int = _lastTileMap.length;
				while (i--) {
					if (_lastTileMap[i] != tileMap[i]) {
						res = false;
						break;
					}
				}
				if (res) return;
			}
			
			_lastTileMap = tileMap;
			_lastAttribs = textureAttribs.serialize();
			
			border = TextureRendering.getBorderFromTileMap(tileMap);
			
			Creator.creatorlibrary.updateTexture(b, textureAttribs, 120, border);	
		}
		
		
		//
		//
		protected function place (x:int, y:int):void {
			
			if (rotation < 0) {
				rotation %= 360;
				rotation += 360;
			}
			if (rotation >= 360) {
				rotation %= 360;
			}
			
			if (rotation % 180 != 0) {
				boundsWidth = originalHeight;
				boundsHeight = originalWidth;
			} else {
				boundsWidth = originalWidth;
				boundsHeight = originalHeight;
			}
			
			if (snap) {
				
				var xoffset:int = (Math.floor(boundsWidth / CreatorPlayfield.GRID_WIDTH) % 2 == 1) ? CreatorPlayfield.GRID_WIDTH / 2 : 0;
				var yoffset:int = (Math.floor(boundsHeight / CreatorPlayfield.GRID_HEIGHT) % 2 == 1) ? CreatorPlayfield.GRID_HEIGHT / 2 : 0;
				
				if (xoffset == 0) this.x = Math.round(x / CreatorPlayfield.GRID_WIDTH) * CreatorPlayfield.GRID_WIDTH + xoffset;
				else this.x = Math.floor(x / CreatorPlayfield.GRID_WIDTH) * CreatorPlayfield.GRID_WIDTH + xoffset;

				if (yoffset == 0) this.y = Math.round(y / CreatorPlayfield.GRID_HEIGHT) * CreatorPlayfield.GRID_HEIGHT + yoffset;
				else this.y = Math.floor(y / CreatorPlayfield.GRID_HEIGHT) * CreatorPlayfield.GRID_HEIGHT + yoffset;
		
			} else {
				
				this.x = x;
				this.y = y;

			}

		}
		
		public function resetSymbol ():void
		{
			graphics.clear();
			graphic = graphic_animation = graphic_version = 0;
			
			var symbol:DisplayObject = CreatorFactory.createNew(id + "", null, 0, 0, 0, { tile: tileID } );
			if (symbol)
			{
				if (_symbolClip && _symbolClip.parent)
				{
					var idx:int = _symbolClip.parent.getChildIndex(_symbolClip);
					_symbolClip.parent.removeChildAt(idx);
					_symbolClip = symbol;
					addChildAt(_symbolClip, idx);
					updateClip();
				}
			}
			
			if (id == 1) setAvatar(Creator.levels.avatar);
		}
		
		//
		//
		protected function onDoubleClick (e:MouseEvent):void {
			
			if (!selectable) return;
			
			if (_selected) Creator.playfield.selection.deselect(this);
			else Creator.playfield.selection.select(this);

		}
		
		//
		//
		protected function onMouseDown (e:MouseEvent):void {
			
			if (!selectable) return;
			
			if (!_dragging) {
				if (_selected) Creator.playfield.selection.startDrag();
				else Creator.playfield.selection.select(this);	
			}
			
		}
        
        //
        //
        //
        public function activate (e:SelectionEvent):void {

			if (e.object != this) return;
			if (_playfield.populating) return;
	
			handles.gotoAndStop(e.asValid ? "valid" : "invalid");
			handles.visible = true;
			
			if (_rotatable && _rotator && _playfield.creator.project.version >= 2) _rotator.visible = true;
			if (_textEntry && _editButton) _editButton.visible = true;
			if (_hasDragger && _dragger) {
				_dragger.visible = true;
				drawDraggerLine();
			}
			if (_linkPrompt) _linkPrompt.play();
			
			if (_avatarEditable && _avatarButton != null) _avatarButton.visible = true;
			
			if (_playfield.selection.objects.length > 1) {
				CreatorHelp.assignButtonHelp(btn, "Drag to move these objects, Shift-drag to create copies");
			} else {
				CreatorHelp.assignButtonHelp(btn, "Drag to move this object, Shift-drag to create a copy");
			}
			
			_selected = true;
            
        }
        
        //
        //
        //
        public function deactivate (e:SelectionEvent):void {
			
			if (e.object != this) return;

			handles.visible = false;
			if (_rotator) _rotator.visible = false;
			if (_editButton) _editButton.visible = false;
			if (_hasDragger && _dragger) {
				_dragger.visible = false;
				clearDraggerLine();
			}
			if (_linkPrompt) _linkPrompt.gotoAndStop(1);
			
			if (_avatarButton != null) _avatarButton.visible = false;
			
			CreatorHelp.assignButtonHelp(btn, "Click to select this object");

			_selected = false;
            
        }
		
        //
        //
        //
        public function startMove (e:SelectionEvent):void {
      
			if (e.object != this) return;

			if (parent == null) {
				remove();
				return;
			}
			
            _lastx = x;
            _lasty = y;
			
			_lastMouseX = x - parent.mouseX;
			_lastMouseY = y - parent.mouseY;

			_dragging = true;
    
        }
        
        //
        //
        //
        public function move (e:SelectionEvent):void {
      
			if (e.object != this) return;
			
			if (parent == null) {
				remove();
				return;
			}
						
			x = Math.round(parent.mouseX + _lastMouseX);
			y = Math.round(parent.mouseY + _lastMouseY);
			
			checkValid();
			
        }
    
        //
        //
        //
        public function stopMove (e:SelectionEvent):void {
 
			if (e.object != this) return;
			
            stopDrag();
			
            validIcon.visible = false;

            if (!dropValid) {
                x = _lastx;
				y = _lasty;
            } else {
				place(x, y);
			}
			
			_playfield.map.update(this);
		
			_dragging = false;
			
			
            
        }
		
		public function onDrop (e:SelectionEvent):void {
			
			if (e.object != this) return;
			
			if (parent != null && (tile || textureAttribs != null))
			{
				parent.addEventListener(Event.ENTER_FRAME, onDropped);	
			}
			
		}
		
		private function onDropped (e:Event):void
		{
			if (parent != null)
			{
				parent.removeEventListener(Event.ENTER_FRAME, onDropped);
				if (tile || textureAttribs != null) updateOldNeighbors(_lastx, _lasty);	
				if (tile || textureAttribs != null) updateClip(true);	
			}
			
		}
		
		protected function startRotate (e:MouseEvent):void {
			
			if (!_rotating) {
				
				stage.addEventListener(Event.ENTER_FRAME, rotate, false, 0, true);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopRotate);
				_rotating = true;
			}
			
		}
		
		protected function rotate (e:Event):void {
			
			var ox:Number = parent.mouseX - x;
			var oy:Number = parent.mouseY - y;
			
			if (ox > 0 && oy < 0) rotation = 0;
			else if (ox > 0 && oy > 0) rotation = 90;
			else if (ox < 0 && oy > 0) rotation = 180;
			else rotation = 270;
			
		}
		
		protected function stopRotate (e:MouseEvent = null):void {
			
			if (_rotating) {
				
				stage.removeEventListener(Event.ENTER_FRAME, rotate);
				stage.removeEventListener(MouseEvent.MOUSE_UP, stopRotate);
				_rotating = false;
				
				place(x, y);
				
			}
			
		}
		
		protected function startDragger (e:MouseEvent):void {
			
			if (_hasDragger && !_draggerDragging) {
				
				stage.addEventListener(Event.ENTER_FRAME, drawDraggerLine);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopDragger);
				_dragger.startDrag();
				_draggerDragging = true;
				
			}
			
		}
		
		protected function clearDraggerLine (e:Event = null):void {
	
			var g:Graphics = _controlClip.graphics;
			g.clear();
			
		}
		
		protected function drawDraggerLine (e:Event = null):void {
	
			var g:Graphics = _controlClip.graphics;
			
			g.clear();
			g.lineStyle(6, 0x00ffff, 0.5);
			g.moveTo(0, 0);
			g.lineTo(_dragger.x, _dragger.y);
			
			//_dragger.rotation = Math.atan2(_dragger.x, 0 - _dragger.y) * Geom2d.rtd + 180;
			
		}
		
		
		protected function stopDragger (e:MouseEvent = null):void {
			
			if (_draggerDragging) {
				
				stage.removeEventListener(Event.ENTER_FRAME, drawDraggerLine);
				stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragger);
				_dragger.stopDrag();
				_draggerDragging = false;
				
				_dragger.x = Math.round(_dragger.x / 30) * 30;
				_dragger.y = Math.round(_dragger.y / 30) * 30;
				
				setData(_dragger.x.toString(), 1);
				setData((0 - _dragger.y) + "", 2);
				
				drawDraggerLine();
				
			}
			
		}
		
		protected function editText (e:MouseEvent = null):void {
			
			_playfield.creator.ddtextentry.show(getData(0));
			
			_playfield.creator.ddtextentry.addEventListener(CreatorDialogue.EVENT_CANCEL, onTextEdited);
			_playfield.creator.ddtextentry.addEventListener(CreatorDialogue.EVENT_CONFIRM, onTextEdited);
			
		}
		
		protected function onTextEdited (e:Event):void {
			
			_playfield.creator.ddtextentry.removeEventListener(CreatorDialogue.EVENT_CANCEL, onTextEdited);
			_playfield.creator.ddtextentry.removeEventListener(CreatorDialogue.EVENT_CONFIRM, onTextEdited);			
			
			if (e.type == CreatorDialogue.EVENT_CONFIRM) {
				
				setData(Cleanser.cleanse(_playfield.creator.ddtextentry.textEntryField.value), 0);
				if (_textField) _textField.text = Cleanser.cleanse(_playfield.creator.ddtextentry.textEntryField.value);
				
			}
			
		}
		
		public function editAvatar (e:Event):void {
			resetSymbol();
			_playfield.creator.ddavatar.show();
		}
		
		public function setAvatar (num:int):void {
			
			var mc:MovieClip = _symbolClip as MovieClip;
			var body:MovieClip = mc.getChildByName("body") as MovieClip;
			
			if (isNaN(num)) num = 0;
			
			if (body != null) {
				var head:MovieClip = body.getChildByName("head") as MovieClip;
				
				if (head != null) {
					head.gotoAndStop(1);
					if (head.getChildByName("g2c")) MovieClip(head.getChildByName("g2c")).gotoAndStop(num * 5 + 1);
				}
			}
			
		}
		
		public function getData (idx:uint = 0):String {
			
			if (dataArray != null && dataArray.length > idx) return unescape(unescape(dataArray[idx]));
			
			return "";
			
		}
		
		public function setData (data:String, idx:uint = 0):void {
			
			if (dataArray == null) dataArray = [];
			
			dataArray[idx] = escape(escape(data));
			
			if (data.length == 0) {
				
				if (dataArray.join("").length == 0) dataArray = [];
				
			}
			
		}
            
        //
        //
        //
        public function checkValid (e:Event = null):void {
			
			if (snap) {
				
				var xoffset:Number = (Math.floor(boundsWidth / CreatorPlayfield.GRID_WIDTH) % 2 == 1) ? CreatorPlayfield.GRID_WIDTH / 2 : 0;
				var yoffset:Number = (Math.floor(boundsHeight / CreatorPlayfield.GRID_HEIGHT) % 2 == 1) ? CreatorPlayfield.GRID_HEIGHT / 2 : 0;
				
				var newx:Number;
				if (xoffset == 0) newx = Math.round(x / CreatorPlayfield.GRID_WIDTH) * CreatorPlayfield.GRID_WIDTH + xoffset;
				else newx = Math.floor(x / CreatorPlayfield.GRID_WIDTH) * CreatorPlayfield.GRID_WIDTH + xoffset;
				
				var newy:Number;
				if (yoffset == 0) newy = Math.round(y / CreatorPlayfield.GRID_HEIGHT) * CreatorPlayfield.GRID_HEIGHT + yoffset;
				else newy = Math.floor(y / CreatorPlayfield.GRID_HEIGHT) * CreatorPlayfield.GRID_HEIGHT + yoffset;
		
				var g:Graphics = _playfield.grid.graphics;
				
				g.lineStyle(1, 0xffec00, 1, true, LineScaleMode.NONE);
				g.beginFill(0xffec00, 0.3);
				g.drawRect(newx - boundsWidth * 0.5, newy - boundsHeight * 0.5, boundsWidth, boundsHeight);
			
			}

            setValid(true); 
            
        }
        
        //
        //
        //
        public function setValid (state:Boolean):void {
            
            if (state) {
                
                validIcon.visible = false;
                dropValid = true;            
                
            } else if (state == false) {
                
                validIcon.visible = true;
                dropValid = false;
                
            }
            
        }  
        
        //
        //
        //
        public function remove ():void {
			
            _playfield.removeObject(this);
			
        }
		
		//
		//
		public function clone (e:SelectionEvent):void {
			
			if (e.object != this) return;
			
			if (unique || uniquegroup != null || permanent) {
				Creator.playfield.selection.deselect(this);
				return;
			}
			
			var d:Array = (dataArray != null && dataArray.length > 0) ? dataArray.concat() : null;
			
			var obj:CreatorPlayfieldObject = Creator.playfield.addObject(id, x, y, zz, rotation, tileID, d, graphic, graphic_version, graphic_animation);
			 
			Creator.playfield.selection.deselect(this);
			Creator.playfield.selection.select(obj, true);
          
		}
		
		public static function getTextureName (cpo:CreatorPlayfieldObject):String {
			
			if (cpo.graphic > 0 && cpo.graphic_version > 0) return cpo.graphic + "_" + cpo.graphic_version;
			return "";
			
		}
		
		private function updateGraphics ():void
		{
			if (keepSymbolWithGraphic && !tile) {
				var s:Sprite = Sprite(_symbolClip).getChildByName("g") as Sprite;
				if (s != null) 
				{
					drawGraphic(s.graphics, this);
					s.scaleX = s.scaleY = 1.0;
				}
				s = Sprite(_symbolClip).getChildByName("g2") as Sprite;
				if (s != null) 
				{
					drawGraphic(s.graphics, this);
					s.scaleX = s.scaleY = 1.0;
				}
			} else drawGraphic(graphics, this);
			return;
		}
		
		
		private static function drawGraphic (g:Graphics, cpo:CreatorPlayfieldObject):void
		{
			var bd:BitmapData;
			
			var m:Matrix = new Matrix();
			var w:Number;
			var h:Number;
			var x:Number;
			var y:Number;
			var bounds:Rectangle;
			var texture_name:String = getTextureName(cpo);
			var clip:DisplayObject = cpo.symbolClip;
			
			var k:int;
			var key:String;
			var s:Sprite;
			var s2:Sprite;
			var r:Rectangle;
			var rects:Object;
			var sw:Number;
			var sh:Number;
			
			if (cpo.graphic > 0) {
				
				bd = Textures.getScaledBitmapData(texture_name, 1, 0, cpo);
				
				if (bd) {
					
					if (cpo.type == "biped")
					{
					
						if (Textures.getRectsFor(texture_name) == null)
						{
							Textures.addRectFor(texture_name, "torso", Textures.getTrimmedRect(bd, bd.width * 0.25, bd.height * 0.5, bd.width * 0.5, bd.height * 0.5));
							Textures.addRectFor(texture_name, "head", Textures.getTrimmedRect(bd, bd.width * 0.25, 0, bd.width * 0.5, bd.width * 0.5));
							Textures.addRectFor(texture_name, "arm_rt", Textures.getTrimmedRect(bd, 0, 0, bd.width * 0.25, bd.height * 0.4));
							Textures.addRectFor(texture_name, "arm_lt", Textures.getTrimmedRect(bd, bd.width * 0.75, 0, bd.width * 0.25, bd.height * 0.4));
							Textures.addRectFor(texture_name, "hand_rt", Textures.getTrimmedRect(bd, 0, bd.height * 0.4, bd.width * 0.25, bd.height * 0.2));
							Textures.addRectFor(texture_name, "hand_lt", Textures.getTrimmedRect(bd, bd.width * 0.75, bd.height * 0.4, bd.width * 0.25, bd.height * 0.2));
							Textures.addRectFor(texture_name, "leg_rt", Textures.getTrimmedRect(bd, 0,  bd.height * 0.6, bd.width * 0.25, bd.height * 0.4));
							Textures.addRectFor(texture_name, "leg_lt", Textures.getTrimmedRect(bd, bd.width * 0.75,  bd.height * 0.6, bd.width * 0.25, bd.height * 0.4));
						}
						
						bd = Textures.getScaledBitmapData(texture_name, 8, 0, cpo);
						
						rects = Textures.getRectsFor(texture_name);
						var isPlayer:Boolean = (cpo.id == 1);
						
						s = Sprite(clip).getChildByName("body") as Sprite;
						if (s.getChildByName("tail")) s.getChildByName("tail").alpha = 0;
						
						for (key in rects)
						{
							s = Sprite(clip).getChildByName("body") as Sprite;
							
							if (!(rects[key] is Rectangle)) continue;
							if (isPlayer && key != "head") continue;
							
							if (s != null)
							{
								r = rects[key].clone();
								
								if (r.width <= 1 || r.height <= 1) continue;
								
								if (key == "hand_lt") s = s.getChildByName("arm_lt") as Sprite;
								if (key == "hand_rt") s = s.getChildByName("arm_rt") as Sprite;
								if (s != null)
								{
									s = s.getChildByName(key) as Sprite;
									
									if (key == "arm_lt") s = s.getChildByName("arm") as Sprite;
									if (key == "arm_rt") s = s.getChildByName("arm") as Sprite;
									if (key == "leg_lt") s = s.getChildByName("leg") as Sprite;
									if (key == "leg_rt") s = s.getChildByName("leg") as Sprite;
									
									if (s != null)
									{	
										if (s.getChildByName("g2c"))
										{
											s2 = s.getChildByName("g2c") as Sprite;
											bounds = s2.getBounds(s);
											s2.visible = false;
										} else {
											bounds = s.getBounds(s);
										}
										
										if (key == "hand_rt" && s.getChildByName("hand")) s.getChildByName("hand").alpha = 0;
										
										sw = bounds.width / r.width / 8;
										sh = bounds.height / r.height / 8;
										
										if (key == "head")
										{
											var ss:Number = Math.min(sw, sh);
											sw = sh = ss;
											m.createBox(sw, sh, 0, 0 - r.x * sw * 8 + bounds.x - ((r.width - 1) * sw * 8 - bounds.width) * 0.5, 0 - r.y * sh * 8 + bounds.y - ((r.height - 1) * sh * 8 - bounds.height));
										}
										else if (key == "torso")
										{
											//m.createBox(sw, sh, 0, 0 - r.x * sw + bounds.x, 0 - r.y * sh + bounds.y);
											m.createBox(sw, sh, 0, 0 - r.x * sw * 8 + bounds.x, 0 - r.y * sh * 8 + bounds.y);
										} else {
											sw = bounds.width / r.height / 8;
											sh = bounds.height / r.width / 8;
											//m.createBox(sw, sh, 0 - Math.PI * 0.5, bounds.x - (r.y * sw), bounds.y + (r.x * sh) + r.width * sh);
											m.createBox(sw, sh, 0 - Math.PI * 0.5, bounds.x - (r.y * sw * 8), bounds.y + (r.x * sh * 8) + r.width * sh * 8);
										}
						
										
										g = s.graphics;
										g.clear();
										//g.lineStyle(1, 0xff0000);
										g.beginBitmapFill(bd, m, false, true);
										if (key == "head") g.drawRect(bounds.x + (bounds.width - (r.width - 1) * sw * 8) * 0.5, bounds.y + (bounds.height - (r.height - 1) * sh * 8), bounds.width - (bounds.width - (r.width - 1) * sw * 8), bounds.height - (bounds.height - (r.height - 1) * sh * 8));
										else g.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
										g.endFill();
										
										if (cpo.id > 1 && (key == "hand_rt" || key == "hand_lt"))
										{
											for (k = 0; k < s.numChildren; k++)
											{
												var tool:DisplayObject = s.getChildAt(k);
												if (tool is MovieClip) MovieClip(tool).gotoAndStop(2);
											}
										}
									}
								}
							}
						}
					
					} 
					else if (cpo.id == 65 || cpo.id == 66) // car type
					{
					
						if (Textures.getRectsFor(texture_name) == null)
						{
							Textures.addRectFor(texture_name, "body", Textures.getTrimmedRect(bd, 0, 0, bd.width, bd.height * 0.5));
							Textures.addRectFor(texture_name, "wheel_lt", Textures.getTrimmedRect(bd, 0,  bd.height * 0.5, bd.width * 0.5, bd.height * 0.5));
							Textures.addRectFor(texture_name, "wheel_rt", Textures.getTrimmedRect(bd, bd.width * 0.5,  bd.height * 0.5, bd.width * 0.5, bd.height * 0.5));
						}
						
						bd = Textures.getScaledBitmapData(texture_name, 8, 0, cpo);
						
						w = cpo.graphicWidth > 0 ? cpo.graphicWidth : cpo.originalWidth;
						h = cpo.graphicHeight > 0 ? cpo.graphicHeight : cpo.originalHeight;
						
						rects = Textures.getRectsFor(texture_name);
						
						for (key in rects)
						{
							s = Sprite(clip) as Sprite;
							
							if (!(rects[key] is Rectangle)) continue;

							if (s != null)
							{
								r = rects[key];
								
								if (r.width <= 1 || r.height <= 1) continue;
								
								if (s != null)
								{
									if (key == "body") 
									{
										s.getChildByName(key).visible = false;
										s = s.getChildByName("g") as Sprite;
									} else {
										s = s.getChildByName(key) as Sprite;
									}
									
									if (s != null)
									{	
										//s.graphics.clear();
										
										if (s.getChildByName("g2c"))
										{
											s2 = s.getChildByName("g2c") as Sprite;
											bounds = s2.getBounds(s);
											s2.visible = false;
										} else {
											if (s.name == "g") s.graphics.clear();
											if (s.name == "g") bounds = s.getBounds(s.parent);
											else bounds = s.getBounds(s);
										}
										
										if (key == "body") {
											sw = w / r.width / 8;
											sh = h / r.height / 8;
											bounds.x = 0 - w / 2;
											bounds.y = 0 - h / 2;
											bounds.width = w;
											bounds.height = h;
											s.scaleX = s.scaleY = 1;
										} else {
											sw = bounds.width / r.width / 8;
											sh = bounds.height / r.height / 8;
										}
										
										m.createBox(sw, sh, 0, 0 - r.x * sw * 8 + bounds.x, 0 - r.y * sh * 8 + bounds.y);
										
										g = s.graphics;
										g.clear();
										//g.lineStyle(1, 0xff0000);
										g.beginBitmapFill(bd, m, false, true);
										g.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
										g.endFill();
									}
								}
							}
						}
					
						if (Sprite(clip).getChildByName("turret"))
						{
							MovieClip(Sprite(clip).getChildByName("turret")).gotoAndStop(2);
						}
						
					
					} 
					else if (cpo.type == "mech") // Mech
					{
						
						if (Textures.getRectsFor(texture_name) == null)
						{
							Textures.addRectFor(texture_name, "head", Textures.getTrimmedRect(bd, 0, 0, bd.width * 0.6, bd.width * 0.6));
							Textures.addRectFor(texture_name, "upper", Textures.getTrimmedRect(bd, bd.width * 0.6, 0, bd.width * 0.4, bd.height * 0.5));
							Textures.addRectFor(texture_name, "punch", Textures.getTrimmedRect(bd, 0, bd.height * 0.6, bd.width * 0.6, bd.height * 0.4));
							Textures.addRectFor(texture_name, "leg", Textures.getTrimmedRect(bd, bd.width * 0.6, bd.height * 0.5, bd.width * 0.4, bd.height * 0.5));
						}
						
						bd = Textures.getScaledBitmapData(texture_name, 8, 0, cpo);
						
						rects = Textures.getRectsFor(texture_name);
						var clips:Array = ["head", "arm_rt/upper", "arm_rt/punch", "arm_lt/upper", "arm_lt/punch", "leg_rt", "leg_lt"];
						var cliprects:Array = ["head", "upper", "punch", "upper", "punch", "leg", "leg"];
						
						for (k = 0; k < clips.length; k++)
						{
							s = Sprite(clip).getChildByName("body") as Sprite;
							
							var clips_parts:Array = clips[k].split("/");
							s = s.getChildByName(clips_parts[0]) as Sprite;
							if (clips_parts.length > 1) s = s.getChildByName(clips_parts[1]) as Sprite;
							
							if (!(rects[cliprects[k]] is Rectangle)) continue;
							
							if (s != null)
							{
								r = rects[cliprects[k]];
								
								if (r.width <= 1 || r.height <= 1) continue;
								
								if (s != null)
								{
									if (s.getChildByName("g2c"))
									{
										s2 = s.getChildByName("g2c") as Sprite;
										bounds = s2.getBounds(s);
										s2.visible = false;
									} else {
										bounds = s.getBounds(s);
									}
									
									sw = bounds.width / r.width / 8;
									sh = bounds.height / r.height / 8;
									
									m.createBox(sw, sh, 0, 0 - r.x * sw * 8 + bounds.x, 0 - r.y * sh * 8 + bounds.y);
									
									g = s.graphics;
									g.clear();
									//g.lineStyle(1, 0xff0000);
									g.beginBitmapFill(bd, m, false, true);
									g.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
									g.endFill();
								}
							}
						}	
					
					} else {
						
						bd = Textures.getScaledBitmapData(texture_name, 8, 0, cpo);
						
						if (g != null)
						{
							w = cpo.graphicWidth > 0 ? cpo.graphicWidth : cpo.originalWidth;
							h = cpo.graphicHeight > 0 ? cpo.graphicHeight : cpo.originalHeight;
							
							if (w / h <= 0.75)
							{
								m.createBox(h / (bd.height), h / (bd.height), 0, 0 - h / 2, 0 -  h / 2);
							} else if (w / h >= 1.49) {
								m.createBox(w / (bd.width), w / (bd.width), 0, 0 - w / 2, 0 - w / 2);
							} else {
								m.createBox(w / (bd.width), h / (bd.height), 0, 0 - w / 2,0 -  h / 2);
							}
							
							g.clear();
							g.beginBitmapFill(bd, m, false, true);
							g.drawRect(0 - w / 2, 0 - h / 2, w, h);
							g.endFill();
							
							if (clip != null && !cpo.keepSymbolWithGraphic) clip.visible = false;
							if (clip is Sprite && Sprite(clip).getChildByName("g2c")) Sprite(clip).getChildByName("g2c").visible = false;
							
							return;
						} else {
							trace("graphic is null");
						}
					}
				} else {
					trace("graphic must not be loaded yet");
				}
			}
			
			if (clip != null) clip.visible = true;
		}
		
		//
		//
		public function updateClip (source:Boolean = false):void {
			
			if (_playfield.populating) return;
			if (_playfield.selection.copying) return;
			
			if (_playfield.clearing) return;
			
			if (graphic > 0) {
				updateGraphics();
				return;
			}
			
			if (_playfield.selection.updateTime > 0 && _playfield.selection.updateTime == lastTileUpdate) return;
			
			
			if (tile) 
			{
				var b:Bitmap = getClipAsBitmap(source);
				if (b != _symbolClip) {
					if (_symbolClip.parent == this) removeChild(_symbolClip);
					_symbolClip = null;
					_symbolClip = b;
					addChild(_symbolClip);
				}

				_symbolClip.rotation = tileRotation;
				_symbolClip.x = 0 - Math.sin(Geom2d.dtr * _symbolClip.rotation) * (0 - _symbolClip.width / 2) + Math.cos(Geom2d.dtr * _symbolClip.rotation) * (0 - _symbolClip.width / 2);
				_symbolClip.y = Math.cos(Geom2d.dtr * _symbolClip.rotation) * (0 - _symbolClip.height / 2) + Math.sin(Geom2d.dtr * _symbolClip.rotation) * (0 - _symbolClip.height / 2);

				setChildIndex(_controlClip, numChildren - 1);
				
				lastTileUpdate = _playfield.selection.updateTime;
			} 
			else if (textureAttribs != null)
			{
				updateTexture(_symbolClip as Bitmap, source);
				lastTileUpdate = _playfield.selection.updateTime;
			}
		}
		
		public function updateTextureOnly ():void
		{
			if (textureAttribs != null)
			{
				if (dataArray == null) dataArray = [];
				dataArray[0] = textureAttribs.serialize();
			}
			if (_symbolClip is Bitmap) 
			{
				Creator.creatorlibrary.updateTexture(_symbolClip as Bitmap, textureAttribs, 120, tileBack ? TextureRendering.BORDER_TYPE_ALL : border);	
			}
		}
		
		//
		//
		protected function updateOldNeighbors (xpos:int, ypos:int):void {
			
			var neighbors:Array;
			var neighbor:CreatorPlayfieldObject;
			
			if (tile)
			{
				neighbors = _playfield.map.getNeighborsNear(xpos, ypos);
				
				for each (neighbor in neighbors) {
					
					if (neighbor.tile && neighbor.tileID == tileID) {
						
						if (neighbor != this) neighbor.updateClip();
						
					}
					
				}
			} 
			else if (textureAttribs != null)
			{
				neighbors = _playfield.map.getNeighborsNear(xpos, ypos);
				
				for each (neighbor in neighbors) {
					
					if (neighbor.textureAttribs != null && neighbor != this) neighbor.updateClip();
					
				}
			}
			
		}

		override public function toString():String 
		{	
			var hasGraphics:Boolean = Creator.mainInstance.project.hasGraphics;
			
			var data:Array;
			
			if (hasGraphics) data = [id, Math.round(x), Math.round(0 - y), normalizeRotation(Math.floor(rotation), _limitRotate), tileID, graphic, graphic_version, graphic_animation]; 
			else data = [id, Math.round(x), Math.round(0 - y), normalizeRotation(Math.floor(rotation), _limitRotate), tileID]; 
			
			if (dataArray != null && dataArray.length > 0) data = data.concat(dataArray);
			
			if (dataArray == null || dataArray.length == 0) {
				
				if (graphic == 0) {
					
					if (hasGraphics)
					{
						data.pop();
						data.pop();
						data.pop();
					}
					
					if (tileID == 0) 
					{
						data.pop();
						if (rotation == 0) data.pop();
					}
				}
			}
			
			return data.join(","); 
			
		}
		
        
        //
        //
        //
        public function endClip ():void {

			if (tile && !_playfield.clearing) updateOldNeighbors(_lastx, _lasty);
			
			stopDrag();
			stopRotate();
			stopDragger();
			
            if (parent != null && parent.getChildIndex(this) != -1) parent.removeChild(this);
			
			if (_symbolClip && _symbolClip.parent) _symbolClip.parent.removeChild(_symbolClip);
			if (_controlClip && _controlClip.parent) _controlClip.parent.removeChild(_controlClip);
			
			_symbolClip = null;
			_controlClip = null;
			_dragger = null;
			_draggerButton = null;
			_editButton = null;
			_textField = null;
			_rotator = null;
			
        }
		
		//
		//
		public static function normalizeRotation (r:Number, limitRotate:Boolean = false):uint {
			
			while (r < 0) r += 360;
			while (r > 360) r -= 360;
			
			if (limitRotate && r > 180) r -= 180;
			
			return r;
			
		}
        
    }
	
}
