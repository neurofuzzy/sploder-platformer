package com.sploder {

	import com.sploder.data.User;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	import fuz2d.Fuz2d;

    public class Leaderboard {

        public var baseURL:String;
        public var boardURL:String;
    
        public var boardXML:XML;
        public var loadInterval:Number;
        
        public var prev_src:String;
        
        public var rcvXML:XML;
        
        public var destY:Number;
        
        public var scores:Array;
        
        public var container:Sprite;
        
    
        //
        //
        public function Leaderboard (container:Sprite) {
            
            super();
			
			this.container = container;
            
            if (User.projectpath != null) {
                
                init(User.projectpath + "leaderboard.xml");
                
            }    
            
        }
        
        //
        //
        private function init (boardURL:String):void {

            this.boardURL = boardURL;
    
            boardXML = new XML();
            
            loadBoard();
    
        }
        
        //
        //
        public function loadBoard ():void {
 
			var base:String = Main.dataLoader.baseURL;
			if (base.indexOf("amazon") != -1 || base.length < 5) base = "http://www.sploder.com";
				
			Main.dataLoader.loadXMLData(base + "/php/getleaderboard.php?loc=" + boardURL + "&nocache=" + getTimer() + "_" + Math.floor(Math.random() * 100000), false, onData);

        }
        
        //
        //
        public function onData (e:Event):void {

            var src:String = e.target.data;
			
            if (src != null) {
                        
                if (src != prev_src) {
                    
                    prev_src = src;
                    
                    if (src != "<empty />") {
                        
						boardXML = new XML("<scores>" + src + "</scores>");
                        populate();
                    
                    } else {
                        
						var noscores:Sprite = Fuz2d.library.getDisplayObject("noScoresSymbol") as Sprite;
						container.addChild(noscores);

                    }
                    
                }
                
            }
            
        }
        
    
        
        //
        //
        public function populate ():void {
  
            var scoreMC:Sprite;
			var i:int = 0;
            var height:Number = 0;
    
			
			for each (var score:XML in boardXML..score) {
                
                if (container["score_" + i] == undefined) {
                        
					scoreMC = Fuz2d.library.getDisplayObject("scoreSymbol") as Sprite;
                    container.addChild(scoreMC);
    
                    scoreMC["rank"].text = i + 1;
                    scoreMC["username"].text = score.@username.toUpperCase();
                    scoreMC["score"].text = getTimeString(parseInt(score.@value, 10));
                    
                    scoreMC.y = height + 2;
                    
                    if (i % 2 == 1) {
                        scoreMC.x += scoreMC.width + 6;
                    }        
                    
                    if (i % 2 == 1) {
                        height += 18;
                    }
	
                }
				
				i++;
                
            }    
            
            if (i < 15) {
    
                for (i = i; i < 16; i++) {
                    
                    if (container["score_" + i] == undefined) {
                            
						scoreMC = Fuz2d.library.getDisplayObject("scoreSymbolEmpty") as Sprite;
						container.addChild(scoreMC);

                        scoreMC.y = height + 2;
                        
                        if (i % 2 == 1) {
                            scoreMC.x += scoreMC.width + 6;
                        }        
                        
                        if (i % 2 == 1) {
                            height += 18;
                        }
                        
                    }
                    
                }    
                
            }
            
        }
        
        //
        //
        public function getTimeString (seconds:Number):String {
    
            var timeString:String = "";
            
            if (seconds > 0) {
                
                if (seconds > 60) {
                    timeString = Math.floor(seconds / 60) + ":";
                } else {
                    timeString = "0:";
                }
                
                if (seconds % 60 == 0) {
                    timeString += "00";
                } else if (seconds % 60 < 10) {
                    timeString += "0" + (seconds % 60);
                } else {
                    timeString += "" + seconds % 60;
                }
                
            } else {
                
                timeString = "-:--";
                
            }
            
            return timeString;
            
        }
        
    }

}
