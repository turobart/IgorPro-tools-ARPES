#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function fitBands()
	SetdataFolder root:
	string graphToFit
	string temp
	prompt temp, "Enter full wave name"
	doprompt "Enter full wave name",temp
	
	graphToFit = temp
	newdatafolder/o $graphToFit
	SetdataFolder $graphToFit
   //Duplicate/o root:$graphToFit, $graphToFit
	make/o/n=9 varlist_bands
	//0 - delta E_C
	//1 - delta E_V
	//2 - m_C
	//3 - m_V
	//4 - E-shift_C
	//5 - E-shift_V
	//6	 - E0+delta E Conduction
	//7 - E0+delta E Valence
	//8 - measured Dirac point
	make/o/n=6 constlist_bands
	constlist_bands[0] = dimsize(root:$graphToFit, 0)
	constlist_bands[1] = DimOffset(root:$graphToFit, 0)
	constlist_bands[2] = DimDelta(root:$graphToFit, 0)
	bands_panel()
	
	
end

function bands_panel()
	variable spectraWidth
	wave constlist_bands,varlist_bands
	
	spectraWidth = constlist_bands[0]
	
	Make/O/N=(spectraWidth)/D conductionFitWave
	Make/O/N=(spectraWidth)/D valenceFitWave
	
	SetScale/P x constlist_bands[1], constlist_bands[2],"", conductionFitWave
	SetScale/P x constlist_bands[1], constlist_bands[2],"", valenceFitWave
		
	variable numItems = ItemsInList(TraceNameList("", ";", 1))
	
	if (numItems<3)
		AppendToGraph conductionFitWave
		AppendToGraph valenceFitWave
		ModifyGraph lsize(conductionFitWave)=2,rgb(conductionFitWave)=(0,0,0), lstyle(conductionFitWave)=2
		ModifyGraph lsize(valenceFitWave)=2,rgb(valenceFitWave)=(0,0,0), lstyle(valenceFitWave)=2
	endif

	
	NewPanel/K=1 /W=(1200,120,1650,390) as "Bands fit panel"
	ModifyPanel cbRGB=( 65535 * 200/255,65535 * 200/255,65535 * 200/255)
	
	TitleBox mainTitle title="Sn content and T for E\B0\M calculation", pos={20,10}, size={50,20},frame=2
	
	SetVariable setvarX title="%\BSn", pos={25,40},size={80,18},value= constlist_bands[3], limits={0, 1, 0.01}, proc = setInitX_B
	SetVariable setVarT title="T [K]", pos={120,40},size={80,18},value= constlist_bands[4], limits={0, 273,1}, proc = setInitT_B
	
	SetVariable initialEDisplay title="E\B0", pos={215,40}, size={70,20},frame=1, value=constlist_bands[5], disable=2
		
	TitleBox conductionTitle title="Conduction band", pos={15,80}, size={50,20},frame=2
	TitleBox valenceTitle title="Valence band", pos={240,80}, size={50,20},frame=2
	SetVariable currentEDisplayC title="E\B0\M+∆E\B0", pos={120,80}, size={100,20},frame=1, value=varlist_bands[6], disable=2
	SetVariable currentEDisplayV title="E\B0\M+∆E\B0", pos={340,80}, size={100,20},frame=1, value=varlist_bands[7], disable=2

	Slider sliderEC pos={15,115},size={100,20},vert=0,side=0,ticks=0,limits={-0.5, 1.0,0.001},value = varlist_bands[0], proc = changeEC
	Slider sliderMC pos={15,155},size={100,20},vert=0,side=0,ticks=0,limits={0, 1.0,0.0001},value = varlist_bands[2], proc = changeMC
	Slider sliderSchiftEC pos={15,195},size={100,20},vert=0,side=0,ticks=0,limits={-1,1,0.001},value = varlist_bands[4], proc = shiftEC
		
	SetVariable setvarEC title="∆E\B0", pos={140,110},size={75,18},value= varlist_bands[0], limits={-0.5, 1.0,0.001}, proc = setChangeEC
	SetVariable setvarMC title="m\SC\M\Bt", pos={140,150},size={75,18},value= varlist_bands[2], limits={0, 1.0,0.0001}, proc = setChangeMC
	SetVariable setvarschiftEC title="E shift", pos={125,190},size={90,18},value= varlist_bands[4], limits={-1,1,0.001}, proc = setShiftEC
	
	Slider sliderEV pos={240,115},size={100,20},vert=0,side=0,ticks=0,limits={-0.5, 1.0,0.001},value = varlist_bands[1], proc = changeEV
	Slider sliderMV pos={240,155},size={100,20},vert=0,side=0,ticks=0,limits={0, 1.0,0.0001},value = varlist_bands[3], proc = changeMV
	Slider sliderSchiftEV pos={240,195},size={100,20},vert=0,side=0,ticks=0,limits={-1,1,0.001},value = varlist_bands[5], proc = shiftEV
	
	SetVariable setvarEV title="∆E\B0", pos={365,110},size={75,18},value= varlist_bands[1], limits={-0.5, 0.5,0.001}, proc = setChangeEV
	SetVariable setvarMV title="m\SV\M\Bt", pos={365,150},size={75,18},value= varlist_bands[3], limits={0, 0.5,0.0001}, proc = setChangeMV
	SetVariable setvarschiftEV title="E shift", pos={350,190},size={90,18},value= varlist_bands[5], limits={-1,1,0.001}, proc = setShiftEV
	
	SetVariable measuredDirac title="Measured Dirac point", pos={15,230}, size={200,20},frame=1, value=varlist_bands[8], disable=2
	
