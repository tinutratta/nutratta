#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
========================================================================================================================
Rotina----: MAT070OK
Autor-----: Davidson Clayton
Data------: 25/09/2017.
========================================================================================================================
Descri��o-: Ponto de entrada executado apos confirma��o do cadastro de banco.
caso o campo A6_FATPORT seja preenchido com Sim os outros bancos receber�o Nao.
Uso-------: Esse campo � utilizado para setar qual o portador a ser utilizado no 
faturamento.
========================================================================================================================
*/
User Function MAT070OK()

Local aAreaSA6	:= GetARea("SA6") 
Local lRet 		:= .T.
Local nQtdReg	:= 0 

//-----------------------------------------------------------------------------------
// Caso o campo da memoria seja marcado como SIM.
//-----------------------------------------------------------------------------------
If M->A6_FATPORT == '1'                            

	dbSelectArea(aAreaSA6)
	dbGotop()
	While !Eof()
		dbSelectArea(aAreaSA6)
	 	 RecLock("SA6",.F.)

		   	Replace SA6->A6_FATPORT With "2"    	 	 
		 MsUnLock()
	dbSkip()
	End 

//-----------------------------------------------------------------------------------
// Verifica se ao menos um banco esta marcado como SIM
//-----------------------------------------------------------------------------------
Else
	dbSelectArea(aAreaSA6)
	dbGotop()
	While !Eof()
		
		If SA6->A6_FATPORT == "1" .And. SA6->A6_BLOCKED  == "2"
			
			nQtdReg++
		EndIf
		dbSkip()
	End
	
	If  (nQtdReg == 0 .And. M->A6_FATPORT == '2') 
		
		Aviso("Aten��o","Ao menos um banco deve ser selecionado como Portador do faturamento!!!Verifique.",{"Voltar"},2)
		lRet:=.F.
	EndIf
EndIf 

Return(lRet)