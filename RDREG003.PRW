#INCLUDE 'protheus.ch'
USER FUNCTION RDREG003()

PRIVATE cServer := ""
PRIVATE cAccount := ""
PRIVATE cPassword := ""
PRIVATE cTo := ""
PRIVATE cCC	:= ""
PRIVATE cCC2 := ""
PRIVATE cConteudo := ""
PRIVATE cQuery2 := ""
PRIVATE cont
PRIVATE cSubject := "Segue lista de Tarefa"
PRIVATE cConteud := ""
PRIVATE lRet:= .T.
PRIVATE cTime := Time()
PRIVATE dData := date()


cQuery2+=" SELECT DISTINCT SZI010.ZI_COD, SZI010.ZI_ZUSUARI, SZI010.ZI_ZTITULO ,SZI010.ZI_ZINFORM,SZI010.ZI_ZALETU, SZI010.ZI_ZDATAIN, SZI010.ZI_ZDATAFI, SZI010.ZI_ZDPARTM,SZI010.ZI_CODUSER,SZI010.ZI_NOMEUSR,SZJ010.ZJ_ZDATEEV"
cQuery2+=" FROM SZI010, SZJ010"
cQuery2+=" WHERE SZI010.D_E_L_E_T_ <> '*'" 
cQuery2+=" AND SZJ010.D_E_L_E_T_ <> '*'"
cQuery2+=" AND SZI010.ZI_FILIAL = '"+xFilial("SZI")+"'" 
cQuery2+=" AND SZJ010.ZJ_ZDATEEV <> " + dtos(DATE())
cQuery2+=" AND SZI010.ZI_COD = SZJ010.ZJ_ZNUM"
cQuery2+=" AND SZI010.ZI_ZDATAIN <= GETDATE() + SZI010.ZI_ZALETU"
cQuery2+=" AND SZI010.ZI_ZSTATUS <> '2'"
cQuery2+=" ORDER BY ZI_COD "
dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery2),"TSZI", .F.,.T.)  


IF TMPT->(EOF()).AND.TMPT->(BOF())
	return .T.
ELSE
	IF MSGYESNO("ENVIA EMAIL")
	else
		return .T.
	ENDIF
ENDIF

cTo := UsrRetMail(RetCodUsr())

IF ( Empty(cTo) )
	MSGINFO("E-MAIL EM BRANCO")
	RETURN .T.
ENDIF

cConteudo:= DadosEmail()
IF ( lRet)
	U_EMAILOK(cServer, cAccount,cPassword,cTo,cCC,cSubject,cConteudo,cCC2,.F.,.F.)
ENDIF

RETURN

STATIC FUNCTION DadosEmail()

LOCAL cConteudo := ""
LOCAL aArea := GetArea()

cConteudo:= "<html lang='en'>"
cConteudo+= "<head>"
cConteudo+= "<meta charset='UTF-8'>
cConteudo+= "   <meta name='viewport' content='width=device-width, initial-scale=1.0'>"
cConteudo+= "   <meta http-equiv='X-UA-Compatible' content='ie=edge'>"
cConteudo+= "<link rel='stylesheet' href='https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css' integrity='sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T' crossorigin='anonymous'>"
cConteudo+= "</head>"
cConteudo+= "<body>"
cConteudo+= "   <center>"
cConteudo+= "     <h2>"
cConteudo+= "     Segue as tarefas a ser realizadas</br>"
cConteudo+= " 	  Data: "+ DtoC(dData) +" - "+ cTime +"</br>"
cConteudo+= "    </h2>"
cConteudo+= "   </center>"
cConteudo+= "</body>"
cConteudo+= "</html>"


