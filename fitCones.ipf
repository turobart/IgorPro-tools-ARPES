#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function fitCones()
	SetdataFolder root:
	string graphToFit
	string temp
	prompt temp, "Enter full wave name"
	doprompt "Enter full wave name",temp
	
	graphToFit = temp
	newdatafolder/o $graphToFit
	SetdataFolder $graphToFit
   //Duplicate/o root:$graphToFit, $graphToFit
	make/o/n=10 varlist_bands
	//0 - delta E_C
	//1 - delta E_V
	//2 - m_C
	//3 - m_V
	//4 - E-shift_C
	//5 - E-shift_V
	//6	 - E0+delta E Conduction
	//7 - E0+delta E Valence
	//8 - measured Dirac point
	//9 - k separation
	make/o/n=6 constlist_bands
	constlist_bands[0] = dimsize(root:$graphToFit, 0)
	constlist_bands[1] = DimOffset(root:$graphToFit, 0)
	constlist_bands[2] = DimDelta(root:$graphToFit, 0)
	//constlist_bands[3] = 0
	//constlist_bands[4] = 0
	//constlist_bands[5] = 0
	// 3 - initial X
	// 4 - initial T
	// 5 - E0
	cones_panel()
	
	
end

function cones_panel()
	variable spectraWidth
	wave constlist_bands,varlist_bands
	
	spectraWidth = constlist_bands[0]
	
	Make/O/N=(spectraWidth)/D conductionFitWave1
	Make/O/N=(spectraWidth)/D valenceFitWave1
	Make/O/N=(spectraWidth)/D conductionFitWave2
	Make/O/N=(spectraWidth)/D valenceFitWave2
	
	SetScale/P x constlist_bands[1], constlist_bands[2],"", conductionFitWave1
	SetScale/P x constlist_bands[1], constlist_bands[2],"", valenceFitWave1
	SetScale/P x constlist_bands[1], constlist_bands[2],"", conductionFitWave2
	SetScale/P x constlist_bands[1], constlist_bands[2],"", valenceFitWave2
		
	variable numItems = ItemsInList(TraceNameList("", ";", 1))
	
	if (numItems<3)
		AppendToGraph conductionFitWave1
		AppendToGraph valenceFitWave1
		AppendToGraph conductionFitWave2
		AppendToGraph valenceFitWave2
		ModifyGraph lsize(conductionFitWave1)=2,rgb(conductionFitWave1)=(65535,0,0)
		ModifyGraph lsize(valenceFitWave1)=2,rgb(valenceFitWave1)=(65535,0,0)
		ModifyGraph lsize(conductionFitWave2)=2,rgb(conductionFitWave2)=(0,0,65535)
		ModifyGraph lsize(valenceFitWave2)=2,rgb(valenceFitWave2)=(0,0,65535)
	endif

	
	NewPanel/K=1 /W=(1200,120,1650,430) as "Bands fit panel"
	ModifyPanel cbRGB=( 65535 * 200/255,65535 * 200/255,65535 * 200/255)
	
	TitleBox mainTitle title="Sn content and T for E\B0\M calculation", pos={20,10}, size={50,20},frame=2
	
	SetVariable setvarX title="%\BSn", pos={25,40},size={80,18},value= constlist_bands[3], limits={0, 1, 0.01}, proc = setInitX_D
	SetVariable setVarT title="T [K]", pos={120,40},size={80,18},value= constlist_bands[4], limits={0, 273,1}, proc = setInitT_D
	
	SetVariable initialEDisplay title="E\B0", pos={215,40}, size={70,20},frame=1, value=constlist_bands[5], disable=2
		
	TitleBox conductionTitle title="Conduction band", pos={15,80}, size={50,20},frame=2
	TitleBox valenceTitle title="Valence band", pos={240,80}, size={50,20},frame=2
	SetVariable currentEDisplayC title="E\B0\M+∆E\B0", pos={120,80}, size={100,20},frame=1, value=varlist_bands[6], disable=2
	SetVariable currentEDisplayV title="E\B0\M+∆E\B0", pos={340,80}, size={100,20},frame=1, value=varlist_bands[7], disable=2

	Slider sliderEC pos={15,115},size={100,20},vert=0,side=0,ticks=0,limits={-0.5, 0.5,0.001},value = varlist_bands[0], proc = changeEC_D
	Slider sliderMC pos={15,155},size={100,20},vert=0,side=0,ticks=0,limits={0, 0.1,0.0001},value = varlist_bands[2], proc = changeMC_D
	Slider sliderSchiftEC pos={15,195},size={100,20},vert=0,side=0,ticks=0,limits={-1,0,0.001},value = varlist_bands[4], proc = shiftEC_D
		
	SetVariable setvarEC title="∆E\B0", pos={140,110},size={75,18},value= varlist_bands[0], limits={-0.5, 0.5,0.001}, proc = setChangeEC_D
	SetVariable setvarMC title="m\SC\M\Bt", pos={140,150},size={75,18},value= varlist_bands[2], limits={0, 0.1,0.0001}, proc = setChangeMC_D
	SetVariable setvarschiftEC title="E shift", pos={125,190},size={90,18},value= varlist_bands[4], limits={-1,0,0.001}, proc = setShiftEC_D
	
	Slider sliderEV pos={240,115},size={100,20},vert=0,side=0,ticks=0,limits={-0.5, 0.5,0.001},value = varlist_bands[1], proc = changeEV_D
	Slider sliderMV pos={240,155},size={100,20},vert=0,side=0,ticks=0,limits={0, 0.1,0.0001},value = varlist_bands[3], proc = changeMV_D
	Slider sliderSchiftEV pos={240,195},size={100,20},vert=0,side=0,ticks=0,limits={-1,0,0.001},value = varlist_bands[5], proc = shiftEV_D
	
	SetVariable setvarEV title="∆E\B0", pos={365,110},size={75,18},value= varlist_bands[1], limits={-0.5, 0.5,0.001}, proc = setChangeEV_D
	SetVariable setvarMV title="m\SV\M\Bt", pos={365,150},size={75,18},value= varlist_bands[3], limits={0, 0.1,0.0001}, proc = setChangeMV_D
	//SetVariable setvarSchiftK title="k shift", pos={135,180},size={90,18},value= varlist_bands[2], limits={0,0.4,0.001}, proc = setShiftK_B
	SetVariable setvarschiftEV title="E shift", pos={350,190},size={90,18},value= varlist_bands[5], limits={-1,0,0.001}, proc = setShiftEV_D
	
	Slider sliderSchiftK pos={25,230},size={100,20},vert=0,side=0,ticks=0,limits={0,0.4,0.001},value = varlist_bands[9], proc = shiftK_D
	SetVariable setvarSchiftK title="k separation", pos={135,230},size={130,18},value= varlist_bands[9], limits={0,0.4,0.001}, proc = setShiftK_D
	SetVariable measuredDirac title="Measured Dirac point", pos={15,270}, size={200,20},frame=1, value=varlist_bands[8], disable=2
	
