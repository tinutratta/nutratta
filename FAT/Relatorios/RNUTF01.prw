#include 'protheus.ch'
#include 'parmtype.ch'

Static __aUserLg := {}


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � RNUTF01  � Autor � Davis Magalhaes       � Data � 12/05/16 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Pedidos nao Entregues Por Vendedor            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Nutratta                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User function RNUTF01()


Local oReport

Private nRegTmp   := 0
Private cArqTrab  := ""
Private cIndTrb1  := Space(08)
Private cArqTSA3  := ""
Private cIndTSA3  := Space(08)
Private cArqTSM0  := ""
Private cIndTSM0  := Space(08)
Private lSelFil	  :=.F.      
Private lSelVen   :=.F.
 
PRIVATE aColunas  := {}

//If FindFunction("TRepInUse") .And. TRepInUse()
//-- Interface de impressao
oReport := ReportDef()
oReport:PrintDialog()
//Else
//	MATR550R3()
//EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Davis Magalhaes       � Data �18/10/10  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()


Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oSection4
Local oSection5
Local oCell
Local aOrdem := {}

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
//oReport:= TReport():New("RDIE002","Custos por Obras","RDIE002PR4", {|oReport| ReportPrint(oReport,"RDIE02")},"Relacao de Custos por Obra") //"Relacao de Pedidos de Compras"##"Emissao da Relacao de  Pedidos de Compras."##"Sera solicitado em qual Ordem, qual o Intervalo para"##"a emissao dos pedidos de compras."
oReport:= TReport():New("RNUTF01","Rela��o de Pedidos Nao Entregue","RNUTF01", {|oReport| ReportPrint(oReport)},"Rela��o de Pedidos n�o Entregue") //"Relacao de Pedidos de Compras"##"Emissao da Relacao de  Pedidos de Compras."##"Sera solicitado em qual Ordem, qual o Intervalo para"##"a emissao dos pedidos de compras."
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)

// -- Ajustas as Perguntas
AjustaSX1("RNUTF01")

Pergunte(oReport:uParam,.F.)

//oSection1 := TRSection():New(oReport,"Relacao de Faturamento por Filial",{"SF2","DTC","SE4","DA3","DA4" }) //"Relacao de Pedidos de Compras"
oSection1 := TRSection():New(oReport,"Relacao de Pedidos Nao Entregues") //"Relacao de Pedidos de Compras"
oSection1 :SetTotalInLine(.F.)
oSection1 :SetHeaderPage()
oSection1 :SetTotalText("Total Geral") //"Total Geral "

TRCell():New(oSection1,"CCODFILI"	,"","Filial"			 	,"@!"	  					,06,/*lPixel*/	,{|| cCodFili })
TRCell():New(oSection1,"DEMISSAO"	,"","Emissao"	         	,"@!"	  					,10,/*lPixel*/	,{|| dEmissao })
TRCell():New(oSection1,"CNUMPEDI"	,"","No Pedido"        		,"@!"						,10,/*lPixel*/	,{|| cNumPedi })

TRCell():New(oSection1,"CVENDEDO"  	,"" ,"Vendedor"	    	 	,"@!"   					,45,/*lPixel*/	,{|| cVendedo })
TRCell():New(oSection1,"CCODCLIE"	,"","Cod. Cliente"        	,"@!"   					,20,/*lPixel*/	,{|| cCodClie })
TRCell():New(oSection1,"CNOMCLIE"	,"","Nome Cliente"        	,"@!"   					,40,/*lPixel*/	,{|| cNomClie })
TRCell():New(oSection1,"CEMAILCL"	,"","E-Mail Cliente"      	,""   				   		,50,/*lPixel*/	,{|| cEmailCl })
TRCell():New(oSection1,"CTELEFCL"	,"","DDD - Telefone"      	,""   						,50,/*lPixel*/	,{|| cTelefCl })
//TRCell():New(oSection1,"CNUMPEDI"	,"","No Pedido"        		,"@!"						,10,/*lPixel*/	,{|| cNumPedi })
TRCell():New(oSection1,"CCODPROD"	,"","Cod Produto"         	,"@!"   					,20,/*lPixel*/	,{|| cCodProd })
TRCell():New(oSection1,"CDESPROD"	,"","Descri��o Produto"  	,"@!"   					,40,/*lPixel*/	,{|| cDesProd })
TRCell():New(oSection1,"CUNMEDID"	,"","UN"                  	,"@!"   					,05,/*lPixel*/ 	,{|| cUNMedid })
//TRCell():New(oSection1,"CSEGUNMD"	,"","S. UN"            		,"@!"   					,05,/*lPixel*/  ,{|| CSEGUNMD })
TRCell():New(oSection1,"NQTDEPUN"	,"","Qtd.Pedido"  	      	,"@E 999,999,999.9999"   	,15	,/*lPixel*/	,{|| nQtdePUn })
//TRCell():New(oSection1,"NTONELAD"	,"","Qtd.Tonelada"       	,"@E 999,999,999.9999"   	,15	,/*lPixel*/	,{|| nTonelad })//Toneladas
TRCell():New(oSection1,"NPRECUNI"	,"","Vlr.Unit"	 		  	,"@E 999,999,999.99"		,15,/*lPixel*/	,{|| nPrecUni })
TRCell():New(oSection1,"NVALFRET"	,"","Vlr.Frete"		  		,"@E 999,999,999.99"		,15,/*lPixel*/	,{|| nValFret })
TRCell():New(oSection1,"NVALTOTA"	,"","Vlr.Total"	  			,"@E 999,999,999.99"		,15,/*lPixel*/	,{|| nValTota })
//TRCell():New(oSection1,"NQTDESUN"	,"","Qtde Seg Un"  	  		,"@E 999,999,999.9999"   	,20	,/*lPixel*/	,{|| nQtdeSUn })

TRCell():New(oSection1,"CCODFISC"	,"","CFOP"				    ,"@!"	  					,05,/*lPixel*/	,{|| cCodFisc })
TRCell():New(oSection1,"CFINCFOP"	,"","Finalidade"		    ,"@!"	  					,20,/*lPixel*/	,{|| cFinCFOP })

TRCell():New(oSection1,"CNUMNOTA"	,"","No NF-e"  	         	,"@!"						,10,/*lPixel*/	,{|| cNumNota })
TRCell():New(oSection1,"CSERNOTA"	,"","S�rie NF-e"         	,"@!"						,03,/*lPixel*/	,{|| cSerNota })
TRCell():New(oSection1,"DEMINFE"	,"","Emiss.NF-e"	         	,"@!"	  					,10,/*lPixel*/	,{|| dEmiss1 })
//TRCell():New(oSection1,"DEMINOTA"	,"","E NF-e"        	,"@!"						,10,/*lPixel*/	,{|| cEmiNota })
TRCell():New(oSection1,"NQTDNOTA"	,"","Qtd. NF-e"            	,"@E 999,999,999.9999"		,15,/*lPixel*/	,{|| nQtdNota })
TRCell():New(oSection1,"NPUNNOTA"	,"","Prc. Unit NF-e"       	,"@E 999,999,999.99"		,15,/*lPixel*/	,{|| nPUnNota })
TRCell():New(oSection1,"NTOTNOTA"	,"","Vlr. Total NF-e"       ,"@E 999,999,999.99"		,15,/*lPixel*/	,{|| nTotNota })

TRCell():New(oSection1,"CNUMCONT"	,"","No Contrato"		  	,"@!"                 		,06,/*lPixel*/	,{|| cNumCont })
TRCell():New(oSection1,"DEMICONT"	,"","Emissao Contrato"	 	,"@!"                 		,10,/*lPixel*/	,{|| dEmiCont })

