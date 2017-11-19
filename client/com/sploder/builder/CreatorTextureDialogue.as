package com.sploder.builder 
{
	import com.sploder.builder.Creator;
	import com.sploder.asui.BButton;
	import com.sploder.asui.Cell;
	import com.sploder.asui.Collection;
	import com.sploder.asui.CollectionItem;
	import com.sploder.asui.Component;
	import com.sploder.asui.Create;
	import com.sploder.asui.HTMLField;
	import com.sploder.asui.Key;
	import com.sploder.asui.Style;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class CreatorTextureDialogue extends CreatorDialogue
	{
		
		protected var _content:Cell;
		protected var _tiles:Collection;
		
		protected var _populated:Boolean = false;
		
		protected var _textures:Array;
		
		protected var _ids:HTMLField;
		
		protected var _prevButton:BButton;
		protected var _nextButton:BButton;
		protected var _applyButton:BButton;
		protected var _closeButton:BButton;
		
		protected var _startTile:int = 110;
		
		public function CreatorTextureDialogue(creator:Creator, container:Sprite) 
		{
			super(creator, container);
		}
		
		override protected function init(creator:Creator, container:Sprite):void 
		{
			super.init(creator, container);
			
			_content = new Cell(_container, 390, 210);
			_content.x = -5;
			_content.y = -5;
			
			_tiles = new Collection(null, 370, 200, 60, 60, 20);
			
			_content.addChild(_tiles);
			
			_ids = new HTMLField(_container, '<p align="center">Tiles 110 - 125</p>', 300);
			_ids.x = 40;
			_ids.y = 220;
			
			_textures = [];
			
			var tile:CollectionItem;
			var texture:CreatorTextureItem;
			var tilenum:int = _startTile;
			var i:int;
			
			for (i = 0; i < 15; i++) {
				texture = new CreatorTextureItem(_creator, tilenum);
				_textures.push(texture);
				tilenum++;
			}
			
			_tiles.addMembers(_textures);

			_prevButton = new BButton(_container, "PREV PAGE");
			_prevButton.addEventListener(Component.EVENT_CLICK, onClick);
			_prevButton.x = 90;
			
			_nextButton = new BButton(_container, "NEXT PAGE");
			_nextButton.addEventListener(Component.EVENT_CLICK, onClick);
			_nextButton.x = 200;
			
			_applyButton = new BButton(_container, "APPLY");
			_applyButton.addEventListener(Component.EVENT_CLICK, onClick);
			_applyButton.x = 320;
			
			_closeButton = new BButton(_container, "CLOSE");
			_closeButton.addEventListener(Component.EVENT_CLICK, onClick);
			_closeButton.x = 0;
			
			_prevButton.y = _nextButton.y = _applyButton.y = _closeButton.y = 260;
			
			
		}
		
		protected function updateTiles ():void {
			
			_ids.value = '<p align="center">Tiles ' + _startTile + ' - ' + (_startTile + 15) + '</p>';
			for (var i:int = 0; i < 15; i++) {
				CreatorTextureItem(_textures[i]).tilenum = _startTile + i;
			}
			
		}
		
		protected function prevPage ():void {
			if (Key.shiftKey) {
				_startTile -= 150;
			} else {
				_startTile -= 15;
			}
			updateTiles();
		}
		
		protected function nextPage ():void {
			if (Key.shiftKey) {
				_startTile += 150;
			} else {
				_startTile += 15;
			}
			updateTiles();
		}
		
		protected function onClick (e:Event):void {
			
			switch (e.target.value) {
				
				case "CLOSE":
					hide();
					break;
					
				case "PREV PAGE":
					prevPage();
					break;
					
				case "NEXT PAGE":
					nextPage();
					break;
					
				case "APPLY":
					applySettings();
					break;
				
				
			}
			
		}
		
		override protected function applySettings():void 
		{
			var selectedTile:CreatorTextureItem = CollectionItem(_tiles.selectedMembers[0]).reference as CreatorTextureItem;
			
			if (selectedTile && !isNaN(selectedTile.tilenum)) {
				
				for (var i:int = 0; i < _creator.objTray.adders.length; i++) {
					
					var adder:CreatorObjectAdder = _creator.objTray.adders[i];
					
					if (adder.isTile) {
						adder.tileID = selectedTile.tilenum;
					}
					
				}
				
			}
			
			_ids.value = '<p align="center">(Applied tile ' + selectedTile.tilenum + ' to tray)</p>';
			
			_creator.cleanBitmapData();
			
		}
		
	}

}