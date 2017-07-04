    ORG &500

.start
	EQUB 0,0,0,0,0,0,0,0
	EQUB 0,0,0,1,0,0,0,0
	EQUB 0,0,0,1,0,0,0,1
	EQUB 0,0,1,0,1,0,0,1
	EQUB 0,1,0,1,0,1,0,1
	EQUB 1,0,1,1,1,0,1,0
	EQUB 1,1,1,0,1,1,1,0
	EQUB 1,1,1,1,1,1,1,0

.end

SAVE "..\scrollmodifiers.bin", start, end