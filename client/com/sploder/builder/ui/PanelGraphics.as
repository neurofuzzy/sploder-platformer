package com.sploder.builder.ui {
	
	import com.sploder.builder.Creator;
	import com.sploder.builder.CreatorFactory;
	import com.sploder.builder.CreatorHelp;
	import com.sploder.builder.CreatorMain;
	import com.sploder.builder.CreatorPlayfieldObject;
	import com.sploder.builder.CreatorSelection;
	import com.sploder.builder.Styles;
	import com.sploder.util.Textures;
	import com.sploder.data.User;
	import com.sploder.asui.*;
	import com.sploder.util.Settings;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	import org.bytearray.gif.events.FrameEvent;
	import org.bytearray.gif.player.GIFPlayer;
	

	
	public class PanelGraphics extends EventDispatcher {
		
		public static const EVENT_SELECT:String = "select";
		public static const EVENT_CONFIRM:String = "confirm";
		
		protected static const MINE:String = "Mine";
		protected static const ALL:String = "All";
		protected static const TAGS:String = "Tags";
		protected static const USERS:String = "Users";
		
		protected var _creator:Creator;
		protected var _contentCell:Cell;
		
		protected var _loadingPrompt:HTMLField;
		protected var _serverMessage:HTMLField;
		protected var _cancelButton:BButton;
		protected var _confirmButton:BButton;
		protected var _pageBack:BButton;
		protected var _pageNext:BButton;
		
		protected var _listContainer:Collection;
		
		protected var _xml:XMLDocument;
		
		protected var _listURL:String = "/graphics/getlist.php";
		public function get listURL():String { return _listURL; }
		
		protected var _public:Boolean = true;
		
		protected var _items:Object;
		protected var _totalItems:int = 0;
		protected var _resultStart:int = 0;
		protected var _resultsPerPage:int = 12;
		protected var _resultsNum:int = 0;
		protected var _resultsTotal:int = 0;
		protected var _totalPages:int = 0;
		protected var _pageNum:int = 0;
		
		protected var _selectedProject:CollectionItem;
		
		protected var _currentProjectID:uint = 0;
		protected var _currentProjectVersion:uint = 0;
		protected var _currentProjectUsername:String = "";
		protected var _currentSelectionLength:uint = 0;
		
		public function get currentProjectID():uint { return _currentProjectID; }
		public function set currentProjectID(value:uint):void { _currentProjectID = value; }
		
		protected var _gifPlayers:Vector.<GIFPlayer>;
		
		protected var _contentCreated:Boolean = false;
		private var listChooser:TabGroup;
		private var _likeButton:BButton;
		private var _searchField:FormField;
		private var _searchButton:BButton;
		private var _searchMode:String = "";
		private var _moveButton:ToggleButton;
		
		protected var _tweener:TweenManager;
		private var _currentTab:String;
		private var _reportButton:BButton;
		
		//
		//
		public function PanelGraphics (creator:Creator) 
		{
			init(creator);
		}
		
		protected function init (creator:Creator):void {
			
			_creator = creator;
			
		}
		
		public function create (container:Cell):void 
		{
			
			_gifPlayers = new Vector.<GIFPlayer>();
			
			_contentCell = new Cell(null, 640, 85, true, false, 0, Styles.absPosition.clone( { top: 425, left: 0 } ), Styles.dialogueStyle);
			container.addChild(_contentCell);
			createContent();
			hide();
			
			_tweener = new TweenManager(true);
			
		}
		
		public function createContent():void 
		{
			if (_contentCreated) return;
			
			var colStyle:Style = new Style( {
				padding: 10,
				round: 10,
				highlightTextColor: 0xffffff,
				selectedButtonBorderColor: 0xffffff
			 } );
			 
			var rowPos:Position = new Position ( { margins: "4 3 3 5", placement: Position.PLACEMENT_FLOAT } );
			var rowPos2:Position = new Position ( { margins: "4 3 3 3", placement: Position.PLACEMENT_FLOAT } );
			
			var pbStyle:Style = Styles.dialogueStyle.clone();
			pbStyle.buttonColor = 0;
			pbStyle.padding = 0;
			 
			_pageBack = new BButton(null, Create.ICON_ARROW_RIGHT, -1, 24, 50, false, false, false, rowPos, pbStyle);
			_contentCell.addChild(_pageBack);
			_pageBack.addEventListener(Component.EVENT_CLICK, onClick);
			
			_listContainer = new Collection(null, 576, 48, 48, 48, 0, Styles.floatPosition.clone( { margin_top: 5 } ), colStyle);
			_listContainer.allowDrag = false;
			_listContainer.allowRearrange = false;

			_listContainer.defaultItemStyle = new Style ( {
				padding: 12,
				round: 5,
				background: true,
				bgGradient: true,
				bgGradientColors: [0x555555, 0x222222],
				highlightTextColor: 0xffffff,
				htmlFont: "Myriad Web",
				font: "Myriad Web",
				fontSize: 13,
				embedFonts: true,
				borderWidth: 2,
				borderColor: 0
				} );
				
			_listContainer.useSnap = true;
			_listContainer.allowDrag = true;
		
			_contentCell.addChild(_listContainer);
			
			_pageNext = new BButton(null, Create.ICON_ARROW_LEFT, -1, 24, 50, false, false, false, rowPos2, pbStyle);
			_contentCell.addChild(_pageNext);
			_pageNext.addEventListener(Component.EVENT_CLICK, onClick);
			
			_listContainer.addEventListener(Component.EVENT_SELECT, onProjectSelect);
				
			var bPos:Position = Styles.floatPosition.clone( { margin_top: 4, margin_left: 62 } );
			var bPos2:Position = Styles.floatPosition.clone( { margin_top: 4, margin_left: 4 } );
			
			_loadingPrompt = new HTMLField(null, "<br /><p align=\"center\">Loading...</p>", 640, true, Styles.absPosition, Styles.dialogueStyle);
			_contentCell.addChild(_loadingPrompt);
			
			_serverMessage = new HTMLField(null, "<br /><p align=\"center\"><b>Server message</b></p>", 640, true, Styles.absPosition, Styles.dialogueStyle);
			_contentCell.addChild(_serverMessage);
			
			var subControls:Cell = new Cell(null, NaN, 34, false, false, 0);
			_contentCell.addChild(subControls);
			
			var tabPos:Position = Styles.floatPosition.clone( { margins: "1 0 0 6" } );
			var tabStyle:Style = Styles.dialogueStyle.clone( { round: 0 } );
			tabStyle.buttonColor = 0x333333;
			tabStyle.selectedButtonBorderColor = 0x666666;
			tabStyle.unselectedTextColor = 0xcccccc;
			tabStyle.unselectedColor = 0x000000;
			tabStyle.unselectedBorderColor = 0x333333;
			tabStyle.inactiveColor = 0x000000;
			tabStyle.inactiveTextColor = 0x666666;
			tabStyle.border = false;
			tabStyle.padding = 3;
			
			var bStyle:Style = Styles.dialogueStyle.clone();
			bStyle.padding = 2;
			
			listChooser = new TabGroup(null, 
				[MINE, ALL, TAGS, USERS], 
				["Choose from my graphics only", "Choose from everyone's public graphics", "Search within tagged graphics", "Search for graphics by a single user"], 
				(_creator.demo) ? 1 : 0, 22, false, tabPos, tabStyle);
			listChooser.textAlign = Position.ALIGN_CENTER;	
			_public = _creator.demo;
			
			subControls.addChild(listChooser);
			listChooser.addEventListener(Component.EVENT_CLICK, onTabClick);
			if (_creator.demo) listChooser.tabs["mine"].disable();
			
			_searchField = new FormField(null, "Enter search term...", 145, 22, false, bPos2);
			subControls.addChild(_searchField);
			_searchField.selectable = _searchField.editable = true;
			_searchField.restrict = "abcdefghijklmnopqrstuvwxyz0123456789 ";
			_searchField.hide();
			
			_searchButton = new BButton(null, "Go", -1, 35, 22, false, false, false, bPos2, bStyle);
			subControls.addChild(_searchButton);
			_searchButton.addEventListener(Component.EVENT_CLICK, onClick);
			_searchButton.hide();
			
			subControls.addChild(new Cell(null, 25, 24, false, false, 0, Styles.floatPosition));
			
			_reportButton = new BButton(null, "Report", -1, 60, 22, false, false, false, bPos, bStyle);
			subControls.addChild(_reportButton);
			_reportButton.addEventListener(Component.EVENT_CLICK, onClick);
			_reportButton.alt = "Click to report this graphic as inappropriate.";
			
			_likeButton = new BButton(null, "Like", -1, 50, 22, false, false, false, bPos2, bStyle);
			subControls.addChild(_likeButton);
			_likeButton.addEventListener(Component.EVENT_CLICK, onClick);
			_likeButton.alt = "Click if you really like this graphic.";
			
			_confirmButton = new BButton(null, "Add", -1, 50, 22, false, false, false, bPos2, bStyle);
			subControls.addChild(_confirmButton);
			_confirmButton.addEventListener(Component.EVENT_CLICK, onClick);
			_confirmButton.alt = "Click to add this graphic as a texture for your selected objects";
			
			_moveButton = new ToggleButton(_contentCell.mc, Create.ICON_ARROW_UP, Create.ICON_ARROW_DOWN, false, -1, 22, 22, null, tabStyle);
			_moveButton.x = 596;
			_moveButton.y = -22;
			_moveButton.addEventListener(Component.EVENT_CLICK, onClick);
			_moveButton.alt = "Click to move this panel to the top of the canvas";
			_moveButton.toggledAlt = "Click to move this panel to the bottom of the canvas";
			
			_cancelButton = new BButton(_contentCell.mc, Create.ICON_CLOSE, -1, 22, 22, false, false, false, null, tabStyle);
			_cancelButton.x = 618;
			_cancelButton.y = -22;
			_cancelButton.alt = "Close this panel";
			_cancelButton.addEventListener(Component.EVENT_CLICK, onClick);
			
			_contentCreated = true;
			
		}
		
		//
		//
		public function connect ():void {
			
			addEventListener(EVENT_CONFIRM, _creator.project.onManagerConfirm);
			Creator.playfield.selection.addEventListener(CreatorSelection.SELECTED, onModelSelectionChange);
			
			_listContainer.addEventListener(Component.EVENT_DROP, onDragFromTray);
			_listContainer.addEventListener(Component.EVENT_MOVE, onDragFromTrayMove);
			_listContainer.addEventListener(Component.EVENT_DROP, onDropFromTray);
			
		}
		
		protected function onModelSelectionChange (e:Event = null):void {
			
			_currentSelectionLength = Creator.playfield.selection.length;

			if (_listContainer.selectedMembers.length > 0 && _currentSelectionLength > 0 && Creator.playfield.selection.objects[0].canHaveGraphic) {
				toggleConfirmButton(true);
			} else {
				toggleConfirmButton(false);
			}
			
		}
		
		protected function onClick (e:Event):void {
			
			switch (e.target) {
				
				case (_pageBack):
					_resultStart -= _resultsPerPage;
					_resultStart = Math.max(0, _resultStart);
					loadList();
					break;
					
				case (_pageNext):
					_resultStart += _resultsPerPage;
					_resultStart = Math.min(_resultsTotal, _resultStart);
					loadList();
					break;
				
				case (_cancelButton):
					hide();
					break;
					
				case (_confirmButton):
					confirm();
					break;
					
				case (_likeButton):
					if (_currentProjectID) like(_currentProjectID);
					break;
					
				case (_reportButton):
					if (_currentProjectID) report(_currentProjectID);
					break;
					
				case (_searchButton):
					if (_searchField.value.indexOf("...") == -1 && _searchField.value.length > 2) search();
					break;
					
				case (_moveButton):
					if (!_moveButton.toggled) {
						_tweener.createTween(_contentCell, "y", _contentCell.y, 425, 0.5, false, false, 0, 0, Tween.EASE_OUT, Tween.STYLE_QUAD);
						_moveButton.y = _cancelButton.y = -22;
					} else {
						_tweener.createTween(_contentCell, "y", _contentCell.y, 47, 0.5, false, false, 0, 0, Tween.EASE_OUT, Tween.STYLE_QUAD);
						_moveButton.y = _cancelButton.y = 85;
					}
					break;
					
				case (_cancelButton):
					clearSelectedProject();
					hide();
					break;
			}
			
		}
		
		protected function onTabClick (e:Event):void {
			
			if (_currentTab == listChooser.value) return;
			_currentTab = listChooser.value;
			
			_searchField.hide();
			_searchButton.hide();
			
			_searchMode = "";
			
			switch (listChooser.value) {
				
				case MINE:
					_public = false;
					loadList();
					break;
					
				case ALL:
					_public = true;
					loadList();
					break;
					
				case TAGS:
				case USERS:
					_searchMode = listChooser.value;
					_searchField.show();
					_searchField.text = "";
					_searchField.onBlur();
					_searchButton.show();
					break;
				
			}
			
		}
		
		protected function onDragFromTray (e:Event):void { 
			Creator.playfield.selection.focusObject = null;
		}
		
		protected function onDragFromTrayMove (e:Event):void { 
		
			getFocusObject(e);
		}
		
		private function getFocusObject (e:Event):void {
			
			if (e.target is Collection)
			{
				Creator.playfield.selection.selectNone();
				
				var dropPoint:Point = new Point(Creator.playfield.objectsContainer.mouseX, Creator.playfield.objectsContainer.mouseY);
				var objects:Array = Creator.playfield.map.getNeighborsNear(dropPoint.x, dropPoint.y, 3, 3);
				dropPoint = Creator.playfield.objectsContainer.localToGlobal(dropPoint);
				
				objects.sortOn("zz", Array.DESCENDING | Array.NUMERIC);
				
				var object:CreatorPlayfieldObject;
				
				for (var i:int = 0; i < objects.length; i++ ) {
					
					object = objects[i];
					
					if (object != null && object.hitTestPoint(dropPoint.x, dropPoint.y))
					{
						Creator.playfield.selection.focusObject = object;
						Creator.playfield.selection.select(object, false, object.canHaveGraphic);
							
						if (object.canHaveGraphic)
						{
							CreatorHelp.prompt("Drop the graphic to add it to this " + CreatorFactory.getCreatorSymbolName(object.id + "") + ".");
						} else {
							CreatorHelp.prompt("You can't add custom graphics to this kind of object.");
						}
						break;
					}
				}
				
			} else {
				Creator.playfield.selection.focusObject = null;
			}
		}
		
		
		protected function onDropFromTray (e:Event):void { 
			
			var i:int;
			
			getFocusObject(e);
			
			if (Creator.playfield.selection.focusObject == null && _creator.ui.stage.mouseX > 120) {
				_creator.ddalert.show("You can only drop graphics onto objects that are on the playfield!");
				return;
			}
			
			if (Creator.playfield.selection.focusObject) {
				if (Creator.playfield.selection.focusObject.canHaveGraphic) addGraphic(Creator.playfield.selection.focusObject);
				else _creator.ddalert.show("Sorry! This kind of object doesn't currently support custom graphics.");
			}

			CreatorMain.mainStage.focus = Component.mainStage;
				
		} 
		
		public function addGraphic (obj:CreatorPlayfieldObject = null):void {
			
			if (obj && _currentProjectID > 0) {
				
				var texture:BitmapData = Textures.getOriginal(_currentProjectID + "_" + _currentProjectVersion);
				
				var animate:Boolean = (texture && texture.width > texture.height);
				
				obj.graphic = _currentProjectID;
				obj.graphic_version = _currentProjectVersion;
				obj.graphic_animation = (animate) ? 1 : 0;
				
				_creator.graphics.assignGraphicToObject(
						_currentProjectID, 
						_currentProjectVersion, 
						obj
						);
			}
			
		}
		
		protected function getSettings ():void {
			
			loadList();
			
		}
		
		protected function search ():void {
			
			loadList();
			
		}
		
		//
		//
		protected function confirm ():void {
			
			for each (var obj:CreatorPlayfieldObject in Creator.playfield.selection.objects)
			{
				if (obj.canHaveGraphic) addGraphic(obj);
			}
			
		}
		
        //
        //
        protected function getList ():void {
			
			var search:String = "";
			
			if (_searchMode != "" && _searchField.value.length > 0 && _searchField.value.indexOf("...") == -1) {
				search = "&searchterm=" + escape(_searchField.value) + "&searchmode=" + _searchMode.toLowerCase();
			}
			
			CreatorMain.dataLoader.loadXMLData(
				_listURL + CreatorMain.dataLoader.getCacheString(
					"published=1&num=" + 
					_resultsPerPage + 
					"&start=" + _resultStart + 
					"&userid=" + ((_public || _creator.demo) ? "0" : User.u.toString()) +
					search), 
				true, 
				onListLoaded
				);
				
			_loadingPrompt.show();
   
        }
		
		//
		//
		protected function onListLoaded (e:Event):void {
			
			_loadingPrompt.hide();
			
			_xml = new XMLDocument();
			_xml.ignoreWhite = true;
			_xml.parseXML(e.target.data);
			
			populate();
			
		}
		
		//
		//
		public function loadList (e:Event = null):void {
			
			if (!_contentCreated) createContent();
			
			if (e == null || e.type == EVENT_CONFIRM) {
				
				clearGIFs();
				clearSelectedProject();
				
				_listContainer.deselectObjects();
				_listContainer.clear();
				_serverMessage.hide();
				
				if (!_contentCell.visible) show();
				getList();
				
			}
			
		}
		

        // 
        // 
        // ADDITEM adds an item to the manager
        protected function addItem (xmlRef:XMLNode, itemtype:String, num:int):CollectionItem {
            
			var projID:String = xmlRef.attributes.id;
			var version:String = xmlRef.attributes.version;
			var username:String = (xmlRef.attributes.username) ? xmlRef.attributes.username : User.name;
			
			var thumb_base:String;
			
			if (CreatorMain.preloader.loaderInfo.url.indexOf("sploder") == -1 || CreatorMain.preloader.loaderInfo.url.indexOf("file") != -1) {
				thumb_base = "http://sploder_dev.s3.amazonaws.com/gfx/gif/";
			} else {
				thumb_base = "http://sploder.s3.amazonaws.com/gfx/gif/";
			}
			
			var thumb_url:String = thumb_base + projID + ".gif" + CreatorMain.dataLoader.getCacheString();
			
			var items:Array = _listContainer.addMembers([
				{ 
					icon: thumb_url,
					version: version,
					username: username,
					id: projID
				}
				]);
				
			var item:CollectionItem = _listContainer.members[_listContainer.members.length - 1];
			item.addEventListener(Component.EVENT_M_OVER, onItemRollover);
			item.addEventListener(Component.EVENT_M_OUT, onItemRollout);
			var g:GIFPlayer = new GIFPlayer();
			item.clip = g;
			item.clip.parent.parent.mouseEnabled = item.clip.parent.parent.mouseChildren = false;
			if (xmlRef.attributes["username"]) item.alt = "created by " + xmlRef.attributes.username; 
			g.x = g.y = 4;
			g.scaleX = g.scaleY = 0.5;
			g.addEventListener(FrameEvent.FRAME_RENDERED, onGIFLoaded);
			g.load(new URLRequest(thumb_url));
			_gifPlayers.push(g);
			
			var loading:Sprite = Component.library.getDisplayObject("icon_loading") as Sprite;
			
			if (loading != null) {
				g.parent.addChild(loading);
				loading.x = loading.y = 24;
				loading.scaleX = loading.scaleY = 0.5;
				g.parent.setChildIndex(loading, 0);
			}
			
            return items[0];
            
        }
		
		protected function onItemRollover (e:Event):void {
			
			CreatorHelp.prompt("To use this graphic, drag it onto an object on the playfield.");
			
		}

		protected function onItemRollout (e:Event):void {
			
			CreatorHelp.prompt("");
			
		}
		
		protected function onGIFLoaded (e:Event):void {
			
			if (e.target && e.target["parent"]) {

				if (e.target is GIFPlayer)
				{
					var g:GIFPlayer = e.target as GIFPlayer;
					if (g.width == 0) return;
					
					g.removeEventListener(FrameEvent.FRAME_RENDERED, onGIFLoaded);
					var loading:Sprite = DisplayObject(e.target).parent.getChildByName("loading") as Sprite;
					if (loading && loading.parent) loading.parent.removeChild(loading); 
					g.width = g.height = 40;
				}
			}
		
		}
    
        // 
        // 
        // POPULATE populates the manager with items when its XML has loaded
        public function populate ():void {
            
			var XMLref:XMLNode ;
			
            trace("populating manager");
           
			_items = { };
			
			if (_xml != null && _xml.firstChild != null) {
					
				_resultsTotal = parseInt(_xml.firstChild.attributes.total);
				
				if (_xml.firstChild.attributes.start != undefined) {
					_resultStart = parseInt(_xml.firstChild.attributes.start);
				} else {
					_resultStart = 0;
				}
				
				if (_xml.firstChild.attributes.num != undefined) {
					_resultsNum = parseInt(_xml.firstChild.attributes.num);	
					_totalPages = Math.ceil(_resultsTotal / _resultsNum);
				} else {
					_resultsNum = _resultsTotal;
					_pageNum = _totalPages = 1;
				}
				
				if (_resultStart == 0) {
					_pageNum = 1;
					_pageBack.disable();
				} else {
					_pageNum = Math.ceil(_resultStart / _resultsNum) + 1;
					_pageBack.enable();
				}
				
				if ((_resultStart + _resultsNum) >= _resultsTotal) {
					_pageNext.disable();
				} else {
					_pageNext.enable();
				}

				XMLref = _xml.firstChild.firstChild;
				
			}
            
            // if there are objects that have been found
            if (XMLref != null) {
                
                var itemType:String = XMLref.nodeName;
                trace(XMLref);
                _totalItems = 0;
                
                while (XMLref != null) {
                    
					_items[XMLref.attributes.id] = addItem(XMLref, itemType, _totalItems);
                    _totalItems++;
                    XMLref = XMLref.nextSibling;
					if (_currentProjectID > 0 && 
						XMLref != null && 
						XMLref.attributes.id == _currentProjectID.toString()) selectProject(XMLref.attributes.id);
                    
                }
                
            } else { // if no objects found
            
				showServerMessage("No graphics found. Choose the 'All' tab below, or <a href=\"/free-graphics-editor.php\" target=\"_blank\">make your own graphics!</a>");
				_serverMessage.show();

				if (_resultStart == 0) _pageBack.disable();
				else _pageBack.enable();
				_pageNext.disable();

                
            }
			
        }

		//
		//
		protected function onThumbError (e:IOErrorEvent):void {

			var projID:String = String(e.toString()).split("thumbs/")[1].split(".png")[0];

			var c:Container = _items[projID];
			
			//if (c.clip != null && c.clip["thumbnail"] != null) c.clip["thumbnail"].proxy.addChild(Creator.UIlibrary.getDisplayObject("notfound"));		

		}
        
		//
		//
        protected function onProjectSelect (e:Event):void {
			
            selectProject();

        }	
		
		//
		//
		protected function selectProject (projID:String = null):void {
			
			if (projID != null || _listContainer.selectedMembers.length > 0) {
				
				_selectedProject = (projID != null) ? _items[projID] : _listContainer.selectedMembers[0];
				
				var ref:Object = _selectedProject.reference;
				
				_currentProjectID = ref.id;
				_currentProjectVersion = ref.version;
				_currentProjectUsername = ref.username;
				
				onModelSelectionChange();
				
				var liked:Boolean = (Settings.loadSetting("lk_g_" + _currentProjectID) != null);
				if (!liked) toggleLikeButton(true);
				
				var reported:Boolean = (Settings.loadSetting("rp_g_" + _currentProjectID) != null);
				if (!reported) toggleReportButton(true);
				
			} else {
				
				clearSelectedProject();
				
			}

		}
		
		protected function clearSelectedProject():void {
			
			_selectedProject = null;
			_currentProjectID = 0;
			_currentProjectVersion = 0;
			_currentProjectUsername = "";
			toggleConfirmButton(false);
			toggleLikeButton(false);
			toggleReportButton(false);
			
		}
		
		//
		//
		protected function like (projID:uint):void {
			
			if (projID) {
				Settings.saveSetting("lk_g_" + projID, true);
				toggleLikeButton(false);
				var likeLoader:URLLoader = new URLLoader();
				CreatorMain.dataLoader.send("/graphics/feedback.php", "projid=" + projID + "&action=like", true);
			}
			
		}

		//
		//
		protected function report (projID:uint):void {
			
			if (projID) {
				Settings.saveSetting("rp_g_" + projID, true);
				toggleReportButton(false);
				CreatorMain.dataLoader.send("/graphics/feedback.php", "projid=" + projID + "&action=report", true);
			}
			
		}
		
		//
		//
		protected function toggleLikeButton (on:Boolean = false):void {
			
			if (on && _public) {
				_likeButton.enable();
			} else {
				_likeButton.disable();
			}
			
		}
		
		//
		//
		protected function toggleReportButton (on:Boolean = false):void {
			
			if (on && _public) {
				_reportButton.enable();
			} else {
				_reportButton.disable();
			}
			
		}
		
		//
		//
		protected function toggleConfirmButton (on:Boolean = false):void {
			
			if (on) {
				_confirmButton.enable();
			} else {
				_confirmButton.disable();	
			}
			
		}
		
		//
		//
		protected function showServerMessage (msg:String = ""):void {
			
			_serverMessage.value = "<br /><p align=\"center\"><b>" + msg + "</b></p>";
			_serverMessage.show();
			
		}
		
		public function show ():void {
			
			if (!_contentCreated) createContent();
			
			_contentCell.show();
			
			//if (_creator.uiController) _creator.uiController.keyboardEnabled = false;

			_resultStart = 0;
			
			clearSelectedProject();
			
			_loadingPrompt.hide();
			_serverMessage.hide();
			
			getSettings();
			
			if (_listContainer) _listContainer.allowKeyboardEvents = false;
			
		}
		
		protected function clearGIFs ():void {
			
			var i:int = _gifPlayers.length;
			var g:GIFPlayer;
			
			while (i--) {
				g = _gifPlayers.pop();
				g.stop();
				g.dispose();
				if (g.parent) g.parent.removeChild(g);
			}			
			
		}
		
		public function hide():void 
		{
			_contentCell.hide();
			//if (_creator.uiController) _creator.uiController.keyboardEnabled = true;
			CreatorMain.mainStage.focus = Component.mainStage;
			
			clearGIFs();
			
			if (_listContainer) _listContainer.allowKeyboardEvents = false;
			
			if (_creator.graphicsPanelToggle &&
				_creator.graphicsPanelToggle.toggled) _creator.graphicsPanelToggle.toggle();
			
		}
		
	}
	
}