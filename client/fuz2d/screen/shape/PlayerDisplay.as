/**
* ...
* @author Default
* @version 0.1
*/

package fuz2d.screen.shape {
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import fuz2d.model.object.Biped;
	import fuz2d.screen.shape.ViewSprite;
	import fuz2d.screen.*;

	
	public class PlayerDisplay extends BipedDisplay {
		
		protected var _body_climbing:MovieClip;
		protected var _body_rolling:MovieClip;
		protected var _body_rolling_head:MovieClip;
		
		protected var _leg_lt_kneel:MovieClip;
		protected var _leg_rt_kneel:MovieClip;
		
		protected var _back_facing_backpack:MovieClip;
		
		//
		//
		public function PlayerDisplay (view:View, container:ViewSprite) {
			
			super(view, container);
			
		}

		//
		//
		override protected function assign ():void {
			
			super.assign();
			
			_body_climbing = _body["climbing"];
			_body_rolling = _body["rolling"];
			_body_rolling_head = _body_rolling["head"];
			_body_rolling_head.stop();
			
			
			_leg_lt_kneel = _body["leg_lt_kneel"];
			_leg_rt_kneel = _body["leg_rt_kneel"];
			
			_back_facing_backpack = _body["backpack"];
			
			_back_facing_backpack.visible = _body_climbing.visible = _body_rolling.visible = _leg_lt_kneel.visible = _leg_rt_kneel.visible = false;
			
		}
		
		override public function updateStance ():void {
			
			super.updateStance();
			
			_hand_lt.visible = _hand_rt.visible = true;
			
			if (_state == Biped.STATE_NORMAL) {
				
				_arm_rt.visible = _arm_lt.visible = _head.visible = _leg_lt.visible = _leg_rt.visible = _torso.visible = true;
				_body_climbing.visible = _body_rolling.visible = _leg_lt_kneel.visible = _leg_rt_kneel.visible = false;
				_back_facing_backpack.visible = false;
				
			} else {
				
				_arm_rt.visible = _arm_lt.visible = _head.visible = _leg_lt.visible = _leg_rt.visible = _torso.visible = false;
				_back_facing_backpack.visible = false;

				switch (_state) {
					
					case Biped.STATE_KNEELING:
						_arm_rt.visible = _arm_lt.visible = _head.visible = _torso.visible = true;
						if (!_hasHeadGraphic) {
							_head.gotoAndStop("bow");
							if (_head.getChildByName("g2c")) MovieClip(_head.getChildByName("g2c")).gotoAndStop(_headAvatar * 5 + _head.currentFrame);
						}
						_leg_lt_kneel.visible = _leg_rt_kneel.visible = true;
						_body_climbing.visible = _body_rolling.visible = false;
						_body.setChildIndex(_leg_rt_kneel, 0);
						_body.setChildIndex(_arm_lt, 1);
						_body.setChildIndex(_arm_rt, 2);
						_body.setChildIndex(_leg_lt_kneel, _body.numChildren - 1);
						break;
						
					case Biped.STATE_ROLLING:
						_body_rolling.visible = true;
						_body_rolling.rotation = _container.dobj.x;
						_body_rolling.gotoAndStop(_biped.armor.level + 1);
						_body_rolling_head.gotoAndStop(_headAvatar * 5 + 1);
						break;
						
					case Biped.STATE_CLIMBING:
						_head.visible = _body_climbing.visible = true;
						_body.setChildIndex(_body_climbing, 0);
						_body.setChildIndex(_head, 1);
						_body_climbing["armor"].gotoAndStop(_biped.armor.level + 1);
						_back_facing_backpack.visible = (_backpack.visible);
						if (_container.objectRef) {
							var cy:Number = 10000 + _container.objectRef.y;
							cy = Math.floor(cy / 20) % 8 + 1;
							_body_climbing.gotoAndStop(cy);
						}
						break;
						
					case Biped.STATE_BOARDED:
						_arm_rt.visible = _arm_lt.visible = _head.visible = _torso.visible = true;
						_leg_lt.visible = _leg_rt.visible = _hand_lt.visible = _hand_rt.visible = false;
						break;
						
					default:
						_arm_rt.visible = _arm_lt.visible = _head.visible = _leg_lt.visible = _leg_rt.visible = _torso.visible = true;
					
				}
				
			}
			
		}
		
	}
	
}
