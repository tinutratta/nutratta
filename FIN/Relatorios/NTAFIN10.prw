#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*
========================================================================================================================
Rotina----: NTAFIN10
Autor-----: Davidson Carvalho
Data------: 30/07/2018
========================================================================================================================
Descri��o-: IMPRESSAO DO BOLETO BANCO SRM ASSET CAPITAL EM MOVIMENTO (Bradesco) COM CODIGO DE BARRAS 
Uso-------: 
========================================================================================================================
*/

User Function NTAFIN10(cNumIni,cNumFim,cPrefixo,nOpc)


LOCAL   aCampos 	:= {{"E1_NOMCLI","Cliente","@!"},{"E1_PREFIXO","Prefixo","@!"},{"E1_NUM","Titulo","@!"},;
{"E1_PARCELA","Parcela","@!"},{"E1_SALDO","Valor","@E 9,999,999.99"},{"E1_VENCTO","Vencimento"}}

LOCAL   aMarked     := {}
LOCAL   aDesc       := {"Este programa imprime os boletos de","cobranca bancaria de acordo com","os parametros informados"}
LOCAL   cPerg    	:= "NTAFIN10"

PRIVATE Exec		:= .F.
PRIVATE cIndexName 	:= ''
PRIVATE cIndexKey  	:= ''
PRIVATE cFilter    	:= ''       
Private nOpcImp       

Private cDadBco  := SuperGetMv("NT_SRM",.F.,.F.)  
Private cCodBc1  := Substr(cDadBco,1,3)
Private cAgencia := Substr(cDadBco,4,5)
Private cNumCta  := Substr(cDadBco,9,10)        

Default nOpc := 1


Tamanho  := "M"
titulo   := "Impressao de Boleto Banco NOVA SRM ADM DE RECURSOS E FINANCAS SA  (Bradesco)
cDesc1   := "Este programa destina-se a impressao do Boleto Banco SRM (Bradesco)."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
wnrel    := "NTAFIN10"
lEnd     := .F.
cQuery   := ""

//????????????????????????????????
//?Variaveis tipo Private padrao de todos os relatorios         ?
//????????????????????????????????
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }   //"Zebrado"###"Administracao"
nLastKey := 0


//????????????????????????????????
//?Verifica as perguntas selecionadas                           ?
//????????????????????????????????
ValidPerg(cPerg)             
If cNumIni == nil
	Pergunte (cPerg,.T.)
Else                    
	Pergunte (cPerg,.F.)
EndIf
	


////????????????????????????????????
//	?Faz update do e1_ok para que funcione depois da atualizacao  ?
//	????????????????????????????????

cQuery := "UPDATE "                         
cQuery := cQuery + RetSQLname("SE1")+" "
cQuery := cQuery + "  SET  E1_OK  = 'CR' "

TCSQLEXEC(cQuery)                                           

//????????????????????????????????
//?Envia controle para a funcao SETPRINT                        ?
//????????????????????????????????
dbSelectArea("SE1")

If cNumIni == nil
	
	Wnrel := SetPrint(cString,Wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,)
	If nLastKey == 27
		Set Filter to
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Set Filter to
		Return
	Endif
EndIf
       
nOpcImp := nOpc

If nOpcImp == 1
	
	cIndexName := Criatrab(Nil,.F.)
	cIndexKey  := 	"E1_PORTADO+E1_CLIENTE+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)"
	cFilter    := 	"E1_PREFIXO >= '" + MV_PAR01 + "' .And. E1_PREFIXO <= '" + MV_PAR02 + "' .And. " + ;
	"E1_NUM     >= '" + MV_PAR03 + "' .And. E1_NUM     <= '" + MV_PAR04 + "' .And. " + ;
	"E1_PARCELA >= '" + MV_PAR05 + "' .And. E1_PARCELA <= '" + MV_PAR06 + "' .And. " + ;
	"E1_PORTADO >= '" + MV_PAR07 + "' .And. E1_PORTADO <= '" + MV_PAR08 + "' .And. " + ;
	"E1_CLIENTE >= '" + MV_PAR09 + "' .And. E1_CLIENTE <= '" + MV_PAR10 + "' .And. " + ;
	"E1_EMISSAO >= CTOD('" + DTOC(MV_PAR15) + "') .And. E1_EMISSAO <= CTOD('" + DTOC(MV_PAR16) + "') .And. " + ;
	"E1_VENCTO  >= CTOD('" + DTOC(MV_PAR13) + "') .And. E1_VENCTO <= CTOD('" + DTOC(MV_PAR14) + "') .And. "+ ;
	"E1_LOJA    >= '"+MV_PAR11+"' .And. E1_LOJA <= '"+MV_PAR12+"' .And. "+;
	"E1_FILIAL   = '"+xFilial()+"' .And. E1_SALDO > 0 .And. " + ;
	"SubsTring(E1_TIPO,3,1) != '-' .And. "+;
	"E1_PORTADO != '   '"
	
	IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
	dbSelectArea("SE1")
	
	#IFNDEF TOP
		DbSetIndex(cIndexName + OrdBagExt())
	#ENDIF
	dbGoTop()
	
	If mv_par17 = 1
		@ 001,001 TO 400,700 DIALOG oDlg TITLE "Selecao de Titulos"
		@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
		@ 180,280 BMPBUTTON TYPE 01 ACTION (Exec := .T.,Close(oDlg))
		@ 180,310 BMPBUTTON TYPE 02 ACTION (Exec := .F.,Close(oDlg))
		ACTIVATE DIALOG oDlg CENTERED
	EndIf
	
	dbGoTop()
	
	Do While !Eof()
		If Marked("E1_OK")
			AADD(aMarked,.T.)
		Else
			AADD(aMarked,.F.)
		EndIf
		dbSkip()
	EndDo
	
	dbGoTop()
	
	If Exec
		Processa({|lEnd|MontaRel(aMarked)})
	Endif
	
	RetIndex("SE1")
	FErase(cIndexName+OrdBagExt())
