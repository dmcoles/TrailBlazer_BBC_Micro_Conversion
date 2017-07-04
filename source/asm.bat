.\beebasm -i trailmenu6502.s

.\beebasm -i trail6502.s

.\beebasm -i gridplotdata.s

.\beebasm -i gridheightdata.s

.\beebasm -i scrollmodifiers.s

copy ..\trailmenu.bin  ..\$.TRAIL
copy ..\trail.bin ..\$.TMAIN
copy ..\gridheightdata.bin ..\$.GHEIGHT
copy ..\gridplotdata.bin ..\$.GPLOT
copy ..\scrollmodifiers.bin ..\$.SCRLMOD

del ..\trailmenu.bin
del ..\trail.bin
del ..\gridheightdata.bin
del ..\gridplotdata.bin
del ..\scrollmodifiers.bin

pause