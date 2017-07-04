OSBYTE = &FFF4
OSWORD = &FFF1
OSWRCH = &FFEE
OSRDCH = &FFE0
OSCLI = &FFF7
EVNTV = &220

gridoffset1a = &70
gridoffset1b = &71
gridoffset2a = &72
gridoffset2b = &73
gridvpos = &74
intcount = &75
sprxpos1 = &76
sprxpos2 = &77

count = &78
count2 = &79
temp = &7A
ypostemp = &7B
yvel = &7C
zvel = &7D
tempzvel = &7E
sprnum = &7F
jumps=&60
dead=&61
time1=&62
time2=&63
printdata1=&64
printdata2=&65
joykey=&66
level=&67
levelcomplete=&68
arcadeortest=&69
level1test=&6A
level2test=&6B
level3test=&6C

debugedit=&6D

fasttimes=&400
highscores=&420

currentscore1=&50
currentscore2=&51
currentscore3=&52

gravity = &53
jump_strength = &54
max_speed = &55
accel = &56

sprwidth = 12
sprheight = 24

level1data = &2800

    ORG &1D00
	
.start	
	;edit keys return ascii codes
	LDA #4
	LDX #1
	JSR OSBYTE
	
	LDA #&7F
	STA &FE4E
	
	LDA #&D3
	STA &FE4E
	
	LDA #0
	STA debugedit

	
	LDA &4fe
	CMP #84
	BNE nottb
	LDA &4ff
	CMP #66
	BNE nottb
	JMP startmenu
	
.nottb

	;load debug default settings
	LDX #debugfile1 MOD 256
	LDY #debugfile1 DIV 256
	JSR OSCLI
	
	LDX #gridplotdatafile MOD 256
	LDY #gridplotdatafile DIV 256
	JSR OSCLI

	LDX #gridheightdatafile MOD 256
	LDY #gridheightdatafile DIV 256
	JSR OSCLI

	LDX #scrollmoddatafile MOD 256
	LDY #scrollmoddatafile DIV 256
	JSR OSCLI

	;setup defaults
	;LDA #5
	;STA gravity
	;LDA #&15
	;STA jump_strength
	;LDA #92
	;STA max_speed
	;LDA #4
	;STA accel


	LDA #0
	STA joykey
	
	LDA #1
	STA arcadeortest
	
	LDX #65
	STX level1test
	INX
	STX level2test
	INX
	STX level3test	

	JSR setuptimesandscores
	
	LDX #scoresfile1 MOD 256
	LDY #scoresfile1 DIV 256
	JSR OSCLI

.reloadpanel
	LDA #22		;set mode
	JSR OSWRCH
	LDA #2		;mode2
	JSR OSWRCH

	JSR definepalette

	LDX #file1 MOD 256
	LDY #file1 DIV 256
	JSR OSCLI

	LDA #header_text MOD 256
	STA printdata1
	LDA #header_text DIV 256
	STA printdata2
	JSR printtext

.startmenu
	JSR updatemenu
	LDA #84
	STA &4fe

	LDA #66
	STA &4ff
	
.domenu
	LDA #menuwindow MOD 256
	STA printdata1
	LDA #menuwindow DIV 256
	STA printdata2
	JSR printtext

	LDA #mainmenu1 MOD 256
	STA printdata1
	LDA #mainmenu1 DIV 256
	STA printdata2
	JSR printtext
	
	LDA #13
	LDX #4
	JSR OSBYTE
	
.redomenu
	
	LDA #mainmenu2 MOD 256
	STA printdata1
	LDA #mainmenu2 DIV 256
	STA printdata2
	JSR printtext

	JSR OSRDCH
	
	CMP #51
	BEQ startgame
	
	CMP #49
	BNE notkey1
	
	LDX #0
	STX joykey
	JSR updatemenu
	
.notkey1
	CMP #50
	BNE notkey2
	
	LDX #1
	STX joykey
	JSR updatemenu

.notkey2	
	CMP #52
	BNE notkey3
	
	JMP scorespage

.notkey3	
	CMP #53
	BNE notkey4

	JMP creditspage
	
.notkey4
	CMP #57
	BNE redomenu

	JMP debugpage
	
