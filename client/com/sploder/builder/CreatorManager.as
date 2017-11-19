package com.sploder.builder {
	
	import com.sploder.data.User;
	import com.sploder.asui.*;
	import flash.display.Loader;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;

	
	public class CreatorManager extends EventDispatcher {
		
		public static const EVENT_SELECT:String = "select";
		public static const EVENT_CONFIRM:String = "confirm";
		
		public static const MODE_LOAD:int = 1;
		public static const MODE_SAVE:int = 2;
		
		protected var _creator:Creator;
		protected var _container:Sprite;
		
		protected var _title:String = "";
		public function get title():String { return _title; }
		public function set title(value:String):void {
			_title = value;
			if (_titleField != null) _titleField.text = _title;
		}
		
		protected var _mode:int = 1;
		
		public function get mode():int { return _mode; }
		
		public function set mode(value:int):void 
		{
			_mode = value;
			if (_mode == MODE_LOAD) {
				_nameField.selectable = false;
			} else {
				_nameField.selectable = true;
			}
		}
		
		protected var _titleField:TextField;
		protected var _loadingPrompt:Sprite;
		protected var _serverMessage:TextField;
		protected var _closeButton:SimpleButton;
		protected var _cancelButton:SimpleButton;
		protected var _confirmButton:SimpleButton;
		protected var _confirmButtonText:Sprite;
		protected var _pageBack:SimpleButton;
		protected var _pageNext:SimpleButton;
		
		protected var _listContainer:Cell;
		protected var _nameField:FormField;
		
		protected var _xml:XMLDocument;
		
		protected var _listURL:String = "";
		public function get listURL():String { return _listURL; }
		public function set listURL(value:String):void { _listURL = value; }
	
		protected var _listParamString:String = "";
		
		protected var _groupType:String = "";
		
		protected var _items:Object;
		
		protected var _totalItems:int = 0;
		protected var _resultStart:int = 0;
		protected var _resultsNum:int = 0;
		protected var _resultsTotal:int = 0;
		protected var _totalPages:int = 0;
		protected var _pageNum:int = 0;
		
		protected var _selectedProject:Container;
		
		protected var _currentProjectID:String = "";
		public function get currentProjectID():String { return _currentProjectID; }
		public function set currentProjectID(value:String):void { _currentProjectID = value; }
		
		public function get currentProjectTitle():String { return _nameField.value; }
		public function set currentProjectTitle(value:String):void { _nameField.value = value; }

		
		//
		//
		public function CreatorManager(creator:Creator, container:Sprite, listURL:String = "", listParamString:String = "") {
			
			init(creator, container, listURL, listParamString);
			
		}
		
		//
		//
		protected function init (creator:Creator, container:Sprite, listURL:String = "", listParamString:String = ""):void {
			
			_creator = creator;
			_container = container;
			_listURL = listURL;
			_listParamString = listParamString;
			
			rigUI();
			
			addEventListener(CreatorManager.EVENT_CONFIRM, _creator.project.onManagerConfirm);

			hide();
			
		}
		
		//
		//
		protected function rigUI ():void {
			
			_titleField = _container["title"];
			_loadingPrompt = _container["loadingprompt"];
			_serverMessage = _container["servermessage"];
			_closeButton = _container["close"];
			_cancelButton = _container["cancel"];
			_confirmButton = _container["ok"];
			_confirmButtonText = _container["confirmtext"];
			_pageBack = _container["pageback"];
			_pageNext = _container["pagenext"];

			_titleField.mouseEnabled = _loadingPrompt.mouseEnabled = _serverMessage.mouseEnabled = _confirmButtonText.mouseEnabled = false;
			
			var c:Cell = new Cell(_container["content"], 427, 250);
			
			_listContainer = new Cell(null, 407, 250);
			c.addChild(_listContainer);
			
			var sb:ScrollBar = new ScrollBar();
			c.addChild(sb);
			sb.targetCell = _listContainer;
			
			_nameField = new FormField(_container, "Enter your game title here...", 402, 25, true);
			_nameField.x = 20;
			_nameField.y = 285;
			_nameField.restrict = "a-z A-Z 0-9";
			_nameField.maxChars = 35;
			
			_loadingPrompt.visible = false;
			
			disableButton(_pageNext);
			disableButton(_pageBack);
			
			_cancelButton.addEventListener(MouseEvent.CLICK, hide);
			_closeButton.addEventListener(MouseEvent.CLICK, hide);
			_confirmButton.addEventListener(MouseEvent.CLICK, confirm);
			_nameField.addEventListener(Component.EVENT_CHANGE, onTitleChanged);
			_nameField.addEventListener(Component.EVENT_FOCUS, onTitleFocus);
			
		}
		
		//
		//
		protected function confirm (e:MouseEvent):void {
			
			dispatchEvent(new Event(EVENT_CONFIRM));
			hide();
			
		}
		
        //
        //
        protected function getList ():void {

			CreatorMain.dataLoader.loadXMLData(
				_listURL + CreatorMain.dataLoader.getCacheString(_listParamString), 
				true, 
				onListLoaded
				);
				
			_loadingPrompt.visible = true;
   
        }
		
		//
		//
		protected function onListLoaded (e:Event):void {
			
			_loadingPrompt.visible = false;
			
			_xml = new XMLDocument();
			_xml.ignoreWhite = true;
			_xml.parseXML(e.target.data);
			
			if (_mode == MODE_SAVE) _nameField.selectable = true;
			
			populate();
			
		}
		
		//
		//
		protected function onTitleChanged (e:Event = null):void {
			
			if (_nameField.value.length > 3 && _nameField.value.indexOf("...") == -1) toggleConfirmButton(true);
			else toggleConfirmButton(false);
			
		}
		
		//
		//
		protected function onTitleFocus (e:Event = null):void {
			
			_currentProjectID = "";
			
			if (_selectedProject != null) {
				_selectedProject.clip["thumbnail"].frame.gotoAndStop("inactive");
			}
			
		}
		
		//
		//
		public function loadList (e:Event = null):void {
			
			if (e != null) _creator.ddconfirm.removeEventListener(CreatorDialogue.EVENT_CONFIRM, loadList);

			if (e == null || e.type == CreatorDialogue.EVENT_CONFIRM) {
				
				_listContainer.clear();
				_selectedProject = null;
				
				show();
				getList();
				
			}
			
		}
		

        // 
        // 
        // ADDITEM adds an item to the manager
        protected function addItem (xmlRef:XMLNode, itemtype:String, num:int):Container {
            
			var clip:Container = new Container(null, Creator.UIlibrary.getDisplayObject("project"));
			_listContainer.addChild(clip);
			
			clip.value = xmlRef.attributes.id;
			
			initProjectIcon(clip, xmlRef, num);
            
            return clip;
            
        }
    
        // 
        // 
        // POPULATE populates the manager with items when its XML has loaded
        public function populate ():void {
            
			var XMLref:XMLNode ;
			
            trace("populating manager");
           
			_items = { };
			
			if (_xml != null && _xml.firstChild != null) {
					
				_groupType = _xml.firstChild.nodeName;
				
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
					disableButton(_pageBack);
				} else {
					_pageNum = Math.ceil(_resultStart / _resultsNum) + 1;
					enableButton(_pageBack);
				}
				
				if ((_resultStart + _resultsNum) >= _resultsTotal) {
					disableButton(_pageNext);
				} else {
					enableButton(_pageNext);
				}

				XMLref = _xml.firstChild.firstChild;
				
			} else {
				
				_groupType = "projects";
				
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
					if (_currentProjectID != null && 
						XMLref != null && 
						XMLref.attributes.id == _currentProjectID) selectProject(XMLref.attributes.id);
                    
                }
                
            } else { // if no objects found
            
                if (_title == "Save Your Game") {
                    
                    _serverMessage.text = "Enter the title of your game below.";
                    _nameField.focus();
                    
                } else {
                    
                    _serverMessage.text = "No " + _groupType + " found.";
    
                    if (_groupType == "projects") {
						if (_mode == MODE_LOAD) {
							_serverMessage.appendText("\nDrag Objects onto your playfield to begin.");
						} else {
							_serverMessage.appendText("\nEnter your game title below.");
						}
                    }
                    
                }
                
            }
            
        }
        
        
        //
        //
        //
        protected function initProjectIcon (clip:Container, xmlRef:XMLNode, num:int):void {

			clip.addEventListener(Component.EVENT_CLICK, onProjectSelect);
            
            if (num % 2 > 0) {
                clip.clip["pbkgd"].visible = false;
            }
            
            clip.clip["title"].text = unescape(xmlRef.attributes.title);
            clip.clip["pdate"].text = xmlRef.attributes.date;
			clip.clip["thumbnail"].frame.gotoAndStop(1);
			
			var projID:String = xmlRef.attributes.id;

			var thumbLoader:Loader = new Loader();
            clip.clip["thumbnail"].proxy.addChild(thumbLoader);
			thumbLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onThumbError);
			//thumbLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onThumbError);
			
			var thumb_base:String = CreatorMain.dataLoader.baseURL;
			if (xmlRef.attributes.archived == "1") thumb_base = "http://sploder.s3.amazonaws.com";
			
			thumbLoader.load(new URLRequest(thumb_base + User.thumbspath + projID + ".png" + CreatorMain.dataLoader.getCacheString()));

        }
		
		//
		//
		protected function onThumbError (e:IOErrorEvent):void {

			var projID:String = String(e.toString()).split("thumbs/")[1].split(".png")[0];

			var c:Container = _items[projID];
			
			if (c.clip != null && c.clip["thumbnail"] != null) c.clip["thumbnail"].proxy.addChild(Creator.UIlibrary.getDisplayObject("notfound"));		

		}
        
		//
		//
        protected function onProjectSelect (e:Event):void {
    
            selectProject(e.target.value);

        }	
		
		//
		//
		protected function selectProject (projID:String):void {
			
			trace("SELECTED:", projID);

			if (_selectedProject != null) {
				if (_selectedProject.clip != null && _selectedProject.clip["thumbnail"] != null) _selectedProject.clip["thumbnail"].frame.gotoAndStop("inactive");
			}
			
			if ((_selectedProject == null || _selectedProject.value != projID) && (projID.length > 0 && _items[projID] is Container)) {
				
				var clip:Container = _items[projID];
				
				try {
					if (clip.clip["thumbnail"] != null) clip.clip["thumbnail"].frame.gotoAndStop("active");
				} catch (e:Error) {
					trace("Error in project thumbnail.");
				}
				
				_selectedProject = clip;
				_currentProjectID = clip.value;
				_nameField.value = unescape(_xml.idMap[_currentProjectID].attributes.title);
				
				toggleConfirmButton(true);
				
			} else {
				
				_selectedProject = null;
				_currentProjectID = "";
	
				setNameFieldDefault();
				toggleConfirmButton(false);
				
			}

		}
		
		public function deselectProject ():void {
			
			_selectedProject = null;
			_currentProjectID = "";
			
			setNameFieldDefault();
			toggleConfirmButton(false);
			
		}
		
		//
		//
		protected function setNameFieldDefault ():void {
			
			if (_selectedProject == null) {
				if (_mode == MODE_LOAD) _nameField.value = "Select a game from the list above...";
				else _nameField.value = "Enter your game title here...";
			}
			
		}
		
		
		//
		//
		protected function toggleConfirmButton (on:Boolean = false):void {
			
			if (on) {
				enableButton(_confirmButton);
				_confirmButtonText.alpha = 1;	
			} else {
				disableButton(_confirmButton);
				_confirmButtonText.alpha = 0.5;			
			}
			
		}
		
		//
		//
		protected function show (e:Event = null):void {
			
			_container.visible = true;
			_creator.ddGraphics.hide();
			_creator.ddLevelName.hide();
			
			_serverMessage.text = "";
			_nameField.selectable = false;
			onTitleChanged();
			setNameFieldDefault();
			
		}
		
		//
		//
		public function hide (e:Event = null):void {
			
			_container.visible = false;
			
		}
		
		//
		//
		protected function disableButton (b:SimpleButton):void {
			
			b.alpha = 0.5;
			b.mouseEnabled = false;
			
		}
		
		//
		//
		protected function enableButton (b:SimpleButton):void {
			
			b.alpha = 1;
			b.mouseEnabled = true;
			
		}
		
	}
	
}