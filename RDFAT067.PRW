/*/{Protheus.doc} struct
	Estrutura de dados para array.
	@author  RDFAT36.PRW
	@example Example
	@param   [Parameter_Name],Parameter_type,Parameter_Description
	@return  Customização para bloquear a venda caso a transportadora não tenha documento cadastrado ou tenha documento vencido.
	@table   Tables
	@since   31-07-2019
/*/

#include "rwmake.ch" 

User Function RDFAT067()

local cQuery1:="" 
local cQuery:="" 
Local cAliTMP := GetNextAlias()
LOCAL cAliTMPs := GetNextAlias()
Local lRet:= .T.
Local cDocs:=""

cQuery:=" SELECT SZD010.ZD_CLIFOR, SZD010.ZD_LOJA, SZD010.ZD_CODDOC, SZD010.ZD_BLQPD, SZD010.ZD_NOMDOC, SZD010.ZD_VENCTO, SZD010.ZD_DTPROT, SZD010.ZD_ZTRANSP"
cQuery+=" FROM SZD010"
cQuery+=" WHERE SZD010.D_E_L_E_T_ <> '*'"
cQuery+=" AND SZD010.ZD_FILIAL = '"+xFilial("SZD")+"'"
cQuery+=" AND SZD010.ZD_ZTRANSP = '"+M->C5_TRANSP+"'"
cQuery+=" AND SZD010.ZD_VENCTO < GETDATE()"
cQuery+=" AND SZD010.ZD_BLQPD='S'"
cQuery+=" AND SZD010.ZD_DTPROT = ''"
dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery),cAliTMP, .f.,)

cQuery1:=" SELECT SZD010.ZD_CLIFOR, SZD010.ZD_LOJA, SZD010.ZD_CODDOC, SZD010.ZD_BLQPD, SZD010.ZD_NOMDOC, SZD010.ZD_VENCTO, SZD010.ZD_DTPROT, SZD010.ZD_ZTRANSP"
cQuery1+=" FROM SZD010"
cQuery1+=" WHERE SZD010.D_E_L_E_T_ <> '*'"
cQuery1+=" AND SZD010.ZD_FILIAL = '"+xFilial("SZD")+"'"
cQuery1+=" AND SZD010.ZD_ZTRANSP = '"+M->C5_TRANSP+"'"
dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery1),cAliTMPs, .f.,)

	IF (cAliTMP)->(EOF()).AND.(cAliTMP)->(BOF())
		lRet:= .T.
	iF (cAliTMPs) -> (EOF())
		AVISO("NECESSÁRIO CADASTRO DE DOCUMENTOS", "Não foi encontrado documento cadastrado da transportadora. " +CHR(13)+CHR(10) +"Favor cadastra. Toda transportadora devera ter no mínimo um documento cadastrado.", { "Voltar" },3)=1	
		return .F.
	ENDIF
	ELSE		
		dbSelectArea(cAliTMP)
		dbGoTop()
			While !EOF()
				lRet:= .F.
				cDocs += (cAliTMP)->ZD_CODDOC+" - " + ALLTRIM((cAliTMP)->ZD_NOMDOC)+" - " + DtoC(StoD((cAliTMP)->ZD_VENCTO))+ chr(10)
			dbskip()	
			Enddo	
			
			IF lRet == .F.		
				AVISO("NECESSÁRIO ATUALIZAÇÃO DE DOCUMENTOS", cDocs, { "Voltar" },3)=1	
			ENDIF
	ENDIF

dbCloseArea()
	
RETURN lRet