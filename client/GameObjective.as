package  
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.xml.XMLNode;
	import fuz2d.action.control.PowerUpController;
	import fuz2d.action.play.PlayfieldEvent;
	import fuz2d.action.play.PlayObject;
	/**
	 * ...
	 * @author Geoff
	 */
	public class GameObjective extends EventDispatcher
	{
		public static const TYPE_NONE:int = 0;
		public static const TYPE_MELEE:int = 1;
		public static const TYPE_CAPTURE:int = 2;
		public static const TYPE_ESCAPE:int = 3;
		
		protected var _gameLevel:GameLevel;
		protected var _type:int = 0;
		public function get type():int { return _type; }
		
		protected var _complete:Boolean = false;
		public function get complete():Boolean { return _complete; }
		
		//
		//
		public function GameObjective (gameLevel:GameLevel) 
		{
			init(gameLevel);
		}
		
		//
		//
		protected function init (gameLevel:GameLevel):void
		{
			_gameLevel = gameLevel;
			_type = getGameObjectiveForLevel(_gameLevel.levelNum);
			_complete = false;
		}
		
		//
		//
		protected function initGameObjective ():void {
			
			if (PowerUpController.counts != null && 
				PowerUpController.counts["escapepod"] != undefined &&
				PowerUpController.counts["escapepod"] > 0) {
					_type = TYPE_ESCAPE;
				}
					
			else if (PowerUpController.counts != null && 
				PowerUpController.counts["crystal"] != undefined &&
				PowerUpController.counts["crystal"] > 0) {
					_type = TYPE_CAPTURE;
				}
				
			else if (PlayObject.counts != null && 
				PlayObject.counts["evil"] != undefined && 
				PlayObject.counts["evil"] > 0) {
					_type = TYPE_MELEE;	
				
				}
				
			else _type = TYPE_NONE;
			
		}
		
		public static function getGameObjectiveForLevel (levelNum:uint = 1):int {
			
			var lvl:XMLNode = Game.gameInstance.gameXML.firstChild.firstChild.childNodes[levelNum - 1];
			
			var objects:Array = lvl.firstChild.nodeValue.split("|");
			var object:Array;
			var id:uint;
			
			var i:int;
			
			i = objects.length;
			
			while (i--) {
				
				object = objects[i].split(",");
				id = parseInt(object[0]);
				
				if (id == 212) return TYPE_ESCAPE;
				
			}
			
			i = objects.length;
			
			while (i--) {
				
				object = objects[i].split(",");
				id = parseInt(object[0]);
				
				if (id == 202) return TYPE_CAPTURE;
				
			}
			
			return TYPE_MELEE;
			
		}
		
		//
		//
		public function start ():void {
			
			registerPlayfield();
			
		}
		
		//
		//
		public function onStatusChange (e:PlayfieldEvent = null):void {
			
			var currentCount:int;
			var total:int;
			
			if (_type == GameObjective.TYPE_MELEE) {
				
				currentCount = (PlayObject.totals["evil"] - PlayObject.counts["evil"]);
				total = PlayObject.totals["evil"];
				
			} else if (_type == GameObjective.TYPE_CAPTURE) {
				
				currentCount = (PowerUpController.totals["crystal"] - PowerUpController.counts["crystal"]);
				total = PowerUpController.totals["crystal"];
				
			}
			
			if ((currentCount == total && !Game.ended && 
					(_type == GameObjective.TYPE_CAPTURE || _type == GameObjective.TYPE_MELEE) 
				) || (
					(e != null && e.type == PlayfieldEvent.ESCAPED && _type == GameObjective.TYPE_ESCAPE)
				)) {

				_complete = true;
				
				dispatchEvent(new Event(Event.COMPLETE));
				
			}
			
		}
		
		//
		//
		protected function registerPlayfield ():void {
			
			GameLevel.player.playfield.addEventListener(PlayfieldEvent.POWERUP, onStatusChange, false, 0, true);
			GameLevel.player.playfield.addEventListener(PlayfieldEvent.DEATH, onStatusChange, false, 0, true);
			GameLevel.player.playfield.addEventListener(PlayfieldEvent.ESCAPED, onStatusChange, false, 0, true);			
			
		}
		
		//
		//
		protected function unregisterPlayfield ():void {
			
			GameLevel.player.playfield.removeEventListener(PlayfieldEvent.POWERUP, onStatusChange);
			GameLevel.player.playfield.removeEventListener(PlayfieldEvent.DEATH, onStatusChange);
			GameLevel.player.playfield.removeEventListener(PlayfieldEvent.ESCAPED, onStatusChange);

		}
		
		//
		//
		public function end ():void {
			
			unregisterPlayfield();
			_gameLevel = null;
			
		}
		
	}

}