Else
	            // -- Inicio -- DAvis -- Boleto Automatico                      
	MV_PAR01 := cPrefixo
	MV_PAR02 := cPrefixo
	MV_PAR03 := cNumIni
	MV_PAR04 := cNumFim    
	MV_PAR05 := " "    
	MV_PAR06 := "ZZZ"
	MV_PAR07 := Substr(cDadBco,1,3)
	MV_PAR08 := Substr(cDadBco,1,3)
	MV_PAR09 := " "
	MV_PAR10 := "ZZZZZZZZ" 
	MV_PAR11 := " " 
	MV_PAR12 := "ZZZZ" 
	MV_PAR17 := 2                                                                                    
	 

	cIndexName := Criatrab(Nil,.F.)
	cIndexKey  := 	"E1_PORTADO+E1_CLIENTE+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)"
	cFilter    := 	"E1_PREFIXO >= '" + MV_PAR01 + "' .And. E1_PREFIXO <= '" + MV_PAR02 + "' .And. " + ;
	"E1_NUM     >= '" + MV_PAR03 + "' .And. E1_NUM     <= '" + MV_PAR04 + "' .And. " + ;
	"E1_PARCELA >= '" + MV_PAR05 + "' .And. E1_PARCELA <= '" + MV_PAR06 + "' .And. " + ;
	"E1_PORTADO >= '" + MV_PAR07 + "' .And. E1_PORTADO <= '" + MV_PAR08 + "' .And. " + ; 
	"E1_AGEDEP  = '" + cAgencia  + "' .And. E1_AGEDEP = '" + cAgencia + "' .And. " + ;
	"E1_CLIENTE >= '" + MV_PAR09 + "' .And. E1_CLIENTE <= '" + MV_PAR10 + "' .And. " + ;
	"E1_LOJA    >= '"+MV_PAR11+"' .And. E1_LOJA <= '"+MV_PAR12+"' .And. "+;
	"E1_FILIAL   = '"+xFilial()+"' .And. E1_SALDO > 0 .And. " + ;
	"SubsTring(E1_TIPO,3,1) != '-' .And. "+;
	"E1_PORTADO != '   ' .And. E1_SITUACA = '0' " //.And. E1_NUMBOR <> ' .And. E1_SITUACA = '1' "
	
	IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
	dbSelectArea("SE1")
	
	#IFNDEF TOP
		DbSetIndex(cIndexName + OrdBagExt())
	#ENDIF
	dbGoTop()
	
	If mv_par17 = 1
		@ 001,001 TO 400,700 DIALOG oDlg TITLE "Selecao de Titulos"
		@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
		@ 180,280 BMPBUTTON TYPE 01 ACTION (Exec := .T.,Close(oDlg))
		@ 180,310 BMPBUTTON TYPE 02 ACTION (Exec := .F.,Close(oDlg))
		ACTIVATE DIALOG oDlg CENTERED
	
		dbGoTop()
	
		Do While !Eof()
			If Marked("E1_OK")
				AADD(aMarked,.T.)
			Else
				AADD(aMarked,.F.)
			EndIf
			dbSkip()
		EndDo
	
	EndIf
	
	dbGoTop()
	
//	If Exec
		Processa({|lEnd|MontaRel(aMarked)})
 //	Endif
	
	RetIndex("SE1")
	FErase(cIndexName+OrdBagExt())
	
EndIf

Return Nil


/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?MontaRel ?Autor ?                      ?Data ?         ??
???????????????????????????????????????
??escri?o ?IMPRESSAO DO BOLETO LASE DO Banco SRM (Bradesco) COM CODIGO DE BARRAS ??
???????????????????????????????????????
??so       ?                                                           ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
Static Function MontaRel(aMarked)

Local oPrint
Local n := 0
//Local cBitmap      := "\SYSTEM\LGRL" + SM0->M0_CODIGO + SM0->M0_CODFIL + ".BMP" // Logo da empresa  
Local cBitmap      := "BOL237.JPG" // Logo do Banco Bradesco

