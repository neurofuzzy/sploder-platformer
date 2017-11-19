package com.sploder.asui {

	import com.slideroll.util.StringUtils;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import flash.text.StyleSheet;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class ASUIML {
		
		private static var _css:StyleSheet;
		
		private static var _defaultCSSTemplate:String;
		
		//
		//
		public static function setStyles (cssText:String):void {
			
			if (cssText != null) {
				
				_css = new StyleSheet();
				_css.parseCSS(cssText);
				
			}
			
		}
		
		//
		//
		public static function create (obj:ASUIObject, xmlString:String, cssText:String, style:Style = null):void {
			
			var css:StyleSheet;
			var xml:XMLDocument;
			

			if (_defaultCSSTemplate == null) {
				
				_defaultCSSTemplate = ( <![CDATA[
				
				h1 { font-family: "Verdana, Helvetica, Arial"; font-weight: bold; font-size: 18px; color: %titleColor%; leading: 0px; }     
				h2 { font-family: "Verdana, Helvetica, Arial"; font-weight: bold; font-size: 16px; color: %titleColor%; leading: 0px; }       
				h3 { font-family: "Verdana, Helvetica, Arial"; font-weight: bold; font-size: 14px; color: %titleColor%; leading: 0px; }
				h4 { font-family: "Verdana, Helvetica, Arial"; font-weight: bold; font-size: 13px; color: %titleColor%; leading: 0px; }
				p { font-family: "Verdana, Helvetica, Arial"; font-weight: normal; font-size: 12px; color: %textColor%; leading: 2px; }
				a { font-weight: bold; color: %linkColor%; text-decoration: underline; }
				a:hover { font - weight: bold; color: #6699cc; textDecoration: underline; }
			
				]]>).toString();
				
			}
			
			
			if (cssText != null) {

				cssText = _defaultCSSTemplate + "\n" + cssText.split("px").join("");
				
			} else {
				
				cssText = _defaultCSSTemplate;
				
			}
				
			var ttc:String = "#336699";
			var tc:String = "#000000";
			var lc:String = "#003399";
			if (style != null) ttc = ColorTools.numberToHTMLColor(style.titleColor);
			if (style != null) tc = ColorTools.numberToHTMLColor(style.textColor);
			if (style != null) lc = ColorTools.numberToHTMLColor(style.linkColor);
			cssText = cssText.split("%titleColor%").join(ttc);
			cssText = cssText.split("%textColor%").join(tc);
			cssText = cssText.split("%linkColor%").join(lc);
			
			css = new StyleSheet();
			cssText = cssText.split("\n").join(" ");
			cssText = cssText.split("\t").join(" ");
			cssText = cssText.split("\r").join(" ");
			cssText = cssText.split(" ").join("");
			cssText = cssText.split(";").join("; ");
			cssText = cssText.split("}").join("} ");
			
			css.parseCSS(cssText);

			if (xmlString != null) {

				xml = new XMLDocument();
				xml.ignoreWhite = true;

				try {
					
					xml.parseXML(xmlString);
			
					if (css != null) buildNode(obj, obj.root, xml.firstChild, css, style);
					else buildNode(obj, obj.root, xml.firstChild, _css, style);
					
				} catch (error:Error) {
					
					trace("ERROR PARSING XML: [code " + error.getStackTrace() + "]");
					
				}
				
			}
			
		}
		
		
		//
		//
		private static function getCSSClass (xmlNode:XMLNode, css:StyleSheet):Object {
			
			var ss:Object = { };

			if (xmlNode.attributes["class"] != undefined) {
				if (css.getStyle("." + xmlNode.attributes["class"]) != null) {
					ss = css.getStyle("." + xmlNode.attributes["class"]);
				} else {
					trace("CLASS NOT FOUND");
				}
			}

			return ss;
		
		}
		
		
		//
		//
		private static function getBounds (xmlNode:XMLNode, css:StyleSheet):Object {
			
			var w:Number;
			var h:Number;
			var bg:Boolean = false;
			var border:Boolean = false;
			var round:Number = 0;
			var ss:Object = getCSSClass(xmlNode, css);

			if (xmlNode.attributes.width != undefined) w = parseInt(xmlNode.attributes.width);
			else if (ss.width != undefined) w = parseInt(ss.width);
			
			if (xmlNode.attributes.height != undefined) h = parseInt(xmlNode.attributes.height);
			else if (ss.height != undefined) h = parseInt(ss.height);
			
			if (ss.background != undefined || xmlNode.attributes.background != undefined) bg = true;
			if (ss.border != undefined || xmlNode.attributes.border != undefined) border = true;
			if (ss.round != undefined) round = parseInt(ss.round);
			
			return { width: w, height: h, background: bg, border: border, round: round };
			
		}
		
		
		//
		//
		private static function getPosition (xmlNode:XMLNode, css:StyleSheet):Position {
			
			var ss:Object = getCSSClass(xmlNode, css);
			
			var top:Number = 0;
			var left:Number = 0;
			
			var options:Object = { };
			
			var textAlign:Number = (xmlNode.nodeName == "input" && (xmlNode.attributes.type == "button" || xmlNode.attributes.type == "toggle")) ? Position.ALIGN_CENTER : Position.ALIGN_LEFT;
			
			if (ss.textAlign != undefined) {
				if (ss.textAlign == "left") textAlign = Position.ALIGN_LEFT;
				if (ss.textAlign == "center") textAlign = Position.ALIGN_CENTER;
				if (ss.textAlign == "right") textAlign = Position.ALIGN_RIGHT;
			}
			
			if (xmlNode.attributes.align != undefined) {
				if (xmlNode.attributes.align == "left") textAlign = Position.ALIGN_LEFT;
				if (xmlNode.attributes.align == "center") textAlign = Position.ALIGN_CENTER;
				if (xmlNode.attributes.align == "right") textAlign = Position.ALIGN_RIGHT;
			}
			
			var placement:Number = Position.PLACEMENT_NORMAL;
			
			if (ss.position != undefined && ss.position == "absolute") {
				placement = Position.PLACEMENT_ABSOLUTE;
				if (ss.top != undefined) top = parseInt(ss.top);
				if (ss.left != undefined) left = parseInt(ss.left);
			} else if (ss.float != undefined) {
				if (ss.float == "left") placement = Position.PLACEMENT_FLOAT;
				if (ss.float == "right") placement = Position.PLACEMENT_FLOAT_RIGHT;
			}
			
			if (xmlNode.attributes.align != undefined) {
				if (xmlNode.attributes.align == "left") placement = Position.PLACEMENT_FLOAT;
				else if (xmlNode.attributes.align == "right") placement = Position.PLACEMENT_FLOAT_RIGHT;
			}
			
			var clear:Number = (placement == Position.PLACEMENT_NORMAL) ? Position.CLEAR_BOTH : Position.CLEAR_NONE;
			if (ss.clear != undefined) {
				if (ss.clear == "left") clear = Position.CLEAR_LEFT;
				if (ss.clear == "right") clear = Position.CLEAR_RIGHT;
				if (ss.clear == "both") clear = Position.CLEAR_BOTH;
			}
			
			if (ss.overflow != undefined) { options.overflow = ss.overflow; }

			var margins:*;
			if (ss.margins != undefined) margins = (ss.margins.indexOf(" ") != -1) ? ss.margins : parseInt(ss.margins);
			if (!(margins is String) && isNaN(parseInt(margins))) margins = undefined;
			if (ss.marginTop != undefined) options.margin_top = parseInt(ss.marginTop);
			if (ss.marginRight != undefined) options.margin_right = parseInt(ss.marginRight);
			if (ss.marginBottom != undefined) options.margin_bottom = parseInt(ss.marginBottom);
			if (ss.marginLeft != undefined) options.margin_left = parseInt(ss.marginLeft);
			
			var collapse:Boolean = (isNaN(getBounds(xmlNode, css).height));
			
			if (ss.collapse == "true") collapse = true;
			
			if (xmlNode.attributes.style != undefined) {
				
				var sel:Array = String(xmlNode.attributes.style).split(";");
				
				for (var i:int = 0; i < sel.length; i++) {
					
					var prop:Array = sel[i].split(" ").join("").split(":");
					if (prop[0] == "text-align") {
						switch (prop[1]) {
							case "right":
								textAlign = Position.ALIGN_RIGHT;
								break;
							case "left":
								textAlign = Position.ALIGN_LEFT;
								break;
							case "center":
								textAlign = Position.ALIGN_CENTER;
								break;
						}
					}
					try {
						options[prop[0]] = prop[1];
					} catch (e:Error) { }
					
				}
				
			}
			
			return new Position(options, textAlign, placement, clear, margins, top, left, NaN, collapse);

		}
		
		//
		//
		private static function getStyle (xmlNode:XMLNode, css:StyleSheet, html:Boolean, style:Style):Style {
			
			var s:Style;

			if (style != null) s = style.clone();
			else s = new Style();

			var ss:Object = getCSSClass(xmlNode, css);
			
			if (css.getStyle("a").color != undefined) s.linkColor = ColorTools.HTMLColorToNumber(css.getStyle("a").color);
			if (css.getStyle("a:hover").color != undefined) s.hoverColor = ColorTools.HTMLColorToNumber(css.getStyle("a:hover").color);
			if (css.getStyle("p").color != undefined) s.textColor = ColorTools.HTMLColorToNumber(css.getStyle("p").color);
			
			if (xmlNode.attributes.style != undefined) {
				
				var sel:Array = String(xmlNode.attributes.style).split(";");
				
				for (var i:int = 0; i < sel.length; i++) {
					
					var prop:Array = sel[i].split(" ").join("").split(":");
					try {
						s[prop[0]] = prop[1];
					} catch (e:Error) { }
					
				}
				
			}
			
			if (html) s.styleSheet = css;
			else {
				for (var param:String in ss) {
					try { 
						if (s[param] != undefined) {
							if (ss[param] == "true" || ss[param] == "false") {
								s[param] = (ss[param] == "true")
							} else if (param == "font" || param == "titleFont" || param == "buttonFont") {
								if (!((xmlNode.nodeName == "input" || xmlNode.nodeName == "textarea") && (xmlNode.attributes.type == "text" || xmlNode.attributes.type == "password" || xmlNode.attributes.type == undefined))) s[param] = ss[param].split("_").join(" ");
							} else if (s[param] is Number) {
								if (ss[param].indexOf("#") == 0) s[param] = ColorTools.HTMLColorToNumber(ss[param]);
								else s[param] = parseFloat(ss[param]);
							} else {
								s[param] = ss[param];
							}
						}
					} catch (e:Error) {
						
					}
				}
				if (xmlNode.nodeName == "input" && (xmlNode.attributes.type == "button" || xmlNode.attributes.type == "toggle")) {
					if (ss.backgroundColor != undefined) s.buttonColor = ColorTools.HTMLColorToNumber(ss.backgroundColor);
					if (ss.color != undefined) s.textColor =  ColorTools.getInverseColor(ColorTools.HTMLColorToNumber(ss.color));
					if (ss.background == "false") s.background = false;
					if (ss.gradient == "false") s.gradient = false;
				} else {
					if (ss.backgroundColor != undefined) s.backgroundColor = ColorTools.HTMLColorToNumber(ss.backgroundColor);
				if (ss.color != undefined) s.titleColor = s.textColor = ColorTools.HTMLColorToNumber(ss.color);
				}
				if (ss.border == "false") s.border = false;
				if (ss.fontSize != undefined) s.fontSize = parseInt(ss.fontSize);
				if (ss.borderWidth != undefined) s.borderWidth = ss.borderWidth;
				if (ss.borderColor != undefined) s.borderColor = ColorTools.HTMLColorToNumber(ss.borderColor);
				if ((xmlNode.nodeName == "input" || xmlNode.nodeName == "textarea") && (xmlNode.attributes.type == "text" || xmlNode.attributes.type == "password" || xmlNode.attributes.type == undefined)) {
					s.embedFonts = false;
					s.font = Style.DEFAULT_HTML_FONT;
				}
				
			}
			
			return s;
			
		}
		
		//
		//
		private static function checkVisibility (xmlNode:XMLNode, css:StyleSheet):Boolean {
		
			var ss:Object = getCSSClass(xmlNode, css);
			
			if ((ss.visibility != undefined && ss.visibility == "hidden") ||
				(ss.display != undefined && ss.display == "none")) {
					
					return false;
					
				}
			
			return true;
			
		}
		
		//
		//
		private static function buildNode (obj:ASUIObject, container:Cell, xmlNode:XMLNode, css:StyleSheet, style:Style):void {
			
			var n:XMLNode = xmlNode;
			var a:Object = xmlNode.attributes;
			var nc:Component;
			var bounds:Object;
			var s:Style;
			var p:Position;
			var scroll:Boolean;

			if (container != null && n != null) {
	 
				switch (n.nodeName) {
					
					case "label":
					case "a":
						
						if (xmlNode.firstChild != null) buildNode(obj, container, xmlNode.firstChild, css, style);
						break;
					
					case "div":		
				   
						bounds = getBounds(n, css);
						s = getStyle(n, css, false, style);
						p = getPosition(n, css);

						nc = container.addChild(new Cell(null, bounds.width, bounds.height, bounds.background, bounds.border, bounds.round, p, s));
						
						if (xmlNode.firstChild != null) buildNode(obj, Cell(nc), xmlNode.firstChild, css, style); 
						
						if (p.collapse == true) Cell(nc).update();
						
						scroll = ((a.scroll != undefined &&  a.scroll == "true") || p.overflow == "scroll");
						
						if (scroll) {
							var sb:ScrollBar = container.addChild(new ScrollBar(null, NaN, NaN, Position.ORIENTATION_VERTICAL, null, s)) as ScrollBar;
							sb.targetCell = Cell(nc);
							Cell(nc).collapse = false;
						}
						
						break;
						
					case "asui:dialogue":
					
						bounds = getBounds(n, css);
						s = getStyle(n, css, false, style);
						p = getPosition(n, css);
						
						if (a.title == undefined) a.title = "";
						
						scroll = ((a.scroll != undefined &&  a.scroll == "true") || p.overflow == "scroll");
						
						var db:DialogueBox = new DialogueBox(null, bounds.width, bounds.height, a.title, (a.controls != undefined) ? a.controls.split(",") : [], scroll, (a.round != undefined) ? parseFloat(a.round) : 0, p, s)

						if (a.offsetx != undefined) db.offsetX = parseInt(a.offsetx);
						if (a.offsety != undefined) db.offsetY = parseInt(a.offsety);

						db.name = (a.name != undefined) ? a.name : StringUtils.clean(a.title);
						
						if (a.pointer != undefined) {
							
							db.pointer = (a.pointer == "true");
							
							db.pointerSize = (a.pointerSize != undefined) ? parseInt(a.pointerSize) : 20;
							db.pointerPosition = (a.pointerPosition != undefined) ? parseInt(a.pointerPosition) : bounds.width * 1.5 + bounds.height;

						}
						
						if (a.mask != undefined && a.mask == "false") db.useBackgroundMask = false;
						
						nc = container.addChild(db);
						
						for each (var btn:BButton in DialogueBox(nc).buttons) btn.addEventListener(Component.EVENT_CLICK, obj.onEvent);
						
						if (xmlNode.firstChild != null) buildNode(obj, DialogueBox(nc).contentCell, xmlNode.firstChild, css, style); 
						
						if (p.collapse == true) Cell(nc).update();
						break;
						
					case "asui:colorpicker":
					
						bounds = getBounds(n, css);
						s = getStyle(n, css, false, style);
						p = getPosition(n, css);
						
						if (a.title == undefined) a.title = "";
						
						if (isNaN(bounds.width)) bounds.width = 120;
						
						var color:Number = (a.color != undefined) ? ColorTools.HTMLColorToNumber(a.color) : 0xff0000;

						var cp:ColorPicker = new ColorPicker(null, color, bounds.width, a.title, p, s);
						
						if (a.full != undefined && a.full == "false") cp.showFullPicker = false;
						
						nc = container.addChild(cp);
						
						ColorPicker(nc).addEventListener(Component.EVENT_CHANGE, obj.onEvent);
						
						break;
						
					case "asui:slider":
					
						bounds = getBounds(n, css);
						s = getStyle(n, css, false, style);
						p = getPosition(n, css);
						
						if (isNaN(bounds.width)) bounds.width = 120;
						if (isNaN(bounds.height)) bounds.height = 20;

						if (a.snap == undefined) a.snap = 0;
						
						nc = container.addChild(new Slider(null, bounds.width, bounds.height, 
							(a.orientation == "vertical") ? Position.ORIENTATION_VERTICAL : Position.ORIENTATION_HORIZONTAL, 
							parseInt(a.snap), p, s));
							
						Slider(nc).ratio = 0.01;	
						
						Slider(nc).addEventListener(Component.EVENT_CHANGE, obj.onEvent);
						
						break;
						
					case "br":		
				  		
						bounds = getBounds(n, css);
						nc = container.addChild(new Cell(null, bounds.width, 10, bounds.background, bounds.border, bounds.round, p, s));
						break;
						
					case "p":
					case "h1":
					case "h2":
					case "h3":
					case "h4":
					case "h5":
					case "li":
					case "ul":
					case "ol":

						bounds = getBounds(n, css);
						s = getStyle(n, css, true, style);
						p = getPosition(n, css);

						if (isNaN(bounds.width)) bounds.width = container.width - p.margin_left - p.margin_right;
						
						nc = container.addChild(new HTMLField(null, n.toString(), bounds.width, (isNaN(bounds.height) || bounds.height > 20), p, s));
						obj.connectHTMLField(HTMLField(nc));
						break;
						
					case "hr":
					
						bounds = getBounds(n, css);
						s = getStyle(n, css, false, style);
						p = getPosition(n, css);
						
						nc = container.addChild(new HRule(null, bounds.width, p, s));
						break;
						
					case "asui:divider":
					
						bounds = getBounds(n, css);
						s = getStyle(n, css, false, style);
						p = getPosition(n, css);
						
						nc = container.addChild(new Divider(null, bounds.width, bounds.height, !(bounds.height > bounds.width), p, s));
						break;
						
					case "img":
					
						bounds = getBounds(n, css);
						s = getStyle(n, css, false, style);
						p = getPosition(n, css);
						
						nc = container.addChild(new Clip(null, a.src, Clip.EMBED_SMART, bounds.width, bounds.height, (a.width == null) ? Clip.SCALEMODE_NOSCALE : Clip.SCALEMODE_STRETCH, 
							(n.parentNode.nodeName == "a" && n.parentNode.attributes.href != undefined) ? n.parentNode.attributes.href : "",
							(n.parentNode.nodeName == "a" && n.parentNode.attributes.target == "_blank"),
							(n.attributes.alt != undefined) ? n.attributes.alt : "", p, s));
						break;
					
					case "input":

						switch (a.type) {
						
							case "hidden":
								break;
								
							case "submit":
							case "button":
							
								bounds = getBounds(n, css);
								s = getStyle(n, css, false, style);
								p = getPosition(n, css);
								
								nc = container.addChild(
									new BButton(
										null,
										(a.value != undefined && a.icon != undefined) ? {icon: Create[a.icon], text: a.value, first: a.first } : (a.value != undefined) ? a.value : (a.icon != undefined) ? Create[a.icon] : "", 
										p.align, bounds.width, bounds.height, false, false, false, p, s
									)
								);
								
								if (a.readonly == "true" || a.disabled == "true") BButton(nc).disable();
								
								break;
								
							case "toggle":
							
								bounds = getBounds(n, css);
								s = getStyle(n, css, false, style);
								p = getPosition(n, css);
								
								nc = container.addChild(
									new ToggleButton(
										null,
										(a.value != undefined) ? a.value : (a.icon != undefined) ? Create[a.icon] : "",
										(a.toggledvalue != undefined) ? a.toggledvalue : (a.toggledicon != undefined) ? Create[a.toggledicon] : "",
										(a.toggled != undefined && a.toggled == "true"),
										p.align, bounds.width, bounds.height, p, s
									)
								);
								
								if (a.readonly == "true" || a.disabled == "true") ToggleButton(nc).disable();
								
								break;
									
							case "checkbox":
							
								bounds = getBounds(n, css);
								s = getStyle(n, css, false, style);
								p = getPosition(n, css);
								
								nc = container.addChild(
									new CheckBox(
										null,
										(n.parentNode.nodeName == "label" && n.nextSibling.nodeValue != null) ? n.nextSibling.nodeValue : "",
										(a.value != undefined) ? a.value : "", (a.checked == "checked"),
										bounds.width, bounds.height, p, s
									)
								);
							
								if (a.readonly == "true" || a.disabled == "true") CheckBox(nc).disable();
							
								break;
								
							case "radio":
							
								bounds = getBounds(n, css);
								s = getStyle(n, css, false, style);
								p = getPosition(n, css);
								
								nc = container.addChild(
									new RadioButton(
										null,
										(n.parentNode.nodeName == "label" && n.nextSibling.nodeValue != null) ? n.nextSibling.nodeValue : "",
										(a.value != undefined) ? a.value : "",
										(a.name != undefined) ? a.name : "", (a.checked == "checked"),
										bounds.width, bounds.height, p, s
									)
								);
						  
								if (a.readonly == "true" || a.disabled == "true") RadioButton(nc).disable();
						  
								break;
								
							case "text":
							case "password":
							default:
							
								bounds = getBounds(n, css);
								s = getStyle(n, css, false, style);
								p = getPosition(n, css);
								
								try {
								nc = container.addChild(
									new FormField(
										null, 
										(a.value != undefined) ? a.value : "",
										bounds.width, bounds.height, (a.readonly != "true"), p, s
									)
								);
								} catch (e:Error) { trace(e.getStackTrace()); }
								if (a.readonly == "true" || a.disabled == "true") FormField(nc).disable();
								
								if (a.restrict != undefined) FormField(nc).restrict = a.restrict;
								if (a.type == "password") FormField(nc).password = true;
								break;
														   
						}
						
						break;
						
					case "select":
						
						var choices:Array = [];
						
						var cx:Array = n.childNodes;
						var cxidx:Number = 0;
						for (var cs:Number = 0; cs < cx.length; cs++) {
							choices.push(cx.attributes.value);
							if (cx.attributes.selected != undefined) cxidx = cs; 
						}
						
						bounds = getBounds(n, css);
						s = getStyle(n, css, false, style);
						p = getPosition(n, css);
						
						nc = container.addChild(
							new ComboBox(
								null, 
								(n.parentNode.nodeName == "label" && n.nextSibling.nodeValue != null) ? n.nextSibling.nodeValue : "",
								choices, 
								cxidx,
								(n.parentNode.nodeName == "label" && n.nextSibling.nodeValue != null) ? n.nextSibling.nodeValue : "",
								bounds.width, p, s
							)
						);
						
						break;
						
					case "textarea":
					
						bounds = getBounds(n, css);
						s = getStyle(n, css, false, style);
						p = getPosition(n, css);
			
						if (isNaN(bounds.height)) {
							if (a.rows == undefined) a.rows = 3;
							bounds.height = parseInt(a.rows) * s.fontSize + Math.floor(s.fontSize * 0.33) + s.borderWidth * 2 + 6;
						}
						
						var tval:String = "";
						if (n.firstChild != null) {
							
							for (var i:int = 0; i < n.childNodes.length; i++) {
								tval += n.childNodes[i].toString() + " \r\n";
							}
						}
			
						try {
						nc = container.addChild(
							new FormField(
								null, tval,
								bounds.width, bounds.height, (a.readonly != "true"), p, s
							)
						);
						} catch (e:Error) { trace(e.getStackTrace()); }
						if (a.readonly == "true" || a.disabled == "true") FormField(nc).disable();
						if (a.editable == "false") FormField(nc).editable = false;
						
						if (a.restrict != undefined) FormField(nc).restrict = a.restrict;
						FormField(nc).value = tval;
						break;	
					
				}
				
				if (nc != null && a.id != undefined) {
					
					obj.idMap[a.id] = nc;
					nc.id = a.id;
					
				}
				
				if (nc != null && a["class"] != undefined) {
					
					obj.mapToClass(nc, a["class"]);
					
				}
				
				if (nc != null && a.name != undefined) {

					nc.name = a.name;
					obj.nameMap[a.name] = nc;
					if (a.value != undefined) nc.value = a.value;
					obj.connect("", nc, "");
					nc.form = obj.form;
					
				}

				if (nc != null && !checkVisibility(n, css)) nc.hide();
				
				if (xmlNode.nextSibling != null) {
					buildNode(obj, container, xmlNode.nextSibling, css, style); 
				}
				
			}
			
		}
		
	}
	
}