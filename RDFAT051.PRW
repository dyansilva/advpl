#INCLUDE "rwmake.ch"
#include "protheus.ch"

USER FUNCTION RDFAT051()

Local lRet:= .T. 
Local nPosProd:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C6_PRODUTO'})
Local nPosPreco:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C6_PRCVEN'})
Local cEstr := ""
Local cSegmento:=""
Local cTblSN:= ""
Local cOrigem       
Local cSeg:=""

cOrigem:= FunName() 

IF(cFilAnt!="0201")
   return.T.
ENDIF
 
IF(cOrigem == "MATA415")//Orçamento.
	
	cCodTabela:= POSICIONE("DA0",3,XFILIAL("DA0")+M->CJ_ZSEG,"DA0_CODTAB")
	cSegmento:= POSICIONE("AOV",1,XFILIAL("AOV")+M->CJ_ZSEG,"AOV_DESSEG") 
	
	IF cTblSN=='N'
		RETURN.T.
	ENDIF
	
	DBSELECTAREA("DA1")
	DBSETORDER(7)
	dbSeek(xFilial("DA1")+cCodTabela+TMP1->CK_PRODUTO)

	IF TMP1->CK_PRCVEN > DA1->DA1_PRCMAX
		lRet:= .F.
		MSGALERT("Valor de venda fora da Tabela de Preço"+CHR(10)+"Segmento: "+cSegmento+chr(10)+"Preço Máximo: " + AllTrim(Transform(DA1->DA1_PRCMAX,PesqPict("DA1","DA1_PRCMAX")))+CHR(10)+"Preço de Venda: "+AllTrim(Transform(DA1->DA1_PRCVEN,PesqPict("DA1","DA1_PRCVEN"))))	
	ENDIF
		M->CJ_ZSEG := POSICIONE("DA0",3,XFILIAL("DA0")+M->CJ_ZSEG,"DA0_SEGMTO")
	RETURN lRet
	
ELSEIF(cOrigem == "MATA410")

	cSeg:=POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_SATIV1")
	
	cSegmento:= POSICIONE("SX5",1,XFILIAL("SX5")+"T3"+cSeg,"X5_DESCRI")
	cTblSN:=POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_ZTBPRC")	
	cEstr := POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_XESTR")
	
	IF cTblSN=='N'
		RETURN.T.
	ENDIF    
		
	DBSELECTAREA("SZF")
	DBSETORDER(1)
   	dbSeek(xFilial("SZF")+cSeg+aCols[n][nPosProd]+cEstr) 
	
	IF M->C6_PRCVEN > SZF->ZF_PRCMAX .OR. M->C6_PRCVEN < SZF->ZF_PRCMIN
		lRet:= .F.
		MSGALERT("Valor de venda fora da Tabela de Preço"+CHR(10)+"Segmento: "+cSegmento+"("+cEstr+"Estrela(s))"+chr(10)+"Preço Máximo: " + Transform(SZF->ZF_PRCMAX,PesqPict("SZF","ZF_PRCMAX"))+CHR(10)+"Preço Minimo: "+Transform(SZF->ZF_PRCMIN,PesqPict("SZF","ZF_PRCMAX")))
	ENDIF
ENDIF	
		M->CJ_ZSEG := POSICIONE("SX5",1,XFILIAL("SX5")+"T3"+cSeg,"X5_DESCRI")
		M->CJ_ZESTR :=POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_XESTR")
	RETURN lRet