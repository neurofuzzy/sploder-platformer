package fuz2d.screen.shape 
{
	import flash.display.Sprite;
	import fuz2d.model.object.Biped;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class ArmorDisplay {
		
		protected var _asset:AssetDisplay;
		protected var _level:int = 0;
		protected var _clips:Array;
		
		//
		//
		public function ArmorDisplay (asset:AssetDisplay) {
			
			init(asset);
			
		}
		
		//
		//
		protected function init (asset:AssetDisplay):void {
			
			_asset = asset;
			
			if (_asset != null) {
				
				var clip:Sprite = Sprite(_asset.clip);
				
				if (clip != null) {

	
					if (_asset is BipedDisplay) {
						
						_clips = [clip["body"]["torso"], clip["body"]["arm_lt"], clip["body"]["arm_rt"]];
						
						draw();
						
					}
					
				}
			
			}
			
		}
		
		//
		//
		public function update ():void {
			
			if (_asset is BipedDisplay) {
				
				var biped:Biped = Biped(_asset.container.objectRef);
				
				if (biped.armor.level != _level) {
					
					_level = biped.armor.level;
					
					draw();
					
				}
				
			}
			
		}
		
		//
		//
		protected function draw ():void {
			
			var i:int;
			var j:int;
			var armorClip:Sprite;
			
			var biped:Biped = Biped(_asset.container.objectRef);

			for (j = 0; j < _clips.length; j++) {
				
				armorClip =  _clips[j];
				
				for (i = 1; i <= biped.armor.max; i++) {
					Sprite(armorClip["armor" + i]).visible = (biped.armor.level == i);
				}
			
			}
			
		}
		
	}
	
}