OSBYTE = &FFF4
OSWORD = &FFF1
OSWRCH = &FFEE
OSRDCH = &FFE0
OSCLI = &FFF7

key_left = 1
key_right = 2
key_up = 4
key_down = 8
key_jump = 16

gridoffset1a = &70
gridoffset1b = &71
gridvpos1 = &72
gridvpos2 = &73
enableraster = &74
intrunning = &75
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
intnum=&6D
reverse=&6E
keys=&6F

oldframe = &5e
soundoffset = &5f

fasttimes=&400
highscores=&420

currentscore1=&50
currentscore2=&51
currentscore3=&52

gravity = &53
jump_strength = &54
max_speed = &55
accel  = &56


fontoffset = &57
fontbits = &58
scroffset = &59
screenaddr = &5a
screenaddr2 = &5b
joylr = &5c
joyud = &5d

sprwidth = 12
sprheight = 24

levelname = &2800
leveltime = &2814
level1data = &2816

scrollmodifiers = &500
gridplotdata = &B00
gridheights = &C00

    ORG &1100
	
.start	
	
	JSR shiftball

.startgame
	LDA #0
	STA level
	STA currentscore1
	STA currentscore2
	STA currentscore3
	STA enableraster

	SEI

	LDA #&7F
	STA &FE4E
	
	LDA #&83
	STA &FE4E

	LDA #&7F
	STA &FE6E
	
	LDA #&c0
	STA &FE6E

	;Set user timer 2 to countdown mode
	LDA #0
	STA &FE6B
	
	LDA &204
	STA oldint+1
	LDA &205
	STA oldint+2
	
	LDA #intv MOD 256
	STA &204
	LDA #intv DIV 256
	STA &205

	CLI
		
.nextlevel
	LDA #0
	STA reverse

	CLC

	LDA level
	TAX
	ADC #65

	LDY arcadeortest
	BEQ arcadelevel
	
	LDA level1test,X
		
.arcadelevel

	STA levelfnmod
	STA leveltextmod
	STA getreadyzonemod
	
	LDA #getreadytext1 MOD 256
	STA printdata1
	LDA #getreadytext1 DIV 256
	STA printdata2
	JSR printtext

	LDA #getreadyarcadetext MOD 256
	STA printdata1
	LDA #getreadyarcadetext DIV 256
	STA printdata2
	
	LDA arcadeortest
	BEQ arcadegetready

	LDA #getreadytesttext MOD 256
	STA printdata1
	LDA #getreadytesttext DIV 256
	STA printdata2

.arcadegetready
	JSR printtext

	LDA #getreadytext2 MOD 256
	STA printdata1
	LDA #getreadytext2 DIV 256
	STA printdata2
	JSR printtext


	LDX #levelfile MOD 256
	LDY #levelfile DIV 256
	JSR OSCLI

	JSR	convertgrid

	
	LDX #gridplotdatafile MOD 256
	LDY #gridplotdatafile DIV 256
	JSR OSCLI


	LDX #gridheightdatafile MOD 256
	LDY #gridheightdatafile DIV 256
	JSR OSCLI

	LDA joykey
	BEQ nojoy

.waitjoy
	LDA &fec0
	AND #128
	BNE waitjoy
	
	JSR dochan0		;initiate joystick read chan0
	
.nojoy
	LDA #100
	JSR delay
	
	LDA #gamesetup MOD 256
	STA printdata1
	LDA #gamesetup DIV 256
	STA printdata2
	JSR printtext

	LDA #leveltext MOD 256
	STA printdata1
	LDA #leveltext DIV 256
	STA printdata2
	JSR printtext

	LDA #0
	STA gridvpos1
	STA yvel
	STA zvel
	STA dead
	STA levelcomplete

	LDX leveltime+1
	LDY	leveltime
	
	LDA arcadeortest
	BEQ arcadetimesetup

	LDY #0
	
.arcadetimesetup
	STY time1
	STX time2
		
	LDA #4
	STA jumps
		
	LDA #level1data MOD 256
	STA gridoffset1a
	LDA #level1data DIV 256
	STA gridoffset1b
		
	LDA #1
	STA enableraster

	JSR drawall

	LDA #lnamesetuptext MOD 256
	STA printdata1
	LDA #lnamesetuptext DIV 256
	STA printdata2
	JSR printtext
	
	LDA #levelname MOD 256
	STA printdata1
	
	LDA #levelname DIV 256
	STA printdata2
	
	LDX #20
	JSR printchars
	
	LDA	#&28
	STA sprxpos1
	LDA #1
	STA sprxpos2
	
	LDA #50
	STA ypostemp

	JSR drawsprite2
	
	LDA &240
	STA oldframe	
	
.mainloop
	JSR waitframe
	JSR	printtime
	JSR printjumps
	JSR printscore
	JSR waitints
	
	JSR drawsprite2	;undraw

	JSR handledeath
	
	LDA dead
	BNE noscroll

	;check escape key to quit
	LDA #&79
	LDX #&f0	;esc key
	JSR OSBYTE	
	CPX	#0
	BMI	quitgame

	LDA #0
	STA keys
	
	LDA joykey
	BNE doreadjoy
	LDA joykey
	BNE doreadjoy
	
	JSR readkeys
	JMP inputdone
	
.doreadjoy
	JSR readjoy

.inputdone

	JSR processinput
	JSR	applyyvelocity

	JSR calcscrollspeed		
	BEQ nozvel

	TAX
	
	LDY sprnum
.calcnextspr
	INY
	CPY #14
	BNE nosprloop
	LDY #0
.nosprloop
	DEX
	BNE calcnextspr
	STY sprnum

.nozvel

	LDX tempzvel
	BEQ noscroll
	
.scrollloop
	STX tempzvel

	JSR calculatescore
	
	JSR scroll

	LDX tempzvel
	DEX
	BNE scrollloop

.noscroll
	JSR checkcollision
		
	JSR drawsprite2	;draw new

	LDA levelcomplete
	BNE gonextlevel
	
	LDA arcadeortest
	BNE mainloop
	
	LDA time1
	BNE	mainloop
	
	LDA time2
	BNE mainloop

.quitgame
	LDA #0
	STA enableraster
	
	LDA #gameovertext MOD 256
	STA printdata1
	LDA #gameovertext DIV 256
	STA printdata2
	JSR printtext
	
	JSR updatetopscores

.domenu
	LDA #100
	JSR delay

	SEI
	LDA oldint+1
	STA &204
	LDA oldint+2
	STA &205
	
	LDA &202
	STA oldbrk

	LDA &203
	STA oldbrk+1
	
	LDA #saveerrorhandler MOD 256
	STA &202
	LDA #saveerrorhandler DIV 256
	STA &203

	LDA #&40
	STA &FE6B
	
	CLI
	
	LDX #savescores MOD 256
	LDY #savescores DIV 256
	JSR OSCLI
	
	SEI
	LDA oldbrk
	STA &202
	LDA oldbrk+1
	STA &203

	CLI
	
