package 
{

	import flash.display.Sprite;
	import flash.events.Event;
	
	import fuz2d.library.EmbeddedLibrary;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class Sounds2 extends Sprite 
	{
		[Embed(source = "assets/sounds2.swf", mimeType="application/octet-stream")]
		protected var SoundLibrarySWF:Class;
		
		public var library:EmbeddedLibrary;
		
		//
		//
		public function Sounds2 (preloader:Preloader):void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			preloader.setSFXClass(SoundLibrarySWF, 2);
			
		}
		
		//
		//
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

		}

	}
	
}