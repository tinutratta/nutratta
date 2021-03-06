#Include 'Protheus.ch'
#Include 'Parmtype.ch'
                                                                                                        
/*
========================================================================================================================
Rotina----: NT_GETCOMSS
Autor-----: Davidson C. Carvalho - Nutratta.
Data------: 13/05/2019 -Utilizado na revitaliza��o de comiss�o 2019.
========================================================================================================================
Descri��o-: Executado o calculo da comiss�o na efetiva��o do pre-pedido e grava��o do pedido de vendas
Uso-------: Realiza o calculo de comiss�o e devolve o resultado de acordo com os parametros usados.
========================================================================================================================
*/   
User Function NT_GETCOMSS(_cFil,_cCodTab,_cProduto,_cCond,_cVendedor,_nQuant,_nPrcUnit,_nValFrete,_dEmissao,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_cSitTrib,_nOpc)

_nPrcTbl		:= 0
_nPrcMax		:= 0
_nPrcVen		:= 0
_nPercent		:= 0
_nBaseComiss	:= 0
_nValComiss 	:= 0
_nFreteI		:= 0 
_nVal0000		:= 0
_nVal0025		:= 0  
_nVal0050		:= 0
_nVal0075		:= 0 
_nVal0100		:= 0
_nVal0125		:= 0  
_nVal0150		:= 0                
_nVal0175		:= 0              
_nVal0200		:= 0 
_nVal0225		:= 0  
_nVal0250		:= 0     
_nVal0275		:= 0 
_nVal0300		:= 0 
_nVal0325		:= 0 
_nVal0350		:= 0  
_nVal0375		:= 0                    
_nVal0400		:= 0
_nVal0425		:= 0  
_nVal0450		:= 0 
_nVal0475		:= 0
_nVal0500 		:= 0  
_nVal0525 		:= 0  
_nVal0550 		:= 0  
_nVal0575 		:= 0 	
_nVal0600 		:= 0
_nVal0625 		:= 0 
_nVal0650 		:= 0
_nVal0675 		:= 0
_nVal0700 		:= 0 
_nVal0725 		:= 0
_nVal0750 		:= 0
_nVal0775 		:= 0				       
_nVal0800 		:= 0 
_nVal0900 		:= 0
_nVal1000 		:= 0 
_nVal1100 		:= 0 
_nVal1200 		:= 0 
_nVal1300 		:= 0
_nVal1400 		:= 0
_nVal1500 		:= 0 
_nVal1600 		:= 0 
_nVal1700 		:= 0 
_nVal1800 		:= 0 
_nVal1900 		:= 0 
_nVal2000 		:= 0 
_nVal0005  		:= 0
_nVal0004 		:= 0
_nVal0003  		:= 0 
_nVal0002 		:= 0  
_nVal0001 		:= 0

_cAlias			:= "ZB4"
_cTAbZZs		:= "" 
_cCondRel		:= "" 
_nRetorno		:= ""
_aTitulo		:= {}

//---------------------------------------------------
// Retorna a condi��o do relat�rio _cCondRel.
//---------------------------------------------------
_cCondRel 	:= fConPagto(_cCond,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_dEmissao,1)

//---------------------------------------------------
// Retorna a condi��o do relat�rio _nQTdParc.
//---------------------------------------------------
_nQTdParc 	:= fConPagto(_cCond,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_dEmissao,2)

//---------------------------------------------------
// Retorna a condi��o do relat�rio _nEncarg.
//---------------------------------------------------
_nEncarg 	:= fConPagto(_cCond,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_dEmissao,3)

//---------------------------------------------------
// Retorna a condi��o do relat�rio _cCond.
//---------------------------------------------------
_cCond	 	:= fConPagto(_cCond,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_dEmissao,4)

		
//--------------------------------------------------------------------------------
//Posiciona na SA3 para buscar as informa��es do Vendedor/Representante.
//--------------------------------------------------------------------------------
dbSelectArea("SA3")
dbSetOrder(1)
If dbSeek(xFilial("SA3")+_cVendedor)

	_cTipVend  	:= fGetTpVend(_cTipVend,_dEmissao,1)
	_cTAbZZs	:= fGetTpVend(_cTipVend,_dEmissao,2)  
EndIf

