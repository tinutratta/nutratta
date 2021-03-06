#INCLUDE "RWMAKE.CH"          
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "topconn.ch"      
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#include 'parmtype.ch'
Static __aUserLg := {}

//--------------------------------------------------------------------------
/* {Protheus.doc} RFIN05
Relatorio de extrato de comissionamento.

Empresa - Copyright -Nutratta Nutri��o Animal.
@author Davidson Clayton
@since 13/03/2017
@version P11 R8
*/
//--------------------------------------------------------------------------  
User Function RFIN05()      

Local oReport

Private nRegTmp   := 0
Private cArqTrab  := ""
Private cIndTrb1  := Space(08)
Private cArqTSA3  := ""
Private cIndTSA3  := Space(08)
Private cArqTSM0  := ""
Private cIndTSM0  := Space(08)
Private aColunas  := {}

//-- Interface de impressao
oReport := ReportDef()
oReport:PrintDialog() 	                  

Return


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Davidson Clayton     � Data �09/02/2017  ���
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
30/04/2020- Criar um campo no relat�rio para trazer o conteduo C5_C_INFAD
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
oReport:= TReport():New("RFIN05","Extrato de comissionamento","RFIN05", {|oReport| ReportPrint(oReport)},"Extrato de comissionamento.") 
oReport:SetLandscape()
//oReport:SetTotalInLine(.F.)

// -- Ajustas as Perguntas
AjustaSX1("RFIN05")
 
Pergunte(oReport:uParam,.F.)

//oSection1 := TRSection():New(oReport,"Relacao de Faturamento por Filial",{"SF2","DTC","SE4","DA3","DA4" }) 
oSection1 := TRSection():New(oReport,"Extrato de comissionamento") 
oSection1 :SetTotalInLine(.F.)
oSection1 :SetHeaderPage()
oSection1 :SetTotalText("Total Geral") //"Total Geral "

