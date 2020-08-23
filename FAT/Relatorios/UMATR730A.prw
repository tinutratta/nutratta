#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "MATR730A.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MATR730A.
Relatorio de pedidos onde ser� impresso os locais de estoque informados.

Author   Davidson-Nutratta
Since 	   19/09/2019.
Version 	12.1.17
param   	n/t
return  	n/t
Especifico Nutratta Nutri��o Animal.
19/09/2019-Valida��o de impress�o:Relatorio s� ser� gerado para pedidos onde a TES 
atualize saldos em estoque
/*/
//-----------------------------------------------------------------------------------------------------------

User Function U1MATR730A()

Private _cAlias		:= GetNextAlias()
Private _cAlias1	:= GetNextAlias()
Private cEOL 		:= "CHR(13)+CHR(10)"
Private cPerg       := "MATR730A" // Nome do grupo de perguntas

#IFNDEF TOP
		MsgAlert(STR0059,STR0004)	 //"Relat�rio somente para Bancos Relacionais (TOP)."###"Aten��o"
		Return
#ENDIF

ValidPerg()
If !Pergunte(cPerg,.T.)
	
	Return
Endif

If Empty(cEOL)
	cEOL := CHR(13)+CHR(10)
Else
	cEOL := Trim(cEOL)
	cEOL := &cEOL
Endif

//Monta arquivo de trabalho tempor�rio
MsAguarde({||MontaQuery()},STR0001,STR0002) //'Aguarde'###'Criando arquivos para impress�o...'

//Verifica resultado da query

DbSelectArea(_cAlias)
DbGoTop()
If (_cAlias)->(Eof())
	MsgAlert(STR0003,STR0004) //"Relat�rio vazio! Verifique os par�metros."###"Aten��o"
Else
 	Processa({|| Imprime() },STR0005,STR0006) //"Pedidos"###"Imprimindo..."
EndIf
(_cAlias)->(DbCloseArea())

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATR730A  �Autor  �Microsiga           � Data �  08/21/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �  MONTA A PAGINA DE IMPRESSAO                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Imprime()

Local nBaseIcm		:= 0
Local nValIcm		:= 0	
Local nBaseIPI		:= 0
Local nValIPI		:= 0	
Local nBaseRet		:= 0
Local nValRet		:= 0	
Local nVlrTot		:= 0	
Local nBaseISS		:= 0
Local vValISS		:= 0
Local nTotValdesc	:= 0
Local nC5Desc1		:= 0
Local nC5Desc2		:= 0 
Local nC5Desc3		:= 0 
Local nC5Desc4		:= 0 
Local nC5Frete		:= 0
Local nC5Seguro		:= 0
Local nC5Despesa	:= 0 
Local _aParc		:= {}
Local _lContinua	:= .T.
Private cStartPath	:= GetSrvProfString("Startpath","")
Private cPosi
Private nLin
Private _nTot    	:= 0   // Valor Total
Private _nValIpi	:= 0   // Valor IPI 
private nVlIPI		:= 0
Private _nValPro	:= 0   // Valor IPI
Private _nPag		:= 1
Private _cTes		:=""

//Fontes a serem utilizadas no relat�rio
oFont06N := TFont():New( "Arial",,06,,.T.,,,,,.f.)
oFont07N := TFont():New( "Arial",,07,,.T.,,,,,.f.)
oFont10  := TFont():New( "Arial",,08,,.F.,,,,,.f.)
oFont10N := TFont():New( "Arial",,08,,.T.,,,,,.f.)
oFont10I := TFont():New( "Arial",,08,,.f.,,,,,.f.,.T.)
oFont09  := TFont():New( "Arial",,09,,.F.,,,,,.f.)
oFont09N := TFont():New( "Arial",,09,,.T.,,,,,.f.)
oFontC9  := TFont():New( "Courier New",,09,,.F.,,,,,.f.)
oFontC9N := TFont():New( "Courier New",,09,,.T.,,,,,.f.)
oFont10  := TFont():New( "Arial",,10,,.f.,,,,,.f.)
oFont10N := TFont():New( "Arial",,10,,.T.,,,,,.f.)
oFont10I := TFont():New( "Arial",,10,,.f.,,,,,.f.,.T.)
oFont11  := TFont():New( "Arial",,11,,.f.,,,,,.f.)
oFont11N := TFont():New( "Arial",,11,,.T.,,,,,.f.)
oFont12N := TFont():New( "Arial",,12,,.T.,,,,,.f.)
oFont12  := TFont():New( "Arial",,12,,.F.,,,,,.F.)
oFont12NS:= TFont():New( "Arial",,12,,.T.,,,,,.T.)
oFont13N := TFont():New( "Arial",,13,,.T.,,,,,.f.)
oFont15  := TFont():New( "Arial",,15,,.F.,,,,,.F.)
oFont15N := TFont():New( "Arial",,15,,.T.,,,,,.F.)
oFont17N := TFont():New( "Arial",,17,,.T.,,,,,.F.)

//Start de impress�o
oPrn:= TMSPrinter():New()
oPrn:SetPortrait()	 				// SetPortrait() - Formato retrato   SetLandscape() - Formato Paisagem 

If oPrn:Setup() == .F.    			// Configura��o da impressora 
	oPrn:End()
	Return
EndIf	

While (_cAlias)->(!Eof()) 
	
	//Caso a TES n�o atualize estoque o relatorio n�o ser� gerado.
	_lContinua:= fValdTES((_cAlias)->C6_TES)
	
	If !_lContinua 
	                           
		MsgAlert("A TES informada no Pedido, n�o atualiza estoque. ","TES INV�LIDA!!!  "+"Pedido/TES:"+(_cAlias)->C5_NUM+"/"+(_cAlias)->C6_TES) 
		Exit
	EndIf
	
	nBaseIcm	:= 0
	nValIcm		:= 0	
	nBaseIPI	:= 0
	nValIPI		:= 0	
	nBaseRet	:= 0
	nValRet		:= 0	
	nVlrTot		:= 0	
	nBaseISS	:= 0
	vValISS		:= 0
	nTotValdesc	:= 0
	nC5Desc1	:= 0
	nC5Desc2	:= 0 
	nC5Desc3	:= 0 
	nC5Desc4	:= 0 
	nC5Frete	:= 0
	nC5Seguro	:= 0
	nC5Despesa	:= 0 
	
	_aParc := Impostos((_cAlias)->C5_NUM,@nBaseIcm,@nValIcm,@nBaseIPI,;
						@nValIPI,@nBaseRet,@nValRet,@nVlrTot,;
						@nBaseISS,@vValISS,@nTotValdesc,@nC5Desc1,;
						@nC5Desc2,@nC5Desc3,@nC5Desc4,@nC5Frete,;
						@nC5Seguro,@nC5Despesa)
	Cabec(.T.,_aParc)
	ImpItens((_cAlias)->C5_NUM,_aParc) 
	Rodap(nBaseIcm,nValIcm,nBaseIPI,nValIPI,nBaseRet,nValRet,nVlrTot,nBaseISS,vValISS,nTotValdesc,nC5Desc1,nC5Desc2,nC5Desc3,nC5Desc4,nC5Frete,nC5Seguro,nC5Despesa)
   	
   	oPrn :EndPage()	
   	_nPag+=1
   	
EndDo

oPrn:Preview() //Preview DO RELATORIO
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATR730A  �Autor  �Microsiga           � Data �  08/21/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Cabec(lImpParc,_aParc)

Local nI := 0
Local cNomeVend1 	:= ""
Local cTelVend1		:= "" 
Local cEndEnt		:= ""
Local cTpEmb		:= ""
Local cBitmap		:= "logo.bmp" 
Local cFileLogo		:= GetSrvProfString('Startpath','') + cBitmap

oPrn:StartPage()	//Inicia uma nova pagina

//             L-In,C-In,Logotipo  ,C-Fi,L-Fi
oPrn:SayBitmap(0035,1450,cFileLogo,0400,0125)

oPrn:say   (0045,35, STR0007 +(_cAlias)->C5_NUM ,oFont15) //"PEDIDO DE VENDA: "

//********************************************************************************************
//										cabecalho
//********************************************************************************************
// Primeira coluna do cabecalho

nLin :=35
oPrn:say (nLin,1860, SM0->M0_NOMECOM ,oFont06N)
nLin += 23
oPrn:say (nLin,1860,STR0014 +Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")+"  -  "+STR0060+Alltrim(SM0->M0_INSC) ,oFont06N)  //CNPJ //I.E:
nLin += 23
oPrn:say (nLin,1860,Alltrim(SM0->M0_BAIRCOB)+" "+ Alltrim(SM0->M0_ENDCOB),oFont06N)
nLin += 23
oPrn:say (nLin,1860,Alltrim(SM0->M0_CIDCOB)+" /"+Alltrim(SM0->M0_ESTCOB)+" "+STR0027+(SM0->M0_CEPENT),oFont06N)  //CEP:
nLin += 23
oPrn:say (nLin,1860,STR0062+Alltrim(SM0->M0_TEL)+"  -  "+STR0063+Alltrim(SM0->M0_FAX) ,oFont07N)  //TEL: FAX:
nLin += 40
oPrn:line(nLin,0005,nLin,2500)    //Linha Horizontal Cabecalho Inferior
//............................................................................................
// cabecalho (CLIENTE)
nLin 	:= 180

nCol0 	:= 25
nCol1 	:= 35
nCol2 	:= 250
nCol3 	:= 1000
nCol4 	:= 1180
nCol5 	:= 1480
nCol6 	:= 1630
nCol7 	:= 1870
nCol8 	:= 2080
nColParc:= 0270
/*
nCol9 	:= 21500
nCol10 	:= 2300
*/