TRCell():New(oSection1,"CMUNENTR"	,"","Municipio Entrega"   	,"@!"						,30,/*lPixel*/	,{|| cMunEntr })
TRCell():New(oSection1,"CUFENTRE"	,"","UF Entrega" 	  	    ,"@!"						,10,/*lPixel*/	,{|| cUFEntre })
TRCell():New(oSection1,"DENTREGA"	,"","Entrega"			    ,"@!"	  					,15,/*lPixel*/	,{|| dEntrega })
TRCell():New(oSection1,"CMESENTR"	,"","Mes Entrega"		    ,"@!"	  					,20,/*lPixel*/	,{|| cMesEntr }) 
TRCell():New(oSection1,"DTEFET"		,"","Dt.Efetiva"		    ,"@!"	  					,20,/*lPixel*/	,{|| dDtEfet })
TRCell():New(oSection1,"TPFRETE"	,"","Incoterms"            	,"@!"   					,05,/*lPixel*/ 	,{|| cTpFrete })
TRCell():New(oSection1,"CMOTO"		,"","Motorista"             ,"@!"   					,05,/*lPixel*/ 	,{|| cTMot })
TRCell():New(oSection1,"CPLACA"		,"","Placa"             	,"@!"   					,05,/*lPixel*/ 	,{|| cPlaca})
TRCell():New(oSection1,"CFROTA"		,"","Frota"             	,"@!"   					,05,/*lPixel*/ 	,{|| cFrota })
TRCell():New(oSection1,"CTIPOV"		,"","Tp.Veiculo"            ,"@!"   					,05,/*lPixel*/ 	,{|| cTipoVe})
TRCell():New(oSection1,"CTPCAR"		,"","Carroceria"            ,"@!"   					,05,/*lPixel*/ 	,{|| cVeiculo})


//TRCell():New(oSection1,"CCONDPAG"	,"","Condi��o"		     	,"@!"	  					,03,/*lPixel*/	,{|| cCondpag })
//TRCell():New(oSection1,"CDESCPAG"	,"","Descri��o"		     	,"@!"	  					,40,/*lPixel*/	,{|| cDescpag })

//TRFunction():New(oSection1:Cell("NVLBRUTO"),NIL,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.T.,,oSection1)
//TRFunction():New(oSection1:Cell("NVLLIQUI"),NIL,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.T.,,oSection1)

//TRFunction():New(oSection1:Cell("NVLBRUTO")		,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
//TRFunction():New(oSection1:Cell("NVLLIQUI")		,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)

Return(oReport)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Davis Magalhaes        � Data �12.05.2016���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport) //Static Function ReportPrint(oReport,cAlias)

Local oSection1 	:= oReport:Section(1)
Local oBreak
Local oTotaliz
Local nTxMoeda		:= 1
Local lFirst    	:= .F.
Local nRegTemp  	:= 0
Local 	aFilsCalc  	:= {}
Local 	aEmpresa   	:= {}
Private cSelFil		:= ""
Private cSelVen		:= ""
Private cFilt		:= MV_PAR01

lSelFil:= IIF(MV_PAR10==1,.T.,.F.)

// -- Chamar MarkBrowse com Cadastro de Vendedores
If lSelFil      //Seleciona Filial = Sim
	aFilsCalc := MatFilCalc( lSelFil,,,,,3)
	If Empty( aFilsCalc )
		Return
	EndIf
	
	nVirgula := 0
	For nXy := 1 To Len( aFilsCalc )
		If aFilsCalc[ nXy, 1 ]
			nVirgula++
		EndIf
    Next
	nContV := 0
	For nForFilial := 1 To Len( aFilsCalc )
		If aFilsCalc[ nForFilial, 1 ]
			cSelFil += "'"+aFilsCalc[ nForFilial, 2 ]+"'"
			nContV++
			If nContV < nVirgula
				cSelFil += ","
			EndIf
			//aAdd(aEmpresa,{ IIf(!Empty(aFilsCalc[nForFilial][4]), aFilsCalc[nForFilial][4], Replic("0",14) ), cEmpAnt, aFilsCalc[nForFilial][2] } )
		EndIf
    Next
EndIf 

/*
If MV_PAR07 == 1
	//MsgStop("Gravar SA3")
	fGrvSA3()

	dbSelectArea("TRBSA3")
	TRBSA3->( dbSetOrder(1) )
	TRBSA3->( dbGoTop() )
	
	If ! TRBSA3->( Eof() )
		
		MontaSA3()
	EndIf
EndIf
*/                                                    
//MsgInfo("Compilado em 13/04/2018")
MsAguarde({ ||FAtuDados() }, "Atualizando datas de entrega...")  //-- Atualizando base de dados.

MsAguarde({ ||FGrvTmp(lSelFil,lSelVen) }, "Atualizando datas de entrega...")  //-- Chamada da Funcao de Arquivo Temporarios


oReport:SetTitle( oReport:Title()) // " - POR NUMERO"
//oSection1 :SetTotalText("Total por Filial" ) //"Total dos Itens: "

//oBreak := TRBreak():New(oSection1,oSection1:Cell("CFILOBRA"),"Total por Filial",.f.)				//"Total do Produto"

//oTotaliz := TRFunction():New(oSection:Cell('NVLBRUTO'),Nil,"SUM",oBreak,"Total Item Contabil" /* + ' 2a.U.M.'Titulo*/,,,.F.,.F.,/*Obj*/) //"Qtde. "##"Disponivel   "
//TRFunction():New(oSection1:Cell("NVLRFRETE"), ,"SUM",oBreak,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.T.,,oSection1)
//TRFunction():New(oSection1:Cell("NPESO"), ,"SUM",oBreak,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.T.,,oSection1)
//TRFunction():New(oSection1:Cell("NVLNOTAC"), +,"SUM",oBreak,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.T.,,oSection1)

//TRPosition():New(oSection1,"RDIE02",1,{|| Substr(RDIE02->FILIAL,1,2)+RDIE02->ITEM,DTOS(RDIE02->DT_EMISSAO) })


//MsgStop("Arquivo Temporario: "+cAliasTP1)


dbSelectArea("RNUTFT")
dbSetOrder(01)
dbGoTop()

oReport:SetMeter( nRegTMP )
oSection1:Init()


While ! oReport:Cancel() .And. ! RNUTFT->( Eof() )
	
	If oReport:Cancel()
		
		Exit
		
	EndIf

	oReport:IncMeter()
	
	oSection1:Cell("CCODFILI"):SetValue(RNUTFT->CODFILI)
	oSection1:Cell("DEMISSAO"):SetValue(RNUTFT->DTEMISS)
	oSection1:Cell("CNUMPEDI"):SetValue(RNUTFT->NUMPEDI)
	oSection1:Cell("CVENDEDO"):SetValue(RNUTFT->CODVEND+"-"+RNUTFT->NOMVEND)
	oSection1:Cell("CCODCLIE"):SetValue(RNUTFT->CLIENTE+"/"+RNUTFT->LOJACLI)
	oSection1:Cell("CNOMCLIE"):SetValue(RNUTFT->NOMECLI)
	oSection1:Cell("CEMAILCL"):SetValue(Posicione("SA1",1,xFilial("SA1")+RNUTFT->CLIENTE+RNUTFT->LOJACLI,"A1_EMAIL"))
	oSection1:Cell("CTELEFCL"):SetValue("("+Posicione("SA1",1,xFilial("SA1")+RNUTFT->CLIENTE+RNUTFT->LOJACLI,"A1_DDD")+") "+Posicione("SA1",1,xFilial("SA1")+RNUTFT->CLIENTE+RNUTFT->LOJACLI,"A1_TEL"))
	oSection1:Cell("CCODPROD"):SetValue(RNUTFT->CODPROD)
	oSection1:Cell("CDESPROD"):SetValue(RNUTFT->DESPROD)
	oSection1:Cell("CUNMEDID"):SetValue(RNUTFT->PRUNMED)