TRCell():New(oSection1,"CCODFIL"	,"","Filial"		 ,"@!"	  					,04,/*lPixel*/	,{|| cCodFili })
TRCell():New(oSection1,"CNOTA"		,"","Nota"			 ,"@!"	  					,09,/*lPixel*/	,{|| cNum })  
TRCell():New(oSection1,"CPEDIDO"	,"","Pedido"		 ,"@!"	  					,06,/*lPixel*/	,{|| cPedido })
TRCell():New(oSection1,"DEMISSAO"	,"","Emissao"     	 ,"@!"   					,10,/*lPixel*/	,{|| dEmissao })
TRCell():New(oSection1,"CTABELA"	,"","Tabela"		 ,"@!"	  					,04,/*lPixel*/	,{|| cTabela })
TRCell():New(oSection1,"CDESTAB"	,"","Desc"		  	 ,"@!"	  					,04,/*lPixel*/	,{|| cDescTab })
TRCell():New(oSection1,"DVIGEN"		,"","Vigencia"   	 ,"@!"   					,10,/*lPixel*/	,{|| dVigencia })
TRCell():New(oSection1,"CLIENTE"	,"","Cliente"		 ,"@!"	  					,10,/*lPixel*/	,{|| cCliente })
TRCell():New(oSection1,"CLOJA"		,"","Loja"		 	 ,"@!"	  					,10,/*lPixel*/	,{|| cLoja }) 
TRCell():New(oSection1,"CNOMCLI"	,"","Nome"		 	 ,"@!"	  					,60,/*lPixel*/	,{|| cNomCli })
TRCell():New(oSection1,"CEST"		,"","UF"		  	 ,"@!"	  					,02,/*lPixel*/	,{|| cUF })
TRCell():New(oSection1,"CSUPER"		,"","Supervisor"  	 ,"@!"	  					,06,/*lPixel*/	,{|| cSup })
TRCell():New(oSection1,"CNOMSUP"	,"","Nome"	  		 ,"@!"	  					,40,/*lPixel*/	,{|| cNomSup })
TRCell():New(oSection1,"CVEND"		,"","Vendedor"	  	 ,"@!"	  					,06,/*lPixel*/	,{|| cVende })
TRCell():New(oSection1,"CNOMVE"		,"","Nome"	  		 ,"@!"	  					,40,/*lPixel*/	,{|| cNomVend })
TRCell():New(oSection1,"CCODIGO"	,"","Codigo"		 ,"@!"	  					,15,/*lPixel*/	,{|| cCodigo })
TRCell():New(oSection1,"CDESCR"		,"","Descri��o"		 ,"@!"	  					,60,/*lPixel*/	,{|| cDescri��o })
TRCell():New(oSection1,"CCOND"		,"","Cond.pgto"		 ,"@!"	  					,03,/*lPixel*/	,{|| cCondicao })
TRCell():New(oSection1,"CDESCOND"	,"","Descri��o"		 ,"@!"	  					,15,/*lPixel*/	,{|| cDescri��o})
TRCell():New(oSection1,"NQTDPARC"	,"","Qtd.Parc"		 ,"@E 999"					,11,/*lPixel*/	,{|| nQtdParc})
TRCell():New(oSection1,"NQUANT"		,"","Quant"			 ,"@E 9,999,999.999"		,11,/*lPixel*/	,{|| nQuant})
TRCell():New(oSection1,"NPRCVEN"	,"","Prec.Unit"		 ,"@E 999,999,999.99"		,12,/*lPixel*/	,{|| nPreco })
TRCell():New(oSection1,"NVFRET"		,"","Vlr.Frete"		 ,"@E 999,999,999.99"		,12,/*lPixel*/	,{|| nVlrfrete })
TRCell():New(oSection1,"NTOTFR"		,"","Tot.Frete"		 ,"@E 999,999,999.99"		,12,/*lPixel*/	,{|| nTotFrete })
TRCell():New(oSection1,"NVALOR"		,"","Vlr.Total"		 ,"@E 999,999,999.99"		,12,/*lPixel*/	,{|| nvlrTot })
TRCell():New(oSection1,"NTRIB"		,"","Imposto"		 ,"@E 9,999,999.9999"	    ,9,/*lPixel*/	,{|| nImposto })
TRCell():New(oSection1,"NPENCAR"	,"","%Encarg"		 ,"@E 99.999"				,06,/*lPixel*/	,{|| nPerEnc }) 
TRCell():New(oSection1,"NVALENC"	,"","Vlr.Encarg"	 ,"@E 999,999,999.99"		,12,/*lPixel*/	,{|| nValEnc })
TRCell():New(oSection1,"CNPARC"		,"","Parcela"		 ,"@!"	  					,02,/*lPixel*/	,{|| cNum })
TRCell():New(oSection1,"NVALORG"	,"","Vlr.Orig"		 ,"@E 999,999,999.99"		,12,/*lPixel*/	,{|| cVlrOrig })
TRCell():New(oSection1,"DVENC"		,"","Venc.Orig"    	 ,"@!"   					,10,/*lPixel*/	,{|| dVencOrig })
TRCell():New(oSection1,"NVALBX"		,"","Vlr.Baixa"		 ,"@E 999,999,999.99"		,12,/*lPixel*/	,{|| cVlrBaixa })
TRCell():New(oSection1,"DBAIXA"		,"","Dt.Baixa"    	 ,"@!"   					,10,/*lPixel*/	,{|| dBaixa })
TRCell():New(oSection1,"BXPROP"		,"","%Baixa"    	 ,"@!"   					,05,/*lPixel*/	,{|| cPerBaixa }) 
TRCell():New(oSection1,"NBASE"		,"","Base"			 ,"@E 999,999,999.99"		,12,/*lPixel*/	,{|| nBase })
TRCell():New(oSection1,"NPERCO"		,"","%"				 ,"@E 99.999"				,05,/*lPixel*/	,{|| nPerc })
TRCell():New(oSection1,"NCOMISS"	,"","Vlr.Comissao"	 ,"@E 999,999,999.99"		,12,/*lPixel*/	,{|| vlrComiss })
TRCell():New(oSection1,"MOTBX"		,"","Banco Baixa"    ,"@!"						,03,/*lPixel*/	,{|| mtbx })
TRCell():New(oSection1,"BXANT"		,"","Motivo Baixa"   ,"@!"						,03,/*lPixel*/	,{|| mtAnt }) 
TRCell():New(oSection1,"TBL"		,"","Tabela ZZZ"     ,"@!"						,60,/*lPixel*/	,{|| mtAnt }) 
TRCell():New(oSection1,"TIPDOC"		,"","TipDoc"         ,"@!"						,02,/*lPixel*/	,{|| TpDoc })
TRCell():New(oSection1,"SITUA"		,"","Situacao"       ,"@!"						,01,/*lPixel*/	,{|| Situac })  
TRCell():New(oSection1,"INFO"		,"","Inf.Adicionais" ,"@!"						,60,/*lPixel*/	,{|| cInfo })