cConteudo +="<html lang='en'>"
cConteudo +="<head>"
cConteudo +="<meta charset='UTF-8'>
cConteudo +="   <meta name='viewport' content='width=device-width, initial-scale=1.0'>"
cConteudo +="   <meta http-equiv='X-UA-Compatible' content='ie=edge'>"
cConteudo += "<link rel='stylesheet' href='https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css' integrity='sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T' crossorigin='anonymous'>"
cConteudo +="</head>"
cConteudo +="<style type='text/css'>"
cConteudo +="	body {"
cConteudo +="  font: 75%/1.6 'Myriad Pro', Frutiger, 'Lucida Grande', 'Lucida Sans', 'Lucida Sans Unicode', Verdana, sans-serif;"
cConteudo +="}"
cConteudo +="table {"
cConteudo +="  border-collapse: collapse;"
cConteudo +="  width: 50em;"
cConteudo +="  border: 1px solid #666;"
cConteudo +="}"
cConteudo +="thead {"
cConteudo +="  background: #ccc url(https://www.devfuria.com.br/html-css/tabelas/bar.gif) repeat-x left center;"
cConteudo +="  border-top: 1px solid #a5a5a5;"
cConteudo +="  border-bottom: 1px solid #a5a5a5;"
cConteudo +="}"
cConteudo +="tr:hover {"
cConteudo +="  background-color:#3d80df;"
cConteudo +="  color: #fff;"
cConteudo +="}"
cConteudo +="thead tr:hover {"
cConteudo +="  background-color: transparent;"
cConteudo +="  color: inherit;"
cConteudo +="  color: blue;"
cConteudo +="}"
cConteudo +="tr:nth-child(even) {"
cConteudo +="    background-color: #edf5ff;"
cConteudo +="}"
cConteudo +="th,td {"
cConteudo +="  text-align: left;"
cConteudo +="  font-style: italic;"
cConteudo +="  font-family: serif;"
cConteudo +="}"
cConteudo +="th, td {"
cConteudo +="  padding: 0.1em 1em;"
cConteudo +="}"
cConteudo +=".Respque{"
cConteudo +="    color: red;"
cConteudo +="}"
cConteudo +="  td{"
cConteudo +="    font-size: 14px;"
cConteudo +="  }"
cConteudo +="  </style>"
cConteudo +="<body>"

dbSelectArea("TSZI")
dbgotop()

