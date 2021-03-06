#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"


//------------------------------------------------------------------+

/*/{Protheus.doc} RRPA001()
Relatorio de RPA Nutratta
@author 	Davis Magalhaes
@since 		31/08/2015
@version 	P11 R5
@param   	n/t
@return  	n/t
@obs        Programa Especifico para Nutratta
/*/
//------------------------------------------------------------------+

User Function RRPA001()

Local   nOpca  := 0                      
Private cPerg := "RRPA001"
Private cAliasSE2 := ""               
Private nRegSE2   := 0
Private oRPA		

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Ajustar perguntas do SX1	   			  				     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
//AjustaSX1(cPerg)

//Pergunte(cPerg,.F.)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Tela de configuracao do Relatorio			         	     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸


nOpca := Aviso("Nutratta","Deseja Emitir o Recibo de Pagamento de Autonomo - RPA. ?",{"Emitir","Sair"},2,"Contrato: "+DTY->DTY_NUMCTC)

/*
DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Recibo de Pagamento de Autonomo") PIXEL    //"Medicoes"
@ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
@ 29, 15 SAY OemToAnsi("Este relatorio ira emitir Recibo(s) de Pagamento de Autonomo(s) - RPA'(s) ") SIZE 268, 8 OF oDlg PIXEL    //"Este relatorio ira emitir uma relacao de medicoes, exibindo suas respectivas"
@ 38, 15 SAY OemToAnsi("de acordo com os paramentros definidos nas perguntas, j� considerando") SIZE 268, 8 OF oDlg PIXEL    //"multas/bonificacoes, descontos e caucoes retidas. Favor verificar os  "
@ 48, 15 SAY OemToAnsi("Impostos e Descontos Diversos") SIZE 268, 8 OF oDlg PIXEL    //"parametros do relatorio.."
DEFINE SBUTTON FROM 80, 190 TYPE 5 ACTION Pergunte(cPerg,.T.) ENABLE OF oDlg
DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
DEFINE SBUTTON FROM 80, 255 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTER
  */
If nOpca == 1
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Processamento do Relatorio						             �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	
	MsAguarde( { || RRPA01Prc(DTY->DTY_NUMCTC,DTY->DTY_CODFOR, DTY->DTY_LOJFOR, DTY->DTY_DATCTC) },,"Selecionando Registros...")
	
	If nRegSE2 > 0
	    
		RptStatus({|lEnd| RRPA01Imp(@lEnd)})
		
	Else
		MsgAlert("Nao foi encontrado nenhum registro para gerar Relatorio. Favor conferir os Parametros.")
	EndIf
EndIf

Return Nil                                                     
                           

//------------------------------------------------------------------+

/*/{Protheus.doc} RRPA01Prc()
Processando Query
@author 	Davis Magalhaes
@since 		31/08/2015
@version 	P11 R5
@param   	n/t
@return  	n/t
@obs        Programa Especifico para Nutratta
/*/
//------------------------------------------------------------------+
      
Static Function RRPA01Prc(cNumCTC,cCodFor,cLojFor,dDatCtc)              
                 
Local cQuery 	:= ""                            
Local cTipCTC   := Padr("TF",Len(SE2->E2_TIPO) )//Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )    // Tipo Contrato de Carreteiro 
Local cPrefix 	:= "MAN" //SuperGetMv("MV_CTCPREF",.F.,'')


cAliasSE2 := GetNextAlias()

cQuery := "SELECT * FROM "+RetSqlName("SE2")
cQuery += " WHERE D_E_L_E_T_ <> '*'  AND E2_FILIAL = '"+xFilial("SE2")+"'"
cQuery += " AND E2_PREFIXO = '"+cPrefix+"'"
cQuery += " AND E2_NUM ='"+cNumCTC+"'"
//cQuery += " AND E2_PARCELA BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"                                                             
cQuery += " AND E2_TIPO = '"+cTipCTC+"' "
cQuery += " AND E2_FORNECE = '"+cCodFor+"'"
cQuery += " AND E2_LOJA = '"+cLojFor+"'"
cQuery += " AND E2_EMISSAO = '"+DTOS(dDatCTC)+"'"                       
 
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSe2,.T.,.T.)
                      
(cAliasSE2)->( dbGoTop() )

dbEVal( { || nRegSE2++ })



Return

                               
//------------------------------------------------------------------+

