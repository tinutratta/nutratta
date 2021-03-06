#INCLUDE "TOTVS.CH"   
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} NT_TXFDC.
Rotina para atualizar o parametro de acordo com a taxa financeira 
praticada FIDIC/SELIC
@Author   Davidson-Nutratta
@Since 	   27/09/2019.
@Version 	P11 R5
@param   	n/t
@return  	n/t
@obs.......  
o	Especifico Nutratta Nutri��o Animal.

xxx......
/*/
//-----------------------------------------------------------------------------------------------------------


User Function NT_TXFDC()  
                       
Local cEdit1	:= SuperGetMv("NT_TXFDC") 
Local cUsu30D	:= SuperGetMv("NT_USU30D",.F.,"000000")
Local cCodUsr 	:= RetCodUsr()
Local _lRet		:=	.T.
Local cEdit2	:= 00.00
Local oEdit1
Local oEdit2 

Private _oDlg				// Dialog Principal

If cCodUsr $ cUsu30D

	DEFINE MSDIALOG _oDlg TITLE "Informe a taxa 30 Dias" FROM C(350),C(575) TO C(487),C(721) PIXEL
	@ C(009),C(007) Say "Taxa atual: " Size C(027),C(012) COLOR CLR_BLUE PIXEL OF _oDlg
	@ C(007),C(030) MsGet oEdit1 Var cEdit1 Size C(040),C(009) COLOR CLR_BLACK WHEN .F. PIXEL PICTURE "@R 99.99"  OF _oDlg  
	@ C(009),C(070) Say "%" Size C(027),C(012) COLOR CLR_BLUE PIXEL OF _oDlg
	
	@ C(032),C(007) Say "Nova Taxa" Size C(028),C(012) COLOR CLR_RED PIXEL OF _oDlg
	@ C(030),C(030) MsGet oEdit2 Var cEdit2 Size C(040),C(009) COLOR CLR_BLACK WHEN .T. PIXEL PICTURE "@R 99.99"  OF _oDlg //HASBUTTON
	@ C(032),C(070) Say "%" Size C(027),C(012) COLOR CLR_RED PIXEL OF _oDlg
	
	DEFINE SBUTTON FROM C(055),C(015) TYPE 1 ENABLE OF _oDlg ACTION _bOk(cEdit2)
	DEFINE SBUTTON FROM C(055),C(045) TYPE 2 ENABLE OF _oDlg ACTION _oDlg:End()
	ACTIVATE MSDIALOG _oDlg CENTERED
	_lRet := .T.
Else

	Aviso("Nutratta","Usu�rio n�o tem permiss�o param modificar a taxa 30 dias..",      {"Voltar"},2)
	_lRet := .F.
EndIf

Return(_lRet)

//-----------------------------------------------------------------------------------
// Fun��o para grava��o do conteudo no parametro.
//-----------------------------------------------------------------------------------
Static Function _bOk(cEdit2)

_oDlg:End()
PutMv("NT_TXFDC",cEdit2)
        
MsgInfo("Taxa alterada!!")

Return