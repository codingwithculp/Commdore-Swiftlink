10 rem  ===============================
20 rem  = basic U64 MODEM test        =
30 rem  = By David Culp               =
40 rem  = codingwithculp@gmail.com    =
50 rem  = YouTube: @codingwithculp    =
60 rem  = @codingwithculp.bsky.social =
70 rem  = X @dwculp                   =
80 rem  = variables used:             =
90 rem  = 6551 regs                   =
100 rem = ba: base address            =
110 rem = dr: data register           =
120 rem = cm: command register        =
130 rem = cr: control register        =  
140 rem = s$: string to output        =
145 rem = rl$: receive line string    =
150 rem = c: charater value for in    =
160 rem = b: byte for output          =
170 rem = cd: carrier, 64=no, 0=yes   =
180 rem = ec: local echo, 1=yes       =
190 rem = tt: 1/C64,2/ASCII, 3/Vt100  =
200 rem = pa: petscii 1=true          =
205 rem = co: columns 40=default      =
210 rem ===============================
220 rem = SUBROUTINE LINE #'s         =
230 rem = RING SOUND - 50030          =
240 rem = SEND STRING IN S$ - 50340   =
250 rem = SEND BYTE IN B - 50540      =
260 rem = SEND CR/LF - 50730          =
270 rem = SEND FILE in F$ - 50870     =
280 rem = RECEIVE BYTE - 51340        =
290 rem = RECEIVE LINE - 51440        =
300 rem = WAIT FOR RING - 51680       =
310 rem = WAIT FOR CARRIER - 51880    =
320 rem = HANGUP - 51930              =
330 rem = SET/RESET MODEM - 52130     =
340 rem = FLUSH RX BUFFER - 52270     = 
350 rem = CHECK CARRIER - 52450       =
360 rem = PRINT 6551 REGS - 52530     =
370 rem = GET BS KEY CODE - 52730     =
380 rem = DELAY           - 52950     =
390 rem ===============================
400 rem ===============================
410 rem = SETUP 6551 and COM VARIABLES=
420 rem ===============================
430 ba=56832: rem $de00 base acia reg
440 dr=ba : rem data register
450 sr=ba+1:rem status reg
460 cm=ba+2: rem command register
470 cr=ba+3: rem control register
480 gosub 52130: rem reset the modem
490 ec=1: pa=1:tt=1:co=40: rem echo on
1000 rem ==============================
1010 rem =  BEGIN USERCODE HERE       =
1020 rem ==============================
1030 poke 53280,0 : poke 53281,0 :poke 646,1
1035 print chr$(147):print"===================":print "Ultimate MODEM Test"
1040 print"==================="
1045 print "Flushing input buffer:":gosub 52270
1050 gosub 52530
1060 print "Waiting for incoming call:"
1070 gosub 51680: rem wait for ring
1080 rem === we have a connection ==
1090 print "We have a connection!!": gosub 50300
1100 print "Sending intro text"
1110 b=147:gosub 50540:b=14: gosub 50540: rem clear screen, lowercase mode
1120 s$="{wht}W{red}e{cyn}l{pur}c{grn}o{blu}m{yel}e {wht}to The Ultimate Commodore 64!": gosub 50340:gosub 50730
1130 s$="Are you keeping up with the Commodore?":gosub 50340:gosub 50730
1135 dl=3:gosub 52950
1140 print "Waiting for the backspace key."
1150 gosub 52730: rem get BS routine
1160 if tt<>1 then print "We only support Commodore Systems!": gosub 50340: gosub 50730:goto 49000
1170 dl=3:gosub 52950:b=147:gosub 50540
1180 s$="Welcome to the {yel} lightning express!!!": gosub 50340:gosub 50730
1190 dl=4:gosub 52950
1200 s$="How about we read a file from disk?":gosub 50340:gosub 50730
1210 f$="storm":gosub 50870: gosub 50540
1220 s$="{grn}These are not the droids you are looking for!":gosub 50340:gosub 50730
1230 s$="What is your name? ":gosub 50340:gosub 51440: gosub 50730
1240 s$=rl$+" glad you are here!  Thats all we have for now!":gosub 50340
1250 dl=3:gosub 52950


49000 print "Hanging up!":gosub 51930:goto 480: rem go back to top