.startgame
	LDA #header_text MOD 256
	STA printdata1
	LDA #header_text DIV 256
	STA printdata2
	JSR printtext

	LDX #gameload MOD 256
	LDY #gameload DIV 256
	JMP OSCLI
	
	
.updatemenu
	LDX joykey
	CPX #0
	BNE keyupdate
	
	LDY #0
	STY keymenu+1

	LDY #131
	STY keymenu+3
	
	LDY #3
	STY joymenu+1

	LDY #128
	STY joymenu+3
	RTS
	
.keyupdate
	LDY #3
	STY keymenu+1

	LDY #128
	STY keymenu+3
	
	LDY #0
	STY joymenu+1

	LDY #131
	STY joymenu+3
	RTS

.setuptimesandscores
	LDA #&99
	LDX #0
.setfasttimes
	STA fasttimes,X
	INX
	CPX #28
	BNE setfasttimes
	
	LDA #0
	LDX #0
.sethighscores
	STA highscores,X
	INX
	CPX #15
	BNE sethighscores
	RTS
	
.scorespage
	JSR updatescores

	LDA #scorestext1 MOD 256
	STA printdata1
	LDA #scorestext1 DIV 256
	STA printdata2
	JSR printtext
	
	LDA #scorestext2 MOD 256
	STA printdata1
	LDA #scorestext2 DIV 256
	STA printdata2
	JSR printtext
	
	
	LDA #0
	STA count2

.scorespage2
	LDA #1
	PHA
	LDA #135
	PHA
	LDA #7
	PHA
	LDA #129
	PHA

	STA testlevelmod3
	STA testlevelmod2
	STA testlevelmod1
		
	LDA arcadeortest
	BEQ arcade
	
	PLA
	PLA
	PLA
	PLA
	
	LDA #7
	PHA
	LDA #129
	PHA
	LDA #1
	PHA
	LDA #135
	PHA

	LDA count2
	CMP #0
	BNE nottest1
	
	LDA #131
	PHA
	LDA #129
	PHA
	LDA #129
	PHA
	JMP updatetest
	
.nottest1
	CMP #1
	BNE nottest2
	
	LDA #129
	PHA
	LDA #131
	PHA
	LDA #129
	PHA
	JMP updatetest

.nottest2
	;CMP #2
	;BNE nottest3
	
	LDA #129
	PHA
	LDA #129
	PHA
	LDA #131
	PHA

.updatetest
	PLA
	STA testlevelmod3
	PLA
	STA testlevelmod2
	PLA
	STA testlevelmod1
		
.arcade
	PLA
	STA arcadetextmod4
	PLA
	STA arcadetextmod3
	PLA
	STA arcadetextmod2
	PLA
	STA arcadetextmod1
	
	LDA level1test
	STA arcadetextmod5

	LDA level2test
	STA arcadetextmod6
	
	LDA level3test
	STA arcadetextmod7
	
	LDA #scorestext3 MOD 256
	STA printdata1
	LDA #scorestext3 DIV 256
	STA printdata2
	JSR printtext

	JSR OSRDCH
	
	CMP #82
	BNE notscorekeyr
	
	JSR setuptimesandscores

	LDX #savescores MOD 256
	LDY #savescores DIV 256
	JSR OSCLI	
	
	JMP scorespage

.notscorekeyr	
	CMP #90
	BNE notscorekeyz

	LDX count2
	BEQ switchtoarcade
	
	DEX
	STX count2
	JMP notscorekeyz
	
.switchtoarcade
	LDX #0
	STX arcadeortest
	
.notscorekeyz
	
	CMP #88
	BNE notscorekeyx
	
	LDX arcadeortest
	BEQ switchtotest
	
	LDX count2
	CPX #2
	BEQ notscorekeyx
	
	INX
	STX count2
	BNE notscorekeyx
	
.switchtotest
	LDX #1
	STX arcadeortest
	
	LDX #0
	STX count2

.notscorekeyx

	CMP #&3a ; key *
	BNE notscorekeystar
	
	LDX arcadeortest
	BEQ notscorekeystar
	
	LDX count2
	
	PHA
	LDA level1test,X
	TAY
	INY
	CPY #79
	BNE notlooptest1
	
	LDY #65
	
