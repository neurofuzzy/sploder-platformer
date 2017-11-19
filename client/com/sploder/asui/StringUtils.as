package com.sploder.asui
{
	
	import flash.utils.Dictionary;
	import flash.xml.XMLDocument;
    import flash.xml.XMLNode;
    import flash.xml.XMLNodeType;
	
	/**
	 * ...
	 * @author ...
	 */
	public class StringUtils {
		
		public static const HTML_SPECIALCHARS:uint = 0;
		public static const HTML_ENTITIES:uint = 1;
		public static const ENT_NOQUOTES:uint = 2;
		public static const ENT_COMPAT:uint = 3;
		public static const ENT_QUOTES:uint = 4;
	
		public static var monthNames:Array = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
		public static var monthShortNames:Array = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
		public static var dayNames:Array = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
			
        // 
        // 
        // PRETTYDATESTRING formats a date into display format and returns it
        public static function prettydatestring(theDate:Date):String {
            
            return dayNames[theDate.getDay()] + ", " + monthNames[theDate.getMonth()] + " " + theDate.getDate() + ", " + theDate.getFullYear();

        }
        
        
        // 
        // 
        // CGIDATESTRING formats a date into CGI encoded format and returns it
        public static function cgidatestring(theDate:Date):String {
            
            var theDay:String = "" + theDate.getDate();
            
            if (theDate.getDate() < 10) {
                theDay = "0" + theDay;
            }
            
            var theMonth:String = "" + theDate.getMonth() + 1;
   
            if ((theDate.getMonth() + 1) < 10) {
                theMonth = "0" + theMonth;
            }
            
            var theYear:String = "" + theDate.getFullYear();
            
            return theMonth + "." + theDay + "." + theYear;
            
        }
		
		//
		//
		public static function removeHTML(source:String) : String
        {
            var pattern:RegExp = /<[^>]*>/g;
            return source.replace(pattern, "");
			
        }
		
		//
		//
		public static function clean(source:String) : String
        {
			source = decomposeUnicode(source);
			source = source.toLowerCase().split(" ").join("_");
            var pattern:RegExp = /[^a-z0-9_]/g;
            return source.replace(pattern, "").split("__").join("_");
			
        }
		
/**
         * Helper arrays for unicode decomposition
         */
        private static var pattern:Array = new Array(29);
        pattern[0] = new RegExp("Š", "g");
        pattern[1] = new RegExp("Œ", "g");
        pattern[2] = new RegExp("Ž", "g");
        pattern[3] = new RegExp("š", "g");
        pattern[4] = new RegExp("œ", "g");
        pattern[5] = new RegExp("ž", "g");
        pattern[6] = new RegExp("[ÀÁÂÃÄÅ]","g");
        pattern[7] = new RegExp("Æ","g");
        pattern[8] = new RegExp("Ç","g");
        pattern[9] = new RegExp("[ÈÉÊË]","g");
        pattern[10] = new RegExp("[ÌÍÎÏ]", "g");
        pattern[11] = new RegExp("Ð", "g");
        pattern[12] = new RegExp("Ñ","g");
        pattern[13] = new RegExp("[ÒÓÔÕÖØ]","g");
        pattern[14] = new RegExp("[ÙÚÛÜ]","g");
        pattern[15] = new RegExp("[ŸÝ]", "g");
        pattern[16] = new RegExp("Þ", "g");
        pattern[17] = new RegExp("ß", "g");
        pattern[18] = new RegExp("[àáâãäå]","g");               
        pattern[19] = new RegExp("æ","g");
        pattern[20] = new RegExp("ç","g");
        pattern[21] = new RegExp("[èéêë]","g");
        pattern[22] = new RegExp("[ìíîï]","g");
        pattern[23] = new RegExp("ð", "g");
        pattern[24] = new RegExp("ñ","g");
        pattern[25] = new RegExp("[òóôõöø]","g");
        pattern[26] = new RegExp("[ùúûü]","g");
        pattern[27] = new RegExp("[ýÿ]","g");
        pattern[28] = new RegExp("þ", "g");

        private static var patternReplace:Array = [
                "S",
                "Oe",
                "Z",
                "s",
                "oe",
                "z",
                "A",
                "Ae",
                "C",
                "E",
                "I",
                "D",
                "N",
                "O",
                "U",
                "Y",
                "Th",
                "ss",
                "a",
                "ae",
                "c",
                "e",
                "i",
                "d",
                "n",
                "o",
                "u",
                "y",
                "th"];

        /**
         * Returns the Unicode decomposition of a given run of accented text. 
         * @param value The original string
         * @return The string without accents
         */             
        public static function decomposeUnicode(str:String):String
        {
                for (var i:int = 0; i < pattern.length; i++)
                {
                        str = str.replace(pattern[i], patternReplace[i]);
                }
                return str;
        }

			
		//
		private static function get_html_translation_table (table:uint = HTML_SPECIALCHARS, quote_style:uint = ENT_COMPAT):Dictionary {
			// Returns the internal translation table used by htmlspecialchars and htmlentities  
			// 
			// version: 909.322
			// discuss at: http://phpjs.org/functions/get_html_translation_table
			// +   original by: Philip Peterson
			// +    revised by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
			// +   bugfixed by: noname
			// +   bugfixed by: Alex
			// +   bugfixed by: Marco
			// +   bugfixed by: madipta
			// +   improved by: KELAN
			// +   improved by: Brett Zamir (http://brett-zamir.me)
			// +   bugfixed by: Brett Zamir (http://brett-zamir.me)
			// +      input by: Frank Forte
			// +   bugfixed by: T.Wild
			// +      input by: Ratheous
			// %          note: It has been decided that we're not going to add global
			// %          note: dependencies to php.js, meaning the constants are not
			// %          note: real constants, but strings instead. Integers are also supported if someone
			// %          note: chooses to create the constants themselves.
			// *     example 1: get_html_translation_table('HTML_SPECIALCHARS');
			// *     returns 1: {'"': '&quot;', '&': '&amp;', '<': '&lt;', '>': '&gt;'}
			
			var entities:Object = { };
			var hash_map:Dictionary = new Dictionary();
			var decimal:int = 0;
			var symbol:String = '';
			var useTable:uint = table;
			var useQuoteStyle:uint = quote_style;
			
			if (useTable !== HTML_SPECIALCHARS && useTable !== HTML_ENTITIES) {
				throw new Error("Table: "+useTable+' not supported');
				// return false;
			}

			//entities['38'] = '&amp;';
			if (useTable == HTML_ENTITIES) {
				entities['160'] = '&nbsp;';
				entities['161'] = '&iexcl;';
				entities['162'] = '&cent;';
				entities['163'] = '&pound;';
				entities['164'] = '&curren;';
				entities['165'] = '&yen;';
				entities['166'] = '&brvbar;';
				entities['167'] = '&sect;';
				entities['168'] = '&uml;';
				entities['169'] = '&copy;';
				entities['170'] = '&ordf;';
				entities['171'] = '&laquo;';
				entities['172'] = '&not;';
				entities['173'] = '&shy;';
				entities['174'] = '&reg;';
				entities['175'] = '&macr;';
				entities['176'] = '&deg;';
				entities['177'] = '&plusmn;';
				entities['178'] = '&sup2;';
				entities['179'] = '&sup3;';
				entities['180'] = '&acute;';
				entities['181'] = '&micro;';
				entities['182'] = '&para;';
				entities['183'] = '&middot;';
				entities['184'] = '&cedil;';
				entities['185'] = '&sup1;';
				entities['186'] = '&ordm;';
				entities['187'] = '&raquo;';
				entities['188'] = '&frac14;';
				entities['189'] = '&frac12;';
				entities['190'] = '&frac34;';
				entities['191'] = '&iquest;';
				entities['192'] = '&Agrave;';
				entities['193'] = '&Aacute;';
				entities['194'] = '&Acirc;';
				entities['195'] = '&Atilde;';
				entities['196'] = '&Auml;';
				entities['197'] = '&Aring;';
				entities['198'] = '&AElig;';
				entities['199'] = '&Ccedil;';
				entities['200'] = '&Egrave;';
				entities['201'] = '&Eacute;';
				entities['202'] = '&Ecirc;';
				entities['203'] = '&Euml;';
				entities['204'] = '&Igrave;';
				entities['205'] = '&Iacute;';
				entities['206'] = '&Icirc;';
				entities['207'] = '&Iuml;';
				entities['208'] = '&ETH;';
				entities['209'] = '&Ntilde;';
				entities['210'] = '&Ograve;';
				entities['211'] = '&Oacute;';
				entities['212'] = '&Ocirc;';
				entities['213'] = '&Otilde;';
				entities['214'] = '&Ouml;';
				entities['215'] = '&times;';
				entities['216'] = '&Oslash;';
				entities['217'] = '&Ugrave;';
				entities['218'] = '&Uacute;';
				entities['219'] = '&Ucirc;';
				entities['220'] = '&Uuml;';
				entities['221'] = '&Yacute;';
				entities['222'] = '&THORN;';
				entities['223'] = '&szlig;';
				entities['224'] = '&agrave;';
				entities['225'] = '&aacute;';
				entities['226'] = '&acirc;';
				entities['227'] = '&atilde;';
				entities['228'] = '&auml;';
				entities['229'] = '&aring;';
				entities['230'] = '&aelig;';
				entities['231'] = '&ccedil;';
				entities['232'] = '&egrave;';
				entities['233'] = '&eacute;';
				entities['234'] = '&ecirc;';
				entities['235'] = '&euml;';
				entities['236'] = '&igrave;';
				entities['237'] = '&iacute;';
				entities['238'] = '&icirc;';
				entities['239'] = '&iuml;';
				entities['240'] = '&eth;';
				entities['241'] = '&ntilde;';
				entities['242'] = '&ograve;';
				entities['243'] = '&oacute;';
				entities['244'] = '&ocirc;';
				entities['245'] = '&otilde;';
				entities['246'] = '&ouml;';
				entities['247'] = '&divide;';
				entities['248'] = '&oslash;';
				entities['249'] = '&ugrave;';
				entities['250'] = '&uacute;';
				entities['251'] = '&ucirc;';
				entities['252'] = '&uuml;';
				entities['253'] = '&yacute;';
				entities['254'] = '&thorn;';
				entities['255'] = '&yuml;';
			}

			if (useQuoteStyle !== ENT_NOQUOTES) {
				entities['34'] = '&quot;';
			}
			if (useQuoteStyle == ENT_QUOTES) {
				entities['39'] = '&#39;';
			}
			entities['60'] = '&lt;';
			entities['62'] = '&gt;';


			// ascii decimals to real symbols
			for (var dec:String in entities) {
				symbol = String.fromCharCode(parseInt(dec));
				hash_map[symbol] = entities[dec];
				
			}
			
			return hash_map;
		}

		/**
		 * Convert all HTML entities to their applicable characters
		 * @param	string
		 * @param	quote_style
		 * @return
		 */
		public static function html_entity_decode (string:String, quote_style:uint = ENT_COMPAT):String {
			// Convert all HTML entities to their applicable characters  
			// 
			// version: 909.322
			// discuss at: http://phpjs.org/functions/html_entity_decode
			// +   original by: john (http://www.jd-tech.net)
			// +      input by: ger
			// +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
			// +    revised by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
			// +   bugfixed by: Onno Marsman
			// +   improved by: marc andreu
			// +    revised by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
			// +    bugfixed by: Brett Zamir (http://brett-zamir.me)
			// +      input by: Ratheous
			// -    depends on: get_html_translation_table
			// *     example 1: html_entity_decode('Kevin &amp; van Zonneveld');
			// *     returns 1: 'Kevin & van Zonneveld'
			// *     example 2: html_entity_decode('&amp;lt;');
			// *     returns 2: '&lt;'
			var hash_map:Dictionary;
			var symbol:String = '';
			var tmp_str:String = '';
			var entity:String = '';
			tmp_str = string.toString();
			
			hash_map = get_html_translation_table(HTML_ENTITIES, quote_style);
			if (hash_map == null) return "";

			for (symbol in hash_map) {
				entity = hash_map[symbol];
				tmp_str = tmp_str.split(entity).join(symbol);
			}
			tmp_str = tmp_str.split('&#039;').join("'");
			
			return tmp_str;
		}

		/**
		 * Convert all applicable characters to HTML entities
		 * @param	string
		 * @param	quote_style
		 * @return
		 */
		public static function htmlentities (string:String, quote_style:uint = ENT_COMPAT):String {
			// Convert all applicable characters to HTML entities  
			// 
			// version: 909.322
			// discuss at: http://phpjs.org/functions/htmlentities
			// +   original by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
			// +    revised by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
			// +   improved by: nobbler
			// +    tweaked by: Jack
			// +   bugfixed by: Onno Marsman
			// +    revised by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
			// +    bugfixed by: Brett Zamir (http://brett-zamir.me)
			// +      input by: Ratheous
			// -    depends on: get_html_translation_table
			// *     example 1: htmlentities('Kevin & van Zonneveld');
			// *     returns 1: 'Kevin &amp; van Zonneveld'
			// *     example 2: htmlentities("foo'bar","ENT_QUOTES");
			// *     returns 2: 'foo&#039;bar'
			var hash_map:Dictionary;
			var symbol:String = '';
			var tmp_str:String = '';
			var entity:String = '';
			tmp_str = string.toString();
			tmp_str = tmp_str.split("&").join("&amp;");
			
			hash_map = get_html_translation_table(HTML_ENTITIES, quote_style);
			if (hash_map == null) return "";
			
			hash_map["'"] = '&#039;';

			for (symbol in hash_map) {
				entity = hash_map[symbol];
				tmp_str = tmp_str.split(symbol).join(entity);
			}
			
			return tmp_str;
		}

		/**
		 * Convert special characters to HTML entities
		 * @param	string
		 * @param	quote_style
		 * @return
		 */
		public static function htmlspecialchars (string:String, quote_style:uint = ENT_COMPAT):String {
			// Convert special characters to HTML entities  
			// 
			// version: 909.322
			// discuss at: http://phpjs.org/functions/htmlspecialchars
			// +   original by: Mirek Slugen
			// +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
			// +   bugfixed by: Nathan
			// +   bugfixed by: Arno
			// +    revised by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
			// +    bugfixed by: Brett Zamir (http://brett-zamir.me)
			// +      input by: Ratheous
			// -    depends on: get_html_translation_table
			// *     example 1: htmlspecialchars("<a href='test'>Test</a>", 'ENT_QUOTES');
			// *     returns 1: '&lt;a href=&#039;test&#039;&gt;Test&lt;/a&gt;'
			var hash_map:Dictionary;
			var symbol:String = '';
			var tmp_str:String = '';
			var entity:String = '';
			tmp_str = string.toString();
			tmp_str = tmp_str.split("&").join("&amp;");
			
			hash_map = get_html_translation_table(HTML_SPECIALCHARS, quote_style);
			if (hash_map == null) return "";

			hash_map["'"] = '&#039;';
			for (symbol in hash_map) {
				entity = hash_map[symbol];
				tmp_str = tmp_str.split(symbol).join(entity);
			}
			
			return tmp_str;
		}

		/**
		 * Convert special HTML entities back to characters
		 * @param	string
		 * @param	quote_style
		 * @return
		 */
		public static function htmlspecialchars_decode (string:String, quote_style:uint = ENT_COMPAT):String {
			// Convert special HTML entities back to characters  
			// 
			// version: 909.322
			// discuss at: http://phpjs.org/functions/htmlspecialchars_decode
			// +   original by: Mirek Slugen
			// +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
			// +   bugfixed by: Mateusz "loonquawl" Zalega
			// +      input by: ReverseSyntax
			// +      input by: Slawomir Kaniecki
			// +      input by: Scott Cariss
			// +      input by: Francois
			// +   bugfixed by: Onno Marsman
			// +    revised by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
			// +   bugfixed by: Brett Zamir (http://brett-zamir.me)
			// +      input by: Ratheous
			// -    depends on: get_html_translation_table
			// *     example 1: htmlspecialchars_decode("<p>this -&gt; &quot;</p>", 'ENT_NOQUOTES');
			// *     returns 1: '<p>this -> &quot;</p>'
			// *     example 2: htmlspecialchars_decode("&amp;quot;");
			// *     returns 2: '&quot;'
			var hash_map:Dictionary;
			var symbol:String = '';
			var tmp_str:String = '';
			var entity:String = '';
			
			tmp_str = string.toString();
			
			hash_map = get_html_translation_table(HTML_SPECIALCHARS, quote_style);
			if (hash_map == null) return "";

			for (symbol in hash_map) {
				entity  = hash_map[symbol];
				tmp_str = tmp_str.split(entity).join(symbol);
			}
			tmp_str = tmp_str.split('&#039;').join("'");
			
			return tmp_str;
			
		}

		
	}
	
}