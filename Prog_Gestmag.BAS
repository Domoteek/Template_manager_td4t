REM ************************************
REM     Application Name: GESTMAG 46x46
REM     Version: 20251117-001
REM ************************************
REM     Brother Base Printing Project
REM ************************************
REM History:
REM     v1.00: First version
REM     v1.10: Implement Suppr Key 
REM             + 3eme champs (code EAN13) 
REM             + Modif pour impression sur 46x46mm en 203dpi.
REM     v1.20: Add quantity screen
REM     v1.21: Correct Template variables names
REM     v1.22: Update version and app name for 46x46 format (2025-05-05)
REM     v1.23: Ajout fonctionnalité rognage images (cropTop) dans Template Manager
DOWNLOAD "GESTMAG.BAS"
qDispAppName$ = "GESTMAG DEMO"
qProgVersion$ = "1.22"
qDebug = 1
REM qDebugPort$ = "NET"
qDispAppLine1$ = "GESTMAG"
qDispAppLine2$ = qProgVersion$
GOSUB ZINIT
GOSUB ZAPPSETTINGS
GOSUB ZMAINAPP
GOSUB ZEND
REM -------------------------------------------
:ZAPPSETTINGS
REM Settings for the main application
	REM qWidth = VAL(qTphDpi$)*2
	REM qLength = VAL(qTphDpi$)*1	
	qWidth = 374   ' 46mm à 203 dpi (46*203/25.4 = 367.6 arrondi à 374)
    qLength = 374  ' 46mm à 203 dpi (46*203/25.4 = 367.6 arrondi à 374)
	CODEPAGE UTF-8
	qCheckFile$ = "CONFIG.DAT"
	GOSUB ZCHECKFILE
	IF qCheckFile = 1 THEN GOSUB ZCFGREAD
	qLibelStp = 0
	qQty = 1
RETURN
REM -------------------------------------------
:ZMAINAPP
REM Main program section
	qDebugMsg$ = "[ZMAINAPP]"
	GOSUB ZDEBUGMSG
	qDispImage$ = "Logo_GM.bmp"
	REM qDispAppLine1$ = qLang001$
	REM Display screen to select the template to run.
	qloop = 0
	WHILE qloop <> 1
		GOSUB ZENTFORM
		GOSUB ZEXECTPL
	WEND
RETURN
REM -------------------------------------------
:ZENTFORM
	qDebugMsg$ = "[ZENTFORM]"
	GOSUB ZDEBUGMSG
	qDispAppLine2$ = "Format:"
	qDispAppLine3$ = ""
	qDispAppLine4$ = ""
	qDispAppLine5$ = ""
	qDispAppLine6$ = ""
	qDispAppLine7$ = ""
	qDispAppLine8$ = ""
	qDispAppLine9$ = ""
	qLibelStp = 1
	GOSUB ZDISPAPP
RETURN
REM -------------------------------------------
:ZEXECTPL
REM Execute a template.
	qDebugMsg$ = "[ZEXECTPL]"
	GOSUB ZDEBUGMSG
	GOSUB ZGETDATARESET
	REM Capturing data from Keyboard
	qDataLast$=""
	IF qDataIsAvl = 1 THEN 
		GOSUB ZGETDATARESET
		qTicks = VAL(@SECOND)
	ENDIF
	WHILE qDataEnd <> 1
	 	GOSUB ZGETDATA
		IF qDataLast$<>qData$ THEN
			REM Update Display
			qDataLast$ = qData$
			qDispAppLine3$ = qData$
			GOSUB ZDISPAPP
		ENDIF
	WEND
	GOSUB ZGETDATARESET
	qTemplate$= qDispAppLine3$ + ".INI"
	qProgram$ = qDispAppLine3$ + ".BAS"
	qDebugMsg$ = "Recovering Template " + qProgram$ + " ..."
	GOSUB ZDEBUGMSG
	qCheckFile$ = qProgram$
	GOSUB ZCHECKFILE
	IF qCheckFile = 1 THEN
		REM ******************
		REM Open ini file to retrieve Menu information
		REM ******************
		qTemplMenu$ = ""
		qItemMenu$ = ""
		qItemMenu1$ = ""
		qItemMenu2$ = ""
		qItemMenu3$ = ""
		qItemMenu4$ = ""
		qItemSep$ = "#"
		OPEN qTemplate$,1
			SEEK 1,0
			WHILE EOF(1)=0
				READ 1,qTmp$
				REM qDebugMsg$ = "qTmp$: " + qTmp$
				REM GOSUB ZDEBUGMSG
				REM Check menu info.
				IF INSTR(qTmp$,"Menu")>0 THEN
					qTemplMenu$ = RIGHT$(qTmp$,LEN(qTmp$)- 6)
					qDebugMsg$ = "qTemplMenu: " + qTemplMenu$
					GOSUB ZDEBUGMSG
				ENDIF
				IF INSTR(qTmp$,"Item")>0 THEN
					qItemMenu$ = qItemMenu$ + RIGHT$(qTmp$,LEN(qTmp$)- 9) + qItemSep$
					REM qDebugMsg$ = "Item: " + qItemMenu$
					REM GOSUB ZDEBUGMSG
				ENDIF
			WEND
			REM Split qItemMenu => qItemMenu_1 / qItemMenu_2 ...
			FOR qj = 1 TO VAL(qTemplMenu$)
				qi = INSTR(1,qItemMenu$,qItemSep$)
				IF qi> 0 THEN
					qItemMenuTmp$ = LEFT$(qItemMenu$,qi-1)
					qItemMenu$ = RIGHT$(qItemMenu$,(LEN(qItemMenu$) - qi))
					REM qDebugMsg$ = "Position: " + STR$(qi) + " - Item: " + qItemMenu$ + " - qItemMenuTmp: " + qItemMenuTmp$
					REM 	GOSUB ZDEBUGMSG
					IF qj = 1 THEN 
						qItemMenu1$ = qItemMenuTmp$
						qDebugMsg$ = "qItemMenu1: " + qItemMenu1$
						GOSUB ZDEBUGMSG
					ENDIF
					IF qj = 2 THEN 
						qItemMenu2$ = qItemMenuTmp$
						qDebugMsg$ = "qItemMenu2: " + qItemMenu2$
						GOSUB ZDEBUGMSG
					ENDIF
					IF qj = 3 THEN 
						qItemMenu3$ = qItemMenuTmp$
						qDebugMsg$ = "qItemMenu3: " + qItemMenu3$
						GOSUB ZDEBUGMSG
					ENDIF
					IF qj = 4 THEN 
						qItemMenu4$ = qItemMenuTmp$
						qDebugMsg$ = "qItemMenu4: " + qItemMenu4$
						GOSUB ZDEBUGMSG
					ENDIF
				ENDIF
			NEXT
		CLOSE 1
		REM ******************
		REM Display menu according to number of items found
		REM ******************
		qDispAppLine2$ = qItemMenu1$
		qDispAppLine3$ = ""
		qDispAppLine4$ = qItemMenu2$
		qDispAppLine5$ = ""
		qDispAppLine6$ = qItemMenu3$
		qDispAppLine7$ = ""
		qDispAppLine8$ = qItemMenu4$
		qDispAppLine9$ = ""
		GOSUB ZDISPAPP
		FOR qj = 1 TO VAL(qTemplMenu$)
			qLibelStp = qj	
			WHILE qDataEnd <> 1
				GOSUB ZGETDATA
				IF qDataLast$<>qData$ THEN
					REM Update Affichage
					qDataLast$ = qData$
					IF qj = 1 THEN qDispAppLine3$ = qData$
					IF qj = 2 THEN qDispAppLine5$ = qData$
					IF qj = 3 THEN qDispAppLine7$ = qData$
					IF qj = 4 THEN qDispAppLine9$ = qData$
					GOSUB ZDISPAPP
				ENDIF
			WEND
		GOSUB ZGETDATARESET
		NEXT
		qItem1$ = qDispAppLine3$
		qItem2$ = qDispAppLine5$
		qItem3$ = qDispAppLine7$
		qItem4$ = qDispAppLine9$
		IF qItem1$<>"" THEN
			qDebugMsg$ = "qItem1: " + qItem1$
			GOSUB ZDEBUGMSG
		ENDIF
		IF qItem2$<>"" THEN
			qDebugMsg$ = "qItem2: " + qItem2$
			GOSUB ZDEBUGMSG
		ENDIF
		IF qItem3$<>"" THEN
			qDebugMsg$ = "qItem3: " + qItem3$
			GOSUB ZDEBUGMSG
		ENDIF
		IF qItem4$<>"" THEN
			qDebugMsg$ = "qItem4: " + qItem4$
			GOSUB ZDEBUGMSG
		ENDIF
		REM ******************
		REM Display menu to get quantity to print
		REM ******************
		GOSUB ZQTY
		REM Execute template
		RUN "" + qProgram$
	ELSE
		REM Message to display : Template could not be found
		qDebugMsg$ = "Template " + qProgram$ + " could not be found."
		GOSUB ZDEBUGMSG
	ENDIF
RETURN
Menu = 3
Item_1 = Libelle
Item_2 = CAB
Item_3 = Prix
	qLibelle$ = "LIBELLE"
	qPrix$ = "12.90"
	qBarcode$ = "0123456789012"
	qQty$ = "1"