//	oSection1:Cell("CSEGUNMD"):SetValue(RNUTFT->SGUNMED)
	oSection1:Cell("NQTDEPUN"):SetValue(RNUTFT->QTDEPUN)
	oSection1:Cell("NPRECUNI"):SetValue(RNUTFT->PRECUNI)
	oSection1:Cell("NVALFRET"):SetValue(RNUTFT->VALFRET)
	oSection1:Cell("NVALTOTA"):SetValue(RNUTFT->VALTOTA)
	
	oSection1:Cell("CCODFISC"):SetValue(RNUTFT->CODFISC)
	oSection1:Cell("CFINCFOP"):SetValue(RNUTFT->FINCFOP)

	oSection1:Cell("CNUMNOTA"):SetValue(Alltrim(RNUTFT->NUMNOTA))
	oSection1:Cell("CSERNOTA"):SetValue(RNUTFT->SERNOTA)
	oSection1:Cell("DEMINFE"):SetValue(RNUTFT->DEMINFE)
//	oSection1:Cell("DEMINOTA"):SetValue(Alltrim(RNUTFT->EMINOTA))
	oSection1:Cell("NQTDNOTA"):SetValue(RNUTFT->QTDNOTA)
	oSection1:Cell("NPUNNOTA"):SetValue(RNUTFT->PUNNOTA)
	oSection1:Cell("NTOTNOTA"):SetValue(RNUTFT->TOTNOTA)

	oSection1:Cell("CNUMCONT"):SetValue(RNUTFT->NUMCONT)
	oSection1:Cell("DEMICONT"):SetValue(RNUTFT->EMICONT)
	
//	oSection1:Cell("NQTDESUN"):SetValue(RNUTFT->QTDESUN)
	oSection1:Cell("CMUNENTR"):SetValue(RNUTFT->MUNENTR)
	oSection1:Cell("CUFENTRE"):SetValue(RNUTFT->UFENTRE)
	oSection1:Cell("DENTREGA"):SetValue(RNUTFT->DTENTRE)
	oSection1:Cell("CMESENTR"):SetValue(RNUTFT->MESENTR)
	oSection1:Cell("DTEFET"):SetValue(RNUTFT->DTEFET)
	oSection1:Cell("TPFRETE"):SetValue(RNUTFT->TPFRETE)
	oSection1:Cell("CMOTO"):SetValue(RNUTFT->CMOTO)
	oSection1:Cell("CPLACA"):SetValue(RNUTFT->CPLACA)	
	oSection1:Cell("CFROTA"):SetValue(RNUTFT->CFROTA)	
	oSection1:Cell("CTIPOV"):SetValue(RNUTFT->CTIPOV)
	oSection1:Cell("CTPCAR"):SetValue(RNUTFT->CTPCAR)
		
	oSection1:PrintLine()
	
	dbSelectArea("RNUTFT")
	RNUTFT->( dbSkip() )
End

//oSecTion1:Print()

oSection1:Finish()

dbSelectArea("RNUTFT")
dbCloseArea()


Return NIL



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �AjustaSX1 � Autor � Davis Magalhaes       � Data �18.10.2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta perguntas no SX1.                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function AjustaSx1(cPerg)

//--Tipo Filtro Emissao Nfe ou Pedido de vendas - Davidson 09/12/2016 
PutSx1(cPerg,"01","Dt.Pedido de  	?"      ," "," ","mv_ch1","D",8,0,0,"G","",""   ,,,"mv_par01")  //"ID do processo"
PutSx1(cPerg,"02","Dt.Pedido ate 	?"      ," "," ","mv_ch2","D",8,0,0,"G","! Empty(Mv_Par02) .And. MV_PAR02 >= MV_PAR01",""   ,,,"mv_par02")  //"ID do processo"
PutSx1(cPerg,"03","Faturado De  ?"     ," "," ","mv_ch3","D",8,0,0,"G","",""   ,,,"mv_par03")  //"ID do processo"
PutSx1(cPerg,"04","Faturado ate ?"     ," "," ","mv_ch4","D",8,0,0,"G","! Empty(Mv_Par04) .And. MV_PAR04 >= MV_PAR03",""   ,,,"mv_par04")  //"ID do processo"
PutSx1(cPerg,"05","Entrega de  ?"     ," "," ","mv_ch5","D",8,0,0,"G","",""   ,,,"mv_par05")  //"ID do processo"
PutSx1(cPerg,"06","Ate Entrega ?"     ," "," ","mv_ch6","D",8,0,0,"G","! Empty(Mv_Par06) .And. MV_PAR06 >= MV_PAR05",""   ,,,"mv_par06")  //"ID do processo"
PutSx1(cPerg,"07","Pedido   de ?"     ," "," ","mv_ch7","C",6,0,0,"G","","SC5"   ,,,"mv_par07")  //"ID do processo"
PutSx1(cPerg,"08","Ate Pedido  ?"     ," "," ","mv_ch8","C",6,0,0,"G","! Empty(Mv_Par08) .And. MV_PAR08 >= MV_PAR07","SC5"   ,,,"mv_par08")  //"ID do processo"
PutSx1(cPerg,"09","Status Pedidos?" ," "," "   ,"mv_ch9","N",1,0,1,"C","","","","","mv_par09","Entregues","S�","Yes","","N�o Entregues","No","No","Ambos","Ambos","Ambos","","","","","","")
PutSx1(cPerg,"10","Seleciona Filiais?" ," "," ","mv_ch10","N",1,0,1,"C","","","","","mv_par10","Sim","S�","Yes","","N�o","No","No","","","","","","","","","")
//PutSx1(cPerg,"01","Filtrar emiss�o por  ?" 		," "," "   ,"mv_ch1","N",1,0,1,"C","","","","","mv_par01","Pedidos","S�","Yes","","Notas ","No","No","","","","","","","","","")
//PutSx1(cPerg,"08","Seleciona Vendedores?" ," "," ","mv_ch7","N",1,0,1,"C","","","","","mv_par07","Sim","S�","Yes","","N�o","No","No","","","","","","","","","")
//PutSx1(cPerg,"07","Serie de    ?"     ," "," ","mv_ch7","C",3,0,0,"G","","",,,"mv_par07")  //"Codigo do processo"
//PutSx1(cPerg,"08","Ate Serie   ?"     ," "," ","mv_ch8","C",3,0,0,"G","! Empty(Mv_Par08) .And. Mv_Par08 >= Mv_Par07","",,,"mv_par08")  //"Versao do processo"

Return

              

Static Function FGrvTmp(lSelFil,lSelVen)
*******************************************************************************
*
**

Local cEol   := ""
Local cQuery := ""
Local aStru  := {}
Local cTipoRel := 2
Local aColunas := {}
Local cLisRDPD := "" //Tem todos as verbas deste programa
Local cAliasSC5 := GetNextAlias()
Local cQrySC5   := ""
Local cMotor	:=""
Local cFrota    :=""
Local cVeiculo	:=""
Local cTipVeic 	:=""
Local cTpFrete	:="" 
Local cTipCar	:=""
Local cEmiNF	:=date()
Local dTefetiv	:=date()
	
