package com.sploder.asui {

    import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class ASUIObject extends Cell {
		
		public function get root():Cell { return this; }
		
		private var _idMap:Object;
		public function get idMap():Object { return _idMap; }
	
		private var _classMap:Object;
		public function get classMap():Object { return _classMap; }

		private var _nameMap:Object;
		public function get nameMap():Object { return _nameMap; }

		public function $(id:String):Component {
			if (_idMap[id] != undefined) return _idMap[id] as Component;
			else return this;
		}

		private var _xmlString:String;
		private var _cssText:String;
		
		public var mainComponent:Component;
		
		//
		//
		public function ASUIObject (container:Sprite, width:Number, height:Number, xmlString:String, cssText:String, position:Position = null, style:Style = null) {
			
			init_ASUIObject(container, width, height, xmlString, cssText, position, style);
			
			if (_container != null) create();
			
		}
		
		//
		//
		private function init_ASUIObject (container:Sprite, width:Number, height:Number, xmlString:String, cssText:String, position:Position = null, style:Style = null):void {
			
			super.init_Cell(container, width, height, false, false, 0, position, style);
			
			_idMap = { };
			_classMap = { };
			_nameMap = { };
			_form = { };

			_width = (width > 0) ? width : (_container.width > 0) ? _container.width : mainStage.stageWidth;
			_height = (height > 0) ? height : (_container.height > 0) ? _container.height : mainStage.stageHeight; 
			
			_xmlString = xmlString;
			_cssText = cssText;
			
		}
		
		//
		//
		override public function create ():void {
			
			super.create();

			ASUIML.create(this, _xmlString, _cssText, _style);
			
		}
		
		
		//
		//
		override public function connect (event:String, target:Component, property:String):void {
			
			if (target.name.length > 0) {
				form[target.name] = (target.value != null) ? target.value : "";
				target.addEventListener(Component.EVENT_CHANGE, onEvent);
				target.addEventListener(Component.EVENT_CLICK, onEvent);
			}
			
		}
		
		//
		//
		public function connectHTMLField (h:HTMLField):void {
			
			var self:Object = this;
			h.addEventListener(Component.EVENT_CLICK, onEvent);

		}
		
		//
		//
		public function mapToClass (c:Component, className:String):void {
			
			if (className.length > 0) {
				
				if (_classMap[className] == undefined) _classMap[className] = [];
				_classMap[className].push(c);
				
			}
			
		}
		
		//
		//
		public function hideAllOfClass (className:String):void {
			
			if (className.length > 0) {
				
				if (_classMap[className] != undefined) {
					
					var members:Array = _classMap[className];
					for each (var c:Component in members) c.hide();

				}
				
			}
			
		}
		
		//
		//
		public function showAllOfClass (className:String):void {
			
			if (className.length > 0) {
				
				if (_classMap[className] != undefined) {
					
					var members:Array = _classMap[className];
					for each (var c:Component in members) c.show();
					
				}
				
			}		
			
		}
		
		//
		//
		public function onEvent (e:Event):void {
			
			var c:Component = Component(e.target);

			if (c is HTMLField && HTMLField(c).linkEvent != "") c.name = HTMLField(c).linkEvent;
			if (c.name.length > 0) form[c.name] = c.value;

			bubble(e);
			
		}
		
		//
		//
		override public function onChildChange(e:Event):void 
		{
			dispatchEvent(new ASUIEvent(EVENT_CHANGE, false, false, e.target as Component));
		}
		
		//
		//
		private function bubble (e:Event):void {
			
			dispatchEvent(new ASUIEvent(e.type, false, false, e.target as Component));
			
		}
		
		//
		//
		override public function show(e:Event = null):void 
		{
			if (mainComponent == null || mainComponent == this) super.show(e);
			else mainComponent.show();
		}
		
		//
		//
		override public function hide(e:Event = null):void 
		{
			if (mainComponent == null || mainComponent == this) super.hide(e);
			else mainComponent.hide();
		}
		
	}
	
}