Return(oReport)



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Davidson Clayton     � Data �09.02.2016���
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
Private cFilt		:= ""

MsAguarde({ ||FGrvTmp05() }, "Criando Arquivo de Trabalho...")  //-- Chamada da Funcao de Arquivo Temporarios

oReport:SetTitle( oReport:Title()) // " - POR NUMERO"

dbSelectArea("RFIN05")
dbSetOrder(01)
dbGoTop()

oReport:SetMeter( nRegTMP )
oSection1:Init()


While ! oReport:Cancel() .And. ! RFIN05->( Eof() )
	
	
	If oReport:Cancel()
		
		Exit
		
	EndIf
	
	oReport:IncMeter()
	
	oSection1:Cell("CCODFIL"):SetValue(RFIN05->CCODFIL)
	oSection1:Cell("CNOTA"):SetValue(RFIN05->CNOTA)        
	oSection1:Cell("CPEDIDO"):SetValue(RFIN05->CPEDIDO)
	oSection1:Cell("DEMISSAO"):SetValue(RFIN05->DEMISSAO)
	oSection1:Cell("CTABELA"):SetValue(RFIN05->CTABELA)
	oSection1:Cell("CDESTAB"):SetValue(RFIN05->CDESTAB) 
	oSection1:Cell("DVIGEN"):SetValue(RFIN05->DVIGEN)	
	oSection1:Cell("CLIENTE"):SetValue(RFIN05->CLIENTE)
	oSection1:Cell("CLOJA"):SetValue(RFIN05->CLOJA)
	oSection1:Cell("CNOMCLI"):SetValue(RFIN05->CNOMCLI)    
	oSection1:Cell("CEST"):SetValue(RFIN05->CEST)
	oSection1:Cell("CSUPER"):SetValue(RFIN05->CSUPER)
	oSection1:Cell("CNOMSUP"):SetValue(RFIN05->CNOMSUP)
	oSection1:Cell("CVEND"):SetValue(RFIN05->CVEND)
	oSection1:Cell("CNOMVE"):SetValue(RFIN05->CNOMVE)
	oSection1:Cell("CCODIGO"):SetValue(RFIN05->CCODIGO)
	oSection1:Cell("CDESCR"):SetValue(RFIN05->CDESCR)
	oSection1:Cell("CCOND"):SetValue(RFIN05->CCOND)
	oSection1:Cell("CDESCOND"):SetValue(RFIN05->CDESCOND) 
	oSection1:Cell("NQTDPARC"):SetValue(RFIN05->NQTDPARC)
	oSection1:Cell("NQUANT"):SetValue(RFIN05->NQUANT)
	oSection1:Cell("NPRCVEN"):SetValue(RFIN05->NPRCVEN)
	oSection1:Cell("NVFRET"):SetValue(RFIN05->NVFRET)
	oSection1:Cell("NTOTFR"):SetValue(RFIN05->NTOTFR)
	oSection1:Cell("NVALOR"):SetValue(RFIN05->NVALOR)
	oSection1:Cell("NTRIB"):SetValue(RFIN05->NTRIB)
	oSection1:Cell("NTRIB"):SetValue(RFIN05->NTRIB)
	oSection1:Cell("CNPARC"):SetValue(RFIN05->CNPARC) 	
	oSection1:Cell("NVALORG"):SetValue(RFIN05->NVALORG) 	
	oSection1:Cell("DVENC"):SetValue(RFIN05->DVENC) 	
	oSection1:Cell("NVALBX"):SetValue(RFIN05->NVALBX) 
   	oSection1:Cell("DBAIXA"):SetValue(RFIN05->DBAIXA)      
   	oSection1:Cell("BXPROP"):SetValue(RFIN05->BXPROP)      
	oSection1:Cell("NBASE"):SetValue(RFIN05->NBASE)
	oSection1:Cell("NPERCO"):SetValue(RFIN05->NPERCO)
	oSection1:Cell("NCOMISS"):SetValue(RFIN05->NCOMISS)
	oSection1:Cell("NPENCAR"):SetValue(RFIN05->NPENCAR) 
	oSection1:Cell("NVALENC"):SetValue(RFIN05->NVALENC)  
	oSection1:Cell("MOTBX"):SetValue(RFIN05->MOTBX)  
	oSection1:Cell("BXANT"):SetValue(RFIN05->BXANT) 
	oSection1:Cell("TBL"):SetValue(RFIN05->TBL) 
	oSection1:Cell("TIPDOC"):SetValue(RFIN05->TIPDOC)
	oSection1:Cell("SITUA"):SetValue(RFIN05->SITUA)
	oSection1:Cell("INFO"):SetValue(RFIN05->INFO)
	
	oSection1:PrintLine()
	
	dbSelectArea("RFIN05")
	RFIN05->( dbSkip())
	
