#INCLUDE "rwmake.ch"

USER FUNCTION RDFAT050()

Local lRet:= .T.
Local cSeg := ""
Local cEstr := "" 
Local nPosProd:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C6_PRODUTO'})
Local cTblSN
Local cOrigem       

IF(cFilAnt!="0201")
   return.T.
ENDIF



cOrigem:= FunName()

IF(Alltrim(cOrigem) == "MATA415" )
	
	cCodTabela:= POSICIONE("DA0",3,XFILIAL("DA0")+M->CJ_ZSEG,"DA0_CODTAB")

	IF cTblSN=="N"
		RETURN .T.
	ENDIF
	
	DBSELECTAREA("DA1")
	DBSETORDER(7)
	IF dbSeek(xFilial("DA1")+cCodTabela+M->CK_PRODUTO)== .F.
		lRet:= .F.
		IF MSGYESNO("NÃO EXISTE TABELA DE PREÇO CADASTRADA."+CHR(10)+CHR(10)+"PRODUTO: "+Alltrim(POSICIONE("SB1",1,XFILIAL("SB1")+M->CK_PRODUTO,"B1_DESC"))+CHR(10)+"SEGMENTO: "+Alltrim(POSICIONE("AOV",1,XFILIAL("AOV")+M->CJ_ZSEG,"AOV_DESSEG"))+CHR(10)+CHR(10)+"Deseja abrir o cadastro agora?")
			OMSA010()
		ENDIF
	ENDIF                                                                  
 
	M->CJ_ZSEG := POSICIONE("DA0",3,XFILIAL("DA0")+M->CJ_ZSEG,"DA0_SEGMTO")
	TMP1->CK_PRUNIT := POSICIONE("DA1",7,XFILIAL("DA1")+cCodTabela+M->CK_PRODUTO,"DA1_PRCVEN")

	RETURN lRet
	
ELSEIF(cOrigem == "MATA410")
    
    cSeg:= POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_SATIV1")
	cEstr := POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_XESTR")
	cTblSN:=POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_ZTBPRC")
	
	IF cTblSN=="N"
		RETURN .T.
	ENDIF

	DBSELECTAREA("SZF")
	DBSETORDER(1)
	IF dbSeek(xFilial("SZF")+cSeg+M->C6_PRODUTO+cEstr)== .F.
		lRet:= .F.
		MSGINFO("NÃO EXISTE TABELA DE PREÇO CADASTRADA."+CHR(10)+CHR(10)+"PRODUTO: "+Alltrim(POSICIONE("SB1",1,XFILIAL("SB1")+M->C6_PRODUTO,"B1_DESC"))+CHR(10)+"SEGMENTO: "+Alltrim(POSICIONE("SX5",1,XFILIAL("SX5")+"T3"+cSeg,"X5_DESCRI "))+" ("+cEstr+" Estrela(s))"+CHR(10)+CHR(10)+"Solicite Cadastro Para o Comercial!")
	ENDIF 
		M->CJ_ZSEG := POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_SATIV1")
		M->CJ_ZESTR := POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_XESTR")
	RETURN lRet
	
ENDIF