/*/{Protheus.doc} RRPA01Imp()

@author 	Davis Magalhaes
@since 		31/08/2015
@version 	P11 R5
@param   	n/t
@return  	n/t
@obs        Programa Especifico para Nutratta
/*/
//------------------------------------------------------------------+
      
Static Function RRPA01Imp(lEnd)


Local lAdjustToLegacy := .T.
Local lDisableSetup  := .T.
Local cDirSpool := GetMv("MV_RELT")



Private oFont08 	:= TFont():New("Arial",08,10,,.T.,,,,.T.,.F.)
Private oFont10		:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Private oFont10n	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Private oFont11n	:= TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)
Private oFont12n	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
Private oFont14n	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
Private oFont16n	:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
Private oFont18n	:= TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)

Private nlin	:= 0
Private nPagina := 0
Private cTitRel := "RECIBO DE PAGAMENTO DE AUTONOMO - RPA"
        

If oRpa == Nil
	lPreview := .T.
	oRPA 	:= FWMSPrinter():New("RPA"+dtos(dDataBase)+Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2), IMP_PDF,lAdjustToLegacy,cDirSpool, lDisableSetup)
	oRpa:SetPortrait()
	oRpa:Setup()
EndIf

oRPA:SetResolution(78) //Tamanho estipulado para a Danfe
oRPA:SetPortrait()
oRPA:SetPaperSize(DMPAPER_A4)
oRPA:SetMargin(60,60,60,60)             
/*
oRPA:lServer := oSetup:GetProperty(PD_DESTINATION)==AMB_SERVER
// ----------------------------------------------
// Define saida de impress�o
// ----------------------------------------------
If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
	oRpa:nDevice := IMP_SPOOL
	// ----------------------------------------------
	// Salva impressora selecionada
	// ----------------------------------------------
	fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
	oRpa:cPrinter := oSetup:aOptions[PD_VALUETYPE]
ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
	oRPA:nDevice := IMP_PDF
	// ----------------------------------------------
	// Define para salvar o PDF
	// ----------------------------------------------
	oRpa:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
Endif
                             


  */       
                    

SetRegua(nRegSE2)
  
dbSelectArea(cAliasSE2)
(cAliasSE2)->( dbGoTop() )

