package com.sploder.builder.ui 
{
	import com.sploder.builder.Creator;
	import com.sploder.builder.CreatorMain;
	import com.sploder.builder.Styles;
	import com.sploder.asui.Component;
	import com.sploder.asui.Create;
	import com.sploder.asui.Position;
	import com.sploder.asui.Style;
	import com.sploder.util.Cleanser;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import com.sploder.asui.Cell;
	import com.sploder.asui.BButton;
	import com.sploder.asui.FormField;
	
	
	/**
	 * ...
	 * @author Geoff Gaudreault
	 */
	public class PanelLevelName extends EventDispatcher 
	{
		private var _creator:Creator;
		
		protected var _contentCell:Cell;
		protected var _contentCreated:Boolean = false;
		private var _searchField:FormField;
		private var _searchButton:BButton;
		protected var _cancelButton:BButton;
		
		public function PanelLevelName (creator:Creator) 
		{
			init(creator);
		}
		
		protected function init (creator:Creator):void {
			
			_creator = creator;
			
		}
		
		public function create (container:Cell):void 
		{
			_contentCell = new Cell(null, 300, 42, true, false, 0, Styles.absPosition.clone( { top: 31, left: 0 } ), Styles.dialogueStyle);
			container.addChild(_contentCell);
			createContent();
			hide();
		}
		
		public function createContent():void 
		{
			if (_contentCreated) return;
			
			var pbStyle:Style = Styles.dialogueStyle.clone();
			pbStyle.buttonColor = 0;
			pbStyle.padding = 0;
			
			var bStyle:Style = Styles.dialogueStyle.clone();
			bStyle.padding = 2;
			
			var bPos2:Position = Styles.floatPosition.clone( { margin_top: 8, margin_left: 8 } );
			
			_searchField = new FormField(null, "Enter level name...", 200, 22, false, bPos2);
			_contentCell.addChild(_searchField);
			_searchField.selectable = _searchField.editable = true;
			_searchField.restrict = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ";
			
			_searchButton = new BButton(null, "Go", -1, 35, 22, false, false, false, bPos2, bStyle);
			_contentCell.addChild(_searchButton);
			_searchButton.addEventListener(Component.EVENT_CLICK, onClick);
			
			_cancelButton = new BButton(null, Create.ICON_CLOSE, -1, 22, 22, false, false, false, bPos2, bStyle);
			_cancelButton.alt = "Close this panel";
			_cancelButton.addEventListener(Component.EVENT_CLICK, onClick);
			
			_contentCell.addChild(_cancelButton);
			
			_contentCreated = true;
			
		}
		
		protected function onClick (e:Event):void {
			
			switch (e.target) {
				
				case (_cancelButton):
					hide();
					break;
					
				case (_searchButton):
					if (_searchField.value.indexOf("...") == -1 && _searchField.value.length > 2) {
						applySettings();
						hide();
					}
					break;
			}
			
		}
		
		private function applySettings ():void {
			
			if (_searchField.value.indexOf("...") == -1 && _searchField.value.length > 2) Creator.levels.currentLevelName = Cleanser.cleanse(_searchField.value);
		}
		
		protected function getSettings ():void {
			
			_searchField.value = Cleanser.cleanse(Creator.levels.currentLevelName);
			
		}
		
				
		public function show ():void {
			
			if (!_contentCreated) createContent();
			
			_contentCell.show();
			
			getSettings();	

		}
		
		
		public function hide():void 
		{
			_contentCell.hide();
			
			CreatorMain.mainStage.focus = Component.mainStage;
			
		}
		
		
	}

}