.notlooptest1
	STY level1test,X
	PLA

.notscorekeystar	
	CMP #&2f ; /? key
	BNE notscorekeyslash

	LDX arcadeortest
	BEQ notscorekeyslash

	LDX count2
	
	PHA
	LDA level1test,X
	TAY
	DEY
	CPY #64
	BNE notlooptest2
	
	LDY #78
	
.notlooptest2
	STY level1test,X
	PLA
	
.notscorekeyslash
	CMP #13
	BEQ scorekeyenter

	JMP scorespage2

.scorekeyenter
	JMP reloadpanel

.creditspage
	LDA #creditstext MOD 256
	STA printdata1
	LDA #creditstext DIV 256
	STA printdata2
	JSR printtext
	JSR OSRDCH

	JMP startmenu


.debugpage
	LDA #debugtext1 MOD 256
	STA printdata1
	LDA #debugtext1 DIV 256
	STA printdata2
	JSR printtext

.debugpage2
	JSR updatedebug
	
	LDA #debugtext2 MOD 256
	STA printdata1
	LDA #debugtext2 DIV 256
	STA printdata2
	JSR printtext

	JSR OSRDCH

	CMP #90
	BNE notdebugkeyz

	LDX debugedit
	DEX
	CPX #255
	BNE notdebugwrap1
	
	LDX #3
	
.notdebugwrap1
	STX debugedit
	
.notdebugkeyz
	CMP #88
	BNE notdebugkeyx

	LDX debugedit
	INX
	CPX #4
	BNE notdebugwrap2
	
	LDX #0

.notdebugwrap2
	STX debugedit

.notdebugkeyx
	CMP #&3a ; key *
	BNE notdebugkeystar

	LDX debugedit
	CPX #0
	BNE notdebuggravity
	
	LDY gravity
	INY
	STY gravity
	
.notdebuggravity
	CPX #1
	BNE notdebugjump

	LDY jump_strength
	INY
	STY jump_strength
	
.notdebugjump
	CPX #2
	BNE notdebugspeed

	LDY max_speed
	INY
	STY max_speed

.notdebugspeed
	CPX #3
	BNE notdebugaccel1

	LDY accel
	INY
	STY accel

.notdebugaccel1
.notdebugkeystar
	CMP #&2f ; /? key
	BNE notdebugkeyslash

	LDX debugedit
	CPX #0
	BNE notdebuggravity2
	
	LDY gravity
	DEY
	STY gravity
	
.notdebuggravity2
	CPX #1
	BNE notdebugjump2

	LDY jump_strength
	DEY
	STY jump_strength
	
.notdebugjump2
	CPX #2
	BNE notdebugspeed2

	LDY max_speed
	DEY
	STY max_speed

.notdebugspeed2
	CPX #3
	BNE notdebugaccel2

	LDY accel
	DEY
	STY accel

.notdebugaccel2
.notdebugkeyslash

	CMP #13
	BNE godebugagain
	
	;save debug settings
	LDX #debugfile2 MOD 256
	LDY #debugfile2 DIV 256
	JSR OSCLI

	JMP startmenu

.godebugagain
	JMP debugpage2

.updatedebug
	LDA	gravity
	AND #&F0
	LSR A 
	LSR A
	LSR A
	LSR A
	TAX
	LDA hexchars,X
	STA debugtextmod3
	LDA	gravity
	AND #&f
	TAX
	LDA hexchars,X
	STA debugtextmod3+1
	
	LDA	jump_strength
	AND #&F0
	LSR A
	LSR A
	LSR A
	LSR A
	TAX
	LDA hexchars,X
	STA debugtextmod6
	LDA	jump_strength
	AND #&f
	TAX
	LDA hexchars,X
	STA debugtextmod6+1
	
	LDA	max_speed
	AND #&F0
	LSR A
	LSR A
	LSR A
	LSR A
	TAX
	LDA hexchars,X
	STA debugtextmod9
	LDA	max_speed
	AND #&f
	TAX
	LDA hexchars,X
	STA debugtextmod9+1
	
	LDA	accel
	AND #&F0
	LSR A
	LSR A
	LSR A
	LSR A
	TAX
	LDA hexchars,X
	STA debugtextmod12
	LDA	accel
	AND #&f
	TAX
	LDA hexchars,X
	STA debugtextmod12+1

	LDX #129
	LDY #7
	
	LDA debugedit
	BNE notedit0
	
	LDX #135
	LDY #0