cQrySC5 := " SELECT * FROM "+RetSqlName("SC6")+" SC6"
CQrySC5 += " INNER JOIN "+RetSqlName("SC5")+" SC5"
cQrySC5 += " ON SC5.C5_FILIAL = SC6.C6_FILIAL"
cQrySC5 += " AND SC5.C5_NUM = SC6.C6_NUM"
cQrySC5 += " WHERE SC5.D_E_L_E_T_ <> '*' AND SC6.D_E_L_E_T_ <> '*' "

If lSelFil 
	//msgStop("cSelFil: "+cSelFil)
	cQrySC5 += " AND SC5.C5_FILIAL IN("+cSelFil+") " //'"+xFilial("SC5")+"'"
Else
	cQrySC5 += " AND SC5.C5_FILIAL = '"+xFilial("SC5")+"' " //'"+xFilial("SC5")+"'"
EndIf
cQrySC5 += " AND SC5.C5_NUM	BETWEEN '"+Mv_Par07+"' AND '"+Mv_Par08+"'"

//-- Davidson 07/07/2017.
//-- Filtra por data de emiss�o Pedido de vendas.

//Emiss�o e Pedidos entregues
If MV_PAR09 == 1 

	cQrySC5 += " AND SC5.C5_TIPO = 'N'"
	cQrySC5 += " AND SC5.C5_NOTA <> 'XXXXXXXXX' " //Adicionado tratamento Elimmina��o de residuos Davidson-25/10/2016.
//	cQrySC5 += " AND SC6.C6_NOTA <> '' AND C6_SERIE <> '' " 
	cQrySC5 += " AND SC5.C5_EMISSAO BETWEEN '"+dToS(Mv_Par01) +"' AND '"+dToS(Mv_Par02)+"'"   //Emissao do pedido
	cQrySC5 += " AND SC6.C6_DATFAT BETWEEN '"+dToS(Mv_Par03) +"' AND '"+dToS(Mv_Par04)+"'"    //Faturamento da NFe  
	cQrySC5 += " AND SC5.C5_FECENT BETWEEN '"+dToS(Mv_Par05) +"' AND '"+dToS(Mv_Par06)+"'"    //Data de entrega
//	cQrySC5 += " AND SC6.C6_ENTREG  BETWEEN '"+dToS(Mv_Par05) +"' AND '"+dToS(Mv_Par06)+"'"

//Emiss�o Pedidos n�o entregues
ElseIf MV_PAR09 == 2                   

	cQrySC5 += " AND SC5.C5_TIPO = 'N'"
	cQrySC5 += " AND SC6.C6_NOTA = '' AND C6_SERIE = '' AND SC5.C5_NOTA ='' " //Adicionado tratamento Elimmina��o de residuos Davidson-25/10/2016.
	cQrySC5 += " AND SC5.C5_EMISSAO BETWEEN '"+dToS(Mv_Par01) +"' AND '"+dToS(Mv_Par02)+"'"   //Emissao do pedido
	cQrySC5 += " AND SC5.C5_FECENT BETWEEN '"+dToS(Mv_Par05) +"' AND '"+dToS(Mv_Par06)+"'"    //Data de entrega
//	cQrySC5 += " AND SC6.C6_DATFAT BETWEEN '"+dToS(Mv_Par03) +"' AND '"+dToS(Mv_Par04)+"'"    //Faturamento da NFe  
//	cQrySC5 += " AND SC6.C6_ENTREG  BETWEEN '"+dToS(Mv_Par05) +"' AND '"+dToS(Mv_Par06)+"'

//Emiss�o Pedidos Pedidos entregues e n�o entregues=Ambos.
ElseIf MV_PAR09 == 3
	
	cQrySC5 += " AND SC5.C5_TIPO = 'N'"
	cQrySC5 += " AND SC5.C5_NOTA <> 'XXXXXXXXX' " //Adicionado tratamento Elimmina��o de residuos Davidson-25/10/2016.
	cQrySC5 += " AND SC5.C5_EMISSAO BETWEEN '"+dToS(Mv_Par01) +"' AND '"+dToS(Mv_Par02)+"'"   //Emissao do pedido
//	cQrySC5 += " OR SC6.C6_DATFAT BETWEEN '"+dToS(Mv_Par03) +"' AND '"+dToS(Mv_Par04)+"'"    //Faturamento da NFe  
	cQrySC5 += " AND SC5.C5_FECENT BETWEEN '"+dToS(Mv_Par05) +"' AND '"+dToS(Mv_Par06)+"'"    //Data de entrega
//	cQrySC5 += " AND SC6.C6_ENTREG  BETWEEN '"+dToS(Mv_Par05) +"' AND '"+dToS(Mv_Par06)+"'
EndIf                                                                                     
    
/*
//--Filtra por data de emiss�o da nota fiscal . 
ElseIf cFilt == 2  

	cQrySC5 += " AND SC5.C5_EMISSAO BETWEEN '"+dToS(Mv_Par02) +"' AND '"+dToS(Mv_Par03)+"'"
	cQrySC5 += " AND SC6.C6_DATFAT BETWEEN '"+dToS(Mv_Par04) +"' AND '"+dToS(Mv_Par05)+"'"
	cQrySC5 += " AND SC5.C5_FECENT BETWEEN '"+dToS(Mv_Par06) +"' AND '"+dToS(Mv_Par07)+"'"
//	cQrySC5 += " AND SC6.C6_ENTREG  BETWEEN '"+dToS(Mv_Par05) +"' AND '"+dToS(Mv_Par06)+"'"
EndIf

If MV_PAR10 == 1 //Pedidos entregues
	cQrySC5 += " AND SC6.C6_NOTA <> '' AND C6_SERIE <> '' "
ElseIf MV_PAR10 == 2 //Pedidos n�o entregues
	cQrySC5 += " AND SC6.C6_NOTA = '' AND C6_SERIE = '' AND SC5.C5_NOTA ='' " //Adicionado tratamento Elimmina��o de residuos Davidson-25/10/2016.
ElseIf MV_PAR10 == 3 //Ambos --Adicionado tratamento Elimmina��o de residuos Davidson-28/11/2016.
	cQrySC5 += " AND SC5.C5_NOTA <> 'XXXXXXXXX' " //Adicionado tratamento Elimmina��o de residuos Davidson-25/10/2016.
EndIf																				 
*/

//cQrySC5 += " AND SF4.F4_DUPLIC = 'S' AND SF4.F4_ESTOQUE = 'S' AND SC5.C5_TIPO = 'N'"
cQrySC5 += " ORDER BY SC5.C5_FILIAL, SC5.C5_EMISSAO,  SC5.C5_NUM, SC5.C5_FECENT, SC6.C6_PRODUTO"

cQrySC5 := ChangeQuery(cQrySC5)

MemoWrite("RNUTF01.SQL",cQrySC5)

MsAguarde({|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySC5),cAliasSC5,.T.,.T.)},"Selecionando Registros..." ) //"Selecionando Registros..."


aStru := {}


