#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "topconn.ch"      
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
 
/*
========================================================================================================================
Rotina----: GTMS001
Autor-----: Davidson Carvalho
Data------: 06/06/2018
========================================================================================================================
Descri��o-: Criado o gatilho DTC_LOTNFC  dominio em DTC_CODOBS  Regra: GTMS001.
Uso-------: _nOPc receber� a origem da chamada Doc.cliente ou Viagem mod.2
========================================================================================================================
*/

User Function GTMS001(_nOPc)

_cFilial 	:= 	xFilial("DTC")
_cFilOrig	:= 	M->DTC_FILORI
_cLotFnc 	:= 	M->DTC_LOTNFC 
_LocRet 	:= 	M->DTC_CODOBS
_nTam 		:= 	TamSX3("DTC_CODOBS")
_nTam1 		:= 	_nTam[1] 
_lRet		:=	.T.
_cViagem	:= 	"" 
_cMotor		:= 	""
_cPlaca		:= 	"" 
_cCodMoto	:=	""

If _nOPc == 1 //Doc.Cliente

	dbSelectArea("DTP")
	dbSetOrder(1)
	If dbSeek(_cFilial+_cLotFnc)	
	
		_cViagem	:= DTP->DTP_VIAGEM 
		
		dbSelectArea("DTR")
		dbSetOrder(1) //DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_ITEM                                                                                                                       
		If dbSeek(_cFilial+_cFilOrig+_cViagem)	
		 	
		 	_cPlaca	:= Alltrim(DTR->DTR_CODVEI)
		 	
		 	dbSelectArea("DUP")
			dbSetOrder(1) //DUP_FILIAL+DUP_CODMOT                                                                                                                       
			If dbSeek(_cFilial+_cFilOrig+_cViagem)
				_cCodMoto 	:= Alltrim(DUP->DUP_CODMOT)
			EndIf
			
			dbSelectArea("DA4")
			dbSetOrder(1) //DA4_FILIAL+DA4_COD                                                                                                                       
			If dbSeek(xFilial("DA4")+_cCodMoto)
				_cMotor 	:= Alltrim(DA4->DA4_NOME)				
			EndIf			
			
			_LocRet	:="Transportadora credenciada na substitui��o tribut�ria conforme termo de credenciamento n� 71080 de 01/11/2016."+chr(10)+Chr(13)
			_LocRet	+=chr(10)+Chr(13)+"MOTORISTA:"+_cMotor
			_LocRet	+=chr(10)+Chr(13)+"PLACA: "+_cPlaca+chr(10)+Chr(13)
			
		EndIf      
	Else
		_LocRet	:="Transportadora credenciada na substitui��o tribut�ria conforme termo de credenciamento n� 71080 de 01/11/2016."+chr(10)+Chr(13)
		_LocRet	+="MOTORISTA: "+Chr(13)
		_LocRet	+="PLACA: "
		
	EndIf
	M->DTC_OBS	:=_LocRet

ElseIf _nOPc == 2 //Viagem mod.2
	
	_LocRet	:="Transportadora credenciada na substitui��o tribut�ria conforme termo de credenciamento n� 71080 de 01/11/2016."+chr(10)+Chr(13)
	_LocRet	+="MOTORISTA: "+chr(10)+Chr(13)
	_LocRet	+="PLACA: "
	M->DTQ_OBS	:=_LocRet
EndIf

//-----------------------------------------------------------------------------------
// Atualiza regi�o do cliente
//-----------------------------------------------------------------------------------
Processa({|lEnd| N_FATUREG()}, "Aguarde...", "Atualizando Regi�o do cliente....")   

Return(_lRet) 


/*
========================================================================================================================
Rotina----: N_FATUREG
Autor-----: Davidson 
Data------: 20/09/2018
========================================================================================================================
Descri��o-: Rotina para atualizar a regi�o dos clientes
Uso-------: Especifico TMS
========================================================================================================================
*/          

Static Function N_FATUREG()

Local cQuery 		:=	""
Local cAliasReg		:=  "" 
 
Private cCodigo		:=	""
Private cLoja		:=	""
Private cRegiao		:=	""

//-----------------------------------------------------------------------------------
// Query para verificar se existe cliente sem regiao informada
//-----------------------------------------------------------------------------------
cQuery := " SELECT  A1.A1_COD,A1.A1_LOJA,A1.A1_EST,A1.A1_CDRDES,A1.A1_EST,A1.A1_COD_MUN,DUY.DUY_EST,DUY_GRPVEN "
cQuery += " FROM "+RetSQLName("SA1")+ " A1 "
cQuery += " INNER JOIN "+RetSQLName("DUY")+ " DUY ON A1_COD_MUN=DUY_CODMUN "
cQuery += " WHERE A1_CDRDES='' "                                          
cQuery += " AND  A1.D_E_L_E_T_<>'*' "
cQuery += " AND  DUY.D_E_L_E_T_<>'*' "
 
cQuery := ChangeQuery(cQuery)
fCloseArea("cAliasReg")
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"cAliasReg",.T.,.T.)


dbSelectArea("CALIASREG")
While !Eof()

cCodigo	:=	("CALIASREG")->A1_COD
cLoja	:=	("CALIASREG")->A1_LOJA 
cRegiao	:=  ("CALIASREG")->DUY_GRPVEN

fGrRegiao(cCodigo,cLoja,cRegiao)

dbSelectArea("CALIASREG")
("CALIASREG")->( dbSkip())
End
Return
 
//--------------------------------------------------------------------------
/* {Protheus.doc} fGrvRisco
Fun��o para realizar a grava��o
Empresa - Copyright -Nutratta Nutri��o Animal.
@author Davidson Clayton
@since 05/10/2016
@version P11 R8
*/
//--------------------------------------------------------------------------
Static Function fGrRegiao(cCodigo,cLoja,cRegiao)

dbSelectArea("SA1")
dbSetOrder(1)
If dbSeek(xFilial("SA1")+cCodigo+cLoja)
	RecLock("SA1",.F.)
		Replace SA1->A1_CDRDES With  cRegiao
	MSUnlock()
EndIf

Return


//--------------------------------------------------------------------------
/* {Protheus.doc} fCloseArea
Funcao para verificar se existe tabela e exclui-la
Empresa - Copyright -Nutratta Nutri��o Animal.
@author Davidson Clayton
@since 09/11/2016
@version P11 R8
*/
//--------------------------------------------------------------------------
Static Function fCloseArea(pParTabe)

If (Select(pParTabe)!= 0)
	dbSelectArea(pParTabe)
	dbCloseArea()
	If File(pParTabe+GetDBExtension())
		FErase(pParTabe+GetDBExtension())
	EndIf
EndIf    

Return 