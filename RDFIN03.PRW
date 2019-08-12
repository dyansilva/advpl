/*/{Protheus.doc} User Function RDFIN03()
    (long_description)
    @type  Function
    @author user
    @since 12/08/2019
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function RDFIN03()
If (cFilAnt == '0201')
    IF (M->E1_PREFIXO=='BAT' .AND. alltrim(M->E1_ZVENDA) =='')
        MSGINFO("Prefixo do tipo BAT é necessário informar N° de venda.")
        return .F.
    ENDIF
EndIf
Return .T.