While ! (cAliasSE2)->( Eof() )
	
	            
	
	IncRegua() 
	
	                
	nlin	:= 0010
	
	
	oRPA:StartPage()	//-- Inicia uma nova pagina
	
	oRpa:Say(nLin,100,"RECIBO DE PAGAMENTO DE AUTONOMO - RPA",oFont14n) 		//"Emissao.: "
	CNRBox1(1550,2000,"No RECIBO / CONTRATO",,.F.,2,oFont10n)
	CNRBox1(2005,2350,"No VIAGEM",,.T.,2,oFont10n)
	
	CNRBox1(1550,2000,DTY->DTY_NUMCTC,,.F.,2,oFont10n)
	CNRBox1(2005,2350,DTY->DTY_VIAGEM,,.T.,2,oFont10n)
	
	nLin += 25
	CNRBox1(0010,1750,"NOME OU RAZAO SOCIAL DA EMPRESA",,.F.,2,oFont10n)
	CNRBox1(1755,2350,"MATRICULA (CNPJ / INSS)",,.T.,2,oFont10n)
	
	CNRBox1(0010,1750,Alltrim(SM0->M0_NOMECOM),,.F.,2,oFont10n)
	CNRBox1(1755,2350,TransForm(SM0->M0_CGC,"@R 99.999.999/9999-99"),,.T.,2,oFont10n)
	
	nLin += 25
	
	oRpa:Say(nLin,130,"RECEBI DA EMPRESA ACIMA IDENTIFICADA PELA PRESTACAO DOS SERVICOS DE",oFont10n) 		//"Emissao.: "
	nLin += 30
	
	
	nValor := (cAliasSE2)->E2_VALOR+(cAliasSE2)->E2_ISS+(cAliasSE2)->E2_IRRF+(cAliasSE2)->E2_INSS+(cAliasSE2)->E2_SEST
	
	oRpa:Say(nLin,0010,Iif( ! Empty((cAliasSE2)->E2_HIST),Alltrim((cAliasSE2)->E2_HIST),"TRANSPORTE DE AUTONOMO"),oFont10) 		//"Emissao.: "
	
	oRpa:Say(nLin,1750,"A IMPORTANCIA DE R$ "+Transform((cAliasSE2)->E2_VALOR,"@EZ 999,999,999.99"),oFont10n) 		//"Emissao.: "
	
	cTexto1 := Extenso((cAliasSE2)->E2_VALOR)
	
	nLin +=  30
	
	oRpa:Say(nLin,0010,Alltrim(cTexto1),oFont10) 		//"Emissao.: "
	
	nLin += 50
	
	oRpa:Say(nLin,0010,"CONFORME DISCRIMINATIVO ABAIXO: ",oFont10n) 		//"Emissao.: "
	oRpa:Say(nLin,1300,"E S P E C I F I C A C A O: ",oFont10n) 		//"Emissao.: "
	nLin += 25
	
	
	CNRBox1(0010,0450,"SALARIO BASE",,.F.,2,oFont10n)
	CNRBox1(0455,0700,"TAXA",,.F.,2,oFont10n)
	CNRBox1(0705,1200,"VALOR PARA INSS",,.T.,2,oFont10n)
	
	
	oRPA:Box(nLin,0010,nLin+120,0450)
	oRPA:Box(nLin,0455,nLin+120,0700)
	oRPA:Box(nLin,0705,nLin+120,1200)
	
	
	
	nLin += 25
	oRpa:Say((nLin -10),1300,"I. VALOR SERVICO PRESTADO: ",oFont10n) 		//"Emissao.: "
	oRpa:Say((nLin -10),1800,TransForm(nValor,"@EZ 999,999,999.99"),oFont10) 		//"Emissao.: "
	
	
	nLIn += 35
	oRpa:Say((nLin-10),1300,"II. ",oFont10n) 		//"Emissao.: "
	oRpa:Say((nLin-10),1800,Transform(0,"@EZ 999,999,999.99"),oFont10) 		//"Emissao.: "
	
	
	nLin += 35
	oRpa:Say(nLin,1300,"                              SOMA R$: ",oFont10n) 		//"Emissao.: "
	oRpa:Say(nLin,1800,TransForm(nValor,"@EZ 999,999,999.99"),oFont10) 		//"Emissao.: "
	
	nLin += 90
	
	nLinAux := nLin
	
	oRpa:Say(nLinAux,0010,"Informacoes Adicionais / Outros RPAs",oFont10n) 		//"Emissao.: "
	oRpa:Say(nLin,1300,"D E S C O N T O S: ",oFont10n) 		//"Emissao.: "
	nLinAux += 25
	
	oRPA:Box(nLinAux,0010,nLinAux+120,1200)
	
	oRPA:Say(nLinAux+50,0020,"Total Rendimentos:",oFont10n)
	oRPA:Say(nLinAux+90,0020,"     Total Deducoes:",oFont10n)
	
	oRPA:Say(nLinAux+50,0750,"Total IRRF: ",oFont10n)
	oRPA:Say(nLinAux+90,0750,"Total INSS: ",oFont10n)
	
	
	
	nLinAux += 135
	
	oRPA:Box(nLinAux,0010,nLinAux+160,1200)
	
	dbSelectArea("SA2")
	SA2->( dbSetOrder(1) )
	SA2->( dbSeek(xFilial("SA2")+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA) )
	
	oRPA:Say(nLinAux+30,0410,"NUMERO DE INSCRICAO",oFont10n)
	oRPA:Say(nLinAux+80,0030," CPF: ",oFont10n)
	oRPA:Say(nLinAux+80,0120,Transform(SA2->A2_CGC,"@R 999.999.999-99"),oFont10)
	
	oRPA:Say(nLinAux+110,0030,"INSS: ",oFont10n)
	oRPA:Say(nLinAux+110,0120,SA2->A2_N_PIS,oFont10) 
	//oRPA:Say(nLinAux+110,0120,SA2->A2_CODINSS,oFont10) A2_N_PIS
	
	nLin += 50     
	
	oRpa:Say(nLin,1300,"ADIANTAMENTO: ",oFont10n) 		//"Emissao.: "
	oRpa:Say(nLin,1800,Transform(DTY->DTY_ADIFRE,"@E 999,999,999.99"),oFont10) 		//"Emissao.: "
	nLin += 35
	
	
