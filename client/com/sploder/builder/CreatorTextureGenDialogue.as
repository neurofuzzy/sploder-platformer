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
	import com.sploder.texturegen_internal.TextureAttributes;
	import com.sploder.util.ObjectEvent;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.SecurityDomain;
	
	import flash.display.Loader;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
		
	/**
	 * ...
	 * @author Geoff
	 */
	public class CreatorTextureGenDialogue extends CreatorDialogue
	{
		protected var _loaded:Boolean = false;
		protected var _loader:Loader;
		
		public var attribs:TextureAttributes;
		public var tileBack:Boolean;
		
		public function CreatorTextureGenDialogue(creator:Creator, container:Sprite) 
		{
			super(creator, container);
			
			tileBack = false;
		}
		
		override protected function init(creator:Creator, container:Sprite):void 
		{
			super.init(creator, container);
			
			
		}
		
		protected function onEvent (e:Event):void {
			
			trace(e);
			
		}
		
		override protected function applySettings():void 
		{
			
			
		}
		
		override public function show(msg:String = null, servermsg:String = null):void 
		{
			super.show(msg, servermsg);
			
			if (_loader == null)
			{
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				
				var context:LoaderContext = new LoaderContext();
				context.allowCodeImport = true;
				context.parameters = { textureData: attribs.serialize() };
				_loader.loadBytes(new Creator.mainInstance.TextureGenSWF(), context);
			} else {
				_loader.content.dispatchEvent(new ObjectEvent("texture_change", false, false, attribs.serialize()));
			}	
		}
		
		override public function hide():void 
		{
			super.hide();
			
		}
		
		private function completeHandler(e:Event):void {
			_loaded = true;
			_container.addEventListener(Event.ENTER_FRAME, onLoadWait);
		}
		
		private function onLoadWait (e:Event):void
		{
			_container.removeEventListener(Event.ENTER_FRAME, onLoadWait);
			
			_loader.x = -80;
			_loader.y = -40;
			_container.addChild(_loader);
			
			_loader.addEventListener(Event.CANCEL, onCancel);
			_loader.addEventListener(Event.COMPLETE, onComplete);
		}

		private function ioErrorHandler(e:Event):void {
			_loaded = false;
			_loader = null;
			trace("loader error " + e);
		}

		private function securityErrorHandler(e:Event):void {
			_loaded = false;
			_loader = null;
			trace("loader error " + e);
		}
		
		private function onCancel (e:Event):void {
			hide();
		}
		
		private function onComplete (e:ObjectEvent):void
		{
			_creator.objTray.updateTextureAdders(e.relatedObject + "", tileBack);
			
			var sel:CreatorSelection = Creator.playfield.selection;
			var obj:CreatorPlayfieldObject;
			
			if (sel.length > 0)
			{
				for (var i:int = 0; i < sel.objects.length; i++)
				{
					obj = sel.objects[i];
					if (obj.textureAttribs != null && obj.tileBack == tileBack)
					{
						obj.textureAttribs.unserialize(e.relatedObject + "");
						obj.updateTextureOnly();
						trace("updating object " + i);
					}
				}
			}
			hide();
		}
		
	}

}