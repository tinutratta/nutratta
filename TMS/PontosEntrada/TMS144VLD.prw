
//Excluido do RPO-Base oficial em 28/06/2017. pois n�o estava permitindo excluir Cte de dentro da viagem  
User Function TMS144VLD() 
Local lRet  := .T.
Local nOpcx := PARAMIXB[1]
If nOpcx == 4           
	lRet:= .F.
	MsgAlert('N�o � permitido alterar esta viagem', 'Aten��o')
Endif   
Return lRet         