.notedit0
	STX debugtextmod1
	STY debugtextmod2
	
	LDX #129
	LDY #7
	
	LDA debugedit
	CMP #1
	BNE notedit1
	
	LDX #135
	LDY #0

.notedit1
	STX debugtextmod4
	STY debugtextmod5
	
	LDX #129
	LDY #7

	LDA debugedit
	CMP #2
	BNE notedit2
	
	LDX #135
	LDY #0

.notedit2
	STX debugtextmod7
	STY debugtextmod8
	
	LDX #129
	LDY #7

	LDA debugedit
	CMP #3
	BNE notedit3
	
	LDX #135
	LDY #0

.notedit3
	STX debugtextmod10
	STY debugtextmod11

	RTS
	
.printtext
	LDY #0
.printchar
	LDA (printdata1),Y
	STY count
	CMP #&FF
	BEQ printdone
	
	JSR OSWRCH
	LDY count
	INY
	JMP printchar
	
.printdone
	RTS

.updatescores
	LDY #0
	LDX #0

.updatescores2
	LDA scoremods,X
	STA printdata1
	INX
	LDA scoremods,X
	STA printdata2
	INX

	LDA #(scorereturn-1) DIV 256
	PHA
	LDA #(scorereturn-1) MOD 256
	PHA
	
	INY
	INY
	
	LDA highscores,Y
	PHA
	DEY
	LDA highscores,Y
	PHA
	DEY
	LDA highscores,Y
	PHA

	INY
	INY
	INY
	
	JMP	scoretostr

.scorereturn
	CPX #10
	BNE updatescores2

	LDY #0

.updatetimes
	LDA fasttimes,Y
	STA time1
	LDA timemods,Y
	STA printdata1
	INY
	LDA fasttimes,Y
	STA time2
	LDA timemods,Y
	STA printdata2
	INY
	
	JSR timetostr

	CPY #28
	BNE updatetimes
	
	RTS	

	;accepts parameters on the stack pushed after the return address
	;so call it with JMP
.scoretostr
	STX count
	STY count2

	LDY #0
	
.doscoretostr
	PLA
	STA temp

	AND #&f0
	LSR A
	LSR A
	LSR A
	LSR A
	TAX
	LDA digits,X
	STA (printdata1),Y
	INY
	LDA temp
	AND #&f
	TAX
	LDA digits,X
	STA (printdata1),Y
	INY
	
	CPY #6
	BNE doscoretostr
	
	LDX count
	LDY count2
	RTS
	
.timetostr
	TYA
	PHA
	LDY #0
	
	LDA time1
	AND #&f0
	LSR A
	LSR A
	LSR A
	LSR A
	TAX
	LDA digits,X
	STA (printdata1),Y
	INY
	LDA time1
	AND #&f
	TAX
	LDA digits,X
	STA (printdata1),Y
	INY
	LDA #58
	STA (printdata1),Y
	INY
	LDA time2
	AND #&f0
	LSR A
	LSR A
	LSR A
	LSR A
	TAX
	LDA digits,X
	STA (printdata1),Y
	INY
	LDA time2
	AND #&f
	TAX
	LDA digits,X
	STA (printdata1),Y
	PLA
	TAY
	RTS

.definepalette	
	LDA #8
	STA pallogical
	
.defpal2
	LDX #paldata MOD 256
	LDY #paldata DIV 256
	LDA #&c
	JSR OSWORD	;write palette entry
	
	INC pallogical
	LDA pallogical
	CMP #16
	BNE	defpal2

	RTS
	
.digits EQUS "0123456789"

.paldata
.pallogical
	EQUB 8
.palphysical
	EQUB 7
	EQUB 0
	EQUB 0
	EQUB 0
	
.file1
	EQUS "*L. TSCR 3000"
	EQUB &D
	
.levelfile
	EQUS "*L. LEVEL"
