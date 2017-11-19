package com.sploder.sound {
	
	import com.sploder.*;
	import flash.display.*;
	import flash.media.*;
	import flash.net.URLLoader;
	import flash.utils.ByteArray;
	import fuz2d.*;
	import neoart.flod.ModProcessor;
	
	
	

    public class SoundManager {

		protected var _main:Fuz2d;
		
        private var _hasSound:Boolean = true;
        public function get hasSound ():Boolean { return _hasSound; }
         public static function set hasSound (val:Boolean):void { 
			_hasSound = val;
			if (!_hasSound) {
				stopAll();
			}
		}
		
		public static var mainInstance:SoundManager;

		//	Required to replay a mod
		private var music:Sound;
		private var stream:ByteArray;
		private var processor:ModProcessor;
		private var songLoader:URLLoader;
		
        //
        //
        //
        public function SoundManager (main:Fuz2d) {
            
			_main = main;
			mainInstance = this;
			
        }
       
		
        //
        //
        //
        public function addSound (parentObject:Object = null, soundID:String = null, allowVolumeAdjust:Boolean = true, loops:int = 0):SoundChannel {
            
            var sound:Sound;
            var volume:Number;
            var pan:Number;
            
			if (soundID == null) soundID == "s_hit";
			
            if (_hasSound) {
				
				sound = Fuz2d.library.getSound(soundID) as Sound;
				
				var channel:SoundChannel = sound.play(0, loops);
				var transform:SoundTransform = new SoundTransform();
				
				if (channel == null) return null;
				
                /*
                sound = new Sound(parentObject);
                sound.attachSound(soundID);
                sound.start();
                */
				/*
                if (allowVolumeAdjust != false && parentObject != null) {
					
                    volume = Math.floor(Math.min(100, 10000 / Math.max(1, (Geom2d.distanceBetweenPoints(parentObject, _player) - 20))));
                    transform.volume = volume * 0.01;
					
                    if (volume < 100) {
						
                       pan = Math.max(-100, Math.min(100, parentObject.x - _player.x));
                       transform.pan = pan * 0.01;
					   
                    }
					
                }
                */
				/*
                sound.onSoundComplete = function ():void {
                    delete this;
                }
                */
				
				channel.soundTransform = transform;
                return channel;
                
            } else {
                
                return null;
                
            }
            
        }
        
        //
        //
        //
        public function addSoundLoop (parentObject:Object, soundID:String):SoundChannel {
            
            return addSound(parentObject, soundID, true, 10000);
            
        }
		

		//
		//
		//
		public static function stopAll ():void {
			
			if (mainInstance) mainInstance.noisePlaying = false;
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
