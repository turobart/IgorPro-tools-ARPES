#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function fitRashbaH()
	SetdataFolder root:
	string /g graphToFit
	string temp
	prompt temp, "Enter the wave name"
	doprompt "Enter the wave name",temp
	
	graphToFit = temp
	newdatafolder/o $graphToFit
	SetdataFolder $graphToFit
   //Duplicate/o root:$graphToFit, $graphToFit
	make/o/n=9 varlistH
	//0-m=m||/me
	//1-rashba coeff
	//2-shiftCorr
	//3-E-shift
	//4 - kramesr Point
	//5 calculated Rashba
	//7 - Band minimum [eV]
	//8 - Minimum position - k
	
	make/o/n=3 constlistH
	constlistH[0] = dimsize(root:$graphToFit, 0)
	constlistH[1] = DimOffset(root:$graphToFit, 0)
	constlistH[2] = DimDelta(root:$graphToFit, 0)
	main_panel_H()
	
	
end

function main_panel_H()
	variable spectraWidth
	wave constlistH, varlistH
	
	spectraWidth = constlistH[0]
	
	Make/O/N=(spectraWidth)/D rasbhaFit1Hwave
	Make/O/N=(spectraWidth)/D rasbhaFit2Hwave
	
	SetScale/P x constlistH[1], constlistH[2],"", rasbhaFit1Hwave
	SetScale/P x constlistH[1], constlistH[2],"", rasbhaFit2Hwave
		
	variable numItems = ItemsInList(TraceNameList("", ";", 1))
	
	if (numItems<1)
		AppendToGraph rasbhaFit1Hwave
		AppendToGraph rasbhaFit2Hwave
		ModifyGraph lsize(rasbhaFit1Hwave)=2,lstyle(rasbhaFit1Hwave)=2
		ModifyGraph lsize(rasbhaFit2Hwave)=2,lstyle(rasbhaFit2Hwave)=2
	endif

	//AppendToGraph rasbhaFit1wave
	//AppendToGraph rasbhaFit2wave
	
	
	NewPanel/K=1 /W=(1200,120,1600,440) as "Rashba fit panel - Hamiltonian"
	ModifyPanel cbRGB=( 65535 * 200/255,65535 * 200/255,65535 * 200/255)
	
	TitleBox mainTitle title="Rashba fit - E(k)\B±\M = h\S2\M\Bred\Mk\B||\M\S2\M/2m\B||\M ± α\BR\M(1+α\Bcorr\Mk\B||\M\S2\M)k\B||", pos={20,10}, size={50,20},frame=2

	Slider sliderM pos={25,85},size={200,20},vert=0,side=0,ticks=0,limits={0, 1,0.00001},value = varlistH[0], proc = changeM_H
	Slider sliderRashba pos={25,125},size={200,20},vert=0,side=0,ticks=0,limits={0, 50,0.01},value = varlistH[1], proc = changeRashba_H
	Slider sliderCorr pos={25,165},size={200,20},vert=0,side=0,ticks=0,limits={0,300,0.5},value = varlistH[2], proc = shiftCorr_H
	Slider sliderSchiftE pos={25,205},size={200,20},vert=0,side=0,ticks=0,limits={-1,1,0.001},value = varlistH[3], proc = shiftE_H
	
	SetVariable setvarM title="m\Bt", pos={235,80},size={80,18},value= varlistH[0], limits={0, 1,0.00001}, proc = setChangeM_H
	SetVariable setvarRashba title="α\BR", pos={235,120},size={80,18},value= varlistH[1], limits={0, 50,0.01}, proc = setChangeRashba_H
	SetVariable setvarCorr title="2\Snd\Mordr corr", pos={235,160},size={120,18},value= varlistH[2], limits={0,300,0.5}, proc = setShiftCorr_H
	SetVariable setvarschiftE title="E shift", pos={235,200},size={100,18},value= varlistH[3], limits={-1,1,0.001}, proc = setShiftE_H
	
	SetVariable kramersPointDisplay title="Kramers point", pos={25,245}, size={135,20},frame=1, value=varlistH[4], disable=2
	SetVariable calculatedRashba title="calculated α\BR\M", pos={170,245}, size={122,20},frame=1, value=varlistH[5], disable=2
	
	SetVariable minimumBandE title="Band minimum [eV]", pos={25,285}, size={170,20},frame=1, value=varlistH[7], disable=2
	SetVariable minimumBandK title="Minimum position [A\S-1\M]", pos={205,278}, size={190,20},frame=1, value=varlistH[8], disable=2
	
