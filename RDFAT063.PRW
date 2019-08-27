#INCLUDE 'protheus.ch'

USER FUNCTION RDFAT063()
	
Local cQuery3 := ""
PRIVATE cServer      := "email-ssl.com.br"
PRIVATE cAccount     := "@citopharmaindustrial.com.br" // vereficar qual  E-mail vai ser responsavel pelo ENVIO..
PRIVATE cPassword    := ""
PRIVATE cTo          := "@citopharmaindustrial.com.br"  
PRIVATE cCC		   := ""   
PRIVATE cCC2		   := ""       
PRIVATE cConteudo	   := ""
PRIVATE cSubject   := ""
PRIVATE cConteudo  := ""
PRIVATE LinkcNomeTransp := ""  
PRIVATE cNomeTransp  := "" 
PRIVATE lRet 	   := .T.
	
	cQuery3 := " SELECT SL1010.L1_DOC, SL1010.L1_EMISNF,SL1010.L1_CGCCLI, SL1010.L1_XTIPOEN, SL1010.L1_NUM,SL1010.L1_TRANSP"
	cQuery3 += " FROM SL1010"
	cQuery3 += " WHERE SL1010.L1_FILIAL = '"+xFilial("SL1")+"'"
	cQuery3 += " AND SL1010.L1_DOC BETWEEN '" + cValToChar(alltrim(MV_PAR01)) + "' AND '" + cValTochar(alltrim(MV_PAR02))+"'"
	cQuery3 += " AND SL1010.L1_EMISNF BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04)+ "'"
	cQuery3 += " AND SL1010.L1_XTIPOEN = 5 "
	cQuery3 += " AND SL1010.L1_TRANSP <> ''"
	cQuery3 += " AND SL1010.D_E_L_E_T_ = ''" 
	
	DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery3),"RDFAT063",.F.,)
	
	IF(Empty(alltrim(MV_PAR01)))
		dbSelectArea("RDFAT063")
		DBCloseArea()
		RETURN .F.
	elseif(Empty(alltrim(MV_PAR02)))
		dbSelectArea("RDFAT063")
		DBCloseArea()
		RETURN .F.
	elseif(Empty(alltrim(cValToChar(MV_PAR03))))
		dbSelectArea("RDFAT063")
		DBCloseArea()
		RETURN .F.
	elseif(Empty(alltrim(cValToChar(MV_PAR04))))
		dbSelectArea("RDFAT063")
		DBCloseArea()
		RETURN .F.
	ENDIF

	DBGOTOP()	

	While !EOF()
		Email(RDFAT063->L1_NUM)
		dbSelectArea("RDFAT063")	
		DBSKIP()
	ENDDO 
	dbSelectArea("RDFAT063")
	DBCLOSEAREA()
	return
	
STATIC FUNCTION Email(cPar)  

