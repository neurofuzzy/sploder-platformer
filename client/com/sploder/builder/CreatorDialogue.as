package com.sploder.builder 
{
	
	import com.sploder.SignString;
	import com.sploder.asui.Cell;
	import com.sploder.asui.CheckBox;
	import com.sploder.asui.Component;
	import com.sploder.asui.FormField;
	import com.sploder.util.StringUtils;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CreatorDialogue extends EventDispatcher {
		
		public static const EVENT_CONFIRM:String = "confirm";
		public static const EVENT_CANCEL:String = "cancel";
		
		protected var _creator:Creator;
		protected var _container:Sprite;
		
		protected var _messageTextField:TextField;
		protected var _serverMessageTextField:TextField;
		
		protected var _maskButton:SimpleButton;
		protected var _progressBarMask:Sprite;
		
		protected var _dialogueName:String = "";
		
		protected var _comments:CheckBox;
		protected var _isprivate:CheckBox;
		protected var _turbo:CheckBox;
		protected var _8bit:CheckBox;
		
		protected var _textEntryField:FormField;
		public function get textEntryField():FormField { return _textEntryField; }
		
		public function set percentComplete (val:Number):void {
			
			if (_dialogueName == "ddprogress") _progressBarMask.width = Math.max(1, Math.min(100, val * 100));	

		}
		
		//
		//
		public function CreatorDialogue(creator:Creator, container:Sprite) {
			
			init(creator, container);
			
		}
		
		//
		//
		protected function init (creator:Creator, container:Sprite):void {
			
			_creator = creator;
			_container = container;
			_dialogueName = _container.name;
			
			var button:SimpleButton;
			var textfield:TextField;
			
			for (var i:int = 0; i < _container.numChildren; i++) {
				
				if (_container.getChildAt(i) is SimpleButton) {
					
					button = _container.getChildAt(i) as SimpleButton;
					
					if (button.name == "maskbutton") {
						button.useHandCursor = false;
					} else {
						button.addEventListener(MouseEvent.CLICK, onButtonClick);
					}
					
				}
				
				if (_container.getChildAt(i) is TextField) {
					
					textfield = _container.getChildAt(i) as TextField;
					
					if (textfield.name == "messagetext") {
						_messageTextField = textfield;
					} else if (textfield.name == "servermessage") {
						_serverMessageTextField = textfield;
					}
					
				}
				
			}
			
			if (_dialogueName == "ddembedcode") {

				_messageTextField.selectable = _messageTextField.mouseEnabled = true;
				_messageTextField.addEventListener(FocusEvent.FOCUS_IN, onTextFocus);
				
			} else if (_dialogueName == "ddpublish") {
				
				_comments = new CheckBox(_container, "", "comments", false, 30);
				_comments.x = 40;
				_isprivate = new CheckBox(_container, "", "comments", false, 30);
				_isprivate.x = 240;
				_comments.y = _isprivate.y = 10;
				
				_turbo = new CheckBox(_container, "No lighting effects (fast mode)", "true", false, 290, 30);
				_turbo.x = 73;
				_turbo.y = 49;
				
				_8bit = new CheckBox(_container, "8bit graphics style (superfast mode)", "true", false, 290, 30);
				_8bit.addEventListener(Component.EVENT_CHANGE, on8bitChange);
				
				_8bit.x = 73;
				_8bit.y = 69;

			} else if (_dialogueName == "ddtextentry") {
				
				_textEntryField = new FormField(_container, "", 340, 70);
				_textEntryField.restrict = StringUtils.RESTRICT_BASIC;
				_textEntryField.x = 40;
				_textEntryField.y = 20;
				
			}
			
			if (_dialogueName == "ddprogress") {
				_progressBarMask = _container["progressbarmask"];
			}
			
			hide();

		}
		
		//
		//
		protected function applySettings ():void {
			
			switch (_dialogueName) {
				
				case "ddpublish":
				
					_creator.project.comments = (_comments.checked) ? "1" : "0";
					_creator.project.isprivate = (_isprivate.checked) ? "1" : "0";
					_creator.project.fast = (_turbo.checked || _8bit.checked) ? "1" : "0";
					_creator.project.bitview = (_8bit.checked) ? "1" : "0";
					break;
				
			}
			
		}
		
		//
		//
		public function updateSettings ():void {
			
			switch (_dialogueName) {
				
				case "ddpublish":
				
					_comments.checked = (_creator.project.comments == "1");
					_isprivate.checked = (_creator.project.isprivate == "1");
					_turbo.checked = (_creator.project.fast == "1" || _creator.project.bitview == "1");
					_8bit.checked = (_creator.project.bitview == "1");
					
					on8bitChange();
					
					break;
				
			}
			
		}
		
		//
		//
		protected function addDescription (e:Event):void {
			
			_textEntryField.enable();
			_textEntryField.focus();
			
		}
		
		//
		//
		protected function removeDescription (e:Event):void {
			
			_textEntryField.disable();
			
		}
		
		//
		//
		protected function onTextFocus (e:FocusEvent):void {
			
			CreatorMain.mainStage.focus = _messageTextField;
            if (_messageTextField.text.length > 0) _messageTextField.setSelection(0, _messageTextField.text.length);
			
		}
		
		//
		//
		protected function disableButton (b:SimpleButton):void {
			
			b.alpha = 0.5;
			b.mouseEnabled = false;
			
		}
		
		//
		//
		protected function enableButton (b:SimpleButton):void {
			
			b.alpha = 1;
			b.mouseEnabled = true;
			
		}
		
		//
		//
		protected function onButtonClick (e:MouseEvent):void {
			
			var buttonName:String = e.target.name;

			switch (buttonName) {
				
				case "demo":
					_creator.project.newProject();
					hide();
					break;
					
				case "cancel":
					dispatchEvent(new Event(EVENT_CANCEL));
					hide();
					break;
					
				case "close":
				case "original":
					hide();
					break;
					
				case "no":
					dispatchEvent(new Event(EVENT_CANCEL));
					hide();
					break;
					
				case "ok":
				case "yes":
				
					switch (_dialogueName) {
						
						case "ddalert":
						case "ddsessionexpire":
						case "ddembedcode":
						case "ddservercomplete":
						case "ddoldgame":
							hide();
							break;
							
						default:
							dispatchEvent(new Event(EVENT_CONFIRM));
							hide();
							break;
							
						case "ddserverpublished":
							_creator.ddsavereminder.show();
							hide();
							break;
							
						
					}
					break;
					
				case "join":
				
					navigateToURL(new URLRequest("http://www.sploder.com/join.php"), "_self");
					break;
					
				case "apply":
					switch (_dialogueName) {
						
						case "ddtextentry":
							dispatchEvent(new Event(EVENT_CONFIRM));
							hide();
							break;
							
						default:
							applySettings();
							hide();
							break;
					}
					break;
					
				case "accept":
					applySettings();
					hide();
					break;
					
				case "publish":
					applySettings();
					_creator.project.publishProject();
					hide();
					break;
					
				case "playagain":
					_creator.project.playPubMovie(e);
					break;

				case "getcode":
					_creator.ddembedcode.show('<div align="center"><embed type="application/x-shockwave-flash" src="http://www.sploder.com/player2.php?s=' + _creator.project.pubkey + '" id="splodergame" base="http://www.sploder.com" width="640" height="480" wmode="transparent" salign="tl" scale="noscale" ></embed><br /><a href="http://www.sploder.com">Make Your Own Game for Free!</a></div>');
					hide();
					break;
					
				case "savenow":
					_creator.project.requestSaveProject();
					hide();
					break;
					
				case "settingsmanager":
					navigateToURL(new URLRequest("http://www.macromedia.com/support/documentation/en/flashplayer/help/settings_manager07.html#117717"), "_blank");
					hide();
					break;
				
			}
			
			
		}
		
		//
		//
		protected function on8bitChange (e:Event = null):void {
			
			if (_8bit.checked) {
				_turbo.checked = true;
				_turbo.disable();
			} else {
				_turbo.enable();
				_turbo.checked = (_creator.project.fast == "1");
			}
			
		}
	
		//
		//
		public function show (msg:String = null, servermsg:String = null):void {
			
			_creator.ddLevelName.hide();
			if (this != _creator.ddalert) _creator.ddGraphics.hide();
			_container.visible = true;
			
			switch (_dialogueName) {
				
				case "ddtextentry":
					_textEntryField.value = msg;
					_textEntryField.focus();
					break;
				
				default:
					if (msg != null && _messageTextField != null) _messageTextField.text = msg;
					if (servermsg != null && _serverMessageTextField != null) _serverMessageTextField.htmlText = servermsg;
					break;
				
			}
			
			updateSettings();
			
		}
		
		//
		//
		public function hide ():void {
			
			_container.visible = false;
			
		}
		
	}
	
}