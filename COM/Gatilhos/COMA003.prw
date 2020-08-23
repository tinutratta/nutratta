#include "rwmake.ch"  
#include "topconn.ch"  
/*
========================================================================================================================
Rotina----: COMA003
Autor-----: Davidson Carvalho
Data------: 07/02/2018
========================================================================================================================
Descrição-: Gatilho para pegar a conta contabil selecionada no campo BM_C_CTEST. 
Uso-------: Chamado no gatilho do C1_PRODUTO E C7_PRODUTO 
=======================================================================================================================
*/
User Function COMA003()

Local _cCodConta 	:= ""
Local _cProduto		:= ""
Local _cGrupo		:= ""
Local _cArea 		:= GetArea()

If	FunName() == "MATA110" 	//Solicitação de compras                     

	nPosCod  		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C1_PRODUTO"})

ElseIf FunName() == "MATA121" //Pedido de compras

	nPosCod  		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO"}) 
ElseIf FunName() == "MATA103" .Or. FunName() == "MATA140" //Documento de entrada.

	nPosCod  		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"}) 		 
ElseIf FunName() == "" .Or. FunName() == "MATA140" //Documento de saida.

	nPosCod  		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"}) 			
EndIf

//--Posiciona no cadastro de produtos;
dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1")+aCols[n][nPosCod])
         	
	_cGrupo := SB1->B1_GRUPO           	
EndIf	

//--Posiciona no cadastro de grupo de produtos; 
dbSelectArea("SBM")
dbSetOrder(1)
If dbSeek(xFilial("SBM")+_cGrupo)
         	
	_cCodConta := SBM->BM_C_CTEST           	
EndIf	

RestArea(_cArea)

Return(_cCodConta)