Local aDadosEmp    := {SM0->M0_NOMECOM                                    ,; //[1]Nome da Empresa
SM0->M0_ENDCOB                                                            ,; //[2]Endere?
AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
"C.N.P.J.: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+          ; //[6]
Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ; //[6]
Subs(SM0->M0_CGC,13,2)                                                    ,; //[6]CGC
"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        }  //[7]I.E

Local aDadosTit
Local aDadosBanco
Local aDatSacado
Local aBolText
Local i         := 1
Local CB_RN_NN  := {}
Local nRec      := 0
Local _nVlrAbat := 0
Local _nTotEnc  := 0
Local cFatura 	:= ""
Local _cCart	:= ""   
Local _cConv	:= ""

Private _cNossoNum := "00000000000"

oPrint:= TMSPrinter():New( "Boleto Laser" )
oPrint:SetPortrait() // ou SetLandscape()
oPrint:StartPage()   // Inicia uma nova p?ina

dbGoTop()
Do While !EOF()
	nRec := nRec + 1
	dbSkip()
EndDo

If MV_PAR18 == 1
	_cCart := "09"
Else
	_cCart := "09"
EndIf

dbGoTop()
ProcRegua(nRec)

Do While !EOF()
	//Posiciona o SA6 (Bancos)
	DbSelectArea("SA6")
	DbSetOrder(1)
	DbSeek(xFilial("SA6")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)
	
	//Posiciona na Arq de Parametros CNAB
	DbSelectArea("SEE")
	DbSetOrder(1)
	DbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)
	If nOpcImp == 1
		If aMarked[i]
			If Empty(SE1->E1_NUMBCO)
				_cNossoNum := StrZero(Val(Alltrim(SEE->EE_FAXATU))+1,11)
				RecLock("SEE",.f.)
				SEE->EE_FAXATU :=	_cNossoNum
				MsUnlock()
			Else
				//_cNossoNum := Substr(SE1->E1_NUMBCO,5,7)
				_cNossoNum := Substr(SE1->E1_NUMBCO,1,11)
			Endif
		Endif
	Else         
		If Empty(SE1->E1_NUMBCO)
			_cNossoNum := StrZero(Val(Alltrim(SEE->EE_FAXATU))+1,11)
			RecLock("SEE",.f.)
			SEE->EE_FAXATU :=	_cNossoNum
			MsUnlock()
		Else
			//_cNossoNum := Substr(SE1->E1_NUMBCO,5,7)
			_cNossoNum := Substr(SE1->E1_NUMBCO,1,11)
		Endif
	EndIf
	
	//Posiciona o SA1 (Cliente)
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
	
	dbSelectArea("SE1")
	aDadosBanco  := {"237-2"     						        ,; // [1]Numero do Banco
	SA6->A6_NOME    	            	            			,; // [2]Nome do Banco
	Alltrim(SA6->A6_AGENCIA)						            ,; // [3]Ag?cia
	Alltrim(SA6->A6_NUMCON) 			    ,; // [4]Conta Corrente
	Substr(SA6->A6_DVCTA,1,1)		   			 	   			,; // [5]D?ito da conta corrente
	_cCart			                         	  				,; // [6]Codigo da Carteira
	Substr(SA6->A6_DVAGE,1,1)				       			    ,; // [7]Digito da Ag?cia  
   	_cConv                                      			    ,; // [8]C?igo Conv?io    
	Alltrim(SA6->A6_AGENCIA)				    			    ,; // [9]Ag?cia B. Correspondente
	Substr(SA6->A6_DVAGE,1,1)					   				,; // [10]Digito da Ag?cia B. Correspondente
	Alltrim(SA6->A6_NUMCON)				,; // [11]Conta Corrente . Correspondente
	Substr(SA6->A6_DVCTA,1,1)		   							}  // [12]D?ito da conta corrente . Correspondente
	
	If Empty(SA1->A1_ENDCOB)
		aDatSacado   := {Capital(SA1->A1_NOME)                  ,;  // [1]Raz? Social
		AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           		,;  // [2]C?igo
		AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO)		,;  // [3]Endere?
		AllTrim(SA1->A1_MUN )                            		,;  // [4]Cidade
		SA1->A1_EST                                      		,;  // [5]Estado
		Substr(SA1->A1_CEP,1,5)+"-"+Substr(SA1->A1_CEP,6,3)     ,;  // [6]cep
		Iif(Len(AllTrim(SA1->A1_CGC)) <= 11,TransForm(SA1->A1_CGC,"@R 999.999.999-99"),TransForm(SA1->A1_CGC,"@R 99.999.999/9999-99")) }		// [7]CGC
	Else
		aDatSacado   := {Capital(SA1->A1_NOME)              	,;	// [1]Raz? Social
		AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA             		,;  // [2]C?igo
		AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC)	,;  // [3]Endere?
		AllTrim(SA1->A1_MUNC)	                            	,;  // [4]Cidade
		SA1->A1_ESTC	                                    	,;  // [5]Estado
		Substr(SA1->A1_CEPC,1,5)+"-"+Substr(SA1->A1_CEPC,6,3)  ,;   // [6]CEP
		Iif(Len(AllTrim(SA1->A1_CGC)) <= 11,TransForm(SA1->A1_CGC,"@R 999.999.999-99"),TransForm(SA1->A1_CGC,"@R 99.999.999/9999-99")) }		// [7]CGC
	
	Endif
	
	_nTotEnc	:= 	SE1->(E1_IRRF+E1_INSS+E1_PIS+E1_COFINS+E1_CSLL+((E1_DESCFIN * E1_SALDO)/100))		 && Bop's 110407 - Inclusao do E1_DESCFIN
	_nVlrAbat   := 	_nTotEnc
	
	//									Codigo Banco           Agencia			C.Corrente     Digito C/C
	CB_RN_NN    := Ret_cBarra(Subs(aDadosBanco[1],1,3),aDadosBanco[9],aDadosBanco[11],;
	aDadosBanco[12],aDadosBanco[6],_cNossoNum,((E1_SALDO+E1_ACRESC-E1_DECRESC)-_nVlrAbat) )
	
	aDadosTit    := {AllTrim(E1_NUM)+AllTrim(E1_PARCELA)		,;  // [1] N?ero do t?ulo
	E1_EMISSAO                              					,;  // [2] Data da emiss? do t?ulo
	Date()                                  					,;  // [3] Data da emiss? do boleto
	E1_VENCTO													,;  // [4] Data do vencimento
	((E1_SALDO+E1_ACRESC-E1_DECRESC)-_nVlrAbat)					,;  // [5] Valor do t?ulo
	CB_RN_NN[3]                             					,;  // [6] Nosso n?ero (Ver f?mula para calculo)
	E1_PREFIXO                               					,;  // [7] Prefixo da NF
	E1_TIPO	                               						,;  // [8] Tipo do Titulo
	E1_IRRF		                               					,;  // [9] IRRF
	E1_ISS	                             						,;  // [10] ISS
	E1_INSS 	                               					,;  // [11] INSS
	E1_PIS                                  					,;  // [12] PIS
	E1_COFINS                               					,;  // [13] COFINS
	E1_CSLL                               						,;  // [14] CSLL
	_nVlrAbat                               					}   // [15] Abatimentos
	
	cFatura := " "
	If SE1->E1_TIPO == "FT "
		cFatura  := BuscaNF(SE1->E1_PREFIXO,SE1->E1_NUM)
	Endif
		
	aBolText	:= 	{"",;//{"DESCONTO DE 1% ATE A DATA DO VENCIMENTO ",;
					"APOS O VENCIMENTO COBRAR  5%  DE MULTA." 	,; //[1]
	                "APOS O VENCIMENTO COBRAR MORA DE 0,1 AO DIA",;//[2]
	                "APOS O VENCIMENTO INCLUIR JUROS DE 3% AO MES." ,; 
	                "PROTESTAR "+StrZero(Val(SEE->EE_DIASPRT),2) + "  DIAS CORRIDOS APOS O VENCIMENTO.", ;//[3]        
                              Substr(cFatura,106,105) } //[6]
	
	     
	If nOpcImp == 1
		If aMarked[i]
			ImpBrad(oPrint,cBitMap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
			n := n + 1
		EndIf
	Else              
		ImpBrad(oPrint,cBitMap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
		n := n + 1
	EndIf
	
	dbSelectArea("SE1")
	dbSkip()
	IncProc()
	i := i + 1
	
EndDo

oPrint:EndPage()     // Finaliza a p?ina
oPrint:Setup()     // Seta a Impressora
oPrint:Preview()     // Visualiza antes de imprimir

Return nil

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?IMPBRAD  ?Autor ?                      ?Data ?         ??
???????????????????????????????????????
??escri?o ?IMPRESSAO DO BOLETO LASE DO BANCO NOVA SRM ADM DE RECURSOS E FINANCAS SA   (Bradesco) COM CODIGO DE BARRAS ??
???????????????????????????????????????
??so       ?                                                           ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
Static Function ImpBrad(oPrint,cBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)

LOCAL oFont8
LOCAL oFont10
LOCAL oFont14n
LOCAL oFont16
LOCAL oFont16n
LOCAL oFont24
LOCAL i := 0
LOCAL cImpData := " "

LOCAL aCoords1 := {0150,1900,0550,2300}
LOCAL aCoords2 := {0450,1050,0550,1900}
LOCAL aCoords3 := {0710,1900,0810,2300}
LOCAL aCoords4 := {0980,1900,1050,2300}
LOCAL aCoords5 := {1330,1900,1400,2300}
LOCAL aCoords6 := {2000,1900,2100,2300}
LOCAL aCoords7 := {2270,1900,2340,2300}
LOCAL aCoords8 := {2620,1900,2690,2300}

LOCAL oBrush

Local cStartPath	:= GetSrvProfString("StartPath","")
Local cBmp			:= ""

cStartPath	:= AllTrim(cStartPath)
If SubStr(cStartPath,Len(cStartPath),1) <> "\"
	cStartPath	+= "\"
EndIf
cBmp	:= cStartPath+"Nutratta.bmp"


//Par?etros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
oFont8  := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14n:= TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24 := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

oBrush := TBrush():New("",4)

oPrint:StartPage()   // Inicia uma nova p?ina
//Pinta os campos de cinza
//oPrint:FillRect(aCoords1,oBrush)
//oPrint:FillRect(aCoords2,oBrush)
//oPrint:FillRect(aCoords3,oBrush)
//oPrint:FillRect(aCoords4,oBrush)
//oPrint:FillRect(aCoords5,oBrush)
//oPrint:FillRect(aCoords6,oBrush)
//oPrint:FillRect(aCoords7,oBrush)
//oPrint:FillRect(aCoords8,oBrush)

// Inicia aqui
oPrint:Line (0150,550,0050, 550)
oPrint:Line (0150,800,0050, 800)

oPrint:SayBitMap(0050,100,cBitmap,0400,100)		// Logo da Empresa
//oPrint:SayBitMap(0050,100,cBitmap,0400,075)		// Logo da Empresa

oPrint:Say  (0062,567,aDadosBanco[1],oFont24 )	// [1]Numero do Banco
oPrint:Say  (0084,1900,"Comprovante de Entrega"									,oFont10)
oPrint:Line (0150,100,0150,2300)
oPrint:Say  (0150,100 ,"Beneficiario"                                        		,oFont8)
//oPrint:Say  (0200,100 ,aDadosEmp[1]                                 			,oFont10) //Nome + CNPJ
oPrint:Say  (0200,100 ,"NOVA SRM ADM DE RECURSOS E FINANCAS SA  "                               	,oFont10) //Nome
oPrint:Say  (0150,1060,"Agencia/Codigo do Beneficiario"                         		,oFont8)
oPrint:Say  (0200,1060,aDadosBanco[9]+"-"+aDadosBanco[10]+"/"+aDadosBanco[11]+"-"+aDadosBanco[12],oFont10)
oPrint:Say  (0150,1510,"Nro.Documento"                                  		,oFont8)
oPrint:Say  (0200,1510,aDadosTit[7]+aDadosTit[1]								,oFont10) //Prefixo +Numero+Parcela
oPrint:Say  (0250,100 ,"Pagador"                                         		,oFont8)
oPrint:Say  (0300,100 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             		,oFont8)	//Nome + Codigo

oPrint:Say  (0250,1060,"Vencimento"                                     		,oFont8)
cImpData := Strzero(Day(aDadosTit[4]),2)+"/"+Strzero(Month(aDadosTit[4]),2)+"/"+Strzero(Year(aDadosTit[4]),4)
oPrint:Say  (0300,1060,If(Dtoc(aDadosTit[4])=="11/11/11","C/Apresentacao",cImpData),oFont10)
//oPrint:Say  (0300,1060,If(Dtoc(aDadosTit[4])=="11/11/11","C/Apresenta?o",DTOC(aDadosTit[4])),oFont10)

oPrint:Say  (0250,1510,"Valor do Documento"                          			,oFont8)
oPrint:Say  (0300,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99"))		,oFont10)
oPrint:Say  (0400,0100,"Recebi(emos) o bloqueto/titulo"                 		,oFont10)
oPrint:Say  (0450,0100,"com as caracteristicas acima."             				,oFont10)
oPrint:Say  (0350,1060,"Data"                                           		,oFont8)
oPrint:Say  (0350,1410,"Assinatura"                                 			,oFont8)
oPrint:Say  (0450,1060,"Data"                                           		,oFont8)
oPrint:Say  (0450,1410,"Entregador"                                 			,oFont8)

oPrint:Line (0250, 100,0250,1900 )
oPrint:Line (0350, 100,0350,1900 )
oPrint:Line (0450,1050,0450,1900 ) //---
oPrint:Line (0550, 100,0550,2300 )

oPrint:Line (0550,1050,0150,1050 )
oPrint:Line (0550,1400,0350,1400 )
oPrint:Line (0350,1500,0150,1500 ) //--
oPrint:Line (0550,1900,0150,1900 )

oPrint:Say  (0160,1910,"(  )Mudou-se"                                			,oFont8)
oPrint:Say  (0200,1910,"(  )Ausente"                                    		,oFont8)
oPrint:Say  (0240,1910,"(  )Nao existe no indicado"                  			,oFont8)
oPrint:Say  (0280,1910,"(  )Recusado"                                			,oFont8)
oPrint:Say  (0320,1910,"(  )Nao procurado"                              		,oFont8)
oPrint:Say  (0360,1910,"(  )Endere�o insuficiente"                  			,oFont8)
oPrint:Say  (0400,1910,"(  )Desconhecido"                            			,oFont8)
oPrint:Say  (0440,1910,"(  )Falecido"                                   		,oFont8)
oPrint:Say  (0480,1910,"(  )Outros(anotar no verso)"                  			,oFont8)

For i := 100 to 2300 step 50
	oPrint:Line( 0600, i, 0600, i+30)
Next i

oPrint:Line (0710,100,0710,2300)
oPrint:Line (0710,550,0610, 550)
oPrint:Line (0710,800,0610, 800)

//oPrint:SayBitMap(0644,100,cBmp,0400,050)		// Logo do Bradesco
oPrint:SayBitMap(0630,100,cBmp,0400,075)		// Logo do Bradesco

oPrint:Say  (0622,567,aDadosBanco[1],oFont24 )	// [1]Numero do Banco
oPrint:Say  (0644,1900,"Recibo do Pagador",oFont10)

oPrint:Line (0810,100,0810,2300)
oPrint:Line (0910,100,0910,2300)
oPrint:Line (0980,100,0980,2300)
oPrint:Line (1050,100,1050,2300)
oPrint:Line (1120,100,1120,2300)//-

oPrint:Line (1120,500,0980,500)
oPrint:Line (1120,750,1050,750) //-
oPrint:Line (1120,1000,0980,1000)
oPrint:Line (1050,1350,0980,1350)
oPrint:Line (1120,1550,0980,1550)

oPrint:Say  (0710,100 ,"Local de Pagamento"                             		,oFont8)
oPrint:Say  (0750,100 ,"PAGAVEL EM QUALQUER AGENCIA BANCARIA ATE A DATA DO VENCIMENTO"        ,oFont10)

oPrint:Say  (0710,1910,"Vencimento"                                     		,oFont8)
cImpData := Strzero(Day(aDadosTit[4]),2)+"/"+Strzero(Month(aDadosTit[4]),2)+"/"+Strzero(Year(aDadosTit[4]),4)
oPrint:Say  (0750,1930,If(Dtoc(aDadosTit[4])=="11/11/11","C/Apresentacao",cImpData),oFont10)
//oPrint:Say  (0750,2010,If(Dtoc(aDadosTit[4])=="11/11/11","C/Apresenta?o",DTOC(aDadosTit[4])),oFont10)

oPrint:Say  (0810,100 ,"Beneficiario"                                        		,oFont8)
//oPrint:Say  (0850,100 ,aDadosEmp[1]+"                  - "+aDadosEmp[6]			,oFont10) //Nome + CNPJ
oPrint:Say  (0850,100 ,"NOVA SRM ADM DE RECURSOS E FINANCAS SA  ", oFont10) //Nome

oPrint:Say  (0810,1910,"Agencia/Codigo do Beneficiario"                         		,oFont8)
oPrint:Say  (0850,1930,aDadosBanco[9]+"-"+aDadosBanco[10]+"/"+aDadosBanco[11]+"-"+aDadosBanco[12],oFont10)

oPrint:Say  (0910,100 ,"Endereco" ,oFont8)
oPrint:Say  (0940,100 ,"Informar aqui o Endere�o do SRM ", oFont10) //Endereco da Empresa  
//oPrint:Say  (0940,100 ,AllTrim(aDadosEmp[2]) + " -  " + aDadosEmp[3] + " - " + AllTrim(aDadosEmp[4]) + " -  " + aDadosEmp[6] ,oFont8) //Endere? e Bairro, Cidade, Estado e Cep

oPrint:Say  (0980,100 ,"Data do Documento"                              		,oFont8)
cImpData := Strzero(Day(aDadosTit[2]),2)+"/"+Strzero(Month(aDadosTit[2]),2)+"/"+Strzero(Year(aDadosTit[2]),4)
oPrint:Say  (1010,100 ,cImpData                               					,oFont10) // Emissao do Titulo (E1_EMISSAO)
//oPrint:Say  (0940,100 ,DTOC(aDadosTit[2],"ddmmyyyy")                          ,oFont10) // Emissao do Titulo (E1_EMISSAO)

oPrint:Say  (0980,505 ,"Nro.Documento"                                  		,oFont8)
oPrint:Say  (1010,605 ,aDadosTit[7]+aDadosTit[1]								,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (0980,1005,"Especie Doc."                                   		,oFont8)
oPrint:Say  (1010,1050,"DM"                                     				,oFont10) //Tipo do Titulo

oPrint:Say  (0980,1355,"Aceite"                                         		,oFont8)
oPrint:Say  (1010,1455,"N"                                             			,oFont10)

oPrint:Say  (0980,1555,"Data do Processamento"                          		,oFont8)
cImpData := Strzero(Day(aDadosTit[3]),2)+"/"+Strzero(Month(aDadosTit[3]),2)+"/"+Strzero(Year(aDadosTit[3]),4)
oPrint:Say  (1010,1655,cImpData                             					,oFont10) // Data impressao
//oPrint:Say  (940,1655,DTOC(aDadosTit[3],"ddmmyyyy")                	        ,oFont10) // Data impressao

oPrint:Say  (0910,1910,"Nosso Numero"                                   		,oFont8)
oPrint:Say  (0940,1930,aDadosTit[6]                                     	    	,oFont10)

oPrint:Say  (1050,100 ,"Uso do Banco"                                   		,oFont8)
oPrint:Say  (1080,100,""                                               		      	,oFont10)

oPrint:Say  (1050,505 ,"Carteira"                                       		,oFont8)
oPrint:Say  (1080,555 ,aDadosBanco[6]                                  			,oFont10)

oPrint:Say  (1050,755 ,"Especie"                                        		,oFont8)
oPrint:Say  (1080,805 ,"R$"                                             		,oFont10)

oPrint:Say  (1050,1005,"Quantidade"                                     		,oFont8)
oPrint:Say  (1050,1555,"Valor"                                          		,oFont8)

oPrint:Say  (0980,1910,"Valor do Documento"                          			,oFont8)
oPrint:Say  (1010,1930,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99"))		,oFont10)

oPrint:Say  (1120,100 ,"Instrucoes (Todas informacoes deste bloqueto sao de exclusiva responsabilidade do Beneficiario) *** Valores expressos em R$ ***",oFont8)
oPrint:Say  (1150,100 ,aBolText[1]                                      		,oFont10)
oPrint:Say  (1200,100 ,aBolText[2]                                      		,oFont10)
oPrint:Say  (1250,100 ,aBolText[3]                                      		,oFont10)
//oPrint:Say  (1300,100 ,aBolText[4]                                      		,oFont10)
//oPrint:Say  (1350,100 ,aBolText[5]                                      		,oFont10)

oPrint:Say  (1050,1910,"(-)Desconto/Abatimento"                         		,oFont8)
If aDadosTit[15] > 0
	oPrint:Say  (1080,2010,AllTrim(Transform(aDadosTit[15],"@E 999,999,999.99")),oFont10)
Endif
oPrint:Say  (1120,1910,"(-)Outras Deducoes"                             		,oFont8)
oPrint:Say  (1190,1910,"(+)Mora/Multa"                                  		,oFont8)
oPrint:Say  (1260,1910,"(+)Outros Acrescimos"                           		,oFont8)
oPrint:Say  (1330,1910,"(=)Valor Cobrado"                                  		,oFont8)

oPrint:Say  (1400,100 ,"Pagador"                                         		,oFont8)
oPrint:Say  (1430,250 ,aDatSacado[1]+" ("+aDatSacado[2]+") CNPJ/CPF: "+aDatSacado[7]						,oFont10)
oPrint:Say  (1483,250 ,aDatSacado[3]                                    		,oFont10)
oPrint:Say  (1536,250 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5]	,oFont10) // CEP+Cidade+Estado

oPrint:Say  (1605,100 ,"Pagador/Avalista: "                               		,oFont8) 
oPrint:Say  (1605,350 ,AllTrim(aDadosEmp[1])+ " - "+aDadosEmp[6]+" - "+AllTrim(aDadosEmp[2])+ " - "+aDadosEmp[3]     	,oFont8)
oPrint:Say  (1645,1500,"Autenticao Mecanica "                        		,oFont8)

oPrint:Line (0710,1900,1400,1900 )
oPrint:Line (1120,1900,1120,2300 )
oPrint:Line (1190,1900,1190,2300 )
oPrint:Line (1260,1900,1260,2300 )
oPrint:Line (1330,1900,1330,2300 )
oPrint:Line (1400,100 ,1400,2300 )
oPrint:Line (1640,100 ,1640,2300 )

For i := 100 to 2300 step 50
	oPrint:Line( 1850, i, 1850, i+30)
Next i

oPrint:Line (2000,100,2000,2300)
oPrint:Line (2000,550,1900, 550)
oPrint:Line (2000,800,1900, 800)

//oPrint:SayBitMap(1934,100,cBmp,0400,050)		// Logo da Empresa
oPrint:SayBitMap(1910,100,cBmp,0400,075)

oPrint:Say  (1912,567,aDadosBanco[1],oFont24 )	// [1]Numero do Banco
oPrint:Say  (1934,820,CB_RN_NN[2]	,oFont14n)	//Linha Digitavel do Codigo de Barras

oPrint:Line (2100,100,2100,2300 )
oPrint:Line (2200,100,2200,2300 )
oPrint:Line (2270,100,2270,2300 )
oPrint:Line (2340,100,2340,2300 )

oPrint:Line (2200,500,2340,500)
oPrint:Line (2270,750,2340,750)
oPrint:Line (2200,1000,2340,1000)
oPrint:Line (2200,1350,2270,1350)
oPrint:Line (2200,1550,2340,1550)

oPrint:Say  (2000,100 ,"Local de Pagamento"                             		,oFont8)
oPrint:Say  (2040,100 ,"PAGAVEL EM QUALQUER AGENCIA BANCARIA ATE A DATA DO VENCIMENTO" ,oFont10)

oPrint:Say  (2000,1910,"Vencimento"                                     		,oFont8)
cImpData := Strzero(Day(aDadosTit[4]),2)+"/"+Strzero(Month(aDadosTit[4]),2)+"/"+Strzero(Year(aDadosTit[4]),4)
oPrint:Say  (2040,1930,If(Dtoc(aDadosTit[4])=="11/11/11","C/Apresentacao",cImpData),oFont10)
//oPrint:Say  (2040,2010,If(Dtoc(aDadosTit[4])=="11/11/11","C/Apresenta?o",DTOC(aDadosTit[4])),oFont10)

oPrint:Say  (2100,100 ,"Beneficiario"                                        		,oFont8)
oPrint:Say  (2140,100 ,"NOVA SRM ADM DE RECURSOS E FINANCAS SA  "			                ,oFont10) 
//oPrint:Say  (2140,100 ,AllTrim(aDadosEmp[2]) + " -  " + aDadosEmp[3] + " - " + AllTrim(aDadosEmp[4]) + " -  " + aDadosEmp[6] ,oFont8) //Endere? e Bairro, Cidade, Estado e Cep

oPrint:Say  (2100,1910,"Agencia/Codigo do Beneficiario"                         		,oFont8)
oPrint:Say  (2140,1930,aDadosBanco[9]+"-"+aDadosBanco[10]+"/"+aDadosBanco[11]+"-"+aDadosBanco[12],oFont10)

oPrint:Say  (2200,100 ,"Data do Documento"                              		,oFont8)
cImpData := Strzero(Day(aDadosTit[2]),2)+"/"+Strzero(Month(aDadosTit[2]),2)+"/"+Strzero(Year(aDadosTit[2]),4)
oPrint:Say  (2230,100 , cImpData       ,oFont10) // Emissao do Titulo (E1_EMISSAO)
//oPrint:Say  (2230,100 ,DTOC(aDadosTit[2],"ddmmyyyy")                          ,oFont10) // Emissao do Titulo (E1_EMISSAO)

oPrint:Say  (2200,505 ,"Nro.Documento"                                  		,oFont8)
oPrint:Say  (2230,605 ,aDadosTit[7]+aDadosTit[1]								,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (2200,1005,"Especie Doc."                                  			,oFont8)
oPrint:Say  (2230,1050,"DM"                                       				,oFont10) //Tipo do Titulo

oPrint:Say  (2200,1355,"Aceite"                                         		,oFont8)
oPrint:Say  (2230,1455,"N"                                             			,oFont10)

oPrint:Say  (2200,1555,"Data do Processamento"                          		,oFont8)
cImpData := Strzero(Day(aDadosTit[3]),2)+"/"+Strzero(Month(aDadosTit[3]),2)+"/"+Strzero(Year(aDadosTit[3]),4)
oPrint:Say  (2230,1655, cImpData             ,oFont10) // Data impressao
//oPrint:Say  (2230,1655,DTOC(aDadosTit[3],"ddmmyyyy")                   		,oFont10) // Data impressao

oPrint:Say  (2200,1910,"Nosso Numero"                                   		,oFont8)
oPrint:Say  (2230,1930,aDadosTit[6]                                     		,oFont10)

oPrint:Say  (2270,100 ,"Uso do Banco"                                   		,oFont8)
oPrint:Say  (2300,100,""                                      			,oFont10)

oPrint:Say  (2270,505 ,"Carteira"                                       		,oFont8)
oPrint:Say  (2300,555 ,aDadosBanco[6]		                                  	,oFont10)
                                            	
oPrint:Say  (2270,755 ,"Especie"                		                        ,oFont8)
oPrint:Say  (2300,805 ,"R$"                            	   	                 	,oFont10)

oPrint:Say  (2270,1005,"Quantidade"                                   			,oFont8)
oPrint:Say  (2270,1555,"Valor"                                          		,oFont8)

oPrint:Say  (2270,1910,"Valor do Documento"                          			,oFont8)
oPrint:Say  (2300,1930,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99"))		,oFont10)

oPrint:Say  (2340,100 ,"Instrucoes (Todas informacoes deste bloqueto sao de exclusiva responsabilidade do Beneficiario) *** Valores expressos em R$ ***",oFont8)
oPrint:Say  (2390,100 ,aBolText[1]                                      		,oFont10)
oPrint:Say  (2440,100 ,aBolText[2]												,oFont10)
oPrint:Say  (2490,100 ,aBolText[3]                                      		,oFont10)
//oPrint:Say  (2540,100 ,aBolText[4]                                      		,oFont10)
//oPrint:Say  (2590,100 ,aBolText[5]                                      		,oFont10)

oPrint:Say  (2340,1910,"(-)Desconto/Abatimento"                    			    ,oFont8)
If aDadosTit[15] > 0
	oPrint:Say  (2370,2010,AllTrim(Transform(aDadosTit[15],"@E 999,999,999.99")),oFont10)
Endif
oPrint:Say  (2410,1910,"(-)Outras Deducoes"                             		,oFont8)
oPrint:Say  (2480,1910,"(+)Mora/Multa"                                 			,oFont8)
oPrint:Say  (2550,1910,"(+)Outros Acrescimos"                           		,oFont8)
oPrint:Say  (2620,1910,"(=)Valor Cobrado"                               		,oFont8)

oPrint:Say  (2690,100 ,"Pagador"                                         		,oFont8)
oPrint:Say  (2720,250 ,aDatSacado[1]+" ("+aDatSacado[2]+") CNPJ/CPF: "+aDatSacado[7] ,oFont10)
oPrint:Say  (2773,250 ,aDatSacado[3]                                    		,oFont10)
oPrint:Say  (2826,250 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5]	,oFont10) // CEP+Cidade+Estado

oPrint:Say  (2895,100 ,"Pagador/Avalista: " 								 		,oFont8)
oPrint:Say  (2895,350 ,AllTrim(aDadosEmp[1])+ " - "+aDadosEmp[6]+" - "+AllTrim(aDadosEmp[2])+ " - "+aDadosEmp[3]     	,oFont8) //Nome + CNPJ
oPrint:Say  (2935,1500,"Autenticacao Mecanica - "                        		,oFont8)
oPrint:Say  (2935,1850,"Ficha de Compensacao"                           		,oFont8)

oPrint:Line (2000,1900,2690,1900 )
oPrint:Line (2410,1900,2410,2300 )
oPrint:Line (2480,1900,2480,2300 )
oPrint:Line (2550,1900,2550,2300 )
oPrint:Line (2620,1900,2620,2300 )
oPrint:Line (2690,100 ,2690,2300 )

oPrint:Line (2930,100,2930,2300  )

MSBAR3("INT25",25.2,1.5,CB_RN_NN[1],oPrint,.F.,,,,1.2,,,,.F.)

For i := 100 to 2300 step 50
	oPrint:Line( 3220, i, 3220, i+30)
Next i

DbSelectArea("SE1")
RecLock("SE1",.f.)
SE1->E1_NUMBCO :=	Substr(CB_RN_NN[3],4,11) + Substr(CB_RN_NN[3],16,1)
MsUnlock()

oPrint:EndPage() // Finaliza a p?ina

Return Nil



/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?Modulo10 ?Autor ?                      ?Data ?         ??
???????????????????????????????????????
??escri?o ?IMPRESSAO DO BOLETO LASE DO BANCO NOVA SRM ADM DE RECURSOS E FINANCAS SA  (Bradesco)COM CODIGO DE BARRAS ??
???????????????????????????????????????
??so       ?Especifico para Clientes Microsiga                         ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
Static Function Modulo10(cData)
LOCAL L, D, P, nInt := 0
L := Len(cdata)
D := 0
P := 2
N := 0

While L > 0
	N := (Val(SubStr(cData, L, 1)) * P)
	If N > 9
		D := D + (Val(SubsTr(Str(N,2),1,1)) + Val(SubsTr(Str(N,2),2,1)))
	Else
		D := D + N
	Endif
	If P = 2
		P := 1
	Elseif P = 1
		P := 2
	EndIf
	L := L - 1
End
nInt := (Int((D / 10)) + 1) * 10
D:= nInt - D

If D == 10
	D:=0
Endif

Return(D)

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?Modulo11 ?Autor ?                      ?Data ?         ??
???????????????????????????????????????
??escri?o ?IMPRESSAO DO BOLETO LASE DO BANCO SRM (Bradesco) COM CODIGO DE BARRAS ??
???????????????????????????????????????
??so       ?                                                           ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
Static Function Modulo11(cData) //Modulo 11 com base 7

LOCAL L, D, P := 0

L := Len(cdata)
D := 0
P := 1
DV:= " "

While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 7   //Volta para o inicio, ou seja comeca a multiplicar por 2,3,4...
		P := 1
	End
	L := L - 1
End

_nResto := mod(D,11)  //Resto da Divisao
D := 11 - _nResto
DV:=STR(D)

If _nResto == 0
	DV := "0"
End
If _nResto == 1
	DV := "P"
End

Return(DV)


/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?Mod11CB  ?Autor ?                      ?Data ?         ??
???????????????????????????????????????
??escri?o ?IMPRESSAO DO BOLETO LASE DO BANCO SRM (Bradesco) COM CODIGO DE BARRAS ??
???????????????????????????????????????
??so       ?                                                           ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
Static Function Mod11CB(cData) // Modulo 11 com base 9

LOCAL CBL, CBD, CBP := 0

CBL := Len(cdata)
CBD := 0
CBP := 1

While CBL > 0
	CBP := CBP + 1
	CBD := CBD + (Val(SubStr(cData, CBL, 1)) * CBP)
	If CBP = 9
		CBP := 1
	End
	CBL := CBL - 1
End

_nCBResto := mod(CBD,11)  //Resto da Divisao
CBD := 11 - _nCBResto

If (CBD == 0 .Or. CBD == 1 .Or. CBD > 9)
	CBD := 1
End

Return(CBD)


//Retorna os strings para inpress? do Boleto
//CB = String para o c?.barras, RN = String com o n?ero digit?el
//Cobran? n? identificada, n?ero do boleto = T?ulo + Parcela
/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?et_cBarra?Autor ?                      ?Data ?         ??
???????????????????????????????????????
??escri?o ?IMPRESSAO DO BOLETO LASE DO BANCO SRM (Bradesco) COM CODIGO DE BARRAS ??
???????????????????????????????????????
??so       ?                                                           ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor)

//LOCAL BlDocNuFinal := cAgencia + Strzero(val(cNroDoc),7) DESABILITADO OSMIL
LOCAL BlDocNuFinal := Strzero(val(cNroDoc),11)
LOCAL blvalorfinal := Strzero(nValor*100,10)
LOCAL dvnn         := 0
LOCAL dvcb         := 0
LOCAL dv           := 0
LOCAL NN           := ''
LOCAL RN           := ''
LOCAL CB           := ''
LOCAL s            := ''
LOCAL cMoeda       := "9"
Local cFator := Strzero(SE1->E1_VENCTO - ctod("07/10/97"),4)

//Montagem no NOSSO NUMERO
//   s :=  cAgencia + cConta + cCarteira + bldocnufinal
snn := bldocnufinal     // Agencia + Numero (pref+num+parc)
// RAI
//dvnn := modulo10(s)  //Digito verificador no Nosso Numero
dvnn := modulo11(cCarteira+snn)  //Digito verificador no Nosso Numero

//[RAI] NN := '/' + bldocnufinal + '-' + AllTrim(Str(dvnn))
NN := cCarteira +"/"+ bldocnufinal +'-'+ AllTrim(dvnn)

_cLivre := cAgencia+cCarteira+bldocnufinal+cConta+"0" // -- Davis Implementado o Zero

scb := cBanco + cMoeda+ cFator + blvalorfinal	+ _cLivre
dvcb := mod11CB(scb)	//digito verificador do codigo de barras

CB := SubStr(scb,1,4)+AllTrim(Str(dvcb))+SubStr(scb,5,39)

//MONTAGEM DA LINHA DIGITAVEL
srn := cBanco + cMoeda + Substr(_cLivre,1,5) //Codigo Banco + Codigo Moeda + 5 primeiros digitos do campo livre
dv := modulo10(srn,1,5)
RN := SubStr(srn,1,5) + '.' + SubStr(srn,6,4) + Alltrim(Str(DV)) + '  '

srn := SubStr(_cLivre,6,10)	// posicao 6 a 15 do campo livre
dv := modulo10(srn)
RN := RN + SubStr(srn,1,5)+'.'+SubStr(srn,6,5)+AllTrim(Str(dv))+'  '

srn := SubStr(_cLivre,16,10)	// posicao 6 a 15 do campo livre
dv := modulo10(srn)
RN := RN + SubStr(srn,1,5)+'.'+SubStr(srn,6,5)+AllTrim(Str(dv)) + '  '

RN := RN + AllTrim(Str(dvcb))+'  '
RN := RN + cFator
RN := RN + Strzero(nValor * 100,10)

Return({CB,RN,NN})



/*
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?uscaNF   ?utor  ?icrosiga           ?Data ? 12/27/06   ??
???????????????????????????????????????
??esc.     ?usca titulos principais que compoem a Fatuta               ??
??         ?                                                           ??
???????????????????????????????????????
??so       ?AP                                                        ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
Static Function BUSCANF(cPrefFat,cNumFat)

Local cRet := " "
Local cQuery := ""

cQuery	:= " SELECT * FROM " + RetSqlName("SE1") "
cQuery	+= " WHERE E1_FILIAL = '"+ xFilial("SE1") + "' AND "
cQuery	+= " E1_FATURA  = '"+ cNumFat + "' AND "
cQuery	+= " E1_FATPREF = '"+ cPrefFat + "' AND "
cQuery	+= " D_E_L_E_T_ <> '*' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QUERY",.T.,.T.)

dbSelectArea("QUERY")
dbGotop()

While !Eof()
	cRet += QUERY->E1_NUM + "/"
	dbSelectArea("QUERY")
	dbSkip()
End

dbSelectArea("QUERY")
dbCloseArea("QUERY")

Return(cRet)


/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o	 ?ALIDPERG ?Autor ? Luiz Carlos Vieira	?Data ?03/07/97   ??
???????????????????????????????????????
??escri?o ?Verifica as perguntas incluindo-as caso nao existam		  ??
???????????????????????????????????????
??so		 ?                           					                 ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
Static Function ValidPerg(cPerg)

Local cLAlias := Alias()
Local aRegs   := {}   
Local aHelpPor := {} //help da pergunta

//Do Prefixo	?
AADD(aHelpPor,"Prefixo do Tiulo a Receber		")
AADD(aHelpPor,"a ser considerado pela rotina.	")
PutSx1(cPerg,"01","Do Prefixo		?","a","a","MV_CH1","C",TamSX3("E1_PREFIXO")[1],0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,{},{},"")

//Ate o Prefixo
aHelpPor := {} 
AADD(aHelpPor,"Prefixo do Titulo a Receber		")
AADD(aHelpPor,"a ser considerado pela rotina.	")
PutSx1(cPerg,"02","Ate o Prefixo	?","a","a","MV_CH2","C",TamSX3("E1_PREFIXO")[1],0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,{},{},"")

//Do Titulo
aHelpPor := {} 
AADD(aHelpPor,"Numero inicial do Tiulo a Receber		")
AADD(aHelpPor,"a ser considerado pela rotina.			")
PutSx1(cPerg,"03","Do Titulo		?","a","a","MV_CH3","C",TamSX3("E1_NUM")[1],0,0,"G","","","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,{},{},"")
                                                                                                         
//At?o T?ulo
aHelpPor := {} 
AADD(aHelpPor,"Numero final do  Tiulo a Receber		")
AADD(aHelpPor,"a ser considerado pela rotina.			")
PutSx1(cPerg,"04","Ate o T?ulo		?","a","a","MV_CH4","C",TamSX3("E1_NUM")[1],0,0,"G","","","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,{},{},"")

//Da Parcela
aHelpPor := {} 
AADD(aHelpPor,"Parcela inicial do Tiulo a Receber		")
AADD(aHelpPor,"a ser considerado pela rotina. 			")
PutSx1(cPerg,"05","Da Parcela		?","a","a","MV_CH5","C",TamSX3("E1_PARCELA")[1],0,0,"G","","","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPor,{},{},"")
                                                                                                             
//Ate a Parcela
aHelpPor := {} 
AADD(aHelpPor,"Parcela final do Tiulo a Receber		")
AADD(aHelpPor,"a ser considerado pela rotina.  			")
PutSx1(cPerg,"06","Ate a Parcela	?","a","a","MV_CH6","C",TamSX3("E1_PARCELA")[1],0,0,"G","","","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPor,{},{},"")
  
//Do Portador
aHelpPor := {} 
AADD(aHelpPor,"Portador do Tiulo a Receber		")
AADD(aHelpPor,"a ser considerado pela rotina.	")
PutSx1(cPerg,"07","Do Portador		?","a","a","MV_CH7","C",TamSX3("E1_PORTADO")[1],0,0,"G","","SA6","","","MV_PAR07","","","","","","","","","","","","","","","","",aHelpPor,{},{},"")

//Ate o Portador                                                                                                                                                                       
aHelpPor := {} 
AADD(aHelpPor,"Portador do Tiulo a Receber		")
AADD(aHelpPor,"a ser considerado pela rotina.	")
PutSx1(cPerg,"08","Ate o Portador	?","a","a","MV_CH8","C",TamSX3("E1_PORTADO")[1],0,0,"G","","SA6","","","MV_PAR08","","","","","","","","","","","","","","","","",aHelpPor,{},{},"")

//Do Cliente
aHelpPor := {} 
AADD(aHelpPor,"Cliente do Tiulo a Receber		")
AADD(aHelpPor,"a ser considerado pela rotina.	")
PutSx1(cPerg,"09","Do Cliente		?","a","a","MV_CH9","C",TamSX3("E1_CLIENTE")[1],0,0,"G","","SA1","","","MV_PAR09","","","","","","","","","","","","","","","","",aHelpPor,{},{},"")

//At?o Cliente
aHelpPor := {} 
AADD(aHelpPor,"Cliente do Tiulo a Receber		")
AADD(aHelpPor,"a ser considerado pela rotina.	")
PutSx1(cPerg,"10","Do Cliente		?","a","a","MV_CHA","C",TamSX3("E1_CLIENTE")[1],0,0,"G","","SA1","","","MV_PAR10","","","","","","","","","","","","","","","","",aHelpPor,{},{},"")

//Da Loja
aHelpPor := {} 
AADD(aHelpPor,"Loja do Cliente responsavel 		")
AADD(aHelpPor,"pelo Titulo a Receber	   		")
AADD(aHelpPor,"a ser considerado pela rotina.  	")
PutSx1(cPerg,"11","Da Loja		?","a","a","MV_CHB","C",TamSX3("E1_LOJA")[1],0,0,"G","","","","","MV_PAR11","","","","","","","","","","","","","","","","",aHelpPor,{},{},"")   

//At?a Loja
aHelpPor := {} 
AADD(aHelpPor,"Loja do Cliente responsavel 		")
AADD(aHelpPor,"pelo Titulo a Receber	   		")
AADD(aHelpPor,"a ser considerado pela rotina.  	")
PutSx1(cPerg,"12","Ate a Loja		?","a","a","MV_CHC","C",TamSX3("E1_LOJA")[1],0,0,"G","","","","","MV_PAR12","","","","","","","","","","","","","","","","",aHelpPor,{},{},"")

//Do Vencimento
aHelpPor := {} 
AADD(aHelpPor,"Data do Vencimento do Tttulo a Receber	")
AADD(aHelpPor,"a ser considerado pela rotina.  			")
PutSx1(cPerg,"13","Do Vencimento		?","a","a","MV_CHD","D",TamSX3("E1_VENCTO")[1],0,0,"G","","","","","MV_PAR13","","","","","","","","","","","","","","","","",aHelpPor,{},{},"")

//At?o Vencimento
aHelpPor := {} 
AADD(aHelpPor,"Data do Vencimento do Titulo a Receber	")
AADD(aHelpPor,"a ser considerado pela rotina.  			")
PutSx1(cPerg,"14","Do Vencimento		?","a","a","MV_CHE","D",TamSX3("E1_VENCTO")[1],0,0,"G","","","","","MV_PAR14","","","","","","","","","","","","","","","","",aHelpPor,{},{},"")

//Da Emiss?
aHelpPor := {} 
AADD(aHelpPor,"Data de Emissao do Titulo a Receber	")
AADD(aHelpPor,"a ser considerado pela rotina.  		")
PutSx1(cPerg,"15","Da Emissao		?","a","a","MV_CHF","D",TamSX3("E1_EMISSAO")[1],0,0,"G","","","","","MV_PAR15","","","","","","","","","","","","","","","","",aHelpPor,{},{},"")

//At?a Emiss?
aHelpPor := {} 
AADD(aHelpPor,"Data de Emissao do Tiulo a Receber	")
AADD(aHelpPor,"a ser considerado pela rotina.  		")
PutSx1(cPerg,"16","At?a Emissao?		?","a","a","MV_CHG","D",TamSX3("E1_EMISSAO")[1],0,0,"G","","","","","MV_PAR16","","","","","","","","","","","","","","","","",aHelpPor,{},{},"")

//Seleciona T?ulos
aHelpPor := {} 
PutSx1(cPerg,"17","Seleciona T?ulos	?","a","a","MV_CHH","C",01,0,0,"C","","","","","MV_PAR17","Sim","","","","N?","","","","","","","","","","","",aHelpPor,{},{},"")

//Seleciona T?ulos
aHelpPor := {}
AADD(aHelpPor,"Tipo de Carteira do Titulo a Receber	 ")
AADD(aHelpPor,"a ser considerado pela rotina.  		 ") 
AADD(aHelpPor,"Com Registro / Sem Registro ") 
PutSx1(cPerg,"18","Carteira				?","a","a","MV_CHI","C",01,0,0,"C","","","","","MV_PAR18","Com Registro","","","","Sem Registro","","","","","","","","","","","",aHelpPor,{},{},"")

Return