REM -------------------------------------------
:ZLIBELLE
REM Wait for a scanned data (over USB). The handheld scanner should be setup in QWERTY + CR or CR/LF as suffix
    qDebugMsg$ = "[ZLIBELLE]"
    GOSUB ZDEBUGMSG
    GOSUB ZGETDATASTATUS
    qDataLast$=""
    IF qDataIsAvl = 1 THEN 
        GOSUB ZGETDATARESET
        qTicks = VAL(@SECOND)
    ENDIF
    qDebugMsg$ = "[ZLIBELLE] ==> Entrer le libelle"
    GOSUB ZDEBUGMSG
    qLibelStp = 1    
    WHILE qDataEnd <> 1
        GOSUB ZGETDATA
        IF qDataLast$<>qData$ THEN
            REM Update Affichage
            qDataLast$ = qData$
            qDispAppLine3$ = qData$
            GOSUB ZDISPAPP
        ENDIF
    WEND
    GOSUB ZGETDATARESET
    qDebugMsg$ = "[ZLIBELLE] ==> Entrer le prix"
    GOSUB ZDEBUGMSG
    qLibelStp = 2
    qDataEnd = 0
    WHILE qDataEnd <> 1
        GOSUB ZGETDATA
        IF qDataLast$<>qData$ THEN
            REM Update Affichage
            qDataLast$ = qData$
            qDispAppLine5$ = qData$
            GOSUB ZDISPAPP
        ENDIF
    WEND
    GOSUB ZGETDATARESET
    qDebugMsg$ = "[ZLIBELLE] ==> Entrer le code EAN"
    GOSUB ZDEBUGMSG
    qLibelStp = 3
    qDataEnd = 0
    qValidEAN = 0  ' Add a flag to track valid EAN input
	WHILE qDataEnd <> 1 OR qValidEAN = 0
        GOSUB ZGETDATA
        IF qDataLast$<>qData$ THEN
            REM Update Affichage
            REM Vérification de la longueur du code EAN (12 caractères)
            IF LEN(qData$) > 12 THEN
                qData$ = LEFT$(qData$, 12)  ' Tronquer à 12 caractères
                SOUND 1,100  ' Bip d'erreur
            ENDIF
            qDataLast$ = qData$
            qDispAppLine7$ = qData$
            GOSUB ZDISPAPP
        ENDIF
    WEND
    REM Vérification finale de la longueur du code EAN
    IF qData$ <> "" AND LEN(qData$) <> 12 THEN
        qDispAppLine3$ = "Code invalide"
        qDispAppLine5$ = "Doit avoir"
        qDispAppLine7$ = "12 caracteres"
        GOSUB ZDISPAPP
        SOUND 1,100  ' Bip d'erreur
        SOUND 1,100  ' Bip d'erreur
        DELAY 2000
        GOTO ZLIBELLE  ' Retour à la saisie
    ENDIF
    IF qData$<>"" THEN 
        GOSUB ZGETDATARESET
        qDebugMsg$ = "[ZLIBELLE] ==> Entrer la quantité"
        GOSUB ZDEBUGMSG
        GOSUB ZQTY
        qDebugMsg$ = "[ZLIBELLE] ==> Printing Label"
        GOSUB ZDEBUGMSG
        GOSUB ZPRINTLABEL
        GOSUB ZGETDATARESET
    ENDIF
RETURN
REM -------------------------------------------
:ZQTY
REM Screen to ask for quantity.
	qDebugMsg$ = "[ZQTY]"
	GOSUB ZDEBUGMSG
	qQty$ = 1
	qDispAppLine2$ = "Quantité à imprimer?"
	qDispAppLine8$ = qQty$
	WHILE qDataEnd <> 1
	 	GOSUB ZGETDATA
		IF qDataLast$<>qData$ THEN
			REM Update Affichage
			qDataLast$ = qData$
			qDispAppLine8$ = qData$
			GOSUB ZDISPQTY
		ENDIF
	WEND
	qQty$ = qDispAppLine8$
RETURN
REM -------------------------------------------
:ZPRINTLABEL
REM Print labels per data acquired
	qLibelle$ = qDispAppLine3$
	qPrix$ = qDispAppLine5$
	qBarcode$ = qDispAppLine7$
	RUN "3.BAS"
RETURN
REM -------------------------------------------
REM -------------------------------------------
:ZAPPDETECTPRESS
REM Detect TouchPress
	REM qDebugMsg$ = "[ZAPPDETECTPRESS]"
	REM GOSUB ZDEBUGMSG
	IF qLCDScreen = 2 THEN RETURN
	REM Detect Close Button
	IF TOUCHPRESS((qXMax - 30),35,(qXMax - 15),55) <> 0 THEN
		SOUND 1,100
		GOSUB ZEND
	ENDIF
	REM Detect Print Button
	IF TOUCHPRESS((qXMax/2)-66,2*(qYMax/3),(qXMax/2)+66,2*(qYMax/3)+162) <> 0 THEN
		SOUND 3,100
		SOUND 5,100
		qDispColor$ = "Green"
		GOSUB ZDISPCOLOR
		DISPLAY (qXMax/2)-66, 2*(qYMax/3) + 140, 132, 6, 3
		GOSUB ZPRINTDEMOLABEL
		qDispColor$ = "Black"
		GOSUB ZDISPCOLOR
	ENDIF
RETURN 
REM ************************************************
REM 		STANDARD MODULE SECTIONS BELOW
REM *************************************************
:ZINIT
REM Initialize printer program
REM Usage:
REM 	GOSUB ZINIT
	qDebugMsg$ = "Program " + qDispAppName$ + " starting..."
	GOSUB ZDEBUGMSG
REM 	GOSUB ZPRTMODEL
REM 	GOSUB zPRTFIRMWARE
	qDispTitle1$ = "Brother"
	qDispTitle2$ = _MODEL$
	qPort = 1
	qMinuteTmp = 0
	qDispLayout = 1
	GOSUB ZBASICS
	GOSUB ZDISPTIT
	GOSUB ZKEYINIT
	GOSUB ZGETDATARESET
	GOSUB ZDISPAPP
	qDebugMsg$ = "End of Initializing"
	GOSUB ZDEBUGMSG
RETURN
REM -------------------------------------------
:ZDISPTIT
REM Display program name on screen (Launch)
REM Usage:
REM 	qDispTitle1$ = "BROTHER"
REM		qDispTitle2$ = _MODEL$
REM		GOSUB ZDISPTIT
	qDispFGCol = 0
	qDispBGCol = 2942000000
		REM Screen Portrait
		IF qLCDScreen = 1 THEN
			DISPLAY qDispFGCol, qDispBGCol
			DISPLAY CLS
			qCheckFile$ = "Logo_GM.bmp"
			GOSUB ZCHECKFILE
			IF qCheckFile = 1 THEN
				DISPLAY (qXMax/2)-75, 200,"Logo_GM.bmp"
			ELSE
				DISPLAY (qXMax/2), 200, "0", 0, 12, 12, 2, qDispTitle1$
				DISPLAY (qXMax/2), 200 + 30, "0", 0, 9, 9, 2, qDispTitle2$
			ENDIF
		ENDIF
		REM Screen Landscape
		IF qLCDScreen = 2 THEN
			DISPLAY qDispFGCol, qDispBGCol
			DISPLAY CLS
			qCheckFile$ = "Logo_GM.bmp"
			GOSUB ZCHECKFILE
			IF qCheckFile = 1 THEN
				DISPLAY 90, 100,"Logo_GM.bmp"
			ELSE
				DISPLAY (qXMax/3), 100, "0", 0, qFntM, qFntM, 2, qDispTitle1$
				DISPLAY (qXMax/3), 100 + 30, "0", 0, qFntS, qFntS, 2, qDispTitle2$
			ENDIF		
		ENDIF
	DELAY 3000