//--------------------------------------------------------------------------------
//Realiza o calculo da base da comiss�o.
//--------------------------------------------------------------------------------
_nPrcUnitot	:= _nQuant  * _nPrcUnit 
_nFreteI	:= _nValFrete * _nQuant
_nBaseComiss:= (_nPrcUnitot)/_nQTdParc  //(_nPrcUnitot - _nFreteI)/_nQTdParc 04/06/2020  Lorran

//--------------------------------------------------------------------------------
//Posiciona na DA1 para buscar o percentual de comiss�o a ser aplicado.
//--------------------------------------------------------------------------------
dbSelectArea(Padr(_cAlias,3))
dbSetOrder(1)                                                         
//If dbSeek(xFilial(Padr(_cCodTab,3))+Padr(_cTipVend,1)+Padr(_cSitTrib,1)+Padr(_cCond,3)+Alltrim(Padr(_cProduto,15)))  
//	ZB4_FILIAL+ZB4_TABELA+ZB4_CODTAB+ZB4_COND+ZB4_CODIGO                                                                                                            
If dbSeek(xFilial(Padr(_cAlias,3))+Padr(_cTAbZZs,3)+Padr(_cCodTab,3)+Padr(_cCond,3)+Alltrim(Padr(_cProduto,15)))
    
	_nVal0000	:= (_cAlias)->&(((_cAlias)+"_0000"))	
	_nVal0025	:= (_cAlias)->&(((_cAlias)+"_0025"))  
	_nVal0050	:= (_cAlias)->&(((_cAlias)+"_0050")) 
	_nVal0075	:= (_cAlias)->&(((_cAlias)+"_0075")) 
	_nVal0100	:= (_cAlias)->&(((_cAlias)+"_0100")) 
	_nVal0125	:= (_cAlias)->&(((_cAlias)+"_0125"))  
	_nVal0150	:= (_cAlias)->&(((_cAlias)+"_0150"))                
	_nVal0175	:= (_cAlias)->&(((_cAlias)+"_0175"))              
	_nVal0200	:= (_cAlias)->&(((_cAlias)+"_0200")) 
	_nVal0225	:= (_cAlias)->&(((_cAlias)+"_0225"))  
	_nVal0250	:= (_cAlias)->&(((_cAlias)+"_0250"))     
	_nVal0275	:= (_cAlias)->&(((_cAlias)+"_0275"))  
	_nVal0300	:= (_cAlias)->&(((_cAlias)+"_0300")) 
	_nVal0325	:= (_cAlias)->&(((_cAlias)+"_0325"))  
	_nVal0350	:= (_cAlias)->&(((_cAlias)+"_0350"))  
	_nVal0375	:= (_cAlias)->&(((_cAlias)+"_0375"))                    
	_nVal0400	:= (_cAlias)->&(((_cAlias)+"_0400")) 
	_nVal0425	:= (_cAlias)->&(((_cAlias)+"_0425"))  
	_nVal0450	:= (_cAlias)->&(((_cAlias)+"_0450"))  
	_nVal0475	:= (_cAlias)->&(((_cAlias)+"_0475")) 	
	_nVal0500 	:= (_cAlias)->&(((_cAlias)+"_0500"))  
	_nVal0525 	:= (_cAlias)->&(((_cAlias)+"_0525"))  
	_nVal0550 	:= (_cAlias)->&(((_cAlias)+"_0550"))  
	_nVal0575 	:= (_cAlias)->&(((_cAlias)+"_0575"))  	
	_nVal0600 	:= (_cAlias)->&(((_cAlias)+"_0600")) 
	_nVal0625 	:= (_cAlias)->&(((_cAlias)+"_0625")) 
	_nVal0650 	:= (_cAlias)->&(((_cAlias)+"_0650")) 
	_nVal0675 	:= (_cAlias)->&(((_cAlias)+"_0675"))  
	_nVal0700 	:= (_cAlias)->&(((_cAlias)+"_0700")) 
	_nVal0725 	:= (_cAlias)->&(((_cAlias)+"_0725")) 
	_nVal0750 	:= (_cAlias)->&(((_cAlias)+"_0750")) 
	_nVal0775 	:= (_cAlias)->&(((_cAlias)+"_0775")) 				       
	_nVal0800 	:= (_cAlias)->&(((_cAlias)+"_0800")) 
	_nVal0900 	:= (_cAlias)->&(((_cAlias)+"_0900")) 
	_nVal1000 	:= (_cAlias)->&(((_cAlias)+"_1000")) 
	_nVal1100 	:= (_cAlias)->&(((_cAlias)+"_1100"))  
	_nVal1200 	:= (_cAlias)->&(((_cAlias)+"_1200")) 
	_nVal1300 	:= (_cAlias)->&(((_cAlias)+"_1300")) 
	_nVal1400 	:= (_cAlias)->&(((_cAlias)+"_1400")) 
	_nVal1500 	:= (_cAlias)->&(((_cAlias)+"_1500"))  
	_nVal1600 	:= (_cAlias)->&(((_cAlias)+"_1600"))  
	_nVal1700 	:= (_cAlias)->&(((_cAlias)+"_1700"))  
	_nVal1800 	:= (_cAlias)->&(((_cAlias)+"_1800"))  
	_nVal1900 	:= (_cAlias)->&(((_cAlias)+"_1900"))  
	_nVal2000 	:= (_cAlias)->&(((_cAlias)+"_2000"))

	///-----------------------------------------------------------------------------------------
	// Tratamento de comissionamento por hierarquia comercial (Negativos)
	//------------------------------------------------------------------------------------------	
	/*
	_nVal0005 	:= (_cAlias)->&(((_cAlias)+"_0005"))
	_nVal0004 	:= (_cAlias)->&(((_cAlias)+"_0004"))
	_nVal0003 	:= (_cAlias)->&(((_cAlias)+"_0003")) 
	_nVal0002 	:= (_cAlias)->&(((_cAlias)+"_0002"))  
	_nVal0001 	:= (_cAlias)->&(((_cAlias)+"_0001")) 
	*/
			
	///-----------------------------------------------------------------------------------------
	// Montagem e carregamento do array para posteriormente encontar o percentual de comiss�o
	//------------------------------------------------------------------------------------------
	AAdd(_aTitulo,{'_nVal0000',_nVal0000,0})
	AAdd(_aTitulo,{'_nVal0025',_nVal0025,0.25})		
	AAdd(_aTitulo,{'_nVal0050',_nVal0050,0.50})
	AAdd(_aTitulo,{'_nVal0075',_nVal0075,0.75})
	AAdd(_aTitulo,{'_nVal0100',_nVal0100,1})
	AAdd(_aTitulo,{'_nVal0125',_nVal0125,1.25})
	AAdd(_aTitulo,{'_nVal0150',_nVal0150,1.50})
	AAdd(_aTitulo,{'_nVal0175',_nVal0175,1.75})
	AAdd(_aTitulo,{'_nVal0200',_nVal0200,2})
	AAdd(_aTitulo,{'_nVal0225',_nVal0225,2.25})
	AAdd(_aTitulo,{'_nVal0250',_nVal0250,2.50})  
	AAdd(_aTitulo,{'_nVal0275',_nVal0275,2.75})
	AAdd(_aTitulo,{'_nVal0300',_nVal0300,3})
	AAdd(_aTitulo,{'_nVal0325',_nVal0325,3.25})
	AAdd(_aTitulo,{'_nVal0350',_nVal0350,3.50})   
	AAdd(_aTitulo,{'_nVal0375',_nVal0375,3.75}) 
	AAdd(_aTitulo,{'_nVal0400',_nVal0400,4})
	AAdd(_aTitulo,{'_nVal0425',_nVal0425,4.25})
	AAdd(_aTitulo,{'_nVal0450',_nVal0450,4.50})
	AAdd(_aTitulo,{'_nVal0475',_nVal0475,4.75})
	AAdd(_aTitulo,{'_nVal0500',_nVal0500,5}) 
	AAdd(_aTitulo,{'_nVal0525',_nVal0525,5.25})
	AAdd(_aTitulo,{'_nVal0550',_nVal0550,5.50})
	AAdd(_aTitulo,{'_nVal0575',_nVal0575,5.75})
	AAdd(_aTitulo,{'_nVal0600',_nVal0600,6})
	AAdd(_aTitulo,{'_nVal0625',_nVal0625,6.25})
	AAdd(_aTitulo,{'_nVal0650',_nVal0650,6.50})
	AAdd(_aTitulo,{'_nVal0675',_nVal0675,6.75})
	AAdd(_aTitulo,{'_nVal0700',_nVal0700,7})
	AAdd(_aTitulo,{'_nVal0725',_nVal0725,7.25})
	AAdd(_aTitulo,{'_nVal0750',_nVal0750,7.50})
	AAdd(_aTitulo,{'_nVal0775',_nVal0775,7.75})
	AAdd(_aTitulo,{'_nVal0800',_nVal0800,8})
	AAdd(_aTitulo,{'_nVal0900',_nVal0900,9})
	AAdd(_aTitulo,{'_nVal1000',_nVal1000,10})  
	AAdd(_aTitulo,{'_nVal1100',_nVal1100,11})
	AAdd(_aTitulo,{'_nVal1200',_nVal1200,12})
	AAdd(_aTitulo,{'_nVal1300',_nVal1300,13})
	AAdd(_aTitulo,{'_nVal1400',_nVal1400,14})   
	AAdd(_aTitulo,{'_nVal1500',_nVal1500,15})
	AAdd(_aTitulo,{'_nVal1600',_nVal1600,16})
	AAdd(_aTitulo,{'_nVal1700',_nVal1700,17})
	AAdd(_aTitulo,{'_nVal1800',_nVal1800,18})
	AAdd(_aTitulo,{'_nVal1900',_nVal1900,19})
   	AAdd(_aTitulo,{'_nVal2000',_nVal2000,20})
   	
   	///-----------------------------------------------------------------------------------------
	// Tratamento de comissionamento por hierarquia comercial (Negativos)
	//------------------------------------------------------------------------------------------	
   /*
   	AAdd(_aTitulo,{'_nVal0005',_nVal0005,5})
   	AAdd(_aTitulo,{'_nVal0004',_nVal0004,4})
   	AAdd(_aTitulo,{'_nVal0003',_nVal0003,3})
	AAdd(_aTitulo,{'_nVal0002',_nVal0002,2})	
	AAdd(_aTitulo,{'_nVal0001',_nVal0001,1})
	*/
			
	///-----------------------------------------------------------------------------------------
	// Pega o menor pre�o da tabela de pre�o.
	//------------------------------------------------------------------------------------------
	For i:=1 To Len(_aTitulo)
		
		If  _aTitulo[i][2] > 0
			
			_nPrcTbl := _aTitulo[i][2] 
			exit
		EndIf
	Next i
		
	///-----------------------------------------------------------------------------------------
	// Monta o ascan para retornar o valor.
	//------------------------------------------------------------------------------------------
	For i:=1 To Len(_aTitulo)
		
		If  _aTitulo[i][2] > 0
			
			_nPrcMax 	:= _aTitulo[i][2]  //Retorna o pre�o maximo.
			
			If _nPrcUnit >= _aTitulo[i][2]
				_nPercent := _aTitulo[i][3]
			Else
				If _nPercent > 0
					_nPercent := _nPercent    //Retorna o percentual de comissao.
				End
			EndIf
		EndIf
	Next i
	
	///-----------------------------------------------------------------------------------------
	// Pega o menor pre�o da tabela de pre�o.
	//------------------------------------------------------------------------------------------
	For i:=1 To Len(_aTitulo)
		
		If  _aTitulo[i][2] > 0
			
			_nPrcTbl := _aTitulo[i][2] 
			exit
		EndIf
	Next i

	_nValComiss:= (_nBaseComiss * _nPercent)/100   //Retonar o valor de comiss�o
