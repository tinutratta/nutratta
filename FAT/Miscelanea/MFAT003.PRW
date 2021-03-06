#INCLUDE "APWIZARD.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch" 
#INCLUDE "TBICONN.CH" 
#include "Rwmake.ch"

#Define  _CRLF  CHR(13)+CHR(10)

//--------------------------------------------------------------------------
/* {Protheus.doc} MFAT003
Rotina para realizar a importa��o da tabela de pre�o.


Criar campo DA1_COND e indice.
DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_COND

Empresa - Copyright -Nutratta Nutri��o Animal.
@author Davidson Clayton
@since 18/10/2017.
@version P11 R8
*/
//--------------------------------------------------------------------------  
User Function MFAT003() 

Local cTexto1   := ""
Local cTexto2   := ""
Local cTexto3   := ""
Local cTexto4   := "" 
Local aTexto    := {}
Local aTxtPre 	:= {}
Local cMsgErro	:= "Erros encontrados durante a importa��o dos arquivos " +_CRLF + _CRLF

Private oWizard
Private cArq1	:= Space(200)
Private cArq2	:= Space(200)
Private cArq3	:= Space(200)

Private cMesAno	:= Space(7)
Private cTipo	:=""
Private cErros	:= ""
Private lContinua:=.T.
Private cMessage:="Processo de importa��o finalizado...!" 
Private cCamArq	:=""
   
//�����������������������������������������Ŀ
//�Monta wizard com as perguntas necessarias�
//�������������������������������������������
aAdd(aTxtPre,"Importa��o da tabela de pre�o Nutratta.") //1
aAdd(aTxtPre,"Aten��o")                    //2
aAdd(aTxtPre,"Informe o arquivo a ser importado (Tabela de pre�o Nutratta.)")//3
aAdd(aTxtPre,"Finaliza��o da importa��o.")              //4

cTexto1 := "Esta rotina tem como objetivo importar a tabela de pre�o Nutratta "
cTexto2 := "para atender as regras de comissionamento de 2017."
cTexto3 := "Onde o comissionamento ser� realizado por item e n�o mais por pedido de venda."
 

aAdd(aTexto,cTexto1+cTexto2+cTexto3)

DEFINE WIZARD oWizard ;
	TITLE aTxtPre[1]; 
	HEADER aTxtPre[2];
	MESSAGE aTxtPre[1];
	TEXT aTexto[1] ;
	NEXT {|| .T.} ;
	FINISH {|| .T.} ; 



CREATE PANEL oWizard  ;
	HEADER aTxtPre[3] ;
	MESSAGE ""	;
	BACK {|| .T.} ;
	NEXT {|| Iif(fValNext(),fProcessa(),.F.)} ;   
	PANEL

TSay():New(044,010,{||"Tabela de pre�o (CSV):"},oWizard:oMPanel[2],,,,,,.T.,CLR_HBLUE,CLR_WHITE,100,008)
TGet():New(056,010,{|u| if(PCount()>0,cArq1:=u,cArq1)},oWizard:oMPanel[2],150,008,,{|| },,,,,,.T.,,,,,,,,,"","cArq1")
TButton():New(056,162,"...",oWizard:oMPanel[2],{|| fGetArq(@cArq1,'.csv')},010,010,,,,.T.,,"",,,,.F. )
                                           
                                   
CREATE PANEL oWizard  ;
HEADER aTxtPre[4] ;
MESSAGE ""	;
BACK {|| .F.} ;
FINISH {|| .T.} ;
PANEL
 
@ 030,010 SAY cMessage SIZE 270,020 COLOR CLR_BLUE PIXEL OF oWizard:oMPanel[3]

ACTIVATE WIZARD oWizard CENTERED
	
If !Empty(AllTrim(cErros))
	
	cMsgErro += cErros 
	
	Aviso("Erros Importa��o",cMsgErro,{"Voltar"},3)
	
EndIf

Return    


Static Function fGetArq(cCamArq,cTipoArq)
/******************************************
** Abre tela para usu�rio escolher o arquivos
**
**********/

Local nOpc	:= GETF_LOCALHARD+GETF_NETWORKDRIVE//GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE
			   