aadd(aStru,{"CODFILI"	,"C" ,04 ,0})
aadd(aStru,{"DTEMISS"	,"D" ,08 ,0})
aadd(aStru,{"CODVEND"	,"C" ,06 ,0})
aadd(aStru,{"NOMVEND"	,"C" ,30 ,0})
aadd(aStru,{"CLIENTE" 	,"C" ,08 ,0})
aadd(aStru,{"LOJACLI"	,"C" ,04 ,0})
aadd(aStru,{"NOMECLI",	 "C" ,50 ,0})
aadd(aStru,{"CODPROD",	 "C" ,15 ,0})
aadd(aStru,{"DESPROD", 	 "C" ,50 ,0})
//aadd(aStru,{"NTONELAD"	,"C" ,02 ,0})
aadd(aStru,{"PRUNMED"	,"C" ,02 ,0})
aadd(aStru,{"QTDEPUN"	,"N" ,14 ,4})
aadd(aStru,{"QTDESUN"	,"N" ,14 ,4})
aadd(aStru,{"NUMPEDI"	,"C" ,06 ,0})
aadd(aStru,{"MUNENTR"	,"C" ,35 ,0})
aadd(aStru,{"UFENTRE"	,"C" ,02 ,0})
aadd(aStru,{"DTENTRE"	,"D" ,08 ,0})
aadd(aStru,{"MESENTR"	,"C" ,15 ,0})
aadd(aStru,{"CODFISC"	,"C" ,05 ,0})
aadd(aStru,{"PRECUNI"	,"N" ,14 ,2})
//aadd(aStru,{"NTONELAD"	,"N" ,14 ,2})
aadd(aStru,{"VALFRET"	,"N" ,14 ,2})
aadd(aStru,{"VALTOTA"	,"N" ,14 ,2})
aadd(aStru,{"NUMCONT"	,"C" ,06 ,0})
aadd(aStru,{"EMICONT"	,"D" ,08 ,0})
aadd(aStru,{"FINCFOP"	,"C" ,50 ,0})
aadd(aStru,{"NUMNOTA"	,"C" ,50 ,0})
aadd(aStru,{"SERNOTA"	,"C" ,03 ,0})
aadd(aStru,{"DEMINFE"	,"D" ,08 ,0})
aadd(aStru,{"QTDNOTA"	,"N" ,14 ,4})
aadd(aStru,{"PUNNOTA"	,"N" ,14 ,2})
aadd(aStru,{"TOTNOTA"	,"N" ,14 ,2})
aadd(aStru,{"DTEFET"	,"D" ,08 ,0})
aadd(aStru,{"TPFRETE"	,"C" ,15 ,0})
aadd(aStru,{"CMOTO"		,"C" ,30 ,0})
aadd(aStru,{"CPLACA"	,"C" ,15 ,0})                   
aadd(aStru,{"CFROTA"	,"C" ,20 ,0})
aadd(aStru,{"CTIPOV"	,"C" ,15 ,0})
aadd(aStru,{"CTPCAR"	,"C" ,15 ,0})
                        

cArqTrab  := CriaTrab(aStru)
//cIndTrb1 := Left(cArqTrab,7)+"A"

dbUseArea(.T.,, cArqTrab, "RNUTFT", .F., .F. )

IndRegua("RNUTFT",cArqTrab,"CODFILI+DTOS(DTEMISS)+NUMPEDI+DTOS(DTENTRE)+CODPROD",,,"Selecionando Registros...")

dbSelectArea(cAliasSC5)
dbGoTop()

While !  (cAliasSC5)->( Eof() )

	If ! Empty((cAliasSC5)->C6_NOTA)
//		MsgStop("Pedido Faturado")
		cNumNF := ""
		cSerNF := ""
//		cEmiNF := 
		nQtdNF := 0
		nPUnNf := 0
		nTotNf := 0
			
		dbSelectArea("SC9")
		SC9->( dbSetOrder(1) )
		If SC9->( dbSeek((cAliasSC5)->(C6_FILIAL+C6_NUM+C6_ITEM)))
		
	//		MsgStop("Achei a SC9")
			While ! SC9->( Eof() ) .And. SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM) ==  (cAliasSC5)->(C6_FILIAL+C6_NUM+C6_ITEM)
			
					If ! Empty(SC9->C9_NFISCAL)
					//	MsgStop("Loop da SC9")
						cFilc	:=SC9->C9_FILIAL
						cNumNF 	:=SC9->C9_NFISCAL+"/"
						cNumero	:=SC9->C9_NFISCAL
						cSerNF 	:=SC9->C9_SERIENF
						cCliente:=SC9->C9_CLIENTE
						cLoja	:=SC9->C9_LOJA
						cProduto:=SC9->C9_PRODUTO
						
						dbSelectArea("SD2")
						SD2->( dbSetOrder(3) )
						//If SD2->( dbSeek(SC9->(C9_FILIAL+C9_NFISCAL+C9_SERIENF+C9_CLIENTE+C9_LOJA+C9_PRODUTO)))-Davidson 01/09/2016.
						If SD2->(dbSeek(cFilc+cNumero+cSerNF+cCliente+cLoja+cProduto))
						//	MsgStop("Achei a SD2")
							cEmiNF := SD2->D2_EMISSAO //dtoc(SD2->D2_EMISSAO) //dtoc(SD2->D2_EMISSAO)+" - "
							nQtdNF += SD2->D2_QUANT
							nPUnNf := SD2->D2_PRCVEN
							nTotNf += SD2->D2_TOTAL
						EndIF
					EndIf
					
					SC9->( dbSkip() )
			
			End
		
		EndIf
		
	
	Else	
		//MsgStop("Nao FAturado")
		cNumNF := ""
		cSerNF := ""
