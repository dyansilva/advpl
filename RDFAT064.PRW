
/*{Protheus.doc} User Function RDFAT06()
    (long_description)
    @type  RDFAT064.PRW
    @author DYANFELIPE
    @since 11/07/2019
    @version 0.01
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
*/
    
    #INCLUDE 'Protheus.ch'
    USER Function RDFAT064()

    LOCAL cQuery := ""
    PRIVATE cServer := "email-ssl.com.br"
    PRIVATE cAccount := ""
    PRIVATE cPassword := ""
    PRIVATE cTo := ""
    PRIVATE cCC := ""
    PRIVATE cCC2 := ""
    PRIVATE cSubject := "Atualização de documento"
    PRIVATE cConteudo := ""
    PRIVATE lRet := .T.

    cQuery := " SELECT SZD010.ZD_COD, SZD010.ZD_CLIFOR, SZD010.ZD_ZFORNEC, SZD010.ZD_ZTRANSP, ZD_NOM, SZD010.ZD_CODDOC, SZD010.ZD_NOMDOC,SZD010.ZD_VENCTO, SZD010.ZD_CONTATO, SZD010.ZD_EMAIL,SZD010.ZD_ZCLIFOR,SZD010.ZD_DTPROT"
    cQuery += " FROM SZD010"
    cQuery += " WHERE SZD010.D_E_L_E_T_ <> '*'"
    cQuery += " AND SZD010.ZD_FILIAL = '" + xFilial("SZD")+"'"
    cQuery += " AND SZD010.ZD_VENCTO <= " + DTOS(DATE())
    cQuery += " AND SZD010.ZD_COD BETWEEN '0001' AND '0012'" 
    cQuery += " AND SZD010.ZD_DTPROT = ''"
    CQUERY += " ORDER BY ZD_COD"

    dbUseArea(.T.,"TOPCONN", tcgenqry(,,cQuery), "SZD_TEMP", .F.,.T.)

   

   
    dbselectArea("SZD_TEMP")
    dbGoTop()
    while !eof()
cTo:=""

IF(Empty(cTo))
    MsgInfo("E-mail do remetente está em branco.")
    dbSkip()
    loop

EndIf   
    bodyEmail()

    IF ( lRet)
        U_EMAILOK(cServer, cAccount,cPassword,cTo,cCC,cSubject,cConteudo,cCC2,.F.,.F.)
    endif
    dbskip()
    enddo

    Return

    Static Function bodyEmail()
   

        cConteudo:=""
        cConteudo+= "<html lang='en'>"
        cConteudo+= "<head>"
        cConteudo+= "<meta charset='UTF-8'>
        cConteudo+= "   <meta name='viewport' content='width=device-width, initial-scale=1.0'>"
        cConteudo+= "   <meta http-equiv='X-UA-Compatible' content='ie=edge'>"
        cConteudo+= "</head>"
        cConteudo+= "<body>"
        cConteudo+= "Bom dia. </br>"
        cConteudo+= ""
        cConteudo+= "cod: " + SZD_TEMP->ZD_COD
        cConteudo+= "t: " +SZD_TEMP->ZD_NOMDOC
        cConteudo+= ""
        cConteudo+= ""
        cConteudo+= ""
        cConteudo+= "</body>"
        cConteudo+= "</html>"
       

return 