cCamArq := cGetFile('Arquivo |*'+cTipoArq,'Selecione  arquivo para importa��o',,'C:\',.T.,nOpc,.F.)

Return 


Static Function fProcessa()
/******************************************
** Fun��o para mostrar a regua de processamento....
**
****************/
	                       
	Processa({|| fImporta()}, 'Aguarde....')                         

Return(.T.)  



Static Function fImporta()
/******************************************
** Importa��o dos arquivos tabela de pre�o
**
****************/

fImpTblNut() 

Return(.T.)



Static Function fImpTblNut()
/******************************************************
** Rotina para leitura e grava��o da tabela de pre�o
**
****************/

Local _aArea		:= GetArea()
Local cCodTAtu		:=""
Local cCodAntBl		:=""
Local cVigula       :=""
Local nDecimal      :=0
Local lContinua		:=.T.

Private _cCabecalho := "DA0"  //Cabecalho
Private _cDetalhe	:= "DA1"  //Detalhe
Private nPosProd	:= 0
Private nPosRegi	:= 0
Private nPosFret	:= 0
Private nPosVend	:= 0
Private nPosCli		:= 0
Private nPosDtIn	:= 0
Private nPosDtFim	:= 0
Private _nPorcMin	:= 0
Private _nPorcMax	:= 0
Private _nPrMin		:= 0
Private _nPrMax		:= 0
Private nCount		:= 0
Private nMasc		:='@E 99999,999'
Private lCabec		:= .T.
Private cLinha		:= ""
Private nHandle
Private cDescProd	:="" 
Private cMensagem	:=""
Private aLinha		:= {}

If Aviso("Aten��o","Confirma a importa��o da tabela de pre�o Nutratta "+UPPER(MV_PAR01)+"?",{"Sim","N�o"}) <> 1
	RestArea(_aArea)
	Return()
EndIf

//-----------------------------------------------------------------------------------
// Realiza a limpeza da tabela DA1 para importa��o.
//-----------------------------------------------------------------------------------           
fDelDA1()

nHandle := FT_Fuse( ALLTRIM(cArq1))

If nHandle == -1                                                                     
	MsgStop("Erro de abertura do arquivo de importa��o.")
    RestArea(_aArea)
	Return()
Else
	cLinha := FT_FReadln()
    
    //Valida a primeira linha do arquivo com a tabela DA1.
	lStop	:="DA1" $ AllTrim(UPPER(SubStr(cLinha,1,3))) .Or. "DA1" $ AllTrim(UPPER(SubStr(cLinha,4,7)))
	If !lStop 	// se tabela sem cabecalho
		MsgStop("Tabela sem cabe�alho. Favor corrig�-la para importa��o.")
	    RestArea(_aArea)
		Return()
	EndIf

	//monta array com linha do cabecalho
	aLinha	  := StrToKarr(cLinha,';')
	//salva posicoes das colunas do array 
	nPosFilial  := aScan(aLinha,"DA1_FILIAL")
	nPosCodTab 	:= aScan(aLinha,"DA1_CODTAB")
	nPosCond 	:= aScan(aLinha,"DA1_COND") 
	nPosDecond 	:= aScan(aLinha,"DA1_DESCON")
	nPosProd 	:= aScan(aLinha,"DA1_CODPRO")
	nPosDescri 	:= aScan(aLinha,"DA1_DESCRI")
	nPosAvista 	:= aScan(aLinha,"DA1_VISTA")
	nPos0000 	:= aScan(aLinha,"DA1_0000")
	nPos0025 	:= aScan(aLinha,"DA1_0025")
	nPos0050 	:= aScan(aLinha,"DA1_0050")
	nPos0075 	:= aScan(aLinha,"DA1_0075")
	nPos0100 	:= aScan(aLinha,"DA1_0100")
	nPos0125 	:= aScan(aLinha,"DA1_0125")
	nPos0150 	:= aScan(aLinha,"DA1_0150")
	nPos0200 	:= aScan(aLinha,"DA1_0200")
	nPos0225 	:= aScan(aLinha,"DA1_0225")
	nPos0250 	:= aScan(aLinha,"DA1_0250")
	nPos0275 	:= aScan(aLinha,"DA1_0275")
	nPos0300 	:= aScan(aLinha,"DA1_0300")
	nPos0325 	:= aScan(aLinha,"DA1_0325")
	nPos0350 	:= aScan(aLinha,"DA1_0350")
	nPos0375 	:= aScan(aLinha,"DA1_0375")
	nPos0400 	:= aScan(aLinha,"DA1_0400")
	nPos0425 	:= aScan(aLinha,"DA1_0425")
	nPos0450 	:= aScan(aLinha,"DA1_0450")
	nPos0475 	:= aScan(aLinha,"DA1_0475")
	nPos0500 	:= aScan(aLinha,"DA1_0500")
	nPos0525 	:= aScan(aLinha,"DA1_0525")
	nPos0550 	:= aScan(aLinha,"DA1_0550")
	nPos0575 	:= aScan(aLinha,"DA1_0575")
	nPos0600 	:= aScan(aLinha,"DA1_0600")
	nPos0625 	:= aScan(aLinha,"DA1_0625") 
	nPos0650 	:= aScan(aLinha,"DA1_0650")                                      
	nPos0675 	:= aScan(aLinha,"DA1_0675")
	nPos0700 	:= aScan(aLinha,"DA1_0700")
	nPos0725 	:= aScan(aLinha,"DA1_0725") 
	nPos0750 	:= aScan(aLinha,"DA1_0750") 
	nPos0775 	:= aScan(aLinha,"DA1_0775")
	nPos0800 	:= aScan(aLinha,"DA1_0800")
	nPos0900 	:= aScan(aLinha,"DA1_0900")	       
	nPos1000 	:= aScan(aLinha,"DA1_1000")
	nPos1100 	:= aScan(aLinha,"DA1_1100")
	nPos1200 	:= aScan(aLinha,"DA1_1200")
	nPos1300 	:= aScan(aLinha,"DA1_1300")
	nPos1400 	:= aScan(aLinha,"DA1_1400")
	nPos1500 	:= aScan(aLinha,"DA1_1500")
	nPos1600 	:= aScan(aLinha,"DA1_1600")
	nPos1700 	:= aScan(aLinha,"DA1_1700")
	nPos1800 	:= aScan(aLinha,"DA1_1800")
	nPos1900 	:= aScan(aLinha,"DA1_1900")
	nPos2000 	:= aScan(aLinha,"DA1_2000")
			
	//salva percetuais min e max, ultimas posicoes do array primeira linha
	_nPorcMin := Val(StrTran(aLinha[Len(aLinha)-1],",","."))
	_nPorcMax := Val(StrTran(aLinha[Len(aLinha)],",","."))
	
	ProcRegua(RecCount())

	FT_FSKIP()	//posiciona na segunda linha

	While !FT_FEOF()	//enquanto nao finalizar o arquivo
		
		IncProc()
		
		//salva string da linha e monta array
		cLinha := FT_FReadln()
		aLinha := StrToKarr(cLinha,';')

        //Salva no cabecalho, itens da segunda linha
//		lCabec := .F.	//salva itens cabecalho apenas 1 vez
		
		//salva cabecalho
		DbSelectArea(_cCabecalho)
		(_cCabecalho)->(DbSetOrder(1))//DA0_FILIAL+DA0_CODTAB
		lExist:=(_cCabecalho)->(DbSeek(xFilial(_cCabecalho)+StrZero(Val(aLinha[nPosCodTab]),3)))
		RecLock(_cCabecalho,!lExist)
		DA0->DA0_FILIAL  := xFilial(_cCabecalho)
		DA0->DA0_CODTAB  := StrZero(Val(aLinha[nPosCodTab]),3)
		
		//Tabela diferente de inativa
	 	If DA0->DA0_ATIVO <> "2"
			DA0->DA0_DATDE   := dDataBase
			DA0->DA0_ATIVO   := "1"
			DA0_TPHORA		 := "1"
            EndIf

		(_cCabecalho)->(MSUnLock())
           
		//-----------------------------------------------
		// Exibe o alerta de nova tablea a ser ativada
		//-----------------------------------------------
	 	If !lExist
			
			cCodTAtu:=StrZero(Val(aLinha[nPosCodTab]),3)
			If cCodTAtu <> cCodAntBl
				MsgAlert("Nova tabela cadastrada "+"- "+StrZero(Val(aLinha[nPosCodTab]),3)+" - "+" Nomea-l�")
		    EndIf
		    cCodAntBl :=cCodTAtu
		EndIf
		
		/******************************************
		** Fun��o para buscar o primeiro campo 
		**preenchido para preecher o pre�o de venda.
		**
		**********/
		For nxg := 7 To Len(aLinha)
		    
		    If Alltrim(StrTran(Alltrim(StrTran(aLinha[nxg],'R$','')),"-","")) <> ""
		    	
		    	cPrcVend:=Alltrim(StrTran(aLinha[nxg],'R$',''))
		    	exit
		    EndIf
		Next
		
		//----------------------------------------------------------------------------------------
		//Realiza a valida��o das casas decimais se estiver com 2 casas no arquivo nao prossegue
		//----------------------------------------------------------------------------------------           
           For nI := 1 To  Len(cPrcVend)
               
               cVigula:=(SubStr(cPrcVend,nI,1))
               If cVigula $ "," 
	               	nDecimal:= Len(cPrcVend) - nI	     
	               	If nDecimal < 3 
	 	               MsgAlert("Aquivo com 2 casas decimais nos campos de valores,gentileza verificar.")
	               	   lContinua:=.F.
	               	   exit
	               EndIf
               EndIf
            Next nI
       
		//-----------------------------------------------------------------------------------
		// Caso estseja tudo ok prossegue com a grava��o.
		//-----------------------------------------------------------------------------------           
		If lContinua
		
			//Salva itens tabela
			DbSelectArea(_cDetalhe)
			(_cDetalhe)->(DbSetOrder(7))//DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_COND	
			lExist:=(_cDetalhe)->(DbSeek(xFilial(_cDetalhe)+StrZero(Val(aLinha[nPosCodTab]),3)+aLinha[nPosProd]+StrZero(Val(aLinha[nPosCond]),3)))  
			RecLock(_cDetalhe,!lExist)
		
            //Incrementa o sequencial do Item
			If !lExist
				DA1->DA1_ITEM  		:= fProximo() 
			EndIf
			
			/************************************************
			** Verifica se o produto esta cadastrado.  			** 
			** e gera um log para exibir uma mensagem no final  **
			***************************************************
			*/                                      
			cDescProd:= Posicione("SB1",1,xFilial("SB1")+aLinha[nPosProd],"B1_DESC")
			
			If Empty(cDescProd)
			     
				//Gerar arquivo txt no C:
				cMensagem+=	"Produto n�o cadastrado: "+aLinha[nPosProd]+" - "+aLinha[nPosDescri]+Chr(13)+Chr(10)
			EndIf 
			
						
			/******************************************
			** Tratamento para unidade de medida  
			** onde s�o definidas mascaras e arredondamento.
			***********************************************/
			/*
			TL
			nRoudn:=0 
			nMasc:='@E 99999,99')
			
			UN
			nRoudn:=2 
			nMasc:='@E 99999,999')
			*/
			
            cUnidade			:=Posicione("SB1",1,xFilial("SB1")+aLinha[nPosProd],"B1_UM")
			
			If   cUnidade == "TL"
				
				nRoudn	:=0 
				nMasc	:='@E 99999,999'
			ElseIf cUnidade == "UN"
			
				nRoudn	:=2 
		  		nMasc	:='@E 99999,999'
			EndIf
			
			DA1->DA1_FILIAL  	:= "01"			
			DA1->DA1_CODTAB  	:= StrZero(Val(aLinha[nPosCodTab]),3)
			DA1_COND	       	:= StrZero(Val(aLinha[nPosCond]),3)
			DA1->DA1_CODPROD    := aLinha[nPosProd]
			DA1_DESCON			:= Posicione("SE4",1,xFilial("SE4")+StrZero(Val(aLinha[nPosCond]),3),"E4_DESCRI")
			DA1_ATIVO			:= "1"
			DA1_TPOPER			:="4"                    
			DA1_QTDLOT			:=999999.99
			DA1_MOEDA			:=1
			DA1_PRCVEN		 	:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(cPrcVend),'R$',' '),',',''),'.','')),nMasc)),nRoudn)
			DA1_VISTA			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPosAvista]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 
			DA1_0000			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0000]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 																					
			DA1_0025            :=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0025]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 
			DA1_0050			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0050]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)
			DA1_0075			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0075]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)  
			DA1_0100			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0100]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)
			DA1_0125			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0125]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)
			DA1_0150			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0150]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)
			DA1_0200			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0200]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)
			DA1_0225			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0225]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)
			DA1_0250			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0250]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)
			DA1_0275			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0275]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)
			DA1_0300			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0300]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 
			DA1_0325			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0325]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)  
			DA1_0350			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0350]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 
			DA1_0375			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0375]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 
			DA1_0400			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0400]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 
			DA1_0425			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0425]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 			
			DA1_0450			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0450]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 			
			DA1_0475			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0475]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 			
			DA1_0500			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0500]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 
			DA1_0525			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0525]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 
			DA1_0550			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0550]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 
			DA1_0575			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0575]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 
			DA1_0600			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0600]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 
			DA1_0625			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0625]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 
			DA1_0650			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0650]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 			
			DA1_0675			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0675]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)                                                                                              
			DA1_0700			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0700]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)  
			DA1_0725			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0725]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)  
			DA1_0750			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0750]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)  
			DA1_0775			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0775]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)  
			DA1_0800			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0800]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)   
			DA1_0900	       	:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos0900]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)   
			DA1_1000			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos1000]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 
			DA1_1100			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos1100]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 
			DA1_1200			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos1200]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 
			DA1_1300			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos1300]),'R$',' '),',',''),'.','')),nMasc)),nRoudn) 
			DA1_1400			:=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos1400]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)  
			DA1_1500            :=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos1500]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)
			DA1_1600            :=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos1600]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)
			DA1_1700            :=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos1700]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)
			DA1_1800            :=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos1800]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)
			DA1_1900            :=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos1900]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)                                                                                                                                     
			DA1_2000            :=Round(Val(Transform(Val(StrTran(StrTran(StrTran(AllTrim(aLinha[nPos2000]),'R$',' '),',',''),'.','')),nMasc)),nRoudn)			
			
			(_cDetalhe)->(MSUnLock())

			nCount++
			FT_FSKIP()
   		Else
   			exit
   		EndIf
   EndDo