end

Function setInitX_B(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave constlist_bands
	
	constlist_bands[3]= varNum
	calculateInitialGuessE_B()
end 

Function setInitT_B(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave constlist_bands
	
	constlist_bands[4]= varNum
	calculateInitialGuessE_B()
end 

function calculateInitialGuessE_B()
	variable initialE
	wave constlist_bands,varlist_bands
	initialE = (125 - 1021*constlist_bands[3] + sqrt(400 + 0.256*constlist_bands[4]^2))/1000
	
	string str
	sprintf str, "%.*g\r", 3, initialE
	constlist_bands[5] = str2num(str)
	
	SetVariable initialEDisplay, value = constlist_bands[5]
	varlist_bands[6] = varlist_bands[0]+constlist_bands[5]
	varlist_bands[7] = varlist_bands[1]+constlist_bands[5]
	SetVariable currentEDisplayC, value = varlist_bands[6]
	SetVariable currentEDisplayV, value = varlist_bands[7]
	
	
end

function changeEC(ctrlName, sliderValueEC, event) : SliderControl
	string ctrlName
	variable sliderValueEC
	variable event
	wave varlist_bands
	if(event %& 0x1)
		varlist_bands[0]=sliderValueEC
		updateFit_B()
	endif	
end

function changeEV(ctrlName, sliderValueEV, event) : SliderControl
	string ctrlName
	variable sliderValueEV
	variable event
	wave varlist_bands
	if(event %& 0x1)
		varlist_bands[1]=sliderValueEV
		updateFit_B()
	endif	
end

function changeMC(ctrlName, sliderValueMC, event) : SliderControl
	string ctrlName
	variable sliderValueMC
	variable event
	wave varlist_bands
	if(event %& 0x1)
		varlist_bands[2]=sliderValueMC
		updateFit_B()
	endif	
end

function changeMV(ctrlName, sliderValueMV, event) : SliderControl
	string ctrlName
	variable sliderValueMV
	variable event
	wave varlist_bands
	if(event %& 0x1)
		varlist_bands[3]=sliderValueMV
		updateFit_B()
	endif	
end

function shiftEC(ctrlName, sliderValueShiftEC, event) : SliderControl
	string ctrlName
	variable sliderValueShiftEC
	variable event
	wave varlist_bands
	if(event %& 0x1)
		varlist_bands[4]=sliderValueShiftEC
		updateFit_B()
	endif	
end

function shiftEV(ctrlName, sliderValueShiftEV, event) : SliderControl
	string ctrlName
	variable sliderValueShiftEV
	variable event
	wave varlist_bands
	if(event %& 0x1)
		varlist_bands[5]=sliderValueShiftEV
		updateFit_B()
	endif	
end


Function setChangeEC(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave varlist_bands
	
	varlist_bands[0]= varNum
	Slider sliderEC, value = varlist_bands[0]
	updateFit_B()
end

Function setChangeEV(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave varlist_bands
	
	varlist_bands[1]= varNum
	Slider sliderEV, value = varlist_bands[1]
	updateFit_B()
end

Function setChangeMC(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave varlist_bands
	
	varlist_bands[2]= varNum
	Slider sliderMC, value = varlist_bands[2]
	updateFit_B()
end

Function setChangeMV(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave varlist_bands
	
	varlist_bands[3]= varNum
	Slider sliderMV, value = varlist_bands[3]
	updateFit_B()
end

Function setShiftEC(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave varlist_bands
	
	varlist_bands[4]= varNum
	Slider sliderSchiftEC, value = varlist_bands[4]
	updateFit_B()
end

Function setShiftEV(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave varlist_bands
	
	varlist_bands[5]= varNum
	Slider sliderSchiftEV, value = varlist_bands[5]
	updateFit_B()
end

function updateFit_B()
	wave varlist_bands,constlist_bands
	wave /D conductionFitWave
	wave /D valenceFitWave
	
	variable h=6.582119514e-16 //reduced Planck constant in eV s
	variable me=0.51099895e6 //electron mass in eV/c^2
	variable c=299792458 //speed of light
	variable angstrom =1e-10
	variable constants
	constants = h^2*c^2/me/angstrom^2
	
	varlist_bands[6] = varlist_bands[0]+constlist_bands[5]
	varlist_bands[7] = varlist_bands[1]+constlist_bands[5]
	
	conductionFitWave = abs(varlist_bands[6])/2*(sqrt(2*constants*(x)^2/varlist_bands[2]/varlist_bands[6]+1)-1)+varlist_bands[4]
	valenceFitWave = -abs(varlist_bands[7])/2*(sqrt(2*constants*(x)^2/varlist_bands[3]/varlist_bands[7]+1)-1)+varlist_bands[5]

	conductionFitWave = (conductionFitWave[p]) > 0 ? Nan : conductionFitWave
	valenceFitWave = (valenceFitWave[p]) > 0 ? Nan : valenceFitWave

	varlist_bands[8] = (varlist_bands[4]+varlist_bands[5])/2
end