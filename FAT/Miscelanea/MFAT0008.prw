#INCLUDE "TOTVS.CH"   
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#include 'parmtype.ch'                              

//-------------------------------------------------------------------
/*{Protheus.doc} MFAT0008.
Rotina para atualizar as notas fiscais/Pedidos emitidas com o calculo de margem
de contribui��o.
@Author   Davidson-Nutratta
@Since 	   22/01/2019.
@Version 	P12 R5
@param   	n/t
@return  	n/t
@obs.......  
o	Especifico Nutratta Nutri��o Animal.

Atualiza��es:
11/09/2019 - Implementa��o do abatimento do ICMS 4.80% 
/*/
//-----------------------------------------------------------------------------------------------------------
User Function MFAT0008(_cFilial,_cNumNota,_cSerieNf)

Local _aAreaAnt		:= GetArea()                          
Local _cTabela		:= "SD2"
Local _nOpc			:= 0 

Private _lFilnF		:= .F.
Private lSchedulle	:= .F.
Private nProc		:= 0
Private nOpc		:= 0
Private	_nCustD 	:= 0
Private nCont		:= 1
Private cCodigo		:= ""
Private cLoja		:= "" 
Private	_cCodProduto:= ""
Private oProcess

//--------------------------------------------------------------------------------
//Chamado por menu /Apos o faturametno no PE MATA460FIM
//--------------------------------------------------------------------------------
If 'MATA461' $ FunName()
	
	_lFilnF	:= .T.
	CalcMargContr(_cFilial,_cNumNota,_cSerieNf)	
Else

	_nOpc := Aviso("A T U A L I Z A  - M A R G E M - C O N T R I B U I C A O ",;
	+Chr(13)+Chr(10)+Chr(13)+Chr(10);
	+Chr(13)+Chr(10)+Chr(13)+Chr(10)+;
	"Escolha a op��o para realizar a atualiza��o do custo dos produtos!!!",{"Cadastros","Nota/Pedido"},2)

	If _nOpc == 1
	
		//--------------------------------------------------------------------------------
		//	Atualizar o cadastro de produtos e tabela de pre�o.
		//--------------------------------------------------------------------------------
	 	oProcess := MsNewProcess():New( { || fProCad(_cTabela) } ,"Atualizando Cadastros...", "Analisando registros..." , .F. )
		oProcess:Activate() 
	// 	MsgBox("Dados atualizados com sucesso,Favor verificar!!","Mensagem","Info")	 
	ElseIf _nOpc == 2   
		 
		 //--------------------------------------------------------------------------------
		// Atualizar as notas fiscais de saidas.
		//--------------------------------------------------------------------------------
	    oProcess := MsNewProcess():New( { || CalcMargContr(_cFilial,_cNumNota,_cSerieNf) } ,"Atualizando registros...", "Analisando registros..." , .F. )
		oProcess:Activate() 
	// 	MsgBox("Dados atualizados com sucesso,Favor verificar!!","Mensagem","Info")	                  
	EndIf 
EndIf
RestArea(_aAreaAnt)
Return 
 
  
/*
========================================================================================================================
Rotina----: fProCad
Autor-----: Davidson Clayton
Data------: 22/01/2019
========================================================================================================================
Descri��o-: Realiza a atualiza��o do cadastro dos produtos.
Uso-------:Especifico Nutratta 
========================================================================================================================
*/
Static Function	fProCad(_cTabel)  

Local nContx	:= 0 
Local cCaminho	:= "" 
                                                          
	Alert("Rotina desatualizada!")
  
Return        


/*
========================================================================================================================
Rotina----: CalcMargContr
Autor-----: Davidson Clayton
Data------: 22/04/2019
========================================================================================================================
Descri��o-: Rotina para refazer o calculo de margem de contribui��o e provisao de comissionamento.
Uso-------:Especifico Nutratta 
========================================================================================================================
*/

Static Function CalcMargContr(_cFilial,_cNumNota,_cSerieNf)

