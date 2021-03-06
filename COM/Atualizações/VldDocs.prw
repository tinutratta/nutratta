#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} VldDocs.
Colocar no campo esta valida��o de usuario = u_VldDocs(cNFiscal)
Preenche os numeros a esquerda com 0.   


@Author   Davidson-Nutratta
@Since 	   09/11/2017.
@Version 	P11 R5
@param   	n/t
@return  	n/t
@obs.......  
Valida��o chamada no campo F1_DOC 
Chamada na valida��o do usuario
U_VldDocs(cNFiscal)                                                                                                             
xxx......
/*/
//-----------------------------------------------------------------------------------------------------------

User Function VldDocs(cDoc)

Local cNumero := AllTrim(cDoc) 

Local cResult := "" 

If FunName() == "MATA103" .Or. FunName() == "MATA140"       

	If Len(cNumero) != 9

    	cResult := PadL(cNumero, 9, "0")// define que sera 9 digitos ao preencher ele ira completar em zeros

        cNFiscal := cResult

	EndIf
EndIf

Return .T.    
#Include "Protheus.ch"

//*************************************************************************
//Criado por Davidson para preencher o campo serie com 3 digitos 17/05/2017                                                                                          
//*************************************************************************
User Function VldFornec(CVAR)

Local lRet		:=.T.  
Local cResult 	:= ""
                                               
cFornec 	:= &CVAR 
cLoja		:= CLOJA
cFilAnt		:= xFilial("SF1")

If FunName() == "MATA103"      
                             
	dbSelectArea("SF1")
	dbSetOrder(2)
	If dbSeek(cFilAnt+cFornec+cLoja+cNFiscal)	//F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC
		Aviso("Aten��o","J� existe um documento com mesmo n�mero lan�ado para este fornecedor.",{"OK"},2) 
	EndIf
EndIf
Return (lRet)      