/*/{Protheus.doc} RDFAT070
User    (long_description)
    @type  Function
    @author dyan.filipe 
    @since 20/09/2019
    @version version
    @verefica se esse cliente correte já contem esse numero de ordem de compra
    @return return, return_type, return_description

    @see (links_or_references)
    /*/
User Function RDFAT070()
LOCAL cQuery := ""
LOCAL lRet := .T.

cQuery := " SELECT SC5010.C5_CLIENTE, SC5010.C5_LOJACLI, SC5010.C5_ZAFCLI"
cQuery += " FROM SC5010"
cQuery += " WHERE SC5010.D_E_L_E_T_ != '*'"
cQuery += " AND SC5010.C5_FILIAL = '" + xFilial("SC5") +"'"
cQuery += " AND SC5010.C5_ZAFCLI NOT LIKE '%MAIL%'"
cQuery += " AND SC5010.C5_CLIENTE = '" +M->C5_CLIENTE + "'"
cQuery += " AND SC5010.C5_LOJACLI = '" + M->C5_LOJACLI +"'"
cQuery += " AND SC5010.C5_ZAFCLI = '"+ alltrim(M->C5_ZAFCLI)+"'"

dbUseArea(.T.,"TOPCONN", tcgenqry(,,cQuery), "SC5_TEMP", .F.,.T.)

If (SC5_TEMP->(EOF()) .AND. SC5_TEMP->(BOF()))
ELSE
    MSGALERT("Já existe uma ordem de compra para esse cliente com este número. Verifique possível duplicidade. Caso sejá segunda parcela de um pedido adicionar barra" +"(/)"+ " seguido o número da parcela.")
    lRet := .F.
EndIf
	dbSelectArea("SC5_TEMP")
	DBCloseArea()

Return lRet