Local _aAreaAnt	:= GetArea()
Local _cQuery  	:= ""     
Local _aDad2	:= {}

//--------------------------------------------------------------------------------
//Busca as notas fiscais faturadas entre 2017 e 2018 2019
//--------------------------------------------------------------------------------
_cQuery := " SELECT D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_COD,D2_ITEM, "
_cQuery += " D2_C_BASCO,D2_C_PERCO,D2_C_VLCOM,D2_VALFRE,D2_VALIMP5,D2_PEDIDO,    "
_cQuery += " D2_COMIS5,D2_N_CUSTD,D2_N_MARGE,D2_N_PERCM,D2_CF,D2_ITEMPV	         "
_cQuery += " FROM "+RetSqlName("SD2")+"  D2"
_cQuery += " WHERE D2.D_E_L_E_T_ = ' '											 "
_cQuery += " AND D2.D2_FILIAL <>'0201'  										 "
_cQuery += " AND D2.D2_EMISSAO BETWEEN '20190101' AND '20901231' 				 "
//_cQuery += " AND D2.D2_C_HISTP = ''											 "
//_cQuery += " AND D2.D2_DOC ='000023385'                                        "

If _lFilnF

	_cQuery += " AND D2.D2_FILIAL   = '"+ _cFilial+"'							 "
	_cQuery += " AND D2.D2_DOC  	= '"+ _cNumNota+"'							 "   
	_cQuery += " AND D2.D2_SERIE    = '"+ _cSerieNf+"'							 "		
EndIf
 
DBUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),"TR2",.F.,.T.)

dbSelectArea("TR2")
dbGotop()
While ("TR2")->(!Eof())
		
	//-----------------------------------------------------------------------------------
	// Alimenta o Array com o resultado da query TR2
	//-----------------------------------------------------------------------------------
	Aadd(_aDad2,{("TR2")->D2_FILIAL,("TR2")->D2_DOC,("TR2")->D2_SERIE,("TR2")->D2_COD,;
				("TR2")->D2_ITEM,("TR2")->D2_CLIENTE,("TR2")->D2_LOJA,("TR2")->D2_PEDIDO,("TR2")->D2_CF,("TR2")->D2_ITEMPV})
		   
	If ! _lFilnF
	
		oProcess:IncRegua2("Atualizando: ")
	EndIf	

	dbSelectArea("TR2")
	("TR2")->(dbSkip())   
End       
//dbCloseArea(_cTempTbl)	 
("TR2")->(DbCloseArea())
  

//-----------------------------------------------------------------------------------
// Chama a rotina para realizar a grava��o dos itens.
//-----------------------------------------------------------------------------------
fCalcMrg(_aDad2)	
RestArea(_aAreaAnt)
Return


/*
========================================================================================================================
Rotina----: fCalcMrg
Autor-----: Davidson Clayton
Data------: 22/04/2019
========================================================================================================================
Descri��o-: Rotina para refazer o calculo de margem de contribui��o e provisao de comissionamento.
Uso-------: Especifico Nutratta 
========================================================================================================================
*/

Static Function fCalcMrg(_aDad2)

Local _cCliente				:= ""
Local _cLoja				:= ""
Local _cEstado				:= ""
Local _cTipo	   			:= ""
Local _cTabela				:= ""
Local _cCondPg 				:= ""
Local _cVendedor			:= ""
Local _cCliente				:= ""
Local _cLoja				:= ""
Local _AnoEmiss				:= "" 
Local _cCodPrd				:= "" 
Local _cCodEspcE			:= ""
Local _cDesCondE			:= ""
Local _cHistorico			:= ""
Local _cUM					:= ""
Local _cSitTrib				:= ""  
Local _cTAbZZs				:= ""
Local _cCondTAB				:= ""
Local _cFops				:= SuperGetMv("NT_CFCOMISS",.F.,"5101") 
Local _dEmissao				:= 	Date()
Local _dDtata1				:= 	Date()
Local _dDtata2				:= 	Date()	             
Local _dDtata3				:= 	Date()
Local _dDtata4				:= 	Date()
Local _aAreaAnt  			:=  GetArea()

