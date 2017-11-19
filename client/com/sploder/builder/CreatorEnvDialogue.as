package com.sploder.builder 
{
	import com.sploder.asui.BButton;
	import com.sploder.asui.CheckBox;
	import com.sploder.asui.ColorPicker;
	import com.sploder.asui.Component;
	import com.sploder.asui.Create;
	import com.sploder.asui.Position;
	import com.sploder.asui.Slider;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CreatorEnvDialogue extends CreatorDialogue {
		
		protected var _background:CreatorBackground;
		protected var _bgPicker:ColorPicker;
		protected var _gdPicker:ColorPicker;
		protected var _bgNext:BButton;
		protected var _bgPrev:BButton;
		protected var _ambSlider:Slider;
		
		//
		//
		public function CreatorEnvDialogue(creator:Creator, container:Sprite) {
			
			super(creator, container);

		}
		
		//
		//
		override protected function init (creator:Creator, container:Sprite):void {
			
			super.init(creator, container);

			_background = new CreatorBackground(_container["content"], 200, 150, Creator.levels.bgColor, Creator.levels.gdColor, 1);
			
			_bgPrev = new BButton(_container, Create.ICON_ARROW_RIGHT, -1, 30, 30);
			_bgNext = new BButton(_container, Create.ICON_ARROW_LEFT, -1, 30, 30);
			
			_bgPrev.y = _bgNext.y = 130;
			_bgPrev.x = -75;
			_bgNext.x = 95;
			
			_bgPicker = new ColorPicker(_container, Creator.levels.bgColor, 100, "Sky Color");
			_gdPicker = new ColorPicker(_container, Creator.levels.gdColor, 100, "Ground Color");
			
			_bgPicker.y = _gdPicker.y = -35;
			_bgPicker.x = 160;
			_gdPicker.x = 320;
			
			_ambSlider = new Slider(_container, 200, 16, Position.ORIENTATION_HORIZONTAL, 20);
			_ambSlider.ratio = 0.1;
			_ambSlider.x = 245;
			_ambSlider.y = 137;
			
			_turbo = new CheckBox(_container, "No lighting effects (fast mode)", "true", false, 290, 30);
			_turbo.x = 60;
			_turbo.y = 177;
			
			_8bit = new CheckBox(_container, "8bit graphics style (superfast mode)", "true", false, 290, 30);
			_8bit.addEventListener(Component.EVENT_CHANGE, on8bitChange);
			_8bit.x = 60;
			_8bit.y = 197;
			
			
			_bgPrev.addEventListener(Component.EVENT_CLICK, prevBackground);
			_bgNext.addEventListener(Component.EVENT_CLICK, nextBackground);
			
			_bgPicker.addEventListener(Component.EVENT_CHANGE, redrawBackground);
			_gdPicker.addEventListener(Component.EVENT_CHANGE, redrawBackground);
			_ambSlider.addEventListener(Component.EVENT_CHANGE, redrawBackground);
			
			updateSettings();
			
			hide();

		}
		
		//
		//
		protected function redrawBackground (e:Event):void {
			
			_background.skyColor = _bgPicker.color;
			_background.groundColor = _gdPicker.color;
			_background.ambientColor = _ambSlider.sliderValue;

		}
		
		//
		//
		protected function prevBackground (e:Event):void {
			
			if (_background.backgroundNum > 0) {
				_background.backgroundNum--;
			}
		}
		
		//
		//
		protected function nextBackground (e:Event):void {
			
			if (_background.backgroundNum < Creator.levels.totalBackgrounds - 1) {
				_background.backgroundNum++;
			}

		}
		
		public function get settings ():Array {
			
			return [
				_background.backgroundNum.toString(),
				_background.skyColor.toString(16),
				_background.groundColor.toString(16),
				Math.floor(_background.ambientColor * 100).toString()
				];			
			
		}
		
		//
		//
		override protected function applySettings ():void {
			
			Creator.levels.saveCurrentEnvironment();
			
			_creator.project.fast = (_turbo.checked || _8bit.checked) ? "1" : "0";
			_creator.project.bitview = (_8bit.checked) ? "1" : "0";
			
			Creator.playfield.redrawBounds();
			
		}
		
		//
		//
		override public function updateSettings ():void {
			
			_background.backgroundNum = Creator.levels.bgNum;
			_background.skyColor = Creator.levels.bgColor;
			_background.groundColor = Creator.levels.gdColor;
			_background.ambientColor = Creator.levels.ambColor;
			_bgPicker.color = Creator.levels.bgColor;
			_gdPicker.color = Creator.levels.gdColor;
			_ambSlider.sliderValue = Creator.levels.ambColor;
			_turbo.checked = (_creator.project.fast == "1" || _creator.project.bitview == "1");
			_8bit.checked = (_creator.project.bitview == "1");
			
			on8bitChange();
			
			Creator.playfield.redrawBounds();

		}
		
		//
		//
		override public function show(msg:String = null, servermsg:String = null):void {
			
			super.show(msg, servermsg);
			
			updateSettings();
			
		}

	}
	
}