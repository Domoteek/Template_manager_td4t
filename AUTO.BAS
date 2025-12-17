SOUND 1,200
SOUND 2,200
SOUND 3,200

qDispFGCol = 0
qDispBGCol = 2942000000

DISPLAY qDispFGCol, qDispBGCol
DISPLAY CLS
DISPLAY 90, 40,"Logo_GM.bmp"
DISPLAY 55, 100, "0", 0, 8, 8, 2, "Installation en cours..."
DISPLAY 20, 120, "0", 0, 8, 8, 2, "Format BMP etiq. en 46 x 46"
DISPLAY 125, 160,"usb2.bmp"

REM -----

	DISPLAY CLS
	DISPLAY 90, 40,"Logo_GM.bmp"
	DISPLAY 55, 100, "0", 0, 8, 8, 2, "Installation en cours..."
	DISPLAY 20, 120, "0", 0, 8, 8, 2, "Format BMP etiq. en 46 x 46"
	DISPLAY 20, 140, "0", 0, 8, 8, 2, "Copie : Programmes..."
	COPY E,"Prog_Gestmag.BAS" ,F,"Prog_Gestmag.BAS"
	COPY E,"AUTO.TXT" ,F,"AUTO.BAS"
	COPY E,"Logo_GM.bmp" ,F,"Logo_GM.bmp"

	DISPLAY CLS
	DISPLAY 90, 40,"Logo_GM.bmp"
	DISPLAY 55, 100, "0", 0, 8, 8, 2, "Installation en cours..."
	DISPLAY 20, 120, "0", 0, 8, 8, 2, "Format BMP etiq. en 46 x 46"
	DISPLAY 20, 140, "0", 0, 8, 8, 2, "Copie : Images PROMO"
	COPY E,"pro05.bmp" ,F,"pro05.bmp"
	COPY E,"pro08.bmp" ,F,"pro08.bmp"
	COPY E,"pro09.bmp" ,F,"pro09.bmp"
	COPY E,"pro14.bmp" ,F,"pro14.bmp"
	COPY E,"pro10.bmp" ,F,"pro10.bmp"
	COPY E,"pro30.bmp" ,F,"pro30.bmp"
	COPY E,"pro50.bmp" ,F,"pro50.bmp"
	COPY E,"pro70.bmp" ,F,"pro70.bmp"

	DISPLAY CLS
	DISPLAY 90, 40,"Logo_GM.bmp"
	DISPLAY 55, 100, "0", 0, 8, 8, 2, "Installation en cours..."
	DISPLAY 20, 120, "0", 0, 8, 8, 2, "Format BMP etiq. en 46 x 46"
	DISPLAY 20, 140, "0", 0, 8, 8, 2, "Copie : Images BOUCHERIE"
	COPY E,"bou01.bmp" ,F,"bou01.bmp"
	COPY E,"bou02.bmp" ,F,"bou02.bmp"
	COPY E,"bou03.bmp" ,F,"bou03.bmp"
	COPY E,"bou04.bmp" ,F,"bou04.bmp"
	COPY E,"bou05.bmp" ,F,"bou05.bmp"
	COPY E,"bou06.bmp" ,F,"bou06.bmp"
	COPY E,"bou07.bmp" ,F,"bou07.bmp"
	COPY E,"bou10.bmp" ,F,"bou10.bmp"
	COPY E,"bou11.bmp" ,F,"bou11.bmp"
	COPY E,"bou20.bmp" ,F,"bou20.bmp"
	COPY E,"bou25.bmp" ,F,"bou25.bmp"
	COPY E,"bou30.bmp" ,F,"bou30.bmp"

	DISPLAY CLS
	DISPLAY 90, 40,"Logo_GM.bmp"
	DISPLAY 55, 100, "0", 0, 8, 8, 2, "Installation en cours..."
	DISPLAY 20, 120, "0", 0, 8, 8, 2, "Format BMP etiq. en 46 x 46"
	DISPLAY 20, 140, "0", 0, 8, 8, 2, "Copie : Images BBQ"
	COPY E,"bar01.bmp" ,F,"bar01.bmp"
	COPY E,"bar02.bmp" ,F,"bar02.bmp"
	COPY E,"bar03.bmp" ,F,"bar03.bmp"

	DISPLAY CLS
	DISPLAY 90, 40,"Logo_GM.bmp"
	DISPLAY 55, 100, "0", 0, 8, 8, 2, "Installation en cours..."
	DISPLAY 20, 120, "0", 0, 8, 8, 2, "Format BMP etiq. en 46 x 46"
	DISPLAY 20, 140, "0", 0, 8, 8, 2, "Copie : Images PREPARATION"
	COPY E,"pre01.bmp" ,F,"pre01.bmp"
	COPY E,"pre02.bmp" ,F,"pre02.bmp"
	COPY E,"pre03.bmp" ,F,"pre03.bmp"
	COPY E,"pre04.bmp" ,F,"pre04.bmp"
	COPY E,"pre05.bmp" ,F,"pre05.bmp"
	COPY E,"pre06.bmp" ,F,"pre06.bmp"
	COPY E,"pre07.bmp" ,F,"pre07.bmp"
	COPY E,"pre08.bmp" ,F,"pre08.bmp"
	COPY E,"pre09.bmp" ,F,"pre09.bmp"
	COPY E,"pre10.bmp" ,F,"pre10.bmp"
	COPY E,"pre11.bmp" ,F,"pre11.bmp"
	COPY E,"pre12.bmp" ,F,"pre12.bmp"
	COPY E,"pre13.bmp" ,F,"pre13.bmp"
	COPY E,"pre14.bmp" ,F,"pre14.bmp"
	COPY E,"pre15.bmp" ,F,"pre15.bmp"

	DISPLAY CLS
	DISPLAY 90, 40,"Logo_GM.bmp"
	DISPLAY 55, 100, "0", 0, 8, 8, 2, "Installation en cours..."
	DISPLAY 20, 120, "0", 0, 8, 8, 2, "Format BMP etiq. en 46 x 46"
	DISPLAY 20, 140, "0", 0, 8, 8, 2, "Copie : Images COMPOSITION"
	COPY E,"com01.bmp" ,F,"com01.bmp"
	COPY E,"com02.bmp" ,F,"com02.bmp"
	COPY E,"com03.bmp" ,F,"com03.bmp"
	COPY E,"com04.bmp" ,F,"com04.bmp"
	COPY E,"com05.bmp" ,F,"com05.bmp"
	COPY E,"com06.bmp" ,F,"com06.bmp"

	DISPLAY CLS
	DISPLAY 90, 40,"Logo_GM.bmp"
	DISPLAY 55, 100, "0", 0, 8, 8, 2, "Installation en cours..."
	DISPLAY 20, 120, "0", 0, 8, 8, 2, "Format BMP etiq. en 46 x 46"
	DISPLAY 20, 140, "0", 0, 8, 8, 2, "Copie : Images MAREE"
	COPY E,"mar01.bmp" ,F,"mar01.bmp"
	COPY E,"mar02.bmp" ,F,"mar02.bmp"
	COPY E,"mar03.bmp" ,F,"mar03.bmp"
	COPY E,"mar04.bmp" ,F,"mar04.bmp"
	COPY E,"mar05.bmp" ,F,"mar05.bmp"
	COPY E,"mar06.bmp" ,F,"mar06.bmp"
	COPY E,"mar07.bmp" ,F,"mar07.bmp"
	COPY E,"mar09.bmp" ,F,"mar09.bmp"

	DISPLAY CLS
	DISPLAY 90, 40,"Logo_GM.bmp"
	DISPLAY 55, 100, "0", 0, 8, 8, 2, "Installation en cours..."
	DISPLAY 20, 120, "0", 0, 8, 8, 2, "Format BMP etiq. en 46 x 46"
	DISPLAY 20, 140, "0", 0, 8, 8, 2, "Copie : Images DIV..."
	COPY E,"ori01.bmp" ,F,"ori01.bmp"
	COPY E,"ori02.bmp" ,F,"ori02.bmp"
	COPY E,"aba01.bmp" ,F,"aba01.bmp"
	COPY E,"aba02.bmp" ,F,"aba02.bmp"
	COPY E,"aba03.bmp" ,F,"aba03.bmp"
	COPY E,"m01.bmp" ,F,"m01.bmp"
	COPY E,"m02.bmp" ,F,"m02.bmp"
	COPY E,"m03.bmp" ,F,"m03.bmp"
	COPY E,"m04.bmp" ,F,"m04.bmp"
	COPY E,"ma01.bmp" ,F,"ma01.bmp"
	COPY E,"ma02.bmp" ,F,"ma02.bmp"
	COPY E,"ma03.bmp" ,F,"ma03.bmp"
	COPY E,"ma04.bmp" ,F,"ma04.bmp"
	COPY E,"ma05.bmp" ,F,"ma05.bmp"
	COPY E,"ma06.bmp" ,F,"ma06.bmp"
	COPY E,"ma07.bmp" ,F,"ma07.bmp"
	COPY E,"ma08.bmp" ,F,"ma08.bmp"
	COPY E,"ma09.bmp" ,F,"ma09.bmp"

