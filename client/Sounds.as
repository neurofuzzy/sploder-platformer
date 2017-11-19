package 
{

	import flash.display.Sprite;
	import flash.events.Event;
	
	import fuz2d.library.EmbeddedLibrary;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class Sounds extends Sprite 
	{
		[Embed(source = "assets/sounds.swf", mimeType="application/octet-stream")]
		protected var SoundLibrarySWF:Class;
		
		public var library:EmbeddedLibrary;
		
		//
		//
		public function Sounds (preloader:Preloader):void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			preloader.setSFXClass(SoundLibrarySWF);
			
		}
		
		//
		//
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

		}

	}
	
}