EndIf

If nCount == 0
	MsgAlert("Nenhum registro importado. Verificar tabela "+UPPER(MV_PAR01)+".")
Else                

	MsgInfo(" "+cValToChar(nCount)+" Registros da Tabela de Pre�os "+UPPER(MV_PAR01)+" importados com sucesso!") 
	
	
	/************************************************************
	* Gerar o arquivo txt com o log dos produtos n�o cadastrados. 
	*************************************************************/
	//U_OkGeraTXT(cMensagem)

Endif

DbCloseArea(_cCabecalho)
DbCloseArea(_cDetalhe)
RestArea(_aArea)

Return()
       



Static Function fValNext()
/******************************************
** Valida campos de sele��o da importa��o
**
**********/                             

Local lRet := .T.


Return(lRet)    

         

Static Function fProximo()
/******************************************
** Fun��o para buscar o proximo numero de item na 
** tabela DA1.
**********/     
Local _nSequen:=0
Local _cArea := GetArea()
Local _cQuery := ""

_cQuery := " SELECT MAX(DA1_ITEM) AS ITEM "
_cQuery += " FROM " + RetSqlName("DA1")
_cQuery += " WHERE  D_E_L_E_T_ = ' '"

TcQuery _cQuery New Alias "TRB"
dbSelectArea("TRB")

