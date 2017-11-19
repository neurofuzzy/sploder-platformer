package fuz2d.sound {
	
	import com.sploder.*;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.*;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest
	import flash.utils.ByteArray;
	import fuz2d.*;
	import fuz2d.action.physics.SimulationObject;
	import fuz2d.action.play.PlayObject;
	import fuz2d.library.EmbeddedLibrary;
	import fuz2d.model.object.Object2d;
	import fuz2d.util.Geom2d;
	import neoart.flod.ModProcessor;
	

    public class SoundManager {

		protected var _library:EmbeddedLibrary;
		protected var _library2:EmbeddedLibrary;
		protected var _focusObj:Object2d;
		
		protected var _initialized:Boolean = false;
		
		public static var baseURL:String = "http://sploder.s3.amazonaws.com/";
		
        private static var _hasSound:Boolean = true;
        public static function get hasSound ():Boolean { return _hasSound; }
        public static function set hasSound (val:Boolean):void { 
			_hasSound = val;
			if (!_hasSound) stopAll();
		}
		
		//	Required to replay a mod
		private var music:Sound;
		private var stream:ByteArray;
		private var processor:ModProcessor;
		private var songLoader:URLLoader;
		
		
        //
        //
        //
        public function SoundManager (librarySWF:Class = null) {
			
			trace("adding sound manager",librarySWF);
			if (librarySWF != null) _library = new EmbeddedLibrary(librarySWF);
			else _library = Fuz2d.library;
			
			
        }
		
		public function addSFX2 (library2SWF:Class):void {
			
			trace("adding sounds set 2");
			if (library2SWF != null && _library2 == null) {
				_library2 = new EmbeddedLibrary(library2SWF);
			}
			
		}
		
		//
		//
		public function getVolume (parentObject:Object):Number {
			
            var volume:Number = 0;
			var modelObj:Object2d;
			
			if (parentObject is Object2d) modelObj = Object2d(parentObject);
			else if (parentObject is PlayObject) modelObj = PlayObject(parentObject).object;
			else if (parentObject is SimulationObject) modelObj = SimulationObject(parentObject).objectRef; 

			if (modelObj != null && _focusObj != null) {
				
				volume = Math.floor(Math.min(100, 5000 / Math.max(1, (Geom2d.distanceBetweenPoints(modelObj.point, _focusObj.point) - 20))));
				return volume * 0.01;
				
				if (volume < 100) {
					
				   pan = Math.max(-100, Math.min(100, (modelObj.x - _focusObj.x) * 0.5));
				   transform.pan = pan * 0.01;
				   
				}
	
			}
			
			return volume;
			
		}
		
		//
		//
		public function adjustSound (parentObject:Object, channel:SoundChannel):void {
			
            var volume:Number = 1;
            var pan:Number = 0;
			var modelObj:Object2d;
			
			if (parentObject is Object2d) modelObj = Object2d(parentObject);
			else if (parentObject is PlayObject) modelObj = PlayObject(parentObject).object;
			else if (parentObject is SimulationObject) modelObj = SimulationObject(parentObject).objectRef; 
			
			var transform:SoundTransform = new SoundTransform();
			transform.volume = 0;
			
			if (modelObj != null && _focusObj != null) {
				
				volume = Math.floor(Math.min(100, 5000 / Math.max(1, (Geom2d.distanceBetweenPoints(modelObj.point, _focusObj.point) - 20))));
				transform.volume = volume * 0.01;
				
				if (volume < 100) {
					
				   pan = Math.max(-100, Math.min(100, (modelObj.x - _focusObj.x) * 0.5));
				   transform.pan = pan * 0.01;
				   
				}
	
			}
			
			if (!_hasSound) transform.volume = 0;

			channel.soundTransform = transform;
			
		}
       
		
        //
        //
        //
        public function addSound (parentObject:Object = null, soundID:String = null, allowVolumeAdjust:Boolean = true, loops:int = 0, volumeFactor:Number = 1):SoundChannel {
           
            var sound:Sound;
            var volume:Number = 1;
            var pan:Number = 0;
			
			if (_library == null || soundID == null) return null;
			
			if (soundID.indexOf(",") != -1) {
				
				var choices:Array = soundID.split(",");
				var choiceNum:int = Math.floor(Math.random() * choices.length);
				soundID = choices[choiceNum];
				
			}
			
			if (soundID == "none") return null;
			
			if (_focusObj == null &&
				Fuz2d.mainInstance &&
				Fuz2d.mainInstance.simulation &&
				Fuz2d.mainInstance.simulation.focalPoint != null && 
				Fuz2d.mainInstance.simulation.focalPoint.objectRef != null) {
					_focusObj = Fuz2d.mainInstance.simulation.focalPoint.objectRef;
				}
				
			if (_focusObj != null && _focusObj.deleted) _focusObj = null;
			
			var modelObj:Object2d;
			
			if (parentObject is Object2d) modelObj = Object2d(parentObject);
			else if (parentObject is PlayObject) modelObj = PlayObject(parentObject).object;
			else if (parentObject is SimulationObject) modelObj = SimulationObject(parentObject).objectRef; 
			
			if (soundID.indexOf("aa_") != 0) {
				sound = _library.getSound(soundID) as Sound;
			} else if (_library2) {
				sound = _library2.getSound(soundID) as Sound;
			}
			
			if (sound == null) return null;
			
			var channel:SoundChannel = sound.play(0, loops);
			var transform:SoundTransform = new SoundTransform();
			
			if (channel == null) return null;
			
			if (allowVolumeAdjust != false && modelObj != null && _focusObj != null) {
				
				volume = Math.floor(Math.min(100, 10000 / Math.max(1, (Geom2d.distanceBetweenPoints(modelObj.point, _focusObj.point) - 20))));
				transform.volume = volume * 0.01;
				
				if (volume < 100) {
					
				   pan = Math.max(-80, Math.min(80, (modelObj.x - _focusObj.x) * 0.125));
				   transform.pan = pan * 0.01;
				   
				}
				
				
				
			}
			
			transform.volume *= volumeFactor;
			
			if (!_hasSound) transform.volume = 0;

			channel.soundTransform = transform;
			return channel;
                
            
        }
        
        //
        //
        //
        public function addSoundLoop (parentObject:Object, soundID:String, volumeFactor:Number = 1):SoundChannel {
            
            return addSound(parentObject, soundID, true, 10000, volumeFactor);
            
        }
		
		//
		//
		//
		public static function stopAll ():void {
			
			SoundMixer.stopAll();
			
		}
		

		public function loadSong (url:String):void {
			
			unloadSong();
			
			songLoader = new URLLoader();
			songLoader.addEventListener(Event.COMPLETE, onSongLoaded, false, 0, true);
			songLoader.addEventListener(IOErrorEvent.IO_ERROR, onSongError, false, 0, true);
			songLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSongError, false, 0, true);
			songLoader.dataFormat = URLLoaderDataFormat.BINARY;
			songLoader.load(new URLRequest(baseURL + "music/modules/" + url));
			
		}
		
		public function pauseSong ():void {
			
			if (processor && processor.isPlaying) processor.pause();
			
		}
		
		public function resumeSong ():void {
			
			if (processor && !processor.isPlaying) {
				processor.play(music);
				var st:SoundTransform = processor.soundChannel.soundTransform;
				st.volume = 0.5;
				processor.soundChannel.soundTransform = st;
			}
			
		}
		
		public function unloadSong ():void {
			
			if (songLoader) {
				try { songLoader.close(); } catch (e:Error) { };
				songLoader = null;
			}
			
			if (processor) {
				processor.stop();	
				processor = null;
			}
			
			if (music) {
				music = null;
			}
			
		}
		
		
		
		protected function onSongLoaded (e:Event):void {
			
			songLoader.removeEventListener(Event.COMPLETE, onSongLoaded);
			songLoader.removeEventListener(IOErrorEvent.IO_ERROR, onSongError);
			songLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSongError);
			
			if (processor) processor.stop();
			processor = new ModProcessor();
			
			if (songLoader.data) {
				processor.load(songLoader.data);
				processor.loopSong = true;
				processor.stereo = 0.2;
				music = new Sound();
				processor.play(music);
				var st:SoundTransform = processor.soundChannel.soundTransform;
				st.volume = 0.5;
				processor.soundChannel.soundTransform = st;
			}
			
		}
		
		protected function onSongError (e:Event):void {
			
			trace("Song load error!");
			
		}
        
    }
	
}
