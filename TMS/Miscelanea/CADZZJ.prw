#Include "rwmake.ch"
#Include 'Protheus.ch'
#Include 'Parmtype.ch'

/*
========================================================================================================================
Rotina----: CADZZJ
Autor-----: Poliester Chaus
Data------: 27/07/2017
========================================================================================================================
Descri��o-: Cadastro de Locais de Entrega 
Uso-------: Logistica Nutratta
========================================================================================================================
*/

//MBROWSE DA TABELA ZZJ - CADASTRO DE LOCAIS DE ENTREGA
User Function CADZZJ
Private cPerg   := ""
Private cCadastro := "Cadastro de locais de entrega"
Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
             {"Visualizar","AxVisual",0,2} ,;
             {"Incluir","AxInclui",0,3} ,;
             {"Alterar","AxAltera",0,4} ,;
             {"Excluir","AxDeleta",0,5}}


Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private cString := "ZZJ"

dbSelectArea("ZZJ")
dbSetOrder(1)

cPerg   := ""

dbSelectArea(cString)
mBrowse(6,1,22,75,cString)

Set Key 123 To // Desativa a tecla F12 do acionamento dos parametros

Return