End

//oSecTion1:Print()

oSection1:Finish()

dbSelectArea("RFIN05")
dbCloseArea()

Return NIL


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  FGrvTmp05 � Autor � Davidson       � Data �18.10.2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava��o da tabela temporaria                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function FGrvTmp05(lSelFil,lSelVen)
*******************************************************************************
*
**
Local cEol   	:= ""
Local cQuery 	:= ""
Local aStru  	:= {}
Local cTipoRel := 2
Local aColunas := {}
Local cAliasZZA:= GetNextAlias()
Local cQrySZZA  := ""


cQrySZZA := " SELECT * FROM "+RetSqlName("ZZA")+" ZA"
cQrySZZA += " WHERE ZA.D_E_L_E_T_ <> '*' "
cQrySZZA += " AND ZA.ZZA_FILIAL <> '0201' " 	
cQrySZZA += " AND ZA.ZZA_DTBAIX BETWEEN '"+dToS(Mv_Par01) +"' AND '"+dToS(Mv_Par02)+"'"	
cQrySZZA += " AND ZA.ZZA_VEND BETWEEN '"+Mv_Par03 +"' AND '"+Mv_Par04+"'"	

cQrySZZA := ChangeQuery(cQrySZZA)

MemoWrite("RFIN05.SQL",cQrySZZA)

MsAguarde({|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySZZA),cAliasZZA,.T.,.T.)},"Selecionando Registros..." ) //"Selecionando Registros..."


aStru := {}