DISPLAY CLS
	DISPLAY 90, 40,"Logo_GM.bmp"
	DISPLAY 55, 100, "0", 0, 8, 8, 2, "Installation en cours..."
	DISPLAY 20, 120, "0", 0, 8, 8, 2, "Format BMP etiq. en 46 x 46"
	DISPLAY 20, 140, "0", 0, 8, 8, 2, "Copie : Images FETE"
	COPY E,"fet01.bmp" ,F,"fet01.bmp"
	COPY E,"fet02.bmp" ,F,"fet02.bmp"
	COPY E,"fet03.bmp" ,F,"fet03.bmp"
	COPY E,"fet04.bmp" ,F,"fet04.bmp"
	COPY E,"fet05.bmp" ,F,"fet05.bmp"
	COPY E,"fet06.bmp" ,F,"fet06.bmp"
	COPY E,"fet07.bmp" ,F,"fet07.bmp"
	COPY E,"fet08.bmp" ,F,"fet08.bmp"
	COPY E,"fet09.bmp" ,F,"fet09.bmp"

DISPLAY CLS
	DISPLAY 90, 40,"Logo_GM.bmp"
	DISPLAY 55, 100, "0", 0, 8, 8, 2, "Installation en cours..."
	DISPLAY 20, 120, "0", 0, 8, 8, 2, "Format BMP etiq. en 46 x 46"
	DISPLAY 20, 140, "0", 0, 8, 8, 2, "Copie : Images PIZZA"
	COPY E,"piz01.bmp" ,F,"piz01.bmp"
	COPY E,"piz02.bmp" ,F,"piz02.bmp"
	COPY E,"piz03.bmp" ,F,"piz03.bmp"
	COPY E,"piz04.bmp" ,F,"piz04.bmp"
	COPY E,"piz05.bmp" ,F,"piz05.bmp"
	COPY E,"piz06.bmp" ,F,"piz06.bmp"
	COPY E,"piz07.bmp" ,F,"piz07.bmp"
	COPY E,"piz08.bmp" ,F,"piz08.bmp"
	COPY E,"piz09.bmp" ,F,"piz09.bmp"
	COPY E,"piz10.bmp" ,F,"piz10.bmp"
	COPY E,"piz11.bmp" ,F,"piz11.bmp"
	COPY E,"piz12.bmp" ,F,"piz12.bmp"
	COPY E,"piz13.bmp" ,F,"piz13.bmp"
	COPY E,"piz14.bmp" ,F,"piz14.bmp"
	COPY E,"piz15.bmp" ,F,"piz15.bmp"
	COPY E,"piz16.bmp" ,F,"piz16.bmp"
	COPY E,"piz17.bmp" ,F,"piz17.bmp"
	COPY E,"piz18.bmp" ,F,"piz18.bmp"


