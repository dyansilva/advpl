/*
Envia e-mail com resumo do pedido com os dados para o cliente possa
o pedido							      		
 */
#INCLUDE 'protheus.ch'


USER FUNCTION RDFAT037(cPar)  
  
    
	   
	LOCAL cServer      := ""
	LOCAL cAccount     := "" 
	LOCAL cPassword    := ""
	LOCAL cTo          := ""    
	LOCAL cCC		   := ""   
	LOCAL cCC2		   := ""       
	LOCAL cConteudo	   := ""
	PRIVATE cSubject   := " "
	PRIVATE cConteudo  := ""
	PRIVATE LinkcNomeTransp := ""  
	PRIVATE cNomeTransp  := "" 
	PRIVATE lRet 	   := .T.
 
	IF (GETMV("MV_RASTRPV")=='N')
	
		RETURN .T.
	ENDIF
    
	IF(cPar == '2')
		
		IF(EMPTY(SC5->C5_NOTA))
			MSGINFO("ESTE PEDIDO AINDA NAO FOI FATURADO. NÃO É POSSIVEL ENVIAR RASTREAMENTO.")
			RETURN
		ENDIF
				
		POSICIONASF2()
		
		dbSelectArea("SF2")
		dbSetorder(1)
		dbSeek(TMP_TAB2->F2_FILIAL+TMP_TAB2->F2_DOC+TMP_TAB2->F2_SERIE+TMP_TAB2->F2_CLIENTE+TMP_TAB2->F2_LOJA+TMP_TAB2->F2_FORMUL+TMP_TAB2->F2_TIPO)
		
		DBSELECTAREA("TMP_TAB2")
		DBCLOSEAREA()
	ENDIF
	
	cSubject+= Alltrim(POSICIONE("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NREDUZ"))+" - NF: " + SF2->F2_DOC 
	
	IF(POSICIONE("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE,"A1_ZENPEDI")== 'N')
		MSGINFO("Cliente Configurado Para Não Receber Rastreamento Por E-mail..")
		RETURN .T. 
	ENDIF
	
	cTo := POSICIONE("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_EMAIL")
	
	IF ( Empty(cTo) )
		MSGINFO("E-MAIL DO CLIENTE EM BRANCO")
		RETURN .T.
	ENDIF
	
LinkcNomeTransp := ALLTRIM(ALLTRIM(POSICIONE("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_ZRASTRE")))

	IF (Empty(LinkcNomeTransp)) 
	
		
		cSubject := "Informar Link de Ratreio - " + cNomeTransp
		
		IF MSGYESNO("Link da Transportadora " + cNomeTransp + " Não Cadastrado!!" + Chr(13) + "Deseja Cadastra?", "Cadastrar Link Da Transportadora")
		    PCEMAIL()
		 ELSE
		 	 lRet:= .F.
		ENDIF
	ENDIF
	
	cConteudo:= STRUCT_SCREEN()
	

	
	IF ( lRet)
		U_EMAILOK(cServer, cAccount,cPassword,cTo,cCC,cSubject,cConteudo,cCC2,.T.,.T.)
	else			
			cTo:="administrativo@citopharmaindustrial.com.br"
			cSubject := "Informar Link de Ratreio - " + cNomeTransp + "NF: "+SF2->F2_DOC
			U_EMAILOK(cServer, cAccount,cPassword,cTo,cCC,cSubject,cConteudo,cCC2,.F.,.T.)
	ENDIF
	
	RETURN 
	
	STATIC FUNCTION STRUCT_SCREEN()
	
	LOCAL cConteudo := ""
	LOCAL cName := ""
	LOCAL cTel := ""
	PRIVATE cData
	
	cName := ALLTRIM(POSICIONE("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE + SF2->F2_LOJA,"A1_NREDUZ"))// POSIONE NO NOME FANTASIA
	cTel := ALLTRIM(POSICIONE("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE + SF2->F2_LOJA,"A1_DDD")) + " " + ALLTRIM(POSICIONE("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE + SF2->F2_LOJA,"A1_TEL"))
	LinkcNomeTransp := ALLTRIM(POSICIONE("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_ZRASTRE"))
	cNomeTransp  := ALLTRIM(POSICIONE("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME"))
	cData := "Belo Horizonte, " + cValToChar(Day(SF2->F2_EMISSAO))+ " de " + cValToChar(MesExtenso(SF2->F2_EMISSAO)) + " de " + cValToChar(Year(SF2->F2_EMISSAO))
	 
	//Dados Do E-mail 
	
	cConteudo :="<html>"
	cConteudo += "<head>"
	cConteudo += "<meta Charset='UTF-8'>"
	cConteudo += "<style>"
	cConteudo += "table, th, td { border: 1px solid black; border-collapse: collapse; }"
	cConteudo += "th, td { padding: 5px; text-align: left; }"
	cConteudo += "</style>"
	cConteudo += "</head>"
	cConteudo += "<body>"
	cConteudo += "<p>"+cData+"</p>"
	cConteudo += "<font size='4' face='Arial' color='Green'><b><center>Mensagem Eletrônica - Casula e Vasconcelos Indústria Farmacêtica Comércio Ltda</b></center></font><br/>"
	cConteudo += "<font size='4' face='Arial' color='Green'><b><center><U>RASTREAMENTO DE ENTREGA - N. FISCAL: "+SF2->F2_DOC+"</U></b></center></font><br/><br/><br/><br/><br/><br/>"
	cConteudo += "<font size='5' face='Arial' Color='red'><b> LINK PARA RASTREAR SEU PEDIDO: <a href='"+ LinkcNomeTransp +"'  style='color: #ff0000'>"+ cNomeTransp +"</font></a></b><br/>"
	cConteudo += "<font size='3' face='Arial'> Nota Fiscal: " +SF2->F2_DOC+ "</font><br/>"
	cConteudo += "<font size='3' face='Arial'>CNPJ: "+ TRANSFORM(SA1->A1_CGC,"@R 99.999.999/9999-99") +"</font><br/>"
	cConteudo += "<font size='3' face='Arial'>DATA DE EMISSÃO: " +Dtoc(SF2->F2_EMISSAO)+ "</font><br/>"
	   
	cConteudo += "<p><Font Color='red'><U>Conforme Logistica da Transportadora, o Rastreamento estara disponivel de 24 a 48 horas uteis apos o recebimento deste e-mail.</U></Font></p>"
	cConteudo += "<p><Font Color='red'><U>Lembramos a importancia da conferencia dos itens no ato do recebimento dos medicamentos, inclusive a ressalva no conhecimento de transporte caso algo fora da normalidade ocorra.</U></Font></p>"
	cConteudo += "<p></p>
	cConteudo += CREATE_TABLE()
	cConteudo += "<font size='3' face='Arial'></font>"
	cConteudo += "</body>"
	cConteudo +="</html>"
	cConteudo += EMAIL_OK()
	
	RETURN cConteudo
	
	STATIC FUNCTION CREATE_TABLE()  

	LOCAL cTable := ""
	LOCAL aArea := GetArea()
	cTable +="<style type='text/css'>"
	cTable +='#tab tr:nth-child(even){background: #C1CDCD;}'
	cTable +="</style>"
	
	cTable += "<center><table id='tab' border='1' style='width:80%'>"
	cTable += "<tr style= 'background-color: snow'>"
	cTable += "<td colspan='6'><Font Color='red'><b><center>ITENS DO PEDIDO</center></b></Font></td>"
	cTable += "</tr>"
	cTable += "<tr style= 'background-color: snow'>"
	cTable += "<th><center>Item</center></th>"
	cTable += "<th><center>Codigo Produto</center></th>"
	cTable += "<th><center>Produto</center></th>"
	cTable += "<th><center>QUANTIDADE</center></th>"
	cTable += "<th><center>PREÇO</center></th>"
	cTable += "<th><center>TOTAL</center></th>"
	cTable += "</tr>"
	
	TMP_TAB()
	
	dbGoTOP()
	WHILE ( ! EOF () )   
		
		cTable += "<tr>"
		cTable += "<td><center> "+ TMP_TAB->D2_ITEM +" </center></td>"
		cTable += "<td><center> "+ (TMP_TAB->D2_COD) +" </center></td>"
		cTable += "<td><center> "+ ALLTRIM(TMP_TAB->B1_DESC) +" </center></td>"
		cTable += "<td><center> "+ cValToChar(TMP_TAB->D2_QUANT) +" </center></td>"
		cTable += "<td><center>R$ "+ TRANSFORM(TMP_TAB->D2_PRCVEN,"@E 999,999,999.99") +"</center></td>"
		cTable += "<td><center>R$ "+ TRANSFORM(TMP_TAB->D2_TOTAL,"@E 999,999,999.99") +"</center></td>"
		cTable += "</tr>"
		DBSkip()
	ENDDO
	
	DBSELECTAREA("TMP_TAB")
	DBCLOSEAREA()   
	
	
	cTable += "<tr style= 'background-color: snow'>"
	cTable += "<td colspan='6'><Font Color='DarkGreen'><b><center><i>Frete: "+TRANSFORM(SF2->F2_FRETE,"@E 999,999,999.99")+"<i></center></b></Font></td>"
	cTable += "</tr>"
	cTable += "<tr style= 'background-color: snow'>"
	cTable += "<td colspan='6'><Font Color='DarkGreen'><b><center><i>Valor Total: "+TRANSFORM(SF2->F2_VALMERC,"@E 999,999,999.99")+"</i></center></b></Font></td>"
	cTable += "</tr>"
	
	cTable += "</table></center>"
	
	DBCloseArea()
	
	RETUR cTable
	
	STATIC FUNCTION TMP_TAB()
	
	LOCAL cQuery := ""
	cQuery := " SELECT SD2010.D2_ITEM, SD2010.D2_COD, SD2010.D2_UM, SD2010.D2_QUANT,"
	cQuery += " SD2010.D2_PRCVEN, SD2010.D2_TOTAL, SB1010.B1_DESC"
	cQuery += " FROM SD2010, SB1010"
	cQuery += " WHERE SD2010.D2_FILIAL = '"+xFilial("SD2")+"'"
	cQuery += " AND SD2010.D2_DOC = '"+SF2->F2_DOC+"'"
	cQuery += " AND SD2010.D_E_L_E_T_ = ''"
	cQuery += " AND SB1010.D_E_L_E_T_ = ''"
	cQuery += " AND SB1010.B1_COD = SD2010.D2_COD	"
	cQuery += " ORDER BY SD2010.D2_ITEM"
	
	DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery), "TMP_TAB",.F.,)
	
	RETURN
	//RADAPE DO EMAIL USUARIO QUE ENVIO DATA HORA....
	STATIC FUNCTION EMAIL_OK()
	
	LOCAL cConteudo
	
	cConteudo := "<br></br>"
	cConteudo += "<p><font size='3' face='Arial'>-------------------INFORMAÇÕES ADICIONAIS----------------</font></p>"
	cConteudo += "<font size='3' face='Arial'><b>USUÁRIO:</b> "+UPPER(ALLTRIM(UsrFullName(RetCodUsr())))
	cConteudo += "<br><b>DATA:</b> "+DTOC(DATE())+"</br>"
	cConteudo += "<b>HORA:</b> "+SUBSTR(cValToChar(TIME()),1,5)+"</font><br/>"
	
	RETURN cConteudo
	
	
	STATIC FUNCTION POSICIONASF2(cNota)
	
	LOCAL cQuery2 := ""
	
	cQuery2 := "SELECT SF2010.F2_FILIAL, SF2010.F2_DOC, SF2010.F2_SERIE, SF2010.F2_CLIENTE, SF2010.F2_LOJA, SF2010.F2_FORMUL, SF2010.F2_TIPO"
	cQuery2 += " FROM SF2010"
	cQuery2 += " WHERE SF2010.F2_FILIAL = '"+xFilial("SF2")+"'"
	cQuery2 += " AND SF2010.D_E_L_E_T_ = ''"
	cQuery2 += " AND SF2010.F2_DOC = '" + SC5->C5_NOTA +"'"
	
	DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery2), "TMP_TAB2",.F.,)
	RETURN	    
	
	STATIC FUNCTION PCEMAIL()
 
	 Local oGet1,oGet2 
	 Local cEndreco   := SPACE(80)
	
	//Exibir a tela
			DEFINE MSDIALOG oDlg1 FROM 190,367 TO 290,890 PIXEL TITLE OemToAnsi("Adicionar Link Rastreio")  
			
		 	TSay():New(012,005,{||OemToAnsi("Link Rastreio: ")},oDlg1,,,,,,.T.,CLR_BLUE,CLR_WHITE,050,008)                    
		
			oGet1:=TGet():New(010    ,060     ,{|u| if(PCount()>0,cEndreco:=u ,cEndreco)},oDlg1,190,010,""/*"@E 99,999,999,999.99"*/,{||},CLR_BLACK,CLR_WHITE,,,,.T.,,,,,.F.,,,, "","cEndreco") 
		        
			@ 035,020 BUTTON  oButton PROMPT "Gravar" OF oDlg1 PIXEL ACTION  oDlg1:End() .And. fGrvValor(cEndreco)                                                                                                                     
		    @ 035,080 BUTTON  oButton PROMPT "Fechar"   OF oDlg1 PIXEL ACTION  oDlg1:End() 
		
			Activate MsDialog oDlg1 Center  
	
	Static Function fGrvValor(cEndreco) 
	
	
		dbSelectArea( "SA4" )
		dbSetOrder( 1 )
		dbSeek( xFilial("SA4")+SC5->C5_TRANSP) 
		
		IF Reclock ("SA4",.F.)				  		  
			replace SA4->A4_ZRASTRE with cEndreco
			MSUnlock()		
		ENDIF
		
		IF MSGYESNO("Link Cadastrado com Sucesso." + Chr(10) + Chr(13) +"Deseja Enviar Resumo de Pedido ao Cliente?")
		 	lRet:= .T.		
		 	 	LinkcNomeTransp := ALLTRIM(POSICIONE("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_ZRASTRE"))
		 	 	cSubject   := "INFORMAÇÕES PARA RASTREAMENTO - CITOPHARMA INDUSTRIAL - NF: " + SF2->F2_DOC 
		ELSE
			lRet:= .F.
	    ENDIF
	return 