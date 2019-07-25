
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
    PRIVATE cSubject := "Atualização de Documento"
    PRIVATE cConteudo := ""
    PRIVATE lRet := .T.

    cQuery := " SELECT SZD010.ZD_COD, SZD010.ZD_CLIFOR, SZD010.ZD_ZFORNEC, SZD010.ZD_ZTRANSP, ZD_NOM, SZD010.ZD_CODDOC, SZD010.ZD_NOMDOC,SZD010.ZD_VENCTO, SZD010.ZD_CONTATO, SZD010.ZD_EMAIL,SZD010.ZD_ZCLIFOR,SZD010.ZD_DTPROT,SZD010.ZD_ZPERENV,SZD010.ZD_ZDATAEV, SZD010.ZD_ZPXDATA,SZD010.ZD_LOJA,SZD010.ZD_ZLOJAF"
    cQuery += " FROM SZD010"
    cQuery += " WHERE SZD010.D_E_L_E_T_ <> '*'"
    cQuery += " AND SZD010.ZD_FILIAL = '" + xFilial("SZD")+"'"
    cQuery += " AND SZD010.ZD_VENCTO <= " + DTOS(DATE())
    cQuery += " AND SZD010.ZD_ZPXDATA <= " + DTOS(DATE())
    cQuery += " AND SZD010.ZD_DTPROT = ''"
    CQUERY += " ORDER BY ZD_COD"

    dbUseArea(.T.,"TOPCONN", tcgenqry(,,cQuery), "SZD_TEMP", .F.,.T.)

    dbselectArea("SZD_TEMP")
    dbGoTop()
    while !EOF()
        //cTo:=""
        IF(Empty(cTo))
            dbSkip()
        loop
        EndIf   
        bodyEmail()
        IF ( lRet)
            U_EMAILOK(cServer, cAccount,cPassword,cTo,cCC,cSubject,cConteudo,cCC2,.F.,.F.)
            SaveDate(SZD_TEMP->ZD_COD)
        endif    
        dbSelectArea("SZD_TEMP")      
      dbskip()
    enddo
    Return

    Static Function bodyEmail()

        cConteudo:=""
        cConteudo+="<html lang='br'>"
        cConteudo+="<head>"
        cConteudo+=" <meta charset='UTF-8'>"
        cConteudo+=" <meta name='viewport' content='width=device-width, initial-scale=1.0'>"
        cConteudo+=" <meta http-equiv='X-UA-Compatible' content='ie=edge'>"
        cConteudo+=" <title>Document</title>"
        cConteudo+="</head>"
        cConteudo+="<body>"
        cConteudo+=" <style type='text/css'>"
        cConteudo+="body {"
        cConteudo+="    font-family: ARIAL;"
        cConteudo+="    margin-top: 10px;"
        cConteudo+="    margin-left: 150px;"
        cConteudo+="    margin-right: 150px;"
        cConteudo+="}"

        cConteudo+="td.cabecalho1 {"
        cConteudo+="    background-color: #00B050;"
        cConteudo+="    border-bottom: 1px solid #b12025;"
        cConteudo+="    color: #FFFFFF;"
        cConteudo+="    font-size: 12pt;"
        cConteudo+="    font-weight: bold;"
        cConteudo+="    height: 30px;"
        cConteudo+="    padding: 16px;"
        cConteudo+="    text-align: center;"
        cConteudo+="}"

        cConteudo+="td.cabecalho2 {"
        cConteudo+="    border-bottom: 1px solid #b12025;"
        cConteudo+="    border-right:0px solid #b12025;"
        cConteudo+="    color: ;"
        cConteudo+="    font-size: 12pt;"
        cConteudo+="    font-weight: bold;"
        cConteudo+="    height: 30px;"
        cConteudo+="    padding: 8px;"
        cConteudo+="    text-align: center;"
        cConteudo+="}"

        cConteudo+="td.titulo {"
        cConteudo+="    background-color: #808080;"
        cConteudo+="    border-bottom: 1px solid #b12025;"
        cConteudo+="    border-right: 1px solid #b12025;"
        cConteudo+="    border-left: 1px solid #b12025;"
        cConteudo+="    color: #FFFFFF;"
        cConteudo+="    font-size: 14pt;"
        cConteudo+="    font-weight: bold;"
        cConteudo+="    padding: 8px;"
        cConteudo+="    text-align: center;"
        cConteudo+="}"

        cConteudo+="td.detalhe {"
        cConteudo+="    background-color: #FFFAFA;"
        cConteudo+="    border-bottom: 1px solid #b12025;"
        cConteudo+="    border-right: 1px solid #b12025;"
        cConteudo+="    border-left: 1px solid #b12025;"
        cConteudo+="    color: #000000;"
        cConteudo+="    font-size: 12pt;"
        cConteudo+="    font-weight: bold;"
        cConteudo+="    padding: 22px 8px;"
        cConteudo+="    text-align: center;"
        cConteudo+="}"

        cConteudo+="td.mensagem {"
        cConteudo+="    background-color: #00B050;"
        cConteudo+="    border-bottom: 1px solid #b12025;"
        cConteudo+="    color: #FFFFFF;"
        cConteudo+="    font-size: 12pt;"
        cConteudo+="    font-weight: bold;"
        cConteudo+="    padding: 18px 90px;"
        cConteudo+="    text-align: center;"
        cConteudo+="}"
        cConteudo+=" </style>"


        cConteudo+="    <table width='100%' cellspacing='0' cellpadding='0' border='0'>"
        cConteudo+="      <tbody>"
        cConteudo+="        <tr>"
        cConteudo+="          <td>"
        cConteudo+="            <table class='grade' width='100%' cellspacing='0' cellpadding='0' border='0'>"
        cConteudo+="              <tbody>"
        cConteudo+="                <tr>"
        cConteudo+="                  <td class='cabecalho1' width='70%'>AVISO DE VENCIMENTO DO DOCUMENTO</td>"
        cConteudo+="                </tr>"
        cConteudo+="                <tr>"
        cConteudo+="                  <td class='cabecalho2' width='50%'>" +SZD_TEMP->ZD_NOM + "</td>"
        cConteudo+="                </tr>"
        cConteudo+="                <tr>"
         dbselectArea("SZD_TEMP")
    IF SZD_TEMP->ZD_ZCLIFOR == 'C'
	    cConteudo +=" <td class='cabecalho2' width='20%'>C.N.P.J.:" +ALLTRIM(transform(POSICIONE("SA1",1,xFilial("SA1")+SZD_TEMP->ZD_CLIFOR+ SZD_TEMP->ZD_LOJA,"SA1->A1_CGC"),"@R 99.999.999/9999-99")) + "</td>"  
    ELSEIF SZD_TEMP->ZD_ZCLIFOR == 'F'
	    cConteudo +=" <td class='cabecalho2' width='20%'>C.N.P.J.:" +alltrim(transform(POSICIONE("SA2",1,xFilial("SA2")+SZD_TEMP->ZD_ZFORNEC+ SZD_TEMP->ZD_ZLOJAF,"SA2->A2_CGC"),"@R 99.999.999/9999-99")) +"</td>"
    ELSEIF SZD_TEMP->ZD_ZCLIFOR == 'T' 
        cConteudo +=" <td class='cabecalho2' width='20%'>C.N.P.J.:" +alltrim(transform(POSICIONE("SA4",1,xFilial("SA4")+SZD_TEMP->ZD_ZTRANSP,"SA4->A4_CGC"),"@R 99.999.999/9999-99")) +"</td>"
    ENDIF
        cConteudo+="                </tr>"
        cConteudo+="              </tbody>"
        cConteudo+="            </table>"
        cConteudo+="          </td>"
        cConteudo+="        </tr>"
        cConteudo+="      </tbody>"
        cConteudo+="    </table>"
        cConteudo+="    <table style='margin-top:3px' width='100%' cellspacing='0' cellpadding='0' border='0'>"
        cConteudo+="      <tbody>"
        cConteudo+="        <tr>"
        cConteudo+="          <td bgcolor='#0094E0'>"
        cConteudo+="            <table class='grade' width='100%' cellspacing='0'
        cConteudo+="              cellpadding='0' border='0'>"
        cConteudo+="              <tbody>"
        cConteudo+="                <tr>"
        cConteudo+="                  <td class='mensagem' colspan='3' width='100%'>Identificamos"
        cConteudo+="                    em nosso cadastro, documentos a vencer nos
        cConteudo+="                    próximos dias. Gentileza enviar o documento
        cConteudo+="                    atualizado ou protocolo de renovação
        cConteudo+="                    para o e-mail '<a moz-do-not-send='true'>'@citophaindustrial.com.br'</a>'
        cConteudo+="                    para maiores informações entrar em contato por esse mesmo e-mail ou fone (31) 3115-6120. </td>"
        cConteudo+="                </tr>"
        cConteudo+="                <tr>"
        cConteudo+="                  <td class='titulo' width='40%'>Documento</td>"
        cConteudo+="                  <td class='titulo' width='20%'>Número</td>"
        cConteudo+="                  <td class='titulo' width='40%'>Vencimento</td>"
        cConteudo+="                </tr>"
        cConteudo+="                <tr>"
        cConteudo+="                  <td class='detalhe' width='40%'>"+SZD_TEMP->ZD_NOMDOC+"</td>"
        cConteudo+="                  <td class='detalhe' width='20%'>"+SZD_TEMP->ZD_CODDOC+"</td>"
        cConteudo+="                  <td class='detalhe' width='40%'>"+ DtoC(StoD(SZD_TEMP->ZD_VENCTO))+"</td>"
        cConteudo+="                </tr>"
        cConteudo+="              </tbody>"
        cConteudo+="            </table>"
        cConteudo+="          </td>"
        cConteudo+="        </tr>"
        cConteudo+="      </tbody>"
        cConteudo+="    </table>"
        cConteudo+="</body>"
        cConteudo+="</html>"
    return 

Static Function SaveDate(nCod)

    dbSelectArea("SZD")
    dbSetOrder(1)
    dbSeek(xFilial("SZD")+nCod)

    if Reclock ("SZD",.F.)
        replace ZD_ZDATAEV with date()
        replace ZD_ZPXDATA with ZD_ZDATAEV + ZD_ZPERENV
        MSUnlock()
    Else
        msgAlert("Registro já está em uso")
    Endif

return


