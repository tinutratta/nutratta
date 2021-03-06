#include "rwmake.ch"  
#include "topconn.ch"  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AEST002   �Autor  �Juarez              � Data �  09/08/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera cod. sequencial automaticamente para o produto  ���
���          � conforme escolha do campo grupo                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP    Gatilho B1_GRUPO                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function AEST002()

Local _cCodPro := "00000000"
Local _cArea := GetArea()
Local _cQuery := ""

_cQuery := " SELECT MAX(B1_COD) AS CODIGO "
_cQuery += " FROM " + RetSqlName("SB1")
//_cQuery += " WHERE SB1_GRUPO = '" + M->B1_GRUPO + "'" 
_cQuery += " WHERE LEFT(B1_COD,2) = '" + SX5->X5_CHAVE + "'" 
_cQuery += " AND  D_E_L_E_T_ = ' '"

TcQuery _cQuery New Alias "TRB"
dbSelectArea("TRB")
dbGoTop()
//_cCodPro :=  M->B1_GRUPO + Strzero(Val(Right(Alltrim(TRB->CODIGO),4))+1,4)
//_cCodPro := Strzero(Val(Right(Alltrim(TRB->CODIGO),4))+1,4)
_cCodPro := Soma1(Alltrim(TRB->CODIGO))

dbSelectArea("TRB")
dbCloseArea("TRB")

While !MayIUseCode("B1_COD"+xFilial("SB1")+_cCodPro)
	_cCodPro := Soma1(_cCodPro)
EndDo             

RestArea(_cArea)

Return(_cCodPro)