50000 rem =============================
50010 rem = phone ring sound (sid)    =
50020 rem =============================
50030 rem reset sid + set volume
50040 for i=54272 to 54296: poke i,0: next i
50050 poke 54296,15: rem max volume
50060 rem voice 1 frequency 
50070 poke 54272,0: poke 54273,8
50090 rem pulse width 50% 
50100 poke 54274,0: poke 54275,8 
50120 rem envelope (fast attack, medium release)
50130 poke 54277,0: poke 54278,240 
50140 rem ring on/off twice
50150 for r=1 to 2
50160 poke 54276,65   : rem pulse + gate on  (64+1)
50170 for t=1 to 250: next t
50180 poke 54276,64   : rem pulse, gate off
50190 for t=1 to 200: next t
50200 next r
50210 rem silence
50220 poke 54296,0
50230 return
50300 rem ==============================
50310 rem = send a string subroutine   =
50320 rem = put string to send in s$   =
50330 rem ==============================
50340 ln=len(s$)
50350 for i=1 to ln
50360 b=asc(mid$(s$,i,1))
50380 t0=0: rem timeout
50390 a=peek(sr)
50400 if (a and 16)<>0 then 50450: rem clear to send
50410 t0=t0+1
50420 if t0<20 then 50390
50430 print "tx timeout sr=";a
50440 goto 50470
50450 poke dr,b: rem send the byte
50460 rem --- end inline send ---
50470 next i
50480 return: rem string sent, return
50500 rem ==============================
50510 rem = send a single byte         =
50520 rem = put byte to send in b      =
50530 rem ==============================
50540 t0=0: rem a timeout counter
50550 a=peek(sr) :  rem look in the status register
50560 if (a and 16)<>0 then 50610: rem if tx empty go send it
50570 t0=t0+1: rem tx was busy, add 1 to timeout
50580 if t0<20 then 50550
50590 print "tx timeout sr=";a:rem took too much time, go back
50600 return
50610 poke dr,b: rem put the byte into the data reg
50620 return: rem go back
50700 rem ==============================
50710 rem = send cr/lf                 =
50720 rem ==============================
50730 b=13: gosub 50540:b=10: gosub 50540
50740 return
50800 rem =============================
50810 rem = send disk file over modem =
50820 rem = f$ = filename             =
50830 rem = sends lines, cr/lf each   =
50840 rem = reports disk errors       =
50850 rem =============================
50870 open 15,8,15: rem open disk command channel
50880 input#15,en,em$,t1,t2
50900 open 2,8,2,f$+",s,r": rem open the file as seq, read
50910 rem check drive status after open (catches file not found)
50920 input#15,en,em$,t1,t2
50930 if en<>0 then 51190: rem something wrong, exit
50940 rem =====MAIN READ LOOP =====
50950 get#2,a$
50960 if st <>0 then 51150
50970 b=asc(a$)
50972 t0=0
50974 a=peek(sr)
50976 if (a and 16)<>0 then 50990
50978 t0=t0+1: if t0<20 then 50974
50980 goto 50950
50990 poke dr,b
51010 goto 50950:rem get another byte
51150 rem ==== eof or read done ====
51160 close 2: close 15: return
51190 rem ==== error path ====
51210 print "disk err ";en;":";em$: rem print drive error message and number
51220 s$="disk err "+str$(en)+":"+em$: rem send error across modem
51230 gosub 50340: gosub 50730
51260 close 2
51270 close 15
51280 return
51300 rem =============================
51310 rem = receive single byte       =
51320 rem = waits until rx ready      =
51330 rem =============================
51340 a=peek(sr):c=0
51345 gosub 52450:if cd=64 then return: rem check for carrier drop
51350 if (a and 8)=0 then 51340:rem wait for a byte in receive buffer
51360 c=peek(dr):rem print c:rem get it and put it into c
51370 return
51400 rem =============================
51410 rem = receive line subroutine   =
51420 rem = reads until cr            =
51430 rem =============================
51440 rl$=""
51450 gosub 51340: rem get a single byte
51460 if c=10 then 51450        : rem ignore lf
51470 if c=13 then return       : rem cr ends line
51472 if c=20 and len(rl$)>0 then 51520: rem handle backspace
51480 if c<32 or c>126 then 51450: rem not a number or letter
51490 if len(rl$)<=39 then rl$=rl$+chr$(c):if ec=1 then b=c: gosub 50540
51500 if len(rl$)=40 then return
51510 goto 51450
51520 rl$=left$(rl$,len(rl$) -1): if ec=1 then b=c:gosub 50540
51530 goto 51450

