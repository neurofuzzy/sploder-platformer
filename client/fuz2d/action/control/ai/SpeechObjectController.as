package fuz2d.action.control.ai {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import fuz2d.action.control.PlayObjectController;
	import fuz2d.action.play.*;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.object.Symbol;
	import fuz2d.screen.BitView;
	import fuz2d.screen.shape.AssetDisplay;
	import fuz2d.TimeStep;
	import fuz2d.util.Geom2d;
	
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class SpeechObjectController extends PlayObjectController {
		
		protected var _player:PlayObject;
		protected var _playerNear:Boolean = false;

		protected var _message:String = "";
		public function get message():String { return _message; }
		public function set message(value:String):void 
		{
			_message = value;
		}
		
		protected var _lastMessageTime:int = -5000;
		protected var _messageSent:Boolean = false;
		
		protected var _speechBubble:Symbol;
		protected var _speechBubbleBackground:Sprite;
		protected var _speechText:TextField;

		//
		//
		public function SpeechObjectController (object:PlayObjectControllable, message:String = "") {
		
			super(object);
			
			_message = message;
			
			if (_object.object is Symbol && Symbol(_object.object).clip["message"] != null) {
				_object.object.attribs.message = message;
				_active = false;
			}

		}
		
		//
		//
		override public function see(p:PlayObject):void {
			
			super.see(p);
			
			if (_object == null || _object.deleted) {
				end();
				return;
			}
			
			if (p.object.symbolName == "player") {
				
				if (_player == null) _object.eventSound("see");
				_player = p;
				_playerNear = true;
				
			}
			
		}
		
		//
		//
		override public function update (e:Event):void {
			
			if (_ended || !_active || _object.locked || _object.dying) return;
			
			super.update(e);
			
			if (_message == null || _message.length == 0) return;
			
			if (_messageSent && _speechBubble && TimeStep.realTime - _lastMessageTime > 18000) {
				destroySpeechBubble();
			} else if (_speechBubbleBackground) {
				_speechBubbleBackground.parent.visible = true;
			}
			
			if (_object.deleted) {
				end();
				return;
			}
			
			if (_player != null && _player.deleted) {
				
				_player = null;
				_playerNear = false;
				_messageSent = false;
				
			} else if (_playerNear) {
				
				var sqdist:Number = Geom2d.squaredDistanceBetweenPoints(_object.object.point, _player.object.point);
				
				if (sqdist > 360000) {
							
					_player = null;
					_playerNear = false;
					_messageSent = false;
					destroySpeechBubble();

				} else {
					
					if (!_messageSent && _speechBubble == null && TimeStep.realTime - _lastMessageTime > 5000 ) {
						
						buildSpeechBubble();
						
						_lastMessageTime = TimeStep.realTime;
						_messageSent = true;
						
					}

				}
				
			}
				
		}
		
		//
		//
		protected function buildSpeechBubble ():void {
			
			var pt:Point = _object.object.point.clone();
			pt.x += _object.object.width / 2;
			pt.y += _object.object.height / 2;

			_speechBubble = ObjectFactory.effect(_object, "speechbubble", true, 195, pt, 0);
			_speechBubble.controlled = true;
			_speechBubble.x += _speechBubble.width / 2 - 40;
			_speechBubble.y += _speechBubble.height / 2 - 30;

			var s:Sprite = Sprite(AssetDisplay(_speechBubble.viewObject.polygon).clip);
			s.visible = false;
			
			if (s) {
				
				_speechText = s.getChildByName("message") as TextField;
				
				if (_speechText) {
					
					_speechText.autoSize = TextFieldAutoSize.CENTER;
					
					if (GameLevel.gameEngine.viewClass == BitView) {
						_speechText.antiAliasType = AntiAliasType.ADVANCED;
						_speechText.sharpness = 400;
						_speechText.thickness = 200;
						_speechText.htmlText = '<P><FONT SIZE="25" COLOR="#336699" LETTERSPACING="2" KERNING="0">' + _message + '</FONT></P>';
					} else {
						_speechText.text = _message;
					}
					
					
					_speechBubbleBackground = s.getChildByName("bkgd") as Sprite;
					
					if (_speechBubbleBackground) {
						
						_speechBubbleBackground.height = _speechText.height + 50;
						_speechBubbleBackground.y = 0 - _speechBubbleBackground.height * 0.5;
						_speechText.y = _speechBubbleBackground.y + 10;	
						
						_object.eventSound("speak");
					
					}
					
				}
			
			}
			
		}
		
		protected function destroySpeechBubble (force:Boolean = false):void {
		
			if (_speechBubble) {
				
				if (TimeStep.realTime - _lastMessageTime > 2500 || force) {
					
					_speechBubble.destroy();
					_speechBubble = null;
					_speechText = null;
					_speechBubbleBackground = null;
					
				}
				
			}
			
		}
		
		//
		//
		override public function end():void {
			
			destroySpeechBubble(true);
			
			_player = null;
			
			super.end();
			
		}

	}
	
}