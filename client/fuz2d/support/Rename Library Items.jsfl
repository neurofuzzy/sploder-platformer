//
//
//
function replace(oldString, newString) {
	
	var lib = fl.getDocumentDOM().library;
	
	lib.selectNone();
	
	var n = lib.items.length;
	
	for (var i = 0; i < n; i++) {
		
		lib.selectNone();
		
		if (lib.items[i].name.indexOf(oldString) != -1) {
			
			lib.selectItem(lib.items[i].name);
			
			var newName = lib.items[i].name.split(oldString).join(newString);
			var newNameParts = newName.split("/");
			newName = newNameParts[newNameParts.length - 1];
			
			lib.renameItem(newName);
			
		}
		
	}		

}

var doc = fl.getDocumentDOM();
var result = doc.xmlPanel(fl.configURI + "/Commands/RenameLibraryItems.xml");
fl.outputPanel.clear();

if (result.search.length > 0 && result.replace.length > 0) {

	replace(result.search, result.replace);
	
}
	


