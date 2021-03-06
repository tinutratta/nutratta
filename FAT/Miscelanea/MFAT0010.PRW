#INCLUDE "TOTVS.CH"   
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"

#Define  _CRLF  CHR(13)+CHR(10) 

//-------------------------------------------------------------------
/*/{Protheus.doc} MFAT0010.
Rotina para realizar a manuten��o dos per�odos de comissonamento.
@Author   Davidson-Nutratta
@Since 	   29/11/2019
@Version 	12.1.17
@param   	n/t
@return  	n/t
@obs.......  
o Especifico Nutratta Nutri��o Animal.

/*/
//-----------------------------------------------------------------------------------------------------------

User Function MFAT0010()

//-----------------------------------------------------------------------------------
//MBROWSE DA TABELA ZZJ - CADASTRO DE LOCAIS DE ENTREGA
//-----------------------------------------------------------------------------------
Private cPerg   := ""
Private cCadastro := "Cadastro per�odos de comiss�o Nutratta"
Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
             {"Visualizar","AxVisual",0,2} ,;
             {"Incluir","AxInclui",0,3} ,;
             {"Alterar","AxAltera",0,4} ,;
             {"Excluir","AxDeleta",0,5}}


Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private cString := "ZB5"

dbSelectArea("ZB5")
dbSetOrder(1)

cPerg   := ""

dbSelectArea(cString)
mBrowse(6,1,22,75,cString)

Set Key 123 To // Desativa a tecla F12 do acionamento dos parametros

Return   


//-------------------------------------------------------------------
/*/{Protheus.doc} ZB5VldCpo
Rotina para validar os campos dos periodos de comiss�o
@Author   Davidson-Nutratta
@Since 	   29/11/2019.
@Version 	12.1.17
@param   	n/t
@return  	_nPerDesc
/*/
//-----------------------------------------------------------------------------------------------------------
User Function ZB5VldCpo (_nOpc)
                    
Local _cMensagem := ""
Local _lRet		 := .T.

If _nOpc  == 1
	If Len(Alltrim(M->ZB5_MES)) == 1
		_cMensagem	+=	_CRLF+"Gentileza corrigir o m�s,Exemplo:01,02,03....   "+_CRLF
		_lRet:=.F.
	EndIf
	
ElseIf _nOpc  == 2
	If M->ZB5_ANO < "2017"			//DataValida(CTOD("01/01/"+M->ZB5_ANO),.F.)
		_cMensagem	+=	_CRLF+"Gentileza corrigir o ano,2017,2018,2019,2020....   "+_CRLF
		_lRet:=.F.
	EndIf
	
ElseIf _nOpc  == 3
	If !Substr(Dtos(M->ZB5_DTINI),1,4) == M->ZB5_ANO .Or. !Substr(Dtos(M->ZB5_DTINI),5,2) == Alltrim(M->ZB5_MES)
		_cMensagem	+=	_CRLF+"Data inv�lida,verificar m�s e ano.."+_CRLF
		_lRet:=.F.
	EndIf
	
ElseIf _nOpc  == 4
	If !Substr(Dtos(M->ZB5_DTFIM),1,4) == M->ZB5_ANO //.Or. !Substr(Dtos(M->ZB5_DTFIM),5,2) == Alltrim(M->ZB5_MES)
		_cMensagem	+=	_CRLF+"Data inv�lida,verificar m�s e ano.."+_CRLF
		_lRet:=.F.
	EndIf
EndIf

If  !_lRet
	
	Aviso("Atenc�o!!!","Campo Inv�lido !! Favor Verificar."+_cMensagem,{"Voltar"},2)
EndIf 
 

Return (_lRet)