51600 rem ============================
51610 rem = wait for "ring" sub      =
51620 rem = waits for bit 3 of the sr=
51630 rem = to go high indicating the=
51640 rem = rx line has received data=
51650 rem = builds a str looking for =
51660 rem = "ring"                   =
51670 rem ============================
51680 l$="": rem empty buffer to hold incoming data
51690 a=peek(sr):rem look at the status register
51700 if (a and 8)=0 then 51690 : rem = bit 3 low read again
51710 c=peek(dr):rem read the data register
51720 if c=10 then 51690: rem ignore line feed
51730 if c=13 then 51780: rem cr marks eol
51740 if c<32 or c>126 then 51690: rem is it a letter?
51750 if len(l$)<20 then l$=l$+chr$(c): rem add it to l$
51760 goto 51690: rem go get more data
51770 rem if we build the string "ring" we have a connection
51780 if l$="ring" or l$="RING" then 51800
51790 goto 51680: rem something else  empty it and do it again
51800 s$="ata": gosub 50340
51820 gosub 50730: rem send CR/LF
51825 cd=peek(sr) and 64
51830 return
51850 rem =============================
51860 rem = wait for carrier detect   =
51870 rem =============================
51880 cd=peek(sr) and 64
51890 if cd<> 0 then 51880
51895 return


51900 rem =============================
51910 rem = hangup!                   =
51920 rem =============================
51930 dl=1:gosub 52950: rem a bit of a delay
51935 s$="Goodbye!": gosub 50340: gosub 50730
51940 b=asc("+"): gosub 50540
51950 b=asc("+"): gosub 50540
51960 b=asc("+"): gosub 50540
51970 dl=1:gosub 52950: rem a bit of a delay
51980 s$="ath"
51990 gosub 50340: gosub 50730
52010 dl=.25:gosub 52950: rem a bit of a delay
52020 poke sr,0: rem reset the 6551
52030 dl=.25:gosub 52950: rem a bit of a delay
52040 poke cr,31 : rem 38400 baud, 8 data bits, 1 stop bit
52050 dl=.25:gosub 52950: rem a bit of a delay
52060 poke cm,9 : rem dtr active (online), rx enabled, tx interrupts off 
52065 gosub 52450: rem get cd status
52070 return
52100 rem =============================
52110 rem = SET/REST MODEM            =
52120 rem =============================
52130 poke sr,0: rem reset the 6551
52140 poke cr,31 : rem 38400 baud, 8 data bits, 1 stop bit
52150 poke cm,9 : rem dtr active (online), rx enabled, tx interrupts off
52155 gosub 52450: rem get cd status
52160 return

52200 rem =============================
52210 rem = flush rx buffer subroutine=
52220 rem = waits until 50 reads in a =
52230 rem = row detect no waiting data=
52240 rem = then assumes the buffer   =
52250 rem = is clear                  =
52260 rem =============================
52270 q=0: rem empty data counter
52280 a=peek(sr): rem read the status reg
52290 if (a and 8)=0 then 52340:  REM if data is waiting
52300 d=peek(dr): rem byte waiting so read and discard it
52310 q=0: rem reset the empty data counter
52320 goto 52280: rem go read it again
52330 rem no data detected this loop
52340 q=q+1: print".";:rem increment our empty dtat counter
52350 if q<50 then 52280: rem less than 50 empty reads?  do it again
52360 print "":return: rem we reached 50 empty reads, exit
52400 rem =============================
52410 rem = get carrier status        =
52420 rem = 64 - no carrier           =
52430 rem = 0 - carrier               =
52440 rem =============================
52450 cd=peek(sr) and 64: rem check bit 6
52460 return
52500 rem =============================
52510 rem = print 6551 register status=
52520 rem =============================
52530 print "======================"
52540 print "=Data register:    ";peek(dr)
52550 print "=Status resgister: ";peek(sr)
52560 print "=Command register: ";peek(cm)
52570 print "=Control register: ";peek(cr)
52575 gosub 52450
52580 print "=Carrier status:   ";cd
52590 print "======================"
52600 return
52700 rem =============================
52710 rem = get backspace/del key code=
52720 rem =============================
52730 rem print "waiting for backspace key."
52740 tr=0
52750 s$="Press your backspace key now:":gosub 50340
52760 gosub 51340: rem get the input into c
52770 if c=8 then s$="looks like an ascii system":tt=2:gosub 50730:gosub 50340: gosub 50730:return
52780 if c=127 then s$="looks like a unix or vt100 system":tt=3:gosub 50730:gosub 50340: gosub 50730:return
52790 if c=20 then s$="looks like a commodore system":tt=1:gosub 50730:gosub 50340: gosub 50730:return
52800 s$="are you sure you hit your backspace key?":gosub 50730:gosub 50340: gosub 50730
52810 tr=tr+1:if tr < 4 then goto 52750
52820 s$="Too many tries!  Logging out!":gosub 50730:gosub 50340:gosub 50730:tt=0:return
52900 rem =============================
52910 rem = delay routine             =
52920 rem = set dl equal to number of =
52930 rem = seconds delay             =
52940 rem =============================
52950 t=peek(678)
52960 h=60: if t=1 then h=50
52970 s=ti:e= dl*h 
52980 if (ti-s) < e then 52980
52990 return