//Imforma��es cadastrais
oPrn:say (nLin,35, "INFORMA��ES CADASTRAIS" ,oFont12N)
nLin += 100

oPrn:say (nLin,nCol1,STR0008,oFont10 ) //"Cliente: "
oPrn:say (nLin,160,(_cAlias)->A1_COD + " " + (_cAlias)->A1_LOJA + " - " + (_cAlias)->A1_NOME, oFont10N)
oPrn:say (nLin,nCol7,STR0009, oFont10 ) //"Emiss�o: "
oPrn:say (nLin,nCol8,dtoc((_cAlias)->C5_EMISSAO),oFont10N)

nLin += 50
oPrn:say (nLin,nCol1,STR0010, oFont10 ) //"End: "
oPrn:say (nlin,160,Substr((_cAlias)->A1_END,1,30), oFont10N)
oPrn:say (nLin,nCol5-200,STR0011, oFont10 ) //"Bairro: "
oPrn:say (nLin,nCol6-200,Alltrim((_cAlias)->A1_BAIRRO),oFont10N)
oPrn:say (nLin,nCol7,STR0012, oFont10 ) //"Municipio/UF: "
oPrn:say (nLin,nCol8,Alltrim((_cAlias)->A1_MUN)+" / "+(_cAlias)->A1_EST,oFont10N)


nLin += 50
oPrn:say (nLin,nCol1,STR0013, oFont10 ) //"Nome Fantasia: "
oPrn:say (nlin,nCol2+40,Alltrim((_cAlias)->A1_NREDUZ), oFont10N)

nLin += 50
oPrn:say (nLin,nCol1,STR0017, oFont10 ) //"Contato: "
oPrn:say (nLin,nCol2,(_cAlias)->A1_CONTATO,oFont10N)
oPrn:say (nLin,nCol3,STR0018, oFont10 ) //"Fone: "
oPrn:say (nLin,nCol4-10,"("+Alltrim((_cAlias)->A1_DDD)+") "+(_cAlias)->A1_TEL,oFont10N)
oPrn:say (nLin,nCol5,STR0019, oFont10 ) //"Fone 2: "
oPrn:say (nLin,nCol6,"("+Alltrim((_cAlias)->A1_DDD)+") "+(_cAlias)->A1_TELEX,oFont10N)
oPrn:say (nLin,nCol7-30,STR0020, oFont10 ) //"FAX: "
oPrn:say (nLin,nCol7+50,"("+Alltrim((_cAlias)->A1_DDD)+") "+(_cAlias)->A1_FAX,oFont10N)

//osmar setar vendedor
SA3->(DbSetOrder(1))
If SA3->(DbSeek(xFilial("SA3")+(_cAlias)->C5_VEND1))  
	cNomeVend1	:= SA3->A3_NOME
	cTelVend1	:= "("+SA3->A3_DDDTEL+") "+SA3->A3_TEL
EndIf
nLin += 50
oPrn:say (nLin,nCol1,"Vend/Rep:", oFont10 ) //"Vendedor: "
oPrn:say (nLin,nCol2,cNomeVend1,oFont10N)
oPrn:say (nLin,nCol3,"Tel:", oFont10 ) //"Tel Distr.: "
oPrn:say (nLin,nCol4,cTelVend1,oFont10N)
oPrn:say (nLin,nCol5,STR0060,oFont10 ) //"I.E: "
oPrn:say (nLin,nCol6,Alltrim((_cAlias)->A1_INSCR),oFont10N)

nLin += 50
oPrn:say (nLin,nCol5,STR0025, oFont10 ) //"Cond. Pgto: "
oPrn:say (nLin,nCol6+30,(_cAlias)->C5_CONDPAG + " - " + (_cAlias)->E4_DESCRI, oFont10N)

nLin += 100

oPrn:say (nLin,nCol1,"Placa:", oFont10N) 							//"Placa: "
nLin += 80
oPrn:say (nLin,nCol1,"Motorista:", oFont10N) 						//"Motorista: "
nLin += 80
oPrn:say (nLin,nCol1,"Transportadora:", oFont10N) 					//"Transportadora: "
nLin += 80
oPrn:say (nLin,nCol1,"Inf.Embalagem:", oFont10N) 					//"Embalagem: "
	
//Tipo de embalagem 
If Alltrim((_cAlias)->C5_ZBIGBAG) == 'A'
	cTpEmb:='GRANEL SEM BAG'
ElseIf Alltrim((_cAlias)->C5_ZBIGBAG) == 'B'
	cTpEmb:='GRANEL COM BAG'
EndIf

oPrn:say (nLin,320,cTpEmb ,oFont10)

DbSelectArea("SA1")
SA1->(DbSetOrder(1))
If !Empty((_cAlias)->C5_CLIENT)
	If SA1->(DbSeek(xFilial("SA1")+(_cAlias)->C5_CLIENT+(_cAlias)->C5_LOJAENT)) 
		cEndEnt :=	SA1->A1_ENDENT 	
	EndIf
Else
	If SA1->(DbSeek(xFilial("SA1")+(_cAlias)->C5_CLIENTE+(_cAlias)->C5_LOJACLI)) 
		cEndEnt :=	SA1->A1_ENDENT 	
	EndIf	
EndIf  


If !Empty((_cAlias)->C5_C_INFAD)

	nLin += 160
//	nLin2 	:= nLin+60
//	nLin 	:= nLin2
EndIf


//Informa��es adicionais.
nLin += 050
oPrn:say (nLin,nCol1,"Inf.Adicionais:", oFont10N) //"Msg Informa��o adicional: "

nTam1 := Len((_cAlias)->C5_C_INFAD)
xLin1 := MLCount((_cAlias)->C5_C_INFAD,100)

For j := 1 To xLin1
	//Tratamento para a primeira linha
	If j == 1
		oPrn:Say(nLin,300,memoline(Upper((_cAlias)->C5_C_INFAD),080,j),oFont10)
		nLin += 050
	ElseIf j >= 2
		 //Tratamento para a segunda linha
		oPrn:Say(nLin,035,memoline(Upper((_cAlias)->C5_C_INFAD),100,j),oFont10)
		nLin += 050
	EndIf
	
Next j
/*
If !Empty((_cAlias)->C5_C_INFAD)
	nLin += 100
Else           
	nLin += 050
EndIf
*/
//********************************************************************************************
//										Corpo
//********************************************************************************************

//Linha Inicial, Coluna Inicial, Linha Final, Coluna Final                                                        '
oPrn:line(nLin-10,0005,nLin-10,2500)    //Linha Horizontal Cabecalho Inferior
oPrn:line(nLin+40,0005,nLin+40,2500)    //Linha Horizontal Cabecalho Inferior