.loadmenu
	LDX #menufile MOD 256
	LDY #menufile DIV 256
	JMP OSCLI

.saveerrorhandler
	;ignore errors during high score saving and continue 
	PLA ;pull old status and return address
	PLA
	PLA
	JMP loadmenu
	
.gonextlevel

	LDA #0
	STA enableraster

	LDX level

	LDY arcadeortest
	BEQ gonextlevel2

	LDA level1test,X
	SEC
	SBC #65

	ASL A
	TAY
	LDA fasttimes,Y
	CMP time1
	BEQ checkfastmillisecs
	BCS isfasttime
	BCC notfasttime

.checkfastmillisecs	
	INY
	LDA fasttimes,Y
	DEY
	CMP time2
	BCC notfasttime

.isfasttime
	LDA time1
	STA fasttimes,Y
	INY
	LDA time2
	STA fasttimes,Y
	
.notfasttime
	
	CPX #2
	BNE gonextlevel2

	JMP quitgame
	
.gonextlevel2
	INX
	STX level
	
	CPX #15
	BNE notgamecomplete
	
	LDX #0
	STX level
	
	LDA #gamecompletetext MOD 256
	STA printdata1
	LDA #gamecompletetext DIV 256
	STA printdata2
	JSR printtext
	
	LDA #200
	JSR delay
	
.notgamecomplete
	JMP nextlevel
	
	RTS

.waitframe
	;lda #00
	;sta &fe21

	LDA oldframe
.waitvbl2
	CMP &240
	BEQ waitvbl2
	LDA &240
	STA oldframe
	;lda #06
	;sta &fe21
	RTS
	
.waitints
	;lda #02
	;sta &fe21
	LDA intrunning
	BNE waitints
	;lda #04
	;sta &fe21
	RTS

	
.delay
	TAX
.delay2
	LDA &240
.waitvbl3
	CMP &240
	BEQ waitvbl3
	DEX
	BNE delay2
	RTS
	
.calculatescore

	LDA ypostemp
	BNE noscore

	SED
	CLC
	LDA currentscore3
	ADC #1
	STA currentscore3
	
	LDA currentscore2
	ADC #0
	STA currentscore2
	
	LDA currentscore1
	ADC #0
	STA currentscore1

	CLD
.noscore
	RTS

.updatetopscores
	LDX #0
.updatetopscores2
	
	STX count2
	LDA highscores,X
	CMP currentscore1
    BEQ comparenextbyte1
	BCC ishigher
	BCS nothigher

.comparenextbyte1
	INX
	LDA highscores,X
	CMP currentscore2
    BEQ comparenextbyte2
	BCC ishigher
	BCS nothigher

.comparenextbyte2
	INX
	LDA highscores,X
	CMP currentscore3
    BEQ comparenextbyte2
	BCC ishigher
	BCS nothigher
	
.ishigher
	LDX count2
	
	LDY #15
	LDX #12
.shiftscores
	CPX count2
	BEQ shiftdone

	DEX
	DEY
	LDA highscores,X
	STA highscores,Y
	
	JMP shiftscores
	
.shiftdone	
	LDA currentscore1
	STA highscores,X
	INX
	LDA currentscore2
	STA highscores,X
	INX
	LDA currentscore3
	STA highscores,X
	
	RTS
	
.nothigher
	LDX count2
	INX
	INX
	INX
	CPX #15
	BNE updatetopscores2
	RTS
	
.handledeath
	LDA dead
	BEQ notdead
	
	LDA ypostemp
	CMP #256-26
	BEQ falldone

	SEC
	SBC #2
	AND #254

	STA ypostemp

.falldone
	DEC dead
	BNE notdead

	LDA jump_strength
	STA yvel
	
	LDA #50
	STA ypostemp
	
	LDA max_speed
	LSR A
	STA zvel

	LDA #0
	STA reverse

.notdead
	RTS
	
.calcscrollspeed
	LDA zvel
	AND #&f
	ASL A
	ASL A
	ASL A
	ASL A
	STA temp
	
	LDA &240
	AND #15
	ORA temp
	TAY
	LDA scrollmodifiers,Y
	STA temp
	
	LDA zvel
	
	LSR A
	LSR A
	LSR A
	LSR A
	CLC
	ADC temp
	STA tempzvel	
	RTS
	
.applyyvelocity
	LDA	yvel
	CMP #0
	BMI negativevel
	
	LSR A
	CLC
	ADC ypostemp
	STA ypostemp

	BMI	negativey
	
	LDA	yvel
	SEC
	SBC gravity
	STA yvel
	RTS

.negativevel
	LDA #0
	SEC
	SBC yvel
	
	LSR A
	STA temp
	SEC
	LDA ypostemp
	SBC temp
	STA ypostemp

	BMI	negativey
	
	LDA	yvel
	SEC
	SBC gravity
	STA yvel
	RTS

.negativey
	LDA #0
	STA ypostemp
	
	;LDA yvel
	;EOR #&ff
	;LSR A
	STA yvel
	RTS
 
 
;1) Fully inside 1 cell considered
;2) Near right edge of rightmost cell - current cell considered only
;3) Near right edge of other cell - current cell and next cell considered - both empty - death
;4) Near right edge of other cell - current cell and next cell considered - current empty - next cell not empty - fall to the left
;5) Near right edge of other cell - current cell and next cell considered - current cell not empty - next cell empty - fall to the right
;6) Near right edge of other cell - current cell and next cell considered - current cell not empty - next cell not empty - nothing
;
;7) Near left edge of leftmost cell - current cell considered only
;8) Near left edge of other cell - current cell and prev cell considered - both empty - death
;9) Near left edge of other cell - current cell and prev cell considered - current empty - prev cell not empty - fall to the right
;10) Near left edge of other cell - current cell and prev cell considered - current cell not empty - prev cell empty - fall to the left
;11) Near left edge of other cell - current cell and prev cell considered - current cell not empty - prev cell not empty - nothing
 
.checkcollision
  
	LDA ypostemp
	BEQ onground

	RTS
	
.onground
	LDA sprxpos1
	LSR A
	LSR A
	LSR A
	TAX
	LDA sprxpos2
	ASL A
	ASL A
	ASL A
	ASL A
	ASL A
	STA count
	TXA
	ORA count
	
	;find mid point of ball
	CLC
	ADC #3
	
	LDY #0
	
	LDX gridvpos1
	
