#INCLUDE "rwmake.ch"
#include "protheus.ch"

USER FUNCTION RDFAT052()

Local lRet:= .T. 
Local cSegmento:= ""   
Local cSeg :=""
Local cTblSN:= ""
Local nFator := ""
Local nPosProd:= ""
Local nValMax := 0
Local nValMin := 0

Local cOrigem       

cOrigem:= FunName() 

IF(cFilAnt!="0201")
   return.T.
ENDIF

IF(cOrigem == "MATA415")
	
	cCodTabela:= POSICIONE("DA0",3,XFILIAL("DA0")+M->CJ_ZSEG,"DA0_CODTAB")	
	nFator := POSICIONE("SB1",1,XFILIAL("SB1")+TMP1->CK_PRODUTO,"B1_CONV")
	cTblSN:=POSICIONE("SA1",1,XFILIAL("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_ZTBPRC")	
   	cSegmento:= POSICIONE("AOV",1,XFILIAL("AOV")+M->CJ_ZSEG,"AOV_DESSEG")
	
	IF cTblSN=='N'
		RETURN.T.
	ENDIF
	
	DBSELECTAREA("DA1")
	DBSETORDER(7)
	dbSeek(xFilial("DA1")+cCodTabela+TMP1->CK_PRODUTO)
	
	nValMax := DA1->DA1_PRCMAX / nFator
	nValMin := DA1->DA1_PRCVEN / nFator
	nValMax := ROUND(nValMax,3)
	nValMin := ROUND(nValMin,3)
	
	IF M->CK_ZVLRSUM > nValMax .OR. M->CK_ZVLRSUM < nValMin
		lRet:= .F.
		MSGALERT("Valor de venda fora da Tabela de Preço"+CHR(10)+"Segmento: "+cSegmento+chr(10)+"Preço Máximo: " + TRANSFORM(nValMax,"@E 999,999.999")+CHR(10)+"Preço Minimo: "+TRANSFORM(nValMin,"@E 999,999.999"))
	ENDIF
		M->CJ_ZSEG := POSICIONE("DA0",3,XFILIAL("DA0")+M->CJ_ZSEG,"DA0_SEGMTO")
	RETURN lRet
	
ELSEIF(cOrigem == "MATA410") 

	cSeg:= POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_SATIV1")
	
	nPosProd:=aScan(aHeader,{|x| AllTrim(x[2]) == 'C6_PRODUTO'})
	
	cSegmento:=POSICIONE("SX5",1,XFILIAL("SX5")+"T3"+cSeg,"X5_DESCRI")
	cTblSN:=POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_ZTBPRC")	
	cEstr := POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_XESTR")
	nFator:=POSICIONE("SB1",1,XFILIAL("SB1")+aCols[n][nPosProd],"B1_CONV")
	
	
	IF cTblSN=='N'
		RETURN.T.
	ENDIF
	
	DBSELECTAREA("SZF")
	DBSETORDER(1)
	dbSeek(xFilial("SZF")+cSeg + aCols[n][nPosProd]+cEstr)
	
	nValMax := SZF->ZF_PRCMAX / nFator
	nValMin := SZF->ZF_PRCMIN / nFator
	nValMax := ROUND(nValMax,3)
	nValMin := ROUND(nValMin,3)
	
	IF M->C6_ZPREC2U > nValMax .OR. M->C6_ZPREC2U < nValMin
		lRet:= .F.
		MSGALERT("Valor de venda fora da Tabela de Preço"+CHR(10)+"Segmento: "+cSegmento+"("+cEstr+"Estrela(s))"+chr(10)+"Preço Máximo: " + TRANSFORM(nValMax,"@E 999,999.999")+CHR(10)+"Preço Minimo: "+TRANSFORM(nValMin,"@E 999,999.999"))
	ENDIF 
		M->CJ_ZSEG := POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_SATIV1")
		M->CJ_ZESTR :=POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_XESTR")
	RETURN lRet
	
ENDIF