.levelfnmod
	EQUS "A 2800"
	EQUB &D

.menuwindow
	EQUB 28,0,31,19,7
	EQUB &FF
	
.mainmenu1
	EQUB 23,1,0,0,0,0,0,0,0,0
	EQUB 17,128
	EQUB 12
	EQUB &FF
	
.mainmenu2
	EQUB 17,3
	EQUB 31,6,3
	EQUS "OPTIONS"
.keymenu
	EQUB 17,3
	EQUB 17,128
	EQUB 31,1,6
	EQUS " 1 : Keyboard    "
.joymenu
	EQUB 17,3
	EQUB 17,128
	EQUB 31,1,8
	EQUS " 2 : Joystick    "
	EQUB 17,3
	EQUB 17,128
	EQUB 31,2,10
	EQUS "3 : Play game"
	EQUB 31,2,12
	EQUS "4 : Game/Scores"
	EQUB 31,2,14
	EQUS "5 : Credits"
	EQUB &FF


.creditstext
	EQUB 12
	EQUB 31,1,3
	EQUB 17,4
	EQUS ".ORIGINAL CONCEPT."
	EQUB 31,3,5
	EQUB 17,1
	EQUS "SHAUN SOUTHERN"
	EQUB 31,3,6
	EQUB 17,2
	EQUS "ANDREW MORRIS"
	EQUB 31,5,8
	EQUB 17,4
	EQUS ".SPECTRUM."
	EQUB 31,4,9
	EQUS ".CONVERSION."
	EQUB 31,4,11
	EQUB 17,1
	EQUS "PETE HARRAP"
	EQUB 31,1,12
	EQUB 17,2
	EQUS "SHAUN HOLLINGWORTH"
	EQUB 31,4,13
	EQUB 17,3
	EQUS "CHRIS KERRY"
	EQUB 31,4,14
	EQUB 17,5
	EQUS "STEVE KERRY"
	EQUB 31,4,15
	EQUB 17,6
	EQUS "TERRY LLOYD"
	EQUB 31,4,17
	EQUB 17,4
	EQUS ".BBC MICRO."
	EQUB 31,5,18
	EQUS ".VERSION."
	EQUB 31,4,20
	EQUB 17,1
	EQUS "DARREN COLES"
	EQUB &FF

.timemods
	EQUW timeamod
	EQUW timebmod
	EQUW timecmod
	EQUW timedmod
	EQUW timeemod
	EQUW timefmod
	EQUW timegmod
	EQUW timehmod
	EQUW timeimod
	EQUW timejmod
	EQUW timekmod
	EQUW timelmod
	EQUW timemmod
	EQUW timenmod


.scorestext1
	EQUB 28,1,29,18,2
	EQUB 17,7	;colour 3
	EQUB 17,129	;bg colour white
	EQUB 12
	EQUB 31,4,1
	EQUS "BEST TIMES"
	EQUB 31,1,3
	EQUS "A."
.timeamod	EQUS "!!.!!  H."
.timehmod	EQUS "!!.!! "
	EQUB 31,1,4
	EQUS "B."
.timebmod	EQUS"!!.!!  I."
.timeimod	EQUS "!!.!! "
	EQUB 31,1,5
	EQUS "C."
.timecmod	EQUS "!!.!!  J."
.timejmod	EQUS "!!.!! "
	EQUB 31,1,6
	EQUS "D."
.timedmod	EQUS "!!.!!  K."
.timekmod	EQUS "!!.!! "
	EQUB 31,1,7
	EQUS "E."
.timeemod	EQUS "!!.!!  L."
.timelmod	EQUS "!!.!! "
	EQUB 31,1,8
	EQUS "F."
.timefmod	EQUS"!!.!!  M."
.timemmod	EQUS "!!.!! "
	EQUB 31,1,9
	EQUS "G."
.timegmod	EQUS "!!.!!  N."
.timenmod	EQUS "!!.!! "
	EQUB &FF

.scoremods
	EQUW score1mod
	EQUW score2mod
	EQUW score3mod
	EQUW score4mod
	EQUW score5mod

.scorestext2
	EQUB 31,4,12
	EQUS "TOP SCORES"
	EQUB 31,5,14
	EQUS "1."
