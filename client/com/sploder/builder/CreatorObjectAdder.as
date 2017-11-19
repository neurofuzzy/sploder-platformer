package com.sploder.builder {
    
	import com.sploder.builder.*;
	import com.sploder.geom.Geom2d;
	import com.sploder.texturegen_internal.TextureAttributes;
	import com.sploder.asui.Tagtip;
	import com.sploder.texturegen_internal.TextureRendering;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import com.sploder.builder.CreatorFactory;

	import flash.display.Sprite;
	
    public class CreatorObjectAdder extends Sprite {
		
		public var textureAttribs:TextureAttributes;

        public var id:int = 0;
		public var type:String = "";
		public var group:String = "";
		
		public var version:int = 1;

        public var unique:Boolean = false;
		public var uniquegroup:Array;

        public var rotatable:Boolean = false;

        public var ortho:Boolean = true;
        
        public var scalable:Boolean = false;

        public var defaultXScale:Number = 1;

        public var defaultYScale:Number = 1;
        
        public var _creator:Creator;
        
        public var icon:CreatorObjectGhost;
        public var btn:SimpleButton;
		public var disabled_btn:SimpleButton;
		public var tf:TextField;
		public var objClip:Sprite;
		public var check:Sprite;
        
        public var dropValid:Boolean = false;
		
		protected var _def:XML;
		public function get def():XML { return _def; }
		
		protected var _isTile:Boolean = false;
		public function get isTile():Boolean { return _isTile; }
		
		protected var _tileID:int = 0;
		public function get tileID():int { return _tileID; }
		public function set tileID(value:int):void 
		{
			_tileID = value;
			tileid_tf.text = _tileID + "";
			updateObject();
		}
		
		protected var _back:Boolean = false;
		public function get back():Boolean { return _back; }
		
		public var zz:int = 0;

		public var tileedit_btn:SimpleButton;
		public var tiledown_btn:SimpleButton;
		public var tileup_btn:SimpleButton;
		public var tileid_tf:TextField;
		
		protected var _clip:MovieClip;
		protected var _pobj:DisplayObject;


		public function set active (value:Boolean):void {
			
			if (btn != null) btn.enabled = btn.mouseEnabled = value;
			if (tf != null) tf.alpha = (value) ? 1 : 0.5;
			if (_pobj != null) _pobj.alpha = (value) ? 1 : 0.5;
			
			check.visible = false; 
			
		}
		
		override public function get height():Number { 
			if (_def..obj.@type == "tile" || _def..obj.@type == "textureblock") return 120;
			else return 90;
		}

        //
        //
        //
        public function CreatorObjectAdder (creator:Creator, def:XML) {
            
            super();
            init(creator, def);
            
        }
        
        //
        //
        //
        protected function init (creator:Creator, def:XML):void {

			_creator = creator;
			_def = def;

			name = "obj" + String(_def.@cid);
			id = parseInt(_def.@cid)
			type = _def.@id;
			group = _def.@ctype;

			icon = _creator.objGhost;
			
			if (_def..obj.@type == "tile") _clip = Creator.UIlibrary.getDisplayObject("objecttileadder") as MovieClip;
			else if (_def..obj.@type == "textureblock") _clip = Creator.UIlibrary.getDisplayObject("objecttextureblockadder") as MovieClip;
			else _clip = Creator.UIlibrary.getDisplayObject("objectadder") as MovieClip;
			addChild(_clip);

			btn = _clip["btn"];
			disabled_btn = _clip["disabled_btn"];
			tf = _clip["textfield"];
			objClip = _clip["proxy"];
			check = _clip["check"];
			check.visible = false;
			
			if (group == "goal") _clip.gotoAndStop("goal");
			
			tf.text = String(_def.@cname);
			
			unique = CreatorFactory.getUnique(id);
			uniquegroup = CreatorFactory.getUniqueGroup(id);
			
			if ("@z" in _def) zz = parseInt(_def.@z);
			
			if (_def..obj.@type == "tile") {
				
				_isTile = true;
				_tileID = parseInt(_def..obj.@tile);
				_back = String(_def..obj.@back) == "1";
				tileup_btn = _clip["tileup"];
				tiledown_btn = _clip["tiledown"];
				tileid_tf = _clip["tileid"];
				tileid_tf.text = _tileID + "";
				tileid_tf.selectable = false;
				tileid_tf.mouseEnabled = false;
				tiledown_btn.addEventListener(MouseEvent.CLICK, decreaseTileID);
				tileup_btn.addEventListener(MouseEvent.CLICK, increaseTileID);
				CreatorHelp.assignButtonHelp(tiledown_btn, "Click to change tile texture, Shift-click to change by 10");
				CreatorHelp.assignButtonHelp(tileup_btn, "Click to change tile texture, Shift-click to change by 10");
				
			} else if (_def..obj.@type == "textureblock") {
				
				_back = String(_def..obj.@back) == "1";
				
				textureAttribs = new TextureAttributes().initFromSeed(40465, 365);
				tileedit_btn = _clip["edittexture"];
				tileedit_btn.addEventListener(MouseEvent.CLICK, editTile);
				CreatorHelp.assignButtonHelp(tileedit_btn, "Click to edit texture in the advanced editor");
			}
				
			
			updateObject();
            
			btn.addEventListener(MouseEvent.MOUSE_DOWN, startDragGhost);
			btn.addEventListener(MouseEvent.MOUSE_UP, stopDragGhost);
			
			disabled_btn.addEventListener(MouseEvent.MOUSE_OVER, showDisabledMessage);
			disabled_btn.addEventListener(MouseEvent.MOUSE_OUT, hideDisabledMessage);
			disabled_btn.visible = false;
			
			CreatorHelp.assignButtonHelp(btn, "Drag this item onto the playfield to add it to your game.");
			
			if ("@goal" in _def) {
				MovieClip(_clip).gotoAndStop(2);
			}

        }
		
		//
		//
		public static function getObject (obj:CreatorObjectAdder, scale:Boolean = false):DisplayObject {
			
			var pobj:DisplayObject = CreatorFactory.createNew(obj.id + "", obj, 0, 0, 0, { tile: obj.tileID, back: obj.back});
			
			if (pobj == null) return null;
			
			if (pobj is Sprite) {

				if (Sprite(pobj).getChildByName("texture") != null) {
					Sprite(pobj).removeChild(Sprite(pobj).getChildByName("texture"));
				}
				
			}
			
			if (obj.def..obj.@type == "symbol" || 
				obj.def..obj.@type == "turretsymbol" || 
				obj.def..obj.@type == "segsymbol" || 
				obj.def..obj.@type == "mech" || 
				obj.def..obj.@type == "biped") {
				
				if (scale) scaleObject(pobj, obj.id);
				
			} else if (obj.def..obj.@type == "tile") {
				
				if (scale) scaleObject(pobj);

				pobj.x = 0 - Math.sin(Geom2d.dtr * pobj.rotation) * (0 - pobj.width / 2) + Math.cos(Geom2d.dtr * pobj.rotation) * (0 - pobj.width / 2);
				pobj.y = Math.cos(Geom2d.dtr * pobj.rotation) * (0 - pobj.height / 2) + Math.sin(Geom2d.dtr * pobj.rotation) * (0 - pobj.height / 2);
				
			} else if (obj.def..obj.@type == "textureblock") {
				
				pobj = CreatorFactory.library.getTextureAsBitmap(obj.textureAttribs, 120, obj.back ? TextureRendering.BORDER_TYPE_ALL : 0);
				pobj.width = pobj.height = 48;
				pobj.x = (0 - pobj.width / 2);
				pobj.y = (0 - pobj.height / 2);		
			}

			if (pobj is MovieClip) {
				if (obj.def.@cframe != undefined && !isNaN(parseInt(obj.def.@cframe))) {
					MovieClip(pobj).gotoAndStop(parseInt(obj.def.@cframe));
				} else {
					MovieClip(pobj).gotoAndStop(1);
				}
			}
			if (pobj is Sprite) {
				Sprite(pobj).mouseEnabled = false;
				if (Sprite(pobj).getChildByName("linkprompt")) {
					Sprite(pobj).getChildByName("linkprompt").parent.removeChild(Sprite(pobj).getChildByName("linkprompt"));
				}
			}
			
			
			return pobj;
			
		}
		
		public function updateTexture (val:String):void
		{
			if (textureAttribs != null)
			{
				textureAttribs.unserialize(val);
				if (_pobj is Bitmap) CreatorFactory.library.updateTexture(Bitmap(_pobj), textureAttribs, 120, _back ? TextureRendering.BORDER_TYPE_ALL : 0);
			}
		}
		
		//
		//
		protected static function scaleObject (obj:DisplayObject, id:int = 0):void {

			var w:Number = obj.width;
			var h:Number = obj.height;
			
			var newScale:Number = Math.min(1, Math.min(50 / w, 50 / h));
			
			// fix for lava scaling wrong
			// if (id == 451 || id == 452) newScale *= 3.6;
			
			obj.scaleX = obj.scaleY = newScale;
			
		}
		
		//
		//
		protected function decreaseTileID (e:MouseEvent):void {
			
			if (e.shiftKey) {
				_tileID -= 10;
			} else {
				_tileID--;
			}
			
			tileid_tf.text = _tileID + "";
			
			updateObject();
			_creator.cleanBitmapData();
			
		}
		
		//
		//
		protected function increaseTileID (e:MouseEvent):void {
			
			if (e.shiftKey) {
				_tileID += 10;
			} else {
				_tileID++;
			}
			
			tileid_tf.text = _tileID + "";
			
			updateObject();
			_creator.cleanBitmapData();
			
		}
		
		protected function editTile (e:MouseEvent):void {
			
			_creator.showTextureGenerator(textureAttribs, back);
		}
		
		//
		//
		protected function updateObject ():void {
			
			if (_pobj != null) {
				_pobj.parent.removeChild(_pobj);
				_pobj = null;
			}
			
			_pobj = getObject(this, true);
			
			if (_pobj != null) _pobj.y -= 6;
			if (_pobj != null) objClip.addChild(_pobj);		
			
		}
        
        //
        //
        //
        public function startDragGhost (e:MouseEvent):void {

            icon.startDrag(this);
            
			CreatorMain.mainStage.addEventListener(MouseEvent.MOUSE_UP, stopDragGhost);
			CreatorMain.mainStage.addEventListener(Event.MOUSE_LEAVE, stopDragGhost);
            CreatorMain.mainStage.addEventListener(Event.ENTER_FRAME, checkValid);
			
			_creator.buttons.setNavMode(CreatorButtons.MODE_PAN);
			
        }
        
        //
        //
        //
        public function stopDragGhost (e:MouseEvent):void {

			if (e.type == Event.MOUSE_LEAVE) dropValid = false;
    
            if (dropValid) {
				
				var z:int = (_def..obj.@z != null) ? parseInt(_def..obj.@z) : 0;
    
                var cobj:CreatorPlayfieldObject = Creator.playfield.addObject(id, Creator.playfield.clip.mouseX, Creator.playfield.clip.mouseY, z, 0, _tileID, (textureAttribs != null) ? [textureAttribs.serialize()] : null);
				
            }
                
            icon.stopDrag();
			
            CreatorHelp.prompt("");
            
			CreatorMain.mainStage.removeEventListener(MouseEvent.MOUSE_UP, stopDragGhost);
			CreatorMain.mainStage.removeEventListener(Event.MOUSE_LEAVE, stopDragGhost);
            CreatorMain.mainStage.removeEventListener(Event.ENTER_FRAME, checkValid);
            
        }
        
        //
        //
        //
        public function checkValid (e:Event):void {

            
            var radius:Number = 10 * (Creator.navigator.container.scaleX);
            icon.validIcon.visible = false;
            dropValid = true;
            
            if (_creator.ui.mouseX < 150) {
                
                dropValid = false;
                
            } else {
                 
                if (Creator.playfield.clip.mouseX <= Creator.playfield.minx || 
                    Creator.playfield.clip.mouseX >= Creator.playfield.maxx ||
                    Creator.playfield.clip.mouseY <= Creator.playfield.miny ||
                    Creator.playfield.clip.mouseY >= Creator.playfield.maxy) {
                        
                    icon.validIcon.visible = true;
                    dropValid = false;                
                        
                }
                
            }
            
        }
		
		//
		//
		protected function showDisabledMessage (e:MouseEvent):void {
			
			Tagtip.showTag("This item can only be used in new games and version 2 games.");
			
		}
		
		//
		//
		protected function hideDisabledMessage (e:MouseEvent):void {
			
			Tagtip.hideTag();
			
		}
        
    }
	
}