EndIf
    

///-----------------------------------------------------------------------------------------
// Retornos possveis comissionamento.   
//------------------------------------------------------------------------------------------
If _nOpc == 1   //Retorna a base da comissao.
	_nRetorno:= _nBaseComiss
ElseIf _nOpc == 2 	//Retorna o % de comissao.
	_nRetorno:= _nPercent  
ElseIf _nOpc == 3	//Retorna o valor de comissao.
	_nRetorno:= _nValComiss 
ElseIf _nOpc == 4	//Retorna o menorpre�o encontrado na tabela de pre�o.
	_nRetorno:= _nPrcTbl	
ElseIf _nOpc == 5 	//Retorna o maior pre�o encontrado na tabela de pre�o.
	_nRetorno:= _nPrcMax	
ElseIf _nOpc == 6 	//Retorna a Tabela de comissionamento .
	_nRetorno:=_cTAbZZs   
ElseIf _nOpc == 7 	//Retorna a condicao a ser impressa no relatorio.
	_nRetorno:= _cCondRel	
ElseIf _nOpc == 8 //Retorna a quantidade de parcelas. 	
	_nRetorno:=	_nQTdParc
ElseIf _nOpc == 9  	//Retorna o historico do comissionamento.	

	If _nPrcUnit == 0			
		
		_nRetorno := 'QUANTIDADE ZERADA'						
	
	ElseIf  _nPrcUnit <= _nPrcTbl .And. _nPrcTbl > 0			
		
		_nRetorno := 'PRECO/TABELA'+'-'+'V: '+Alltrim(Str(_nPrcUnit))+'-'+'TB: '+Alltrim(Str(_nPrcTbl))+' M: '+Alltrim(Str(_nPrcMax))		
	
	ElseIf _nPrcUnit >= _nPrcTbl .And. _nValComiss == 0  .And. _nPrcTbl > 0   	
   		
   		_nRetorno	:= 'FAIXA ZERO'+'-'+'V: '+Alltrim(Str(_nPrcUnit))+'-'+'TB: '+Alltrim(Str(_nPrcTbl))+' M: '+Alltrim(Str(_nPrcMax))
	
	ElseIf _nValComiss > 0		
		
		_nRetorno	:= 'COMISSIONAMENTO NORMAL'		
		
	ElseIf _cVendedor == '000004' .And. _nPrcTbl > 0
		
		_nRetorno	:= 'VENDEDOR BALCAO'
	
	Else		
	
		_nRetorno	:= 'TABELA/PRODUTO NAO ENCONTRADA'
	EndIf