//	If ! Empty((cAliasSE2)->E2_IRRF)
		oRpa:Say(nLin,1300,"IRRF: ",oFont10n) 		//"Emissao.: "
		oRpa:Say(nLin,1800,Transform((cAliasSE2)->E2_IRRF,"@E 999,999,999.99"),oFont10) 		//"Emissao.: "
		nLin += 35
 //	EndIF
	
//	If ! Empty((cAliasSE2)->E2_ISS)
		oRpa:Say(nLin,1300,"ISS: ",oFont10n) 		//"Emissao.: "
		oRpa:Say(nLin,1800,Transform((cAliasSE2)->E2_ISS,"@E 999,999,999.99"),oFont10) 		//"Emissao.: "
		nLin += 35
  //	EndIF
	
	
	
//	If ! Empty((cAliasSE2)->E2_INSS)
		oRpa:Say(nLin,1300,"INSS: ",oFont10n) 		//"Emissao.: "
		oRpa:Say(nLin,1800,Transform((cAliasSE2)->E2_INSS,"@E 999,999,999.99"),oFont10) 		//"Emissao.: "
		nLin += 35
//	EndIF
	
	
//	If ! Empty((cAliasSE2)->E2_SEST)
		oRpa:Say(nLin,1300,"SEST: ",oFont10n) 		//"Emissao.: "
		oRpa:Say(nLin,1800,Transform((cAliasSE2)->E2_SEST,"@E 999,999,999.99"),oFont10) 		//"Emissao.: "
		nLin += 35
