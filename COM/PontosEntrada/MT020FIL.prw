#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
//--------------------------------------------------------------------------
/* {Protheus.doc} MT020FIL
Incluir campos no Browse da amarra��o Fornecedor x Banco.
Empresa - Copyright -Nutratta Nutri��o Animal.
@author Davidson Clayton
@since 10/09/2018
@version P11 R8
Link Totvs 
http://tdn.totvs.com/pages/releaseview.action?pageId=185756465
*/
//--------------------------------------------------------------------------

User Function MT020FIL()
Local aRet := Array(2)

aRet[1] := "|FIL_DESBCO|FIL_OPERAC|FIL_DESOPE"
aRet[2] := 2
     
Return aRet