RETURN
REM -------------------------------------------
:ZDISPAPP
REM FBPL Specific.
REM Appliciation typical screen
REM Usage:
REM qDispAppName$ = "My Application"	(could be set once at the beginning of the program)
REM qDispAppLine1$ = "Information Line1"
REM qDispAppLine2$ = "Sub information"
REM		GOSUB ZDISPAPP
REM 2 Different Layouts may be called:
REM LAYOUT 1:
REM =================================
REM	< prg vers>					<time>
REM _________________________________
REM | <Brother Logo>				|
REM |								|
REM |								|
REM |	   <qDispAppLine1$>			|
REM |								|
REM |								|
REM |	   <qDispAppLine2$>			|
REM |	<qDispAppLine2$>							|
REM _________________________________
REM LAYOUT 2:
REM =================================
REM	< Program Name> + <Version> <time>
REM _________________________________
REM |								|
REM |	  	<qDispAppLine1$>		|
REM |								|
REM |		<Input Field			|
REM |								|
REM _________________________________
	DISPLAY CLS
	IF qDispLayout = 1 THEN
		REM Theme: Layout 1 / Screen Portrait
		IF qLCDScreen = 1 THEN
			REM Line
			DISPLAY 0, 30, 320, 2, 2
			DISPLAY 0, qYMax - 30, 320, 2, 2
			REM Program Name
			qDispColor$ = "Blue"
			GOSUB ZDISPCOLOR
			DISPLAY 10, 5, "0", 0, qFntXS, qFntXS, 1, qDispAppName$ + "  (" + qProgVersion$+")"
			REM Display Logo
			DISPLAY 10, 40, qDispImage$
			qDispColor$ = "Black"
			GOSUB ZDISPCOLOR
			REM Test Texte width to center
			qTWStrg$ = qDispAppLine1$
			qTWFont$ = "0"
			qTWSize = qFntM
			GOSUB ZTESTWIDTH
			DISPLAY (qXMax/2 - strwidth/2), qYMax/4, "0", 0, qFntM, qFntM, 2, qDispAppLine1$
			qDispColor$ = "Grey"
			GOSUB ZDISPCOLOR
			qTWStrg$ = qDispAppLine2$
			qTWFont$ = "0"
			qTWSize = qFntS
			GOSUB ZTESTWIDTH
			DISPLAY (qXMax/2 - strwidth/2), 2*(qYMax/5), "0", 0, qFntS, qFntS, 2, qDispAppLine2$
			qDispColor$ = "Grey"
			GOSUB ZDISPCOLOR
			qTWStrg$ = qDispAppLine3$
			qTWFont$ = "0"
			qTWSize = qFntS
			GOSUB ZTESTWIDTH
			DISPLAY (qXMax/2 - strwidth/2), 2*(qYMax/5) + 30, "0", 0, qFntS, qFntS, 2, qDispAppLine3$
			qDispColor$ = "Black"
			GOSUB ZDISPCOLOR
			DISPLAY (qXMax/2)-66, 2*(qYMax/3),"Print_Button.bmp"
			REM Extra information
			GOSUB ZTIME
			DISPLAY qXMax - 35, 5, "0", 0, qFntXS, qFntXS, 3, qTime$
			REM Close Application Button
			qDispColor$ = "Red"
			GOSUB ZDISPCOLOR
			DISPLAY qXMax - 30, 35, 15, 20, 5
			qDispColor$ = "White"
			GOSUB ZDISPCOLOR
			DISPLAY qXMax - 27, 37, "0", 0, qFntXS, qFntXS, 3, "X"
			qDispColor$ = "Black"
			GOSUB ZDISPCOLOR
		ENDIF
		REM Theme: Layout 1 / Screen Landscape
		IF qLCDScreen = 2 THEN
			REM Line
			REM DISPLAY 0, 30, 320, 2, 2
			REM DISPLAY 0, qYMax - 30, 320, 2, 2
			REM Program Name
			qXPos = 70
			qYPos = 100
			REM DISPLAY qXPos, qYPos - 60, "0", 0, qFntM, qFntM, 2, qDispAppLine1$
			DISPLAY qXPos, qYPos - 60, "Logo_GM.bmp"
			qDispColor$ = "Grey"
			GOSUB ZDISPCOLOR
			DISPLAY (qXPos), (qYPos), "0", 0, qFntS, qFntS, 2, qDispAppLine2$
			qDispColor$ = "Blue"
			GOSUB ZDISPCOLOR
			DISPLAY (qXPos + 70), (qYPos), "0", 0, qFntS, qFntS, 2, qDispAppLine3$
			IF qLibelStp = 1 THEN
				REM Add extra line to show user which field to enter
				DISPLAY (qXPos + 70), (qYPos + 20), 100, 2, 2
			ENDIF
			qDispColor$ = "Grey"
			GOSUB ZDISPCOLOR
			DISPLAY (qXPos), (qYPos + 30), "0", 0, qFntS, qFntS, 2, qDispAppLine4$
			qDispColor$ = "Red"
			GOSUB ZDISPCOLOR
			DISPLAY (qXPos + 70), (qYPos + 30), "0", 0, qFntS, qFntS, 2, qDispAppLine5$
			IF qLibelStp = 2 THEN
				REM Add extra line to show user which field to enter
				DISPLAY (qXPos + 70), (qYPos + 50), 100, 2, 2
			ENDIF
			qDispColor$ = "Grey"
			GOSUB ZDISPCOLOR
			DISPLAY (qXPos), (qYPos + 60), "0", 0, qFntS, qFntS, 2, qDispAppLine6$
			qDispColor$ = "Green"
			GOSUB ZDISPCOLOR
			DISPLAY (qXPos + 70), (qYPos + 60), "0", 0, qFntS, qFntS, 2, qDispAppLine7$
			IF qLibelStp = 3 THEN
				REM Add extra line to show user which field to enter
				DISPLAY (qXPos + 70), (qYPos + 80), 100, 2, 2
			ENDIF
			qDispColor$ = "Black"
			GOSUB ZDISPCOLOR
		ENDIF
	ENDIF
	REM qDebugMsg$ = "	[Display]: " + qDispAppName$ + " / " + qDispAppLine1$ + " / " + qDispAppLine2$ + " / " + qDispAppLine3$ + " / " + qDispAppLine4$ + " / " + qDispAppLine5$
	REM qDebugMsg$ = "	[Display]: " + qDispAppName$ + " / " + qDispAppLine1$ + " / " + qDispAppLine2$
	REM GOSUB ZDEBUGMSG
RETURN
REM -------------------------------------------
:ZDISPQTY
REM Screen to ask for quantity
DISPLAY CLS
		DISPLAY qXPos, qYPos - 60, "Logo_GM.bmp"
		REM Theme: Layout 1 / Screen Landscape
		IF qLCDScreen = 2 THEN
			REM Line
			REM DISPLAY 0, 30, 320, 2, 2
			REM DISPLAY 0, qYMax - 30, 320, 2, 2
			REM Program Name
			qXPos = 70
			qYPos = 100
			REM DISPLAY qXPos, qYPos - 60, "0", 0, qFntM, qFntM, 2, qDispAppLine1$
			DISPLAY qXPos, qYPos - 60, "Logo_GM.bmp"
			qDispColor$ = "Grey"
			GOSUB ZDISPCOLOR
			DISPLAY (qXPos), (qYPos), "0", 0, qFntS, qFntS, 2, qDispAppLine2$
			qDispColor$ = "Blue"
			GOSUB ZDISPCOLOR
			DISPLAY (qXPos + 70), (qYPos + 40), "0", 0, qFntS, qFntS, 2, qDispAppLine8$
			qDispColor$ = "Black"
			GOSUB ZDISPCOLOR
			REM DISPLAY (qXMax)-95, qYMax - 25,"Print_Button-Small.bmp"
			REM DISPLAY 80, qYMax - 27,"Setting-Icon.bmp"
			REM Extra information
			REM GOSUB ZTIME
			REM DISPLAY 280, 10, "0", 0, 6, 6, 3, qTime$
		ENDIF
	ENDIF
	qDebugMsg$ = "	[Display Qty]: " + qDispAppName$ + " / " + qDispAppLine1$ + " / " + qDispAppLine2$ + " / " + qDispAppLine8$
	GOSUB ZDEBUGMSG
RETURN
REM -------------------------------------------
:ZDISPCOLOR
REM Modify Foreground color
	IF qDispColor$ = "Black" THEN qDispFGCol = 0
	IF qDispColor$ = "Dark Blue" THEN qDispFGCol = 202020
	IF qDispColor$ = "Blue" THEN qDispFGCol = 0020002000
	IF qDispColor$ = "Yellow" THEN qDispFGCol = 16776960
	IF qDispColor$ = "Orange" THEN qDispFGCol = 16744448
	IF qDispColor$ = "Red" THEN qDispFGCol = 16711680
	IF qDispColor$ = "White" THEN qDispFGCol = 16777215
	IF qDispColor$ = "Grey" THEN qDispFGCol = 6316128
	IF qDispColor$ = "Green" THEN qDispFGCol = 52224
	DISPLAY qDispFGCol, qDispBGCol
RETURN
REM -------------------------------------------
:ZDISPEND
REM clean screen
DISPLAY OFF
RETURN
REM -------------------------------------------
:ZKEYINIT
REM Initialize Keys
REM Notes:
REM 	KEY1 = Top Right (Feed)
REM 	KEY2 = Top Left (Menu)
REM 	KEY3 = Up arrow
REM 	KEY4 = Right arrow
REM 	KEY5 = Left arrow
REM 	KEY6 = Down arrow
REM Usage:
REM		GOSUB ZKEYINIT
	SET KEY1 OFF
	SET KEY2 OFF
	SET KEY3 OFF
	SET KEY4 OFF
	SET KEY5 OFF
	SET KEY6 OFF
	KEY1 = 0
	KEY2 = 0
	KEY3 = 0
	KEY4 = 0
	KEY5 = 0
	KEY6 = 0
	qKey = 0
	qKeyChanged = 0
RETURN
REM -------------------------------------------
:ZKEYDEFAULT
REM Return key to default values
	SET KEY1 DEFAULT
	SET KEY2 DEFAULT
	SET KEY3 DEFAULT
	SET KEY4 DEFAULT
	SET KEY5 DEFAULT
	SET KEY6 DEFAULT
RETURN
REM -------------------------------------------
:ZGETKEYPRESSED
REM Get key pressed
	REM qDebugMsg$ = "[ZGETKEYPRESSED]"
	REM GOSUB ZDEBUGMSG
	REM Get key pressed
	IF KEY1 = 1 THEN 
		qKey = 1
	ENDIF
	IF KEY2 = 1 THEN 
		qKey = 2
	ENDIF
	IF KEY3 = 1 THEN 
		qKey = 3
	ENDIF
	IF KEY4 = 1 THEN 
		qKey = 4
	ENDIF
	IF KEY5 = 1 THEN 
		qKey = 5
	ENDIF
	IF KEY6 = 1 THEN 
		qKey = 6
	ENDIF
	IF qKey <> 0 THEN
		REM qDebugMsg$ = "@SECOND - qKeyTimeLast: " + STR$(VAL(@SECOND) - qKeyTimeLast)
		REM GOSUB ZDEBUGMSG
		IF ABS((VAL(@SECOND) - qKeyTimeLast)) >=1 THEN
			qKeyTimeLast = VAL(@SECOND)
			qDebugMsg$ = "Key Pressed: " + STR$(qKey) + " - " + NOW$ ()
			GOSUB ZDEBUGMSG
			GOSUB zKEYFUNCTION
		ENDIF
	ENDIF
RETURN
REM -------------------------------------------
:zKEYFUNCTION
REM Handle default key function
	IF qKey = 1 THEN FORMFEED
	REM IF qKey = 1 THEN GOSUB ZPRINTDEMOLABEL
	IF qKey = 2 THEN GOSUB ZMENUDFLT
	REM IF qKey = 3 THEN GOSUB ZPRINTDEMOLABEL
	REM IF qKey = 4 THEN GOSUB ZPRINTDEMOLABEL
	IF qKey = 5 THEN GOSUB ZEND
	REM IF qKey = 6 THEN GOSUB ZPRINTDEMOLABEL
	REM Reset key value
	qKey = 0
