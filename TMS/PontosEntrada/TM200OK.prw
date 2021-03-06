#Include 'Protheus.ch'
//Poliester Moreira - Chaus - 01/08/2017
//Ponto de Entrada no C�lculo do Frete, retorna .T. ou .F. e impede ou n�o a continua��o do c�lculo.
//Objetivo: Evitar erros nos cadastros dos clientes remetentes e destinat�rios para:
//1) Evitar documentos inutilizados na SEFAZ.
//2) Evitar documentos com c�lculos errados e estornos de CTe�s.
User Function TM200OK()

	Local nOpc		:= PARAMIXB[1]	//1-Calcular, 3-Estornar
	Local lRet 		:= .T.
	Local cLotNfc	:= DTP->DTP_LOTNFC
	Local cCliRem	:= Posicione("DTC",1,xFilial("DTC")+xFilial("DTC")+cLotNfc,"DTC->DTC_CLIREM")
	Local cLojRem	:= Posicione("DTC",1,xFilial("DTC")+xFilial("DTC")+cLotNfc,"DTC->DTC_LOJREM")
	Local cCliDes	:= Posicione("DTC",1,xFilial("DTC")+xFilial("DTC")+cLotNfc,"DTC->DTC_CLIDES")
	Local cLojDes	:= Posicione("DTC",1,xFilial("DTC")+xFilial("DTC")+cLotNfc,"DTC->DTC_LOJDES")
	Local cMsg		:= ""
	Local lCtrlRem	:= .F.
	Local lCtrlDes	:= .F.

	If nOpc == 1	//C�lculo do Frete
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		//Valida��es no cadastro do cliente remetente
		If SA1->(DbSeek(xFilial("SA1")+cCliRem+cLojRem))
			cMsg := "Por favor corrija no cadastro do Cliente Remetente ("+Alltrim(cCliRem)+"/"+Alltrim(cLojRem)+") os seguintes dados: "+CHR(13)+CHR(10)
			If Len(Alltrim(SA1->A1_CEP)) < 8
				cMsg += "- Preencha corretamente o campo CEP. Ex.: 75500-000."+CHR(13)+CHR(10)
				lCtrlRem := .T.
				lRet := .F.
			Endif
			If Len(Alltrim(SA1->A1_DDD)) < 3
				cMsg += "- Preencha corretamente o campo DDD. Ex.:062!"+CHR(13)+CHR(10)
				lCtrlRem := .T.
				lRet := .F.
			Endif
			/*
			If Len(Alltrim(SA1->A1_EMAIL)) < 7 .OR. !(ISEMAIL(SA1->A1_EMAIL))
				cMsg += "- Preencha corretamente o campo EMAIL. Ex.: nome@dominio.com.br"+CHR(13)+CHR(10)
				lCtrlRem := .T.
				lRet := .F.
			Endif
			*/
			If Empty(SA1->A1_CDRDES)
				cMsg += "- Preencha o campo Reg.Cliente."+CHR(13)+CHR(10)
				lCtrlRem := .T.
				lRet := .F.
			Endif
			If (Posicione("DUY",1,xFilial("DUY")+SA1->A1_CDRDES,"DUY_EST")) <> SA1->A1_EST
				cMsg += "- O c�digo da regi�o do cliente n�o pertence ao mesmo estado que o cliente."+CHR(13)+CHR(10)
				lCtrlRem := .T.
				lRet := .F.
			Endif
		Endif
	
		If lCtrlRem
			MsgInfo(cMsg)
			cMsg := ""
		Endif
	
	
		//Valida��es no cadastro do cliente destinat�rio
		If SA1->(DbSeek(xFilial("SA1")+cCliDes+cLojDes))
			cMsg := "Por favor corrija no cadastro do Cliente Destinatario ("+Alltrim(cCliDes)+"/"+Alltrim(cLojDes)+") os seguintes dados: "+CHR(13)+CHR(10)
			If Len(Alltrim(SA1->A1_CEP)) < 8
				cMsg += "- Preencha corretamente o campo CEP. Ex.: 75500-000."+CHR(13)+CHR(10)
				lCtrlDes := .T.
				lRet := .F.
			Endif
			If Len(Alltrim(SA1->A1_DDD)) < 3
				cMsg += "- Preencha corretamente o campo DDD. Ex.:062!"+CHR(13)+CHR(10)
				lCtrlDes := .T.
				lRet := .F.
			Endif
			/*
			If Len(Alltrim(SA1->A1_EMAIL)) < 7 .OR. !(ISEMAIL(SA1->A1_EMAIL))
				cMsg += "- Preencha corretamente o campo EMAIL. Ex.: nome@dominio.com.br"+CHR(13)+CHR(10)
				lCtrlDes := .T.
				lRet := .F.
			Endif
			*/
			If Empty(SA1->A1_CDRDES)
				cMsg += "- Preencha o campo Reg.Cliente."+CHR(13)+CHR(10)
				lCtrlDes := .T.
				lRet := .F.
			Endif
			If (Posicione("DUY",1,xFilial("DUY")+SA1->A1_CDRDES,"DUY_EST")) <> SA1->A1_EST
				cMsg += "- O c�digo da regi�o do cliente n�o pertence ao mesmo estado que o cliente."+CHR(13)+CHR(10)
				lCtrlDes := .T.
				lRet := .F.
			Endif
		Endif
	
		If lCtrlDes
			MsgInfo(cMsg)
			cMsg := ""
		Endif
	Endif
	
	
	If nOpc == 3	//Estorno. Ajustando o SX3 para corrigir o error.log at� a virada para P12 ou at� a TOTVS resolver o chamado aberto.
		DbSelectArea("SX3")
		SX3->(DbGoTop())
		While SX3->(!Eof())
			If SX3->X3_ARQUIVO == "DT6"
				RecLock("SX3",.F.)
				SX3->X3_USADO := '���������������'
				SX3->(MsUnLock())
			Endif
			SX3->(DbSkip())
		EndDo
		//"���������������"
	Endif
	
Return(lRet)