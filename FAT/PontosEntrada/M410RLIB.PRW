#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
//--------------------------------------------------------------------------
/* {Protheus.doc} M410RLIB
� executado ap�s a grava��o das altera��es, para refazer as 
libera��es de estoque considerando os registros do arquivo 
SDC (composi��o de empenho) da libera��o anterior.

Empresa - Copyright -Nutratta Nutri��o Animal.
@author Davidson Clayton
@since 15/04/2019
@version P11 R8
*/
//--------------------------------------------------------------------------
User Function M410RLIB()

Private _lEnd	   	:= .F.
Private _oProcess   := NIL

oProcess := MsNewProcess():New( { |_lEnd| StaticCall(MT410TOK,fProcNut2,_lEnd,oProcess)} ,"Processamento...", "Processando grava��o do Pedido...", .F. )
oProcess:Activate()


Return 