// Subtitulo do Corpo
oPrn:say (nLin,0300,STR0067,oFont10N)		//"C�digo"
oPrn:say (nLin,0800,STR0068,oFont10N)  		//"Descri��o"
oPrn:say (nLin,1600,STR0069,oFont10N)		//"Unid."
oPrn:say (nLin,1500,STR0066,oFont10N) 		//"Qtde"
oPrn:say (5,2370,Transform(_nPag,"@R 999"),oFont10N)    //Impress�o do numero da p�gina

nLin += 050

return nLin


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATR730A  �Autor  �Microsiga           � Data �  08/21/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Itens                                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ImpItens(cNumped,_aParc) 

Local   _nCont 		:= 1
Local	cPicITEM	:= PesqPict("SC6","C6_ITEM")
Local	cPicQTD		:= PesqPict("SC6","C6_QTDVEN")
Local	cPicPrcVen	:= PesqPict("SC6","C6_PRCVEN")
Local	cPicVALDESC	:= PesqPict("SC6","C6_VALDESC")
Local	cPicVALOR	:= PesqPict("SC6","C6_VALOR")
Local	nTamDescPr	:= 0
Local 	cDescProd	:= ""
Local	nQtdDigito	:= 30
_nValPro := 0

//PREPARE ENVIRONMENT EMPRESA "02" FILIAL "01"

Set Century On

***************************************
** VARIAVEIS UTILIZADAS NO RELATORIO **
***************************************
Private lAdjustToLegacy := .T.
Private lDisableSetup   := .T.
Private cDirSpool	  	:= GetMv("MV_RELT")
//Private cPerg			:= "RFATREL"

*******************************************
** OBJETOS PARA TAMANHO E TIPO DE FONTES **
*******************************************
Private oFont02	 := TFont():New("Arial",02,02,,.F.,,,,.T.,.F.)
Private oFont06	 := TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
Private oFont06n := TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)
Private oFont10C := TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
Private oFont10CN := TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.)
Private oFont07	 := TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)
Private oFont07n := TFont():New("Courier New",07,07,,.T.,,,,.T.,.F.)
Private oFont07A  := TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
Private oFont10	 := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
Private oFont10n := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
Private oFont09	 := TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
Private oFont09n := TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)
Private oFont10	 := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Private oFont10n := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Private oFont11	 := TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)
Private oFont11n := TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)
Private oFont12	 := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Private oFont12n := TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
Private oFont13	 := TFont():New("Arial",13,13,,.F.,,,,.T.,.F.)
Private oFont13n := TFont():New("Arial",13,13,,.T.,,,,.T.,.F.)
Private oFont14	 := TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
Private oFont14n := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
Private oFont16n := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
Private oFont18n := TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)
Private oFont22n := TFont():New("Arial",22,22,,.T.,,,,.T.,.F.)
Private oFont34n := TFont():New("Arial",34,34,,.T.,,,,.T.,.F.)

Private oBrush1 := TBrush():New( , CLR_GRAY)

*********************************************
** VARI�VEIS INICIALIZADAS COMO CONTADORES **
*********************************************
//Private nLin	 := 100
Private nMaxLin  := 3300
Private nPagina  := 0
Private nTLinhas := 2350
Private nCol	 := 50
Private nMasc	 :=''
Private nRoudn	 :=0
Private nQuant	 :=0

****************************************
** VARI�VEIS DO CONTE�DO DO RELAT�RIO **
****************************************
Private cTitulo := "LOCAL DE ENTREGA"
Private oRel

//-----------------------------------------------------------------------------------
// Fim das declara��es de variaveis.
//-----------------------------------------------------------------------------------
While (_cAlias)->(!Eof()) .And. (_cAlias)->C5_NUM == cNumped 
		
		If _nCont > 49
			_nCont := 1
			_nPag  += 1
			oPrn:line(nLin,0005,nLin,2500)    //Linha Horizontal Rodape Inferior
			oPrn :EndPage()
			Cabec(.F.,_aParc)
		EndIf
		
//		oPrn:say (nLin,0095,Transform((_cAlias)->C6_ITEM,cPicITEM), oFont10,,,,2)				//item
		oPrn:say (nLin,0300,Substr((_cAlias)->C6_PRODUTO,1,25),oFont10)							//codigo 
		
		cUnidade:=	Alltrim((_cAlias)->C6_UM)
		
		If	cUnidade == "TL"
			nRoudn	:=0 
			nMasc	:='@E 99,9'
			nQuant	:= Alltrim(Str((_cAlias)->C6_QTDVEN))				
		ElseIf cUnidade == "UN"
			nRoudn	:=2 
		  	nMasc	:='@E 9999'
			nQuant:= Transform(Round((_cAlias)->C6_QTDVEN,nRoudn),nMasc)
		EndIf
				
		oPrn:say (nLin,1510,nQuant,oFont10)			//Quantidade
		//DESCRICAO ABAIXO PARA CONROLE DE LINHA
		
		oPrn:say (nLin,1610,cUnidade,oFont10)											//UM
//		oPrn:say (nLin,1700,Transform((_cAlias)->C6_PRCVEN,cPicPrcVen),oFont10,,,,2)			//VLR UNIT
//		oPrn:say (nLin,2000,Transform((_cAlias)->C6_VALDESC,cPicVALDESC),oFont10,,,,2)		//VLR DESC
//		oPrn:say (nLin,2200,Transform((_cAlias)->C6_VALOR,cPicVALOR),oFont10,,,,2)			//VLR TOT
		 
		nTamDescPr 	:= 1                                                                       	
		cDescProd	:= RTRIM((_cAlias)->B1_DESC)
		While Len(cDescProd) > nTamDescPr
			oPrn:say (nLin,0800,Substr(cDescProd,nTamDescPr,nQtdDigito),oFont10)	//Descricao 
			nTamDescPr+=nQtdDigito
			If nTamDescPr <= Len(cDescProd) 
				nLin 	+= 50
				_nCont 	+= 1 
			EndIf
		EndDo
		_nCont 	+= 1
		_nValPro	+= (_cAlias)->C6_VALOR
			
		nLin 	+= 50   //pula linha
		
		(_cAlias)->(dBskip())
EndDo 

nLin 	+= 050 

//-----------------------------------------------------------------------------------
// Impress�o Grafica: Locais de entrega Nutratta
//-----------------------------------------------------------------------------------
************************************
** MONTA A R�GUA DE PROCESSAMENTO **
************************************
		
	Processa({|| fImpRel(cNumped),'Gerando...'},'Imprimindo local de entrega...')
	
Return

//-----------------------------------------------------------------------------------
// Inicio da impress�o 
//-----------------------------------------------------------------------------------
Static Function fImpRel(cNumped)  

**************************************
** FUN��O DE IMPRESS�O DO RELAT�RIO **
**************************************
Local aAreaOrc 	:= GetArea()
Local cNota 	:= ''
Local cRoteiro 	:= ''
Local cDetChap	:=''
Local cDiaRec	:=''

ProcRegua(8)
IncProc("Preparando a impress�o...")
cDirSpool := ""
//dbSelectArea("SCJ")

//oPrn := FWMSPrinter():New("MC_0101",IMP_PDF,lAdjustToLegacy,cDirSpool,lDisableSetup) //TMSPrinter():New( "Boleto Laser" )//
//oPrn:SetPortrait()
//oPrn:SetPaperSize(9)
//oRel:cPathPDF := cDirSpool


