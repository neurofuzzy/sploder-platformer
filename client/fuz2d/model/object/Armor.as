package fuz2d.model.object 
{
	import flash.display.Sprite;
	import fuz2d.action.play.PlayObject;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class Armor {
		
		protected var _obj:Symbol;
		
		protected var _max:int = 0;
		public function get max():int { return _max; }
		
		protected var _level:int = 0;
		public function get level():int { return _level; }
		public function set level(value:int):void {
			_level = Math.min(_max, Math.max(0, value));
		}
		
		//
		//
		public function Armor (obj:Symbol) {
			
			init(obj);
			
		}
		
		//
		//
		protected function init (obj:Symbol):void {
			
			_obj = obj;
			_max = 0;
			
			if (_obj != null) {
				
				var clip:Sprite = _obj.clip;
				
				if (clip != null) {
					
					var armorClip:Sprite = clip;
	
					if (_obj is Biped && clip["body"] != null && clip["body"]["torso"] != null) {
						armorClip =  clip["body"]["torso"];
					}

					while (armorClip["armor" + (_max + 1)] != undefined) {
						_max++;
					}
					
				}
			
			}
			
		}
	
	}
	
}