while !EOF()
	
	TMP_TAB()
	dbSelectArea("TMP_TAB")
	dbGoTop()
	
	IF(TSZI->ZI_CODUSER == RetCodUsr() .OR. TMP_TAB->ZJ_ZCODUSU == RetCodUsr())
		cConteudo +=" <table class='table table-hover'>"
		cConteudo +="    <thead>"
		cConteudo +="      <tr>"
		cConteudo +="        <tr class='Respque'>"
		cConteudo +="          <th colspan='2'>Requerente: "+substr(TSZI->ZI_ZUSUARI,1,30) +" </th>"
		cConteudo +="          <th colspan='6' >Respons�vel OS: "+substr(TSZI->ZI_NOMEUSR,1,30)+"</th>"
		cConteudo +="          </tr>"
		cConteudo +="          <th scope='col'>C�digo</th>"
		cConteudo +="          <th scope='col'>Titulo Tarefa</th>"
		cConteudo +="          <th scope='col'>Informa��o</th>"
		cConteudo +="          <th scope='col'>Usu�rio</th>"
		cConteudo +="          <th scope='col'>Data Inicial</th>"
		cConteudo +="          <th scope='col'>Data Final</th>"
		cConteudo +="          <tr>"
		cConteudo +="            <th scope='col'>"+TSZI->ZI_COD+"</th>"
		cConteudo +="            <th scope='col'>"+TSZI->ZI_ZTITULO+"</th>"
		cConteudo +="            <th scope='col'>"+TSZI->ZI_ZINFORM+"</th>"
		cConteudo +="            <th scope='col'>"+TSZI->ZI_ZUSUARI+"</th>"
		cConteudo +="            <th scope='col'>"+DtoC(StoD(TSZI->ZI_ZDATAIN))+"</th>"
		cConteudo +="            <th scope='col'>"+DtoC(StoD(TSZI->ZI_ZDATAFI))+"</th>"
		cConteudo +="          </tr>"
		cConteudo +="    </thead>"
		cConteudo +="<tbody>"
		cConteudo +="<tr>"
		
		dbSelectArea("TMP_TAB")
		dbGoTop()
		While !EOF()
		GravaDataEv(TMP_TAB->ZJ_ZNUM,TMP_TAB->ZJ_ITEM)	
			cConteudo +="		<td>item: "+TMP_TAB->ZJ_ITEM+"</td>"
			cConteudo +="		<td>"+SUBSTR(TMP_TAB->ZJ_DESC,1,30)+"</td>"
			cConteudo +="		<td>Atribuida: "+SUBSTR(TMP_TAB->ZJ_ZNOMEUS,1,12)+"</td>"
			cConteudo +="		<td>"+Substr(TMP_TAB->ZJ_ZINFORM,1,20)+"</td>"
			cConteudo +="		<td>"+DtoC(StoD(TMP_TAB->ZJ_ZDATA))+"</td>"
			
			if (TMP_TAB->ZJ_ZSTATUS=="1")
				cConteudo +="<td>Aberto</br>"
			elseif(TMP_TAB->ZJ_ZSTATUS=="2")
				cConteudo +="<td>Fechado</td>"
			else
				cConteudo +="<td>Campo em branco</td>"
			endif
			
			cConteudo +="</tr>"
			cConteudo +="</tbody>"
			cConteudo +="</br>"
			cConteudo +="  <script src='https://code.jquery.com/jquery-3.3.1.slim.min.js' integrity='sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo' crossorigin='anonymous'></script>"
			cConteudo +="  <script src='https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js' integrity='sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1' crossorigin='anonymous'></script>"
			cConteudo +="  <script src='https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js' integrity='sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM' crossorigin='anonymous'></script>"
			cConteudo +="</body>"
			cConteudo +="</html>"
			
			dbSelectArea("TMP_TAB")
			dbskip()
		enddo
	endif
	
	dbselectArea("TMP_TAB")
	dbCloseArea()
	dbSelectArea("TSZI")
	dbSkip()
ENDDO

RETURN cConteudo

STATIC FUNCTION TMP_TAB()

LOCAL cQuery1 := ""
cQuery1 += " SELECT SZJ010.ZJ_ZNUM,SZJ010.ZJ_ITEM,SZJ010.ZJ_DESC,SZJ010.ZJ_ZSTATUS,SZJ010.ZJ_ZNOMEUS, SZJ010.ZJ_ZINFORM, SZJ010.ZJ_ZDATA,SZJ010.ZJ_ZCODUSU, SZJ010.ZJ_ZDATEEV"
cQuery1 += " FROM SZJ010"
cQuery1 += " WHERE SZJ010.D_E_L_E_T_ <> '*'"
cQuery1 += " AND SZJ010.ZJ_FILIAL = '"+xFilial("SZJ")+"'"
cQuery1 += " AND SZJ010.ZJ_ZDATA <= GETDATE() + SZJ010.ZJ_ZALERTA"
cQuery1 += " AND SZJ010.ZJ_ZDATEEV <> " + dtos(DATE())
cQuery1 += " AND SZJ010.ZJ_ZNUM = "+TSZI->ZI_COD 
IF(TMPT->ZI_CODUSER <> RetCodUsr())
cQuery1 += " AND SZJ010.ZJ_ZCODUSU =" + RetCodUsr()
ENDIF

DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery1), "TMP_TAB",.F.,)

RETURN

static Function GravaDataEv(cNum,cItem)

dbSelectArea("SZJ")
dbSetOrder(1)
dbSeek(xFilial("SZJ")+cNum+cItem)

if Reclock ("SZJ",.F.)
	
	replace ZJ_ZDATEEV with date()
	MSUnlock()
Else
	msgAlert("Registro em uso")
Endif

return
