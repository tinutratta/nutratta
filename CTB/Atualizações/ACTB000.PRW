#INCLUDE "rwmake.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ACTB000   � Autora�Andressa Borges     � Data � 16/02/2009  ���
�������������������������������������������������������������������������͹��
���Descricao � Programa para a inclus�o de itens contabeis a partir do    ���
���          � cadastro do Fornecedor                                     ���
�������������������������������������������������������������������������͹��
���Uso       � U_ACTB000(ALLTRIM(SD1->D1_FORNECE))                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function ACTB000(_ccod)

Local _cCodFor := ''
Local _aArea   := GetArea()

dbSelectArea("SA2")
dbSetOrder(1)
dbSeek(xFilial("SA2")+_ccod)

If found()	    
    _cCodFor := '2' + ALLTRIM(_ccod)
	_cNome   := SA2->A2_NOME
	
	dbSelectArea("CTD")
	dbGoTop()
	dbSetorder(1)
	dbSeek(xFilial("CTD")+_cCodFor)
	If !Found() .AND. _cCodFor <> ''
		RecLock("CTD",.T.)
		CTD->CTD_FILIAL 	:= xFilial("CTD")
		CTD->CTD_ITEM  		:= _cCodFor
		CTD->CTD_CLASSE 	:=	'2'
		CTD->CTD_DESC01 	:=	_cNome
		CTD->CTD_BLOQ		  := '2'
		CTD->CTD_DTEXIS		:= STOD('20030101')
		CTD->CTD_ITLP		  := _cCodFor
		CTD->CTD_ITSUP    := SUBSTR(ALLTRIM(_cCodFor),1,1)
		MsUnLock()
	EndIf
EndIf
Return ( _cCodFor) //Segundo Rita n�o dever� retorna a loja pois a mesma n�o ser� gravada na CTD.