.notnextrow	
	CMP #&11
	BMI definiteposfound
	
	CMP #&14
	BMI RHSdangerzonefound
	
	INY
	
	CMP #&17
	BMI LHSdangerzonefound

	CMP #&1e
	BMI definiteposfound

	CMP #&21
	BMI RHSdangerzonefound
	
	INY
	
	CMP #&24
	BMI LHSdangerzonefound

	CMP #&2d
	BMI definiteposfound

	CMP #&30
	BMI RHSdangerzonefound
	
	INY
	
	CMP #&33
	BMI LHSdangerzonefound

	CMP #&39
	BMI definiteposfound

	CMP #&3c
	BMI RHSdangerzonefound
	
	INY
	
	CMP #&40
	BMI LHSdangerzonefound

	JMP definiteposfound
	
	;&00 - &13 = position 1, &11-13 is danger zone
	;&14 - &20 = position 2,  &14-16 and &1e-&20 is danger zone, 
	;&21 - &2f = position 3,  &21-23 and &2d-&2f is danger zone, 
	;&30 - &3b = position 4,  &30-32 and &39-&3b is danger zone, 
	;&3c - &50 = position 5,  &3c-3f is danger zone, 

.getboth
	LDA (gridoffset1a),Y
	AND #&7
	EOR #&7
	TAX
	
	INY
	LDA (gridoffset1a),Y
	AND #&7
	EOR #&7
	RTS

.definiteposfound
	LDA (gridoffset1a),Y
	AND #&7
	EOR #&7
	
	STY temp
	
	CMP #0
	BNE nothole
	
	JMP prochole
	
.LHSdangerzonefound
	STY temp
	DEY
	JSR getboth
	
	CMP #0
	BNE nothole
	
	CPX #0
	BEQ prochole ; both panels empty

	;right panel empty - ball moves slightly to the right
	CLC
	LDA sprxpos1
	ADC #24 ;- 3 pixels
	STA sprxpos1
	
	LDA sprxpos2
	ADC #0
	STA sprxpos2
	JMP prochole
	
.RHSdangerzonefound
	STY temp
	JSR getboth

	CPX #0
	BNE nothole

	CMP #0
	BEQ prochole ; both panels empty
	
	;left panel empty - ball moves slightly to the left
	SEC
	LDA sprxpos1
	SBC #24 ;- 3 pixels
	STA sprxpos1
	
	LDA sprxpos2
	SBC #0
	STA sprxpos2
	
.prochole
	LDX #75
	STX dead
	JSR fallsound
	JMP colldone
	
.nothole
	LDY temp
	LDA (gridoffset1a),Y
	AND #&7
	EOR #&7

	CMP #2
	BNE notjump

	JSR jumpsound
	LDX jump_strength
	STX yvel

.notjump
	CMP #1
	BNE notslow
	
	LDX zvel
	CPX #8
	BMI notslow
	
	LDX #8
	STX zvel
		
.notslow
	CMP #5
	BNE notturbo
	
	LDX max_speed
	STX zvel
	
.notturbo	   
	CMP #7
	BEQ isreverse
	CMP #6
	BNE notreverse
.isreverse
	LDX #1
	STX reverse
	
.notreverse
	CMP #3
	BEQ cancelrev
	CMP #4
	BEQ cancelrev
	BNE colldone

.cancelrev
	LDX #0
	STX reverse

.midair
.colldone
	RTS

;0 = hole
;1 = slowdown
;2 = jump
;3
;4
;5 - turbo	
;6 - reverse

.printjumps

	LDA #&40
	STA screenaddr
	LDA #&3D
	STA screenaddr+1
	
	LDA #whiteonmagenta MOD 256
	STA colourtblmod+1

	LDA #whiteonmagenta DIV 256
	STA colourtblmod+2

	LDA jumps
	JSR fastprint2

	RTS
	
.readjoy
	lda joylr
	ora joyud
	STA keys

	lda #128
    ldx #0
	ldy #0
    jsr OSBYTE
    cpx #$01            ; If X>=1 then set the carry flag.
	BCC nofire

	LDA keys
	ORA #key_jump
	STA keys
.nofire
	
	RTS
	
	
	
.scanjoy
	lda &fec0
	tax
	and #128
	bne skipadc

	txa
	and #3
	beq chan0
	
	cmp #1
	beq chan1
	
	bne dochan0
	
.chan0
	LDA #0
	STA joylr
	
	txa
	and #48 
	beq read_joystick_low
	
	eor #48
	beq read_joystick_high

.dochan1	
	lda #1
	sta &fec0	;initiate chan 1 read
.skipadc
	rts

.chan1
	LDA #0
	STA joyud
	txa
	and #48 
	beq read_joystick_low2
	
	eor #48
	beq read_joystick_high2

.dochan0
	lda #0
	sta &fec0	;initiate chan 1 read
	rts

.read_joystick_low
	LDA #key_right
	STA joylr
	JMP dochan1
	
.read_joystick_high
	LDA #key_left
	STA joylr
	JMP dochan1
	
.read_joystick_low2
	LDA #key_down
	STA joyud
	JMP dochan0
	
.read_joystick_high2
	LDA #key_up
	STA joyud
	JMP dochan0
	
.readkeys
	LDA #&79
	LDX #&e1	;Z key
	JSR OSBYTE
	
	CPX	#0
	BPL	nokeyL
	
	LDA keys
	ORA #key_left
	STA keys

.nokeyL

	LDA #&79
	LDX #&c2	;X key
	JSR OSBYTE
	
	CPX	#0
	BPL	nokeyR

	LDA keys
	ORA #key_right
	STA keys

.nokeyR
	LDA #&79
	LDX #&c9	;return key
	JSR OSBYTE
	
	CPX	#0
	BPL	nokeyJUMP

	LDA keys
	ORA #key_jump
	STA keys
	
.nokeyJUMP

	LDA #&79
	LDX #&e8	;/ key
	JSR OSBYTE
	
	CPX	#0
	BPL	nokeyD

	LDA keys
	ORA #key_down
	STA keys

.nokeyD
	LDA #&79
	LDX #&c8	;: key
	JSR OSBYTE
	
	CPX	#0
	BPL	nokeyU

	LDA keys
	ORA #key_up
	STA keys

.nokeyU
	RTS
	
.processinput

	LDX #key_left
	LDY #key_right

	LDA reverse
	BEQ noreverse

	LDX #key_right
	LDY #key_left
	
.noreverse	
	TXA
	AND keys
	BEQ	noleft
	
	LDA sprxpos2
	BNE notminx
	
	LDA sprxpos1
	CMP #64
	BCS notminx
	
	JMP noleft