//	EndIF
	
	nTotDesc := (cAliasSE2)->E2_SEST +(cAliasSE2)->E2_INSS+(cAliasSE2)->E2_ISS+(cAliasSE2)->E2_IRRF+DTY->DTY_ADIFRE
	oRpa:Say(nLin,1300,"TOTAL DESCONTOS R$: ",oFont10n) 		//"Emissao.: "
	oRpa:Say(nLin,1800,Transform(nTotDEsc,"@E 999,999,999.99"),oFont10) 		//"Emissao.: "
	
	
	
	nLin += 55
	
	oRpa:Say(nLin,1300,"VALOR LIQUIDO R$: ",oFont10n) 		//"Emissao.: "
	oRpa:Say(nLin,1800,Transform((cAliasSE2)->E2_VALOR-nTotDesc,"@E 999,999,999.99"),oFont10n) 		//"Emissao.: "
	
	nLin  += 50
	
	
	nLinAux += 175
	
	oRPA:Box(nLinAux,0010,nLinAux+160,1200)
	
	
	oRPA:Say(nLinAux+30,0500,"IDENTIFICACAO",oFont10n)
	oRPA:Say(nLinAux+80,0030,"NUMERO",oFont10n)
	oRPA:Say(nLinAux+130,0030,Alltrim(SA2->A2_PFISICA),oFont10)
	
	oRPA:Say(nLinAux+80,0800,"ORGAO EMISSOR ",oFont10n)
	oRPA:Say(nLinAux+130,0800,"",oFont10)
	
	
	oRPA:Box(nLinAux,1300,nLinAux+160,2350)
	oRPA:Say(nLinAux+30,1760,"ASSINATURA",oFont10n)
	
	
	nLinAux += 185
	
	
	oRPA:Box(nLinAux,0010,nLinAux+160,1200)
	
	
	oRPA:Say(nLinAux+40,0030,"LOCAL",oFont10n)
	
	oRPA:Say(nLinAux+110,0030,Alltrim(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB,oFont10)
	
	oRPA:Say(nLinAux+40,0800,"DATA",oFont10n)
	oRPA:Say(nLinAux+110,0800,DTOC(dDataBase),oFont10)
	
	
	oRPA:Box(nLinAux,1300,nLinAux+160,2350)
	oRPA:Say(nLinAux+40,1720,"NOME COMPLETO",oFont10n)
	oRPA:Say(nLinAux+110,1350,Alltrim(SA2->A2_NOME),oFont10)
	
	
	nLinAux += 220
	
	oRPA:Say(nLinAux,010,Replicate("-",310),oFont10)
	
	
	nLinAux += 70
	
	
	
	nLin := nLinAux
	
	
	// ---  Come�ar a Segunda Via.
	
	oRpa:Say(nLin,100,"RECIBO DE PAGAMENTO DE AUTONOMO - RPA",oFont14n) 		//"Emissao.: "
	CNRBox1(1550,2000,"No RECIBO / CONTRATO",,.F.,2,oFont10n)
	CNRBox1(2005,2350,"No VIAGEM",,.T.,2,oFont10n)
	
	CNRBox1(1550,2000,DTY->DTY_NUMCTC,,.F.,2,oFont10n)
	CNRBox1(2005,2350,DTY->DTY_VIAGEM,,.T.,2,oFont10n)
	
	nLin += 25
	CNRBox1(0010,1750,"NOME OU RAZAO SOCIAL DA EMPRESA",,.F.,2,oFont10n)
	CNRBox1(1755,2350,"MATRICULA (CNPJ / INSS)",,.T.,2,oFont10n)
	
	CNRBox1(0010,1750,Alltrim(SM0->M0_NOMECOM),,.F.,2,oFont10n)
	CNRBox1(1755,2350,TransForm(SM0->M0_CGC,"@R 99.999.999/9999-99"),,.T.,2,oFont10n)
	
	nLin += 25
	
	oRpa:Say(nLin,130,"RECEBI DA EMPRESA ACIMA IDENTIFICADA PELA PRESTACAO DOS SERVICOS DE",oFont10n) 		//"Emissao.: "
	nLin += 30
	
	
	nValor := (cAliasSE2)->E2_VALOR+(cAliasSE2)->E2_ISS+(cAliasSE2)->E2_IRRF+(cAliasSE2)->E2_INSS+(cAliasSE2)->E2_SEST
	
	oRpa:Say(nLin,0010,Iif( ! Empty((cAliasSE2)->E2_HIST),Alltrim((cAliasSE2)->E2_HIST),"TRANSPORTE DE AUTONOMO"),oFont10) 		//"Emissao.: "
	
	oRpa:Say(nLin,1750,"A IMPORTANCIA DE R$ "+Transform((cAliasSE2)->E2_VALOR,"@E 999,999,999.99"),oFont10n) 		//"Emissao.: "
	
	cTexto1 := Extenso((cAliasSE2)->E2_VALOR)
	
	nLin +=  30
	
	oRpa:Say(nLin,0010,Alltrim(cTexto1),oFont10) 		//"Emissao.: "
	
	nLin += 50
	
	oRpa:Say(nLin,0010,"CONFORME DISCRIMINATIVO ABAIXO: ",oFont10n) 		//"Emissao.: "
	oRpa:Say(nLin,1300,"E S P E C I F I C A C A O: ",oFont10n) 		//"Emissao.: "
	nLin += 25
	
	
	CNRBox1(0010,0450,"SALARIO BASE",,.F.,2,oFont10n)
	CNRBox1(0455,0700,"TAXA",,.F.,2,oFont10n)
	CNRBox1(0705,1200,"VALOR PARA INSS",,.T.,2,oFont10n)
	
	
	oRPA:Box(nLin,0010,nLin+120,0450)
	oRPA:Box(nLin,0455,nLin+120,0700)
	oRPA:Box(nLin,0705,nLin+120,1200)
	
	
	
	nLin += 25
	oRpa:Say((nLin -10),1300,"I. VALOR SERVICO PRESTADO: ",oFont10n) 		//"Emissao.: "
	oRpa:Say((nLin -10),1800,TransForm(nValor,"@E 999,999,999.99"),oFont10) 		//"Emissao.: "
	
	
	nLIn += 35
	oRpa:Say((nLin-10),1300,"II. ",oFont10n) 		//"Emissao.: "
	oRpa:Say((nLin-10),1800,Transform(0,"@EZ 999,999,999.99"),oFont10) 		//"Emissao.: "
	
	
	nLin += 35
	oRpa:Say(nLin,1300,"                              SOMA R$: ",oFont10n) 		//"Emissao.: "
	oRpa:Say(nLin,1800,TransForm(nValor,"@E 999,999,999.99"),oFont10) 		//"Emissao.: "
	
	nLin += 90
	
	nLinAux := nLin
	
	oRpa:Say(nLinAux,0010,"Informacoes Adicionais / Outros RPAs",oFont10n) 		//"Emissao.: "
	oRpa:Say(nLin,1300,"D E S C O N T O S: ",oFont10n) 		//"Emissao.: "
	nLinAux += 25
	
	oRPA:Box(nLinAux,0010,nLinAux+120,1200)
	
	oRPA:Say(nLinAux+50,0020,"Total Rendimentos:",oFont10n)
	oRPA:Say(nLinAux+90,0020,"     Total Deducoes:",oFont10n)
	
	oRPA:Say(nLinAux+50,0750,"Total IRRF: ",oFont10n)
	oRPA:Say(nLinAux+90,0750,"Total INSS: ",oFont10n)
	
	
	
	nLinAux += 135
	
	oRPA:Box(nLinAux,0010,nLinAux+160,1200)
	
	dbSelectArea("SA2")
	SA2->( dbSetOrder(1) )
	SA2->( dbSeek(xFilial("SA2")+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA) )
	
	oRPA:Say(nLinAux+30,0410,"NUMERO DE INSCRICAO",oFont10n)
	oRPA:Say(nLinAux+80,0030," CPF: ",oFont10n)
	oRPA:Say(nLinAux+80,0120,Transform(SA2->A2_CGC,"@R 999.999.999-99"),oFont10)
	
	oRPA:Say(nLinAux+110,0030,"INSS: ",oFont10n)
	oRPA:Say(nLinAux+110,0120,SA2->A2_CODINSS,oFont10)
	
	nLin += 50
	
	oRpa:Say(nLin,1300,"ADIANTAMENTO: ",oFont10n) 		//"Emissao.: "
	oRpa:Say(nLin,1800,Transform(DTY->DTY_ADIFRE,"@E 999,999,999.99"),oFont10) 		//"Emissao.: "
	nLin += 35
	
//	If ! Empty((cAliasSE2)->E2_IRRF)
		oRpa:Say(nLin,1300,"IRRF: ",oFont10n) 		//"Emissao.: "
		oRpa:Say(nLin,1800,Transform((cAliasSE2)->E2_IRRF,"@E 999,999,999.99"),oFont10) 		//"Emissao.: "
		nLin += 35
//	EndIF
	
//	If ! Empty((cAliasSE2)->E2_ISS)
		oRpa:Say(nLin,1300,"ISS: ",oFont10n) 		//"Emissao.: "
		oRpa:Say(nLin,1800,Transform((cAliasSE2)->E2_ISS,"@E 999,999,999.99"),oFont10) 		//"Emissao.: "
		nLin += 35
//	EndIF
	
	
	
//	If ! Empty((cAliasSE2)->E2_INSS)
		oRpa:Say(nLin,1300,"INSS: ",oFont10n) 		//"Emissao.: "
		oRpa:Say(nLin,1800,Transform((cAliasSE2)->E2_INSS,"@E 999,999,999.99"),oFont10) 		//"Emissao.: "
		nLin += 35
//	EndIF
	
	
//	If ! Empty((cAliasSE2)->E2_SEST)
		oRpa:Say(nLin,1300,"SEST: ",oFont10n) 		//"Emissao.: "
		oRpa:Say(nLin,1800,Transform((cAliasSE2)->E2_SEST,"@E 999,999,999.99"),oFont10) 		//"Emissao.: "
		nLin += 35
//	EndIF
	
	nTotDesc := (cAliasSE2)->E2_SEST +(cAliasSE2)->E2_INSS+(cAliasSE2)->E2_ISS+(cAliasSE2)->E2_IRRF + DTY->DTY_ADIFRE
	oRpa:Say(nLin,1300,"TOTAL DESCONTOS R$: ",oFont10n) 		//"Emissao.: "
	oRpa:Say(nLin,1800,Transform(nTotDEsc,"@E 999,999,999.99"),oFont10) 		//"Emissao.: "
	
	
	
	nLin += 55
	
	oRpa:Say(nLin,1300,"VALOR LIQUIDO R$: ",oFont10n) 		//"Emissao.: "
	oRpa:Say(nLin,1800,Transform((cAliasSE2)->E2_VALOR-nTotDesc,"@E 999,999,999.99"),oFont10n) 		//"Emissao.: "
	
	nLin  += 50
	
	
	nLinAux += 175
	
	oRPA:Box(nLinAux,0010,nLinAux+160,1200)
	
	
	oRPA:Say(nLinAux+30,0500,"IDENTIFICACAO",oFont10n)
	oRPA:Say(nLinAux+80,0030,"NUMERO",oFont10n)
	oRPA:Say(nLinAux+130,0030,Alltrim(SA2->A2_PFISICA),oFont10)
	
	oRPA:Say(nLinAux+80,0800,"ORGAO EMISSOR ",oFont10n)
	oRPA:Say(nLinAux+130,0800,"",oFont10)
	
	
	oRPA:Box(nLinAux,1300,nLinAux+160,2350)
	oRPA:Say(nLinAux+30,1760,"ASSINATURA",oFont10n)
	
	
	nLinAux += 185
	
	
	oRPA:Box(nLinAux,0010,nLinAux+160,1200)
	
	
	oRPA:Say(nLinAux+40,0030,"LOCAL",oFont10n)
	
	oRPA:Say(nLinAux+110,0030,Alltrim(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB,oFont10)
	
	oRPA:Say(nLinAux+40,0800,"DATA",oFont10n)
	oRPA:Say(nLinAux+110,0800,DTOC(dDataBase),oFont10)
	
	
	oRPA:Box(nLinAux,1300,nLinAux+160,2350)
	oRPA:Say(nLinAux+40,1720,"NOME COMPLETO",oFont10n)
	oRPA:Say(nLinAux+110,1350,Alltrim(SA2->A2_NOME),oFont10)
	
	
	
	
	
	oRPA:EndPage() 	//-- Encerra a pagina anterior
	                                           
	dbSelectArea(cAliasSE2)
	(cAliasSE2)->( dbSkip() )
	
	
End
    
dbSelectArea(cAliasSE2)
(cAliasSE2)->( dbCloseArea() )

oRPA:Preview()//Visualiza antes de imprimir
FreeObj(oRPA)
oRpa := Nil

Return


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un놹o    � CNRCabec1� Autor � Davis Magalhaes       � Data �17/01/2011낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Cabecalho padrao para relatorios graficos                  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� ExpN1 = Posicao da coluna para impressao do cTexto         낢�
굇�          � ExpC2 = Texto a ser impresso	                             낢�
굇�          � ExpC3 = Titulo do Relatorio                                낢�
굇�          � ExpO4 = Fonte para impressao do cTexto                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      �                                                           낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function CNRCabec1(nCol,cTexto,cTitulo,oFontT,lPaisagem,lLinhaItem)
Local cFileLogo	:= ""
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializa Fontes											           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Local oFont10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont10n	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Local oFont11n	:= TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)
Local oFont14n	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
Local oFont16n	:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
Local oFont18n	:= TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)
Local cLogo     := GetSrvProfString("Startpath","") + "ORCA" + cEmpAnt + cFilAnt + ".BMP" //FisxLogo("1")


