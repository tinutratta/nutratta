#INCLUDE "RWMAKE.CH"          
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "topconn.ch"      
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#include 'parmtype.ch'   

/*
========================================================================================================================
Rotina----: MPCP001
Autor-----: Davidson Clayton
Data------: 07/06/2018
========================================================================================================================
Descri��o-: Fun��o para realizar o bloqueio e desbloqueio de armazem.
Uso-------: NNR_FILIAL+NNR_CODIGO 
			1=Sim;2=Nao                                                                                                                                                                                                                                                                
========================================================================================================================
*/

User Function MPCP001()

_lSituac	:=.F.
_lTrava		:=.F.
_nOpc		:= 0    
   

dbSelectArea("NNR")
dbSetOrder(1)
If dbSeek(NNR->NNR_FILIAL+NNR_CODIGO)
	
	If NNR->NNR_MSBLQL == '1' //Bloqueado
		_lSituac :=.T.
		
	ElseIf NNR->NNR_MSBLQL == '2' //Desbloqueado
		_lSituac :=.F.
		
	EndIf
	
	If _lSituac
		
		_nOpc := Aviso("A R M A Z E M -  B L O Q U E A D O ","Armazem bloqueado,deseja realizar o desbloqueio?",{"Sim","Nao"},2)
		If _nOpc == 1
			_lTrava := "2"
		Else
			Return
		EndIf
	Else
		_nOpc := Aviso("A R M A Z E M - D E S B L O Q U E A D O","Armazem Desbloqueado,deseja realizar o bloqueio?",{"Sim","Nao"},2)
		If _nOpc == 1
			_lTrava := "1"
		Else
			Return
		EndIf
	 EndIf	
	
	//Realiza o Bloqueio/Desbloqueio
	dbSelectArea("NNR")
	dbSetOrder(1)
	If dbSeek(NNR->NNR_FILIAL+NNR_CODIGO)
		If RecLock("NNR",.F.)
			Replace NNR_MSBLQL With _lTrava
			MsUnlock()
		EndIf
	EndIf	
EndIf

Return