.notminx
	;move left
	LDA &240
	AND #7
	BEQ noleft
	
	SEC
	LDA sprxpos1
	SBC #8
	STA sprxpos1
	
	LDA sprxpos2
	SBC #0
	STA sprxpos2
	
.noleft

	TYA
	AND keys
	BEQ	noright
	
	LDA &240
	AND #7
	BEQ noright

	LDA sprxpos2
	CMP #2
	BNE notmaxx
	
	LDA sprxpos1
	CMP #&18
	BCC notmaxx
	
	JMP noright
	
.notmaxx
	;move right
	CLC
	LDA sprxpos1
	ADC #8
	STA sprxpos1
	
	LDA sprxpos2
	ADC #0
	STA sprxpos2

.noright

	LDA keys
	AND #key_down
	BEQ	nodown

	LDA	zvel
	SEC
	SBC accel
	BCC isnegative
	CMP #8
	BCS notundermin

.isnegative
	LDA #8
	
.notundermin
	STA zvel
	
.nodown

	LDA keys
	AND #key_up
	BEQ	noup

	LDA	zvel
	CLC
	ADC accel
	CMP max_speed
	BCC notovermax
	
	LDA max_speed
.notovermax
	STA zvel

.noup
	LDA keys
	AND	#key_jump
	BEQ nojump

	LDA	ypostemp
	BNE nojump

	LDX arcadeortest
	BNE infyjumps
	
	LDX jumps
	BEQ nojump
	
	DEX
	STX jumps


.infyjumps
	JSR jumpsound
	LDA jump_strength
	STA yvel
	
.nojump
	RTS

.jumpsound
	LDX #(jumpsounddata-sounddata)
	STX soundoffset

	RTS
	
.fallsound
	LDA #(fallsounddata-sounddata)
	STA soundoffset
	RTS

.updatesound
	TXA
	PHA
	TYA
	PHA
	LDX soundoffset
	LDA sounddata,X
	BEQ soundfinished
	INX
	JSR writetosound
	LDA sounddata,X
	INX
	JSR writetosound
	LDA sounddata,X
	INX
	JSR writetosound
	TXA
	
.soundfinished
	STA soundoffset
	PLA
	TAY
	PLA
	TAX
	RTS
	
.writetosound
	SEI
	LDY #&FF
	STY &FE43	;Data direction register A all pins output
	STA &FE41	;Write sound output data
	LDA #0
	STA &FE40	;sound chip write pin low
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	LDA #8
	STA &FE40	;sound chip write pin high
	CLI
	RTS
 	
.scroll
	
	CLC
	LDA gridvpos1
	ADC #14
	CMP #16*14
	BNE noresetgridvpos
		
	CLC
	LDA gridoffset1a
	ADC #5
	STA gridoffset1a

	LDA gridoffset1b
	ADC #0
	STA gridoffset1b

	LDA #0
.noresetgridvpos
	STA gridvpos1

	RTS


.drawall
	LDA #gridplotdata MOD 256
	STA printdata1
	LDA #gridplotdata DIV 256
	STA printdata2
	JSR printtext

	RTS


.convertgrid
	LDA #level1data MOD 256
	STA gridoffset1a
	LDA #level1data DIV 256
	STA gridoffset1b

	LDY #0
	LDX #&10
	
.processgrid
	LDA (gridoffset1a),Y
	CMP #&FF
	beq allprocesssed
	
	CMP #'0'
	BEQ found0
	CMP #'1'
	BEQ found1
	CMP #'2'
	BEQ found2
	CMP #'3'
	BEQ found3
	CMP #'4'
	BEQ found4
	CMP #'5'
	BEQ found5
	CMP #'6'
	BEQ found6
	CMP #'7'
	BEQ found7

.badgrid
	BNE badgrid
	
.found0
	TXA
	ORA #&7
	STA	(gridoffset1a),Y
	JMP more
	
.found1
	TXA
	ORA #&5
	STA	(gridoffset1a),Y
	JMP more

.found2
	TXA
	ORA #&6
	STA	(gridoffset1a),Y
	JMP more
	
.found3
	TXA
	ORA #&4
	STA	(gridoffset1a),Y
	JMP more

.found4
	TXA
	ORA #&3
	STA	(gridoffset1a),Y
	JMP more
	
.found5
	TXA
	ORA #&2
	STA	(gridoffset1a),Y
	JMP more

.found6
	TXA
	ORA #&1
	STA	(gridoffset1a),Y
	JMP more

.found7
	TXA
	;ORA #&0
	STA	(gridoffset1a),Y
	
.more
	TXA
	CLC
	ADC #&10
	CMP #&60
	BNE notresetcolour

	LDA #&10
	
.notresetcolour
	TAX
	
	INY
	CPY #0
	BNE processgrid
	
	INC gridoffset1b
	JMP processgrid

.allprocesssed
	RTS
	
.precalc
	CLC						;2
	TYA						;2
	AND #&f8				;2
	TAX						;2
	
	LDA startdata3,X		;4+
	ADC sprxpos1			;3
	STA &80					;3
	
	LDA startdata4,X		;4+
	ADC sprxpos2			;3
	STA &81					;3
	
	LDA	&80					;2
	ADC #8					;2
	STA &82					;2
	LDA &81					;2
	ADC #0					;2
	STA &83					;2
	
	LDA	&82					;2
	ADC #8					;2
	STA &84					;2
	LDA &83					;2
	ADC #0					;2
	STA &85					;2
	
	LDA	&84					;2
	ADC #8					;2
	STA &86					;2
	LDA &85					;2
	ADC #0					;2
	STA &87					;2

	LDA	&84					;2
	ADC #8					;2
	STA &86					;2
	LDA &85					;2
	ADC #0					;2
	STA &87					;2

	LDA	&86					;2
	ADC #8					;2
	STA &88					;2
	LDA &87					;2
	ADC #0					;2
	STA &89					;2

	LDA	&88					;2
	ADC #8					;2
	STA &8a					;2
	LDA &89					;2
	ADC #0					;2
	STA &8b					;2

	;CLC - not needed
	LDX #0					;2
	
	TYA						;2
	AND #7 ;position within the block	;2
	TAY						;2
	RTS

.drawsprite2

	LDA #185
	SEC
	SBC ypostemp
	TAY

	SEI
	
	LDA #sprdata MOD 256
	STA &80
	LDA #sprdata DIV 256
	STA &81
	
	LDX sprnum
	BEQ calcspr2

	CLC
.calcspr
	LDA &80
	ADC #144
	STA &80
	LDA &81
	ADC #0
	STA &81
	DEX
	BNE calcspr