Default nCol	:= 0
Default cTexto	:= ""
Default cTitulo := ""
Default oFontT  := oFont10
Default lPaisagem := .T.
Default lLinhaItem := .T.

nLin := 3500

If (If(lPaisagem,(nLin >= 2350),(nLin >= 2900)))
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Cabecalho da Pagina					  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	
	
	nPagina++ //-- Variavel Private
	nLin := 50 //-- Variavel private
	oRPA:EndPage() 	//-- Encerra a pagina anterior
	oRPA:StartPage()	//-- Inicia uma nova pagina
	
	
	oRPA:Box(nLin,0050,nLin+300,2250)
	//	cFileLogo += "LGRL"+SM0->M0_CODIGO+".BMP"
	oRPA:SayBitmap(70,60,cLogo,950,250) //-- Logotipo
	
	
	
	//    oRPA:Box(nLin,480,nLin+300,2450)
	
	oRPA:Say(nLin+70,900,SM0->M0_NOMECOM,oFont18n,,CLR_HBLUE) 		//"Emissao.: "
	oRPA:Say(nLin+130,950,SM0->M0_ENDCOB,oFont14n) 		//"Emissao.: "
	oRPA:Say(nLin+180,950,Alltrim(SM0->M0_CIDCOB)+" / "+SM0->M0_ESTCOB+ "          CEP.: "+Transform(SM0->M0_CEPCOB,"@R 99999-999"),oFont14n) 		//"Emissao.: "
	cCnpj := "CNPJ: "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")
	cInsc := "      Inscricao Estadual: "+SM0->M0_INSC
	oRPA:Say(nLin+230,950,cCNPJ+" "+cInsc,oFont14n) 		//"Emissao.: "
	If cEmpAnt == "01"
		oRPA:Say(nLin+280,1150,"TEL: (31) 3307-3535    -    FAX: (31) 3307-3538",oFont14n) 		//"Emissao.: "
	EndIf
	
	
	oRPA:Box(nLin,2255,nLin+300,3000)
	
	oRPA:Say(nLin+100,2410,OemToAnsi("ORCAMENTO No.: ")+SCJ->CJ_NUM,oFont14n,,CLR_HRED)
	oRPA:Say(nLin+180,2480,OemToAnsi("EMISSAO.: ")+DTOC(SCJ->CJ_EMISSAO),oFont14n,,CLR_HRED)
	//"Emissao.: "
	oRPA:Say(nLin+280,2850,OemToAnsi("Folha...: ")	+ StrZero(nPagina,3),oFont10n) 		//"Emissao.: "
	
	
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Salta para a proxima linha			   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
nLin := 350
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Impressao do texto					      �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Return Nil

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un놹o    � CNRBox1() � Autor � Davis Magalhaes     � Data �17/01/2011낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Cria Box para Textos			                                낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� ExpN1 = Posicao inicial da coluna para criacao do Box      낢�
굇�          � ExpN2 = Posicao final da coluna para criacao do Box        낢�
굇�          � ExpC3 = Texto da 1a. linha do Box                          낢�
굇�          � ExpC4 = Texto da 2a. linha do Box                          낢�
굇�          � ExpL5 = Quebra para proxima linha apos a impressao do Box  낢�
굇�          �         (.T. Com  Quebra / .F. Sem Quebra)                 낢�
굇�          � ExpN6 = Tipo do Box : 									           낢�
굇�          �                      1 - Linha de Cabecalho                낢�
굇�          �                      2 - Linha Unica Simples               낢�
굇�          �                      3 - Linha de Detalhe                  낢�
굇�          �                      4 - Somente Texto                     낢�
굇�          � ExpO7 = Fonte para impressao do Texto                      낢�
굇�          � ExpL8 = Se .T. realiza o alinhamento do cTexto1 a Direita. 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      �                                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function CNRBox1(nCol1,nCol2,cTexto1,cTexto2,lQuebra,nTipo,oFontB,lAlinDir)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializa Fontes											           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Local oFont10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont10n	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)

