package com.sploder.builder.ui {
	
	import com.sploder.builder.Creator;
	import com.sploder.builder.CreatorMain;
	import com.sploder.builder.Styles;
	import com.sploder.asui.*;
	import com.sploder.SignString;
	import com.sploder.util.StringUtils;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	import neoart.flectrum.Flectrum;
	import neoart.flectrum.SoundEx;
	import neoart.flod.ModProcessor;
	

	
	public class DialogueMusicManager extends Dialogue {
		
		public static const EVENT_SELECT:String = "select";
		public static const EVENT_REMOVE:String = "remove";
		public static const EVENT_CONFIRM:String = "confirm";
		
		public function get title ():String {
			if (dbox && dbox.titleField) return dbox.titleField.value;
			return "";
		}
		public function set title(value:String):void {
			if (dbox && dbox.titleField) dbox.titleField.value = '<p align="center"><h3>' + value + '</h3></p>';
		}
		
		protected var _nameFieldSelectable:Boolean = false;
		
		protected var _loadingPrompt:HTMLField;
		protected var _serverMessage:HTMLField;
		protected var _cancelButton:BButton;
		protected var _removeButton:BButton;
		protected var _confirmButton:BButton;
		protected var _pageBack:BButton;
		protected var _pageNext:BButton;
		
		protected var _listContainer:Collection;
		protected var _nameField:FormField;
		
		protected var _xml:XMLDocument;
		protected var _xmlFeatured:XMLDocument;
		
		protected var _listURL:String = "";
		public function get listURL():String { return _listURL; }
		public function set listURL(value:String):void { _listURL = value; }
	
		protected var _listParamString:String = "";
		public function get listParamString():String { return _listParamString; }
		public function set listParamString(value:String):void { _listParamString = value; }
		
		protected var _groupType:String = "";
		
		protected var _items:Object;
		protected var _totalItems:int = 0;
		protected var _resultStart:int = 0;
		protected var _resultsPerPage:int = 7;
		protected var _resultsNum:int = 0;
		protected var _resultsTotal:int = 0;
		protected var _featuredTotal:int = 0;

		protected var _selectedTrack:CollectionItem;
		
		protected var _currentMusicTrack:String = "";
		
		private var _nameFieldTitle:HTMLField;
		public function get currentMusicTrack():String { return _currentMusicTrack; }
		public function set currentMusicTrack(value:String):void { _currentMusicTrack = value; }
		
		public var currentTrackURL:String = "";
		
		//	Required to replay a mod
		private var stream:ByteArray;
		private var processor:ModProcessor;
		private var songLoader:URLLoader;
		private var songInterval:int;
		private var _populating:Boolean;
		private var sound:SoundEx;
		private var flectrum:Flectrum;
		private var tabs:TabGroup;
		private var featured:Boolean = true;
		
		//
		//
		public function DialogueMusicManager (creator:Creator, width:int = 300, height:int = 300, title:String = "Title", buttons:Array = null) 
		{
			super(creator, width, height, title, buttons);
		}
		
		override public function create():void 
		{
			scroll = false;
			super.create();
			
			dbox.contentPadding = 18;
			dbox.contentBottomMargin = 115;
			dbox.contentHasBackground = true;
			dbox.contentHasBorder = true;
			_creator.uiContainer.addChild(dbox);
			dbox.addButtonListener(Component.EVENT_CLICK, onClick);
			
			hide();
			
		}
		
		public function createContent():void 
		{
			if (_contentCreated) return;
			
			dbox.contentCell.y += 30;
			
			var colStyle:Style = new Style( {
				padding: 10,
				round: 10,
				highlightTextColor: 0xffffff,
				selectedButtonBorderColor: 0xffffff
			 } );
			
			_listContainer = new Collection(null, 267, NaN, 287, 34, 2, new Position ( { placement: Position.PLACEMENT_ABSOLUTE, margin_left: 3, margin_bottom: 0 } ), colStyle);
			_listContainer.allowDrag = false;
			_listContainer.allowRearrange = false;
			_listContainer.defaultItemComponent = "Clip";
			
			_listContainer.defaultItemStyle = new Style ( {
				padding: 5,
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
			
			dbox.contentCell.addChild(_listContainer);
			_listContainer.x = 3;
			
			_listContainer.addEventListener(Component.EVENT_SELECT, onTrackSelect);
				
			var subControls:Cell = new Cell(null, _width - 35, 50, false, false, 0, new Position( { margin_left: 20, margin_top: 25 } ));
			dbox.addChild(subControls);
				
			_nameFieldTitle = new HTMLField(null, '<h3>SELECTED MUSIC:</h3>', 160, false, Styles.floatPosition.clone( { margin_top: 30 } ), Styles.dialogueStyle.clone( { titleFontSize: 11, titleColor: 0xffec00 } ) );
			subControls.addChild(_nameFieldTitle);
			
			var pbPos:Position = new Position(null, 
				Position.ALIGN_RIGHT, 
				Position.PLACEMENT_FLOAT_RIGHT, 
				Position.CLEAR_NONE, "10 0 10 0");
			
			var pbStyle:Style = Styles.dialogueStyle.clone();
			pbStyle.buttonColor = 0;
			pbStyle.padding = 0;
			pbStyle.inactiveColor = 0;
			pbStyle.unselectedColor = 0;
			
			_pageBack = new BButton(null, { icon: Create.ICON_ARROW_RIGHT, text: "BACK" }, -1, 70, 26, false, false, false, pbPos, pbStyle);
			subControls.addChild(_pageBack);
			_pageBack.addEventListener(Component.EVENT_CLICK, onClick);
			
			_pageNext = new BButton(null, { icon: Create.ICON_ARROW_LEFT, text: "NEXT", first: "false" }, -1, 70, 26, false, false, false, pbPos, pbStyle);
			subControls.addChild(_pageNext);
			_pageNext.addEventListener(Component.EVENT_CLICK, onClick);
			
			_nameField = new FormField(null, "None selected...", 225, 30, true, new Position( { margin_top: 10 } ));
			_nameField.x = 20;
			_nameField.y = 285;
			_nameField.restrict = "a-z A-Z 0-9";
			_nameField.maxChars = 35;
			subControls.addChild(_nameField);
			
			_loadingPrompt = new HTMLField(null, "<br><br><br><p align=\"center\"><h1>Loading...</h1></p>", 267, true, null, Styles.dialogueStyle);
			dbox.addChild(_loadingPrompt);
			_loadingPrompt.x = 20;
			_loadingPrompt.y = 60;
			
			_serverMessage = new HTMLField(null, "<p align=\"center\"><h1>Server message</h1></p>", 267, true, null, Styles.dialogueStyle);
			dbox.addChild(_serverMessage);
			_serverMessage.x = 20;
			_serverMessage.y = 100;
			
			var tabStyle:Style = Styles.dialogueStyle.clone();
			tabStyle.unselectedTextColor = 0xcccccc;
			
			tabs = new TabGroup(dbox.mc, ["Featured", "All"], null, 0, 30, false, Styles.absPosition, tabStyle);
			tabs.x = 18;
			tabs.y = 42;
			tabs.addEventListener(Component.EVENT_CLICK, onClick);
			
			sound = new SoundEx();
			
			flectrum = new Flectrum(sound, 8);
			flectrum.rowSpacing = 0;
			flectrum.columnSpacing = 2;
			flectrum.showBackground = true;
			flectrum.backgroundBeat = false;
			flectrum.x = 258;
			flectrum.y = 376;
			flectrum.width = 55;
			flectrum.height = 30;
			dbox.mc.addChild(flectrum);
			
			_contentCreated = true;
			
			connect();
			
		}
		
		//
		//
		protected function connect ():void {
			
			_cancelButton = dbox.buttons[0];
			_removeButton = dbox.buttons[1];
			_confirmButton = dbox.buttons[2];
			
			dbox.addEventListener(Component.EVENT_BLUR, onBlur);
			
		}
		
		protected function onBlur (e:Event):void {
			
			if (processor) {
				processor.stop();
				processor = null;
			}
			
		}
		
		override protected function onClick (e:Event):void {
			
			switch (e.target) {
				
				case (tabs):
					var f:Boolean = featured;
					featured = (tabs.value == "Featured");
					if (f != featured) {
						_resultStart = 0;
						loadList();
					}
					break;
				
				case (_pageBack):
					_resultStart -= _resultsPerPage;
					_resultStart = Math.max(0, _resultStart);
					loadList();
					break;
					
				case (_pageNext):
					_resultStart += _resultsPerPage;
					_resultStart = Math.min(_resultsNum - _resultsPerPage, _resultStart);
					loadList();
					break;
				
				case (_cancelButton):
					hide();
					break;
					
				case (_removeButton):
					removeMusic();
					break;
					
				case (_confirmButton):
					confirm();
					break;
				
			}
			
		}
		
		//
		//
		protected function removeMusic ():void {
			
			Creator.levels.music = "";
			_currentMusicTrack = "";
			currentTrackURL = "";
			_nameField.value = "None selected...";
			hide();
			
		}
		
		//
		//
		protected function confirm ():void {
			
			Creator.levels.music = currentTrackURL;
			hide();
			
		}
		
        //
        //
        protected function getList ():void {

			CreatorMain.dataLoader.loadXMLData(
				_listURL + CreatorMain.dataLoader.getCacheString(), 
				true, 
				onListLoaded
				);
				
			_loadingPrompt.show();
   
        }
		
		//
		//
		protected function onListLoaded (e:Event):void {
			
			_loadingPrompt.hide();
			
			e.target.data = String(e.target.data).split("\r").join("");
			
			var lines:Array = String(e.target.data).split("\n");
			var meta:Object = { };
			var i:int;
			var tag:Array;
			var id:String;
			
			i = lines.length;
			while (i--) {
				if (String(lines[i]).indexOf("http://") != -1) {
					tag = String(lines[i]).split("\\");
					meta[tag[0]] = tag[1];
					lines.splice(i, 1);
				}
			}
			
			var xmlString:String = "<tracks total=\"" + lines.length + "\">\n";
			var featuredXMLString:String = "<tracks total=\"$total\">\n";
			var tracks:Array = [];
			var featuredTracks:Array = [];
			var c_title:String = "";
			var c_url:String = "";
			
			for (i = 0; i < lines.length; i++) {
				tag = String(lines[i]).split("\\");
				c_url = String(lines[i]).split("\\").join("/").split("?featured=1").join("");
				id = SignString.sign(c_url);
				c_title = String(tag[1]).split("?")[0];
				if (tag && tag.length > 1) {
					tracks.push("\t" + '<track title="' + c_title + '" author="' + tag[0] + '" url="' + c_url + '" author_url="' + meta[tag[0]] + '" id="' + id + '" />' + "\n");
					if (String(lines[i]).indexOf("?featured=1") != -1) featuredTracks.push("\t" + '<track title="' + c_title + '" author="' + tag[0] + '" url="' + c_url + '" author_url="' + meta[tag[0]] + '" id="' + id + '" />' + "\n");
				}
			}
			
			tracks.sort();
			featuredTracks.sort();
			
			xmlString += tracks.join("");
			xmlString += "</tracks>";
			
			featuredXMLString += featuredTracks.join("");
			featuredXMLString += "</tracks>";
			
			_xml = new XMLDocument();
			_xml.ignoreWhite = true;
			_xml.parseXML(xmlString);
			
			_xmlFeatured = new XMLDocument();
			_xmlFeatured.ignoreWhite = true;
			_xmlFeatured.parseXML(featuredXMLString);
			
			_resultsTotal = tracks.length;
			_resultsNum = _featuredTotal = featuredTracks.length;
			
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
			
			_currentMusicTrack = "";
		}
		
		//
		//
		public function loadList (e:Event = null):void {
			
			if (!_contentCreated) createContent();
			
			currentTrackURL = Creator.levels.music;
			
			if (currentTrackURL) {
				_currentMusicTrack = SignString.sign(currentTrackURL);
				_nameField.value = currentTrackURL.split("/")[1];
			} else {
				_currentMusicTrack = "";
				_nameField.value = "None selected...";
			}
			
			if (e == null || e.type == EVENT_CONFIRM) {
				
				if (_xml == null) {
					
					_listContainer.clear();
					_selectedTrack = null;
					getList();
					
				} else {
					
					_listContainer.clear();
					populate();
					
				}
				
			}
			
		}
		

        // 
        // 
        // ADDITEM adds an item to the manager
        protected function addItem (xmlRef:XMLNode, itemtype:String, num:int):CollectionItem {
            
			var title:String = com.sploder.util.StringUtils.titleCase(unescape(xmlRef.attributes.title).split(".mod").join("").split("-").join(" "));
            var author:String = xmlRef.attributes.author;
			var url:String = xmlRef.attributes.url;
			var author_url:String = xmlRef.attributes.author_url;
			
			var items:Array = _listContainer.addMembers([
				{ 
					id: xmlRef.attributes.id,
					title: "<p><font face=\"Myriad Web Bold\">" + title + "</font></p>", 
					raw_title: title,
					url: url,
					icon: "icon_musictrack",
					link: author_url,
					credit: author
				}
				]);
			
            return items[0];
            
        }
    
        // 
        // 
        // POPULATE populates the manager with items when its XML has loaded
        public function populate ():void {
            
			_pageBack.disable();
			_pageNext.disable();
			
			var XMLref:XMLNode;
			
            _populating = true;
			
			_items = { };
			
			if (_xml != null && _xml.firstChild != null && _xmlFeatured != null && _xmlFeatured.firstChild != null) {
					
				_groupType = "music tracks";
				_resultsNum = (featured) ? _featuredTotal : _resultsTotal;
				
				XMLref = (featured) ? _xmlFeatured.firstChild.firstChild : _xml.firstChild.firstChild;	
				
			}
			
			if (_resultStart > 0) _pageBack.enable();
			if (_resultStart < _resultsNum - _resultsPerPage) _pageNext.enable();
            
            // if there are objects that have been found
            if (XMLref != null) {
                
                var itemType:String = XMLref.nodeName;
                var i:int = 0;
                _totalItems = 0;
				
                while (XMLref != null) {
                    
					if (i >= _resultStart) {
						
						_items[XMLref.attributes.id] = addItem(XMLref, itemType, _totalItems);
						_totalItems++;
							
					}
					
					XMLref = XMLref.nextSibling;
					
					
					i++;
					
					if (i >= _resultStart + _resultsPerPage) break;
                    
                }
				
				if (_currentMusicTrack != null && _items[_currentMusicTrack]) {
						
					_listContainer.selectObject(_items[_currentMusicTrack]);	
		
				}
					
                
            } else { // if no objects found
            
				var stext:String = "No music tracks found.";
				
				showServerMessage(stext);
				_serverMessage.show();
				
            }
			
			//dbox.scrollbar.reset();
			_listContainer.contents.y = 3;
			
			_populating = false;
            
        }

		//
		//
        protected function onTrackSelect (e:Event):void {
			
            if (!_populating) selectTrack();

        }	
		
		//
		//
		protected function selectTrack (id:String = null):void {
			
			if (id != null || _listContainer.selectedMembers.length > 0) {
				
				_selectedTrack = (id != null) ? _items[id] : _listContainer.selectedMembers[0];
				
				var ref:Object = _selectedTrack.reference;
				
				_currentMusicTrack = ref.id;
				currentTrackURL = ref.url;
				
				if (_xml.idMap[_currentMusicTrack]) {
					
					_nameField.value = "Loading...";
					
					if (songLoader) {
						try { songLoader.close(); } catch (e:Error) { };
						songLoader = null;
						if (processor) {
							processor.stop();
							processor = null;
						}
					}
					
					clearInterval(songInterval);
					songInterval = setInterval(loadSongReady, 100);
					
				}
				
				toggleConfirmButton(true);
				
			} else {
				
				if (songLoader) {
					try { songLoader.close(); } catch (e:Error) { };
					songLoader = null;
					clearInterval(songInterval);
				}
				if (processor) processor.stop();
				
				_selectedTrack = null;
				_currentMusicTrack = "";
	
				setNameFieldDefault();
				toggleConfirmButton(false);
				
			}


		}
		
		protected function loadSongReady ():void {
			
			clearInterval(songInterval);
			
			if (!dbox.visible) return;
			
			if (CreatorMain.dataLoader && _currentMusicTrack && _items[_currentMusicTrack]) {
				
				songLoader = new URLLoader();
				songLoader.addEventListener(Event.COMPLETE, onSongLoaded, false, 0, true);
				songLoader.addEventListener(IOErrorEvent.IO_ERROR, onSongError, false, 0, true);
				songLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSongError, false, 0, true);
				songLoader.dataFormat = URLLoaderDataFormat.BINARY;
				songLoader.load(new URLRequest(CreatorMain.dataLoader.baseURL + "/music/modules/" + _items[_currentMusicTrack].reference.url));
			
			}
			
		}
		
		protected function onSongLoaded (e:Event):void {
			
			if (_xml.idMap && _xml.idMap[_currentMusicTrack]) {
				_nameField.value = unescape(_xml.idMap[_currentMusicTrack].attributes.title)
			}
			
			if (processor) processor.stop();
			
			if (!dbox.visible) return;
			
			processor = new ModProcessor();
			
			if (songLoader.data) {
				processor.load(songLoader.data);
				processor.loopSong = true;
				processor.play(sound);
				processor.externalReplay
			}
			
		}
		
		protected function onSongError (e:Event):void {
			
			_nameField.value = "Error loading track...";
			
		}
		
		//
		//
		protected function setNameFieldDefault ():void {
			
			if (_selectedTrack == null) {
				_nameField.value = "None selected...";
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
			
			_serverMessage.value = "<p align=\"center\"><h1>" + msg + "</h1></p>";
			_serverMessage.show();
			
		}
		
		//
		//
		override public function show():void 
		{
			if (!_contentCreated) createContent();
			super.show();
			
			if (_listContainer) _listContainer.deselectObjects();
	
			_selectedTrack = null;
			_currentMusicTrack = null;
			currentTrackURL = Creator.levels.music;
			_resultStart = 0;
			_loadingPrompt.hide();
			_serverMessage.hide();
			_nameField.selectable = _nameFieldSelectable;
			onTitleChanged();
			
			
			if (_xml == null) {
				loadList();
			} else {
				if (currentTrackURL) {
					var i:int;
					var foundInFeatured:Boolean = false;
					for (i = 0; i < _xmlFeatured.firstChild.childNodes.length; i++) {
						if (currentTrackURL == _xmlFeatured.firstChild.childNodes[i].attributes.url) {
							_resultStart = Math.floor(i / _resultsPerPage) * _resultsPerPage;
							foundInFeatured = true;
							featured = true;
							break;
						}
					}
					if (!foundInFeatured) {
						for (i = 0; i < _xml.firstChild.childNodes.length; i++) {
							if (currentTrackURL == _xml.firstChild.childNodes[i].attributes.url) {
								_resultStart = Math.floor(i / _resultsPerPage) * _resultsPerPage;
								featured = false;
								break;
							}
						}
					}
					if (featured) tabs.select("featured");
					else tabs.select("all");
					loadList();
					loadSongReady();
				}
			}
			
			setNameFieldDefault();
						
			if (_listContainer) _listContainer.allowKeyboardEvents = true;
			
		}
		
		override public function hide():void 
		{
			super.hide();
			
			if (processor) {
				processor.stop();
				processor = null;
			}
			
			if (_listContainer) _listContainer.allowKeyboardEvents = false;
			
		}
		
	}
	
}