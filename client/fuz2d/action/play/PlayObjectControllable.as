/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.play {
	
	import flash.events.Event;
	
	import flash.geom.Point;
	import fuz2d.action.behavior.*;
	import fuz2d.action.control.*;
	import fuz2d.action.modifier.AtomicModifier;
	import fuz2d.action.modifier.ModifierManager;
	import fuz2d.action.physics.*;
	import fuz2d.Fuz2d;
	import fuz2d.library.ObjectDefinition;
	import fuz2d.model.*;
	import fuz2d.model.object.*;
	import fuz2d.TimeStep;
	
	

	public class PlayObjectControllable extends PlayObject {
		
		protected var _behaviors:BehaviorManager;
		public function get behaviors():BehaviorManager { return _behaviors; }
		
		protected var _modifiers:ModifierManager;
		public function get modifiers():ModifierManager { return _modifiers; }
		
		protected var _controller:Controller;
		public function get controller():Controller { return _controller; }
		public function set controller (obj:Controller):void { _controller = obj; }
	
		protected var _sightPoint:Point2d;
		public function get sightPoint():Point2d { return _sightPoint; }
		
		protected var _locked:Boolean = false;
		public function get locked():Boolean { return _locked; }
		public function set locked(value:Boolean):void { _locked = value; }
		
		protected var _health:Number = 0;
		
		public function get health():Number { return _health; }
		public function set health(value:Number):void {
			if (invincible) return;
			_health = Math.max(0, Math.min(_maxHealth, value));
			if (_modelObjectRef != null) {
				_modelObjectRef.attribs.health = _health / _maxHealth;
				if (_modelObjectRef is Symbol && _modelObjectRef.material && _modelObjectRef.material.showDamage) {
					var damage:int = Math.max(1, 100 - Math.floor(100 * (_health / _maxHealth)));
					Symbol(_modelObjectRef).state = "" + damage;
					_modelObjectRef.attribs.damage = damage;
				}
			}
			dispatchEvent(new Event(PlayObject.EVENT_HEALTH));
			if (_health == 0) dispatchEvent(new Event(PlayObject.EVENT_DIE));
			
		}
		
		public function setInitialHealth (value:Number):void {
			
			_health = Math.max(0, Math.min(_maxHealth, value));
			dispatchEvent(new Event(PlayObject.EVENT_HEALTH));
			
		}
		
		protected var _maxHealth:Number = 100;
		public function get maxHealth():Number { return _maxHealth; }
		
		protected var _originalStrength:Number = 1;
		protected var _strengthFactor:Number = 1;
		public function get strengthFactor():Number { return _strengthFactor; }
		public function set strengthFactor(value:Number):void 
		{
			_strengthFactor = value;
		}
		
		protected var _striking:Boolean = false;
		public function get striking():Boolean { return _striking; }
		public function set striking(value:Boolean):void { _striking = value; }
		
		protected var _dying:Boolean = false;
		public function get dying():Boolean { return _dying; }

		public var invincible:Boolean = true;
		
		//
		//
		public function PlayObjectControllable (type:String, creator:Object, main:Fuz2d, def:ObjectDefinition, health:int = 1, strengthFactor:Number = 1) {
			
			super(type, creator, main, def);
			
			_health = _maxHealth = health;
			if (_health > 1) invincible = false;
			
			if (_modelObjectRef != null) {
				_modelObjectRef.attribs.health = 1;
			}
			
			_originalStrength = _strengthFactor = strengthFactor;
			
			inheritCreatorModifiers();
			
		}
		
		//
		//
		override protected function init ():void { 
			
			super.init();
			
			initializeReferencePoints();
			initializeBehaviors();
			initializeModifiers();
			initializeController();
			
		}

		//
		//
		protected function initializeBehaviors ():void {
			
			_behaviors = new BehaviorManager(this);
			
			_def.addBehaviors(_behaviors);
			
		}
		
		//
		//
		protected function initializeModifiers ():void {
			
			_modifiers = new ModifierManager(this);
			
		}
		
		//
		//
		protected function inheritCreatorModifiers ():void {
			
			if (creator is PlayObjectControllable) {
				
				var po:PlayObjectControllable = creator as PlayObjectControllable;
				_strengthFactor *= po.strengthFactor;
				
				if (po.modifiers.contains("atomic")) {
					_modifiers.add(new AtomicModifier());
				}
				
			}

		}
		
		//
		//
		protected function initializeController ():void {
			
			_controller = _def.newController();
			if (_simObjectRef) _simObjectRef.controlled = true;
	
		}	
		
		//
		//
		protected function initializeReferencePoints ():void {
			
			_sightPoint = new Point2d(_modelObjectRef, 0, 0);

		}



		//
		//
		override public function destroy ():void {
	
			_behaviors.end();
			_modifiers.end();
			
			if (_controller != null) _controller.end();
			
			super.destroy();

			delete this;

		}
		
		//
		
		/*
		 * --------------------------------------------------------
		 * OBJECT ACTIONS
		 * --------------------------------------------------------
		 */	
		
		//
		//
		public function spawnFrom (spawner:PlayObject):void {
			
			_simObjectRef.objectRef.alignTo(spawner.simObject.objectRef);
			_simObjectRef.getPosition();
			_simObjectRef.getOrientation();
			
		}
		
		//
		//
		public function restoreStrength ():void {
			_strengthFactor = _originalStrength;
		}
		
		//
		//
		public function harm (playObj:PlayObjectControllable, amount:Number = 0, contactPoint:Point = null):void {

			if (_dying || _locked || _deleted) return;
			
			amount *= _strengthFactor;

			if (playObj is BipedObject) {
				if (BipedObject.defendSuccess(this, playObj as BipedObject)) {
					amount *= 1 - BipedObject(playObj).body.tools_lt.strength / 10;
				}

				amount /= ((Biped(playObj.object).armor.level * 0.33) + 1);

				if (amount <= 0) return;
			}
			
			if (playObj.health > 0) playObj.health -= amount;
			
			playObj.onHarmed(this, amount, contactPoint);
			
		}
		
		public function onHarmed (harmer:PlayObjectControllable, amount:Number = 0, contactPoint:Point = null, deathBlow:Boolean = false):void {
			
			dispatchEvent(new PlayfieldEvent(PlayfieldEvent.HARM, false, false, harmer, amount, contactPoint));

			if ((health == 0 || deathBlow) && !_dying) die();
			
		}
		
		public function endControl ():void {
			
			_locked = true;
			if (_controller != null) _controller.end();
			_behaviors.end();
			
		}
		
		public function kill ():void {
			die();
		}
		
		//
		//
		override protected function die ():void {
			
			super.die();
			
			if (!_dying) {
				dispatchEvent(new PlayfieldEvent(PlayfieldEvent.DEATH, false, false, this));
				_playfield.dispatchEvent(new PlayfieldEvent(PlayfieldEvent.DEATH, false, false, this));
				_dying = true;
			}
			
			endControl();

			eventSound("die");

			if (_modelObjectRef is Symbol) Symbol(_modelObjectRef).state = "f_die";
			
			if (_modelObjectRef != null) _modelObjectRef.attribs.dieTime = TimeStep.realTime;
			
		}
		
	}
	
}
