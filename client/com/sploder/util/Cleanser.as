package com.sploder.util {
	
    /**
    * ...
    * @author Default
    * @version 0.1
    */
    
    public class Cleanser {

    
        public static function cleanse (text:String):String {
    
            var censor_words:Array = [" ass ", "lesbian", "shit", "nigger", "f.u.c.k", "s.h.i.t", "s*h*i*t", "b.i.t.c.h", "b-i-t-c-h", "s-h-i-t", "f-u-c-k", "f*u*c*k", "f u c k", "c.o.c.k", "c o c k", "s h i t", "c u n t", "b i t c h", "w h o r e", "p u s s y", "f-u-c-k", "penis", "pussy ", "bullshit", "whore", " piss ", " pissing", " pee ", " peeing ", "tranny", "blow job", "transexual", "bitch", " shit ", "bestiality", "fucking", "fucker", "jackoff", "dickhead", "dickless", "masturbation", "masturbate", "fuck", "cocksucker", "cocksucking", " cock ", "hentai", "bastard", "shithead", "shitface", "shitty", "shiteating", "blowjob", "horny", "cunt", "clitoris", "clit", "asshole", "incest", "foreskin", "faggot", "cock"];
			
			if (text == null) return "";
			
            text = text.split("-").join("").split("_").join("").split("*").join("").split("^").join("").split("~").join("");
            
            var lowercase_text:String = text.toLowerCase();
            var times:Number;
            var censor_word:String;
            
            var start_marker:Number;
            var end_marker:Number;
            var start_padding:String;
            var end_padding:String;
            var text_a:String;
            var text_b:String;
            
            for (var i:Number = 0; i < censor_words.length; i++) {
    
                times = 0;
                
                while (lowercase_text.indexOf(censor_words[i]) !== -1) {
                
                    censor_word = censor_words[i];
                    
                    start_marker = lowercase_text.indexOf(censor_word);
                    end_marker = start_marker + censor_word.length;
                    
                    text_a = text.substr(0, start_marker);
                    text_b = text.substr(end_marker, text.length - 1);
                    
                    start_padding = "";
                    end_padding = "";
                    
                    if (censor_word.charAt(0) == " ") {
                        start_padding = " ";
                    }
                    
                    if (censor_word.charAt(censor_word.length - 1) == " ") {
                        end_padding = " ";
                    }
                    
                    text = text_a + start_padding + "BLEEP" + end_padding + text_b;
                    lowercase_text = text.toLowerCase();
                    
                    times++;
                    
                    if (times > 1000) {
                        break;
                    }
                    
                    
                }
                
            }
    
            return text;
            
        }
        
    }
}
