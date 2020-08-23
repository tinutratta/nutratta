#include "protheus.ch" 
#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "colors.ch"
#Include "Totvs.ch"                          
               
//-------------------------------------------------------------------
/*/{Protheus.doc} MA030ROT.
Rotina para realizar a altera��o de carteira de clientes.
Montagem do item no menu.

@Author   Davidson Carvalho  Nutratta Nutri��o Animal Ltda.
@Since 	   10/09/2018.
@Version 	P11 R5
@param   	n/t
@return  	n/t
@obs.......   
xxx......
/*/                                                     
//-----------------------------------------------------------------------------------------------------------
User Function MA030ROT()
	
Local aRet 		:= {}
Local _cCodUser :=	RetCodUsr()


//-----------------------------------------------------------------------------------
// Restringe o acesso � rotina.
//-----------------------------------------------------------------------------------	 
If _cCodUser == '000099' .Or. _cCodUser == '000100' .Or. _cCodUser == '000101'  //Lucas - Lorran -Davidson

	aAdd(aRet,{"Alt.Carteira","U_MFAT006",0,4})
EndIf

Return(aRet)