#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MT094END
Este Ponto de Entrada � executado antes da conclus�o do tipo de opera��o 
que est� em andamento (Liberar o Documento, Transfer�ncia do Documento, 
Transfer�ncia para Superior)

Ponto de entrada utilizado para nao permitir a libera��o por documento maior que 
o limite.
http://tdn.totvs.com/display/public/PROT/TUMXYE_DT_PONTO_ENTRADA_MT094END

@author 	Davidson Clayton - Nutratta
@since 		31/05/2018.
@version 	P11 R8
@param   	n/t
@return  	n/t
@obs
Exclusivo para Nutratta
/*/
//-------------------------------------------------------------------
User Function MT094END()

Local _cDoc			:=PARAMIXB[1]	//Caracter	N�mero do Documento	X
Local _cTpDoc	 	:=PARAMIXB[2]	//Caracter	Tipo do documento (PC, NF, SA, IP, AE)	X
Local _nOpc			:=PARAMIXB[3]	//Num�rico	Opera��o a ser executada (1-Aprovar, 2-Estornar, 3-Aprovar pelo Superior, 4-Transferir para Superior, 5-Rejeitar, 6-Bloquear)	X
Local _cFilDoc		:=PARAMIXB[4]	//Caracter	Filial do documento   
 


      


Return