.calcspr2
	LDA &80
	STA spr1+1
	STA spr2+1
	STA spr3+1
	STA spr4+1
	STA spr5+1
	STA spr6+1

	LDA &81
	STA spr1+2
	STA spr2+2
	STA spr3+2
	STA spr4+2
	STA spr5+2
	STA spr6+2
	
	JSR	precalc
	;108
	
	;FOR n, 1, sprheight
.nextrow1
	LDA (&80),Y				;5+
	;STA copydata,X
.spr1
	EOR sprdata,X			;4+
	STA (&80),Y				;6
	
	INX						;2
	
	LDA (&82),Y				;5+
	;STA copydata,X
.spr2
	EOR sprdata,X			;4+
	STA (&82),Y				;6
	
	INX						;2
	
	LDA (&84),Y				;5+
	;STA copydata,X
.spr3
	EOR sprdata,X			;4+
	STA (&84),Y				;6
	
	INX						;2

	LDA (&86),Y				;5+
	;STA copydata,X
.spr4
	EOR sprdata,X			;4+
	STA (&86),Y				;6
	
	INX						;2

	LDA (&88),Y				;5+
	;STA copydata,X
.spr5
	EOR sprdata,X			;4+
	STA (&88),Y				;6
	
	INX						;2

	LDA (&8a),Y				;5+
	;STA copydata,X
.spr6
	EOR sprdata,X			;4+
	STA (&8a),Y				;6
	
	INX						;2
	INY						;2

	TYA						;2
	AND #7					;2