EndIf

Return(_nRetorno)    


/*
========================================================================================================================
Rotina----: fGetTpVend
Autor-----: Davidson Clayton
Data------: 25/01/2019
========================================================================================================================
Descri��o-: Rotina para buscar selecionar o tipo de vendedor.
Uso-------: Especifico Nutratta 
========================================================================================================================
*/
Static Function fGetTpVend(_cTipVend,_dEmissao,_nOpc) 
 
Local _cTAbZZs	:= ""

//---------------------------------------------------------------------------------------
//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZB-Modelo Antigo
// Usado: 2 - 4  - ZZB 
//---------------------------------------------------------------------------------------	
If Dtos(_dEmissao) > '20170201' .And. Dtos(_dEmissao) < '20170315'	
	
	_cTAbZZs:="ZZB"
	_cTipVend:='4' 
	
//---------------------------------------------------------------------------------------
//Rotina para calcular a comiss�o de cada produto do pedido de vendas.  ZZ9-Modelo Novo
// Usado: 2 - 4 - ZZ9
//---------------------------------------------------------------------------------------						
ElseIf Dtos(_dEmissao) >= '20170315'	 .And. Dtos(_dEmissao) < '20170403'	
	_cTAbZZs:="ZZ9"
	_cTipVend:='4'	