//------------------------------------------------------------------------------------------
//Posiciona na tabela SC5 para pegar as informa��es do local de entrega vinculado ao pedido 
//-----------------------------------------------------------------------------------------
dbSelectArea("SC5")
dbSetOrder(1)
If dbSeek(xFilial("SC5")+cNumped)

	cLocEntr	:=Alltrim(SC5->C5_XLOCENT)
	cNomeFaz	:=Alltrim(SC5->C5_XNOMFAZ)
	cEnderec	:=Alltrim(SC5->C5_XENDERE)
	cBairro 	:=Alltrim(SC5->C5_XBAIRRO)
	cCidade		:=Alltrim(SC5->C5_XMUNENT)
	cUf			:=Alltrim(SC5->C5_XUF)    
	cFone		:=Alltrim(SC5->C5_XTELEFO)
	cDDD		:=Alltrim(SC5->C5_XDDD)
	cContato	:=Alltrim(SC5->C5_XCTTLOC)
	cGPS		:=Alltrim(SC5->C5_XCODGPS)
	cTpVei		:=Alltrim(SC5->C5_XTPVEIC)

			
	//Chapas levar ou n�o
  
   	If Alltrim(SC5->C5_XLOCCHA) == '1' .Or. Alltrim(SC5->C5_XLOCCHA) $ 'Motorista leva/procura'  
		cDetChap:='Motorista leva/procura'
	ElseIf Alltrim(SC5->C5_XLOCCHA) == '2' .Or. Alltrim(SC5->C5_XLOCCHA) $ 'No local de entrega' 
		cDetChap:='No local de entrega'
	ElseIf Alltrim(SC5->C5_XLOCCHA) == '3'	.Or.  Alltrim(SC5->C5_XLOCCHA) $ 'Tenho indicacao'  
		cDetChap:='Tenho indicacao'
	EndIf

	//Dias de recebimento
	If Alltrim(SC5->C5_XRECEBI) == '1' .Or. Alltrim(SC5->C5_XRECEBI) $ 'SEG A SEX'
		cDiaRec:='SEG A SEX'
	ElseIf Alltrim(SC5->C5_XRECEBI) == '2' .Or. Alltrim(SC5->C5_XRECEBI) $ 'SEG A SAB'   
		cDiaRec:='SEG A SAB'
	ElseIf Alltrim(SC5->C5_XRECEBI) == '3'	.Or. Alltrim(SC5->C5_XRECEBI) $'SEG A DOM'  
		cDiaRec:='SEG A DOM'
	EndIf
	
	cChapa		:=Alltrim(SC5->C5_XNOMCHA)
	cCidCHp		:=Alltrim(SC5->C5_XMUNCHA) 
	cUfChp		:=Alltrim(SC5->C5_XUFCHAP)
	cDDChp		:=Alltrim(SC5->C5_XDDDCHA)
	cTelchp		:=Alltrim(SC5->C5_XTELCHA)
	cHRec		:=Alltrim(SC5->C5_XHRECED)
	cHrAte		:=Alltrim(SC5->C5_XHRECEA)
	cDtEntr		:=Dtoc(SC5->C5_FECENT)
	cRoteiro	:=Alltrim(SC5->C5_XROTEIR) 
EndIf


//-----------------------------------------------------------------------------------
// Impress�o grafica do realtorio de local de entrega 
//-----------------------------------------------------------------------------------
//nLin := 1000	
//nLin += 100                      
//oPrn:FillRect ( {nLin,nCol,nLin+200,nTLinhas}, oBrush1, "-2" ) 
oPrn:Say(nLin+60,35,"LOCAL DE ENTREGA" ,oFont15N,,CLR_BLACK)

nLin += 050

oPrn:Say(nLin+130,35,"Nome do Local:" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,35,cNomeFaz,oFont10N)

oPrn:Say(nLin+130,nCol+800,"Endere�o:" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,nCol+800,cEnderec,oFont10N) 
 
nLin += 100
 
oPrn:Say(nLin+130,35,"Bairro:" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,35,cBairro,oFont10N) 

oPrn:Say(nLin+130,nCol+800,"Cidade:" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,nCol+800,cCidade,oFont10N) 

oPrn:Say(nLin+130,nCol+1300,"UF:" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,nCol+1300,cUf ,oFont10N) 

oPrn:Say(nLin+130,nCol+1400,"DDD:" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,nCol+1400,cDDD,oFont10N)

oPrn:Say(nLin+130,nCol+1500,"Fone:" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,nCol+1500,cFone,oFont10N)

oPrn:Say(nLin+130,nCol+1700,"Contato:" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,nCol+1700,cContato,oFont10N) 

nLin += 100
oPrn:Say(nLin+130,35,"Coord.GPS:" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,35,cGPS,oFont10N) 

nLin += 200

oPrn:Say(nLin+60,35,"INFORMA��O CHAPA:" ,oFont10N,,CLR_BLACK)

nLin += 050

oPrn:Say(nLin+130,35,"Detalhes do Chapa" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,35,cDetChap,oFont10N) 

oPrn:Say(nLin+130,nCol+500,"Chapa:" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,nCol+500,cChapa,oFont10N) 

oPrn:Say(nLin+130,nCol+1500,"Cidade:" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,nCol+1500,cCidCHp ,oFont10N) 

oPrn:Say(nLin+130,nCol+1800,"UF:" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,nCol+1800,cUfChp,oFont10N)

oPrn:Say(nLin+130,nCol+1900,"DDD:" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,nCol+1900,cDDChp,oFont10N)

oPrn:Say(nLin+130,nCol+2000,"Telefone:" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,nCol+2000,cTelchp,oFont10N)

nLin += 100
oPrn:Say(nLin+130,35,"Dia Receb.:" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,35,cDiaRec,oFont10N) 

oPrn:Say(nLin+130,nCol+500,"Hr.Receb.:" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,nCol+500,cHRec,oFont10N) 

oPrn:Say(nLin+130,nCol+1500,"Hr.Ate:" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,nCol+1500,cHrAte,oFont10N) 

oPrn:Say(nLin+130,nCol+1800,"Dt.Entrega:" ,oFont10N,,CLR_GRAY)
oPrn:Say(nLin+170,nCol+1800,cDtEntr,oFont10N)

nLin += 150

oPrn:Say(nLin+130,35,"ROTEIRO DE ENTREGA :" ,oFont10N,,CLR_BLACK)

//nLin += 050

nTam := Len(cRoteiro)
xLin := MLCount(cRoteiro,80)

For i := 1 To xLin 
	
	oPrn:Say(nLin+130,nCol+500,memoline(Upper(cRoteiro),80,i),oFont10)
	nLin += 050
	
	//Tratamento para a primeira linha.
/*	If i == 1
		oPrn:Say(nLin+130,nCol+500,memoline(Upper(cRoteiro),80,i),oFont10)
		nLin += 050
		
	ElseIf i >= 2 
		//Segunda linha justificada
		oPrn:Say(nLin+130,35,memoline(Upper(cRoteiro),100,2),oFont10)
		nLin += 050
	EndIf */
Next i 

/*
oPrn:Say(nLin+130,35,"Roteiro de entrega.:" ,oFont10N,,CLR_GRAY)
oPrn:Say(MLCount(cRoteiro, 150,4,.T.)
oPrn:Say(nLin+170,35,Substr(cRoteiro,1,150),oFont10N) 
oPrn:Say(nLin+200,35,Substr(cRoteiro,151,300),oFont10N) 
oPrn:Say(nLin+230,35,Substr(cRoteiro,301,450),oFont10N)
oPrn:Say(nLin+260,35,Substr(cRoteiro,451,600),oFont10N)
*/
RestArea(aAreaOrc)

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATR730A  �Autor  �Microsiga           � Data �  08/21/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          � Rodape                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Rodap(nBaseIcm,nValIcm,nBaseIPI,nValIPI,;
						nBaseRet,nValRet,nVlrTot,nBaseISS,vValISS,;
						nTotValdesc,nC5Desc1,nC5Desc2,nC5Desc3,nC5Desc4,nC5Frete,nC5Seguro,nC5Despesa)
nLin := 2850

nLin := 3125
oPrn:say (nLin,050, "___________________________________",oFont10N)
oPrn:say (nLin,1500, "___________________________________",oFont10N)

nLin := 3160
oPrn:say (nLin,250,"CONFERENTE",oFont10N)
oPrn:say (nLin,1700,"MOTORISTA",oFont10N)

oPrn :EndPage()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATR730A  �Autor  �Microsiga           � Data �  08/21/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MontaQuery

Local cQuery

// Abertura das tabela, para garantir a criacao caso alguma n�o exista ainda
dbSelectArea("SC5")
dbSelectArea("SC6")
dbSelectArea("SE4")
dbSelectArea("SB1")
dbSelectArea("SA1")
dbSelectArea("SA3")

