#Include 'Protheus.ch'
#Include 'Topconn.ch'
                 
#INCLUDE "rwmake.ch"
#Include 'Protheus.ch'
#Include 'Parmtype.ch'

/*
========================================================================================================================
Rotina----: SC5NUM
Autor-----: Davidson Carvalho
Data------: 21/02/2018
========================================================================================================================
Descri��o-: Busca o proximo numero valido GETSXENUM("SC5","C5_NUM")          
Uso-------: Logistica Nutratta
========================================================================================================================
*/
User Function _SC5NUM()
	
	Local  CQRYSC5	:= ""
	Local CNEXC5NUM	:= ""
       
	CQRYSC5	:="	SELECT MAX(C5_NUM) AS C5_CODIGO FROM "+RETSQLNAME("SC5")
	CQRYSC5	+="	WHERE "
	CQRYSC5	+="	C5_FILIAL = '"+XFILIAL("C5")+"' "

	IF SELECT("TMSC5") <> 0
		TMSC5->(DBCLOSEAREA())
	ENDIF

	TCQUERY CQRYSC5 NEW ALIAS "TMSC5"

	DBSELECTAREA("TMSC5")
	TMSC5->(DBGOTOP())
	
	CNEXC5NUM := VAL(CNEXC5NUM->C5_NUM) + 1
	
	IF (TMSC5->(RECCOUNT())) > 0
		TMSC5->(DBCLOSEAREA())
	ENDIF
			
Return (PADL(ALLTRIM(CVALTOCHAR(CNEXC5NUM)),6,"0"))