.score1mod EQUS "000000"
	EQUB 31,5,15
	EQUS "2."
.score2mod EQUS "000000"
	EQUB 31,5,16
	EQUS "3."
.score3mod EQUS "000000"
	EQUB 31,5,17
	EQUS "4."
.score4mod EQUS "000000"
	EQUB 31,5,18
	EQUS "5."
.score5mod EQUS "000000"
	EQUB &FF

.scorestext3
	EQUB 17
.arcadetextmod1
	EQUB 0
	EQUB 17
.arcadetextmod2
	EQUB 0
	EQUB 31,1,23
	EQUS " PLAY "
	EQUB 31,1,24
	EQUS "ARCADE"

	EQUB 17
.arcadetextmod3
	EQUB 0
	EQUB 17
.arcadetextmod4
	EQUB 0
	EQUB 31,9,23
	EQUS "3 COURSE"
	EQUB 31,9,24
	EQUS "  TEST  "

	EQUB 17,7,17,129
	EQUB 31,10,26
	
	EQUB 17
.testlevelmod1
	EQUB 129
.arcadetextmod5
	EQUS "0"

	EQUB 31,12,26
	EQUB 17
.testlevelmod2
	EQUB 129
.arcadetextmod6
	EQUS "0"

	EQUB 31,14,26
	EQUB 17
.testlevelmod3
	EQUB 129

.arcadetextmod7
	EQUS "0"
	
	EQUB &FF

.header_text
	EQUB 26
	EQUB 31,1,1
	EQUB 17,3,17,132
	EQUB "SC: 000000"
	EQUB 31,1,3
	EQUB 17,0,17,134
	EQUB "LEVEL:  "
	EQUB 31,1,5
	EQUB 17,7,17,133
	EQUB "JUMP:  "
	EQUB 17,3,17,132
	EQUB 31,14,1
	EQUB "00:00"
	EQUB 31,14,3
	EQUB "00:00"
	EQUB 31,14,5
	EQUB "00:00"
	EQUB &FF

.debugtext1
	EQUB 12
	EQUB 28,1,21,18,9
	EQUB 17,7	;colour 3
	EQUB 17,129	;bg colour white
	EQUB 12
	EQUB 31,3,3
	EQUS "GRAVITY &"
	EQUB 31,3,5
	EQUS "JUMP &"
	EQUB 31,3,7
	EQUS "SPEED &"
	EQUB 31,3,9
	EQUS "ACCEL &"
	EQUB &FF

.debugtext2
	EQUB 17
.debugtextmod1
	EQUB 0
	EQUB 17
.debugtextmod2
	EQUB 0
	EQUB 31,12,3
.debugtextmod3
	EQUS "xx"
	EQUB 17
.debugtextmod4
	EQUB 0
	EQUB 17
.debugtextmod5
	EQUB 0
	EQUB 31,9,5
.debugtextmod6
	EQUS "xx"
	EQUB 17
.debugtextmod7
	EQUB 0
	EQUB 17
.debugtextmod8
	EQUB 0
	EQUB 31,10,7
.debugtextmod9
	EQUS "xx"
	EQUB 17
.debugtextmod10
	EQUB 0
	EQUB 17
.debugtextmod11
	EQUB 0
	EQUB 31,10,9
.debugtextmod12
	EQUS "xx"
	EQUB &FF
	
.hexchars
	EQUS "0123456789ABCDEF"
	
.gameload
	EQUS "*/ TMAIN"
	EQUB &D

.scoresfile1
	EQUS "*L.SCORES 400"
	EQUB &D

.debugfile1
	EQUS "*L.DEBUG 53"
	EQUB &D

.debugfile2
	EQUS "*SAVE DEBUG 53+4"
	EQUB &D

.scrollmoddatafile
	EQUS "*L.SCRLMOD 500"
	EQUB &D

.gridplotdatafile
	EQUS "*L.GPLOT B00"
	EQUB &D

.gridheightdatafile
	EQUS "*L.GHEIGHT C00"
	EQUB &D

.savescores
	EQUS "*SAVE SCORES 400+30"
	EQUB &D


.end

SAVE "..\trailmenu.bin", start, end