//ZZC-03/04/2017	
ElseIf Dtos(_dEmissao) >= '20170403' .And. Dtos(_dEmissao) < '20170413'	
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZC-Primeira tabela abril- 2017. 
	//Usado: 2 - 4 -ZZC
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZZC"
	_cTipVend:='4'
	
//ZZD-13/04/2017
ElseIf Dtos(_dEmissao) >= '20170413' .And. Dtos(_dEmissao) < '20170508'		
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZD-Segunda tabela abril- 2017.
	//  Usado: 2 - 4  -ZZD
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZZD"
	_cTipVend:='4'		                  								

//ZZE-08/05/2017
ElseIf Dtos(_dEmissao) >= '20170508' .And. Dtos(_dEmissao) < '20170603'	
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZE-Segunda tabela Maio- 2017. 
	// Usado: 2 - 4 - ZZE
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZZE"
	_cTipVend:='4'	                  								
				
//ZZF-03/06/2017  a 13/06/2017
ElseIf Dtos(_dEmissao) >= '20170603'	 .And. Dtos(_dEmissao) < '20170613'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZF-Prmeira tabela de Junho 2017. 
	// Usado: 2 - 4 -ZZF
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZZF"
	_cTipVend:='4'	                  								

//ZZG-13/06/2017 a   21/07/2017
ElseIf Dtos(_dEmissao) >= '20170613'	.And. Dtos(_dEmissao) < '20170721'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZG-Segunda tabela de Junho 2017.
	// Usado: 2 - 4  - ZZG
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZZG"
	_cTipVend:='4'			                  								

