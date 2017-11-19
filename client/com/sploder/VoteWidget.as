package com.sploder {
	
	import com.sploder.data.User;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
    /**
    * ...
    * @author Default
    * @version 0.1
    */
    
    
    public class VoteWidget extends MovieClip {

		protected var _container:MovieClip;
		
        public var _gameID:String;
        public var _sessionID:String;
        public var _loggedIn:Boolean;
        
		protected var voteClip:MovieClip;
		
        public var rating:Number;
        public var voted:Boolean = false;
        public var vote:Number;

		protected var _ratingLoader:URLLoader;
		protected var _ratingRequest:URLRequest;
		protected var _ratingVars:URLVariables;
		
		protected var _voteLoader:URLLoader;
		protected var _voteRequest:URLRequest;
		protected var _voteVars:URLVariables;
        
		//
		//
        public function VoteWidget (container:MovieClip) {

			init(container);
			
        }
        
        //
        //
        protected function init (container:MovieClip):void {
        
			_container = container;
			initFrames();
			
            _gameID = User.m;
            _sessionID = Main.dataLoader.embedParameters.sid;
            
            if (Main.dataLoader.embedParameters.nu == undefined && Main.dataLoader.embedParameters.onsplodercom == "true") {
                _loggedIn = true;
            } else {
                _loggedIn = false;
            }
            
            if (_gameID != null) {
                
                if (!isNaN(Game.rating)) {
                    
					rating = Game.rating;
					
                }
                
            } else {
             
            }
            
        }
        
        //
        //
        public function setButtonActions ():void {

			var activate:SimpleButton = _container["activate"];
			
			if (_gameID != null) {
				
				activate.addEventListener(MouseEvent.CLICK, onActivateButtonClicked);
				
				var currentRating:Sprite = _container["currentrating"];
				showRating(currentRating);
				
			} else {
				
				activate.visible = false;
				
			}
            
        }
		
		//
		//
		protected function onActivateButtonClicked (e:MouseEvent):void {
			
			if (_loggedIn) _container.play();
			else _container.gotoAndPlay(40);
			
		}
		
		//
		//
		protected function initFrames ():void {
			
			for each (var lbl:FrameLabel in _container.currentLabels) _container.addFrameScript(lbl.frame - 1, onLabel);
			
		}
		
		//
		//
		protected function onLabel ():void {
			
			if (_container == null) return;
			
			var labelName:String = _container.currentLabel;
			
			switch (labelName) {
				
				case "init":
					_container.stop();
					setButtonActions();
					break;
					
				case "setVote":
					_container.stop();
					setVoteClip(_container["myvote"]);
					if (voted) showChoice(vote);
					break;
					
				case "done":
					_container.stop();
					dovote(vote);
					break;
					
				case "warningdone":
					_container.gotoAndPlay(4);
					break;

				
			}

		}
        
        //
        //
        public function showRating (currentRating:Sprite):void {
            
            var num:int = Math.floor(rating);

            if (num > 0) {
				
				try {
					
					var i:int;
					
					for (i = 1; i <= num; i++) currentRating["star" + i].gotoAndStop(3);
					
					for (i = num + 1; i <= 5; i++)  currentRating["star" + i].gotoAndStop(1);

					if (rating - num == 0.5) currentRating["star" + (num + 1)].gotoAndStop(2);

					currentRating["toprated"].visible = (num == 5);
				
				} catch (e:Error) {
					
					trace("Rating clip malformed");
					
				}

                
            }
            
        }
        
        //
        //
        public function setRating (success:Boolean):void {
            
            if (success) {
                
               // if (this.currentFrame == 5) {
                   // showRating();
                //}
                
            }
            
        }
        
        //
        //
        public function setVoteClip (clip:MovieClip):void {
			
            voteClip = clip;
			
			var sb:SimpleButton;
			
			for (var i:int = 1; i <= 5; i++) {
				
				sb = voteClip["star" + i + "_button"];
				
				sb.addEventListener(MouseEvent.CLICK, onStarClicked);
				sb.addEventListener(MouseEvent.ROLL_OVER, onStarRollOver);
				sb.addEventListener(MouseEvent.ROLL_OUT, onStarRollOut);
				
			}
            
        }
		
		//
		protected function onStarClicked (e:MouseEvent):void {
			
			var num:int = parseInt(String(e.target.name).split("_")[0].split("star")[1]);
			
			vote = num;
			_container.play();
			
		}
        
		//
		protected function onStarRollOver (e:MouseEvent):void {
			
			var num:int = parseInt(String(e.target.name).split("_")[0].split("star")[1]);
			
			showChoice(num);
			
		}
		
		//
		protected function onStarRollOut (e:MouseEvent):void {
			
			hideChoice();
			
		}
		
        //
        //
        public function showChoice (num:int):void {
            
			var i:int;
			
            if (num < 1 || isNaN(num)) {
                if (vote > 0) {
                    num = vote;
                } else {
                    num = 0;
                }
            }
            
			try {
				
				for (i = 1; i <= num; i++) voteClip["star"+i].gotoAndStop(3);
				
				for (i = num + 1; i <= 5; i++) voteClip["star" + i].gotoAndStop(1);
				
				voteClip.toprated.visible = (num == 5);
			
			} catch (e:Error) {
				
				trace("Vote clip malformed");
				
			}
            
        }
    
        //
        //
        public function hideChoice ():void {
            
            showChoice(vote);
            
        }
    
        //
        //
        public function dovote (num:int):void {
            
            voted = true;
            vote = num;
            rating = vote;
 
            // send vote
            if (_gameID != null) {

				_voteVars = new URLVariables();
				_voteVars.ssid = _gameID;
				_voteVars.score = vote;
				_voteVars.PHPSESSID = _sessionID;
				
				var base:String = Main.dataLoader.baseURL;
				if (base.indexOf("amazon") != -1 || base.length < 5) base = "http://www.sploder.com";
				
				_voteRequest = new URLRequest(base + "/php/vote.php");
				_voteRequest.method = "GET";
				_voteRequest.data = _voteVars;
				
				_voteLoader = new URLLoader();
				_voteLoader.addEventListener(Event.COMPLETE, onVoteRequestSent);
				_voteLoader.load(_voteRequest);
			
			}
            
        }
		
		//
		//
		protected function onVoteRequestSent (e:Event):void {
			
			var loader:URLLoader = URLLoader(e.target);
			var urlVars:String = loader.data;
			
			if (urlVars.charAt(0) == "&") urlVars = urlVars.replace("&", "");
			
			var votedata:URLVariables = new URLVariables();
			votedata.decode(urlVars);
			
			if (votedata.vote_average != null) rating = parseInt(votedata.vote_average);
			
			_container.gotoAndPlay(4);
			
		}
        
    }
}
