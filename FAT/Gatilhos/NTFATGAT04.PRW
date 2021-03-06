#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#Include 'Parmtype.ch'

//--------------------------------------------------------------------------
/*/{Protheus.doc} NTFATGAT04
Gatilho para recalcular o valor do desconto.  
Calculo do desconto sem frete.

C6_QTDVEN  - Quantidade 
C6_C_VLRDI - Pre�o unitario/Lista
C6_PRCVEN  - Pre�o de venda padr�o
C6_VALOR   - Valor Total 
C6_DESCONT - Percentual de desconto 
C6_VALDESC - Valor de desconto

Chamado na valida��o do campo.
Campo 		  C6_DESCONT
Campo.Domino  C6_VALDESC
Conteudo	  U__NTFATGAT04()  

O gatilho tem como objetivo preencher os campos 
campos abaixo:     

Empresa - Copyright - Nutratta Nutri��o Animal.
@author Davidson Clayton
@since 20/09/2019.
@version P12 R8   
                   
@return Logico (o valor do custo direto)
*/
//--------------------------------------------------------------------------
User Function _NTFATGAT04()                                                                                     

Local _cCodPrd		:= 	GDFieldGet("C6_PRODUTO",n)
Local _cTEs			:=	GDFieldGet("C6_TES",n)
Local _nValFrete	:= 	GDFieldGet("C6_C_FRETE",n)   
Local _nPrcVen 		:= 	GDFieldGet("C6_PRCVEN",n)  
Local _nPrcUnit		:= 	GDFieldGet("C6_C_VLRDI",n)  
Local _nQtdVend		:=	GDFieldGet("C6_QTDVEN",n) 
Local _nValBrut		:=	GDFieldGet("C6_VALOR",n)
Local _nPerDesc		:=  GDFieldGet("C6_DESCONT",n)
Local _nValDesc		:=  GDFieldGet("C6_VALDESC",n)

Local _cCondPag		:= 	M->C5_CONDPAG 
Local _cDiasCond 	:= 	Posicione("SE4",1,xFilial("SE4")+_cCondPag,"E4_COND")
Local _cTipCond		:= 	Posicione("SE4",1,xFilial("SE4")+_cCondPag,"E4_TIPO")

Local _cTipo		:=	M->C5_TIPO
Local _cTabela		:=	M->C5_TABELA
Local _cVendedor	:=	M->C5_VEND1
Local _cCliente		:=	M->C5_CLIENTE
Local _cLoja		:=	M->C5_LOJACLI

Local _dEmissao		:=	M->C5_EMISSAO
Local _dDtata1		:= 	M->C5_DATA1
Local _dDtata2		:= 	M->C5_DATA2	             
Local _dDtata3		:= 	M->C5_DATA3
Local _dDtata4		:= 	M->C5_DATA4 

Local _cMens		:=	""  
Local _nPos			:=  0
Local _nPos1		:=  0
Local _nValDesc_	:=  0 
Local _nRet			:=  0 
Local _lRet			:= .T. 
Local _aHeader		:= aHeader 
Local _aCols		:= aCols
Local oTButton
Local oDlgVen

_nPerDesc 			:=0
_nValDesc_			:=0

If _cCondPag == "001"	//Desconto somente para condi��o a vista
	
	Define MSDialog oDlgVen From 000,000 To 60,360 Title OemToAnsi("Informe o Percentual de Desconto Comercial ") Pixel
	
	@010,002 Say " Percentual de  Desconto:" Size 120,08 Pixel Of oDlgVen
	@010,080 MSGet _nPerDesc Size 040,08 Pixel Of oDlgVen When .T.
	
	oTButton := TButton():New(010,140,"OK",oDlgVen,{|| oDlgVen:End()},30,10,,,.F.,.T.,.F.,,.F.,,,.F.)
	
	Activate MSDialog oDlgVen Centered
	
	//------------------------------------------------------------------------------------
	//Realiza o calculo do desconto com base na regra Quantidade * pre�o lista (sem frete)
	//------------------------------------------------------------------------------------
	_nValDesc_ := Round(((_nQtdVend * _nPrcUnit)*_nPerDesc)/100,2)
	
	_nPos := aScan( _aHeader , {|x| Alltrim(x[2]) == 'C6_DESCONT'})
	If _nPos > 0
		
		_nPerDesc:=	Round((_nValDesc_/_nValBrut)*100,2)
		_aCols[n][_nPos] := _nPerDesc
		RunTrigger(2,n,nil,,"C6_DESCONT")
	EndIf
	
	_nPos1 := aScan( _aHeader , {|x| Alltrim(x[2]) == 'C6_VALDESC'})
	If _nPos1 > 0
		
		//		_aCols[n][_nPos1] := _nValDesc_
		GDFieldPut ("C6_VALDESC",_nValDesc_,Len(aCols))
		RunTrigger(2,n,nil,,"C6_VALDESC")
	EndIf
EndIf

Return(.T.)




		
	
		

		
   