Default nCol1	:= 0
Default nCol2	:= 0
Default cTexto1 := ""
Default cTexto2 := ""
Default lQuebra := .T.
Default nTipo   := 3
Default oFontB  := oFont10
Default lAlinDir:= .F.
/*
If nLin >= 2400
	CNRCabec1(Nil,Nil,OemToAnsi(cTitRel)) //-- Impressao do Cabecalho da pagina
EndIf
 */
If nTipo == 1  //-- Linha de Cabecalho
	oRPA:Box(nLin,nCol1,nLin+55,nCol2)
	oRPA:Box(nLin+5,nCol1+5,nLin+50,nCol2-5)
	oRPA:Say(nLin+10,((nCol2-nCol1)/2)-((Len(alltrim(cTexto1))/2)*20),cTexto1,oFont10n)
ElseIf nTipo == 2 //-- Linha Unica Simples
	oRPA:Box(nLin,nCol1,nLin+45,nCol2)
	If lAlinDir //-- Alinhamento a Direita
		oRPA:Say(nLin+28,nCol2-5-TamTexto(Alltrim(cTexto1)),AllTrim(cTexto1),oFontB)
		//      oRPA:Say(nLin+7,nCol2-5-TamTexto(cTexto1),cTexto1,oFontB)
	Else
		oRPA:Say(nLin+28,nCol1+10,cTexto1,oFontB)
	EndIf
ElseIf nTipo == 3 //-- Linha de Detalhe
	oRPA:Box(nLin,nCol1,nLin+100,nCol2)
	oRPA:Say(nLin+10,nCol1+10,cTexto1,oFont10n)
	oRPA:Say(nLin+50,nCol1+10,cTexto2,oFont10)
ElseIf nTipo == 4 //-- Somente Texto
	oRPA:Say(nLin+7,nCol1,cTexto1,oFontB)
EndIf
If lQuebra //-- Quebra Linha
	If nTipo == 1
		nLin += 60	//-- Cabecalho
	ElseIf nTipo == 2
		nLin += 50	//-- Unica Simples
	ElseIf nTipo == 3
		nLin += 110	//-- Detalhe
	ElseIf nTipo == 4
		nLin += 50 //-- Somente Texto
	EndIf
EndIf


Return