end

Function setInitX_D(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave constlist_bands
	
	constlist_bands[3]= varNum
	calculateInitialGuessE_D()
end 

Function setInitT_D(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave constlist_bands
	
	constlist_bands[4]= varNum
	calculateInitialGuessE_D()
end 

function calculateInitialGuessE_D()
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

function changeEC_D(ctrlName, sliderValueEC, event) : SliderControl
	string ctrlName
	variable sliderValueEC
	variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	wave varlist_bands
	if(event %& 0x1)
		varlist_bands[0]=sliderValueEC
		updateFit_D()
	endif	
end

function changeEV_D(ctrlName, sliderValueEV, event) : SliderControl
	string ctrlName
	variable sliderValueEV
	variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	wave varlist_bands
	if(event %& 0x1)
		varlist_bands[1]=sliderValueEV
		updateFit_B()
	endif	
end

function changeMC_D(ctrlName, sliderValueMC, event) : SliderControl
	string ctrlName
	variable sliderValueMC
	variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	wave varlist_bands
	if(event %& 0x1)
		varlist_bands[2]=sliderValueMC
		updateFit_D()
	endif	
end

function changeMV_D(ctrlName, sliderValueMV, event) : SliderControl
	string ctrlName
	variable sliderValueMV
	variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	wave varlist_bands
	if(event %& 0x1)
		varlist_bands[3]=sliderValueMV
		updateFit_D()
	endif	
end

function shiftEC_D(ctrlName, sliderValueShiftEC, event) : SliderControl
	string ctrlName
	variable sliderValueShiftEC
	variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	wave varlist_bands
	if(event %& 0x1)
		varlist_bands[4]=sliderValueShiftEC
		updateFit_D()
	endif	
end

function shiftEV_D(ctrlName, sliderValueShiftEV, event) : SliderControl
	string ctrlName
	variable sliderValueShiftEV
	variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	wave varlist_bands
	if(event %& 0x1)
		varlist_bands[5]=sliderValueShiftEV
		updateFit_D()
	endif	
end

function shiftK_D(ctrlName, sliderValueShiftK, event) : SliderControl
	string ctrlName
	variable sliderValueShiftK
	variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	wave varlist_bands
	if(event %& 0x1)
		varlist_bands[9]=sliderValueShiftK
		updateFit_D()
	endif	
end


Function setChangeEC_D(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave varlist_bands
	
	varlist_bands[0]= varNum
	Slider sliderEC, value = varlist_bands[0]
	updateFit_D()
end

Function setChangeEV_D(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave varlist_bands
	
	varlist_bands[1]= varNum
	Slider sliderEV, value = varlist_bands[1]
	updateFit_D()
end

Function setChangeMC_D(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave varlist_bands
	
	varlist_bands[2]= varNum
	Slider sliderMC, value = varlist_bands[2]
	updateFit_D()
end

Function setChangeMV_D(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave varlist_bands
	
	varlist_bands[3]= varNum
	Slider sliderMV, value = varlist_bands[3]
	updateFit_D()
end

Function setShiftEC_D(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave varlist_bands
	
	varlist_bands[4]= varNum
	Slider sliderSchiftEC, value = varlist_bands[4]
	updateFit_D()
end

Function setShiftEV_D(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave varlist_bands
	
	varlist_bands[5]= varNum
	Slider sliderSchiftEV, value = varlist_bands[5]
	updateFit_D()
end

Function setShiftK_D(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave varlist_bands
	
	varlist_bands[9]= varNum
	Slider sliderSchiftK, value = varlist_bands[9]
	updateFit_D()
end

function updateFit_D()
	wave varlist_bands,constlist_bands
	wave /D conductionFitWave1
	wave /D valenceFitWave1
	wave /D conductionFitWave2
	wave /D valenceFitWave2
	
	variable h=6.582119514e-16 //reduced Planck constant in eV s
	variable me=0.51099895e6 //electron mass in eV/c^2
	variable c=299792458 //speed of light
	variable angstrom =1e-10
	variable constants
	constants = h^2*c^2/me/angstrom^2
	
	varlist_bands[6] = varlist_bands[0]+constlist_bands[5]
	varlist_bands[7] = varlist_bands[1]+constlist_bands[5]
	
	conductionFitWave1 = abs(varlist_bands[6])/2*(sqrt(2*constants*(x+varlist_bands[9])^2/varlist_bands[2]/varlist_bands[6]+1)-1)+varlist_bands[4]
	valenceFitWave1 = -abs(varlist_bands[7])/2*(sqrt(2*constants*(x+varlist_bands[9])^2/varlist_bands[3]/varlist_bands[7]+1)-1)+varlist_bands[5]
	conductionFitWave2 = abs(varlist_bands[6])/2*(sqrt(2*constants*(x-varlist_bands[9])^2/varlist_bands[2]/varlist_bands[6]+1)-1)+varlist_bands[4]
	valenceFitWave2 = -abs(varlist_bands[7])/2*(sqrt(2*constants*(x-varlist_bands[9])^2/varlist_bands[3]/varlist_bands[7]+1)-1)+varlist_bands[5]


	varlist_bands[8] = (varlist_bands[4]+varlist_bands[5])/2
end