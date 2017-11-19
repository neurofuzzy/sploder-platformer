package com.sploder {
    
	import com.sploder.Settings;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import fuz2d.action.behavior.WeakBlockBehavior;
	import fuz2d.action.control.PowerUpController;
	import fuz2d.action.control.TeleportController;
	import fuz2d.action.physics.Simulation;
	import fuz2d.action.play.PlayObject;
	import fuz2d.action.play.PlayObjectControllable;
	import fuz2d.action.play.PlayObjectMovable;
	import fuz2d.Fuz2d;
	import fuz2d.model.ModelEvent;
	import fuz2d.screen.View;
	
	import fuz2d.action.play.Playfield;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
    
    final public class Radar {
        
        private var _mc:MovieClip;
		private var _parent:Sprite;
        private var _field:MovieClip;
        
        public var _playfield:Playfield;
        
        public var introShown:Boolean = false;
        
        public var xhome:Number;
        public var yhome:Number;
        public var xdest:Number;
        
        public static var screenScale:Number = 0.06667;
        
        private var totalBlips:Number = 0;
		
		private var _blips:Dictionary;
		
		private var _introTimer:Timer;
        
        //
        //
        //
        public function Radar(mc:MovieClip, playfield:Playfield) {
            
            init(mc, playfield);
            
        }
        
        //
        //
        //
        private function init (mc:MovieClip, playfield:Playfield):void {
            
            _mc = mc;
			_parent = _mc.parent as Sprite;
            _mc.pc = this;
			_mc.visible = false;
			_parent.removeChild(_mc);
            _field = _mc["field"];
           
            xhome = _mc.x;
            yhome = _mc.y;
            xdest = xhome + 240;
            _mc.x = xdest;
            
            var introTimes:Number = parseInt("" + Settings.loadSetting("radarIntroShown2"));
            
            if (isNaN(introTimes)) {
                introTimes = 1;
            } else {
                introTimes++;
            }
            
            if (introTimes > 3) {
                introShown = true;
            } else {
                Settings.saveSetting("radarIntroShown2", introTimes);
            }
			
			reset(playfield);
			
			View.mainStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			View.mainStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
  
        }
		
		//
		//
		public function setPlayfield (playfield:Playfield = null):void {
			
			reset(playfield);
			
		}
		
		//
		//
		private function reset (playfield:Playfield = null):void {
			
			if (_playfield) {
				if (_playfield.simulation) _playfield.simulation.removeEventListener(Simulation.CYCLE_END, update);
				if (_playfield.model) _playfield.model.removeEventListener(ModelEvent.DELETE, removeBlip);
				_playfield = null;
			}
			
			var i:int = _field.numChildren;
			
			while (i--) {
				_field.removeChildAt(i);
			}
			
			if (playfield) {
				
				_blips = new Dictionary(true);
				_playfield = playfield;
				
				_field.graphics.clear();
				_field.graphics.beginFill(Fuz2d.environment.skyColor, 0.8);
				_field.graphics.drawRect( -500, -500, 1000, 500);
				_field.graphics.endFill();
				_field.graphics.beginFill(0, 0.8);
				_field.graphics.drawRect( -500, 0, 1000, 500);
				_field.graphics.endFill();	
				
				_playfield.simulation.addEventListener(Simulation.CYCLE_END, update, false, 0, true);
				_playfield.model.addEventListener(ModelEvent.DELETE, removeBlip, false, 0, true);
				
				populate();
				
			}
			
		}
		
		//
		//
		private function onKeyDown (e:KeyboardEvent):void {
			
			if (e.charCode == 82 || e.charCode == 114) show();
			
		}
		
		//
		//
		private function onKeyUp (e:KeyboardEvent):void {
			
			if (e.charCode == 82 || e.charCode == 114) hide();
			
		}
        
		//
		//
		private function populate ():void {
			
			var obj:PlayObject;
			var objs:Array = _playfield.objects.concat();
			
			objs.sortOn("zDepth", Array.NUMERIC);
			
			for (var i:int = 0; i < objs.length; i++) {
				
				obj = objs[i];
				addBlip(obj);

			}
			
		}
        
        //
        //
        //
        public function addBlip (obj:PlayObject):void {
            
			if (obj == null) return;
			
            totalBlips++;
            
            var blip:Sprite = new Sprite();
			var blipColor:Number;
			var blipWidth:int = 4;
			var blipHeight:int = 4;
			
			if (obj.simObject != null) {
				if (obj == GameLevel.player) blipColor = 0xffffff;
				else if (obj.object.symbolName == "crystal") blipColor = 0xffec00;
				else if (obj.group == "evil") blipColor = 0xff0000;
				else if (obj is PlayObjectControllable && PlayObjectControllable(obj).controller is PowerUpController) blipColor = 0x00ff00;
				else if (obj is PlayObjectControllable && PlayObjectControllable(obj).controller is TeleportController) {
					blipColor = 0x00ccff;
					blipWidth = blipHeight = 12;
				}
				else if (obj is PlayObjectControllable && PlayObjectControllable(obj).behaviors.containsClass(WeakBlockBehavior)) blipColor = 0x666666; 
				else {
					blipColor = 0x999999;
					blipWidth *= Math.round(obj.object.width / 60);
					blipHeight *= Math.round(obj.object.height / 60);
				}
			} else if (obj.object != null) {
				blipWidth *= Math.round(obj.object.width / 60);
				blipHeight *= Math.round(obj.object.height / 60);
			}
			
			blip.graphics.beginFill(blipColor, 0.8);
			blip.graphics.drawRect( 0 - blipWidth / 2, 0 - blipHeight / 2, blipWidth, blipHeight);
			
			_field.addChild(blip);
			_blips[obj] = blip;
			
			moveBlip(obj);
            
        }
        
        //
        //
        //
        public function removeBlip (e:ModelEvent):void {
			
			if (e.object != null && e.object.simObject != null) {
				var object:PlayObject = _playfield.playObjects[e.object.simObject];
				
				if (_blips[object] != null && _blips[object] is DisplayObject && _field.getChildIndex(_blips[object]) != -1) {
					_field.removeChild(_blips[object]);
				}
				
			}
			
			updateBlips();
            
        }
		
		//
		//
		private function update (e:Event):void {
			
			if (_mc.visible == false) return;
			
			updateBlips();
			
		}
		
		//
		//
		protected function updateBlips ():void {
 			
			for (var key:Object in _blips) {
				
				var pobj:PlayObject = key as PlayObject;
				var blip:Sprite = _blips[key];
				
				if (pobj.deleted) {
					if (blip.parent != null) blip.parent.removeChild(blip);
					_blips[pobj] = null;
					delete _blips[pobj];
				}
				
				if (pobj is PlayObjectControllable) moveBlip(pobj);
				if (pobj == GameLevel.player) centerOn(pobj);
				
			}			
			
		}
        
        //
        //
        //
        public function moveBlip (object:PlayObject):void {

            
            if (_blips[object] != null && _blips[object] is DisplayObject) {
                
				var r:Sprite = _blips[object];
				
				if (object != null && object.object != null) {

					r.x = object.object.x * Radar.screenScale;
					r.y = 0 - object.object.y * Radar.screenScale;
					
				}
                
            }        
            
        }
        
        //
        //
        //
        public function centerOn (object:PlayObject):void {
 
            if (_blips[object] != null && _blips[object] is DisplayObject) {
				
				var r:Sprite = _blips[object];
				
                _field.x = 0 - r.x;
                _field.y = 0 - r.y;
				
            }
            
        }
        
        //
        //
        //
        public function hide ():void {
 
            if (introShown) {
                
				_mc.removeEventListener(Event.ENTER_FRAME, removeRadar);
				_mc.removeEventListener(Event.ENTER_FRAME, revealRadar);
				
				_mc.addEventListener(Event.ENTER_FRAME, removeRadar);
 
            }
            
        }
		
		//
		//
		protected function removeRadar (e:Event = null):void {
			
			if (_mc.x < xdest) {
				_mc.x += 40;
			} else {
				_mc.visible = false;
				_parent.removeChild(_mc);
				_mc.removeEventListener(Event.ENTER_FRAME, removeRadar);
			}			
			
		}
        
        //
        //
        //
        public function show ():void {

            _mc.visible = true;
			_parent.addChild(_mc);
            
			_mc.removeEventListener(Event.ENTER_FRAME, removeRadar);
			_mc.removeEventListener(Event.ENTER_FRAME, revealRadar);
			
			_mc.addEventListener(Event.ENTER_FRAME, revealRadar);
            
        }
		
		//
		//
		protected function revealRadar (e:Event = null):void {
			
			if (_mc.x > xhome) {
				_mc.x -= 40;
			} else {
				_mc.removeEventListener(Event.ENTER_FRAME, revealRadar);
			}			
			
		}
        
        //
        //
        //
        public function showIntro ():void {

            if (!introShown) {
                _mc["intro"].gotoAndPlay(2);
                show();
				_introTimer = new Timer(3000, 1);
				_introTimer.addEventListener(TimerEvent.TIMER_COMPLETE, endIntro);
				_introTimer.start();
			}
            
        }
        
        //
        //
        //
        public function endIntro (e:TimerEvent = null):void {

			_introTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, endIntro);
            introShown = true;
			hide();
			
        }
        
        //
        //
        //
        public function showDamage ():void {

            _mc.gotoAndStop(2);
        }
		
		//
		//
		public function end ():void {
			
			reset();
			_blips = null;
			
		}
        
    }
}