aadd(aStru,{"CCODFIL"	,"C" ,04 ,0})
aadd(aStru,{"CNOTA"		,"C" ,09 ,0})
aadd(aStru,{"CPEDIDO"	,"C" ,06 ,0})
aadd(aStru,{"DEMISSAO"	,"D" ,08 ,0})            
aadd(aStru,{"CTABELA"	,"C" ,03 ,0})
aadd(aStru,{"CDESTAB"	,"C" ,40 ,0})
aadd(aStru,{"DVIGEN"	,"D" ,08 ,0})
aadd(aStru,{"CLIENTE"	,"C" ,09 ,0})
aadd(aStru,{"CLOJA"		,"C" ,04 ,0})
aadd(aStru,{"CNOMCLI"	,"C" ,60 ,0})
aadd(aStru,{"CEST"		,"C" ,02 ,0})
aadd(aStru,{"CSUPER"	,"C" ,06 ,0})
aadd(aStru,{"CNOMSUP"	,"C" ,40 ,0})
aadd(aStru,{"CVEND"		,"C" ,06 ,0})
aadd(aStru,{"CNOMVE"	,"C" ,40 ,0})
aadd(aStru,{"CCODIGO"	,"C" ,15 ,0})
aadd(aStru,{"CDESCR"	,"C" ,60 ,0})
aadd(aStru,{"CCOND"		,"C" ,03 ,0})
aadd(aStru,{"CDESCOND"	,"C" ,15 ,0})  
aadd(aStru,{"NQTDPARC"	,"C" ,02 ,0})
aadd(aStru,{"NQUANT"	,"N" ,11 ,3})
aadd(aStru,{"NPRCVEN"	,"N" ,12 ,4})
aadd(aStru,{"NVFRET"	,"N" ,09 ,2})
aadd(aStru,{"NTOTFR"	,"N" ,12 ,4})
aadd(aStru,{"NVALOR"	,"N" ,12 ,2})
aadd(aStru,{"NTRIB"		,"N" ,12 ,4})
aadd(aStru,{"NPENCAR"	,"N" ,12 ,4})
aadd(aStru,{"CNPARC"	,"C" ,02 ,0})
aadd(aStru,{"NVALORG"	,"N" ,12 ,4})
aadd(aStru,{"DVENC"		,"D" ,08 ,0})
aadd(aStru,{"NVALBX"	,"N" ,12 ,4})
aadd(aStru,{"DBAIXA"	,"D" ,08 ,0})
aadd(aStru,{"BXPROP"	,"N" ,05 ,0})
aadd(aStru,{"NBASE"		,"N" ,12 ,2})
aadd(aStru,{"NVALENC"	,"N" ,12 ,2})
aadd(aStru,{"NPERCO"	,"N" ,06 ,3})
aadd(aStru,{"NCOMISS"	,"N" ,12,2})
aadd(aStru,{"MOTBX"		,"C" ,03,0})  
aadd(aStru,{"BXANT"		,"C" ,03,0})
aadd(aStru,{"TBL"		,"C" ,60,0})
aadd(aStru,{"TIPDOC"	,"C" ,02,0})
aadd(aStru,{"SITUA"		,"C" ,01,0})                                    
aadd(aStru,{"INFO"		,"C" ,60,0}) 
                        
cArqTrab  := CriaTrab(aStru)
//cIndTrb1 := Left(cArqTrab,7)+"A"

dbUseArea(.T.,, cArqTrab, "RFIN05", .F., .F. )

IndRegua("RFIN05",cArqTrab,"CCODFIL",,,"Selecionando Registros...")

dbSelectArea(cAliasZZA)
dbGoTop()

