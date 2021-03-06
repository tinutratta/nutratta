#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch" 
#INCLUDE "TBICONN.CH" 
#include "Rwmake.ch"

#Define  _CRLF  CHR(13)+CHR(10)
//--------------------------------------------------------------------------
/* {Protheus.doc} fNexZZJ
Pega o proximo numero na ZZJ 
Empresa - Copyright -Nutratta Nutri��o Animal.
@author Davidson Clayton
@since 19/12/2017
@version P11 R8
*/
//-------------------------------------------------------------------------- 

User Function fNexZZJ()
     
Local _nSequen	:= 0
Local _cArea 	:= GetArea()
Local _cQuery 	:= ""

_cQuery := " SELECT MAX(ZZJ_CODIGO) AS ITEM "
_cQuery += " FROM " + RetSqlName("ZZJ")
_cQuery += " WHERE  D_E_L_E_T_ = ' '"

TcQuery _cQuery New Alias "TRB"
dbSelectArea("TRB")

_nSequen := Soma1(Alltrim(TRB->ITEM))

If Empty(_nSequen)
	_nSequen:="0001"
EndIf

dbSelectArea("TRB")
dbCloseArea("TRB")
             
RestArea(_cArea)

Return(_nSequen)