//		cEmiNF := ""
		nQtdNF := 0
		nPUnNf := 0
		nTotNf := 0
	EndIF

	cMesEntr := Substr((cAliasSC5)->C6_ENTREG,5,2)+"/"+Substr((cAliasSC5)->C6_ENTREG,1,4)
	
	
	If 'S' $ (cAliasSC5)->C5_TPFRETE
	   cTpFrete :="S/Frete"
	ElseIf  'C' $ (cAliasSC5)->C5_TPFRETE 
		 cTpFrete :="CIF"
	ElseIf 'C' $ (cAliasSC5)->C5_TPFRETE
		 cTpFrete :="FOB"     	
	EndIf
		
	dbSelectArea("DA3")
	DA3->( dbSetOrder(1))
	If DA3->(dbSeek(xFilial("DA3")+(cAliasSC5)->C5_VEICULO))
 
		cVeiculo	:=	DA3->DA3_COD
		cCodMotor	:=	DA3->DA3_MOTORI	
		//cFrota    	:=	DA3->DA3_FROVEI
		//cTipCar 	:=	DA3->DA3_ZTPCAR 
		//cTipVeic 	:=	DA3->DA3_TIPVEI 
		 
		//	1=Propria;2=Terceiro;3=Agregado                                                                                                 
		If DA3->DA3_FROVEI == '1'
			cFrota :="Propria"
		ElseIf  DA3->DA3_FROVEI == '2' 
			cFrota :="Terceiro"
		ElseIf DA3->DA3_FROVEI == '3'
			cFrota :="Agregado"     	
		EndIf 
		 
		//Tipo do veiculo                                                                                                 
		If DA3->DA3_TIPVEI == '01'
			cTipVeic :="Carreta Ls"
		ElseIf  DA3->DA3_TIPVEI == '02' 
			cTipVeic :="3/4"
		ElseIf DA3->DA3_TIPVEI == '03'
			cTipVeic :="Truck Toco"    
		ElseIf DA3->DA3_TIPVEI == '04'
			cTipVeic :="Truck"    
		ElseIf DA3->DA3_TIPVEI == '05'
			cTipVeic :="Reboque"    
		ElseIf DA3->DA3_TIPVEI == '06'
			cTipVeic :="Utilitario" 
		EndIf   
		
		//00=Nao aplicavel;01=Aberta;02=Fechada/Bau;03=Granelera;04=Porta Container;05=Sider;06=Aberta;07=Munck;08=Silo                   
		If DA3->DA3_ZTPCAR == '01'
			cTipCar :="Carreta Ls"
		ElseIf  DA3->DA3_ZTPCAR == '02' 
			cTipCar :="3/4"
		ElseIf DA3->DA3_ZTPCAR == '03'
			cTipCar :="Truck Toco"    
		ElseIf DA3->DA3_ZTPCAR == '04'
			cTipCar :="Truck"    
		ElseIf DA3->DA3_ZTPCAR == '05'
			cTipCar :="Reboque"    
		ElseIf DA3->DA3_ZTPCAR == '06'
			cTipCar :="Utilitario" 
		EndIf   
		   
	
	    dbSelectArea("DA4")
		DA4->( dbSetOrder(1))
		If DA4->(dbSeek(xFilial("DA4")+cCodMotor))
		
			cMotor   	:= 	DA4->DA4_NOME	    
	    EndIf  
	EndIf
	
	
	dbSelectArea("ZZ1")
	ZZ1->( dbSetOrder(1))
	If ZZ1->(dbSeek(xFilial("ZZ1")+Padr((cAliasSC5)->C5_SERIE,4)+Alltrim(Padr((cAliasSC5)->C5_NOTA,9))))
    
		dTefetiv	:=ZZ1->ZZ1_DTREC
	EndIf
	
	dbSelectArea("RNUTFT")
	RecLock("RNUTFT",.T.)
		
	Replace CODFILI		With (cAliasSC5)->C5_FILIAL ,;
			DTEMISS		With Stod((cAliasSC5)->C5_EMISSAO) ,;
			CODVEND		With (cAliasSC5)->C5_VEND1 ,;
			NOMVEND		With Posicione('SA3',1,xFilial("SA3")+(cAliasSC5)->C5_VEND1,"A3_NOME") ,;
			CLIENTE		With (cAliasSC5)->C5_CLIENTE ,;
			LOJACLI		With (cAliasSC5)->C5_LOJACLI ,;
			NOMECLI		With Posicione('SA1',1,xFilial("SA1")+(cAliasSC5)->(C5_CLIENTE+C5_LOJACLI),"A1_NOME") ,;
			CODPROD		With (cAliasSC5)->C6_PRODUTO ,;
			DESPROD		With Posicione("SB1",1,xFilial("SB1")+(cAliasSC5)->C6_PRODUTO,"B1_DESC") ,;
			PRUNMED		With (cAliasSC5)->C6_UM ,;
			QTDEPUN		With (cAliasSC5)->C6_QTDVEN ,;
			QTDESUN		With (cAliasSC5)->C6_UNSVEN ,;
			NUMPEDI		With (cAliasSC5)->C5_NUM ,;
			MUNENTR		With Posicione('SA1',1,xFilial("SA1")+(cAliasSC5)->(C5_CLIENTE+C5_LOJACLI),"A1_MUN"),;
			UFENTRE		With Posicione('SA1',1,xFilial("SA1")+(cAliasSC5)->(C5_CLIENTE+C5_LOJACLI),"A1_EST"),;
			DTENTRE		With sTod((cAliasSC5)->C6_ENTREG) ,;
			MESENTR		With cMesEntr ,;
			CODFISC		With (cAliasSC5)->C6_CF ,;
			PRECUNI		With (cAliasSC5)->C6_PRCVEN ,;
			VALFRET		With (cAliasSC5)->C6_C_FRETE ,;
			VALTOTA		With (cAliasSC5)->C6_VALOR ,;
			NUMCONT		With (cAliasSC5)->C6_CONTRAT,;
			EMICONT		With Posicione("ADA",1,(cAliasSC5)->(C6_FILIAL+C6_CONTRAT),"ADA_EMISSA") ,;
			FINCFOP		With Posicione("SF4",1,(cAliasSC5)->(C6_FILIAL+C6_TES),"F4_FINALID") ,;
			NUMNOTA		With cNumNF ,;
			SERNOTA		With cSerNF ,;
			DEMINFE		With cEmiNF ,; 
			QTDNOTA		With nQtdNF ,;
			PUNNOTA		With nPUnNF,;
			TOTNOTA		With nTotNF ,;
			DTEFET		With dTefetiv ,;
			TPFRETE		With cTpFrete ,;
			CMOTO		With cMotor,;
			CPLACA		With (cAliasSC5)->C5_VEICULO,;
			CFROTA		With cFrota,;	
			CTIPOV		With cTipVeic ,; 
			CTPCAR		With cTipCar 
			
		MsUnLock()
		
		nRegTMP++
		
		dbSelectArea(cAliasSC5)
		(cAliasSC5)->( dbSkip() )	
	
Enddo


dbSelectArea(cAliasSC5)
dbCloseArea()

dbSelectArea("RNUTFT")
dbSetOrder(1)
dbGoTop()


Return


Static Function FGrvSA3()
*******************************************************************************
*
**

Local aStru  := {}


aadd(aStru,{"A3_MARK"	,"C" ,02 ,0})
aadd(aStru,{"A3_COD"	,"C" ,06 ,0})
aadd(aStru,{"A3_NOME"	,"C" ,40 ,0})

//MsgStop("Entrei na Funcao GRVSA3")

cArqtSA3  := CriaTrab(aStru)
//cIndTrb1 := Left(cArqTrab,7)+"A"

dbUseArea(.T.,, cArqTSA3, "TRBSA3", .F., .F. )

IndRegua("TRBSA3",cArqTSA3,"A3_COD",,,"Selecionando Registros...")

dbSelectArea('SA3')
SA3->( dbSetOrder(1) )
SA3->( dbGoTop() )

While !  SA3->( Eof() )
		
	//	MsgStop("Gravando Vendedor: "+SA3->A3_COD)
		RecLock("TRBSA3",.T.)

		Replace A3_COD With SA3->A3_COD ,;
				A3_NOME With SA3->A3_NOME
				
				
		MsUnLock()
		
		dbSelectArea("SA3")
		SA3->( dbSkip() )
	
Enddo

	
return