end

function changeM_H(ctrlName, sliderValueM, event) : SliderControl
	string ctrlName
	variable sliderValueM
	variable event
	wave varlistH
	if(event %& 0x1)
		varlistH[0]=sliderValueM
		updateFitH()
	endif	
end

function changeRashba_H(ctrlName, sliderValueShiftK, event) : SliderControl
	string ctrlName
	variable sliderValueShiftK
	variable event
	wave varlistH
	if(event %& 0x1)
		varlistH[1]=sliderValueShiftK
		updateFitH()
	endif	
end

function shiftCorr_H(ctrlName, sliderValueShiftK, event) : SliderControl
	string ctrlName
	variable sliderValueShiftK
	variable event
	wave varlistH
	if(event %& 0x1)
		varlistH[2]=sliderValueShiftK
		updateFitH()
	endif	
end

function shiftE_H(ctrlName, sliderValueShiftE, event) : SliderControl
	string ctrlName
	variable sliderValueShiftE
	variable event
	wave varlistH
	if(event %& 0x1)
		varlistH[3]=sliderValueShiftE
		updateFitH()
	endif	
end


Function setChangeM_H(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave varlistH
	
	varlistH[0]= varNum
	Slider sliderM, value = varlistH[0]
	updateFitH()
end

Function setChangeRashba_H(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave varlistH
	
	varlistH[1]= varNum
	Slider sliderRashba, value = varlistH[1]
	updateFitH()
end

Function setShiftCorr_H(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave varlistH
	
	varlistH[2]= varNum
	Slider sliderCorr, value = varlistH[2]
	updateFitH()
end

Function setShiftE_H(ctrlName,varNum, varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave varlistH
	
	varlistH[3]= varNum
	Slider sliderSchiftE, value = varlistH[3]
	updateFitH()
end

function updateFitH()
	wave varlistH
	wave /D rasbhaFit1Hwave
	wave /D rasbhaFit2Hwave
	
	variable h=6.582119514e-16 //reduced Planck constant in eV s
	variable me=0.51099895e6 //electron mass in eV/c^2
	variable c=299792458 //speed of light
	variable angstrom =1e-10
	variable constants
	constants = h^2*c^2/me/angstrom^2
	
	//RSS
	//rasbhaFit1Hwave = varlistH[3] + (constants/2/varlistH[0]*x^2 + varlistH[1]*(1+varlistH[2]*x^2)*x)
	//rasbhaFit2Hwave = varlistH[3] + (constants/2/varlistH[0]*x^2 - varlistH[1]*(1+varlistH[2]*x^2)*x)
	
	//TSS
	rasbhaFit1Hwave = varlistH[3] + varlistH[1]*(1+varlistH[2]*x^2)*x
	rasbhaFit2Hwave = varlistH[3] - varlistH[1]*(1+varlistH[2]*x^2)*x
	
	rasbhaFit1Hwave = (rasbhaFit1Hwave[p]) > 0 ? Nan : rasbhaFit1Hwave
	rasbhaFit2Hwave = (rasbhaFit2Hwave[p]) > 0 ? Nan : rasbhaFit2Hwave
	
	varlistH[4] = rasbhaFit1Hwave(0)
	Duplicate /O/R=(-0.15,0.15) rasbhaFit1Hwave, visibleRangeFit1
	FindLevel/Q visibleRangeFit1, WaveMin(visibleRangeFit1)
	varlistH[5] = 2*(abs(WaveMin(visibleRangeFit1))-abs(visibleRangeFit1(0)))/abs(V_levelX)
	varlistH[7] = WaveMin(visibleRangeFit1)
	varlistH[8] = V_levelX
end