cQuery := "SELECT DISTINCT "
cQuery += " C5.C5_NUM, "
cQuery += " C5.C5_CLIENTE,"
cQuery += " C5.C5_LOJACLI,"
cQuery += " C5.C5_CLIENT,"
cQuery += " C5.C5_LOJAENT,"
cQuery += " C5.C5_CONDPAG,"
cQuery += " C5.C5_EMISSAO,"
cQuery += " E4.E4_DESCRI,"
cQuery += " C5.C5_FECENT,"
cQuery += " C5.C5_SERIE,"
cQuery += " C6.C6_ITEM,"
cQuery += " C5.C5_NOTA,"
cQuery += " C5.C5_C_INFAD,"
cQuery += " C5.C5_PARC1,"
cQuery += " C5.C5_PARC2,"
cQuery += " C5.C5_PARC3,"
cQuery += " C5.C5_PARC4,"
cQuery += " C5.C5_DATA1,"
cQuery += " C5.C5_DATA2,"
cQuery += " C5.C5_DATA3,"
cQuery += " C5.C5_DATA4,"
cQuery += " C5.C5_ZBIGBAG,"
cQuery += " C6.C6_PRODUTO,"
cQuery += " C6.C6_TES,"
cQuery += " C6.C6_UM,"
cQuery += " C6.C6_VALDESC,"
cQuery += " C5.C5_VEICULO, " 
cQuery += " C5.C5_VEND1, "
cQuery += " B1.B1_COD,"
cQuery += " B1.B1_DESC,"
cQuery += " B1.B1_IPI,"
cQuery += " B1.B1_GRUPO,"
cQuery += " C6.C6_QTDVEN,"
cQuery += " C6.C6_PRCVEN,"
cQuery += " C6.C6_VALOR,"
cQuery += " A1.A1_COD,"
cQuery += " A1.A1_LOJA,"
cQuery += " A1.A1_NOME,"
cQuery += " A1.A1_END,"
cQuery += " A1.A1_CGC,"
cQuery += " A1.A1_INSCR,"
cQuery += " A1.A1_CEP,"
cQuery += " A1.A1_BAIRRO,"
cQuery += " A1.A1_MUN,"
cQuery += " A1.A1_EST,"
cQuery += " A1.A1_DDD,"
cQuery += " A1.A1_TEL,"
cQuery += " A1.A1_FAX,"
cQuery += " A1.A1_TELEX,"
cQuery += " A1.A1_CONTATO,"
cQuery += " A1.A1_EMAIL,"
cQuery += " A1.A1_HPAGE,"
cQuery += " A1.A1_NREDUZ,"
cQuery += " A1.A1_CLASVEN"
cQuery += " FROM"
cQuery += " " + RetSqlName('SC5') + " C5,"
cQuery += " " + RetSqlName('SC6') + " C6,"
cQuery += " " + RetSqlName('SE4') + " E4,"
cQuery += " " + RetSqlName('SB1') + " B1,"
cQuery += " " + RetSqlName('SA1') + " A1 "
cQuery += " LEFT OUTER JOIN "+ RetSqlName('SA3') + " A3 "
cQuery += " ON A3.A3_FILIAL = '" + xFilial("SA3") + "' "
cQuery += " AND A3.A3_COD BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'"
cQuery += " AND A3.D_E_L_E_T_ = ''"
cQuery += " WHERE"
cQuery += " C5.C5_FILIAL = '" + xFilial("SC5") + "'"
cQuery += " AND C6.C6_FILIAL = '" + xFilial("SC6") + "'"
cQuery += " AND E4.E4_FILIAL = '" + xFilial("SE4") + "'"
cQuery += " AND B1.B1_FILIAL = '" + xFilial("SB1") + "'"
cQuery += " AND A1.A1_FILIAL = '" + xFilial("SA1") + "'"
cQuery += " AND C5.C5_NUM BETWEEN '"+(MV_PAR05)+"' AND '"+(MV_PAR06)+"'"
cQuery += " AND C5.C5_CLIENTE BETWEEN '"+(MV_PAR01)+"' AND '"+(MV_PAR03)+"'"
cQuery += " AND C5.C5_LOJACLI BETWEEN '"+(MV_PAR02)+"' AND '"+(MV_PAR04)+"'"
cQuery += " AND C5.C5_EMISSAO BETWEEN '"+Dtos(MV_PAR07)+"' AND '"+Dtos(MV_PAR08)+"'"
cQuery += " AND C5.C5_NUM = C6.C6_NUM"
cQuery += " AND C6.C6_PRODUTO = B1.B1_COD"
cQuery += " AND C5.C5_CONDPAG = E4.E4_CODIGO"
cQuery += " AND C5.C5_CLIENTE = A1.A1_COD"
cQuery += " AND C5.C5_LOJACLI = A1.A1_LOJA"
cQuery += " AND C5.D_E_L_E_T_ = ''"
cQuery += " AND C6.D_E_L_E_T_ = ''"
cQuery += " AND E4.D_E_L_E_T_ = ''"
cQuery += " AND B1.D_E_L_E_T_ = ''"
cQuery += " AND A1.D_E_L_E_T_ = ''"
cQuery += " ORDER BY C5.C5_NUM,C6.C6_ITEM"

cQuery := ChangeQuery(cQuery)
dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),_cAlias,.F.,.T.)

TcSetField((_cAlias), "C5_EMISSAO", "D")
TcSetField((_cAlias), "C5_FECENT",  "D")
TcSetField((_cAlias), "C5_DATA1",  "D")
TcSetField((_cAlias), "C5_DATA2",  "D")
TcSetField((_cAlias), "C5_DATA3",  "D")
TcSetField((_cAlias), "C5_DATA4",  "D")

Return (_cAlias)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATR730A  �Autor  �Microsiga           � Data �  08/21/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �  Grupo de perguntas                                        ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ValidPerg()