Local 	_Nyx				:= 0                       
Local 	_nFreteUnit			:= 0
Local 	_nQtdVend			:= 0
Local 	_nTotFrete			:= 0
Local 	_nQtdVend			:= 0
Local	_nBaseComiss		:= 0		  
Local 	_nPerComiss 		:= 0	                                                                        
Local	_nVlComiss  		:= 0     
Local	_nValCustD			:= 0	  
Local	_nMargConTri 		:= 0  	 
Local	_nPerComiss    		:= 0  	  
Local	_nImposto			:= 0  	  
Local	_nPercTrib			:= 0 
Local   _nPrcUnit			:= 0 
Local   _nVlTbPreco			:= 0 
Local   _nMaxVlrTb			:= 0
Local 	_nConverT			:= 0  
Local	_nValBrut			:= 0                       
Local 	_nValCusto1         := 0 

For _Nyx := 1 To Len(_aDad2)

	
	If	Alltrim(_aDad2[_Nyx][9]) $ _cFops  	   
	     
		_nFreteUnit	:=	0
		_nTotFrete	:=  0
		//--------------------------------------------------------------------------------
		//Calcula o imposto de acordo com o solicitado.(_nValBrut -_nImposto)/100
		//Posiciona na SA1 para buscar a localiza��o do cliente Dentro ou fora do estado
		//--------------------------------------------------------------------------------
		dbSelectArea("SA1")
		dbSetOrder(1)
		If dbSeek(xFilial("SA1")+Padr(_aDad2[_Nyx][6],8)+Padr(_aDad2[_Nyx][7],4))
			
			_cEstado:=SA1->A1_EST
			
			If  _cEstado $ "GO"
				_cSitTrib:="D"
				_nPercTrib	:= 9.25/100  //0.0925
			Else
				_cSitTrib:="F"
				_nPercTrib	:= 14.05/100  //0.1405
			EndIf
		EndIf
	
		//---------------------------------------------------------------------------------------
		//Chama a fun��o para realizar a grava��o nas tabelas abaixo.
		// Ano 2019 - DA1_N_CUST
		// Ano 2018 - B1_N_2018
		// Ano 2017 - B1_N_2017
		// Verifica o ano de emissao do pedido para buscar o custo correto -
		// Posiciona no cadastro de produtos para pegar o conteudo do campo de custo
		// referente ao ano de emiss�o
		//---------------------------------------------------------------------------------------
		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(xFilial("SB1")+Padr(_aDad2[_Nyx][4],15))
			
			_cUM		:= Alltrim(SB1->B1_UM)
			_nValCusto1	:= 0		
		EndIf
		
		
		//--------------------------------------------------------------------------------
		// Pega os dados do cabe�a�ho do pedido de vendas
		//--------------------------------------------------------------------------------
		dbSelectArea("SC5")                                                                                                                          
		dbSetOrder(3) //C5_FILIAL+C5_CLIENTE+C5_LOJACLI+C5_NUM
		If dbSeek(Padr(_aDad2[_Nyx][1],4)+Padr(_aDad2[_Nyx][6],8)+Padr(_aDad2[_Nyx][7],4)+Padr(_aDad2[_Nyx][8],6))
			
			_cTipo			:=	SC5->C5_TIPO
			_cTabela		:=	SC5->C5_TABELA
			_cCondPg		:=	SC5->C5_CONDPAG
			_cVendedor		:=	SC5->C5_VEND1
			_cCliente		:=	SC5->C5_CLIENTE
			_cLoja			:=	SC5->C5_LOJACLI
			
			_dEmissao		:=	SC5->C5_EMISSAO
			_dDtata1		:= 	SC5->C5_DATA1
			_dDtata2		:= 	SC5->C5_DATA2
			_dDtata3		:= 	SC5->C5_DATA3
			_dDtata4		:= 	SC5->C5_DATA4
			
			_AnoEmiss 	:= Alltrim(Substr(Dtos(_dEmissao),1,4))
			
			
		 	If _AnoEmiss == '2017'			
				_nValCusto1 := SB1->B1_N_2017

			ElseIf 	_AnoEmiss == '2018'     	
				_nValCusto1 := SB1->B1_N_2018
								
			ElseIf 	_AnoEmiss == '2019'			
				_nValCusto1 := SB1->B1_N_2019 
			
			ElseIf 	_AnoEmiss == '2020'			
				_nValCusto1 := SB1->B1_N_2020 
				
			ElseIf 	_AnoEmiss == '2021'			
				_nValCusto1 := SB1->B1_N_2021
											
			EndIf
			
			//----------------------------------------------------------------------------------------------------
			// Tratamento das condi��es de pagamento.
			//----------------------------------------------------------------------------------------------------
			//--Condi��o 004
			If _cCondPg $ '004'
				
				_cCondTAB:='006'
			EndIf
			
			//--Condi��o 009
			If _cCondPg $ '009'
				
				_cCondTAB:='012'
			EndIf
			
			//--Tratamento para condi��o negociada-020.
			If _cCondPg $ '020'
				
				_cCondTAB:='012'
			EndIf 
			
			//--------------------------------------------------------------------------------
			// Busca o valor do frete unit�rio para gravar nos campos:
			// D2_N_FRETE    -  Valor Unit�rio de frete
			// D2_N_VFRETE   -  Valor Total do frete
			//--------------------------------------------------------------------------------
			dbSelectArea("SC6")                                                                                                                             
			dbSetOrder(2) //1-C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO   2-C6_FILIAL+C6_PRODUTO+C6_NUM+C6_ITEM
			If dbSeek(Padr(_aDad2[_Nyx][1],4)+Padr(_aDad2[_Nyx][4],15)+Padr(_aDad2[_Nyx][8],6)+Padr(_aDad2[_Nyx][10],2))
				
				_nQtdVend		:=	SC6->C6_QTDVEN
				_nValBrut       :=	SC6->C6_VALOR
				_cCodPrd		:=	SC6->C6_PRODUTO
				_nPrcUnit		:=	SC6->C6_C_VLRDI
				_nValCustD		:=	_nValCusto1 * _nQtdVend
				 
				//--------------------------------------------------------------------------------
				//Calculo Total do frete
				//--------------------------------------------------------------------------------
				_nFreteUnit	:=	SC6->C6_C_FRETE
				_nTotFrete	:= _nFreteUnit * _nQtdVend
				
				//--------------------------------------------------------------------------------
				//Calculo Imposto
				//--------------------------------------------------------------------------------
				_nImposto	:=	(_nValBrut * _nPercTrib)
				_nPercTrib	:=	_nPercTrib * 0.1
			
			
				//NT_GETCOMSS(_cFil,_cCodTab,_cProduto,_cCond,_cVendedor,_nQuant,_nPrcUnit,_nValFrete,_dEmissao,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_cSitTrib,_nOpc)			
				//----------------------------------------------------------------------------------------------------
				// Busca a base da comiss�o na fun��o especifica. DA1
				//----------------------------------------------------------------------------------------------------
				_nBaseComiss:= U_NT_GETCOMSS(Padr(_aDad2[_Nyx][1],4),_cTabela,_cCodPrd,_cCondPg,_cVendedor,_nQtdVend,_nPrcUnit,_nFreteUnit,_dEmissao,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_cSitTrib,1)
				
				//----------------------------------------------------------------------------------------------------
				// Busca o percentual de comissao na tabela especifica
				//----------------------------------------------------------------------------------------------------
				_nPerComiss:= U_NT_GETCOMSS(Padr(_aDad2[_Nyx][1],4),_cTabela,_cCodPrd,_cCondPg,_cVendedor,_nQtdVend,_nPrcUnit,_nFreteUnit,_dEmissao,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_cSitTrib,2)
				
				//----------------------------------------------------------------------------------------------------
				// Busca o valor a ser comissionado e grava o percentual e valor nos campos do or�amento.
				//----------------------------------------------------------------------------------------------------
				_nVlComiss  := U_NT_GETCOMSS(Padr(_aDad2[_Nyx][1],4),_cTabela,_cCodPrd,_cCondPg,_cVendedor,_nQtdVend,_nPrcUnit,_nFreteUnit,_dEmissao,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_cSitTrib,3)
				
				//----------------------------------------------------------------------------------------------------
				// Busca pre�o encontrado na tabela de pre�o.
				//----------------------------------------------------------------------------------------------------
				_nVlTbPreco := U_NT_GETCOMSS(Padr(_aDad2[_Nyx][1],4),_cTabela,_cCodPrd,_cCondTAB,_cVendedor,_nQtdVend,_nPrcUnit,_nFreteUnit,_dEmissao,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_cSitTrib,4)
				
				//----------------------------------------------------------------------------------------------------
				// Busca pre�o encontrado na tabela de pre�o.
				//----------------------------------------------------------------------------------------------------
				_nMaxVlrTb  := U_NT_GETCOMSS(Padr(_aDad2[_Nyx][1],4),_cTabela,_cCodPrd,_cCondTAB,_cVendedor,_nQtdVend,_nPrcUnit,_nFreteUnit,_dEmissao,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_cSitTrib,5)
				
				//----------------------------------------------------------------------------------------------------
				//Retorna a tabela de comissionamento encontrada
				//----------------------------------------------------------------------------------------------------
			    _cTAbZZs    := U_NT_GETCOMSS(Padr(_aDad2[_Nyx][1],4),_cTabela,_cCodPrd,_cCondTAB,_cVendedor,_nQtdVend,_nPrcUnit,_nFreteUnit,_dEmissao,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_cSitTrib,6)
				
				//-------------------------------------------------------------------------------------------
				//Calculo da Margem Bruta.
				//Valor bruto do produto no pedido de venda -Imposto gerado pra nota -frete do produto
				//provisao de comissao -(custo de material direto inserido na tabela de pre�o pelo Leonardo).
				//-------------------------------------------------------------------------------------------
				_nMargConTri := _nValBrut - (_nImposto + _nTotFrete + _nVlComiss +_nValCustD)
				_nPercM		 := (_nMargConTri/_nValBrut) * 100
				_nPercM		 :=	IIF(_nPercM < 0 ,0,Round(_nPercM,0))  
				_nPercM		 :=	IIF(_nPercM >= 100,99,_nPercM) 
				
				
			//--------------------------------------------------------------------------------
			// Realiza a grava��o na SC6 com os dados atualizados.
 			//--------------------------------------------------------------------------------
			dbSelectArea("SC6")
			dbSetOrder(2) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO   2-C6_FILIAL+C6_PRODUTO+C6_NUM+C6_ITEM
			If dbSeek(Padr(_aDad2[_Nyx][1],4)+Padr( _aDad2[_Nyx][4],15)+Padr(_aDad2[_Nyx][8],6)+Padr(_aDad2[_Nyx][10],2))
				
				//Realiza a convers�o do produto KG para TON
				If  _cUM == 'UN'
					
					_nConverT := SC6->C6_QTDVEN *25/1000
					
				ElseIf _cUM =='TL'
					
					_nConverT := SC6->C6_QTDVEN
				EndIf
									
				//Tratamento condi��es especiais.
				If Empty(SC6->C6_CONTRAT)
					_cCodEspcE := '02'
					_cDesCondE := 'CONTRATO'
				EndIf
				
				If _nQtdVend == 0
				
					_cHistorico := 'Quantidade Zerada'						
				ElseIf  _nPrcUnit <= _nVlTbPreco
					
					_cCodEspcE 	:= '04'
					_cDesCondE 	:= 'COND.ESP.PRECO'
					_cHistorico := 'PRECO/TABELA'+'-'+'V: '+Alltrim(Str(_nPrcUnit))+'-'+'TB: '+Alltrim(Str(_nVlTbPreco))+' M: '+Alltrim(Str(_nMaxVlrTb))
					
				ElseIf _nPrcUnit >= _nVlTbPreco .And. _nVlComiss == 0 .And. _nVlTbPreco > 0
			   	
			   			_cHistorico	:= 'FAIXA ZERO'+'-'+'V: '+Alltrim(Str(_nPrcUnit))+'-'+'TB: '+Alltrim(Str(_nVlTbPreco))+' M: '+Alltrim(Str(_nMaxVlrTb))
				ElseIf _nVlComiss > 0
					
					_cHistorico	:= 'COMISSIONAMENTO NORMAL'
					
				ElseIf _cVendedor == '000004' .And. _nVlTbPreco > 0
					
					_cHistorico	:= 'VENDEDOR BALCAO'
				Else
					
					_cHistorico	:= 'TABELA/PRODUTO NAO ENCONTRADA'
				EndIf
				
				If _AnoEmiss < '2017'
	   		
	   	   			_nValCusto1	:= 0
	   				_cHistorico := _AnoEmiss
				EndIf
				
				If RecLock("SC6",.F.)
					
					Replace	C6_C_BASCO	With 	_nBaseComiss
					Replace	C6_C_PERCO 	With 	_nPerComiss
					Replace	C6_C_VLCOM 	With 	_nVlComiss
					Replace	C6_N_CUSTD 	With 	_nValCustD
					Replace	C6_N_MARGE 	With	_nMargConTri
					Replace	C6_N_PERCM 	With	_nPerComiss
					Replace	C6_VLIMPOR	With 	_nImposto
					Replace	C6_COMIS5  	With 	_nPercTrib //% Imposto
					Replace	C6_C_CDOES	With 	_cCodEspcE
					Replace	C6_C_VMIN	With 	_nVlTbPreco
					Replace	C6_C_VMAX	With	_nMaxVlrTb
					Replace	C6_C_VDIF	With 	Abs( _nPrcUnit - _nVlTbPreco )
					Replace	C6_C_HISTP  With	_cHistorico+" - "+_cTAbZZs
					Replace	C6_N_TONEL  With	_nConverT
					MsUnlock()
				EndIf
				EndIf
			EndIf 
		
			//--------------------------------------------------------------------------------
			// Reinicia as variaveis
			//--------------------------------------------------------------------------------
			_nQtdVend		:=	0 
			_nValCustD		:=  0
			_nValBrut       :=	0  
			_nPrcUnit		:=	0