//ZZH-21/07/2017
ElseIf Dtos(_dEmissao) >= '20170721'	.And. Dtos(_dEmissao) <= '20170807'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZH- Unica tabela de julho 2017. 
	// Usado: 2 - 4 - ZZH
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZZH"
	_cTipVend:='4'	                  								

//ZZI-08/08/2017
ElseIf Dtos(_dEmissao) >= '20170808' .And. Dtos(_dEmissao) <= '20170911'	
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZH- Unica tabela de julho 2017.
	// Usado: 2 - 4  - ZZI
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZZI"
	_cTipVend:='4'		

//ZZL-11/09/2017 a 08/10/2017
ElseIf Dtos(_dEmissao) >= '20170912'	.And. Dtos(_dEmissao) <= '20171008'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZl- Unica tabela de julho 2017.
	// Usado: 2-4-5 -ZZL
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZZL"
	_cTipVend:='5'
	
//ZZM-09/10/2017 a 10/12/2017
ElseIf Dtos(_dEmissao) >= '20171009'	.And. Dtos(_dEmissao) <= '20171210'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZH- Unica tabela de julho 2017. 
	//Usado: 2-4-5 - ZZM
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZZM"
	_cTipVend:='5'

//ZZN-11/12/2017 
ElseIf Dtos(_dEmissao) >= '20171211'.And. Dtos(_dEmissao) <= '20180114'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZH- Unica tabela de julho 2017.
	//Usado: 2-4-5 - ZZN 
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZZN"
	_cTipVend:='5'													

//ZZO-24/01/2018 
ElseIf Dtos(_dEmissao) >= '20180115' .And. Dtos(_dEmissao) <= '20180304'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZH- Unica tabela de julho 2017. 
	//Usado: 2-4-5  - ZZO

	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZZO"
	_cTipVend:='5'															

//ZZP-05/03/2018 
ElseIf Dtos(_dEmissao) >= '20180305' .And. Dtos(_dEmissao) <= '20180404'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZP- Tabela de Mar�o 2018. 
	// Usado: 2-4-5 - ZZP
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZZP"
	_cTipVend:='5'

//TODO
//ZZQ-05/03/2018 
ElseIf Dtos(_dEmissao) >= '20180405' .And. Dtos(_dEmissao) <= '20180506'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZQ- Tabela de abril 2018. 
	//Usado: 2-4-5 -ZZQ
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZZQ"
	_cTipVend:='5'

//ZZR-07/05/2018 
ElseIf Dtos(_dEmissao) >= '20180507' .And. Dtos(_dEmissao) <= '20180603'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZR- Tabela de Mar�o 2018.
	// 2-4-5-6-7 - ZZR
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZZR"
	_cTipVend:='7'

//ZZS-24/06/2018 
ElseIf Dtos(_dEmissao) >= '20180604' .And. Dtos(_dEmissao) <= '20180813'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZS- Tabela de Mar�o 2018. 
	// 2-4-5-6-7 - ZZS
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZZS"
	_cTipVend:='7'																		

//ZZT-14/08/2018
ElseIf Dtos(_dEmissao) >= '20180814' .And. Dtos(_dEmissao) <= '20180910'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZS- Tabela de Mar�o 2018.     
	// 2-4-5-6-7-8 - ZZT
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZZT"
	_cTipVend:='8'

//ZZU-11/09/2018
ElseIf Dtos(_dEmissao) >= '20180911' .And. Dtos(_dEmissao) <= '20180917'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZS- Tabela de Mar�o 2018.
	//4-5-6-7 - ZZU 
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZZU"
	_cTipVend:='7'																		

//ZZV-18/09/2018
ElseIf Dtos(_dEmissao) >= '20180918' .And. Dtos(_dEmissao) <= '20181007'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZZS- Tabela de Mar�o 2018. 
	// Usado: 1-4-9 - ZZV
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZZV"
	_cTipVend:='9'		 

