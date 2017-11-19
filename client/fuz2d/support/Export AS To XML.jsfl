/*
	Software Secret Weapons Code Library
	Copyright (C) 2005 Pavel Simakov
	http://www.softwaresecretweapons.com
	
	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.
	
	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.
	
	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
*/

function asToXml()
{

	var mTraceArray;
  var mWalkedElements;
	var mNumberOfTimelines;
	var mNumberOfFrames;
	var mNumberOfLayers;
	var mNumberOfElements;
	var mNumberOfInstances;
  var mTabLevel;
  var mTabString;
  
  var mLineLimit = 9000;
  var mLinesUsed = 0;

	function init()
  {
    // A multidimensional array. Each index holds a 
    // number of lines to trace, up to mLineLimit.
    // Initialized with an empty array at index 0.
		mTraceArray = new Array( [] );
    mWalkedElements = new Array();
		
    mTabLevel = 0;
    mTabString = "\t";
    
		// stats
		mNumberOfTimelines = 0;
		mNumberOfFrames = 0;
		mNumberOfLayers = 0;
		mNumberOfElements = 0;
		mNumberOfInstances = 0;
	}
	
	// removes white space
	function trim(text)
  {
		return text.replace(/^\s+|\s+$/, '');
	}
	
	// checks if item is in array
	function inArray( Needle, Haystack )
  {
		for( var i=0; i < Haystack.length; i++)
    {
			if( Haystack[i] == Needle )
      {	return true; }
		}
		return false;
	}
  
  // returns a string of tabs for formatting nested XML nodes
  function getTabs()
  {
    var TheTabs = "";
    
    for( var tabs=1; tabs <= mTabLevel; tabs++ )
    { TheTabs += mTabString; }
    
    return TheTabs;
  }
  
	// adds text to trace
	function addToTraceStack( str )
  {
    if( mLinesUsed >= mLineLimit )
    {
      mTraceArray[ mTraceArray.length ] = new Array();
      mLinesUsed = 0;
    }
    mTraceArray[ mTraceArray.length - 1 ].push( str );
    mLinesUsed++;
  }
	
	// generates XML from flash DOM
	this.generate = function ( theDoc, SaveURI )
  {
		flash.trace( "Started on " + theDoc.name + " on " + new Date() );
		
		init();
		
		try
    {	walkDoc( theDoc ); }
    catch( Exception )
    { return "Exception: " + Exception; }
    
		flash.trace( "Completed " + theDoc.name + " on " + new Date() );
		
    // Save up to *mLineLimit* lines at a time.
		for( i=0; i < mTraceArray.length; i++ )
    {
      flash.outputPanel.clear(); 
      for( var j = 0; j < mTraceArray[i].length; j++ )
      {
        flash.outputPanel.trace( mTraceArray[i][j] );
      }
      
      if( SaveURI != null )
      {
        // Save to a new file for the first *mLineLimit* lines, and append after that
        var Append = ( i==0 ) ? false : true;
        flash.outputPanel.save( SaveURI, Append );
      }
    }

    // Expanded XML report file saving
    if( SaveURI == null )
    {
      // user cancelled the save file dialog box
      flash.trace( "You have elected to NOT save the XML report to a file." );
    }
    else
    {
      // File is saved
      flash.trace( "XML report was saved to: " + SaveURI );
    }
    // Warn user for output that's too long to show in the output panel
    if( mTraceArray.length > 1 )
    { flash.trace( "\nOnly the last " + mLineLimit + " lines are visible in the output panel." ); }
	}
	
	// check that prior frame did not have script found in the current frame
	function hasScriptExistedOnPriorFrame( Frames, Index )
  {
		var PriorIndex = Index - 1;
		if ( PriorIndex < 0 || PriorIndex >= Frames.length )
    {	return false;	}

		var the_prior = Frames[PriorIndex];
		return Frames[Index].actionScript == the_prior.actionScript;
	}

	
	function walkDoc( theDoc )
  {
		addToTraceStack( "<EmbeddedAS document='"+ theDoc.name + "'>" );
    
    mTabLevel++;
		addToTraceStack( getTabs() + "<timelines>" );
    
    mTabLevel++;
		for(var t = 0; t < theDoc.timelines.length; t++)
    {	walkTimeline( theDoc.timelines[t] ); }
    
    mTabLevel--;
		addToTraceStack( getTabs() + "</timelines>" );

		walkLibrary( theDoc.library.items );

		addToTraceStack
    (
			getTabs() + "<stats " + 
				" date='" + new Date() + "'" +
				" timelines='" + mNumberOfTimelines + "'" + 
				" frames='" + mNumberOfFrames + "'" + 
				" layers='" + mNumberOfLayers + "'" + 
				" elements='" + mNumberOfElements + "'" + 
				" instances='" + mNumberOfInstances + "'" + 
			  "/>"
	  );
		mTabLevel--;
		addToTraceStack( "</EmbeddedAS>" );
	}

	function walkLibrary( the_lib )
	{
		addToTraceStack( getTabs() + "<library>" );
    mTabLevel++;
		for( var i = 0; i < the_lib.length; i++ )
		{
			var myItem = the_lib[i];
			if( myItem.itemType == "movie clip" )
			{
				addToTraceStack( getTabs() + "<movieclip name='"+ myItem.name + "'>" );
        mTabLevel++;
        		if (myItem.linkageClassName) {
					addToTraceStack( getTabs() + "<linkageClass>"+myItem.linkageClassName+"</linkageClass>");
				} 
				if( myItem.linkageExportForAS )
				{
					addToTraceStack( getTabs() + "<linkage>"+myItem.linkageIdentifier+"</linkage>");
				}
				walkTimeline( myItem.timeline );
        mTabLevel--;
        
				addToTraceStack( getTabs() + "</movieclip>" );
			}
		}
    mTabLevel--;
		addToTraceStack( getTabs() + "</library>" );
	}
	
	function walkTimeline( Timeline, InstanceName, AttachedAS )
  {
		mNumberOfTimelines++;
		flash.trace( "Processing timeline " + mNumberOfTimelines + ": " + Timeline.name );
		
    var MyInstanceName = "";
    if( InstanceName!=undefined && InstanceName != "" )
    { MyInstanceName = " instancename='" + InstanceName + "'"; }
    
		addToTraceStack( getTabs() + "<timeline name='" + Timeline.name + "'" + MyInstanceName + ">" );
    mTabLevel++;
    
    if( AttachedAS !=undefined && AttachedAS != "" )
    { addToTraceStack( getTabs() + "<attachedactionscript><![CDATA[" + AttachedAS + "]]></attachedactionscript>" ); }
		
		for(var l=0; l < Timeline.layers.length; l++)
    {
			mNumberOfLayers++;
		  
			var the_layer = Timeline.layers[l];
			for( var f=0; f < the_layer.frames.length; f++ )
      {
				mNumberOfFrames++;
			  
				var CurrentFrame = the_layer.frames[f];
				var Script = trim( CurrentFrame.actionScript );
				var Include = 
					Script != "" 
						&& 
					!hasScriptExistedOnPriorFrame( the_layer.frames, f );
        
				// output action script
				if( Include )
        {
					addToTraceStack
          (
            getTabs() + "<ascript layer='" + l + "' frame='" + f + "'>" + 
            "<![CDATA[" + Script + "]]></ascript>"
          );
				}
				walkElements( CurrentFrame );
			}
		}
		mTabLevel--;
		addToTraceStack( getTabs() + "</timeline>");
	}
	
	function walkElements( Frame )
  {
		for( var e=0; e < Frame.elements.length; e++ )
    {
			mNumberOfElements++;
			var the_elem = Frame.elements[e];
      
			if( the_elem.elementType == "instance" )
      {	walkInstance( the_elem ); }
		}
	}

	function walkInstance( the_elem )
  {
		mNumberOfInstances++;
		
		if( the_elem.instanceType == "symbol" && the_elem.symbolType == "movie clip" )
    {
			var Timeline = the_elem.libraryItem.timeline;
      var InstanceName = the_elem.name;
      var AttachedAS = the_elem.actionScript;
      
      mTabLevel++;
      // Pass the element's instance name and any attached AS code along to walkTimeline
      var UniqueID = "Clip: " + the_elem.libraryItem.name + " InstanceName: " + InstanceName + " AS: " + AttachedAS;
			if ( !inArray( UniqueID, mWalkedElements ) )
      {
				mWalkedElements.push( UniqueID );
        walkTimeline( Timeline, InstanceName, AttachedAS );
      }
      mTabLevel--;
		}
		
		// ADDED
		if(the_elem.symbolType == "button")
		{
			
		  var AttachedAS = trim(the_elem.actionScript);
		  
		  if (AttachedAS.length > 0) {
			  
			  AttachedAS = AttachedAS.split("\n").join(" ").split("\r").join(" ");
			 
				addToTraceStack
			  (
				getTabs() + "<ascript buttonInstance='" + the_elem.libraryItem.name + "'>" + 
				"<![CDATA[" + AttachedAS + "]]></ascript>"
			  );
			  
		  }

		}
		// END ADDED
		
	}
	
}

function runCommand()
{
  // Allow user to choose output location of XML report
  var xmlReportURI = flash.browseForFileURL( "save","Save XML report to a file or cancel to view in Output panel only." );
  var flashDoc = new asToXml();
  flashDoc.generate( flash.getDocumentDOM(), xmlReportURI ); 
}

runCommand();