RETURN
REM -------------------------------------------
:ZMENUDFLT
REM Display default user menus
	qDebugMsg$ = "Menu Screen [On]"
	GOSUB ZDEBUGMSG
	qMenuExit = 0
	:ZMENUDFLTLOOP
	OPEN "Setup Menu",0
	qList$ = FREAD$(0, LOF("Setup Menu"))
	CLOSE 0
	MENU "Setup Menu", qList$, qMenuItem$
	IF LEN(qMenuItem$) = 0 THEN qKey = 0
	REM IF qMenuItem$ <>"" THEN
	REM 	qDebugMsg$ = "Menu Item: " + qMenuItem$
	REM 	GOSUB ZDEBUGMSG
	REM ENDIF
	IF qMenuItem$ = "Language >" THEN GOSUB ZMENULANG
	REM IF qMenuItem$ = "Miscellaneous >" THEN GOSUB ZMENUMISC
	IF qMenuItem$ = "Exit" THEN GOSUB ZEND
	IF qMenuExit = 1 THEN 
		qDebugMsg$ = "Menu Screen [EXIT]"
		GOSUB ZDEBUGMSG
		GOTO ZMAINAPP
	ENDIF
	GOTO ZMENUDFLTLOOP
	qDebugMsg$ = "Menu Screen [OFF]"
	GOSUB ZDEBUGMSG
RETURN
REM -------------------------------------------
:ZMENULANG
	qDebugMsg$ = "Menu Screen [LANGUAGE]"
	GOSUB ZDEBUGMSG
	qMenuItem$=""
	qKey = 0
	:ZMENULANGLOOP
	OPEN "Language",0
	qList$ = FREAD$(0, LOF("Language"))
	CLOSE 0
	MENU "Language", qList$, qMenuItem$
	IF LEN(qMenuItem$) = 0 THEN qKey = 0
	IF qMenuItem$ <>"" THEN
		qDebugMsg$ = "Menu Item: " + qMenuItem$
	 	GOSUB ZDEBUGMSG
	ENDIF
	IF qMenuItem$ = "English" THEN 
		qLang$ = "EN"
		GOSUB ZCFGSAVE
		qMenuExit = 1
		SOUND 2,100
		SOUND 3,100
	ENDIF
	IF qMenuItem$ = "French" THEN 
		qLang$ = "FR"
		GOSUB ZCFGSAVE
		qMenuExit = 1
		SOUND 2,100
		SOUND 3,100
	ENDIF
	IF qMenuItem$ = "German" THEN 
		qLang$ = "DE"
		GOSUB ZCFGSAVE
		qMenuExit = 1
		SOUND 2,100
		SOUND 3,100
	ENDIF
	IF qMenuItem$ = "Spanish" THEN 
		qLang$ = "SP"
		GOSUB ZCFGSAVE
		qMenuExit = 1
		SOUND 2,100
		SOUND 3,100
	ENDIF
	IF qMenuExit = 1 THEN 
		REM qDebugMsg$ = "Menu Screen Language [EXIT]"
		REM GOSUB ZDEBUGMSG
		RETURN
	ENDIF
	GOTO ZMENULANGLOOP
RETURN
REM -------------------------------------------
:ZCFGSAVE
REM Save Current configuration in Flash
	qDebugMsg$ = "Write down and Save config file"
	GOSUB ZDEBUGMSG
	OPEN "CONFIG.DAT",1
	SEEK 1,0
	WRITE 1, qLang$
	CLOSE 1
RETURN
REM -------------------------------------------
:ZCFGREAD
REM Save Current configuration in Flash
	qDebugMsg$ = "Read config file"
	GOSUB ZDEBUGMSG
	OPEN "CONFIG.DAT",1
	SEEK 1,0
	READ 1, qLang$
	CLOSE 1
RETURN
REM -------------------------------------------
:ZBASICS
REM Retrieve different type of settings in variables.
	qPrinter$ = _MODEL$
	qPrinterFw$ = GETSETTING$("SYSTEM","INFORMATION","VERSION")
	qPrinterSN$ = GETSETTING$("SYSTEM","INFORMATION","SERIAL")
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	REM 	Check for LCD model and  portrait (=1) or landscape (=2)
	IF qPrinter$ = "TJ-4020TN" THEN qLCDScreen = 0
	IF qPrinter$ = "TJ-4120TN" THEN qLCDScreen = 0
	IF qPrinter$ = "TD-4420TN" THEN qLCDScreen = 0
	IF qPrinter$ = "TD-4520TN" THEN qLCDScreen = 0
	IF qPrinter$ = "TJ-4021TN" THEN 
		qLCDScreen = 1
		REM Resolution is 320x480
		qXMax = 320
		qYMax = 480
	ENDIF
	IF qPrinter$ = "TJ-4021TNR" THEN 
		qLCDScreen = 1
		REM Resolution is 320x480
		qXMax = 320
		qYMax = 480
	ENDIF
	IF qPrinter$ = "TJ-4121TN" THEN 
		qLCDScreen = 1
		REM Resolution is 320x480
		qXMax = 320
		qYMax = 480
	ENDIF
	IF qPrinter$ = "TJ-4121TNR" THEN 
		qLCDScreen = 1
		REM Resolution is 320x480
		qXMax = 320
		qYMax = 480
	ENDIF
	IF qPrinter$ = "TJ-4422TN" THEN 
		qLCDScreen = 1
		REM Resolution is 275x480
		qXMax = 275
		qYMax = 480
	ENDIF
	IF qPrinter$ = "TJ-4522TN" THEN
		qLCDScreen = 1
		REM Resolution is 275x480
		qXMax = 275
		qYMax = 480
	ENDIF
	IF qPrinter$ = "TJ-4420TN" THEN 
		qLCDScreen = 2
		REM Resolution is 320x240
		qXMax = 320
		qYMax = 240
	ENDIF
	IF qPrinter$ = "TJ-4520TN" THEN
		qLCDScreen = 2
		REM Resolution is 320x240
		qXMax = 320
		qYMax = 240
	ENDIF
	IF qPrinter$ = "TD-4650TNWB" THEN 
		qLCDScreen = 2
		REM Resolution is 320x240
		qXMax = 320
		qYMax = 240
	ENDIF
	IF qPrinter$ = "TD-4650TNWBR" THEN 
		qLCDScreen = 2
		REM Resolution is 320x240
		qXMax = 320
		qYMax = 240
	ENDIF
	IF qPrinter$ = "TD-4750TNWB" THEN 
		qLCDScreen = 2
		REM Resolution is 320x240
		qXMax = 320
		qYMax = 240
	ENDIF
	IF qPrinter$ = "TD-4750TNWBR" THEN 
		qLCDScreen = 2
		REM Resolution is 320x240
		qXMax = 320
		qYMax = 240
	ENDIF
	IF qLCDScreen = 1 THEN
		IF qPrinter$ = "TJ-4021TN" THEN 
			qFntL = 15
			qFntM = 12
			qFntS = 8
			qFntXS = 6
		ENDIF
		IF qPrinter$ = "TJ-4121TN" THEN 
			qFntL = 13
			qFntM = 9
			qFntS = 6
			qFntXS = 4
		ENDIF
		IF qPrinter$ = "TJ-4422TN" THEN 
			qFntL = 15
			qFntM = 12
			qFntS = 8
			qFntXS = 6
		ENDIF
		IF qPrinter$ = "TJ-4522TN" THEN 
			qFntL = 13
			qFntM = 9
			qFntS = 6
			qFntXS = 4
		ENDIF
	ENDIF
	IF qLCDScreen = 2 THEN
		IF qPrinter$ = "TD-4650TNWB" THEN 
			qFntL = 12
			qFntM = 10
			qFntS = 7
			qFntXS = 5
		ELSE
			qFntL = 9
			qFntM = 7
			qFntS = 6
			qFntXS = 4
		ENDIF
	ENDIF
	qDebugMsg$ = qPrinter$ + " (" + qTphDpi$ + " dpi)  - Version: " + qPrinterFw$
	GOSUB ZDEBUGMSG
	qDebugMsg$ = qPrinter$ + ": " + qPrinterSN$ + "/" + STR$(qLCDScreen)
	GOSUB ZDEBUGMSG