//ZZA4-29/10/2018
ElseIf Dtos(_dEmissao) >= '20181008' .And. Dtos(_dEmissao) <= '20181015'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZA4- Outubro 2018. 
	// Usado:1-9 - ZA4
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZA4"
	_cTipVend:='9' 

//ZZA5-29/10/2018
ElseIf Dtos(_dEmissao) >= '20181016' .And. Dtos(_dEmissao) <= '20181108'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZA4- Outubro 2018. 
	// 1-7-8-9  - ZA5
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZA5"
	_cTipVend:='9' 																					

//ZZA6-29/11/2018
ElseIf Dtos(_dEmissao) >= '20181109' .And. Dtos(_dEmissao) <= '20181202'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZA4- Outubro 2018. 
	//Usado: 5-7 -ZA6
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZA6"
	_cTipVend:='7'
	  
//ZZA7-17/12/2018
ElseIf Dtos(_dEmissao) >= '20181203' .And. Dtos(_dEmissao) <= '20190207'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZA7- Outubro 2018. 
	// Usado: 5-7 - ZA7
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZA7"
	_cTipVend:='7'																	

//ZZA9-08/02/2019
ElseIf Dtos(_dEmissao) >= '20190208' .And. Dtos(_dEmissao) <= '20190315'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZA8- Outubro 2018. 
	// Usado: 5-7 - ZA8
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZA9"
	_cTipVend:='7'

//ZB2
ElseIf Dtos(_dEmissao) >= '20190316' .And. Dtos(_dEmissao) <= '20190602'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZA8- Outubro 2018. 
	// Usado: 5-7 - ZA8
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZB2"
	_cTipVend:='7'	

//ZB5
ElseIf Dtos(_dEmissao) >= '20190603' .And. Dtos(_dEmissao) <= '20190807'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZA8- Outubro 2018. 
	// Usado: 5-7 - ZA8
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZB5"
	_cTipVend:='7'	

//ZB6
ElseIf Dtos(_dEmissao) >= '20190808'  .And. Dtos(_dEmissao) <= '20191008'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZB7 
	// Usado: 5-7 - ZA8
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZB6"
	_cTipVend:='7'	

//ZB7
ElseIf Dtos(_dEmissao) >= '20191009'   .And. Dtos(_dEmissao) <= '20191117'   //Tabela 040
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZB7. 
	// Usado: 5-7 - ZB7
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZB7"
	_cTipVend:='7'	
	
ElseIf Dtos(_dEmissao) >= '20191118'    .And. Dtos(_dEmissao) <= '20200420'   //Comissinamento negativo
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZB8. 
	// Usado: 5-7 - ZB7
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZB8"
	_cTipVend:='7'	

ElseIf  Dtos(_dEmissao) >= '20200421'  .And. Dtos(_dEmissao) <= '20200531'
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-ZB9. 
	// Usado: 5-7 - ZB9
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="ZB9"
	_cTipVend:='7'
	
ElseIf  Dtos(_dEmissao) >= '20200601' .And. Dtos(_dEmissao) <= '20200630'    
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-B10. 
	// Usado: 5-7 - Z
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="B10"
	_cTipVend:='7'	

ElseIf  Dtos(_dEmissao) >= '20200701'   
	//------------------------------------------------------------------------------------------------------
	//Rotina para calcular a comiss�o de cada produto do pedido de vendas.-B11. 
	// Usado: 5-7 - Z
	//------------------------------------------------------------------------------------------------------		
	_cTAbZZs:="B11"
	_cTipVend:='7'	
EndIf 

         
If _nOpc == 1
	_cReturn:= _cTipVend	
ElseIf _nOpc == 2
	_cReturn:= _cTAbZZs
EndIf

Return(_cReturn)

 

/*
========================================================================================================================
Rotina----: fConPagto
Autor-----: Davidson Carvalho
Data------: 14/05/2019
========================================================================================================================
Descri��o-: Fun��o para buscar a condi��o de pagamento e realizar tratamento das datas de pagamento e quantidade de 
Uso-------: Parcela.
========================================================================================================================
*/
Static Function fConPagto(_cCond,_dDtata1,_dDtata2,_dDtata3,_dDtata4,_dEmissao,_nOpc)

Local _nEncarg	:= ""
Local _cCondRel	:= ""
Local _nQTdParc	:= 0
Local _nDias	:= 0 
              
