#INCLUDE "TOTVS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � SPFCLOSE� Autor � Nelltech Gestao de TI � Data � 15/12/15  ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao utilizada para fechar aqquivo de senha para recupera���
���          � cao senha ADMINISTRADOR                                    ���
�������������������������������������������������������������������������͹��
���Uso       � CONFIGURADOR - Nutratta                                    ���
�������������������������������������������������������������������������͹��
���Nelltech Gestao de TI � Leandro Otoni                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
-/*/
/*/{Protheus.doc} SPFCLOSE
Fechar arquivo de senha
@Example U_SPFCLOSE()
@Example U_SPFCLOSEX()
/*/
User Function SPFCLOSE()

SPF_CLOSE("SIGAPSS.SPF")

Return( Nil )