//			_nFreteUnit		:=	0
//			_nTotFrete		:=  0				
			_nBaseComiss	:=  0
			_nPerComiss		:=  0
			_nVlComiss 		:=  0 
			_nVlTbPreco 	:=  0
			_nMaxVlrTb 		:=  0
			_nMargConTri 	:=  0
			_nPercM			:=  0
			_nPercM			:=	0 
			_nPercM		 	:=	0 
			_cHistorico		:=  ""
			_cVendedor		:=  ""
			
			
			//--------------------------------------------------------------------------------
			// Posiciona na SD2 para gravar os dados calculados.
			// nMargConTri := _nValBrut - (_nImposto + _nFreteI + _nVlComiss + _nValCustD)
			//--------------------------------------------------------------------------------
			dbSelectArea("SD2")
			dbSetOrder(3) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			If dbSeek(Padr(_aDad2[_Nyx][1],4)+Padr(_aDad2[_Nyx][2],9)+Padr(_aDad2[_Nyx][3],3)+Padr(_aDad2[_Nyx][6],8)+Padr(_aDad2[_Nyx][7],4)+Padr(_aDad2[_Nyx][4],15)+Padr(_aDad2[_Nyx][5],2))
				
				_nQtdVend		:=	SD2->D2_QUANT
				_nValBrut       :=	SD2->D2_TOTAL  
				_cCodPrd		:=	SD2->D2_COD
				_nPrcUnit		:=	SD2->D2_PRUNIT - SD2->D2_N_FRETE //SD2->D2_C_VUNIT
				_nImposto		:=  (SD2->D2_VALIMP5+SD2->D2_VALIMP6+SD2->D2_VALICM)//D2_BASIMP5 | D2_VALIMP5 - COFINS Apura��o: + D2_BASIMP6 | D2_VALIMP6 - PIS Apura��o: 
				_nPICM			:=  (SD2->D2_VALICM/_nValBrut)*100
				_nPercTrib		:=	(SD2->D2_ALQIMP5+SD2->D2_ALQIMP6+ _nPICM)
				_nValCustD		:=  _nValCusto1 * _nQtdVend      
				
				
				 
				//--------------------------------------------------------------------------------
				//Calculo Total do frete
				//--------------------------------------------------------------------------------
			   //	_nFreteUnit	:=	SD2->D2_N_VFRET
			   //	_nTotFrete	:= _nFreteUnit * _nQtdVend
							
				//NT_GETCOMSS(_cFil,_cCodTab,_cProduto,_cCond,_cVendedor,_nQuant,_nPrcUnit,_nValFrete,_dEmissao,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_cSitTrib,_nOpc)			
				//----------------------------------------------------------------------------------------------------
				// Busca a base da comiss�o na fun��o especifica. DA1
				//----------------------------------------------------------------------------------------------------
				_nBaseComiss:= U_NT_GETCOMSS(Padr(_aDad2[_Nyx][1],4),_cTabela,_cCodPrd,_cCondPg,_cVendedor,_nQtdVend,_nPrcUnit,_nFreteUnit,_dEmissao,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_cSitTrib,1)
				
				//----------------------------------------------------------------------------------------------------
				// Busca o percentual de comissao na tabela especifica
				//----------------------------------------------------------------------------------------------------
				_nPerComiss:= U_NT_GETCOMSS(Padr(_aDad2[_Nyx][1],4),_cTabela,_cCodPrd,_cCondPg,_cVendedor,_nQtdVend,_nPrcUnit,_nFreteUnit,_dEmissao,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_cSitTrib,2)
				
				//----------------------------------------------------------------------------------------------------
				// Busca o valor a ser comissionado e grava o percentual e valor nos campos do or�amento.
				//----------------------------------------------------------------------------------------------------
				_nVlComiss := U_NT_GETCOMSS(Padr(_aDad2[_Nyx][1],4),_cTabela,_cCodPrd,_cCondPg,_cVendedor,_nQtdVend,_nPrcUnit,_nFreteUnit,_dEmissao,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_cSitTrib,3)
				
				//----------------------------------------------------------------------------------------------------
				// Busca pre�o encontrado na tabela de pre�o.
				//----------------------------------------------------------------------------------------------------
				_nVlTbPreco := U_NT_GETCOMSS(Padr(_aDad2[_Nyx][1],4),_cTabela,_cCodPrd,_cCondPg,_cVendedor,_nQtdVend,_nPrcUnit,_nFreteUnit,_dEmissao,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_cSitTrib,4)
				
				//----------------------------------------------------------------------------------------------------
				// Busca pre�o encontrado na tabela de pre�o.
				//----------------------------------------------------------------------------------------------------
				_nMaxVlrTb := U_NT_GETCOMSS(Padr(_aDad2[_Nyx][1],4),_cTabela,_cCodPrd,_cCondPg,_cVendedor,_nQtdVend,_nPrcUnit,_nFreteUnit,_dEmissao,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_cSitTrib,5)
								
				//----------------------------------------------------------------------------------------------------
				//Retorna a tabela de comissionamento encontrada
				//----------------------------------------------------------------------------------------------------
			    _cTAbZZs := U_NT_GETCOMSS(Padr(_aDad2[_Nyx][1],4),_cTabela,_cCodPrd,_cCondPg,_cVendedor,_nQtdVend,_nPrcUnit,_nFreteUnit,_dEmissao,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_cSitTrib,6)

				//-------------------------------------------------------------------------------------------
				//Calculo da Margem Bruta.
				//Valor bruto do produto no pedido de venda -Imposto gerado pra nota -frete do produto
				//provisao de comissao -(custo de material direto inserido na tabela de pre�o pelo Leonardo).
				//-------------------------------------------------------------------------------------------
				_nMargConTri := _nValBrut - (_nImposto + _nTotFrete + _nVlComiss +_nValCustD)
				_nPercM		 := (_nMargConTri/_nValBrut) * 100
				_nPercM		 :=	IIF(_nPercM < 0 ,0,Round(_nPercM,0))  
				_nPercM		 :=	IIF(_nPercM >= 100,99,_nPercM) 
								
				//Realiza a convers�o do produto KG para TON
				If  _cUM == 'UN'
					
					_nConverT := SD2->D2_QUANT *25/1000
					
				ElseIf _cUM =='TL'
					
					_nConverT := SD2->D2_QUANT
				EndIf
				
				If _nQtdVend == 0
				
					_cHistorico := 'Quantidade Zerada'						
				ElseIf  _nPrcUnit <= _nVlTbPreco
					
					_cCodEspcE 	:= '04'
					_cDesCondE 	:= 'COND.ESP.PRECO'
					_cHistorico := 'PRECO/TABELA'+'-'+'V: '+Alltrim(Str(_nPrcUnit))+'-'+'TB: '+Alltrim(Str(_nVlTbPreco))+' M: '+Alltrim(Str(_nMaxVlrTb))
					
				ElseIf _nPrcUnit >= _nVlTbPreco .And. _nVlComiss == 0  .And. _nVlTbPreco > 0
			   	
			   			_cHistorico	:= 'FAIXA ZERO'+'-'+'V: '+Alltrim(Str(_nPrcUnit))+'-'+'TB: '+Alltrim(Str(_nVlTbPreco))+' M: '+Alltrim(Str(_nMaxVlrTb))
				ElseIf _nVlComiss > 0
					
					_cHistorico	:= 'COMISSIONAMENTO NORMAL'
					
				ElseIf _cVendedor == '000004' .And. _nVlTbPreco > 0
					
					_cHistorico	:= 'VENDEDOR BALCAO'
				Else
					
					_cHistorico	:= 'TABELA/PRODUTO NAO ENCONTRADA'
				EndIf
				
				If _AnoEmiss < '2017'
	   		
	   	   			_nValCusto1	:= 0
	   				_cHistorico := _AnoEmiss
				EndIf	
				
				
				If RecLock("SD2",.F.)
					
					Replace D2_C_BASCO  With _nBaseComiss
					Replace D2_C_PERCO 	With _nPerComiss
					Replace D2_C_VLCOM 	With _nVlComiss
					Replace D2_N_CUSTD 	With _nValCustD
					Replace D2_N_MARGE 	With _nMargConTri
					Replace D2_C_IMPOS 	With _nImposto
					Replace D2_N_COMIS 	With _nPercTrib
					Replace D2_N_FRETE 	With _nFreteUnit
					Replace D2_N_VFRET  With _nTotFrete
					Replace D2_C_CDOES  With _cCodEspcE
					Replace D2_C_ESPEC  With _cDesCondE
					Replace	D2_C_HISTP	With _cHistorico+" - "+_cTAbZZs
					Replace	D2_C_VMIN	With _nVlTbPreco
					Replace	D2_C_VMAX	With _nMaxVlrTb
					Replace	D2_C_VDIF	With Abs( _nPrcUnit - _nVlTbPreco )
					Replace	D2_N_TONEL  With _nConverT
					Replace D2_N_PERCM  With _nPercM
					
					MsUnlock()
				EndIf
			EndIf
		EndIf
	EndIf
Next _Nyx 

RestArea(_aAreaAnt)
Return











 
 
 
        



   







           

