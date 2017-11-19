package com.sploder {
    import com.sploder.util.Cleanser;
    
    public class GameScreens {

    
        public var baseurl:String;
        
        public var gameID:String;
        
        public var gameVars:LoadVars;
        public var resultVars:LoadVars;
        
        public var sendScore:XML;
        public var scoresXML:XML;
        
        public var gameTitle:String = "";
        public var gameAuthor:String = "";
        public var gameDifficulty:Number = 0;
        public var gameRating:Number = 0;
        public var gameType:String = "melee";
        
        public var started:Boolean = false;
        
        public var wonGame:Boolean = false;
        public var gameTime:Number = 0;
        
        //
        //
        public function GameScreens() {
            
            init();
            
        }
        
        //
        //
        private function init ():void {

            
            baseurl = "";
            baseurl = "http://www.sploder.com/";
            // DEV
        
            if (_root._url.indexOf("sploder.com") == -1 && _root._url.indexOf("sploder.amazonaws.com") == -1) {
            
                baseurl = "/";
                
            }
            
            start();
            
        }
        
        //
        //
        public function start ():void {

            
            if (_level0.g != undefined && !started) {
                
                started = true;
                
                gameID = _level0.g;
            
                gameVars = new LoadVars();
    
                gameVars.onLoad = Delegate.create(this, onGameData);
                gameVars.load(baseurl + "php/getgamedata.php?g=" + gameID);
                
                if (_global.game != undefined) {
                    
                    gameTitle = Cleanser.cleanse(unescape(_global.game.gameTitle));
                    gameType = _global.game.gameType;
                    
                }
                
            }
            
        }
        
        //
        //
        public function onGameData (success:Boolean):void {

            
            if (success) {
                
                _root.gotoAndStop(2);
                
                gameAuthor = gameVars.username;
                trace(gameVars.username);
                gameDifficulty = parseInt(gameVars.difficulty);
                gameRating = parseFloat(gameVars.rating);
                
            }
            
        }
        
        //
        //
        public function setGameTime (field:TextField):void {

    
            if (gameTime > 0) {
                
                if (gameTime > 60) {
                    field.text = Math.floor(gameTime / 60) + ":";
                } else {
                    field.text = "0:";
                }
                
                if (gameTime % 60 == 0) {
                    field.text += "00";
                } else if (gameTime % 60 < 10) {
                    field.text += "0" + (gameTime % 60);
                } else {
                    field.text += "" + gameTime % 60;
                }
                
            } else {
                
                field.text = "-:--";
                
            }
            
        }
        
        //
        //
        public function setGameAuthor (field:TextField, showArrow:Boolean):void {

            
            var arrow:String = "";
            
            if (showArrow) {
                arrow = unescape('%20%AC%AC');
            }
            
            field.htmlText = '<a href="http://www.sploder.com/games/members/' + gameAuthor.toLowerCase() + '/">' + gameAuthor.toUpperCase() + arrow + '</a>';
    
        }
        
        //
        //
        public function launchAuthorPage ():void {

            
            getURL("http://www.sploder.com/games/members/" + gameAuthor.toLowerCase() + "/");
            
        }
        
        //
        //
        public function end (won:Boolean, time:Number):void {

            
            wonGame = won;
            gameTime = time;
            
            _root.gotoAndStop(3);
            
        }
        
        //
        //
        public function showLeaderboard (container:MovieClip):void {

            
            
        }
        
        //
        //
        public static function main ():void {

            
            var gd:GameScreens = new GameScreens();
            
            _global.gamedata = gd;
            
        }
    
        
    }
}
