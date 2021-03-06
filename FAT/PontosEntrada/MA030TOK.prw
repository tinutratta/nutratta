#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
//--------------------------------------------------------------------------
/* {Protheus.doc} MA030TOK
Ponto de entrada na grava��o do cadastro de cliente
permitindo ao usuario excessao de preenchimento 
atraves do parametro NT_USUCLI   =Usuarios do cadastro rapido de clientes
Empresa - Copyright -Nutratta Nutri��o Animal.

@author Davidson Clayton
@since 25/08/2017
@version P11 R8
*/
//--------------------------------------------------------------------------
User Function MA030TOK()

Local aAreaCli	:= GetArea()
Local lExecuta 	:= .T.
Local cUsuCli	:= SuperGetMv("NT_USUCLI",.F.,"000000")   
Local cCodUsr 	:= RetCodUsr()      

//-----------------------------------------------------------------------------------
// Verificar se o usaurio do parametro � o mesmo do usuario logado na rotina
//Permitir preenchemento rapido com apenas alguns campos.
//-----------------------------------------------------------------------------------
If cCodUsr $ cUsuCli
	
	//-----------------------------------------------------------------------------------
	// Campos com preenchimento automatico
	//-----------------------------------------------------------------------------------
	M->A1_PAIS 		:='105'
	M->A1_REGIAO	:="005'
	M->A1_VEND		:='000004'  //BALCAO DENTRO ESTADO      
	M->A1_CODPAIS	:='01058'   
	
	If Empty(M->A1_LOJA)
		MsgInfo ("Gentileza informar o campo LOJA!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_PESSOA)
		MsgInfo ("Gentileza informar o campo tipo para FISICA/JURIDICA!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_NOME)
		MsgInfo ("Gentileza informar o campo NOME do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)   
	ElseIf Empty(M->A1_END)
		MsgInfo ("Gentileza informar o campo ENDERE�O do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_EST)
		MsgInfo ("Gentileza informar o campo ESTADO do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_COD_MUN)
		MsgInfo ("Gentileza informar o campo CODIGO DO MUNICIPIO do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_BAIRRO)
		MsgInfo ("Gentileza informar o campo BAIRRO do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_CEP)
		MsgInfo ("Gentileza informar o campo CEP do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_CGC)
		MsgInfo ("Gentileza informar o campo CPF/CGC do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_DDD )
		MsgInfo ("Gentileza informar o campo DDD do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)  
	ElseIf Empty(M->A1_ZTELFIX )
		MsgInfo ("Gentileza informar o campo TELEFONE FIXO do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_ZDDFX )
		MsgInfo ("Gentileza informar o campo DDD do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)  
	ElseIf Empty(M->A1_TEL )
		MsgInfo ("Gentileza informar o campo TELEFONE CELULAR do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	EndIf
	
	/*	ElseIf Empty(M->A1_EMAIL ) --Solicitado por Felipe Orizona em 12/09/2017.
	MsgInfo ("Gentileza informar o campo E-MAIL do cliente!!!")
	lExecuta := .F.                                              
	Return (lExecuta) */ 
 
//-----------------------------------------------------------------------------------
// Valida��o para os usuarios que n�o est�o no parametro.
//-----------------------------------------------------------------------------------
Else  
	If Empty(M->A1_lOJA)
		MsgInfo ("Gentileza informar o campo LOJA!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_PESSOA)
		MsgInfo ("Gentileza informar o campo tipo para FISICA/JURIDICA!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_TIPO)
		MsgInfo ("Gentileza informar o campo TIPO!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_NOME)
		MsgInfo ("Gentileza informar o campo NOME do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)   
	ElseIf Empty(M->A1_NREDUZ)
		MsgInfo ("Gentileza informar o campo NOME FANTASIA do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta) 
	ElseIf Empty(M->A1_END)
		MsgInfo ("Gentileza informar o campo ENDERE�O do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_EST)
		MsgInfo ("Gentileza informar o campo ESTADO do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_COD_MUN)
		MsgInfo ("Gentileza informar o campo CODIGO DO MUNICIPIO do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_BAIRRO)
		MsgInfo ("Gentileza informar o campo BAIRRO do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_CEP)
		MsgInfo ("Gentileza informar o campo CEP do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)              
	ElseIf Empty(M->A1_PAIS)
		MsgInfo ("Gentileza informar o campo PAIS do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)  		
	ElseIf Empty(M->A1_CGC)
		MsgInfo ("Gentileza informar o campo CPF/CGC do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)		
	ElseIf Empty(M->A1_INSCR )
		MsgInfo ("Gentileza informar o campo INSCRI��O ESTADUAL do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)		
	ElseIf Empty(M->A1_DTNASC )
		MsgInfo ("Gentileza informar o campo DATA ABERTURA/NASCIMENTO do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_DDD )
		MsgInfo ("Gentileza informar o campo DDD do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)  
	ElseIf Empty(M->A1_ZTELFIX )
		MsgInfo ("Gentileza informar o campo TELEFONE FIXO do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_ZDDFX )
		MsgInfo ("Gentileza informar o campo DDD do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_TEL )
		MsgInfo ("Gentileza informar o campo TELEFONE CELULAR do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)  
	ElseIf Empty(M->A1_NATUREZ )
		MsgInfo ("Gentileza informar o campo NATUREZA do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta) 
	ElseIf Empty(M->A1_LC )
		MsgInfo ("Gentileza informar o campo LIMITE DE CREDITO do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_RECISS )
		MsgInfo ("Gentileza informar o campo RECOLHE ISS !!!")
		lExecuta := .F.                                              
		Return (lExecuta) 
	ElseIf Empty(M->A1_RECINSS )
		MsgInfo ("Gentileza informar o campo RECOLHE INSS !!!")
		lExecuta := .F.                                              
		Return (lExecuta)	
	ElseIf Empty(M->A1_RECCOFI )
		MsgInfo ("Gentileza informar o campo RECOLHE COFINS !!!")
		lExecuta := .F.                                              
		Return (lExecuta)		
	ElseIf Empty(M->A1_RECCSLL )
		MsgInfo ("Gentileza informar o campo RECOLHE CSLL !!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_RECPIS )
		MsgInfo ("Gentileza informar o campo RECOLHE PIS !!!")
		lExecuta := .F.                                              
		Return (lExecuta)  
	ElseIf Empty(M->A1_SIMPNAC )
		MsgInfo ("Gentileza informar o campo OPT.SIMPLES NACIONAL !!!")
		lExecuta := .F.                                              
		Return (lExecuta)    
	ElseIf Empty(M->A1_CONTRIB )
		MsgInfo ("Gentileza informar o campo CONTRIBUINTE !!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_IENCONT )
		MsgInfo ("Gentileza informar o campo DESTACA IE !!!")
		lExecuta := .F.                                              
		Return (lExecuta)  
	ElseIf Empty(M->A1_IRBAX )
		MsgInfo ("Gentileza informar o campo IRPJ BAIXA !!!")
		lExecuta := .F.                                              
		Return (lExecuta) 
	ElseIf Empty(M->A1_RECIRRF )
		MsgInfo ("Gentileza informar o campo RECOLHE IRRF !!!")
		lExecuta := .F.                                              
		Return (lExecuta) 
	ElseIf Empty(M->A1_REGIAO )
		MsgInfo ("Gentileza informar o campo REGIAO do cliente!!!")
		lExecuta := .F.                                              
		Return (lExecuta)
	ElseIf Empty(M->A1_VEND )
		MsgInfo ("Gentileza informar o campo VENDEDOR !!!")
		lExecuta := .F.                                              
		Return (lExecuta) 
	ElseIf Empty(M->A1_CODPAIS )
		MsgInfo ("Gentileza informar o campo CODPAIS !!!")
		lExecuta := .F.                                              
		Return (lExecuta) 
	//-Quando o cliente for ISENTO o campo contribuinte na aba fiscal dever� estar como n�o.		
	ElseIf !IsNumeric(Alltrim(StrTran(StrTran(M->A1_INSCR,'.',''),'-','')))
		If Alltrim(M->A1_CONTRIB) == "1"	//1=Sim;2=Nao                                                                                                                      
			MsgInfo ("Para clientes com inscricao isentas o campo contribuinte dever� ser n�o!!!")
			lExecuta := .F.                                              
			Return (lExecuta)
		EndIf
	EndIf		     
EndIf

RestArea(aAreaCli)

Return (lExecuta)