#INCLUDE "Ap5Mail.ch" 


/*{Protheus.doc} 
Função com o objetivo de enviar email, validando a priore o destinatário.
Caso o email seja inválido, será enviado uma notifucação ao atendimento para entrar em contato com o cliente para atualização.
Parametros Necessários:
cServer: Servidor smtp:587
cAccount: Conta remetente
cPassword: senha
cTo: Destinatário
cCC: Com Cópia para...
cSubject: Assunto do e-mail
cConteudo: corpo do e-mail
/*/


User Function EMAILOK(cServer, cAccount, cPassword, cTo, cCC, cSubject, cConteudo,cCC2,lCliente,lConfirmaEnvio)
 
Local lSmtpAuth := GetMv("MV_RELAUTH",,.F.)
Local cFrom     := cAccount
Local lOk       := .T.
Local lAutOk    := .F.                                          
Local cBody     := cConteudo  
local cMsg      :=""



If lConfirmaEnvio
	if ValidEmail(cTo, lCliente)
	
		cMsg:= "Email enviado ao Cliente com sucesso!!!"
		
		if lCliente == .F.
			cMsg:= "Email interno Enviado."
		endif
		
	else
		//Se o e-mail não for válido, será enviado uma msgm ao atendimento para solicitar correção ao cliente.
		
		alert("Ops!   Email do Cliente Inválido: "+ cTo + chr(10) + chr(10) +"Obs.: Um email será enviado ao atendimento Solicitando a correção ao cadastro do cliente!")
		cConteudo:= "<H2>E-MAIL INVALIDO: "+ cTo +"</H2>" + cConteudo
		
		
		if cFilAnt==''
			cTo:= ""
		elseif cFIlAnt==''
			cTo:=""
		endif
		cCC2 := ""
		cSubject:="EMAIL DO CLIENTE INVALIDO"
		
		
		cMsg:= "Correção solicitada ao Atendimento/administrativo. - "+cTo
	
	end if
EndIf

cCC+= ", "
cCC+= cCC2

		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk   
		 	      
			If !lAutOk 
			If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
			Else
			lAutOk := .T.
			EndIf 
			EndIf       
			     	
			cBody := cConteudo
		
		
		   	If lOk .and. lAutOk 
				 Send Mail From cFrom To cTo CC cCC Subject cSubject Body cBody Result lOk
			
				If lConfirmaEnvio = .T.
					If lOk
						MsgInfo(cMsg)
					Else
						GET MAIL ERROR cErro
						MsgStop("Não foi possível enviar o Email. Contate setor de T.I." +Chr(13)+Chr(10)+ cErro,"AVISO")
						Return .f.
					EndIf
				EndIf	   
		 	Else
				GET MAIL ERROR cErro
				MsgStop("Erro na conexão com o SMTP Server. Contate setor de T.I." +Chr(13)+Chr(10)+ cErro,"AVISO")
				Return .f.
			EndIf 
				
				DISCONNECT SMTP SERVER

Return .T.

//Função para válidar se o e-mail é válido

STATIC FUNCTION ValidEmail(cEmail, lCliente)

lRet := .T.

if !"@" $ cEmail	
	lRet := .F.
endif

if !"." $ cEmail	
	lRet := .F.
endif

If lCliente = .T.
	if "CITOPH" $ cEmail .OR. "citoph" $ cEmail 	
		lRet := .F.
		
	Endif
EndIf

if "/" $ cEmail	
	lRet := .F.
endif

if "*" $ cEmail	
	lRet := .F.
endif

RETURN lRet





