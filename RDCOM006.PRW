/*/{Protheus.doc} struct
	Customização para bloquear a venda caso o Fornecedor tenha algum documento
	Vencido na tabela SZD - E O DOCUMENTO ESTEJA SETADO PARA BLOQUEAR PEDIDO
	@author  Name
	@example Example
	@param   [Parameter_Name],Parameter_type,Parameter_Description
	@return  Return
	@table   Tables
	@since   22-05-2019
/*/

WSStruct struct

WsData

ENDWsStruct
#include "rwmake.ch" 

User Function RDCOM006()
local cQuery:="" 
Local cAliTMP := GetNextAlias()
Local lRet:= .T.
Local cDocs:=""

cQuery:=" SELECT SZD010.ZD_ZFORNEC, SZD010.ZD_ZLOJAF, SZD010.ZD_CODDOC, SZD010.ZD_BLQPD, SZD010.ZD_NOMDOC, SZD010.ZD_DTPROT, SZD010.ZD_VENCTO"
cQuery+=" FROM SZD010"
cQuery+=" WHERE SZD010.D_E_L_E_T_ <> '*'"
cQuery+=" AND SZD010.ZD_FILIAL = '"+xFilial("SZD")+"'"
cQuery+=" AND SZD010.ZD_ZFORNEC = '"+M->CA120FORN+"'"
cQuery+=" AND SZD010.ZD_ZLOJAF = '"+M->CA120LOJ+"'"
cQuery+=" AND SZD010.ZD_VENCTO < GETDATE()"
cQuery+=" AND SZD010.ZD_BLQPD='S'"
cQuery+=" AND SZD010.ZD_DTPROT = 1/1/1900"

dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery),cAliTMP, .f., .t.) 

	IF (cAliTMP)->(EOF()).AND.(cAliTMP)->(BOF())  	
		lRet:= .T.
	ELSE 
	
		dbSelectArea(cAliTMP)
		dbGoTop()
		   	While !EOF()		   	
				cDocs += (cAliTMP)->ZD_CODDOC+" - " + ALLTRIM((cAliTMP)->ZD_NOMDOC)+" - " + DtoC(StoD((cAliTMP)->ZD_VENCTO))+ chr(10)
				lRet:= .F.
		   	dbskip()	
		   	ENDDO			
			
			IF lRet == .F.		
				AVISO("NECESSÁRIO ATUALIZACAO DE DOCUMENTOS", cDocs, { "Voltar" },3)=1	
			ENDIF
	ENDIF
//	dbCloseArea()
RETURN lRet