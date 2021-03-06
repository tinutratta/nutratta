#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ACTB001   � Autora�Andressa Borges     � Data �  16/10/2007 ���
�������������������������������������������������������������������������͹��
���Descricao � Programa para incluir itens contabeis a partir do cadastro ���
���          � dos clientes.                                              ���
�������������������������������������������������������������������������͹��
���Uso       �                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function ACTB001(_cCod)

Local _cCodCli := ''
Local _aArea := GetArea()

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+_ccod)
If found()
	_cNome   := SA1->A1_NOME
	_cCodCli := '1' + ALLTRIM(_ccod)

	
	dbSelectArea("CTD")
	dbGoTop()
	dbSetorder(1)
	dbSeek(xFilial("CTD")+_cCodCli)
	
	If !Found()
		RecLock("CTD",.T.)
		CTD->CTD_FILIAL	   := xFilial("CTD")
		CTD->CTD_ITEM  		 := _cCodCli
		CTD->CTD_CLASSE 	 :=	'2'
		CTD->CTD_DESC01 	 :=	_cNome
		CTD->CTD_BLOQ		   := '2'
		CTD->CTD_DTEXIS		 := STOD('20030101')
		CTD->CTD_ITLP		   := _cCodCli
		CTD->CTD_ITSUP     :=  SUBSTR(ALLTRIM(_cCodCli),1,1)
		MsUnLock()
	EndIf
	
EndIf
Return (_cCodCli)