DBSELECTAREA("SL1") 
DBSETORDER(1)
DBSEEK(XFILIAL("SL1")+cPar)
	
	IF(EMPTY(SL1->L1_DOC))//Verifica se a Nota Já foi Faturada.
		MSGINFO("ESTE PEDIDO AINDA NÃO FOI FATURADO. NAO É POSSIVEL ENVIAR RASTREAMENTO. "+ CHR(13) + "Numero Da Nota: "+ L1_NUM)
		RETURN
	ENDIF
			
	POSICIONASF2()
	
	dbSelectArea("SF2")
	dbSetorder(1)
	dbSeek(TMP_TAB2->F2_FILIAL+TMP_TAB2->F2_DOC+TMP_TAB2->F2_SERIE+TMP_TAB2->F2_CLIENTE+TMP_TAB2->F2_LOJA+TMP_TAB2->F2_FORMUL+TMP_TAB2->F2_TIPO)
	DBSELECTAREA("TMP_TAB2")
	cSubject   := "RASTREAMENTO TRANSPORTADORA - CITOPHARMA" /*-------------*/
	DBCLOSEAREA()

	IF(POSICIONE("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE,"A1_ZENPEDI")== 'N')
		MSGINFO("Cliente Configurado Para Não Receber Rastreamento Por E-mail.")
		RETURN .T. 
	ENDIF

	//cTo := POSICIONE("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_EMAIL")

IF ( Empty(cTo) )
	MSGINFO("E-MAIL DO CLIENTE EM BRANCO")
	RETURN .T.
ENDIF

	LinkcNomeTransp := ALLTRIM(ALLTRIM(POSICIONE("SA4",1,xFilial("SA4")+SL1->L1_TRANSP,"A4_ZRASTRE")))

IF (Empty(LinkcNomeTransp)) 
	cNomeTransp := ALLTRIM(POSICIONE("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME"))		
	IF MSGYESNO("Link da Transportadora " + cNomeTransp + " Não Cadastrado!!" + Chr(13) + "Deseja Cadastra?", "Cadastrar Link Da Transportadora")
		PCEMAIL()
		ELSE
			lRet:= .F.
	ENDIF
ENDIF

cConteudo:= STRUCT_SCREEN()
IF ( lRet)
	U_EMAILOK(cServer, cAccount,cPassword,cTo,cCC,cSubject,cConteudo,cCC2,.F.,.F.)
else			
		cTo:="@citopharmaindustrial.com.br"
		cSubject := "RASTREAMENTO TRANSPORTADORA - CITOPHARMA "
		U_EMAILOK(cServer, cAccount,cPassword,cTo,cCC,cSubject,cConteudo,cCC2,.F.,.F.)
ENDIF

RETURN 

STATIC FUNCTION STRUCT_SCREEN()

LOCAL cConteudo := ""

LinkcNomeTransp := ALLTRIM(POSICIONE("SA4",1,xFilial("SA4")+SL1->L1_TRANSP,"A4_ZRASTRE"))
cNomeTransp:= ALLTRIM(POSICIONE("SA4",1,xFilial("SA4")+SL1->L1_TRANSP,"A4_NOME"))
	
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
cConteudo += "<font size='4' face='Arial' color='Green'><b><center>Mensagem Eletrônica - Citopharma Manipulação de Medicamentos Especiais LTDA</b></center></font><br/>"
cConteudo += "<font size='4' face='Arial' color='Green'><b><center><U>RASTREAMENTO DE ENTREGA - N. FISCAL: "+SF2->F2_DOC+"</U></b></center></font><br/><br/>"
cConteudo += "<font size='5' face='Arial' Color='Black'><b> LINK PARA RASTREAR SEU PEDIDO: <a href='"+ LinkcNomeTransp +"'  style='color: #4B0082'>"+ cNomeTransp +"</font></a></b><br/>"
cConteudo += "<font size='3' face='Arial'> Nota Fiscal: " +SF2->F2_DOC+ "</font><br/>"
cConteudo += "<font size='3' face='Arial'>CNPJ/CPF: "+ IIF(SA1->A1_PESSOA == 'F',Transform(SA1->A1_CGC,"@R 999.999.999-99"),Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")) +"</font><br/>"
cConteudo += "<font size='3' face='Arial'>Data de Emissão: " +Dtoc(SF2->F2_EMISSAO)+ "</font><br/>"
cConteudo += "<p><Font Color='red'><U>Lembramos a importância da conferência dos itens no ato do recebimento dos medicamentos, inclusive a ressalva no conhecimento de transporte caso algo fora da normalidade ocorra.</U></Font></p>"
cConteudo += "<p></p>
cConteudo += CREATE_TABLE()
cConteudo += "<font size='3' face='Arial'></font>"
cConteudo += "</body>"
cConteudo +="</html>"

RETURN cConteudo

STATIC FUNCTION CREATE_TABLE()  

//TABELA CABEÇARIO            

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
cTable += "<th><center>Codico Produto</center></th>"
cTable += "<th><center>Produto</center></th>"
cTable += "<th><center>QUANTIDADE</center></th>"
cTable += "<th><center>PREÇO</center></th>"
cTable += "<th><center>TOTAL</center></th>"
cTable += "</tr>"

TMP_TAB()

dbGoTOP()
WHILE ( ! EOF () )   

	//INFORMAÇÃAO DA TABELA COM PRODUTOS  
	
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
cTable += "<tr style= 'background-color: snow'>"
cTable += "<td colspan='6'><Font Color='DarkGreen'><b><center><i>Valor Total: "+TRANSFORM(SF2->F2_VALMERC,"@E 999,999,999.99")+"</i></center></b></Font></td>"
cTable += "</tr>"

cTable += "</table></center>"

DBCloseArea()

RETURN cTable

STATIC FUNCTION TMP_TAB()

LOCAL cQuery := ""
cQuery := " SELECT SD2010.D2_ITEM, SD2010.D2_COD, SD2010.D2_UM, SD2010.D2_QUANT,"
cQuery += " SD2010.D2_PRCVEN, SD2010.D2_TOTAL, SB1010.B1_DESC"
cQuery += " FROM SD2010, SB1010"
cQuery += " WHERE SD2010.D2_FILIAL = '"+xFilial("SD2")+"'"
cQuery += " AND SD2010.D2_DOC = '"+SF2->F2_DOC+"'"
cQuery += " AND SD2010.D_E_L_E_T_ = ''"
cQuery += " AND SB1010.D_E_L_E_T_ = ''"
cQuery += " AND SB1010.B1_COD = SD2010.D2_COD"
cQuery += " ORDER BY SD2010.D2_ITEM"

DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery), "TMP_TAB",.F.,)

RETURN


STATIC FUNCTION POSICIONASF2(cNota)

LOCAL cQuery2 := ""

cQuery2 := " SELECT SF2010.F2_FILIAL, SF2010.F2_DOC, SF2010.F2_SERIE, SF2010.F2_CLIENTE, SF2010.F2_LOJA, SF2010.F2_FORMUL, SF2010.F2_TIPO"
cQuery2 += " FROM SF2010"
cQuery2 += " WHERE SF2010.F2_FILIAL = '"+xFilial("SF2")+"'"
cQuery2 += " AND SF2010.D_E_L_E_T_ = ''"
cQuery2 += " AND SF2010.F2_DOC = '" + SL1->L1_DOC +"'"

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
	
	dbSelectArea("SA4")
	dbSetOrder(1)
	dbSeek(xFilial("SA4")+SL1->L1_TRANSP) 
	IF Reclock ("SA4",.F.)// Primeiro parâmetro é alias que tem o registro que deve ser alterado 		  	  
		replace SA4->A4_ZRASTRE with cEndreco
		MSUnlock()   	
	ENDIF
	IF MSGYESNO("Link Cadastrado com Sucesso." + Chr(10) + Chr(13) +"Deseja Enviar Resumo de Pedido ao Cliente?")
		lRet:= .T.		
			LinkcNomeTransp := ALLTRIM(POSICIONE("SA4",1,xFilial("SA4")+SL1->L1_TRANSP,"A4_ZRASTRE"))
			cSubject:= "RASTREAMENTO TRANSPORTADORA - CITOPHARMA  "
	ELSE
		lRet:= .F.
	ENDIF
return