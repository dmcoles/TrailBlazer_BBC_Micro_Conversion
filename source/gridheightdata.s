	ORG &700

.start
	
.gridheights
;position 1
	EQUW &800 - &30  ; 32
	EQUW &500 - &30  ; 20
	EQUW &300 - &30  ; 12
	EQUW &200 - &30	 ; 8
	EQUW &180 - &30  ; 6
	EQUW &180 - &30  ; 6
	EQUW &440 - &30  ; 0
;position 2
	EQUW &700 - &30  ; 28
	EQUW &540 - &30  ; 21
	EQUW &300 - &30  ; 12
	EQUW &200 - &30	 ; 8
	EQUW &180 - &30  ; 6
	EQUW &180 - &30  ; 6
	EQUW &440 - &30  ; 0
;position 3
	EQUW &640 - &30  ; 25
	EQUW &580 - &30  ; 22
	EQUW &340 - &30  ; 13
	EQUW &200 - &30	 ; 8
	EQUW &180 - &30  ; 6
	EQUW &180 - &30  ; 6
	EQUW &480 - &30  ; 1
;position 4
	EQUW &640 - &30  ; 25
	EQUW &580 - &30  ; 22
	EQUW &340 - &30  ; 13
	EQUW &200 - &30	 ; 8
	EQUW &180 - &30  ; 6
	EQUW &180 - &30  ; 6
	EQUW &480 - &30  ; 1
;position 5
	EQUW &580 - &30  ; 22
	EQUW &5c0 - &30  ; 23
	EQUW &380 - &30  ; 14
	EQUW &240 - &30	 ; 9
	EQUW &180 - &30  ; 6
	EQUW &180 - &30  ; 6
	EQUW &480 - &30  ; 1
;position 6
	EQUW &500 - &30  ; 20
	EQUW &600 - &30  ; 24
	EQUW &380 - &30  ; 14
	EQUW &240 - &30	 ; 9
	EQUW &180 - &30  ; 6
	EQUW &180 - &30  ; 6
	EQUW &4c0 - &30  ; 2
;position 7
	EQUW &480 - &30  ; 18
	EQUW &640 - &30  ; 25
	EQUW &3c0 - &30  ; 15
	EQUW &240 - &30	 ; 9
	EQUW &180 - &30  ; 6
	EQUW &180 - &30  ; 6
	EQUW &4c0 - &30  ; 2
;position 8
	EQUW &440 - &30  ; 17
	EQUW &640 - &30  ; 25
	EQUW &3c0 - &30  ; 15
	EQUW &240 - &30	 ; 9
	EQUW &180 - &30  ; 6
	EQUW &180 - &30  ; 6
	EQUW &500 - &30  ; 3
;position 9
	EQUW &340 - &30  ; 13
	EQUW &680 - &30  ; 26
	EQUW &400 - &30  ; 16
	EQUW &280 - &30	 ; 10
	EQUW &1c0 - &30  ; 7
	EQUW &180 - &30  ; 6
	EQUW &500 - &30  ; 3
;position 10
	EQUW &300 - &30  ; 12
	EQUW &6c0 - &30  ; 27
	EQUW &400 - &30  ; 16
	EQUW &280 - &30	 ; 10
	EQUW &1c0 - &30  ; 7
	EQUW &180 - &30  ; 6
	EQUW &500 - &30  ; 3
;position 11
	EQUW &280 - &30  ; 10
	EQUW &6c0 - &30  ; 27
	EQUW &440 - &30  ; 17
	EQUW &280 - &30	 ; 10
	EQUW &1c0 - &30  ; 7
	EQUW &180 - &30  ; 6
	EQUW &540 - &30  ; 4
;position 12
	EQUW &240 - &30  ; 9
	EQUW &700 - &30  ; 28
	EQUW &440 - &30  ; 17
	EQUW &280 - &30	 ; 10
	EQUW &1c0 - &30  ; 7
	EQUW &180 - &30  ; 6
	EQUW &540 - &30  ; 4
;position 13
	EQUW &180 - &30  ; 6
	EQUW &740 - &30  ; 29
	EQUW &480 - &30  ; 18
	EQUW &2c0 - &30	 ; 11
	EQUW &1c0 - &30  ; 7
	EQUW &180 - &30  ; 6
	EQUW &540 - &30  ; 4
;position 14
	EQUW &100 - &30  ; 4
	EQUW &780 - &30  ; 30
	EQUW &480 - &30  ; 18
	EQUW &2c0 - &30	 ; 11
	EQUW &1c0 - &30  ; 7
	EQUW &180 - &30  ; 6
	EQUW &580 - &30  ; 5
;position 15
	EQUW &080 - &30  ; 2
	EQUW &7c0 - &30  ; 31
	EQUW &4c0 - &30  ; 19
	EQUW &2c0 - &30	 ; 11
	EQUW &1c0 - &30  ; 7
	EQUW &180 - &30  ; 6
	EQUW &580 - &30  ; 5
;position 16
	EQUW &080 - &30  ; 2
	EQUW &7c0 - &30  ; 31
	EQUW &4c0 - &30  ; 19
	EQUW &2c0 - &30	 ; 11
	EQUW &1c0 - &30  ; 7
	EQUW &180 - &30  ; 6
	EQUW &580 - &30  ; 5

	.end

	SAVE "..\gridheightdata.bin", start, end