//--------------------------------------------------------------------------------
// Tratamento de condi��o de pagamento.
//--------------------------------------------------------------------------------
If  _cCond $ '001' .Or. _cCond $ '013' 
	_cCond		:= '001' 	
	_cCondRel	:= '001' 
	_nEncarg 	:= 0
	_nQTdParc	:= 1
EndIf
    
/*If  _cCond $ '011' 
	_cCond	 	:= '012'	
	_cCondRel	:= '011' 
	_nEncarg 	:= 0
	_nQTdParc	:= 1
EndIf     
//Retirado a pedido de Lorran 04/06/2020 
*/        
If 	_cCond $ '004' 
	_cCond		:= '006' 	
	_cCondRel	:= '004' 
	_nEncarg 	:= 0
	_nQTdParc	:= 1
EndIf
     
If 	_cCond $ '006' .Or. _cCond $ '008'
	_cCond	  := '006'
	_cCondRel := '006' 
	_nEncarg  := 0
	_nQTdParc := 1
EndIf

If 	_cCond $ '009' .Or. _cCond $ '035'
	_cCond		:= '012' 
	_cCondRel	:= '009' 
	_nEncarg 	:= 0
	_nQTdParc	:= 1		
EndIf 
	
If 	_cCond $ '011'  
	_cCondRel	:= '011'				
	_nEncarg 	:= 0
	_nQTdParc	:= 3
EndIf 

If 	_cCond $ '012' .And.  _cCondRel != "009" .And. _cCond != '020' 
	_cCondRel	:= '012'				
	_nEncarg 	:= 0
	_nQTdParc	:= 2
EndIf 


//-----------------------------------------------------------------------------------
// Tratamento para condi��o negociada-020.
//-----------------------------------------------------------------------------------
If 	_cCond $ '020'
	_cCondRel := '020'
	_cCond	  := '012'
	                                                                  
	If	!Empty(_dDtata4)
		_nDias+=  DateDiffDay( _dDtata3,_dDtata4)  //-> nDiffDay ( Diferenca em dias entre duas datas
		_nDias+=  DateDiffDay( _dDtata2,_dDtata3)  //-> nDiffDay ( Diferenca em dias entre duas datas
		
		If SC5->C5_PARC1 > 0
			_nQTdParc++
			If SC5->C5_PARC2 > 0
				_nQTdParc++
				If SC5->C5_PARC3 > 0
					_nQTdParc++
					If SC5->C5_PARC4 > 0
						_nQTdParc++
						If SC5->C5_PARC5 > 0
							_nQTdParc++
							If SC5->C5_PARC6 > 0
								_nQTdParc++
								If SC5->C5_PARC7 > 0
									_nQTdParc++
									If SC5->C5_PARC8 > 0
										_nQTdParc++
										If SC5->C5_PARC8 > 0
											_nQTdParc++
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	
	
		_nEncarg	:= 0
		_cCond 		:= '012' //Condi��o para a tabela ZZ9/ZZB
		
	ElseIf !Empty(_dDtata3)
		_nDias   += DateDiffDay(_dDtata2,_dDtata3)  //-> nDiffDay ( Diferenca em dias entre duas datas
		_nDias   += DateDiffDay(_dDtata1,_dDtata2)  //-> nDiffDay ( Diferenca em dias entre duas datas
		_nQTdParc:= 3
		_nEncarg :=0
	ElseIf	!Empty(_dDtata2)
		_nDias   += DateDiffDay(_dDtata1,_dDtata2)  //-> nDiffDay ( Diferenca em dias entre duas datas
		_nQTdParc:=2
		_nEncarg :=0
	Else
		_nDias   := DateDiffDay(_dEmissao,_dDtata1)
		_nQTdParc:=1
		_nEncarg :=0	
	EndIf
EndIf 

//------------------------------------------------------------------
// Retorno com as informa��es referentes a condi��o de pagamento.  
//------------------------------------------------------------------
If _nOpc == 1
	_cReturn:= _cCondRel	
ElseIf _nOpc == 2
	_cReturn:= _nQTdParc
ElseIf _nOpc == 3
	_cReturn:= _nEncarg
ElseIf _nOpc == 4
	_cReturn:= _cCond  
EndIf

Return(_cReturn)     