_nSequen := Soma1(Alltrim(TRB->ITEM))

If Empty(_nSequen)
	_nSequen:="0001"
EndIf

dbSelectArea("TRB")
dbCloseArea("TRB")
             
RestArea(_cArea)

Return(_nSequen) 

           
/*
========================================================================================================================
Rotina----: OkGeraTXT
Autor-----: Davidson - Nutratta
Data------: 08/08/2017
========================================================================================================================
Descri��o-: Rotina para gera��o do arquivo Txt dos produtos n�o cadastrados.
Uso-------: Especifico Nutratta.
========================================================================================================================
*/
User Function OkGeraTXT(cMensagem)

Local cArq
Local nHdl
Local cLinha
                                
/********************************************************************** 
 Se for especificado o drive no caminho do arquivo, sera criado no
 Client, caso contrario sera criado no Server, no diretorio RooPath.
***********************************************************************/
cLog1 := cMensagem		
	
nHdl := FCreate("C:\Log\Log_PRDNAOCAD_"+DToS(DDataBase)+".txt")
	
If nHdl <> -1
	FWrite(nHdl,cLog1)
	FClose(nHdl)
	MsgAlert("Arquivo de Log salvo na pasta: C:\Log\Log_PRDNAOCAD_"+DToS(DDataBase)+".txt")
Else
	MsgAlert("Alerta")
EndIf

FClose(nHdl)

Return

   
/*
========================================================================================================================
Rotina----: fDelDA1
Autor-----: Davidson
Data------: 09/10/2017
========================================================================================================================
Descri��o-: Fun��o para dele��o DA1 antes da importa��o.
Uso-------: 
========================================================================================================================
*/
Static Function fDelDA1() 

DbSelectArea("DA1")
DbGoTop()
While !Eof()

	IncProc()

	RecLock("DA1",.F.)
	DbDelete()
	MsUnLock()
	
	DbSelectArea("DA1")
	DbSkip()
End 

Return


