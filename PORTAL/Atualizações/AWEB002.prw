#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"                 
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} AWEB002
// Rotina de Prospect em MVC - TMKA260
@author Marco Aurelio Braga
@since 26/05/2016
@version 1.0
@type function
/*/

User Function AWEB002()

Return()

/*/{Protheus.doc} MenuDef
// Menu Default
@author Marco Aurelio Braga
@since 26/05/2016
@version 1.0
@type function
/*/
                              	
Static Function MenuDef()

	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Pesquisar"	ACTION 'VIEWDEF.TMKA260' 	OPERATION 1	ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar"	ACTION 'U_AWEB002A("VIS")'	OPERATION 2	ACCESS 0
//	ADD OPTION aRotina TITLE "Incluir"		ACTION 'U_AWEB002A("INC")'	OPERATION 3	ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"		ACTION 'U_AWEB002A("EDT")'	OPERATION 4	ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"		ACTION 'U_AWEB002A("EXC")'	OPERATION 5	ACCESS 0
	ADD OPTION aRotina Title 'Efetivar'    	Action 'U_AWEB002A("EFT")'	OPERATION 4 ACCESS 0
//	ADD OPTION aRotina TITLE "Ag.Visita"	ACTION 'U_AWEB002A("AGD")'	OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE "Legenda"		ACTION 'U_AWEB002A("LEG")'	OPERATION 7 ACCESS 0 
//	ADD OPTION aRotina TITLE "Contato"		ACTION 'U_AWEB002A("CNT")'	OPERATION 4 ACCESS 0
//	ADD OPTION aRotina TITLE "Conhecimento" ACTION 'MsDocument'			OPERATION 9 ACCESS 0
	
Return(aRotina)

/*/{Protheus.doc} BrowseDef
// Integra��o Web
@author Marco Aurelio Braga
@since 04/02/2016
@version 1.0
@type function
/*/

Static Function BrowseDef()

	Local aRet	:= {}
	
	// Array principal
	
	aAdd(aRet, {"Legend"	, {} })
	aAdd(aRet, {"Alias"		, {} })
	aAdd(aRet, {"Filter"	, {} })
	
	// Array Legenda
	
//	aAdd(aRet[1,2], {"SUS->US_STATUS == '1'", "BR_MARROM"		,'Classificado'			})
//	aAdd(aRet[1,2], {"SUS->US_STATUS == '1'", "BR_MARROM"		,'Aguardando'			})
//	aAdd(aRet[1,2], {"SUS->US_STATUS == '2'", "BR_VERMELHO"		,'Desenvolvimento'		})
//	aAdd(aRet[1,2], {"SUS->US_STATUS == '3'", "BR_AZUL"			,'Gerente'				})
//	aAdd(aRet[1,2], {"SUS->US_STATUS == '4'", "BR_AMARELO"		,'Standy by'			})
//	aAdd(aRet[1,2], {"SUS->US_STATUS == '5'", "BR_PRETO"		,'Cancelado'			})
//	aAdd(aRet[1,2], {"SUS->US_STATUS == '6'", "BR_VERDE"		,'Cliente' 				})
//	aAdd(aRet[1,2], {"Empty(SUS->US_STATUS)", "BR_BRANCO"		,'Maling (sem status)'	})

	// Legenda altera a pedido do cliente Nutratta
	aAdd(aRet[1,2], {"SUS->US_STATUS == '1'", "BR_VERMELHO"		,'Aguardando'			})
	aAdd(aRet[1,2], {"SUS->US_STATUS == '5'", "BR_PRETO"		,'Cancelado'			})
	aAdd(aRet[1,2], {"SUS->US_STATUS == '6'", "BR_VERDE"		,'Cliente' 				})
	
	// Array Alias
	
	aAdd(aRet[2,2], {"SUS"})
	
	// Array Filter
	
	aAdd(aRet[3,2], {""})	

Return(aRet)

/*/{Protheus.doc} AWEB002A
// Opa��es do Menu - TMKA260
@author Marco Aurelio Braga
@since 26/05/2016
@version 1.0
@type function
/*/

User Function AWEB002A(cOpcao)

	Local lRet	:= .T.

	// Compatibilidade com TMKA260
	
	Private cCadastro	:= 'Prospect'
	Private aMemos		:= {}
	Private aRotina		:= StaticCall(AWEB002,MenuDef)
	Private lTk260Auto	:= .F.

	Do Case
		Case (cOpcao == "VIS")
			FWExecView('Prospect', 'TMKA260', 1,, { || .T. },  )			
		Case (cOpcao == "INC")
			FWExecView('Prospect', 'TMKA260', 3,, { || .T. },  )	
		Case (cOpcao == "EDT")
			lRet := fEdtPro()
		Case (cOpcao == "EXC")
			lRet := fExcPro()
		Case (cOpcao == "EFT")
			lRet := fEftPro()			
		Case (cOpcao == "AGD")
			Tka260Vis("SCS",SCS->(Recno()),6)		
		Case (cOpcao == "LEG")
			//Tk260Legenda()
			fGetLeg()
		Case (cOpcao == "CNT")
			FtContato("SCS",SCS->(Recno()),4)			
	EndCase

Return(lRet)

/*/{Protheus.doc} fEdtPro
// Edita propesct
@author Marco Aurelio Braga
@since 26/05/2016
@version 1.0
@type function
/*/

Static Function fEdtPro()

	Local lRet := .F.
	
	If SUS->US_STATUS == '6' //j� � cliente
		MsgInfo("Este Propesct j� � cliente!")
	ElseIf SUS->US_STATUS == '5' //j� � cliente
		MsgInfo("Este Propesct foi cancelado!")
	Else
		lRet := ( FWExecView('Prospect', 'TMKA260', 4,, { || .T. },  ) == 0 )
	EndIf
	
	If lRet
		MsgInfo("Propesct alterado com sucesso!")
		// Send WF vendedor
	Endif
	
Return(lRet)

/*/{Protheus.doc} fExcPro
// Exclui propesct
@author Marco Aurelio Braga
@since 26/05/2016
@version 1.0
@type function
/*/

Static Function fExcPro()

	Local lRet := .F.
	
	If SUS->US_STATUS == '6' //j� � cliente
		MsgInfo("Este Propesct j� � cliente, nao pode ser excluido!")
	Else
		lRet := ( FWExecView('Prospect', 'TMKA260', 5,, { || .T. },  ) == 0 )
	EndIf
	
	If lRet
		MsgInfo("Propesct excluido com sucesso!")
		// Send WF vendedor
	Endif
	
Return(lRet)

/*/{Protheus.doc} fEftPro
// Efetiva propesct
@author Marco Aurelio Braga
@since 26/05/2016
@version 1.0
@type function
/*/

Static Function fEftPro()

	Local cAlias	:= ""
	Local aArea		:= GetArea()
	Local aASUS		:= SUS->(GetArea())
	Local aASCJ		:= SCJ->(GetArea())
	Local lRet		:= .F.
	Local cBkpCgc	:= SUS->US_CGC

	If SUS->US_STATUS == '6' //j� � cliente
		MsgAlert("Propesct j� efetivado como cliente - codigo/loja: "+SUS->US_CODCLI+"/"+SUS->US_LOJACLI)
	ElseIf SUS->US_STATUS == '5' //j� � cliente
		MsgAlert("Este Propesct foi cancelado!")
	Else
		//XGH-REMOVE E GUARDA CGC PARA CONSEGUIR INCLUIR O PROSPECT 
		SUS->(Reclock("SUS",.F.))
		SUS->US_CGC = ""
		SUS->(MsUnlock())
		
		lRet := Tk273GrvPTC(SUS->US_COD,SUS->US_LOJA,.F.)
	EndIf
	
	If lRet
	
		// Complementa cadastro do cliente incluido
//		lRet := U_AWEB005A("EDT")
//		If !lRet
//			Return(lRet)
//		Endif

		//XGH-RETORNA CGC GUARDADO NAS TABELAS SUS E SA1 
		SUS->(Reclock("SUS",.F.))
		SUS->US_CGC = cBkpCgc
		SUS->(MsUnlock())
		
		SA1->(Reclock("SA1",.F.))
		SA1->A1_CGC := cBkpCgc 
		SA1->A1_PESSOA	:= SUS->US_PESSOA
		SA1->A1_NREDUZ	:= SUS->US_NOME	
		SA1->A1_COD_MUN	:= SUS->US_COD_MUN
		SA1->A1_DTNASC	:= SUS->US_DTNASC	
		SA1->A1_CGC		:= SUS->US_CGC
		SA1->A1_PAIS	:= SUS->US_PAIS
		SA1->A1_DDD		:= SUS->US_DDD          
		SA1->A1_ZTELFIX	:= SUS->US_ZTELFIX                
		SA1->A1_ZDDFX	:= SUS->US_ZDDFX 
		SA1->A1_TEL		:= SUS->US_TEL 
		SA1->A1_EMAIL	:= SUS->US_EMAIL 
		SA1->A1_PFISICA	:= SUS->US_PFISICA 
		SA1->A1_NATUREZ	:= "101010"    
		SA1->A1_CODPAIS	:= "01058"	                        
		SA1->A1_REGIAO	:= "005" //Regi�o do cliente	                          
		SA1->A1_MSBLQL	:= '1' //Bloqueado.	  
		SA1->(MsUnlock())

		U_AWEB005A("EDT")
	
		// Atualiza or�amentos do propesct efetivado
		cAlias	:= GetNextAlias()
		
		BeginSql alias cAlias
			SELECT	SCJ.R_E_C_N_O_ AS RECNUM
			FROM	%Table:SCJ% SCJ
			WHERE	SCJ.%NOTDEL%
					AND SCJ.CJ_FILIAL	= %xFilial:SCJ%
					AND SCJ.CJ_PROSPE	= %exp:SUS->US_COD%
					AND SCJ.CJ_LOJPRO	= %exp:SUS->US_LOJA%
					AND SCJ.CJ_CLIENTE	= ''
		EndSql
		
		DbSelectArea(cAlias)
		(cAlias)->(DbGoTop())
		If (cAlias)->(!Eof())
			While (cAlias)->(!Eof())
			
				DbSelectArea("SCJ")
				SCJ->(DbGoTo((cAlias)->RECNUM))
				If SCJ->(Recno()) == (cAlias)->RECNUM
					SCJ->(RecLock("SCJ",.F.))
					SCJ->CJ_CLIENTE	:= SUS->US_CODCLI
					SCJ->CJ_LOJA	:= SUS->US_LOJACLI
					SCJ->(MsUnLock())
				Endif
		
				(cAlias)->(DbSkip())
			Enddo
		Endif
		
		(cAlias)->(DbCloseArea())
	    	
		/*
		========================================================================================================================
		Rotina----: MFAT004 
		Autor-----: Davidson Clayton 
		Data------: 26/12/2017
		========================================================================================================================
		Descri��o-: Rotina para transferir o local de entrega entre novo cliente e cliente.
		Uso-------: Especifico portal Nutratta
		========================================================================================================================
		*/
		
//		Processa( {|| U_MFAT004() }, "Aguarde...", "Verifica se existe locais de entrega para vincular....",.F.)
		  
	
		MsgInfo("Propesct efetivado com sucesso!")
		// Send WF vendedor
	Else
		MsgAlert("Falha na efetiva��o do Propesct!")
	Endif
	
	SCJ->(RestArea(aASCJ))
	SUS->(RestArea(aASUS))
	RestArea(aArea)
	
Return(lRet)
    

/*/{Protheus.doc} fGetLeg
// Legenda do proposct
@author Marco Aurelio Braga
@since 26/05/2016
@version 1.0
@type function
/*/

Static Function fGetLeg()

	Local aLeg := {}
	
	aAdd(aLeg, {"BR_VERMELHO"	,'Aguardando'	} )
	aAdd(aLeg, {"BR_PRETO"		,'Cancelado'	} )
	aAdd(aLeg, {"BR_VERDE"		,'Cliente'		} )
	
	BrwLegenda("Legenda","Legenda",aLeg)

Return()