Local i := 0
Local j := 0
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01",STR0061,"","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA1"}) //"Do Cliente      	  ?"
AADD(aRegs,{cPerg,"02",STR0073,"","","mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""}) //"Da Loja      	  ?"
AADD(aRegs,{cPerg,"03",STR0049,"","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA1"}) //"At� o Cliente   	  ?"
AADD(aRegs,{cPerg,"04",STR0074,"","","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""}) //"At� a Loja   	  ?"
AADD(aRegs,{cPerg,"05",STR0050,"","","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SC5"}) //"Do Pedido       	  ?"
AADD(aRegs,{cPerg,"06",STR0051,"","","mv_ch6","C",06,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SC5"}) //"At� o Pedido    	  ?"
AADD(aRegs,{cPerg,"07",STR0052,"","","mv_ch7","D",08,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","",""}) //"Da Emiss�o        	  ?"
AADD(aRegs,{cPerg,"08",STR0053,"","","mv_ch8","D",08,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""}) //"At� Emiss�o       	  ?"
AADD(aRegs,{cPerg,"09",STR0054,"","","mv_ch9","C",06,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SA3"}) //"Do Vendedor      	  ?"
AADD(aRegs,{cPerg,"10",STR0055,"","","mv_ch10","C",06,0,0,"G","","mv_par010","","","","","","","","","","","","","","","","","","","","","","","","","SA3"}) //"At� o Vendedor   	  ?"
AADD(aRegs,{cPerg,"11",STR0056,"","","mv_ch11","C",20,0,0,"G","","mv_par011","","","","","","","","","","","","","","","","","","","","","","","","",""}) //"Assinatura 1       	  ?"
AADD(aRegs,{cPerg,"12",STR0057,"","","mv_ch12","C",20,0,0,"G","","mv_par012","","","","","","","","","","","","","","","","","","","","","","","","",""}) //"Assinatura 2       	  ?"
AADD(aRegs,{cPerg,"13",STR0058,"","","mv_ch13","C",20,0,0,"G","","mv_par013","","","","","","","","","","","","","","","","","","","","","","","","",""}) //"Assinatura 3       	  ?"

If SX1->(dbSeek(cPerg+"02")) .And.  SX1->X1_PERGUNT <> aRegs[2,3]
	SX1->(dbSkip(-1))
	While SX1->X1_GRUPO == cPerg
		SX1->(RecLock("SX1",.F.))
		SX1->(DbDelete())
		SX1->(MsUnlock())
		SX1->(dbSkip())	
	End	
EndIf

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
dbSelectArea("SX1")  

aHelpPor := {"Do Cliente."}
aHelpEng := aHelpPor
aHelpSpa := aHelpPor
PutHelp("P.MATR730A01.",aHelpPor,aHelpEng,aHelpSpa,.T.) 
aHelpPor := {"Da Loja."}
aHelpEng := aHelpPor
aHelpSpa := aHelpPor
PutHelp("P.MATR730A02.",aHelpPor,aHelpEng,aHelpSpa,.T.)
aHelpPor := {"At� o Cliente."}
aHelpEng := aHelpPor
aHelpSpa := aHelpPor
PutHelp("P.MATR730A03.",aHelpPor,aHelpEng,aHelpSpa,.T.)
aHelpPor := {"At� Loja."}
aHelpEng := aHelpPor
aHelpSpa := aHelpPor
PutHelp("P.MATR730A04.",aHelpPor,aHelpEng,aHelpSpa,.T.) 
aHelpPor := {"Do Pedido."}
aHelpEng := aHelpPor
aHelpSpa := aHelpPor
PutHelp("P.MATR730A05.",aHelpPor,aHelpEng,aHelpSpa,.T.)
aHelpPor := {"At� o Pedido."}
aHelpEng := aHelpPor
aHelpSpa := aHelpPor
PutHelp("P.MATR730A06.",aHelpPor,aHelpEng,aHelpSpa,.T.)
aHelpPor := {"Da Emiss�o."}
aHelpEng := aHelpPor
aHelpSpa := aHelpPor
PutHelp("P.MATR730A07.",aHelpPor,aHelpEng,aHelpSpa,.T.) 
aHelpPor := {"At� Emiss�o."}
aHelpEng := aHelpPor
aHelpSpa := aHelpPor
PutHelp("P.MATR730A08.",aHelpPor,aHelpEng,aHelpSpa,.T.)  
aHelpPor := {"Do Vendedor."}
aHelpEng := aHelpPor
aHelpSpa := aHelpPor
PutHelp("P.MATR730A09.",aHelpPor,aHelpEng,aHelpSpa,.T.)
aHelpPor := {"At� o Vendedor."}
aHelpEng := aHelpPor
aHelpSpa := aHelpPor
PutHelp("P.MATR730A10.",aHelpPor,aHelpEng,aHelpSpa,.T.)
aHelpPor := {"Assinatura 1"}
aHelpEng := aHelpPor
aHelpSpa := aHelpPor
PutHelp("P.MATR730A11.",aHelpPor,aHelpEng,aHelpSpa,.T.)
aHelpPor := {"Assinatura 2"}
aHelpEng := aHelpPor
aHelpSpa := aHelpPor
PutHelp("P.MATR730A12.",aHelpPor,aHelpEng,aHelpSpa,.T.)
aHelpPor := {"Assinatura 3"}
aHelpEng := aHelpPor
aHelpSpa := aHelpPor
PutHelp("P.MATR730A13.",aHelpPor,aHelpEng,aHelpSpa,.T.)


Return  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATR730A  �Autor  �Microsiga           � Data �  08/21/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Static Function Impostos(cNumPed,nBaseIcm,nValIcm,nBaseIPI,;
							nValIPI,nBaseRet,nValRet,nVlrTot,;
							nBaseISS,vValISS,nTotValdesc, nC5Desc1,;
							nC5Desc2,nC5Desc3,nC5Desc4,nC5Frete,;
							nC5Seguro,nC5Despesa)

Local lQuery    := .F.
#IFNDEF TOP
	Local cCondicao := ""
#ENDIF
Local aParcelas  := {}
Local aPedCli    := {}
Local aC5Rodape  := {}
Local aRelImp    := MaFisRelImp("MT100",{"SF2","SD2"})
Local aFisGet    := Nil
Local aFisGetSC5 := Nil
Local cKey 	     := ""
Local cAliasSC5  := "SC5"
Local cAliasSC6  := "SC6"
Local cQryAd     := ""
Local cPedido    := ""
Local cCliEnt	 := ""
Local cNfOri     := Nil
Local cSeriOri   := Nil
Local nDesconto  := 0
Local nPesLiq    := 0
Local nRecnoSD1  := Nil
Local nG		 := 0
Local nFrete	 := 0
Local nSeguro	 := 0
Local nFretAut	 := 0
Local nDespesa	 := 0
Local nDescCab	 := 0
Local nPDesCab	 := 0
Local nY         := 0
Local nValMerc   := 0
Local nPrcLista  := 0
Local nAcresFin  := 0
Local nCont		 := 0
Local aItemPed	 := {}
Local aCabPed	 := {}
Local nVlrtotal	 := 0
Local nValSOL	 := 0

FisGetInit(@aFisGet,@aFisGetSC5)

//������������������������������������������������������������������������Ŀ
//�Filtragem do relat�rio                                                  �
//��������������������������������������������������������������������������

If TcSrvType() <> "AS/400"

	cQryAd := "%"
	For nY := 1 To Len(aFisGet)
		cQryAd += ","+aFisGet[nY][2]
	Next nY
	For nY := 1 To Len(aFisGetSC5)
		cQryAd += ","+aFisGetSC5[nY][2]
	Next nY		
	cQryAd += "%"

	cAliasSC5:= cAliasSC6:= GetNextAlias()
	lQuery    := .T.
	
	BeginSql Alias cAliasSC5
	SELECT SC5.R_E_C_N_O_ SC5REC,SC6.R_E_C_N_O_ SC6REC,
	SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_TIPO,
	SC5.C5_TIPOCLI,SC5.C5_TRANSP,SC5.C5_PBRUTO,SC5.C5_PESOL,SC5.C5_DESC1,
	SC5.C5_DESC2,SC5.C5_DESC3,SC5.C5_DESC4,SC5.C5_C_INFAD,SC5.C5_EMISSAO,
	SC5.C5_CONDPAG,SC5.C5_FRETE,SC5.C5_DESPESA,SC5.C5_FRETAUT,SC5.C5_TPFRETE,SC5.C5_SEGURO,SC5.C5_TABELA,
	SC5.C5_VOLUME1,SC5.C5_ESPECI1,SC5.C5_MOEDA,SC5.C5_REAJUST,SC5.C5_BANCO,
	SC5.C5_ACRSFIN,SC5.C5_VEND1,SC5.C5_VEND2,SC5.C5_VEND3,SC5.C5_VEND4,SC5.C5_VEND5,
	SC5.C5_COMIS1,SC5.C5_COMIS2,SC5.C5_COMIS3,SC5.C5_COMIS4,SC5.C5_COMIS5,SC5.C5_PDESCAB,SC5.C5_DESCONT,C5_INCISS,
	SC5.C5_CLIENT,
	SC6.C6_FILIAL,SC6.C6_NUM,SC6.C6_PEDCLI,SC6.C6_PRODUTO,
	SC6.C6_TES,SC6.C6_CF,SC6.C6_QTDVEN,SC6.C6_PRUNIT,SC6.C6_VALDESC,
	SC6.C6_VALOR,SC6.C6_ITEM,SC6.C6_DESCRI,SC6.C6_UM,
	SC6.C6_PRCVEN,SC6.C6_NOTA,SC6.C6_SERIE,SC6.C6_CLI,
	SC6.C6_LOJA,SC6.C6_ENTREG,SC6.C6_DESCONT,SC6.C6_LOCAL,
	SC6.C6_QTDEMP,SC6.C6_QTDLIB,SC6.C6_QTDENT,SC6.C6_NFORI,SC6.C6_SERIORI,SC6.C6_ITEMORI
	%Exp:cQryAd%
	FROM %Table:SC5% SC5, %Table:SC6% SC6
	WHERE
	SC5.C5_FILIAL = %xFilial:SC5% AND
	SC5.C5_NUM = %Exp:cNumPed% AND
	SC5.%notdel% AND
	SC6.C6_FILIAL = %xFilial:SC6% AND
	SC6.C6_NUM   = SC5.C5_NUM AND
	SC6.%notdel%
	ORDER BY SC5.C5_NUM    
	EndSql

Else
   Return
Endif

//������������������������������������������������������������������������Ŀ
//�Inicio da impressao do fluxo do relat�rio                               �
//��������������������������������������������������������������������������
While !((cAliasSC5)->(Eof())) .and. xFilial("SC5")==(cAliasSC5)->C5_FILIAL

	//��������������������������������������������������������������Ŀ
	//� Executa a validacao dos filtros do usuario           	     �
	//����������������������������������������������������������������
	dbSelectArea(cAliasSC5)

	cCliEnt := IIf(!Empty((cAliasSC5)->(FieldGet(FieldPos("C5_CLIENT")))),(cAliasSC5)->C5_CLIENT,(cAliasSC5)->C5_CLIENTE)
	aCabPed := {}

	MaFisIni(cCliEnt,;						// 1-Codigo Cliente/Fornecedor
		(cAliasSC5)->C5_LOJACLI,;			// 2-Loja do Cliente/Fornecedor
		If((cAliasSC5)->C5_TIPO$'DB',"F","C"),;	// 3-C:Cliente , F:Fornecedor
		(cAliasSC5)->C5_TIPO,;				// 4-Tipo da NF
		(cAliasSC5)->C5_TIPOCLI,;			// 5-Tipo do Cliente/Fornecedor
		aRelImp,;							// 6-Relacao de Impostos que suportados no arquivo
		,;						   			// 7-Tipo de complemento
		,;									// 8-Permite Incluir Impostos no Rodape .T./.F.
		"SB1",;								// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
		"MATA461")							// 10-Nome da rotina que esta utilizando a funcao
	//Na argentina o calculo de impostos depende da serie.
	If cPaisLoc == 'ARG'
		SA1->(DbSetOrder(1))
		SA1->(MsSeek(xFilial()+(cAliasSC5)->C5_CLIENTE+(cAliasSC5)->C5_LOJACLI))
		MaFisAlt('NF_SERIENF',LocXTipSer('SA1',MVNOTAFIS))
	Endif

	nFrete		:= (cAliasSC5)->C5_FRETE
	nSeguro		:= (cAliasSC5)->C5_SEGURO
	nFretAut	:= (cAliasSC5)->C5_FRETAUT
	nDespesa	:= (cAliasSC5)->C5_DESPESA
	nDescCab	:= (cAliasSC5)->C5_DESCONT
	nPDesCab	:= (cAliasSC5)->C5_PDESCAB
 	nC5Desc1	:= (cAliasSC5)->C5_DESC1
 	nC5Desc2	:= (cAliasSC5)->C5_DESC2
 	nC5Desc3	:= (cAliasSC5)->C5_DESC3
 	nC5Desc4	:= (cAliasSC5)->C5_DESC4
 	nC5Frete	:= nFrete
 	nC5Seguro	:= nSeguro
 	nC5Despesa	:= nDespesa
	aItemPed:= {}
	aCabPed := {	(cAliasSC5)->C5_TIPO	,;
		(cAliasSC5)->C5_CLIENTE				,;
		(cAliasSC5)->C5_LOJACLI				,;
		(cAliasSC5)->C5_TRANSP				,;
		(cAliasSC5)->C5_CONDPAG				,;
		(cAliasSC5)->C5_EMISSAO				,;
		(cAliasSC5)->C5_NUM					,;
		(cAliasSC5)->C5_VEND1				,;
		(cAliasSC5)->C5_VEND2				,;
		(cAliasSC5)->C5_VEND3				,;
		(cAliasSC5)->C5_VEND4				,;
		(cAliasSC5)->C5_VEND5				,;
		(cAliasSC5)->C5_COMIS1				,;
		(cAliasSC5)->C5_COMIS2				,;
		(cAliasSC5)->C5_COMIS3				,;
		(cAliasSC5)->C5_COMIS4				,;
		(cAliasSC5)->C5_COMIS5				,;
		(cAliasSC5)->C5_FRETE				,;
		(cAliasSC5)->C5_TPFRETE				,;
		(cAliasSC5)->C5_SEGURO				,;
		(cAliasSC5)->C5_TABELA				,;
		(cAliasSC5)->C5_VOLUME1				,;
		(cAliasSC5)->C5_ESPECI1				,;
		(cAliasSC5)->C5_MOEDA				,;
		(cAliasSC5)->C5_REAJUST				,;
		(cAliasSC5)->C5_BANCO				,;
		(cAliasSC5)->C5_ACRSFIN				 ;
		}
	nTotQtd := 0
	nTotVal := 0
	nPesBru	:= 0
	nPesLiq	:= 0
	aPedCli	:= {}
	If !lQuery
		dbSelectArea(cAliasSC6)
		dbSetOrder(1)
		dbSeek(xFilial("SC6")+(cAliasSC5)->C5_NUM)
	EndIf
	cPedido    := (cAliasSC5)->C5_NUM
	aC5Rodape  := {}
	aadd(aC5Rodape,{(cAliasSC5)->C5_PBRUTO,(cAliasSC5)->C5_PESOL,(cAliasSC5)->C5_DESC1,(cAliasSC5)->C5_DESC2,;
		(cAliasSC5)->C5_DESC3,(cAliasSC5)->C5_DESC4,(cAliasSC5)->C5_C_INFAD})

	dbSelectArea(cAliasSC5)
	For nY := 1 to Len(aFisGetSC5)
		If !Empty(&(aFisGetSC5[ny][2]))
			If aFisGetSC5[ny][1] == "NF_SUFRAMA"
				MaFisAlt(aFisGetSC5[ny][1],Iif(&(aFisGetSC5[ny][2]) == "1",.T.,.F.),Len(aItemPed),.T.)		
			Else
				MaFisAlt(aFisGetSC5[ny][1],&(aFisGetSC5[ny][2]),Len(aItemPed),.T.)
			Endif	
		EndIf
	Next nY

	While !((cAliasSC6)->(Eof())) .And. xFilial("SC6")==(cAliasSC6)->C6_FILIAL .And.;
			(cAliasSC6)->C6_NUM == cPedido	

		cNfOri     := Nil
		cSeriOri   := Nil
		nRecnoSD1  := Nil
		nDesconto  := 0

		If !Empty((cAliasSC6)->C6_NFORI)
			dbSelectArea("SD1")
			dbSetOrder(1)
			dbSeek(xFilial("SC6")+(cAliasSC6)->C6_NFORI+(cAliasSC6)->C6_SERIORI+(cAliasSC6)->C6_CLI+(cAliasSC6)->C6_LOJA+;
				(cAliasSC6)->C6_PRODUTO+(cAliasSC6)->C6_ITEMORI)
			cNfOri     := (cAliasSC6)->C6_NFORI
			cSeriOri   := (cAliasSC6)->C6_SERIORI
			nRecnoSD1  := SD1->(RECNO())
		EndIf
		dbSelectArea(cAliasSC6)

		//���������������������������������������������Ŀ
		//�Calcula o preco de lista                     �
		//�����������������������������������������������
		nValMerc  := (cAliasSC6)->C6_VALOR
		nPrcLista := (cAliasSC6)->C6_PRUNIT
		If ( nPrcLista == 0 )
			nPrcLista := NoRound(nValMerc/(cAliasSC6)->C6_QTDVEN,TamSX3("C6_PRCVEN")[2])
		EndIf
		nAcresFin := A410Arred((cAliasSC6)->C6_PRCVEN*(cAliasSC5)->C5_ACRSFIN/100,"D2_PRCVEN")
		nValMerc  += A410Arred((cAliasSC6)->C6_QTDVEN*nAcresFin,"D2_TOTAL")		
		nDesconto := a410Arred(nPrcLista*(cAliasSC6)->C6_QTDVEN,"D2_DESCON")-nValMerc
		nDesconto := IIf(nDesconto==0,(cAliasSC6)->C6_VALDESC,nDesconto)
		nDesconto := Max(0,nDesconto)
		nTotValdesc += nDesconto
		nPrcLista += nAcresFin
		If cPaisLoc=="BRA"
			nValMerc  += nDesconto
		EndIf			
		
		MaFisAdd((cAliasSC6)->C6_PRODUTO	,;	// 1-Codigo do Produto ( Obrigatorio )
			(cAliasSC6)->C6_TES				,;	// 2-Codigo do TES ( Opcional )
			(cAliasSC6)->C6_QTDVEN			,;	// 3-Quantidade ( Obrigatorio )
			nPrcLista						,;	// 4-Preco Unitario ( Obrigatorio )
			nDesconto						,;	// 5-Valor do Desconto ( Opcional )
			cNfOri							,;	// 6-Numero da NF Original ( Devolucao/Benef )
			cSeriOri						,;	// 7-Serie da NF Original ( Devolucao/Benef )
			nRecnoSD1						,;	// 8-RecNo da NF Original no arq SD1/SD2
			0								,;	// 9-Valor do Frete do Item ( Opcional )
			0								,;	// 10-Valor da Despesa do item ( Opcional )
			0								,;	// 11-Valor do Seguro do item ( Opcional )
			0								,;	// 12-Valor do Frete Autonomo ( Opcional )
			nValMerc						,;	// 13-Valor da Mercadoria ( Obrigatorio )
			0								,;	// 14-Valor da Embalagem ( Opiconal )
			0								,;	// 15-RecNo do SB1
			0								)	// 16-RecNo do SF4
	
						

		aadd(aItemPed,	{	(cAliasSC6)->C6_ITEM	,;
			(cAliasSC6)->C6_PRODUTO					,;
			(cAliasSC6)->C6_DESCRI					,;
			(cAliasSC6)->C6_TES						,;
			(cAliasSC6)->C6_CF						,;
			(cAliasSC6)->C6_UM						,;
			(cAliasSC6)->C6_QTDVEN					,;
			(cAliasSC6)->C6_PRCVEN					,;
			(cAliasSC6)->C6_NOTA					,;
			(cAliasSC6)->C6_SERIE					,;
			(cAliasSC6)->C6_CLI						,;
			(cAliasSC6)->C6_LOJA					,;
			(cAliasSC6)->C6_VALOR					,;
			(cAliasSC6)->C6_ENTREG					,;
			(cAliasSC6)->C6_DESCONT					,;
			(cAliasSC6)->C6_LOCAL					,;
			(cAliasSC6)->C6_QTDEMP					,;
			(cAliasSC6)->C6_QTDLIB					,;
			(cAliasSC6)->C6_QTDENT					,;
			})							
			
		//�����������������������������������������������������������������������Ŀ
		//�Forca os valores de impostos que foram informados no SC6.              �
		//�������������������������������������������������������������������������
		dbSelectArea(cAliasSC6)
		For nY := 1 to Len(aFisGet)
			If !Empty(&(aFisGet[ny][2]))
				MaFisAlt(aFisGet[ny][1],&(aFisGet[ny][2]),Len(aItemPed))
			EndIf
		Next nY

		//���������������������������������������������Ŀ
		//�Calculo do ISS                               �
		//�����������������������������������������������
		SF4->(dbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4")+(cAliasSC6)->C6_TES))
		If ( (cAliasSC5)->C5_INCISS == "N" .And. (cAliasSC5)->C5_TIPO == "N")
			If ( SF4->F4_ISS=="S" )
				nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(Len(aItemPed))/100)),"D2_PRCVEN")
				nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(Len(aItemPed))/100)),"D2_PRCVEN")
				MaFisAlt("IT_PRCUNI",nPrcLista,Len(aItemPed))
				MaFisAlt("IT_VALMERC",nValMerc,Len(aItemPed))
			EndIf
		EndIf	
		
		//���������������������������������������������Ŀ
		//�Altera peso para calcular frete              �
		//�����������������������������������������������
		SB1->(dbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+(cAliasSC6)->C6_PRODUTO))			
		MaFisAlt("IT_PESO",(cAliasSC6)->C6_QTDVEN*SB1->B1_PESO,Len(aItemPed))
		MaFisAlt("IT_PRCUNI",nPrcLista,Len(aItemPed))
		MaFisAlt("IT_VALMERC",nValMerc,Len(aItemPed))
			
		If !lQuery
			dbSelectArea(cAliasSC6)
		EndIf

		(cAliasSC6)->(dbSkip())
	EndDo
	MaFisAlt("NF_FRETE"   ,nFrete)
	MaFisAlt("NF_SEGURO"  ,nSeguro)
	MaFisAlt("NF_AUTONOMO",nFretAut)
	MaFisAlt("NF_DESPESA" ,nDespesa)

	If nDescCab > 0
		MaFisAlt("NF_DESCONTO",Min(MaFisRet(,"NF_VALMERC")-0.01,nDescCab+MaFisRet(,"NF_DESCONTO")))
	EndIf
	If nPDesCab > 0
		MaFisAlt("NF_DESCONTO",A410Arred(MaFisRet(,"NF_VALMERC")*nPDesCab/100,"C6_VALOR")+MaFisRet(,"NF_DESCONTO"))
	EndIf         
	
    nVlrtotal	:= MaFisRet(,"NF_BASEDUP")
    nValIPI		:= MaFisRet(,"NF_VALIPI")
    nValSOL		:= MaFisRet(,"NF_VALSOL")
         
    nBaseIcm	:= MaFisRet(,"NF_BASEICM")	// "Base Icms"
	nValIcm		:= MaFisRet(,"NF_VALICM")	// "Valor Icms"
	nBaseIPI	:= MaFisRet(,"NF_BASEIPI")	// "Base Ipi" 
	nValIPI		:= MaFisRet(,"NF_VALIPI")	// "Valor Ipi"
	nBaseRet	:= MaFisRet(,"NF_BASESOL")	// "Base Retido" 
	nValRet		:= MaFisRet(,"NF_VALSOL")	// "Valor Retido"
	nVlrTot		:= MaFisRet(,"NF_TOTAL"	)	// "Valor Total"
	nBaseISS	:= MaFisRet(,"NF_BASEISS")	// "Base Iss" 
	vValISS		:= MaFisRet(,"NF_VALISS")	// "Valor Iss"

    
	MaFisEnd()


EndDo

aParcelas := Condicao(nVlrtotal, aCabPed[5],nValIPI,STOD(aCabPed[6]),nValSOL)

Return aParcelas


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATR730A  �Autor  �Microsiga           � Data �  08/21/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FisGetInit(aFisGet,aFisGetSC5)

Local cValid      := ""
Local cReferencia := ""
Local nPosIni     := 0
Local nLen        := 0

If aFisGet == Nil
	aFisGet	:= {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("SC6")
	While !Eof().And.X3_ARQUIVO=="SC6"
		cValid := UPPER(X3_VALID+X3_VLDUSER)
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
			aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		dbSkip()
	EndDo
	aSort(aFisGet,,,{|x,y| x[3]<y[3]})
EndIf

If aFisGetSC5 == Nil
	aFisGetSC5	:= {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("SC5")
	While !Eof().And.X3_ARQUIVO=="SC5"
		cValid := UPPER(X3_VALID+X3_VLDUSER)
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGetSC5,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
			aAdd(aFisGetSC5,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		dbSkip()
	EndDo
	aSort(aFisGetSC5,,,{|x,y| x[3]<y[3]})
EndIf
MaFisEnd()
Return(.T.)


//-------------------------------------------------------------------
/*/{Protheus.doc} fValdTES.
Valida��o para permitir que seja gerado o relatorio em TES sem 
atualiza��o de estoque .
de contribui��o.
@Author   Davidson-Nutratta
@Since 	   17/09/2019.
@Version 	P11 R5
@param   	n/t
@return  	n/t
@obs.......  
o	Especifico Nutratta Nutri��o Animal.

xxx......
/*/
//-----------------------------------------------------------------------------------------------------------
Static Function fValdTES(_cTes)

Local _lRet :=.F.

dbSelectArea("SF4")
dbSetOrder(1)
If dbSeek(xFilial("SF4")+_cTes)
	
	If	SF4->F4_ESTOQUE == 'S'
		
		_lRet:=.T.		
	Else
	
		_lRet:=.F.
	EndIf
EndIf

Return(_lRet)
