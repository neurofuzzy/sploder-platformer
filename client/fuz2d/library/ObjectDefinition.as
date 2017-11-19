/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.library {
	
	import com.adobe.serialization.json.JSON;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.media.SoundChannel;
	import fuz2d.*;
	import fuz2d.action.behavior.*;
	import fuz2d.action.control.*;
	import fuz2d.action.control.ai.*;
	import fuz2d.action.physics.*;
	import fuz2d.action.play.*;
	import fuz2d.model.environment.OmniLight;
	import fuz2d.model.material.Material;
	import fuz2d.screen.View;
	import fuz2d.util.Geom2d;
	import fuz2d.util.NodeSet;
	import fuz2d.util.ShrinkWrap;

	import fuz2d.model.*;
	import fuz2d.model.object.*;
	
	import flash.utils.getQualifiedClassName;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public dynamic class ObjectDefinition {
		
		protected var dna:XMLList;
		
		protected var _created:Boolean = false;
		
		public var child:ObjectTemplate;
		
		public function get isMappable ():Boolean { return (dna != null && String(dna.@map) == "1"); }
		
		public function get isSubMappable ():Boolean { return (dna != null && String(dna.@submap) == "1"); }
		
		public function get doButtress ():Boolean { return (dna != null && String(dna.@buttress) == "1"); }
		
		public function get linkable ():Boolean { return (dna != null && String(dna.@linkable) == "1"); }
		
		public var velocity:Vector2d;

		public function ObjectDefinition (definition:XMLList, x:Number = 0, y:Number = 0, z:Number = 0, options:Object = null) {
			
			init(definition, x, y, z, options);
			
		}
		
		public var x:Number = 0;
		public var y:Number = 0;
		public var z:Number = 0;
		
		public var rotation:Number = 0;
		public var tileID:int = -1;
		
		public var scaleX:Number = 1;
		public var scaleY:Number = 1;
		
		public var useCreateSound:Boolean = true;
		
		public var data:Array;
		
		protected function init (definition:XMLList, x:Number = 0, y:Number = 0, z:Number = 0, options:Object = null):void {
			
			dna = definition;
			
			this.x = x;
			this.y = y;
			this.z = z;
			
			if (options != null) {
				
				for (var param:String in options) {
					try {
						this[param] = options[param];
					} catch (e:Error) {
						trace("Parameter '" + param + "' not found or is read-only in " + getQualifiedClassName(this));
					}
				}
			
			}
			
			if (velocity == null) velocity = new Vector2d();
			
		}
		
		//
		//
		public function eventSound (eventName:String):SoundChannel {
			
			if (dna..sounds.attribute(eventName) != undefined) {
				return Fuz2d.sounds.addSound(child, dna..sounds.attribute(eventName) + "");
			}
			
			return null;
			
		}
		
		//
		//
		public function getObjectTemplate (objID:String, creator:Object):ObjectTemplate {
			
			if (_created) return null;
			
			var obj:ObjectTemplate = null;
			
			var health:int;
			var speed:Number;
			var strength:Number;
			
			var type:String = (dna.@id != undefined) ? String(dna.@id) : objID;
			
			var groupIsGlobal:Boolean = (dna.@global == "1");
				
			switch (String(dna.@type)) {
				
				case "biped":
					
					health = (dna.@health != undefined) ? parseInt(dna.@health) : 100;
					speed = (dna.@speed != undefined) ? parseFloat(dna.@speed) : 1;
					strength = (dna.@strength != undefined) ? parseInt(dna.@strength) : 1;
					var jump:int = (dna.@jump != undefined) ? parseInt(dna.@jump) : 1000;
					
					obj = new BipedObject(type, creator, ObjectFactory.main, this, health, strength, speed, jump);
					BipedObject(obj).global = groupIsGlobal;
					_created = true;
					break;
					
				case "control":
				
					health = (dna.@health != undefined) ? parseInt(dna.@health) : 1;
					strength = (dna.@strength != undefined) ? parseInt(dna.@strength) : 1;
				
					obj = new PlayObjectControllable(type, creator, ObjectFactory.main, this, health, strength);
					PlayObjectControllable(obj).global = groupIsGlobal;
					_created = true;
					break;				
					
				case "movable":
				
					health = (dna.@health != undefined) ? parseInt(dna.@health) : 100;
					strength = (dna.@strength != undefined) ? parseInt(dna.@strength) : 1;
					speed = (dna.@speed != undefined) ? parseFloat(dna.@speed) : 1;
					
					obj = new PlayObjectMovable(type, creator, ObjectFactory.main, this, health, strength, speed);
					PlayObjectMovable(obj).global = groupIsGlobal;
					_created = true;
					break;
					
				default:
				
					if (dna..ctrl != undefined) {
						obj = new PlayObjectControllable(type, creator, ObjectFactory.main, this);
						PlayObjectControllable(obj).global = groupIsGlobal;
					} else {
						obj = new PlayObject(type, creator, ObjectFactory.main, this);
						PlayObject(obj).global = groupIsGlobal;
					}
					_created = true;
					break;
					
			}
			
			if (dna.@group != undefined) obj.group = String(dna.@group);

			return obj;			
			
		}
		
		//
		//
		public function newMaterial ():Material {
			
			var options:Object = { };
			
			if (dna != null) {
				
				if (dna..material != null) {
					
					var attributes:XMLList = dna..material.attributes();
					var count:int = attributes.length();
					
					for ( var i:int = 0; i < count; i++ ) {
						
						var attribute:XML = attributes[ i ];
						options[String(attribute.name())] = String(attribute.valueOf());
						
					}
					   
					
				}
				
			}
			
			return new Material(options);
			
			
		}
		
		
		//
		//
		public function newModelObject ():Object2d {
			
			var newLight:OmniLight;
			var name:String;
			
			if (dna != null) {
				
				var dnaobj:XMLList = dna..obj;
				
				if (dnaobj != null) {
					
					var objType:String = dnaobj.@type;
					
					if (dnaobj.@light != undefined) {
						
						newLight = Fuz2d.environment.addLight(new OmniLight(null, x, y, 1, parseInt(dnaobj.@light, 16), 50, 300));
						
					}
					
					var cache:Boolean, cast:Boolean, receive:Boolean, back:Boolean;
					
					switch (objType) {
						
						case "tile":
						
							var tid:int = parseInt(dnaobj.@tile);
							
							if (tileID > 0) tid = tileID;
							
							z = (dnaobj.@z.toString().length > 0) ? parseInt(dnaobj.@z.toString()) : z;
							
							cast = (dnaobj.@castshadow == "1");
							receive = !(dnaobj.@receiveshadow == "0");
							
							var defID:String = tid + "";
							
							back = String(dnaobj.@back) == "1";
							var tilescale:int = (dnaobj.@tilescale != undefined) ? parseInt(dnaobj.@tilescale) : 1;
							
							if (dnaobj.children()[0] != undefined && dnaobj.children()[0].toString().length > 0) {
								defID = Fuz2d.library.createTileSet(tid, back, com.adobe.serialization.json.JSON.decode(dnaobj.children()[0].toString()), -1, tilescale)
								dna.obj.@defID = defID;
							} else if (dnaobj.@tile != undefined) {
								defID = Fuz2d.library.createTileSet(tid, back, null, -1, tilescale);
							}
							
							if (rotation == 0) rotation = (dnaobj.@r != undefined) ? parseInt(dnaobj.@r) * Geom2d.dtr : rotation;
							
							return ObjectFactory.model.addObject(new Tile(defID, dnaobj.@stamp, Fuz2d.library, newMaterial(), null, x, y, z, rotation, cast, receive, tilescale));
							
						case "textureblock":
							
							z = (dnaobj.@z.toString().length > 0) ? parseInt(dnaobj.@z.toString()) : z;
							
							cast = (dnaobj.@castshadow == "1");
							receive = !(dnaobj.@receiveshadow == "0");
							
							back = String(dnaobj.@back) == "1";
					
							
							return ObjectFactory.model.addObject(new TextureBlock(back, Fuz2d.library, newMaterial(), null, x, y, z, rotation, cast, receive));
							
						case "symbol":
						case "turretsymbol":
						case "segsymbol":
						
							name = (dnaobj.@symbolname != undefined) ? dnaobj.@symbolname : dna.@id;
							
							z = (dnaobj.@z.toString().length > 0) ? parseInt(dnaobj.@z.toString()) : z;
							
							cache = (dnaobj.@cache == "1");
							cast = (dnaobj.@castshadow == "1");
							receive = !(dnaobj.@receiveshadow == "0");
							
							if (rotation == 0) rotation = (dnaobj.@r != undefined) ? parseInt(dnaobj.@r) * Geom2d.dtr : rotation;
							
							var overlay:Boolean = (dnaobj.@overlay != undefined);
							var rectnames:Array = (dnaobj.@graphicsrects) ? String(dnaobj.@graphicsrects).split(",") : null;
							
							if (objType == "symbol") {
								
								return ObjectFactory.model.addObject(new Symbol(name, Fuz2d.library, newMaterial(), null, x, y, z, rotation, scaleX, scaleY, cache, cast, receive, (child is PlayObjectControllable), overlay, rectnames), newLight);
							} else if (objType == "segsymbol") {
								return ObjectFactory.model.addObject(new SegSymbol(name, Fuz2d.library, newMaterial(), null, x, y, z, rotation, scaleX, scaleY, cache, cast, receive, (child is PlayObjectControllable), overlay, rectnames), newLight);
							} else if (objType == "turretsymbol") {
								return ObjectFactory.model.addObject(new TurretSymbol(name, Fuz2d.library, newMaterial(), null, x, y, z, rotation, scaleX, scaleY, cache, cast, receive, (child is PlayObjectControllable), overlay, rectnames), newLight);
							}
							
						case "biped":
						
							var skeletonXML:XML = ObjectFactory.getNodeByNameAndID("skeleton", String(dnaobj.@skeleton));

							return ObjectFactory.model.addObject(new Biped(dnaobj.@symbolname, Fuz2d.library, skeletonXML, null, x, y, z, 1, newMaterial()));
						
						case "mech":
						
							name = (dnaobj.@symbolname != undefined) ? dnaobj.@symbolname : dna.@id;
							return ObjectFactory.model.addObject(new Mech(name, Fuz2d.library, newMaterial(), null, x, y, z, rotation, scaleX, scaleY, cache, cast, receive, (child is PlayObjectControllable)), newLight);
							
					}
					
				}
				
			}
			
			return null;
			
		}
		
		//
		//
		public function newSimulationObject ():SimulationObject {
			
			var ignore:Boolean;
			
			var m:Number;
			var g:Number;
			var damp:Number;
			var rdamp:Number;
			var nosleep:Boolean;
			var nodeData:Array;
			var nodeSet:NodeSet;
			var nodeString:String;
			var vertices:Array;
			var connections:Array;
			var pt:Point;
			var buoyancy:Number;
			var leakage:Number;
			
			if (child == null) return null;

			if (dna != null) {
				
				var dnasimobj:XMLList = dna..simobj;
				
				if (dnasimobj != null) {
					
					var objType:String = dnasimobj.@type;
					var collisionObjType:uint = (dnasimobj.@ct != undefined) ? CollisionObject.parseType(String(dnasimobj.@ct)) : CollisionObject.OBB;
					var onlyStatic:Boolean = (dnasimobj.@only == "1");	
					var reactionType:uint = (dnasimobj.@rt != undefined) ? ReactionType.parseType(String(dnasimobj.@rt)) : ReactionType.BOUNCE;
					
					switch (objType) {
						
						case "sim":
	
							nodeString = dnasimobj.children()[0];
							vertices = [];
							
							
							if (collisionObjType == CollisionObject.POLYGON || collisionObjType == CollisionObject.POLYGON2) {
								
								if (ObjectFactory.cache[dna.@id + "_vertices"] != null) {
									
									vertices = ObjectFactory.cache[dna.@id + "_vertices"];
									connections = ObjectFactory.cache[dna.@id + "_connections"];

								} else if (nodeString != null && nodeString.length > 0) {
									
									nodeData = com.adobe.serialization.json.JSON.decode(nodeString) as Array;
									nodeSet = new NodeSet(nodeData);
									
									vertices = nodeSet.nodesAsPoints;
									for each (pt in vertices) pt.y = 0 - pt.y;
									
									connections = nodeSet.connections;
									
									ObjectFactory.cache[dna.@id + "_vertices"] = vertices;
									ObjectFactory.cache[dna.@id + "_connections"] = connections;
									
								} else {
									
									if (PlayObject(child).object is Symbol) {
										
										var s:Symbol = Symbol(PlayObject(child).object);
							
										var c:Sprite = s.clip;
										c.x = View.mainStage.stageWidth * 0.5;
										c.y = View.mainStage.stageHeight * 0.5;
							
										View.mainStage.addChild(c);
										
										var w:ShrinkWrap = new ShrinkWrap(c, -5);

										View.mainStage.removeChild(c);
										
										vertices = w.bounds.concat();

										for each (pt in vertices) pt.y = 0 - pt.y;
										
										ObjectFactory.cache[dna.@id + "_vertices"] = vertices;
									
									}
							
									
								}
							
							}

							return new SimulationObject(ObjectFactory.simulation, PlayObject(child).object, collisionObjType, reactionType, false, vertices, connections); 
						
						case "vel":
						
							ignore = (dnasimobj.@ignoreSameType == 1) ? true : false;
							var maxPen:int = (dnasimobj.@pen != undefined) ? parseInt(dnasimobj.@pen) : 0;
							var bound:Boolean = (dnasimobj.@bound == "1");
							
							return new VelocityObject(ObjectFactory.simulation, PlayObject(child).object, collisionObjType, reactionType, ignore, onlyStatic, maxPen, bound);
							
						case "mot":

							m = (dnasimobj.@m != undefined) ? parseFloat(dnasimobj.@m) : 1;
							g = (dnasimobj.@g != undefined) ? parseFloat(dnasimobj.@g) : NaN;
							damp = (dnasimobj.@damp != undefined) ? parseFloat(dnasimobj.@damp) : 0.995;
							rdamp = (dnasimobj.@rdamp != undefined) ? parseFloat(dnasimobj.@rdamp) : 0.1;
							nosleep = (dnasimobj.@nosleep == "1") ? true : false;
							ignore = (dnasimobj.@ignoreSameType == 1) ? true : false;
							buoyancy = (dnasimobj.@buoyancy != undefined) ? parseFloat(dnasimobj.@buoyancy) : 0;
							leakage = (dnasimobj.@leakage != undefined) ? parseFloat(dnasimobj.@leakage) : 0;
							
							return new MotionObject(ObjectFactory.simulation, PlayObject(child).object, collisionObjType, reactionType, m, g, damp, rdamp, ignore, onlyStatic, nosleep, buoyancy, leakage);
						
						case "compound":

							nodeString = dnasimobj.children()[0];
							m = (dnasimobj.@m != undefined) ? parseFloat(dnasimobj.@m) : 1;
							g = (dnasimobj.@g != undefined) ? parseFloat(dnasimobj.@g) : NaN;
							damp = (dnasimobj.@damp != undefined) ? parseFloat(dnasimobj.@damp) : 0.995;
							rdamp = (dnasimobj.@rdamp != undefined) ? parseFloat(dnasimobj.@rdamp) : 0.1;
							nosleep = (dnasimobj.@nosleep == "1") ? true : false;
							ignore = (dnasimobj.@ignoreSameType == 1) ? true : false;
							buoyancy = (dnasimobj.@buoyancy != undefined) ? parseFloat(dnasimobj.@buoyancy) : 0;
							leakage = (dnasimobj.@leakage != undefined) ? parseFloat(dnasimobj.@leakage) : 0;
							
							var subsymbolname:String = (dna..obj.@subsymbolname != undefined) ? dna..obj.@subsymbolname : "";
							
							if (ObjectFactory.cache[dna.@id + "_vertices"] != null) {
								
								vertices = ObjectFactory.cache[dna.@id + "_vertices"];

							} else if (nodeString != null && nodeString.length > 0) {
								
								nodeData = com.adobe.serialization.json.JSON.decode(nodeString) as Array;
								nodeSet = new NodeSet(nodeData);
								
								vertices = nodeSet.nodesAsPoints;
								for each (pt in vertices) pt.y = 0 - pt.y;
								
								ObjectFactory.cache[dna.@id + "_vertices"] = vertices;

							}
							
							var radius:Number = (dnasimobj.@radius != undefined) ? parseFloat(dnasimobj.@radius) : 20;
							
							return new CompoundObject(ObjectFactory.simulation, PlayObject(child).object, collisionObjType, reactionType, m, g, damp, rdamp, ignore, onlyStatic, nosleep, vertices, radius, subsymbolname, buoyancy, leakage);
								
					}
					
				}
				
			}
			
			return null;
			
		}
		
		//
		//
		public function addBehaviors (behaviorManager:BehaviorManager):void {
			
			if (dna..behavior != null) {
				
				var behaviors:XMLList = dna..behavior;
				var b:Behavior;
				
				for each (var behavior:XML in behaviors) {
					
					switch (String(behavior.@type)) {
						
						case "collide":
						
							b = behaviorManager.add(new CollisionBehavior());
							break;
							
						case "stand":
						
							b = behaviorManager.add(new StandBehavior());
							break;
							
						case "walk":

							b = behaviorManager.add(new WalkBehavior());
							if (behavior.@sound == "1") WalkBehavior(b).soundEvents = true;
							break;	
							
						case "swim":
						
							b = behaviorManager.add(new SwimBehavior());
							break;	
							
						case "weakblock":
						
							var strength:int = 10;
							if (behavior.@strength != undefined) strength = parseInt(behavior.@strength);
							
							var damage:String = "weight";
							if (behavior.@damage != undefined) {
								damage = (behavior.@damage); // weight, hit, heat
							}
							
							var explode:Boolean = ("@explode" in behavior && behavior.@explode == "1");
							var radius:int = ("@radius" in behavior) ? parseInt(behavior.@radius) : 100;
							
							var resilience:Number = ("@resilience" in behavior) ? parseInt(behavior.@resilience) : 0;
							var damageby:String = ("@damageby" in behavior) ? behavior.@damageby : "";
						
							b = behaviorManager.add(new WeakBlockBehavior(strength, damage, explode, radius, resilience, damageby));
							break;	
							
						case "death":
							
							// remove, passthrough, bloom, shatter, explode
							
							var style:String = ("@style" in behavior) ? behavior.@style : "remove";
							strength = ("@strength" in behavior) ? parseInt(behavior.@strength) : 10;
							radius = ("@radius" in behavior) ? parseInt(behavior.@radius) : 100;
							var effectclip:String = ("@effect" in behavior) ? behavior.@effect : "";
						
							b = behaviorManager.add(new DeathBehavior(style, strength, radius, effectclip));
							break;	
								
						
					}
					
					if (b != null && parseInt(behavior.@prio) > 0) b.priority = parseInt(behavior.@prio);
					
				}
				
			}
			
		}
		
		//
		//
		public function newController ():Controller {
			
			var vel:Vector2d;
			var lockX:Boolean;
			var lockY:Boolean;
			var strength:Number;
			var lifeSpan:int;
			var aggression:int;
			var range:int;
			var bounce:Boolean;
			var soundID:String;
			var name:String;
			var delay:int;
			var sound:String;
			var loopsound:Boolean;
			
			var fireobj:String = "";
			var firedelay:int = 0;
			var firepower:int = 100;
			
			if (dna != null) {
				
				var dnactrl:XMLList = dna..ctrl;
				
				if (dnactrl != null) {
					
					switch (String(dnactrl.@method)) {
						
						case "kbd":
						
							switch (String(dnactrl.@type)) {
								
								case "playobj":
								
									return new PlayObjectKeyboardController(child as PlayObjectMovable);
									break;

								case "bipedobj":
								
									return new BipedKeyboardController(child as BipedObject);
									break;
									
								case "drive":
								
									name = (dnactrl.@projectile != undefined) ? String(dnactrl.@projectile) : "";
									delay = (dnactrl.@firedelay != undefined) ? parseInt(dnactrl.@firedelay) : 0;
									
									return new DriveKeyboardController(child as PlayObjectControllable, name, delay);
									break;
									
								case "mech":
								
									name = (dnactrl.@projectile != undefined) ? String(dnactrl.@projectile) : "";
									delay = (dnactrl.@firedelay != undefined) ? parseInt(dnactrl.@firedelay) : 0;
									
									return new MechKeyboardController(child as PlayObjectControllable, name, delay);
									break;
									
								case "fly":
								
									name = (dnactrl.@projectile != undefined) ? String(dnactrl.@projectile) : "";
									delay = (dnactrl.@firedelay != undefined) ? parseInt(dnactrl.@firedelay) : 0;
									
									return new FlyKeyboardController(child as PlayObjectControllable, name, delay);
									break;
									
							}
						
							break;
							
						case "cpu":
						default:

							switch (String(dnactrl.@type)) {
								
								case "power":
									
									var power:int = 1;
									if (dnactrl.@power != undefined) power = parseInt(dnactrl.@power);
									
									var restore:int = -1;
									if (dnactrl.@restore != undefined) restore = parseInt(dnactrl.@restore);
								
									var addToBelt:Boolean = (dnactrl.@addtobelt == "1");
									
									soundID = (dnactrl.@sound != undefined) ? String(dnactrl.@sound) : "powerup";
									
									var attribIsGlobal:Boolean = ("@global" in dnactrl && dnactrl.@global == "1");
									var attribIsModifier:Boolean = ("@modifier" in dnactrl && dnactrl.@modifier == "1");
									var spendAtEnd:Boolean = ("@spendatend" in dnactrl && dnactrl.@spendatend == "1");
									
									return new PowerUpController(child as PlayObjectControllable, dnactrl.@attrib, attribIsModifier, attribIsGlobal, power, restore, addToBelt, spendAtEnd, soundID); 
								
								case "escapepod":
								
									return new EscapePodController(child as PlayObjectControllable);
									
								case "door":
								
									var near:Boolean = false;
									if (dnactrl.@near == "1") near = true;
									
									var key:String = (dnactrl.@key != undefined) ? String(dnactrl.@key) : "";
									var oneway:String = (dnactrl.@oneway != undefined) ? String(dnactrl.@oneway) : "";
									
									return new DoorController(child as PlayObjectControllable, near, key, oneway); 
									
								case "light":
								
									return new LightController(child as PlayObjectControllable);
									
								case "teleporter":
							
									var group:String = "none";
									if (dnactrl.@group != undefined) group = String(dnactrl.@group);
									
									return new TeleportController(child as PlayObjectControllable, group); 
									
								case "switch":

									if (dnactrl.@name != undefined) name = String(dnactrl.@name);
									delay = (dnactrl.@delay != undefined) ? parseInt(dnactrl.@delay) : 1000;
									var localize:Boolean = (dnactrl.@local == "1");
									
									return new SwitchController(child as PlayObjectControllable, name, localize, delay); 
									
								case "trigger":
									
									if (dnactrl.@name != undefined) name = String(dnactrl.@name);
									delay = (dnactrl.@delay != undefined) ? parseInt(dnactrl.@delay) : 0;
									
									var cascade:int = (dnactrl.@cascade != undefined) ? parseInt(dnactrl.@cascade) : 500;
									var onatstart:Boolean = ("@onatstart" in dnactrl && dnactrl.@onatstart == "1");
									
									return new TriggerController(child as PlayObjectControllable, name, delay, cascade, onatstart); 
									
								case "drop":
																	
									strength = 10;
									if (dnactrl.@strength != undefined) strength = parseInt(dnactrl.@strength);
									
									return new DropController(child as PlayObjectControllable, strength, dnactrl.@effect); 
									
								case "beam":
								
									strength = 1;
									if (dnactrl.@strength != undefined) strength = parseInt(dnactrl.@strength);
									soundID = (dnactrl.@sound != undefined) ? String(dnactrl.@sound) : "beam";
									
									return new BeamHarmerController(child as PlayObjectControllable, strength, soundID);
									
								case "platform":
								
									vel = new Vector2d(null, parseInt(dnactrl.@vx), parseInt(dnactrl.@vy));
									lockX = (vel.y != 0);
									lockY = (vel.x != 0);

									return new PlatformController(child as PlayObjectControllable, vel, lockX, lockY);
									
								case "link":
								
									return new LinkController(child as PlayObjectControllable);
									
								case "crusher":
								
									speed = (dnactrl.@speed) ? parseInt(dnactrl.@speed) : 3;
									
									var started:Boolean = !(dnactrl.@started && dnactrl.@started == "0");
									var yoyo:Boolean = !(dnactrl.@yoyo && dnactrl.@yoyo == "0");
								
									return new CrusherController(child as PlayObjectControllable, speed, started, yoyo); 
								
								case "spring":
								
									lockX = (dnactrl.@lockx == "1");
									lockY = (dnactrl.@locky == "1");
									var k:Number = (dnactrl.@k != undefined) ? parseFloat(dnactrl.@k) : 1;
									bounce = (dnactrl.@bounce == "1");
									
									return new SpringController(child as PlayObjectControllable, k, bounce, lockX, lockY); 
								
								case "push":
								
									lockX = (dnactrl.@lockx == "1");
									lockY = (dnactrl.@locky == "1");

									return new PushController(child as PlayObjectControllable, lockX, lockY); 
									
								case "burst":
								
									return new BurstController(child as PlayObjectControllable);
									
								case "projectile":
									
									var speed:Number = (dnactrl.@speed != undefined) ? parseFloat(dnactrl.@speed) : 1;
									
									if (speed != 1) {
										velocity.normalize(1);
										velocity.scaleBy(speed);
									}
									
									strength = 1;
									if (dnactrl.@strength != undefined) strength = parseInt(dnactrl.@strength);
										
									lifeSpan = 3;
									if (dnactrl.@lifespan != undefined) lifeSpan = parseInt(dnactrl.@lifespan);
									
									var drop:int = 0;
									if (dnactrl.@drop != undefined) drop = parseInt(dnactrl.@drop);
									
									var push:Number = 1;
									if ("@push" in dnactrl) push = parseFloat(dnactrl.@push);
									
									bounce = false;
									if (dnactrl.@bounce != undefined) bounce = (dnactrl.@bounce == "1");
									
									var hiteffect:String = (dnactrl.@hiteffect != undefined) ? String(dnactrl.@hiteffect) : "";
									var bounceeffect:String = (dnactrl.@bounceeffect != undefined) ? String(dnactrl.@bounceeffect) : "";
									
									return new ProjectileController(child as PlayObjectControllable, velocity, strength, lifeSpan, drop, push, hiteffect, bounce, bounceeffect);
									
								case "spray":
									
									strength = 1;
									if (dnactrl.@strength != undefined) strength = parseFloat(dnactrl.@strength);
									
									lifeSpan = 3;
									if (dnactrl.@lifespan != undefined) lifeSpan = parseInt(dnactrl.@lifespan);
									
									var forceFactor:Number = (dnactrl.@force != undefined) ? parseFloat(dnactrl.@force) : 0;
											
									sound = (dnactrl.@sound != undefined) ? dnactrl.@sound : "";
									loopsound = (dnactrl.@loop == "1");
		
									return new SprayController(child as PlayObjectControllable, strength, forceFactor, lifeSpan, sound, loopsound);
									
								case "bomb":
									
									strength = 10;
									if (dnactrl.@strength != undefined) strength = parseInt(dnactrl.@strength);
									
									var radius:int = 200;
									if (dnactrl.@radius != undefined) radius = parseInt(dnactrl.@radius);
									
									lifeSpan = 3;
									if (dnactrl.@lifespan != undefined) lifeSpan = parseInt(dnactrl.@lifespan);
								
									return new BombController(child as PlayObjectControllable, strength, radius, lifeSpan);
									
								case "harmtouch":
									
									strength = 10;
									if (dnactrl.@strength != undefined) strength = parseInt(dnactrl.@strength);
									
									var pressure:Boolean = ("@pressure" in dnactrl && dnactrl.@pressure == "1");
							
									return new HarmTouchController(child as PlayObjectControllable, strength, pressure, dnactrl.@effect);
									
								case "spin":
								
									var dir:int = 1;
									if (dnactrl.@dir != undefined) dir = parseInt(dnactrl.@dir);
									
									var freespin:Boolean = ("@freespin" in dnactrl) ? (dnactrl.@freespin == "1") : false;
								
									return new SpinController(child as PlayObjectControllable, dir, freespin);
									
								case "proximity":
								
									var spawn:String = (dnactrl.@spawn != undefined) ? dnactrl.@spawn : "";
									range = (dnactrl.@range != undefined) ? parseInt(dnactrl.@range) : 300;
									delay = (dnactrl.@delay != undefined) ? parseInt(dnactrl.@delay) : 0;
									
									return new ProximityController(child as PlayObjectControllable, spawn, range, delay);
									
								case "enemy":
								
									speed = (dnactrl.@speed != undefined) ? parseInt(dnactrl.@speed) : 5;
									aggression = (dnactrl.@aggression != undefined) ? parseInt(dnactrl.@aggression) : 50;
									range = (dnactrl.@range != undefined) ? parseInt(dnactrl.@range) : 0;
									
									return new EnemyController(child as PlayObjectControllable, speed, aggression, range);
									
								case "rangedenemy":
								
									speed = (dnactrl.@speed != undefined) ? parseInt(dnactrl.@speed) : 5;
									aggression = (dnactrl.@aggression != undefined) ? parseInt(dnactrl.@aggression) : 50;
									range = (dnactrl.@range != undefined) ? parseInt(dnactrl.@range) : 0;
									
									return new RangedEnemyController(child as PlayObjectControllable, speed, aggression, range);
									
								case "flyingenemy":
								case "flyingenemyprobe":
								case "flyingally":
									
									speed = (dnactrl.@speed != undefined) ? parseInt(dnactrl.@speed) : 5;
									aggression = (dnactrl.@aggression != undefined) ? parseInt(dnactrl.@aggression) : 50;
									range = (dnactrl.@range != undefined) ? parseInt(dnactrl.@range) : 0;
									
									var bank:Boolean = (dnactrl.@bank == "1");
									
									if ("@fire" in dnactrl) fireobj = String(dnactrl.@fire);
									if ("@firedelay" in dnactrl) firedelay = parseInt(dnactrl.@firedelay);
									if ("@firepower" in dnactrl) firepower = parseInt(dnactrl.@firepower);
									
									switch (String(dnactrl.@type))
									{
										case "flyingenemy":
											return new FlyingEnemyController(child as PlayObjectControllable, speed, aggression, range, fireobj, firedelay, firepower, bank);
								
										case "flyingenemyprobe":
											return new FlyingEnemyProbeController(child as PlayObjectControllable, speed, aggression, range, fireobj, firedelay, firepower, bank);
								
										case "flyingally":
											return new FlyingAllyController(child as PlayObjectControllable, speed, aggression, range, fireobj, firedelay, firepower, bank);
									}
									
								case "turretenemy":
								
									speed = (dnactrl.@speed != undefined) ? parseInt(dnactrl.@speed) : 5;
									aggression = (dnactrl.@aggression != undefined) ? parseInt(dnactrl.@aggression) : 50;
									range = (dnactrl.@range != undefined) ? parseInt(dnactrl.@range) : 0;
									
									if ("@fire" in dnactrl) fireobj = String(dnactrl.@fire);
									if ("@firedelay" in dnactrl) firedelay = parseInt(dnactrl.@firedelay);
									if ("@firepower" in dnactrl) firepower = parseInt(dnactrl.@firepower);
									
									return new TurretEnemyController(child as PlayObjectControllable, speed, aggression, range, fireobj, firedelay, firepower);
								
									
								case "mech":
									
									speed = (dnactrl.@speed != undefined) ? parseInt(dnactrl.@speed) : 5;
									aggression = (dnactrl.@aggression != undefined) ? parseInt(dnactrl.@aggression) : 50;
									range = (dnactrl.@range != undefined) ? parseInt(dnactrl.@range) : 0;
									
									if ("@fire" in dnactrl) fireobj = String(dnactrl.@fire);
									if ("@firedelay" in dnactrl) firedelay = parseInt(dnactrl.@firedelay);
									
									return new MechEnemyController(child as PlayObjectControllable, speed, aggression, range, fireobj, firedelay);
									
								case "seg":
								
									return new SegController(child as PlayObjectControllable);
									
								case "swim":
									
									speed = (dnactrl.@speed != undefined) ? parseInt(dnactrl.@speed) : 5;
									aggression = (dnactrl.@aggression != undefined) ? parseInt(dnactrl.@aggression) : 50;
									range = (dnactrl.@range != undefined) ? parseInt(dnactrl.@range) : 0;
									
									if ("@fire" in dnactrl) fireobj = String(dnactrl.@fire);
									if ("@firedelay" in dnactrl) firedelay = parseInt(dnactrl.@firedelay);
									
									return new SwimmingEnemyController(child as PlayObjectControllable, speed, aggression, range, fireobj, firedelay);
								
								case "speech":
								
									var message:String = (data != null && data.length > 0) ? unescape(unescape(data[0])) : "";
									return new SpeechObjectController(child as PlayObjectControllable, message);
									
								case "leveldoor":
								
									return new LevelDoorController(child as PlayObjectControllable);
										
									
							}
						
							break;
						
					}
					
				}
			
			}
			
			return null;
			
		}
		
	}
	
}