#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include <AnnotationInfo Procs>


Function resizeAll()
	Variable graphWidth=90, graphHeight=100, textFontSize = 8
	Prompt graphWidth, "Enter graph width in points: "
	Prompt graphHeight, "Enter graph width in points: "
	Prompt textFontSize, "Enter caption font size in points: "
	DoPrompt "Graph size", graphWidth, graphHeight, textFontSize
	if (V_Flag)
		return -1	// User canceled
	else							

		variable ic, numberOfGraphs, captionLen, endPos
		string graphsList, theOne, textList, graphCaption
	
		graphsList = WinList("Graph*",";","WIN:1")
		numberOfGraphs = ItemsInList(graphsList)
	
		for(ic=0;ic<numberOfGraphs;ic+=1)
			theOne = StringFromList(ic,graphsList)
			Dowindow/F $theOne

			textList = AnnotationInfo(theOne, "text0")
			graphCaption = AnnotationText(textList)
		
			Variable startPos = strsearch(graphCaption, "\\\\Z" , 0)
			if(	startPos >= 0 )
          	endPos = startPos + strlen("\\\\Zdd")-1
       	endif
    	
    		String replaceWith=""
    		sprintf replaceWith, "\Z%02d", textFontSize
    	
    		if( startPos < 0 )
       		graphCaption = replaceWith + graphCaption
    		else
    			graphCaption[startPos, endPos] = replaceWith
    		endif
			
			TextBox/C/N=text0 graphCaption
		
			ModifyGraph /W=$theOne width=graphWidth,height=graphHeight
			DoUpdate
			ModifyGraph/W=$theOne width = 0, height = 0
   		endfor
   		dowindow/H/F
   endif
end