.hop
	BNE nextrow1			;2/3+
	
	CLC						;2
	LDA &80					;3
	ADC #&80-8				;2
	STA &80					;3
	LDA &81					;3
	ADC #2					;2
	STA &81					;3
	
	LDA &82					;3
	ADC #&80-8				;2
	STA &82					;3
	LDA &83					;3
	ADC #2					;2
	STA &83					;3
	
	LDA &84					;3
	ADC #&80-8				;2
	STA &84					;3
	LDA &85					;3
	ADC #2					;2
	STA &85					;3
	
	LDA &86					;3
	ADC #&80-8				;2
	STA &86					;3
	LDA &87					;3
	ADC #2					;2
	STA &87					;3
	
	LDA &88					;3
	ADC #&80-8				;2
	STA &88					;3
	LDA &89					;3
	ADC #2					;2
	STA &89					;3
	
	LDA &8a					;3
	ADC #&80-8				;2
	STA &8a					;3
	LDA &8b					;3
	ADC #2					;2
	STA &8b					;3
						;
						;
							;((111*21)+(3*98)+108 = 4170 + 38 = 4208
							
.rowdone
	CPY #24
	BNE hop
	;NEXT
	CLI
	RTS	


	
.shiftball
	LDX #0
	LDY #0
.mod1
	LDA sprdata,X
	ASL A
	ASL A
.mod2
	STA sprdata,X
	
	CPX #&E0
	BNE notdone

	CPY #7
	BNE notdone
	
	RTS
	
.notdone
	INX
	BNE mod1

	INC mod1+2
	INC mod2+2
	INY
	BNE mod1

.printscore
	LDA arcadeortest
	BNE noscoreprint

	LDA #scoremodtext MOD 256
	STA printdata1
	LDA #scoremodtext DIV 256
	STA printdata2

	LDA #(scorereturn2-1) DIV 256
	PHA
	LDA #(scorereturn2-1) MOD 256
	PHA
	
	LDA currentscore3
	PHA
	LDA currentscore2
	PHA
	LDA currentscore1
	PHA

	JMP	scoretostr

.scorereturn2

	LDA #&20
	STA screenaddr
	LDA #&33
	STA screenaddr+1
	
	LDA #yellowonblue MOD 256
	STA colourtblmod+1

	LDA #yellowonblue DIV 256
	STA colourtblmod+2
	
	JSR fastprinttext
	
.noscoreprint
	RTS
	
.printtime

	LDA #&c0
	STA screenaddr
	LDA #&31
	STA screenaddr+1
	
	LDA #yellowonblue MOD 256
	STA colourtblmod+1

	LDA #yellowonblue DIV 256
	STA colourtblmod+2

	LDX #1
	LDA arcadeortest
	BEQ arcadetimeprint
	
	LDX level
	INX
	TXA
	ASL A
	TAX
	DEX
	
.arcadetimeprint

	CLC
.findscreeny
	LDA screenaddr
	ADC #&80
	STA screenaddr
	LDA screenaddr+1
	ADC #2
	STA screenaddr+1
	
	DEX
	BNE findscreeny
	

	LDA time1
	AND #&f0
	LSR A
	LSR A
	LSR A
	LSR A
	
	JSR fastprint2
	
	LDA time1
	AND #&f

	JSR fastprint2

	CLC
	LDA screenaddr
	ADC #32
	STA screenaddr
	LDA screenaddr+1
	ADC #0
	STA screenaddr+1
	
	LDA time2
	AND #&f0
	LSR A
	LSR A
	LSR A
	LSR A

	JSR fastprint2

	LDA time2
	AND #&f

	JSR fastprint2
	
	;lda #1
	;sta &fe21
	RTS

	
.fastprint2
	CLC
	ADC #48
	STA fontread
	
	LDA #&a
	LDX #fontread MOD 256
	LDY #fontread DIV 256
	JSR OSWORD

	;ASL A
	;ASL A
	;ASL A
	;TAX
	;ADC #7
	;STA selfmod+1
	LDX #0	
	LDA #0
	STA scroffset
.nextcharbyte
	LDA fontread+1,X
	STX fontoffset
	
	LDX #4
.nextpixelpair
	ROL A
	ROL A
	STA fontbits
	ROL A

	AND #3
	TAY

.colourtblmod
	LDA whiteonmagenta,Y

	LDY scroffset
	STA (screenaddr),Y
	TYA
	CLC
	ADC #8
	STA scroffset

	LDA fontbits
	DEX
	BNE nextpixelpair

	LDA scroffset
	SEC
	SBC #31
	STA scroffset
	
	LDX fontoffset
	INX
.selfmod
	CPX #7
	BNE nextcharbyte
	
	CLC
	LDA screenaddr
	ADC #32
	STA screenaddr
	LDA screenaddr+1
	ADC #0
	STA screenaddr+1
	RTS

	
.fastprinttext
	LDY #0
.printchar2
	LDA (printdata1),Y
	CMP #&FF
	BEQ printdone2
	
	STY temp
	JSR fastprint2
	
	LDY temp
	INY
	JMP printchar2
	
.printdone2
	RTS
	
	
.printtext
	LDY #0
.printchar
	LDA (printdata1),Y
	CMP #&FF
	BEQ printdone
	
	JSR OSWRCH
	INY
	JMP printchar
	
.printdone
	RTS

;print a number of characters passed in X
.printchars
	LDY #0
.printchar3
	LDA (printdata1),Y
	
	JSR OSWRCH
	INY
	DEX
	BNE printchar3
	
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
	STA (printdata1),Y
	INY
	LDA temp
	AND #&f
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
	
.intv
	;Catch VSync interrupts
	LDA &FE4D
	AND #2
	BNE vsync
	
	;user timer 2 interrupts
	LDA &FE6D
	AND #&40
	BNE timer
		
    JMP oldint

.vsync

    ;clear the VSync flag.
	STA &FE4D

	LDA enableraster
	BEQ noraster
	
	LDA #&f0
	STA &FE64	; write timer lo
	LDA #&22
	STA &FE65	; write timer hi
	LDA #&C0
	STA &FE6E	; enable timer interrupts

	LDA #1
	STA intrunning

	LDA joykey
	BEQ noraster

	TXA
	PHA
	TYA
	PHA
	JSR scanjoy
	PLA
	TAY
	PLA
	TAX

.noraster

	INC &240
	
	;set ball colours to white
	JSR ballcolourstowhite
	
	JSR resetmaincolours

	LDA soundoffset
	BEQ nosound

	JSR updatesound
	
.nosound
	LDA #7
	STA intnum
	
	SED

	LDA arcadeortest
	BNE testtimeupdate
	
	SEC
	LDA time2
	SBC #2
	STA time2
	
	LDA time1
	SBC #0
	STA time1
	BCS timedone
	
	LDA #0
	STA time1
	STA time2
	BEQ timedone

.testtimeupdate	

	CLC
	LDA time2
	ADC #2
	STA time2
	LDA time1

	ADC #0
	STA time1
	BCC timedone

	LDA #&99
	STA time1
	STA time2
	
.timedone
	CLD
	
	LDA &FC
	RTI
	
.oldint JMP &0

.timer
	STA &FE6D
	
	SEC
	LDA intnum
	SBC #1
	STA intnum
	BCC intsdone
	
	TXA
	PHA
	TYA
	PHA
	
	LDA intnum
	
	CLC	
	ASL A
	ADC gridvpos1
	TAX
	LDA gridheights,X

	STA &FE64	; write timer lo
	
	INX
	LDA gridheights,X
	STA &FE65	; write timer hi

	;LDA #&A0
	;STA &FE6E	; enable timer interrupts
	
	;LDA #00
	;STA &fe21
	
	JSR setcolours

	PLA
	TAY
	PLA
	TAX
	
	;lda #07
	;sta &fe21
	
	LDA &FC
	RTI
	

.intsdone
	LDA #&40
	STA &FE6E	

	LDA #0
	STA intrunning

	LDA joykey
	BEQ skipjoy

	TXA
	PHA
	TYA
	PHA
	JSR scanjoy
	PLA
	TAY
	PLA
	TAX

.skipjoy
	;set ball colours to black
	JSR ballcolourstoblack

	LDA &FC
	RTI

.resetmaincolours
	LDA #&16
	STA &FE21
	LDA #&25
	STA &FE21
	LDA #&34
	STA &FE21
	LDA #&43
	STA &FE21
	LDA #&52
	STA &FE21
	RTS
	
.ballcolourstowhite
	LDA #&80
	STA &FE21
	LDA #&90
	STA &FE21
	LDA #&a0
	STA &FE21
	LDA #&b0
	STA &FE21
	LDA #&c0
	STA &FE21
	LDA #&d0
	STA &FE21
	LDA #&e0
	STA &FE21
	LDA #&f0
	STA &FE21
	RTS

.ballcolourstoblack	
	LDA #&87
	STA &FE21
	LDA #&97
	STA &FE21
	LDA #&a7
	STA &FE21
	LDA #&b7
	STA &FE21
	LDA #&c7
	STA &FE21
	LDA #&d7
	STA &FE21
	LDA #&e7
	STA &FE21
	LDA #&f7
	STA &FE21
	RTS
	
.setcolours
	CLC
	
	LDA intnum
	ADC intnum
	ADC intnum
	ADC intnum
	ADC intnum
	TAY

	LDA (gridoffset1a),Y
	
	STA &FE21   ; set colour 1

	INY
	LDA (gridoffset1a),Y

	STA &FE21   ; set colour 2

	INY
	LDA (gridoffset1a),Y

	STA &FE21   ; set colour 3

	INY
	LDA (gridoffset1a),Y

	STA &FE21   ; set colour 4
	
	INY
	LDA (gridoffset1a),Y
	STA &FE21   ; set colour 5	

	INY
	LDA (gridoffset1a),Y

	CMP #&FF
	BNE notleveldone

	LDA #1
	STA levelcomplete

.notleveldone
	RTS

.oldbrk EQUW 0
	
.digits EQUS "0123456789"
	
.levelfile
	EQUS "*L. LEVEL"
.levelfnmod
	EQUS "A 2800"
	EQUB &D

.savescores
	EQUS "*SAVE SCORES 400+30"
	EQUB &D
	
.menufile
	EQUS "*/TRAIL"
	EQUB &D
	
.gridplotdatafile
	EQUS "*L. GPLOT B00"
	EQUB &D

.gridheightdatafile
	EQUS "*L. GHEIGHT C00"
	EQUB &D
	
.gamesetup
	EQUB 12
	EQUB 26
	EQUB &FF
	
.leveltext EQUB 31,7,3,17,0,17,134
.leveltextmod EQUS "A"
	EQUB &FF

.lnamesetuptext
	EQUB 17,128,17,7,31,0,7,&FF

.gameovertext
	EQUB 28,0,31,19,7
	EQUB 17,128
	EQUB 12	
	EQUB 17,0,17,133
	EQUB 28,3,17,16,15
	EQUB 12	
	EQUB 31,2,1
	EQUS "GAME OVER"
	EQUB &FF
	
.getreadytext1
	EQUB 28,0,31,19,7
	EQUB 17,128
	EQUB 12
	EQUB 17,0,17,133
	EQUB 28,2,19,17,11
	EQUB 12
	EQUB &FF

.getreadyarcadetext
	EQUB 31,3,1
	EQUS "PLAY ARCADE"
	EQUB &FF
	
.getreadytesttext
	EQUB 31,2,1
	EQUS "3 COURSE TEST"
	EQUB &FF

.getreadytext2
	EQUB 31,1,3
	EQUS "ENTERING TRAIL"
	EQUB 31,5,5
	EQUS "ZONE "
.getreadyzonemod
	EQUS "A"
	EQUB 31,3,7
	EQUS "GET READY!"
	EQUB 17,128
	EQUB &FF

.scoremodtext
	EQUS "ssssss"
	EQUB &FF

.gamecompletetext
	EQUB 28,0,31,19,7
	EQUB 17,128
	EQUB 12
	EQUB 28,2,27,16,10
	EQUB 17,0,17,133
	EQUB 12
	EQUB 31,1,1
	EQUS "NIFTY CONTROL"
	EQUB 31,5,3
	EQUB "THERE"
	EQUB 31,2,5
	EQUB "ALL LEVELS"
	EQUB 31,5,7
	EQUB "DONE!!"
	EQUB 31,2,9
	EQUB "NO RELAXING"
	EQUB 31,5,11
	EQUB "NOW!!"
	EQUB 31,1,13
	EQUB "BOUNCE AROUND"
	EQUB 31,5,15
	EQUB "AGAIN"
    EQUB &FF

.fontread
	EQUB 65
	EQUB 0,0,0,0,0,0,0,0
	
.yellowonblue
	EQUB 48,37,26,15

.whiteonmagenta
	EQUB 51,55,59,63
	
.sounddata
	EQUB 0	;dummy
.jumpsounddata
	EQUB &80,&29,&90	;freq, freq, vol triplet
	EQUB &80,&28,&90	;freq, freq, vol triplet
	EQUB &80,&27,&90	;freq, freq, vol triplet
	EQUB &80,&26,&90	;freq, freq, vol triplet
	EQUB &80,&25,&90	;freq, freq, vol triplet
	EQUB &80,&24,&90	;freq, freq, vol triplet
	EQUB &80,&23,&90	;freq, freq, vol triplet
	EQUB &80,&22,&90	;freq, freq, vol triplet
	EQUB &80,&21,&90	;freq, freq, vol triplet
	EQUB &80,&20,&90	;freq, freq, vol triplet
	EQUB &80,&00,&9F	;freq, freq, vol triplet
	EQUB 0
.fallsounddata
	EQUB &80,&20,&90	;freq, freq, vol triplet
	EQUB &80,&20,&90	;freq, freq, vol triplet
	EQUB &80,&20,&90	;freq, freq, vol triplet
	EQUB &80,&19,&90	;freq, freq, vol triplet
	EQUB &80,&19,&90	;freq, freq, vol triplet
	EQUB &80,&19,&90	;freq, freq, vol triplet
	EQUB &80,&18,&90	;freq, freq, vol triplet
	EQUB &80,&18,&90	;freq, freq, vol triplet
	EQUB &80,&18,&90	;freq, freq, vol triplet
	EQUB &80,&17,&90	;freq, freq, vol triplet
	EQUB &80,&17,&90	;freq, freq, vol triplet
	EQUB &80,&17,&90	;freq, freq, vol triplet
	EQUB &80,&16,&90	;freq, freq, vol triplet
	EQUB &80,&16,&90	;freq, freq, vol triplet
	EQUB &80,&16,&90	;freq, freq, vol triplet
	EQUB &80,&00,&9F	;freq, freq, vol triplet
	EQUB 0


.startdata3
	EQUB &00
	EQUB &01
	EQUB &02
	EQUB &03
	EQUB &04
	EQUB &05
	EQUB &06
	EQUB &07
	EQUB &80
	EQUB &81
	EQUB &82
	EQUB &83
	EQUB &84
	EQUB &85
	EQUB &86
	EQUB &87
	EQUB &00
	EQUB &01
	EQUB &02
	EQUB &03
	EQUB &04
	EQUB &05
	EQUB &06
	EQUB &07
	EQUB &80
	EQUB &81
	EQUB &82
	EQUB &83
	EQUB &84
	EQUB &85
	EQUB &86
	EQUB &87
	EQUB &00
	EQUB &01
	EQUB &02
	EQUB &03
	EQUB &04
	EQUB &05
	EQUB &06
	EQUB &07
	EQUB &80
	EQUB &81
	EQUB &82
	EQUB &83
	EQUB &84
	EQUB &85
	EQUB &86
	EQUB &87
	EQUB &00
	EQUB &01
	EQUB &02
	EQUB &03
	EQUB &04
	EQUB &05
	EQUB &06
	EQUB &07
	EQUB &80
	EQUB &81
	EQUB &82
	EQUB &83
	EQUB &84
	EQUB &85
	EQUB &86
	EQUB &87
	EQUB &00
	EQUB &01
	EQUB &02
	EQUB &03
	EQUB &04
	EQUB &05
	EQUB &06
	EQUB &07
	EQUB &80
	EQUB &81
	EQUB &82
	EQUB &83
	EQUB &84
	EQUB &85
	EQUB &86
	EQUB &87
	EQUB &00
	EQUB &01
	EQUB &02
	EQUB &03
	EQUB &04
	EQUB &05
	EQUB &06
	EQUB &07
	EQUB &80
	EQUB &81
	EQUB &82
	EQUB &83
	EQUB &84
	EQUB &85
	EQUB &86
	EQUB &87
	EQUB &00
	EQUB &01
	EQUB &02
	EQUB &03
	EQUB &04
	EQUB &05
	EQUB &06
	EQUB &07
	EQUB &80
	EQUB &81
	EQUB &82
	EQUB &83
	EQUB &84
	EQUB &85
	EQUB &86
	EQUB &87
	EQUB &00
	EQUB &01
	EQUB &02
	EQUB &03
	EQUB &04
	EQUB &05
	EQUB &06
	EQUB &07
	EQUB &80
	EQUB &81
	EQUB &82
	EQUB &83
	EQUB &84
	EQUB &85
	EQUB &86
	EQUB &87
	EQUB &00
	EQUB &01
	EQUB &02
	EQUB &03
	EQUB &04
	EQUB &05
	EQUB &06
	EQUB &07
	EQUB &80
	EQUB &81
	EQUB &82
	EQUB &83
	EQUB &84
	EQUB &85
	EQUB &86
	EQUB &87
	EQUB &00
	EQUB &01
	EQUB &02
	EQUB &03
	EQUB &04
	EQUB &05
	EQUB &06
	EQUB &07
	EQUB &80
	EQUB &81
	EQUB &82
	EQUB &83
	EQUB &84
	EQUB &85
	EQUB &86
	EQUB &87
	EQUB &00
	EQUB &01
	EQUB &02
	EQUB &03
	EQUB &04
	EQUB &05
	EQUB &06
	EQUB &07
	EQUB &80
	EQUB &81
	EQUB &82
	EQUB &83
	EQUB &84
	EQUB &85
	EQUB &86
	EQUB &87
	EQUB &00
	EQUB &01
	EQUB &02
	EQUB &03
	EQUB &04
	EQUB &05
	EQUB &06
	EQUB &07
	EQUB &80
	EQUB &81
	EQUB &82
	EQUB &83
	EQUB &84
	EQUB &85
	EQUB &86
	EQUB &87
	EQUB &00
	EQUB &01
	EQUB &02
	EQUB &03
	EQUB &04
	EQUB &05
	EQUB &06
	EQUB &07
	EQUB &80
	EQUB &81
	EQUB &82
	EQUB &83
	EQUB &84
	EQUB &85
	EQUB &86
	EQUB &87
	EQUB &00
	EQUB &01
	EQUB &02
	EQUB &03
	EQUB &04
	EQUB &05
	EQUB &06
	EQUB &07
	EQUB &80
	EQUB &81
	EQUB &82
	EQUB &83
	EQUB &84
	EQUB &85
	EQUB &86
	EQUB &87
	EQUB &00
	EQUB &01
	EQUB &02
	EQUB &03
	EQUB &04
	EQUB &05
	EQUB &06
	EQUB &07
	EQUB &80
	EQUB &81
	EQUB &82
	EQUB &83
	EQUB &84
	EQUB &85
	EQUB &86
	EQUB &87
	EQUB &00
	EQUB &01
	EQUB &02
	EQUB &03
	EQUB &04
	EQUB &05
	EQUB &06
	EQUB &07
	EQUB &80
	EQUB &81
	EQUB &82
	EQUB &83
	EQUB &84
	EQUB &85
	EQUB &86

	
.startdata4
	EQUB &30
	EQUB &30
	EQUB &30
	EQUB &30
	EQUB &30
	EQUB &30
	EQUB &30
	EQUB &30
	EQUB &32
	EQUB &32
	EQUB &32
	EQUB &32
	EQUB &32
	EQUB &32
	EQUB &32
	EQUB &32
	EQUB &35
	EQUB &35
	EQUB &35
	EQUB &35
	EQUB &35
	EQUB &35
	EQUB &35
	EQUB &35
	EQUB &37
	EQUB &37
	EQUB &37
	EQUB &37
	EQUB &37
	EQUB &37
	EQUB &37
	EQUB &37
	EQUB &3a
	EQUB &3a
	EQUB &3a
	EQUB &3a
	EQUB &3a
	EQUB &3a
	EQUB &3a
	EQUB &3a
	EQUB &3c
	EQUB &3c
	EQUB &3c
	EQUB &3c
	EQUB &3c
	EQUB &3c
	EQUB &3c
	EQUB &3c
	EQUB &3f
	EQUB &3f
	EQUB &3f
	EQUB &3f
	EQUB &3f
	EQUB &3f
	EQUB &3f
	EQUB &3f
	EQUB &41
	EQUB &41
	EQUB &41
	EQUB &41
	EQUB &41
	EQUB &41
	EQUB &41
	EQUB &41
	EQUB &44
	EQUB &44
	EQUB &44
	EQUB &44
	EQUB &44
	EQUB &44
	EQUB &44
	EQUB &44
	EQUB &46
	EQUB &46
	EQUB &46
	EQUB &46
	EQUB &46
	EQUB &46
	EQUB &46
	EQUB &46
	EQUB &49
	EQUB &49
	EQUB &49
	EQUB &49
	EQUB &49
	EQUB &49
	EQUB &49
	EQUB &49
	EQUB &4b
	EQUB &4b
	EQUB &4b
	EQUB &4b
	EQUB &4b
	EQUB &4b
	EQUB &4b
	EQUB &4b
	EQUB &4e
	EQUB &4e
	EQUB &4e
	EQUB &4e
	EQUB &4e
	EQUB &4e
	EQUB &4e
	EQUB &4e
	EQUB &50
	EQUB &50
	EQUB &50
	EQUB &50
	EQUB &50
	EQUB &50
	EQUB &50
	EQUB &50
	EQUB &53
	EQUB &53
	EQUB &53
	EQUB &53
	EQUB &53
	EQUB &53
	EQUB &53
	EQUB &53
	EQUB &55
	EQUB &55
	EQUB &55
	EQUB &55
	EQUB &55
	EQUB &55
	EQUB &55
	EQUB &55
	EQUB &58
	EQUB &58
	EQUB &58
	EQUB &58
	EQUB &58
	EQUB &58
	EQUB &58
	EQUB &58
	EQUB &5a
	EQUB &5a
	EQUB &5a
	EQUB &5a
	EQUB &5a
	EQUB &5a
	EQUB &5a
	EQUB &5a
	EQUB &5d
	EQUB &5d
	EQUB &5d
	EQUB &5d
	EQUB &5d
	EQUB &5d
	EQUB &5d
	EQUB &5d
	EQUB &5f
	EQUB &5f
	EQUB &5f
	EQUB &5f
	EQUB &5f
	EQUB &5f
	EQUB &5f
	EQUB &5f
	EQUB &62
	EQUB &62
	EQUB &62
	EQUB &62
	EQUB &62
	EQUB &62
	EQUB &62
	EQUB &62
	EQUB &64
	EQUB &64
	EQUB &64
	EQUB &64
	EQUB &64
	EQUB &64
	EQUB &64
	EQUB &64
	EQUB &67
	EQUB &67
	EQUB &67
	EQUB &67
	EQUB &67
	EQUB &67
	EQUB &67
	EQUB &67
	EQUB &69
	EQUB &69
	EQUB &69
	EQUB &69
	EQUB &69
	EQUB &69
	EQUB &69
	EQUB &69
	EQUB &6c
	EQUB &6c
	EQUB &6c
	EQUB &6c
	EQUB &6c
	EQUB &6c
	EQUB &6c
	EQUB &6c
	EQUB &6e
	EQUB &6e
	EQUB &6e
	EQUB &6e
	EQUB &6e
	EQUB &6e
	EQUB &6e
	EQUB &6e
	EQUB &71
	EQUB &71
	EQUB &71
	EQUB &71
	EQUB &71
	EQUB &71
	EQUB &71
	EQUB &71
	EQUB &73
	EQUB &73
	EQUB &73
	EQUB &73
	EQUB &73
	EQUB &73
	EQUB &73
	EQUB &73
	EQUB &76
	EQUB &76
	EQUB &76
	EQUB &76
	EQUB &76
	EQUB &76
	EQUB &76
	EQUB &76
	EQUB &78
	EQUB &78
	EQUB &78
	EQUB &78
	EQUB &78
	EQUB &78
	EQUB &78
	EQUB &78
	EQUB &7b
	EQUB &7b
	EQUB &7b
	EQUB &7b
	EQUB &7b
	EQUB &7b
	EQUB &7b
	EQUB &7b
	EQUB &7d
	EQUB &7d
	EQUB &7d
	EQUB &7d
	EQUB &7d
	EQUB &7d
	EQUB &7d
	
.sprdata
	INCBIN "sprdat.bin"

.end

SAVE "..\trail.bin", start, end
