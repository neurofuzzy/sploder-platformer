package com.sploder
{
	import com.sploder.util.PlayTimeCounter;
	import com.sploder.util.StringUtils;
	import flash.display.FrameLabel;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import fuz2d.action.control.PowerUpController;
	import fuz2d.action.play.BipedObject;
	import fuz2d.action.play.Playfield;
	import fuz2d.action.play.PlayfieldEvent;
	import fuz2d.action.play.PlayObject;
	import fuz2d.action.play.PlayObjectControllable;
	import fuz2d.Fuz2d;
	import fuz2d.model.object.Toolset;
	import fuz2d.sound.SoundManager;
	import fuz2d.TimeStep;
	
	/**
	 * ...
	 * @author ...
	 */
	public class GameConsole extends EventDispatcher {
		
		public static const TEST_COMPLETE:String = "test_complete";
		
		public static var firstPlay:Boolean = true;
		
		protected var _game:Game;
		protected var _container:Sprite;
		protected var _width:int;
		protected var _height:int;
		
		protected var _clip:Sprite;
		protected var _titleScreen:MovieClip;
		protected var _pauseScreen:Sprite;
		protected var _helpScreen:MovieClip;
		protected var _endScreen:MovieClip;
		protected var _leaderboard:Leaderboard;
		protected var _voteWidget:VoteWidget;
		
		protected var _gameStats:MovieClip;
		protected var _ammoStats:Sprite;
		protected var _playerHealthText:MovieClip;
		protected var _playerHealth:MovieClip;
		protected var _playerStamina:MovieClip;
		protected var _playerLives:MovieClip;
		protected var _playerAbilities:MovieClip;
		protected var _abilityStomp:MovieClip;
		protected var _abilitySmash:MovieClip;
		protected var _abilityRoll:MovieClip;
		protected var _abilityDoubleJump:MovieClip;
		
		protected var _radarScreen:MovieClip;
		protected var _topBar:MovieClip;
		protected var _taskNotice:MovieClip;
		protected var _bottomBar:MovieClip;
		protected var _bottomBarBackground:MovieClip;
		protected var _helpButton:SimpleButton;
		protected var _musicIcon:MovieClip;
		protected var _soundStatusTF:TextField;
		protected var _logo:Sprite;
		protected var _soundToggle:MovieClip;
		protected var _soundToggleButton:SimpleButton;
		
		protected var _ammoGun:TextField;
		protected var _ammoBlaster:TextField;
		protected var _ammoGrenades:TextField;
		protected var _ammoGrapple:MovieClip;
		protected var _ammoPowerglove:MovieClip;
		protected var _ammoBackpack:MovieClip;
		
		protected var _musicTrack:String = "";
		public function get musicTrack():String { return _musicTrack; }
		public function set musicTrack(value:String):void 
		{
			_musicTrack = value;
			updateSoundStatus();
		}
		
		public var radar:Radar;
		
		protected var _healthEventSent:Boolean = false;
		protected var _winEventSent:Boolean = false;
		
		protected var _paused:Boolean = true;
		protected var _titleShowing:Boolean = true;
		protected var _wonGame:Boolean = false;
		protected var _finishing:Boolean = false;
		protected var _finishTimer:Timer;
		
		protected var _playtimeText:TextField;
		protected var _prevSecondsCounted:int = -1;
		protected var _prevComplete:Boolean = false;
		
		protected var _displayedLives:int = 1;
		
		protected var _taskNoticeTimer:Timer;
			
		//
		//
		public function GameConsole (game:Game, container:Sprite, width:int, height:int) 
		{
			_game = game;
			_container = container;
			_width = width;
			_height = height;

			build();
			
		}
		
		//
		//
		protected function build ():void {
			
			_clip = _game.uiLibrary.getDisplayObject("console") as Sprite;
			_clip.mouseEnabled = true;
			_clip.mouseChildren = true;
			_clip.tabEnabled = false;
			_clip.tabChildren = false;
			_clip.focusRect = false;
			_container.addChild(_clip);
			
			initConsole();
			showTitleScreen();
			
		}
		
		//
		//
		protected function initConsole ():void {
			
			_ammoStats = _clip["ammo_stats"];
			_ammoStats.x = Game.gameInstance.width - _ammoStats.width - 5;
			
			_gameStats = _clip["game_stats"];
			_playerHealthText = _clip["playerHealthText"];
			_playerHealthText.x = Game.gameInstance.width - 277;
			_playerHealth = _clip["player_health"];
			_playerHealth.gotoAndStop(1);
			_playerHealth.x = Game.gameInstance.width - 247;
			
			_playerStamina = _clip["player_stamina"];
			_playerStamina.x = Game.gameInstance.width - 247;
			_playerLives = _clip["lives"];
			_playerLives.x = Game.gameInstance.width - 345;
			
			_playerAbilities = _clip["abilities"];
			_playerAbilities.x = Game.gameInstance.width - 455;
			_abilityStomp = _playerAbilities["stomp"];
			_abilitySmash = _playerAbilities["smash"];
			_abilityRoll = _playerAbilities["roll"];
			_abilityDoubleJump = _playerAbilities["doublejump"];
			
			resetAbilities();
			initLives();
			
			SimpleButton(_abilityStomp["btn"]).addEventListener(MouseEvent.ROLL_OVER, onAbilityMouseEvent);
			SimpleButton(_abilityStomp["btn"]).addEventListener(MouseEvent.ROLL_OUT, onAbilityMouseEvent);
			
			SimpleButton(_abilitySmash["btn"]).addEventListener(MouseEvent.ROLL_OVER, onAbilityMouseEvent);
			SimpleButton(_abilitySmash["btn"]).addEventListener(MouseEvent.ROLL_OUT, onAbilityMouseEvent);
			
			SimpleButton(_abilityRoll["btn"]).addEventListener(MouseEvent.ROLL_OVER, onAbilityMouseEvent);
			SimpleButton(_abilityRoll["btn"]).addEventListener(MouseEvent.ROLL_OUT, onAbilityMouseEvent);
			
			SimpleButton(_abilityDoubleJump["btn"]).addEventListener(MouseEvent.ROLL_OVER, onAbilityMouseEvent);
			SimpleButton(_abilityDoubleJump["btn"]).addEventListener(MouseEvent.ROLL_OUT, onAbilityMouseEvent);
			
			_topBar = _clip["topbar"];
			_topBar.width = Game.gameInstance.width;
			
			_radarScreen = _clip["radarScreen"];
			_radarScreen.gotoAndStop(1);

			_radarScreen.x = Game.gameInstance.width - 120;
			_radarScreen.y = Game.gameInstance.height - 130;
			
			_taskNotice = _clip["taskNotice"];
			_taskNotice.x = (Game.gameInstance.width - _taskNotice.width) * 0.5;
			_taskNotice.y = Game.gameInstance.height - 80;
			_taskNotice.visible = false;
			
			_bottomBar = _clip["bottom_bar"];
			_bottomBar.y = Game.gameInstance.height - 20;
			
			_bottomBarBackground = _bottomBar["bkgd"];
			_bottomBarBackground.width = Game.gameInstance.width;
			_playtimeText = _bottomBar.getChildByName("playtime") as TextField;
			_playtimeText.x = Game.gameInstance.width - _playtimeText.width - 4;
			
			_helpButton = _clip["help"];
			_helpButton.y = Game.gameInstance.height - 29;
			
			_musicIcon = _bottomBar["music"];
			_soundStatusTF = _bottomBar["soundstatus"];
			
			_logo = _bottomBar["logo"];
			_logo.x = Game.gameInstance.width - Math.floor(_logo.width) - 20;
			
			_soundToggle = _bottomBar["soundtoggle"];
			_soundToggle.x = Game.gameInstance.width - _soundToggle.width
			
			if (SoundManager.hasSound) _soundToggle.gotoAndStop(1);
			else _soundToggle.gotoAndStop(2);
			
			_soundToggleButton = _soundToggle["btn"];
			
			_soundToggleButton.addEventListener(MouseEvent.CLICK, onSoundToggleButtonClicked, false, 0, true);
			_helpButton.addEventListener(MouseEvent.CLICK, onHelpButtonClicked, false, 0, true);

			_ammoBackpack = _ammoStats["ammo_backpack"];
			_ammoBlaster = _ammoStats["ammo_blaster"];
			_ammoGrapple = _ammoStats["ammo_grapple"];
			_ammoGrenades = _ammoStats["ammo_grenade"];
			_ammoGun = _ammoStats["ammo_gun"];
			_ammoPowerglove = _ammoStats["ammo_powerglove"];
			
			if (_game.currentLevel && _game.currentLevel.fuz2d) {
				registerPlayfield(_game.currentLevel.fuz2d.playfield);
				registerPlayer();
			}
			
			updateGameType();
			updateStatus();
			
			if (_container && _container.stage) {
				_container.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
				if (PlayTimeCounter.showTime) {
					_container.stage.addEventListener(Event.ENTER_FRAME, updatePlayTime, false, 0, true);
					_bottomBarBackground.gotoAndStop(2);
					_logo.visible = false;
					_soundToggle.x -= 104;
				} else {
					_playtimeText.visible = false;
				}
			}
			
		}
		
		public function updateGameType ():void {
			
			if (_game.currentLevel.gameObjective.type == GameObjective.TYPE_MELEE) _gameStats.gotoAndStop(2);
			else if (_game.currentLevel.gameObjective.type == GameObjective.TYPE_CAPTURE) _gameStats.gotoAndStop(3);
			else if (_game.currentLevel.gameObjective.type == GameObjective.TYPE_ESCAPE) _gameStats.gotoAndStop(4);	
			
			onStatusChange();
			
		}
		
		//
		//
		public function updateStatus (e:Event = null):void {
			
			onToolCountChange();
			onHealthChange();
			onStatusChange();
			updateLives();
			
		}
		
		protected function updatePlayTime (e:Event):void {
			
			if (PlayTimeCounter.mainInstance != null) {
				
				var st:int = PlayTimeCounter.mainInstance.secondsCounted;
				
				if (_playtimeText != null && (_prevSecondsCounted != st || _prevComplete != PlayTimeCounter.mainInstance.complete)) {
					
					_prevSecondsCounted = st;
					_prevComplete = PlayTimeCounter.mainInstance.complete;
					
					if (PlayTimeCounter.timeLimit == 0) {
						_playtimeText.htmlText = StringUtils.timeInMinutes(_prevSecondsCounted);
					} else {
						var timeleft:int = Math.max(0, PlayTimeCounter.timeLimit - _prevSecondsCounted);
						var timeleftDisplay:String = StringUtils.timeInMinutes(timeleft);
						if (_prevComplete && timeleft > 0)
						{
							_playtimeText.htmlText = '<font color="#00ff66">' + timeleftDisplay + '</font>';
						}
						else if (timeleft < 20) {
							_playtimeText.htmlText = '<font color="#ff3300">' + timeleftDisplay + '</font>';
						} else {
							_playtimeText.htmlText = timeleftDisplay;
						}
					}
					
				}
			
			}
			
		}
		
		//
		//
		public function registerPlayfield (playfield:Playfield):void {
			
			if (radar == null) {

				radar = new Radar(_radarScreen, playfield);
				trace("REGISTERNG PLAYFIELD");
			} else {
				
				radar.setPlayfield(playfield);
				
			}
			
			
		}
		
		public function unregisterPlayfield ():void {
			
			if (radar != null) radar.setPlayfield();
			
		}
		
		//
		//
		public function reinit ():void {
			
			initConsole();
			
		}
		
		public function registerPlayer ():void {
			
			GameLevel.player.addEventListener(PlayObject.EVENT_HEALTH, onHealthChange, false, 0, true);
			GameLevel.player.addEventListener(BipedObject.EVENT_STAMINA, onStaminaChange, false, 0, true);
			
			GameLevel.player.body.tools_rt.events.addEventListener(Toolset.TOOL_COUNT, onToolCountChange, false, 0, true);
			GameLevel.player.body.tools_lt.events.addEventListener(Toolset.TOOL_COUNT, onToolCountChange, false, 0, true);
			GameLevel.player.body.tools_back.events.addEventListener(Toolset.TOOL_COUNT, onToolCountChange, false, 0, true);
			
			GameLevel.player.playfield.addEventListener(PlayfieldEvent.POWERUP, onStatusChange, false, 0, true);
			GameLevel.player.playfield.addEventListener(PlayfieldEvent.DEATH, onStatusChange, false, 0, true);
			GameLevel.player.playfield.addEventListener(PlayfieldEvent.ESCAPED, onStatusChange, false, 0, true);			
			
		}
		
		public function unregisterPlayer (death:Boolean = true):void {
			
			if (GameLevel.player && GameLevel.player.body && GameLevel.player.playfield) {
				
				GameLevel.player.removeEventListener(PlayObject.EVENT_HEALTH, onHealthChange);
				GameLevel.player.removeEventListener(BipedObject.EVENT_STAMINA, onStaminaChange);
				
				GameLevel.player.body.tools_rt.events.removeEventListener(Toolset.TOOL_COUNT, onToolCountChange);
				GameLevel.player.body.tools_lt.events.removeEventListener(Toolset.TOOL_COUNT, onToolCountChange);
				GameLevel.player.body.tools_back.events.removeEventListener(Toolset.TOOL_COUNT, onToolCountChange);
				
				GameLevel.player.playfield.removeEventListener(PlayfieldEvent.POWERUP, onStatusChange);
				GameLevel.player.playfield.removeEventListener(PlayfieldEvent.DEATH, onStatusChange);
				GameLevel.player.playfield.removeEventListener(PlayfieldEvent.ESCAPED, onStatusChange);
			
			}
			
			if (death) resetAbilities();
			
		}
		
		
		//
		//
		public function finishGame (won:Boolean):void {
			
			if (!_finishing) {
				
				_finishing = true;
				
				_wonGame = won;
				
				_finishTimer = new Timer(1000, 1);
				_finishTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onFinishGameTimer);
				_finishTimer.start();
				
			}
			
		}
		
		//
		//
		protected function onFinishGameTimer (e:TimerEvent):void {
			
			if (_finishTimer) {
				_finishTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onFinishGameTimer);
				Game.endGame(_wonGame);
				showEndScreen();
				_finishTimer = null;
			}
			
		}
		

		//
		//
		public function showPauseScreen ():void {
			
			if (_pauseScreen) {
				_pauseScreen.visible = true;
			} else {
				_pauseScreen = _game.uiLibrary.getDisplayObject("pausescreen") as Sprite;
				_pauseScreen.mouseEnabled = _pauseScreen.mouseChildren = false;
				_pauseScreen.x = Math.floor(_width * 0.5)
				_pauseScreen.y = Math.floor(_height * 0.5) - 10;	
			}
			_container.addChild(_pauseScreen);
			
		}
		
		//
		//
		public function hidePauseScreen ():void {
			
			if (_pauseScreen) {
				_pauseScreen.visible = false;
				if (_pauseScreen.parent) _pauseScreen.parent.removeChild(_pauseScreen);
			}
		}
		
		//
		//
		public function showHelpScreen ():void {
			
			if (_helpScreen) {
				_helpScreen.visible = true;
			} else {
				_helpScreen = _game.uiLibrary.getDisplayObject("helpscreen") as MovieClip;
				_helpScreen.x = Math.floor(_width * 0.5)
				_helpScreen.y = Math.floor(_height * 0.5) - 10;
				_helpScreen["resume"].addEventListener(MouseEvent.CLICK, onHelpResume)
			}
			_container.addChild(_helpScreen);	
		}
		
		//
		//
		public function hideHelpScreen ():void {
			
			if (_helpScreen) {
				_helpScreen.visible = false;
				if (_helpScreen.parent) _helpScreen.parent.removeChild(_helpScreen);
			}
		}
		
		//
		//
		protected function resetAbilities ():void {
			
			_abilityStomp.gotoAndStop(1);
			_abilitySmash.gotoAndStop(1);
			_abilityRoll.gotoAndStop(1);
			_abilityDoubleJump.gotoAndStop(1);			
			
		}
		
		public function updateAbilities ():void {
			
			if (GameLevel.playerAttribs) {
				var a:Object = GameLevel.playerAttribs;
				
				if (a["roll"]) _abilityRoll.gotoAndStop(2);
				if (a["smash"]) _abilitySmash.gotoAndStop(2);
				if (a["stomp"]) _abilityStomp.gotoAndStop(2);
				if (a["doublejump"]) _abilityDoubleJump.gotoAndStop(2);
			}
			
		}
		
		
		//
		//
		protected function onAbilityMouseEvent (e:MouseEvent):void {
			
			var t:MovieClip;
			t = e.target.parent["tooltip"];
			
			if (t) {
				
				switch (e.type) {
					
					case MouseEvent.ROLL_OVER:
						t.visible = true;
						t.gotoAndPlay(1);
						break;
					
					case MouseEvent.ROLL_OUT:
						t.visible = false;
						break;
				}
			
			}
			
		}
		
		//
		//
		protected function onToolCountChange (e:Event = null):void {
			
			if (GameLevel.player != null && GameLevel.player.body != null) {
				
				var tools_rt:Toolset = GameLevel.player.body.tools_rt;
				var tools_lt:Toolset = GameLevel.player.body.tools_lt;
				var tools_back:Toolset = GameLevel.player.body.tools_back;
				
				_ammoBackpack["value"] = tools_back.getToolCount("backpack");
				_ammoBlaster.text = "" + tools_rt.getToolCount("blaster");
				_ammoGrapple["value"] = tools_lt.getToolCount("grapple");
				_ammoGrenades.text = "" + tools_rt.getToolCount("grenade");
				_ammoGun.text = "" + tools_rt.getToolCount("gun");
				_ammoPowerglove["value"] = tools_lt.getToolCount("powerglove");
				
			}
			
		}
		
		//
		//
		protected function onHealthChange (e:Event = null):void {
			
			if (GameLevel.player) {
				
				var health:Number = _playerHealth.width = Math.max(0, Math.min(100, 100 * GameLevel.player.health / GameLevel.player.maxHealth));
				
				if (health <= 25) _playerHealth.gotoAndStop(2);
				else _playerHealth.gotoAndStop(1);
				
				if (health <= 25) {
					if (!_healthEventSent) {
						_healthEventSent = true;
						Game.sendEvent(4);
					}
				}
				
				if (health <= 0) {
					
					unregisterPlayer();
					_game.currentLevel.losePlayerLife();
				}
				
				updateLives();
				
			}
			
		}
		
		//
		//
		protected function onStaminaChange (e:Event = null):void {
			
			if (GameLevel.player) _playerStamina.width = Math.max(0, Math.min(100, GameLevel.player.stamina));
			
		}
		
		//
		//
		protected function onStatusChange (e:PlayfieldEvent = null):void {
			
			var currentCount:int;
			var total:int;
			
			if (e && e.type == PlayfieldEvent.POWERUP && 
				e.playObject is PlayObjectControllable && 
				PlayObjectControllable(e.playObject).controller is PowerUpController) {
					
				var attrib:String = PowerUpController(PlayObjectControllable(e.playObject).controller).powerAttribName;
				
				switch (attrib) {
				
					case "stomp":
						_abilityStomp.gotoAndStop(2);
						return;
						
					case "smash":
						_abilitySmash.gotoAndStop(2);
						return;
						
					case "roll":
						_abilityRoll.gotoAndStop(2);
						return;
						
					case "doublejump":
						_abilityDoubleJump.gotoAndStop(2);
						return;
						
					case "extralife":
						updateLives();
						return;
					
				}
					
			}
				
			
			if (_game.currentLevel.gameObjective.type == GameObjective.TYPE_MELEE) {
				
				currentCount = (PlayObject.totals["evil"] - PlayObject.counts["evil"]);
				total = PlayObject.totals["evil"];
				
			} else if (_game.currentLevel.gameObjective.type == GameObjective.TYPE_CAPTURE) {
				
				currentCount = (PowerUpController.totals["crystal"] - PowerUpController.counts["crystal"]);
				total = PowerUpController.totals["crystal"];
				
			}
			
			if (_game.currentLevel.gameObjective.type != GameObjective.TYPE_ESCAPE) {
				
				_gameStats["stats"].text = currentCount + " OF " + total;
			
			} else {
				
				_gameStats["stats"].text = "";
				
			}
			
			if (!_winEventSent && _game.currentLevel.levelNum == Game.totalLevels) {
				if (currentCount / total >= 0.8) {
					Game.sendEvent(5);
					_winEventSent = true;
				}
			}
			
		}
		
		protected function initLives ():void {
			
			for (var i:int = 1; i <= 4; i++) _playerLives["life" + i].gotoAndStop(1);
			_displayedLives = 0;
			
		}
		
		protected function updateLives ():void {
			
			if (GameLevel.player) {
				
				var life:MovieClip;
				
				if (_displayedLives != GameLevel.lives) {
					
					for (var i:int = 1; i <= 4; i++) {
						
						life = _playerLives["life" + i];
						
						if (i == GameLevel.lives) {
							
							if (i > _displayedLives) {
								life.gotoAndPlay("new");
							} else {
								life.gotoAndStop("full");
							}
							
						} else if (i > GameLevel.lives) {
							
							if (i == _displayedLives) {
								life.gotoAndPlay("done");
							} else {
								life.gotoAndStop("idle");
							}
							
						} else if (i < GameLevel.lives) {
							
							life.gotoAndStop("full");
							
						}
						
					}
					
					_displayedLives = GameLevel.lives;
					
				} else {
					
					life = _playerLives["life" + _displayedLives];
						
					if (GameLevel.player.health > 0 && GameLevel.player.health / GameLevel.player.maxHealth < 0.5) {
						life.gotoAndStop("half");
					} else {
						life.gotoAndStop("full");
					}					
					
				}
				
			} else {
				
				initLives();
				
			}
			
		}
		
		//
		//
		public function showTitleScreen ():void {
			
			if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.reset();
			
			_titleShowing = true;
			
			if (_titleScreen) {
				
				_titleScreen.visible = true;
				_titleScreen.gotoAndPlay(1);
				
			} else {
				
				_titleScreen = _game.uiLibrary.getDisplayObject("titledialogue") as MovieClip;
				_titleScreen.mouseEnabled = true;
				_titleScreen.mouseChildren = true;
				_titleScreen.x = Math.floor(_width * 0.5 - _titleScreen.width * 0.5) + 10;
				_titleScreen.y = Math.floor(_height * 0.75 - _titleScreen.height * 0.5);
				_container.addChild(_titleScreen);
				
				initTitleScreen();
				
				if (GameLevel.gameEngine && 
					GameLevel.gameEngine.view && 
					GameLevel.gameEngine.view.background) {
					GameLevel.gameEngine.view.background.update();
				}
				
			}
			
		}
		
		//
		//
		public function hideTitleScreen ():void {
			
			_titleShowing = false;
			
			if (_titleScreen) {
				_titleScreen.visible = false;
				_titleScreen.gotoAndStop(1);
				if (_titleScreen.parent) _titleScreen.parent.removeChild(_titleScreen);
			}
			
		}
		
		//
		//
		protected function initTitleScreen ():void {
			
			if (_titleScreen == null) return;
			
			for each (var lbl:FrameLabel in _titleScreen.currentLabels) _titleScreen.addFrameScript(lbl.frame - 1, onTitleScreenLabel);
			
		}
		
		//
		//
		protected function onTitleScreenLabel ():void {
			
			if (_titleScreen == null) return;
			
			var labelName:String = _titleScreen.currentLabel;
			
			switch (labelName) {
				
				case "getTitle":
					_titleScreen.game_title.text = Game.title;
					break;
					
				case "getAuthor":
					_titleScreen.game_author.text = Game.author.toUpperCase();
					break;
					
				case "getDifficulty":
					_titleScreen.game_difficulty.gotoAndStop(Game.difficulty + 2);
					break;
					
				case "getMission":
					if (_game && _game.currentLevel && _game.currentLevel.gameObjective) {
						if (_game.currentLevel.gameObjective.type == GameObjective.TYPE_MELEE) MovieClip(_titleScreen.game_mission).gotoAndStop(2);
						if (_game.currentLevel.gameObjective.type == GameObjective.TYPE_CAPTURE) MovieClip(_titleScreen.game_mission).gotoAndStop(3);
						if (_game.currentLevel.gameObjective.type == GameObjective.TYPE_ESCAPE) MovieClip(_titleScreen.game_mission).gotoAndStop(4);
					}
					break;
					
				case "getPlayAction":
					SimpleButton(_titleScreen.game_play).addEventListener(MouseEvent.MOUSE_UP, onPlayButtonClicked, false, 0, true);
					_titleScreen.stop();
					break;
					
				case "end":

					_container.removeChild(_titleScreen);
					_titleScreen.stop();
					_titleScreen = null;
					break;
				
			}

		}
		
		protected function pauseGame ():void {
			
			_paused = true;
			
			try {
				if (!Game.ended && Game.gameInstance.currentLevel.fuz2d.playfield.playing) {
					Game.gameInstance.currentLevel.fuz2d.playfield.pauseToggle();
					if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.pause();
					showPauseScreen();
				}
			} catch (e:Error) {
				trace("GameConsole pauseGame:", e);
			}
			
		}
		
		protected function resumeGame ():void {
			
			_paused = false;
			
			try {
				if (!Game.ended && !Game.gameInstance.currentLevel.fuz2d.playfield.playing) {
					Game.gameInstance.currentLevel.fuz2d.playfield.pauseToggle();
					if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.resume();
					hidePauseScreen();
				}
			} catch (e:Error) {
				trace("GameConsole resumeGame:", e);
			}
			
			Main.mainStage.focus = Main.mainStage;
			
		}
		
		//
		//
		protected function onHelpButtonClicked (e:MouseEvent):void {
			
			pauseGame();
			hideTitleScreen();
			showHelpScreen();
			
		}
		
		//
		//
		protected function onPlayButtonClicked (e:MouseEvent):void {
			
			SimpleButton(_titleScreen.game_play).removeEventListener(MouseEvent.MOUSE_UP, onPlayButtonClicked);
			
			if (firstPlay) {
				firstPlay = false;
				Game.startTime = TimeStep.stepTime;
			}
			
			_titleShowing = false;
			_titleScreen.play();
			_game.currentLevel.start();
			Game.sendEvent(1);
			radar.showIntro();
			
			if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.resume();
			
		}
		
		//
		//
		protected function onKeyDown (e:KeyboardEvent):void {
			
			if (e.keyCode == 80) {
				if (!_titleShowing) {
					if (_paused) {
						hidePauseScreen();
						resumeGame();
					}
					else {
						pauseGame();
						showPauseScreen();
					}
				}
			}
		}
		
		/**
		 * Shows the task notice
		 * @param	frame "complete" or "unlocked" depending on whether door exists on level
		 */
		public function showTaskNotice (frame:String):void {
			
			_taskNotice.gotoAndStop(frame);
			_taskNotice.visible = true;
			_taskNoticeTimer = new Timer (3000, 1);
			_taskNoticeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTaskNoticeDone);
			_taskNoticeTimer.start();
			
		}
		
		public function onTaskNoticeDone (e:TimerEvent = null):void {
			
			if (_taskNoticeTimer) {
				_taskNoticeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTaskNoticeDone);
				_taskNoticeTimer.stop();
				_taskNoticeTimer = null;
			}
			
			_taskNotice.visible = false;
			
		}
		
		//
		//
		public function showEndScreen ():void {
			
			if (_endScreen == null) _endScreen = _game.uiLibrary.getDisplayObject("enddialogue") as MovieClip;
			
			if (_endScreen != null) {
				
				_endScreen.mouseEnabled = true;
				_endScreen.mouseChildren = true;
				_endScreen.x = Math.floor(_width * 0.5 - _endScreen.width * 0.5);
				_endScreen.y = Math.floor(_height * 0.5 - _endScreen.height * 0.5);
				_container.addChild(_endScreen);
				
				initEndScreen();
				
			}
			
		}
		
		//
		//
		public function removeEndScreen ():void {
			
			if (_endScreen != null && _container.getChildIndex(_endScreen) != -1) _container.removeChild(_endScreen);
			
		}
		
		//
		//
		protected function initEndScreen ():void {
			
			for each (var lbl:FrameLabel in _endScreen.currentLabels) _endScreen.addFrameScript(lbl.frame - 1, onEndScreenLabel);
			
		}
		
		//
		//
		protected function onEndScreenLabel ():void {
			
			var btn:SimpleButton;
			
			if (_endScreen == null) return;
			
			var labelName:String = _endScreen.currentLabel;
			
			switch (labelName) {
				
				case "setResult":
					if (Game.wonGame) _endScreen["result"].gotoAndPlay(30);
					break;
					
				case "checkSubmission":
					if (Game.gameResultSubmitted) _endScreen.play();
					else _endScreen.gotoAndPlay(75);
					break;
					
				case "showGameTime":
					if (_endScreen["game_time"] != null) setGameTime(_endScreen["game_time"]);
					break;
					
				case "showGameResult":
					if (_endScreen["game_result"] != null) {
						if (Game.wonGame) {
							_endScreen["game_result"].gotoAndStop(3);
						} else {
							_endScreen["game_result"].gotoAndStop(2);
						}
					}
					
				case "showAuthor":
					if (_endScreen["game_author"] != null) setGameAuthor(_endScreen["game_author"]);
					if (_endScreen["author_button"] != null) {
						btn = _endScreen["author_button"];
						btn.addEventListener(MouseEvent.CLICK, onAuthorNameClicked, false, 0, true);
					}
					break;
					
				case "showLeaderboard":
					// leaderboard
					_leaderboard = new Leaderboard(_endScreen["leaderboard"]);
					break;
					
				case "voteWidget":
					if (_endScreen["vote_widget"] != null) {
						_voteWidget = new VoteWidget(_endScreen["vote_widget"]);
					}
					break;
					
				case "buildComplete":

					if (_endScreen["replay_game_button"] != null) {
						btn = _endScreen["replay_game_button"];
						btn.addEventListener(MouseEvent.CLICK, onReplayButtonClicked, false, 0, true);
					}
					if (_endScreen["play_more_games_button"] != null) {
						btn = _endScreen["play_more_games_button"];
						btn.addEventListener(MouseEvent.CLICK, onPlayMoreGamesButtonClicked, false, 0, true);
					}
					
					_endScreen.stop();
					
					break;
				
			}

		}
		
        //
        //
        public function setGameTime (field:TextField):void {

			var gameTime:int = Math.floor(Game.endTime / 1000);
    
            if (gameTime > 0) {
                
                if (gameTime >= 60) {
                    field.text = Math.floor(gameTime / 60) + ":";
                } else {
                    field.text = "0:";
                }
                
                if (gameTime % 60 == 0) {
                    field.appendText("00");
                } else if (gameTime % 60 < 10) {
                    field.appendText("0" + (gameTime % 60));
                } else {
                    field.appendText("" + gameTime % 60);
                }
                
            } else {
                
                field.text = "-:--";
                
            }
            
        }
		
		protected function updateSoundStatus ():void {
			
			if (_soundStatusTF == null ) return;
			
			if (_musicTrack != "") {
				var tag:Array = _musicTrack.split("/");
				var c_title:String = String(tag[1]).split("?")[0];
				c_title = StringUtils.titleCase(unescape(c_title).split(".mod").join("").split("-").join(" "));
				_soundStatusTF.htmlText = c_title + ' - ' + '<font color="#ffec00"><a href="http://www.sploder.com/music/author_redirect.php?author=' + tag[0] + '" target="_blank">' + tag[0] + ' ¬</a></font>';
				_soundStatusTF.visible = true;
				_soundStatusTF.mouseEnabled = true;
				_musicIcon.visible = true;
			} else {
				_soundStatusTF.text = "";
				_soundStatusTF.visible = false;
				_musicIcon.visible = false;
			}
			
		}
		
        //
        //
        public function setGameAuthor (field:TextField, showArrow:Boolean = true):void {
            
            var arrow:String = "";
            
            if (showArrow) {
                arrow = unescape('%20%AC%AC');
            }
            
            field.htmlText = '<a href="http://www.sploder.com/games/members/' + Game.author.toLowerCase() + '/">' + Game.author.toUpperCase() + arrow + '</a>';
    
        }
		
		//
		//
		public function onAuthorNameClicked (e:MouseEvent):void {
			
			var request:URLRequest = new URLRequest("http://www.sploder.com/games/members/" + Game.author.toLowerCase() + "/");
			
			try {
				navigateToURL(request, "_blank");
			} catch (e:Error) {
				trace("GameConsole onAuthorNameClicked:", e);
			}
			
		}
		
		//
		//
		public function onHelpResume (e:MouseEvent):void {
			
			hideHelpScreen();
			hideTitleScreen();
			resumeGame();
			
		}
		
		//
		//
		public function onReplayButtonClicked (e:MouseEvent):void {
			
			if (PlayTimeCounter.mainInstance != null) {
				PlayTimeCounter.mainInstance.reset();
			}
			Game.restartGame();
			
		}
		
		//
		//
		public function onPlayMoreGamesButtonClicked (e:MouseEvent):void {
			
			if (_endScreen["play_more_games_button"] != null) {
				
				var btn:SimpleButton = _endScreen["play_more_games_button"];
				btn.removeEventListener(MouseEvent.CLICK, onPlayMoreGamesButtonClicked);
				
				loadLinks();
				
			}
			
		}
		
		//
		//
		protected function loadLinks():void {
			
			var linksSWFURL:String;
			if (Main.dataLoader.baseURL.indexOf("http://sploder.home") == -1 && Main.dataLoader.baseURL.indexOf("192.168.") == -1 && Main.dataLoader.embedParameters.onsplodercom == undefined) {
				linksSWFURL = "http://www.sploder.com/gamelinks.swf";
			} else {
				linksSWFURL = "gamelinks.swf";
			}
			
			var myLoader:Loader = new Loader();
			_container.addChild(myLoader); 
			var url:URLRequest = new URLRequest(linksSWFURL); 
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLinksLoaded);
			myLoader.load(url);
		
		}
		
		//
		//
		protected function onLinksLoaded (e:Event):void {
			
			removeEndScreen();
			
		}
		
		//
		//
		protected function onSoundToggleButtonClicked (e:MouseEvent):void {
			
			SoundManager.hasSound = !SoundManager.hasSound;
			
			if (SoundManager.hasSound) _soundToggle.gotoAndStop(1);
			else _soundToggle.gotoAndStop(2);
			
			try {
				if (SoundManager.hasSound && _game.currentLevel.levelNode.attributes.music != "") {
					Fuz2d.sounds.pauseSong();
					Fuz2d.sounds.resumeSong();
				}
			} catch (e:Error) {
				trace("GameConsole onSoundToggleButtonClicked:", e);
			}
			
		}
		
		//
		//
		public function end ():void {
			
			if (radar) radar.end();
			if (_clip && _container) _container.removeChild(_clip);
			
		    if (_container && _container.stage) {
				_container.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				_container.stage.removeEventListener(Event.ENTER_FRAME, updatePlayTime);
			}
			
			unregisterPlayer();
			unregisterPlayfield();
			
			_container = null;
			_clip = null;
			_voteWidget = null;
			_leaderboard = null;
			
		}
		
	}
	
}