//-------------------------------------------------------------------
/*/{Protheus.doc} Monta Vendedores
Monta Vendedores

@author Davis Magalhaes
@since 12/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------

User Function MatVenCalc(lMostratela,aListaVen,lChkUser,lConsolida,nOpca,nValida)
Local aVensCalc	:= {}
// Variaveis utilizadas na selecao de categorias
Local oChkQual,lQual,oQual,cVarQ
// Carrega bitmaps
Local oOk       := LoadBitmap(GetResources(),"LBOK")
Local oNo       := LoadBitmap(GetResources(),"LBNO")
// Variaveis utilizadas para lista de filiais
Local nx        := 0
Local nAchou    := 0
Local aRetPE	:= {}           
Local lIsBlind  := IsBlind()

Local aAreaSA3	:= SA3->(GetArea())
Local cVersao   := GetVersao() 

Local cSelCNPJIE:=""
local nSelCNPJIE:=0

Default nValida	:= 0 //0=Legado Sele��o Livre
Default lMostraTela	:= .F.
Default aListaVen	:= {{.T., cFilAnt}}  
Default lchkUser	:= .T.
Default lConsolida	:= .F.
Default nOpca		:= 1

//-- Carrega filiais da empresa corrente
dbSelectArea("SA3")
SA3->( dbSetORder(1) )
SA3->( dbGoTop() )

While ! SA3->(EOF()) 
		//-- aEmpresas: contem as filiais que sao permitidas para o acesso do usuario corrente.
	nPos := aScan(aEmpresas,{|x| AllTrim(x) == Alltrim(SA3->A3_COD)})
	If nPos > 0 .Or. IsBlind()
		aAdd(aVensCalc,{.F.,SA3->A3_COD,SA3->A3_NOME})
	EndIf
	SA3->(dbSkip())
End

//-- Monta tela para selecao de filiais
If lMostraTela
	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Cadastro de Vendedores") STYLE DS_MODALFRAME From 145,0 To 445,628 OF oMainWnd PIXEL
		oDlg:lEscClose := .F.
		@ 05,15 TO 125,300 LABEL OemToAnsi("Testestews") OF oDlg  PIXEL
		If lConsolida
			@ 15,20 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi("Codigo"),OemToAnsi("Nome") SIZE 273,105 ON DBLCLICK (aFilsCalc:=MtFClTroca(oQual:nAt,aFilsCalc,nValida,@nSelCNPJIE,@cSelCNPJIE),oQual:Refresh()) NoScroll OF oDlg PIXEL
			bLine := {|| {If(aVensCalc[oQual:nAt,1],oOk,oNo),aVensCalc[oQual:nAt,2],aVensCalc[oQual:nAt,3]}}
		Else
			@ 15,20 CHECKBOX oChkQual VAR lQual PROMPT OemToAnsi("Testes") SIZE 50, 10 OF oDlg PIXEL ON CLICK (AEval(aFilsCalc, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}), oQual:Refresh(.F.))
			@ 30,20 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi("Codigo"),OemToAnsi("Nome")SIZE 273,090 ON DBLCLICK (aFilsCalc:=MtFClTroca(oQual:nAt,aFilsCalc),oQual:Refresh()) NoScroll OF oDlg PIXEL
			bLine := {|| {If(aVensCalc[oQual:nAt,1],oOk,oNo),aVensCalc[oQual:nAt,2],aVensCalc[oQual:nAt,3]}}
		EndIf
		oQual:SetArray(aVensCalc)
		oQual:bLine := bLine
		DEFINE SBUTTON FROM 134,240 TYPE 1 ACTION If(MtFCalOk(@aFilsCalc,.T.,.T.,lConsolida,nValida,@nOpca),oDlg:End(),) ENABLE OF oDlg
		DEFINE SBUTTON FROM 134,270 TYPE 2 ACTION If(MtFCalOk(@aFilsCalc,.F.,.T.,lConsolida,nValida,@nOpca),oDlg:End(),) ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTERED
	
EndIF
SA3->(RestArea(aAreaSA3))
Return aVensCalc

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    � MtFCalOk (Original MA330FOk)                               ���
��������������������������������������������������������������������������Ĵ��
��� Autor     � Microsiga Software S/A                   � Data � 22/01/06 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o � Checa marcacao das filiais para calculo por empresa        ���
��������������������������������������������������������������������������Ĵ��
���Parametros � ExpA1 = Array com a selecao das filiais                    ���
���           � ExpL2 = Valida array de filiais (.t. se ok e .f. se cancel)���
���           � ExpL3 = Mostra tela de aviso no caso de inconsistencia     ���
���           � ExpL4 = Indica se consolida ou n�o o arquivo			   ���
���           � ExpN5 = 0=Legado/1=CNPJ iguais/2=CNPJ+IE iguais/3=CNPJ Raiz���
���           � 4=CNPJ+IE+Inscr.Municipal iguais                           ���
��������������������������������������������������������������������������Ĵ��
���  Uso      � Generico                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function MtFCalOk(aFilsCalc,lValidaArray,lMostraTela,lConsolida,nValida)
Local lRet    	:= .F.
Local nX   	  	:= 0
Local nOpca		:= 0
Local nPos		:= 0
Local aEmpresas := {}

Default lMostraTela := .T.
Default lConsolida	:= .F.
Default nValida		:= 0

If !lValidaArray
	aFilsCalc := {}
	lRet := .T.
Else
	//-- Checa se existe alguma filial marcada na confirmacao
	If !(lRet := aScan(aFilsCalc,{|x| x[1]}) > 0) .And. lMostraTela
		Aviso(OemToAnsi("Teste"),OemToAnsi("Teste"),{"Ok"})
	EndIf

	//-- Se rotina consolidada, valida se todas as filiais da empresa (CNPJ+IE) foram marcadas
	If lRet .And. lConsolida
		For nX := 1 To Len(aFilsCalc)
			If nValida == 1         		// CNPJ Igual
				nPos := aScan(aEmpresas,{|x| x[3] == aFilsCalc[nX,4]})
			ElseIf nValida == 2			// CNPJ + I.E. iguais
				nPos := aScan(aEmpresas,{|x| x[1] == aFilsCalc[nX,4]+aFilsCalc[nX,5]})
			ElseIf nValida == 3			// CNPJ Raiz
				nPos := aScan(aEmpresas,{|x| x[4] == Substr(aFilsCalc[nX,4],1,8)})
			ElseIf nValida == 4			// CNPJ + Insc.Municipal iguais
				nPos := aScan(aEmpresas,{|x| x[5] == aFilsCalc[nX,4]+aFilsCalc[nX,6] })
			Else						// Legado - n�o valida
				nPos := 0
			EndIf
		
			If !Empty(nPos) .And. aFilsCalc[nX,1] # aEmpresas[nPos,2]
				If Empty(nOpca)
					If lMostraTela
						nOpca := Aviso("Aten��o","A execu��o desta rotina foi parametrizada para modo consolidado por�m n�o foram selecionadas todas as filiais de uma ou mais empresas. Deseja que estas filiais sejam adicionadas a sele��o ou mant�m a sele��o atual?",{"Teste 1","Teste 2","Teste 3"},2) //"A execu��o desta rotina foi parametrizada para modo consolidado por�m n�o foram selecionadas todas as filiais de uma ou mais empresas. Deseja que estas filiais sejam adicionadas a sele��o ou mant�m a sele��o atual?"
					Else
						nOpca := 1
					EndIf
				EndIf
				If nOpca == 1
					aEmpresas[nPos,2] := .T.
				Else
					If nOpca == 3
						lRet := .F.
					EndIf
					Exit
				EndIf
			ElseIf Empty(nPos)
				aAdd(aEmpresas,{aFilsCalc[nX,4]+aFilsCalc[nX,5], aFilsCalc[nX,1], aFilsCalc[nX,4], Substr(aFilsCalc[nX,4],1,8), aFilsCalc[nX,4]+aFilsCalc[nX,6] })
			EndIf					
		Next nX
		
		If nOpca == 1
			aFilsCalc := {}
						
			//-- Percorre SM0 adicionando filiais com CNPJ+IE marcados
			SM0->(dbGoTop())
			If nValida < 2         		// CNPJ Igual
				SM0->(dbEval({|| If(aScan(aEmpresas,{|x| M0_CODIGO == cEmpAnt .And. x[3] == M0_CGC .And. x[2]}) == 0,NIL,aAdd(aFilsCalc,{.T.,M0_CODFIL,M0_FILIAL,M0_CGC,M0_INSC,M0_INSCM}))}))
			ElseIf nValida == 2			// CNPJ + I.E. iguais
				SM0->(dbEval({|| If(aScan(aEmpresas,{|x| M0_CODIGO == cEmpAnt .And. x[1] == M0_CGC+M0_INSC .And. x[2]}) == 0,NIL,aAdd(aFilsCalc,{.T.,M0_CODFIL,M0_FILIAL,M0_CGC,M0_INSC,M0_INSCM}))}))
			ElseIf nValida == 3			// CNPJ Raiz
				SM0->(dbEval({|| If(aScan(aEmpresas,{|x| M0_CODIGO == cEmpAnt .And. x[4] == SubStr(M0_CGC,1,8) .And. x[2]}) == 0,NIL,aAdd(aFilsCalc,{.T.,M0_CODFIL,M0_FILIAL,M0_CGC,M0_INSC,M0_INSCM}))}))
			ElseIf nValida == 4			// CNPJ + Insc.Municipal iguais
				SM0->(dbEval({|| If(aScan(aEmpresas,{|x| M0_CODIGO == cEmpAnt .And. x[5] == M0_CGC+M0_INSCM .And. x[2]}) == 0,NIL,aAdd(aFilsCalc,{.T.,M0_CODFIL,M0_FILIAL,M0_CGC,M0_INSC,M0_INSCM}))}))
			EndIf
			
			//-- Ordena por CNPJ+IE+Ins.Mun+Codigo para facilitar a quebra da rotina
			aSort(aFilsCalc,,,{|x,y| x[4]+x[5]+x[6]+x[2] < y[4]+y[5]+x[6]+y[2]})
			
		ElseIf nOpca # 3
			//-- Deleta filiais que nao serao processadas
			nX := 1
			While nX <= Len(aFilsCalc)
				If !aFilsCalc[nX,1]
					aDel(aFilsCalc,nX)
					aSize(aFilsCalc,Len(aFilsCalc)-1)
				Else
					nX++
				EndIf
			End
		EndIf
	EndIf	
EndIf

Return lRet

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    � MtFClTroca(Original CA330Troca)                            ���
��������������������������������������������������������������������������Ĵ��
��� Autor     � Microsiga Software S/A                   � Data � 12/01/06 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o � Troca marcador entre x e branco                            ���
��������������������������������������������������������������������������Ĵ��
���Parametros � ExpN1 = Linha onde o click do mouse ocorreu                ���
���           � ExpA2 = Array com as opcoes para selecao                   ���
���           � ExpN3 = Valida sele��o de CNPJ/IE na fun��o MatFilCalc     ��� 
���           � 0=Legado n�o Valida / 1=CNPJ / 2=CNPJ+IE / 3=CNPJ Raiz     ���
���           � 4=CNPJ+IE+Insc.Municipal 							       ���
���           � ExpN4 = Quantidade de Itens marcados - CNPJ/IE iguais      ���
���           � ExpC5 = CNPJ/IE selecionado                                ���
��������������������������������������������������������������������������Ĵ��
���  Uso      � Protheus 8.11                                              ���
���������������������������������������������������������������������������ٱ�
���05/08/2013 � Wagner Montenegro 										   ���
���			  � Adicionado os parametros ExpL3,ExpN4,ExpC5 para permitir   ���
���			  � sele��o apenas de CNPJ/IE iguais na fun��o MatFilCalc	   ���
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function MtFClTroca(nIt,aArray,nValida,nSelCNPJIE,cSelCNPJIE)
Default nValida := 0 	//1= Valida apenas CNPJ com mesmo numero MatFilCalc() / 2=Valida apenas CNPJ+IE com mesmo numero MatFilCalc()
						//3= Valida CNPJ Raiz (8 primeiros d�gitos) com mesmo n�mero/ 4= Valida CNPJ+IE+Insc.Municipal com mesmo n�mero
If nValida == 0
	aArray[nIt,1] := !aArray[nIt,1]
Else
	If aArray[nIt,1]
	   	nSelCNPJIE--
		If nSelCNPJIE==0
 	   		cSelCNPJIE:=""
		Endif
		aArray[nIt,1] := !aArray[nIt,1]
	Else
 		If nSelCNPJIE > 0
 	    	If ( nValida==1 .and. aArray[nIt,4]==cSelCNPJIE ) .or. ( nValida==2 .and. aArray[nIt,4]+aArray[nIt,5]==cSelCNPJIE ) .or.;
 	    		( nValida==3 .and. Substr(aArray[nIt,4],1,8) == Substr(cSelCNPJIE,1,8) ) .or. ( nValida==4 .and. aArray[nIt,4]+aArray[nIt,6] == cSelCNPJIE )
	 	   		nSelCNPJIE++
		 	   	aArray[nIt,1] := !aArray[nIt,1]
	 	  	Else
	 	  		If nValida == 1 
	 	  			//'SIGACUSCNPJ' ; 'A Consolida��o por CNPJ est� habilitado. Selecione apenas Filiais com o mesmo CNPJ [' ; '] j� marcado, ou refa�a sua sele��o!'
		 	  		Help(nil,1," ddd",nil,"dddd"+Transform(cSelCNPJIE,"@R 99.999.999/9999-99")+"dddd",3,0)
		 	  	ElseIf nValida == 2
		 	  	   //'SIGACUSCNPJIE' ; 'A Consolida��o por CNPJ+IE est� habilitado. Selecione apenas Filiais com o mesmo CNPJ+IE [' ; '] j� marcado, ou refa�a sua sele��o!'
		 	  		Help(nil,1,'SIGACUSCNPJIE',nil,'A Consolida��o por CNPJ+IE est� habilitado. Selecione apenas Filiais com o mesmo CNPJ+IE ['+Transform(Substr(cSelCNPJIE,1,14),"@R 99.999.999/9999-99")+" - "+Substr(cSelCNPJIE,15)+'] j� marcado, ou refa�a sua sele��o!',3,0)
		 	  	ElseIf nValida == 3
					//'SIGACUSCNPJP' ; 'A Consolida��o por CNPJ Raiz est� habilitado. Selecione apenas Filiais com o mesmo CNPJ Raiz [' ; '] j� marcado, ou refa�a sua sele��o!'
					Help(nil,1,"Teste",nil,"Teste"+Transform(Substr(cSelCNPJIE,1,8),"@R 99.999.999")+" - "+Substr(cSelCNPJIE,15)+"Teste",3,0)
		 	  	Else	
					//'SIGACUSCNPJIM' ; 'A Consolida��o por CNPJ + Insc.Municiap est� habilitado. Selecione apenas Filiais com o mesmo CNPJ e Inscri��o Municipal [' ; '] j� marcado, ou refa�a sua sele��o!'
					Help(nil,1,"Teste",nil,"CNPJ: "+Transform(Substr(cSelCNPJIE,1,14),"@R 99.999.999/9999-99")+" - "+Substr(cSelCNPJIE,15)+"Teste",3,0)
		 	  	Endif
	 	   	Endif
		Else
			nSelCNPJIE++ 
			If nValida==1									// Valida CNPJ 
				cSelCNPJIE := aArray[nIt,4]
			ElseIf nValida ==2								// Valida CNPJ + I.E.
				cSelCNPJIE := aArray[nIt,4]+aArray[nIt,5]
			ElseIf nValida ==3								// Valida CNPJ Raiz (oito primeiros d�gitos)
				cSelCNPJIE := Subs(aArray[nIt,4],1,8)
			Else											// Valida CNPJ + Insc.Municipal
				cSelCNPJIE := aArray[nIt,4]+aArray[nIt,6]
			Endif
			aArray[nIt,1] := !aArray[nIt,1]
 		Endif
 	Endif
Endif 	   	
Return aArray


/*
========================================================================================================================
Rotina----: FAtuDados
Autor-----: Davidson Nutratta
Data------: 12/04/2018
========================================================================================================================
Descri��o-: Atualiza as datas de entrega antes da emiss�o do relatorio
Uso-------: Especifico faturamento.
========================================================================================================================
*/
Static Function FAtuDados()

Local cQuery := ""

cQuery += " UPDATE C6 " 
cQuery += " SET C6.C6_ENTREG = C5.C5_FECENT"
cQuery += " FROM SC6010 C6" 
cQuery += " INNER JOIN SC5010 C5
cQuery += " ON C5.C5_NUM=C6.C6_NUM AND C5.C5_FILIAL=C6.C6_FILIAL 
cQuery += " WHERE C5.D_E_L_E_T_<>'*'
cQuery += " AND C6.D_E_L_E_T_<>'*'

TcSqlExec(cQuery) 
 
Return
 