While !  (cAliasZZA)->( Eof() )
		
	dbSelectArea("RFIN05")
	RecLock("RFIN05",.T.)
	
	Replace CCODFIL		With (cAliasZZA)->(ZZA_FILIAL)
	Replace CNOTA		With (cAliasZZA)->(ZZA_NOTA)
	Replace CPEDIDO		With (cAliasZZA)->(ZZA_NUM)
	Replace DEMISSAO	With Stod((cAliasZZA)->ZZA_EMISSAO) 
	Replace CTABELA		With (cAliasZZA)->(ZZA_TABELA)  
	Replace CDESTAB		With (cAliasZZA)->(ZZA_DESTAB) 
	Replace DVIGEN		With Stod((cAliasZZA)->ZZA_VIGENC)	 
 	Replace CLIENTE		With (cAliasZZA)->(ZZA_CLIENT)  
	Replace CLOJA		With (cAliasZZA)->(ZZA_LOJA)
	Replace CNOMCLI		With Posicione("SA1",1,xFilial("SA1")+(cAliasZZA)->(ZZA_CLIENT)+(cAliasZZA)->(ZZA_LOJA),"A1_NOME")
	Replace CEST		With (cAliasZZA)->(ZZA_EST)
	Replace CSUPER		With (cAliasZZA)->(ZZA_CODSUP)
	Replace CNOMSUP		With (cAliasZZA)->(ZZA_SUPER)
	Replace CVEND		With (cAliasZZA)->(ZZA_VEND)
	Replace CNOMVE		With (cAliasZZA)->(ZZA_NOME)
	Replace CCODIGO		With (cAliasZZA)->(ZZA_CODIGO)
	Replace CDESCR		With (cAliasZZA)->(ZZA_DESCRI)
	Replace CCOND		With (cAliasZZA)->(ZZA_COND)
	Replace CDESCOND	With (cAliasZZA)->(ZZA_DESC)
	Replace NQTDPARC	With (cAliasZZA)->(ZZA_PARC)
	Replace NQUANT		With (cAliasZZA)->(ZZA_QUANT)
	Replace NPRCVEN		With (cAliasZZA)->(ZZA_PRCVEN)
	Replace NVFRET		With (cAliasZZA)->(ZZA_VFRETE)
	Replace NTOTFR		With (cAliasZZA)->(ZZA_QUANT) * (cAliasZZA)->(ZZA_VFRETE) //(cAliasZZA)->(ZZA_TOTFRT)	
	Replace NVALOR		With (cAliasZZA)->(ZZA_VALOR)
	Replace NTRIB		With (cAliasZZA)->(ZZA_TRIB) 
	Replace NPENCAR		With (cAliasZZA)->(ZZA_PERENC)    
	Replace NVALENC		With (cAliasZZA)->(ZZA_VALENC)	
	Replace CNPARC		With StrZero(Val((cAliasZZA)->(ZZA_NUMPAR)),2)	 
	Replace NVALORG		With (cAliasZZA)->(ZZA_VALORG)	
	Replace DVENC		With Stod((cAliasZZA)->ZZA_VENORI)
	Replace NVALBX		With (cAliasZZA)->(ZZA_VLBAIXA)
	Replace DBAIXA		With Stod((cAliasZZA)->ZZA_DTBAIX) 
	Replace BXPROP		With Round((cAliasZZA)->(ZZA_BXPROP),0)
	Replace NBASE		With (cAliasZZA)->(ZZA_BASE) 
	Replace NPERCO		With (cAliasZZA)->(ZZA_PERCO) 
	Replace NCOMISS 	With (cAliasZZA)->(ZZA_COMISS)    
	Replace MOTBX	 	With (cAliasZZA)->(ZZA_MOTBX)
	Replace BXANT	 	With (cAliasZZA)->(ZZA_BXANT)
	Replace TBL			With (cAliasZZA)->(ZZA_TBLZZ)   
	Replace TIPDOC		With (cAliasZZA)->(ZZA_TPDOC)   
	Replace SITUA		With (cAliasZZA)->(ZZA_SITUA)  
	Replace INFO		With Posicione("SC5",1,xFilial("SC5")+(cAliasZZA)->(ZZA_NUM),"C5_C_INFAD")  
	
	 		
	MsUnLock()
	nRegTMP++

	cMesEntr := Substr((cAliasZZA)->ZZA_EMISSAO,5,2)+"/"+Substr((cAliasZZA)->ZZA_EMISSAO,1,4)

dbSelectArea(cAliasZZA)	
(cAliasZZA)->( dbSkip())
Enddo

dbSelectArea(cAliasZZA)
dbCloseArea()


dbSelectArea("RFIN05")
dbSetOrder(1)
dbGoTop()

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �AjustaSX1 � Autor � Davidson Clayton    � Data �18.10.2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta perguntas no SX1.                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function AjustaSx1(cPerg)

//--Tipo Filtro Emissao Nfe ou Pedido de vendas - Davidson 09/12/2016 
//PutSx1(cPerg,"11","Filtra por  ?" ," "," "   ,"mv_ch10","N",1,0,1,"C","","","","","mv_par10","Entregues","S�","Yes","","N�o Entregues","No","No","Ambos","Ambos","Ambos","","","","","","")

PutSx1(cPerg,"01","Baixa de  ?"     ," "," ","mv_ch1","D",8,0,0,"G","",""   	,,,"mv_par01")  //"ID do processo"
PutSx1(cPerg,"02","Baixa ate ?"     ," "," ","mv_ch2","D",8,0,0,"G","",""   	,,,"mv_par02")  //"ID do processo"
PutSx1(cPerg,"03","Vendedor de  ?"     ," "," ","mv_ch3","C",6,0,0,"G","","SA3" 	,,,"mv_par03")  //"ID do processo"
PutSx1(cPerg,"04","Vendedor ate ?"     ," "," ","mv_ch3","C",6,0,0,"G","","SA3"  ,,,"mv_par04")  //"ID do processo"

Return