RETURN
REM -------------------------------------------
:ZBGNDTASKS
REM Perform background tasks to mainly check printer status
REM To avoid slowing down the system, background tasks are performed at a low frequency
	REM qBgndFreq = time between each verification. 500 ~ 4 seconds
	qBgndFreq = 500
	qBgndCnt = qBgndCnt + 1
	IF qBgndCnt > qBgndFreq THEN
		REM qDebugMsg$ = "[ZBGNDTASKS]"
		REM GOSUB ZDEBUGMSG
		REM Print head open Status
		qTphStatus = GETSENSOR("HEAD UP")
			IF qTphStatus = 1 THEN 
				qDebugMsg$ = "TPH Open"
				GOSUB ZDEBUGMSG
			ENDIF
		REM Time Display Refresh
		IF VAL(@MINUTE)=0 THEN
			qMinuteTmp = -1
		ENDIF
		IF (VAL(@MINUTE) - qMinuteTmp)>0 THEN
			qDebugMsg$ = "[Time Refresh]"
			GOSUB ZDEBUGMSG
			qMinuteTmp = VAL(@MINUTE)
			GOSUB ZDISPAPP
			REM qDebugMsg$ = "VAL(@MINUTE): " + STR$(VAL(@MINUTE)
			REM GOSUB ZDEBUGMSG
			REM qDebugMsg$ = "qMinuteTmp: " + STR$(qMinuteTmp)
			REM GOSUB ZDEBUGMSG
		ENDIF
		qBgndCnt = 0
	ENDIF
RETURN
REM -------------------------------------------
:ZCHECKFILE
REM Check if File exists
REM Usage:
REM		qCheckFile$ = "MyFile.bmp"
REM		GOSUB ZCHECKFILE
REM 	IF qCheckFile = 1 THEN ...
	qCheckFile = 0
	IF LOF(qCheckFile$) > 0 THEN qCheckFile = 1
RETURN
REM -------------------------------------------
:ZTIME
REM Return Time Format
REM Usage:
REM		GOSUB ZTIME
REM 	DISPLAY 280, 10, "0", 0, 6, 6, 3, qTime$
REM	Out:
REM		qTime$ Format = HH:MM
	IF VAL(@HOUR)<10 THEN
		qHour$ = "0" + @HOUR
	ELSE
		qHour$ = @HOUR
	ENDIF
	IF VAL(@MINUTE)<10 THEN
		qMinute$ = "0" + @MINUTE
	ELSE
		qMinute$ = @MINUTE
	ENDIF	
	qTime$ = qHour$ + ":" + qMinute$
RETURN
REM -------------------------------------------
:ZGETDATA
REM Capture Data on incoming port
	IF LOB( )<>0 THEN 
		qGetDataIn$ = INP$( qPort )
		IF ASC(qGetDataIn$) = 27 THEN
			RUN "GESTMAG.BAS"
		ELSEIF ASC(qGetDataIn$) = 96 THEN
			FORMFEED
		ELSEIF ASC(qGetDataIn$) = 13 THEN
			REM qDebugMsg$ = "\tIn ==> [CR]"
			REM GOSUB ZDEBUGMSG
			qGetDataIn$ = ""
			qDataEnd = 1
		ELSEIF ASC(qGetDataIn$) = 10 THEN
			REM qDebugMsg$ = "\tIn ==> [LF]"
			REM GOSUB ZDEBUGMSG
			qGetDataIn$ = ""
			REM qDataEnd = 1
		ELSEIF ASC(qGetDataIn$) = 8 THEN
			REM qDebugMsg$ = "\tIn ==> [DEL]"
			REM GOSUB ZDEBUGMSG
			qGetDataIn$ = ""
			qData$ = LEFT$(qData$, LEN(qData$) - 1)
			REM qDataEnd = 1
		ELSEIF qDataEnd = 0 THEN
			IF qGetDataIn$<>"" THEN
				REM qDebugMsg$ = "\tIn ==> [" + qGetDataIn$ + "] (" + STR$(ASC(qGetDataIn$)) + ")"
				REM GOSUB ZDEBUGMSG
				REM Conversion from QWERTY to AZERTY (FR) in case of Keyboard usage
				IF qGetDataIn$ = "Q" THEN 
					qGetDataIn$ = "A"
				ELSEIF qGetDataIn$ = "A" THEN 
					qGetDataIn$ = "Q"
				ENDIF
				IF qGetDataIn$ = "q" THEN 
					qGetDataIn$ = "a"
				ELSEIF qGetDataIn$ = "a" THEN 
					qGetDataIn$ = "q"
				ENDIF
				IF qGetDataIn$ = "W" THEN 
					qGetDataIn$ = "Z"
				ELSEIF qGetDataIn$ = "Z" THEN 
					qGetDataIn$ = "W"
				ENDIF
				IF qGetDataIn$ = "w" THEN 
					qGetDataIn$ = "z"
				ELSEIF qGetDataIn$ = "z" THEN 
					qGetDataIn$ = "w"
				ENDIF
				IF qGetDataIn$ = ";" THEN
					qGetDataIn$ = "m"
				ELSEIF qGetDataIn$ = "m" THEN
					qGetDataIn$ = ";"
				ENDIF
				IF qGetDataIn$ = ":" THEN
					qGetDataIn$ = "M"
				ELSEIF qGetDataIn$ = "M" THEN
					qGetDataIn$ = ":"
				ENDIF
				IF qGetDataIn$ = ";" THEN
					qGetDataIn$ = ","
				ELSEIF qGetDataIn$ = "," THEN
					qGetDataIn$ = ";"
				ENDIF
				IF qGetDataIn$ = "<" THEN
					qGetDataIn$ = "."
				ELSEIF qGetDataIn$ = ">" THEN
					qGetDataIn$ = "/"
				ENDIF
				IF qGetDataIn$ = "/" THEN
					qGetDataIn$ = "!"
				ELSEIF qGetDataIn$ = "?" THEN
					qGetDataIn$ = "§"
				ENDIF
				qData$ = qData$ + qGetDataIn$
				qDataEnd = 0
				REM qTicks = SECOND
			ENDIF
		ENDIF
	ENDIF
	REM Create timing check to escape from loop in case of no CR/LF
	REM IF (VAL(@SECOND) - qTicks)>2 THEN
	REM 		qDebugMsg$ = "\tIn ==> [Time-Out]"
	REM 		GOSUB ZDEBUGMSG
	REM 		qGetDataIn$ = ""
	REM 		qDataEnd = 1
	REM ENDIF
RETURN
REM -------------------------------------------
:ZGETDATARESET
	qData$=""
	qDataEnd = 0
RETURN
REM -------------------------------------------
:ZGETDATASTATUS
	qDataIsAvl = 0
	IF LOB( )<>0 THEN qDataIsAvl = 1
RETURN
REM -------------------------------------------
:ZTESTWIDTH
REM	Provide width of a text
REM Usage:
REM 	qTWStrg$ = "My Demo Application"
REM 	qTWFont$ = "0"
REM 	qTWSize = 12
REM		strwidth = TEXTPIXEL(qTWStrg$,qTWFont$,qTWSize)
REM: Do not change the name of the value strwidth (otherwise it won't work)
	 strwidth = 0
	 strwidth=TEXTPIXEL(qTWStrg$,qTWFont$,qTWSize)
	REM qDebugMsg$ = STR$( strwidth ) + " pixels"
	REM GOSUB ZDEBUGMSG
RETURN
REM -------------------------------------------
:ZDEBUGMSG
REM Initialize DEBUG Information
REM Usage:
REM		qDebug = 1
REM 	qDebugPort$ = "NET"
REM		qDebugMsg$ = "Test Message"
REM		GOSUB ZDEBUGMSG
	IF qDebug THEN
		IF qDebugPort$ = "NET" THEN
			OUT NET "DEBUG: ";qDebugMsg$
		ENDIF
		IF qDebugPort$ = "COM" THEN
			OUT COM "DEBUG: ";qDebugMsg$
		ENDIF
	ENDIF
RETURN
REM -------------------------------------------
:ZEND
REM Cleaning items before ending program
REM Usage:
REM		GOSUB ZEND
	qDebugMsg$ = "End of program"
	GOSUB ZDEBUGMSG
	GOSUB ZDISPEND
	GOSUB ZKEYDEFAULT
EOP
REM -------------------------------------------
REM Menu sections (may be edited carefully)
DOWNLOAD F,"Setup Menu"
Language >
Exit
EOP
DOWNLOAD F,"Language"
English
French
German
Spanish
EOP
DOWNLOAD F,"Miscellaneous"
Sub Menu Misc 1
Sub Menu Misc 2
Sub Menu Misc 3
EOP
DOWNLOAD F,"1.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	REM Vérification que le code EAN a bien 12 caractères
    IF LEN(qItem1$) <> 12 THEN
        CLS
        TEXT 187, 120, "0",0, 12, 12, 2, "CODE EAN INVALIDE"
		TEXT 187, 150, "0",0, 12, 12, 2, "DOIT AVOIR"
        TEXT 187, 180, "0",0, 12, 12, 2, "12 CHIFFRES"
        PRINT 1
        END
    ENDIF
    IF qTphDpi$ = "203" THEN
        REM Format 46x39mm
        CLS
        DIRECTION 1
        BARCODE 187, 78, "EAN13", 100, 1, 0, 2, 1, 2, qItem1$
        PRINT VAL(qQty$)
    ELSE
        REM Pour autres résolutions
    ENDIF
EOP
DOWNLOAD F,"1.INI"
REM - Init file for Template
Menu = 1
Item_1 = CAB
EOP
DOWNLOAD F,"2.BAS"
    qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
    REM Vérification que le code EAN a bien 12 caractères
    IF LEN(qItem1$) <> 12 THEN
        CLS
        TEXT 187, 120, "0",0, 12, 12, 2, "CODE EAN INVALIDE"
		TEXT 187, 150, "0",0, 12, 12, 2, "DOIT AVOIR"
        TEXT 187, 180, "0",0, 12, 12, 2, "12 CHIFFRES"
        PRINT 1
        END
    ENDIF
    IF qTphDpi$ = "203" THEN
        REM Format 46x39mm
        CLS
        DIRECTION 1
        BARCODE 187, 70, "EAN13", 80, 1, 0, 2, 1, 2, qItem1$
        TEXT 187, 180, "0", 0, 14, 14, 2, "PRIX: " + qItem2$ + "€"
        PRINT VAL(qQty$)
    ELSE
        REM Pour autres résolutions
    ENDIF
EOP
DOWNLOAD F,"2.INI"
REM - Init file for Template
Menu = 2
Item_1 = CAB
Item_2 = Prix
EOP
DOWNLOAD F,"3.BAS"
    qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
    REM Vérification que le code EAN a bien 12 caractères
    IF LEN(qItem2$) <> 12 THEN
        CLS
        TEXT 187, 120, "0",0, 12, 12, 2, "CODE EAN INVALIDE"
		TEXT 187, 150, "0",0, 12, 12, 2, "DOIT AVOIR"
        TEXT 187, 180, "0",0, 12, 12, 2, "12 CHIFFRES"
        PRINT 1
        END
    ENDIF
    IF qTphDpi$ = "203" THEN
        REM Format 46x39mm
        CLS
        DIRECTION 1
        TEXT 187, 30, "0",0, 12, 12, 2, qItem1$
        BARCODE 187, 70, "EAN13", 80, 1, 0, 2, 1, 2, qItem2$
        TEXT 187, 180, "0", 0, 14, 14, 2, "PRIX: " + qItem3$ + "€"
        PRINT VAL(qQty$)
    ELSE
        REM Pour autres résolutions
    ENDIF
EOP
DOWNLOAD F,"3.INI"
REM - Init file for Template
Menu = 3
Item_1 = Libelle
Item_2 = CAB
Item_3 = Prix
EOP
REM ---------------- FORMAT ROND de 1€ a 9 € ---------------------
DOWNLOAD F,"PRI0.BAS"
qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL(qItem1$ + "€", "0", 72)
		qStart = 160 - (qW1 / 2)
		TEXT qStart, 75, "0",0, 72, 72, 1, qItem1$ + "€"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"PRI0.INI"
Menu = 1
Item_1 = Prix
EOP
REM ---------------- FORMAT OVALE de 1€ a 9 € ---------------------
DOWNLOAD F,"V0.BAS"
qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL(qItem1$ + "€", "0", 72)
		qStart = 160 - (qW1 / 2)
		TEXT qStart, 75, "0",0, 72, 72, 1, qItem1$ + "€"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"V0.INI"
Menu = 1
Item_1 = Prix
EOP
DOWNLOAD F,"PRI01.BAS"
    qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
    IF qTphDpi$ = "203" THEN
        REM Configuration pour TD-4650TNWB (203 DPI)
        CLS
        DIRECTION 1
        REM Calcul de la largeur du texte prix
        qPrixText$ = qItem1$ + "€"
        qTextWidth = TEXTPIXEL(qPrixText$, "0", 30)
        REM Avec DIRECTION 1 (rotation 90°):
        REM - Le paramètre X devient la position sur la LARGEUR physique (46mm)
        REM - 46mm à 203 DPI = environ 360 pixels
        REM Centre sur l'axe principal
        REM Ajustement manuel : 240 était trop à gauche, on tente 260
        qCenter = 260
        qXPos = qCenter - (qTextWidth / 2)
        REM Position Y (reste identique sur la hauteur)
        qYPos = 110
        TEXT qXPos, qYPos, "0", 0, 30, 30, 2, qPrixText$
        PRINT VAL(qQty$)
    ELSE
        REM To work for TD-4750TNWB
    ENDIF
EOP
DOWNLOAD F,"PRI01.INI"
REM - Init file for Template
Menu = 1
Item_1 = Prix
EOP
DOWNLOAD F,"PRI02.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	qVir = INSTR(qItem1$,".")
	qPrixLeft$ = LEFT$(qItem1$,qVir-1)
	qPrixRight$ = RIGHT$(qItem1$,(LEN(qItem1$)-qVir))
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL(qPrixLeft$, "0", 60)
		qW2 = TEXTPIXEL("€" + qPrixRight$, "0", 40)
		qStart = 160 - ((qW1 + qW2) / 2)
		TEXT qStart, 100, "0",0, 60, 60, 1, qPrixLeft$
		TEXT qStart + qW1, 100, "0",0, 40, 40, 1,  "€" + qPrixRight$
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"PRI02.INI"
REM - Init file for Template
Menu = 1
Item_1 = Prix
EOP
DOWNLOAD F,"PRI03.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	REM Vérification que le code EAN a bien 12 caractères
    IF LEN(qItem2$) <> 12 THEN
        CLS
        TEXT 187, 120, "0",0, 12, 12, 2, "CODE EAN INVALIDE"
		TEXT 187, 150, "0",0, 12, 12, 2, "DOIT AVOIR"
        TEXT 187, 180, "0",0, 12, 12, 2, "12 CHIFFRES"
        PRINT 1
        END
    ENDIF
	qVir = INSTR(qItem1$,".")
	IF qVir > 0 THEN
		qPrixUnit$ = LEFT$(qItem1$,qVir-1)
	ELSE
		qPrixUnit$ = qItem1$
	ENDIF
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL(qPrixUnit$ + "€", "0", 40)
		qStart = 187 - (qW1 / 2)
		TEXT qStart, 50, "0",0, 40, 40, 1, qPrixUnit$ + "€"
		BARCODE 187, 160, "EAN13",80, 1, 0, 2, 1, 2, qItem2$
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"PRI03.INI"
REM - Init file for Template
Menu = 2
Item_1 = Prix
Item_2 = CAB
EOP
DOWNLOAD F,"PRI04.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	REM Vérification que le code EAN a bien 12 caractères
    IF LEN(qItem2$) <> 12 THEN
        CLS
        TEXT 187, 120, "0",0, 12, 12, 2, "CODE EAN INVALIDE"
		TEXT 187, 150, "0",0, 12, 12, 2, "DOIT AVOIR"
        TEXT 187, 180, "0",0, 12, 12, 2, "12 CHIFFRES"
        PRINT 1
        END
    ENDIF
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL(qItem1$ + "€", "0", 16)
		qStart = 187 - (qW1 / 2)
		TEXT qStart, 40, "0",0, 16, 16, 1, qItem1$ + "€"
		BARCODE 187,100, "EAN13",80, 1, 0, 2, 1, 2, qItem2$
		qW3 = TEXTPIXEL(qItem3$, "0", 11)
		qStart3 = 187 - (qW3 / 2)
		TEXT qStart3, 220, "0",0, 11, 11, 1, qItem3$
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"PRI04.INI"
REM - Init file for Template
Menu = 3
Item_1 = Prix
Item_2 = CAB
Item_3 = Libelle
EOP
DOWNLOAD F,"PRI05.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	REM Vérification que le code EAN a bien 12 caractères
    IF LEN(qItem2$) <> 12 THEN
        CLS
        TEXT 187, 120, "0",0, 12, 12, 2, "CODE EAN INVALIDE"
		TEXT 187, 150, "0",0, 12, 12, 2, "DOIT AVOIR"
        TEXT 187, 180, "0",0, 12, 12, 2, "12 CHIFFRES"
        PRINT 1
        END
    ENDIF
	qVir = INSTR(qItem1$,".")
	IF qVir > 0 THEN
		qPrixLeft$ = LEFT$(qItem1$,qVir-1)
		qPrixRight$ = RIGHT$(qItem1$,(LEN(qItem1$)-qVir))
	ELSE
		qPrixLeft$ = qItem1$
		qPrixRight$ = "00"
	ENDIF
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL(qPrixLeft$, "0", 40)
		qW2 = TEXTPIXEL("€" + qPrixRight$, "0", 25)
		qStart = 187 - ((qW1 + qW2) / 2)
		TEXT qStart, 50, "0",0, 40, 40, 1, qPrixLeft$
		TEXT qStart + qW1, 50, "0",0, 25, 25, 1,  "€" + qPrixRight$
		BARCODE 187, 160, "EAN13",80, 1, 0, 2, 1, 2, qItem2$
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"PRI05.INI"
REM - Init file for Template
Menu = 2
Item_1 = Prix
Item_2 = CAB
EOP
DOWNLOAD F,"PRI07.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		REM Ancien Prix (Barre)
		qW1 = TEXTPIXEL(qItem1$ + "€", "0", 35)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 60, "0",0, 35, 35, 1, qItem1$ + "€"
		BAR qStart1, 85, qW1, 4
		REM Nouveau Prix
		qW2 = TEXTPIXEL(qItem2$ + "€", "0", 35)
		qStart2 = 187 - (qW2 / 2)
		TEXT qStart2, 187, "0",0, 35, 35, 1, qItem2$ + "€"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"PRI07.INI"
REM - Init file for Template
Menu = 2
Item_1 = Ancien
Item_2 = Nouveau
EOP
DOWNLOAD F,"DLC02.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	REM Vérification que le code EAN a bien 12 caractères
    IF LEN(qItem2$) <> 12 THEN
        CLS
        TEXT 187, 120, "0",0, 12, 12, 2, "CODE EAN INVALIDE"
		TEXT 187, 150, "0",0, 12, 12, 2, "DOIT AVOIR"
        TEXT 187, 180, "0",0, 12, 12, 2, "12 CHIFFRES"
        PRINT 1
        END
    ENDIF
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL(qItem1$ + "€", "0", 16)
		qStart = 187 - (qW1 / 2)
		qW1 = TEXTPIXEL("D.L.C", "0", 16)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 20, "0",0, 16, 16, 1, "D.L.C"
		qW2 = TEXTPIXEL("COURTE", "0", 16)
		qStart2 = 187 - (qW2 / 2)
		TEXT qStart2, 70, "0",0, 16, 16, 1, "COURTE"
		qW3 = TEXTPIXEL(qItem1$ + "€", "0", 20)
		qStart3 = 187 - (qW3 / 2)
		TEXT qStart3, 120, "0",0, 20, 20, 1, qItem1$ + "€"
		BARCODE 187,180, "EAN13",80, 1, 0, 2, 1, 2, qItem2$
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"DLC02.INI"
REM - Init file for Template
Menu = 2
Item_1 = Prix
Item_2 = CAB
EOP
DOWNLOAD F,"DLC01.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL("D.L.C", "0", 30)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 70, "0",0, 30, 30, 1, "D.L.C"
		qW2 = TEXTPIXEL("COURTE", "0", 30)
		qStart2 = 187 - (qW2 / 2)
		TEXT qStart2, 150, "0",0, 30, 30, 1, "COURTE"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"DLC01.INI"
REM - Init file for Template
Menu = 0
EOP
DOWNLOAD F,"DLC30.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL("D.L.C", "0", 16)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 15, "0",0, 16, 16, 1, "D.L.C"
		qW2 = TEXTPIXEL("COURTE", "0", 16)
		qStart2 = 187 - (qW2 / 2)
		TEXT qStart2, 55, "0",0, 16, 16, 1, "COURTE"
		qW3 = TEXTPIXEL("A CONSOMMER RAPIDEMENT", "0", 8)
		qStart3 = 187 - (qW3 / 2)
		TEXT qStart3, 100, "0",0, 8, 8, 1, "A CONSOMMER RAPIDEMENT"
		qW4 = TEXTPIXEL("-30%", "0", 40)
		qStart4 = 187 - (qW4 / 2)
		TEXT qStart4, 135, "0",0, 40, 40, 1, "-30%"
		qW5 = TEXTPIXEL("REMISE IMMEDIATE", "0", 10)
		qStart5 = 187 - (qW5 / 2)
		TEXT qStart5, 230, "0",0, 10, 10, 1, "REMISE IMMEDIATE"
		qW6 = TEXTPIXEL("EN CAISSE", "0", 10)
		qStart6 = 187 - (qW6 / 2)
		TEXT qStart6, 265, "0",0, 10, 10, 1, "EN CAISSE"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"DLC30.INI"
REM - Init file for Template
Menu = 0
EOP
DOWNLOAD F,"DLC40.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL("D.L.C", "0", 16)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 15, "0",0, 16, 16, 1, "D.L.C"
		qW2 = TEXTPIXEL("COURTE", "0", 16)
		qStart2 = 187 - (qW2 / 2)
		TEXT qStart2, 55, "0",0, 16, 16, 1, "COURTE"
		qW3 = TEXTPIXEL("A CONSOMMER RAPIDEMENT", "0", 8)
		qStart3 = 187 - (qW3 / 2)
		TEXT qStart3, 100, "0",0, 8, 8, 1, "A CONSOMMER RAPIDEMENT"
		qW4 = TEXTPIXEL("-40%", "0", 40)
		qStart4 = 187 - (qW4 / 2)
		TEXT qStart4, 135, "0",0, 40, 40, 1, "-40%"
		qW5 = TEXTPIXEL("REMISE IMMEDIATE", "0", 10)
		qStart5 = 187 - (qW5 / 2)
		TEXT qStart5, 230, "0",0, 10, 10, 1, "REMISE IMMEDIATE"
		qW6 = TEXTPIXEL("EN CAISSE", "0", 10)
		qStart6 = 187 - (qW6 / 2)
		TEXT qStart6, 265, "0",0, 10, 10, 1, "EN CAISSE"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"DLC40.INI"
REM - Init file for Template
Menu = 0
EOP
DOWNLOAD F,"DLC20.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL("D.L.C", "0", 16)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 15, "0",0, 16, 16, 1, "D.L.C"
		qW2 = TEXTPIXEL("COURTE", "0", 16)
		qStart2 = 187 - (qW2 / 2)
		TEXT qStart2, 55, "0",0, 16, 16, 1, "COURTE"
		qW3 = TEXTPIXEL("A CONSOMMER RAPIDEMENT", "0", 8)
		qStart3 = 187 - (qW3 / 2)
		TEXT qStart3, 100, "0",0, 8, 8, 1, "A CONSOMMER RAPIDEMENT"
		qW4 = TEXTPIXEL("-20%", "0", 40)
		qStart4 = 187 - (qW4 / 2)
		TEXT qStart4, 135, "0",0, 40, 40, 1, "-20%"
		qW5 = TEXTPIXEL("REMISE IMMEDIATE", "0", 10)
		qStart5 = 187 - (qW5 / 2)
		TEXT qStart5, 230, "0",0, 10, 10, 1, "REMISE IMMEDIATE"
		qW6 = TEXTPIXEL("EN CAISSE", "0", 10)
		qStart6 = 187 - (qW6 / 2)
		TEXT qStart6, 265, "0",0, 10, 10, 1, "EN CAISSE"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"DLC20.INI"
REM - Init file for Template
Menu = 0
EOP
DOWNLOAD F,"DLC50.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL("D.L.C", "0", 16)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 15, "0",0, 16, 16, 1, "D.L.C"
		qW2 = TEXTPIXEL("COURTE", "0", 16)
		qStart2 = 187 - (qW2 / 2)
		TEXT qStart2, 55, "0",0, 16, 16, 1, "COURTE"
		qW3 = TEXTPIXEL("A CONSOMMER RAPIDEMENT", "0", 8)
		qStart3 = 187 - (qW3 / 2)
		TEXT qStart3, 100, "0",0, 8, 8, 1, "A CONSOMMER RAPIDEMENT"
		qW4 = TEXTPIXEL("-50%", "0", 40)
		qStart4 = 187 - (qW4 / 2)
		TEXT qStart4, 135, "0",0, 40, 40, 1, "-50%"
		qW5 = TEXTPIXEL("REMISE IMMEDIATE", "0", 10)
		qStart5 = 187 - (qW5 / 2)
		TEXT qStart5, 230, "0",0, 10, 10, 1, "REMISE IMMEDIATE"
		qW6 = TEXTPIXEL("EN CAISSE", "0", 10)
		qStart6 = 187 - (qW6 / 2)
		TEXT qStart6, 265, "0",0, 10, 10, 1, "EN CAISSE"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"DLC50.INI"
REM - Init file for Template
Menu = 0
EOP
DOWNLOAD F,"DLC70.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL("D.L.C", "0", 16)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 15, "0",0, 16, 16, 1, "D.L.C"
		qW2 = TEXTPIXEL("COURTE", "0", 16)
		qStart2 = 187 - (qW2 / 2)
		TEXT qStart2, 55, "0",0, 16, 16, 1, "COURTE"
		qW3 = TEXTPIXEL("A CONSOMMER RAPIDEMENT", "0", 8)
		qStart3 = 187 - (qW3 / 2)
		TEXT qStart3, 100, "0",0, 8, 8, 1, "A CONSOMMER RAPIDEMENT"
		qW4 = TEXTPIXEL("-70%", "0", 40)
		qStart4 = 187 - (qW4 / 2)
		TEXT qStart4, 135, "0",0, 40, 40, 1, "-70%"
		qW5 = TEXTPIXEL("REMISE IMMEDIATE", "0", 10)
		qStart5 = 187 - (qW5 / 2)
		TEXT qStart5, 230, "0",0, 10, 10, 1, "REMISE IMMEDIATE"
		qW6 = TEXTPIXEL("EN CAISSE", "0", 10)
		qStart6 = 187 - (qW6 / 2)
		TEXT qStart6, 265, "0",0, 10, 10, 1, "EN CAISSE"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"DLC70.INI"
REM - Init file for Template
Menu = 0
EOP
DOWNLOAD F,"PRO01.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL("A", "0", 30)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 60, "0",0, 30, 30, 1, "A"
		qW2 = TEXTPIXEL("SAISIR", "0", 30)
		qStart2 = 187 - (qW2 / 2)
		TEXT qStart2, 150, "0",0, 30, 30, 1, "SAISIR"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"PRO01.INI"
REM - Init file for Template
Menu = 0
EOP
DOWNLOAD F,"PRO02.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL("PETIT", "0", 30)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 60, "0",0, 30, 30, 1, "PETIT"
		qW2 = TEXTPIXEL("PRIX", "0", 30)
		qStart2 = 187 - (qW2 / 2)
		TEXT qStart2, 150, "0",0, 30, 30, 1, "PRIX"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"PRO02.INI"
REM - Init file for Template
Menu = 0
EOP
DOWNLOAD F,"PRO03.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL("SOLDE", "0", 40)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 100, "0",0, 40, 40, 1, "SOLDE"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"PRO03.INI"
REM - Init file for Template
Menu = 0
EOP
DOWNLOAD F,"PRO04.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL("OFFRE", "0", 25)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 60, "0",0, 25, 25, 1, "OFFRE"
		qW2 = TEXTPIXEL("SPECIALE", "0", 25)
		qStart2 = 187 - (qW2 / 2)
		TEXT qStart2, 150, "0",0, 25, 25, 1, "SPECIALE"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"PRO04.INI"
REM - Init file for Template
Menu = 0
EOP
DOWNLOAD F,"PRO05.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 10, 20, "pro05.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"PRO05.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRO10.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 10, 20, "pro10.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"PRO10.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRO30.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 10, 20, "pro30.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"PRO30.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRO50.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 10, 20, "pro50.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"PRO50.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRO70.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 10, 20, "pro70.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"PRO70.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRO08.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 10, 20, "pro08.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"PRO08.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRO09.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "pro09.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"PRO09.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRO11.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL("AFFAIRE", "0", 20)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 40, "0",0, 20, 20, 1, "AFFAIRE"
		qW2 = TEXTPIXEL("DU", "0", 20)
		qStart2 = 187 - (qW2 / 2)
		TEXT qStart2, 100, "0",0, 20, 20, 1, "DU"
		qW3 = TEXTPIXEL("JOUR", "0", 30)
		qStart3 = 187 - (qW3 / 2)
		TEXT qStart3, 150, "0",0, 30, 30, 1, "JOUR"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"PRO11.INI"
REM - Init file for Template
Menu = 0
EOP
DOWNLOAD F,"PRO12.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL("AFFAIRE", "0", 20)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 40, "0",0, 20, 20, 1, "AFFAIRE"
		qW2 = TEXTPIXEL("DU", "0", 20)
		qStart2 = 187 - (qW2 / 2)
		TEXT qStart2, 100, "0",0, 20, 20, 1, "DU"
		qW3 = TEXTPIXEL("MOIS", "0", 30)
		qStart3 = 187 - (qW3 / 2)
		TEXT qStart3, 150, "0",0, 30, 30, 1, "MOIS"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"PRO12.INI"
REM - Init file for Template
Menu = 0s
EOP
DOWNLOAD F,"PRO06.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL("LE MOINS", "0", 25)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 60, "0",0, 25, 25, 1, "LE MOINS"
		qW2 = TEXTPIXEL("CHER", "0", 30)
		qStart2 = 187 - (qW2 / 2)
		TEXT qStart2, 140, "0",0, 30, 30, 1, "CHER"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"PRO06.INI"
REM - Init file for Template
Menu = 0
EOP
DOWNLOAD F,"PRO07.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL("PREMIER", "0", 25)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 60, "0",0, 25, 25, 1, "PREMIER"
		qW2 = TEXTPIXEL("PRIX", "0", 30)
		qStart2 = 187 - (qW2 / 2)
		TEXT qStart2, 140, "0",0, 30, 30, 1, "PRIX"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"PRO07.INI"
REM - Init file for Template
Menu = 0
EOP
DOWNLOAD F,"PRO13.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL("AFFAIRE", "0", 20)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 40, "0",0, 20, 20, 1, "AFFAIRE"
		qW2 = TEXTPIXEL("DE LA", "0", 20)
		qStart2 = 187 - (qW2 / 2)
		TEXT qStart2, 100, "0",0, 20, 20, 1, "DE LA"
		qW3 = TEXTPIXEL("SEMAINE", "0", 30)
		qStart3 = 187 - (qW3 / 2)
		TEXT qStart3, 150, "0",0, 30, 30, 1, "SEMAINE"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"PRO13.INI"
REM - Init file for Template
Menu = 0
EOP
DOWNLOAD F,"TXT03.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL(qItem1$, "0", 20)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 50, "0",0, 20, 20, 1, qItem1$
		qW2 = TEXTPIXEL(qItem2$, "0", 20)
		qStart2 = 187 - (qW2 / 2)
		TEXT qStart2, 120, "0",0, 20, 20, 1, qItem2$
		qW3 = TEXTPIXEL(qItem3$, "0", 20)
		qStart3 = 187 - (qW3 / 2)
		TEXT qStart3, 190, "0",0, 20, 20, 1, qItem3$
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"TXT03.INI"
REM - Init file for Template
Menu = 3
Item_1 = Ligne 1
Item_2 = Ligne 2
Item_3 = Ligne 3
EOP
DOWNLOAD F,"TXT01.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		REM Texte large (taille 30) centré
		qW1 = TEXTPIXEL(qItem1$, "0", 30)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 110, "0",0, 30, 30, 1, qItem1$
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"TXT01.INI"
REM - Init file for Template
Menu = 1
Item_1 = Texte
EOP
DOWNLOAD F,"PRO45.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL("CODE 45", "0", 30)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 110, "0",0, 30, 30, 1, "CODE 45"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"PRO45.INI"
REM - Init file for Template
Menu = 0
EOP
DOWNLOAD F,"PRO55.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
		REM Ok for TD-4650TNWB
		CLS
		DIRECTION 1
		qW1 = TEXTPIXEL("CODE 55", "0", 30)
		qStart1 = 187 - (qW1 / 2)
		TEXT qStart1, 110, "0",0, 30, 30, 1, "CODE 55"
		PRINT VAL(qQty$)
	ELSE
		REM To work for TD-4750TNWB
	ENDIF
EOP
DOWNLOAD F,"PRO55.INI"
REM - Init file for Template
Menu = 0
EOP
DOWNLOAD F,"PRO14.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "pro14.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"PRO14.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"MAI01.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "mai01.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"MAI01.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"MAI02.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "mai02.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"MAI02.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"MAI03.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "mai03.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"MAI03.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"MAI04.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "mai04.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"MAI04.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"BOU01.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "bou01.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"BOU01.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"BOU02.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "bou02.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"BOU02.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"BOU03.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "bou03.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"BOU03.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"BOU04.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "bou04.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"BOU04.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"BOU05.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "bou05.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"BOU05.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"BOU06.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "bou06.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"BOU06.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"BOU07.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "bou07.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"BOU07.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"BOU10.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "bou10.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"BOU10.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"BOU11.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "bou11.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"BOU11.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"BOU20.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "bou20.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"BOU20.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"BOU25.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "bou25.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"BOU25.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"BOU30.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "bou30.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"BOU30.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"BAR01.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "bar01.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"BAR01.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"BAR02.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "bar02.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"BAR02.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"BAR03.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        REM Configuration pour 203 DPI - Format 46x46mm
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "bar03.bmp", 1 
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
        PRINT VAL(qQty$)
    ELSE
        REM Configuration pour autres résolutions si nécessaire
	ENDIF
EOP
DOWNLOAD F,"BAR03.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRE01.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "pre01.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PRE01.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRE02.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "pre02.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PRE02.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRE03.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "pre03.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PRE03.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRE04.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "pre04.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PRE04.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRE05.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "pre05.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PRE05.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRE06.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "pre06.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PRE06.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRE07.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "pre07.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PRE07.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRE08.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "pre08.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PRE08.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRE09.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "pre09.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PRE09.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRE10.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "pre10.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PRE10.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRE11.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "pre11.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PRE11.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRE12.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "pre12.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PRE12.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRE13.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "pre13.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PRE13.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRE14.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "pre14.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PRE14.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PRE15.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "pre15.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PRE15.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"COM01.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "com01.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"COM01.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"COM02.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "com02.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"COM02.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"COM03.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "com03.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"COM03.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"COM04.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "com04.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"COM04.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"COM05.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "com05.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"COM05.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"COM06.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "com06.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"COM06.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"ORI01.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "ori01.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"ORI01.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"ORI02.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "ori02.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"ORI02.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"MAR01.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "mar01.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"MAR01.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"MAR02.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "mar02.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"MAR02.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"MAR03.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "mar03.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"MAR03.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"MAR04.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "mar04.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"MAR04.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"MAR05.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "mar05.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"MAR05.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"MAR06.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "mar06.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"MAR06.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"MAR07.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "mar07.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"MAR07.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"MAR08.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "mar08.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"MAR08.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"MAR09.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "mar09.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"MAR09.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"FET01.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "fet01.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"FET01.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"FET02.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "fet02.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"FET02.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"FET03.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "fet03.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"FET03.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"FET04.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "fet04.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"FET04.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"FET05.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "fet05.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"FET05.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"FET06.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "fet06.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"FET06.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"FET07.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "fet07.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"FET07.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"FET08.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "fet08.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"FET08.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"FET09.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "fet09.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"FET09.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PIZ01.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "piz01.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PIZ01.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PIZ02.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "piz02.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PIZ02.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PIZ03.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "piz03.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PIZ03.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PIZ05.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "piz05.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PIZ05.INI"
REM - Init file for Template
EOP  	
DOWNLOAD F,"PIZ06.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "piz06.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PIZ06.INI"
REM - Init file for Template
EOP 	
DOWNLOAD F,"PIZ07.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "piz07.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PIZ07.INI"
REM - Init file for Template
EOP 	
DOWNLOAD F,"PIZ08.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "piz08.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PIZ08.INI"
REM - Init file for Template
EOP 	
DOWNLOAD F,"PIZ09.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "piz09.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PIZ09.INI"
REM - Init file for Template
EOP 
DOWNLOAD F,"PIZ10.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "piz10.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PIZ10.INI"
REM - Init file for Template
EOP 
DOWNLOAD F,"PIZ11.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "piz11.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PIZ11.INI"
REM - Init file for Template
EOP 
DOWNLOAD F,"PIZ12.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "piz12.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PIZ12.INI"
REM - Init file for Template
EOP 
DOWNLOAD F,"PIZ13.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "piz13.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PIZ13.INI"
REM - Init file for Template
EOP 
DOWNLOAD F,"PIZ14.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "piz14.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PIZ14.INI"
REM - Init file for Template
EOP 
DOWNLOAD F,"PIZ15.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "piz15.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PIZ15.INI"
REM - Init file for Template
EOP 
DOWNLOAD F,"PIZ16.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "piz16.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PIZ16.INI"
REM - Init file for Template
EOP 
DOWNLOAD F,"PIZ17.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "piz17.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PIZ17.INI"
REM - Init file for Template
EOP 
DOWNLOAD F,"PIZ18.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "piz18.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PIZ18.INI"
REM - Init file for Template
EOP 
DOWNLOAD F,"AMO01.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "amo01.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"AMO01.INI"
REM - Init file for Template
EOP 
DOWNLOAD F,"AMO02.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "amo02.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"AMO02.INI"
REM - Init file for Template
EOP 
DOWNLOAD F,"AMO03.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "amo03.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"AMO03.INI"
REM - Init file for Template
EOP 
DOWNLOAD F,"AMO04.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "amo04.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"AMO04.INI"
REM - Init file for Template
EOP 
DOWNLOAD F,"AMO05.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "amo05.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"AMO05.INI"
REM - Init file for Template
EOP 
DOWNLOAD F,"BOU08.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 22, 22, "bou08.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"BOU08.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"AMO06.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "amo06.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"AMO06.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"ABA03.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 8, 22, "aba03.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"ABA03.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"ABA01.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm  
        DIRECTION 1
        CLS
        PUTBMP 22, 22, "aba01.bmp", 1 
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"ABA01.INI"
REM - Init file for Template
EOP
DOWNLOAD F,"PIZ04.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm
        DIRECTION 1
        CLS
        PUTBMP 22, 22, "piz04.bmp", 1
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"PIZ04.INI"
REM - CROPTOP = 0
EOP
DOWNLOAD F,"ABA02.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm
        DIRECTION 1
        CLS
        PUTBMP 22, 22, "aba02.bmp", 1
        PRINT VAL(qQty$)
    ENDIF
EOP
DOWNLOAD F,"ABA02.INI"
REM - CROPTOP = 0
EOP


RUN "GESTMAG.BAS"