DISPLAY CLS
	DISPLAY 90, 40,"Logo_GM.bmp"
	DISPLAY 55, 100, "0", 0, 8, 8, 2, "Installation en cours..."
	DISPLAY 20, 120, "0", 0, 8, 8, 2, "Format BMP etiq. en 46 x 46"
	DISPLAY 20, 140, "0", 0, 8, 8, 2, "Copie : Images AMOUR"
	COPY E,"amo01.bmp" ,F,"amo01.bmp"
	COPY E,"amo02.bmp" ,F,"amo02.bmp"
	COPY E,"amo03.bmp" ,F,"amo03.bmp"
	COPY E,"amo04.bmp" ,F,"amo04.bmp"
	COPY E,"amo05.bmp" ,F,"amo05.bmp"
	COPY E,"amo06.bmp" ,F,"amo06.bmp"
	COPY E,"bou08.bmp" ,F,"bou08.bmp"
	COPY E,"dlc03.bmp" ,F,"dlc03.bmp"
	COPY E,"fra01.bmp" ,F,"fra01.bmp"
	COPY E,"fra02.bmp" ,F,"fra02.bmp"
	COPY E,"fra03.bmp" ,F,"fra03.bmp"
	COPY E,"mai01.bmp" ,F,"mai01.bmp"
	COPY E,"mai02.bmp" ,F,"mai02.bmp"
	COPY E,"mai03.bmp" ,F,"mai03.bmp"
	COPY E,"mai04.bmp" ,F,"mai04.bmp"
	COPY E,"mar08.bmp" ,F,"mar08.bmp"






DISPLAY CLS
DISPLAY 55, 110, "0", 0, 8, 8, 2, "Installation Terminee !"
DISPLAY 75, 140, "0", 0, 6, 6, 2, "Retirer Cle + OFF/ON"
DELAY 4000		
RUN "Prog_Gestmag.BAS"