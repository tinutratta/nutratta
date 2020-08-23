/*

+----------------------------------------------------------------------------+
|   DADOS DO PROGRAMA                                                        |
+------------------+---------------------------------------------------------+
|Tipo              | Ponto de Entrada                                        |
+------------------+---------------------------------------------------------+
|Modulo            | Compras                                                 |
+------------------+---------------------------------------------------------+
|Nome              | MT120OK                                                 |
+------------------+---------------------------------------------------------+
|Descricao         | Ponto de entrada para valida��o das informa��es digita- |
|                  | pelo usuario ao final do pedido                         |
+------------------+---------------------------------------------------------+
|Onde e Executado  | MATA120 - Pedidos de Compra                             |
+------------------+---------------------------------------------------------+
|Parametros        | Nenhum                                                  |
+------------------+---------------------------------------------------------+
|Retorno           | .T. = Libera a inclus�o/altera��o                       |
|                  | .F. = Bloqueia a inclus�o/altera��o                     |
+------------------+---------------------------------------------------------+
|Autor             | Rafael Almeida                                          |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 12/05/2015                                              |
+------------------+---------------------------------------------------------+
|   ATUALIZACOES                                                             |
+-------------------------------------------+-----------+-----------+--------+
|   Descricao detalhada da atualizacao      |Nome do    | Analista  |Data da |
|                                           |Solicitante| Respons.  |Atualiz.|
+-------------------------------------------+-----------+-----------+--------+
|Alterado por Fabio Mota                    |           |           |        |
| Comentario linha 54                       |           |           |        |
+-------------------------------------------+-----------+-----------+--------+
*/

#include 'protheus.ch'
#DEFINE __ENTER CHR(13)+CHR(10)
#DEFINE TOTPED  6

User Function MT120OK()
        
        //+----------------------------------------------------------+
        //| Declara��o de Vari�veis                                  |
        //+----------------------------------------------------------+
        Local lContinua := .T.
        Local aArea     := GetArea()
        Local nValTot   := 0
        Local cMsgErro  := ""
        Local nPosItem  := aScan(aHeader,{|X| rTrim(Upper(X[2]))=="C7_ITEM" })
        Local nPosProd  := aScan(aHeader,{|X| rTrim(Upper(X[2]))=="C7_PRODUTO" })
        Local nPosCC    := aScan(aHeader,{|X| rTrim(Upper(X[2]))=="C7_CC" })
        Local nPosRateio:= aScan(aHeader,{|X| rTrim(Upper(X[2]))=="C7_RATEIO" })
        Local nPosLocal	:= aScan(aHeader,{|X| rTrim(Upper(X[2]))=="C7_LOCAL" })
        
        //Verifica se existe a variavel cOrigem e o seu Conteudo
        //If Type("cOrigem") = "C" .And. cOrigem == "CNTA120"
                
                //+----------------------------------------------------------+
                //|                  VALIDA��ES NO PEDIDO                    |
                //+----------------------------------------------------------+
                //+----------------------------------------------------------+
                //| Valida se tem rateio, n�o � obrigatorio o Centro de Custo|
                //+----------------------------------------------------------+
                For nX := 1 To Len(aCols)
                        
                        If Empty(aCols[nX][nPosCC])
                                
                                If aCols[nX][nPosRateio] == "2"
                                        
                                        cMsgErro += __ENTER +"- O centro de custo s� pode ficar em branco quando tem rateio."+__ENTER+;
                                        "Linha: " + Alltrim(aCols[nX][nPosItem])+__ENTER+; 
                                        "By Nutratta"+__ENTER+__ENTER
                                        lContinua := .F.
                                        
                                EndIf
                        EndIf
                        	
						//-----------------------------------------------------------------------------------
						// Valida��o local de estoque no pedido de compras, de acordo com cadastro de produtos.
						//-----------------------------------------------------------------------------------
                        cCodProduto	:=	Alltrim(GDFieldGet("C7_PRODUTO",n,.T.,,,)) //Produto do pedido
                        cLocPed		:=	Alltrim(GDFieldGet("C7_LOCAL",n,.T.,,,)) //Local do pedido
                        cLocalEst	:=	Alltrim(Posicione("SB1",1,xFilial("SB1")+cCodProduto,"B1_LOCPAD"))  //Local do cad. Produto.

                        If cLocPed <> cLocalEst
                              cMsgErro += __ENTER +"-O Local de estoque n�o � o padr�o do produto."+__ENTER+;
                              "Verificar o cadastro do produto:"+__ENTER+;
                              "Armazem do pedido:  "+cLocPed+__ENTER+;
                              "Armazem do produto:  "+cLocalEst+__ENTER+;    
                              "Linha:  "+ Alltrim(aCols[nX][nPosItem])+__ENTER+;
                              "By Nutratta"
                              lContinua := .F.
                        
                        EndIf
                        
                Next nX
                
                //+----------------------------------------------------------+
                //| Apresenta a mensagem formatada                           |
                //+----------------------------------------------------------+
                If !lContinua
                        
                        MsgInfo("Favor corrigir os seguintes erros abaixo:" + __ENTER + cMsgErro,"Alerta")
                        
                EndIf
                
                //+----------------------------------------------------------+
                //| Restaura a posicao de memoria e ponteiro de arquivos     |
                //+----------------------------------------------------------+
                RestArea(aArea)
                
                //+----------------------------------------------------------+
                //| Limpa Variaveis e memoria                                |
                //+----------------------------------------------------------+
                aArea := aSize(aArea,0)
                aArea := Nil
                
     
        
Return lContinua