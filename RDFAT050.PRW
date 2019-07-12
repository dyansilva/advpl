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
	
	cSeg:=POSICIONE("SA1",1,XFILIAL("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_SATIV1")
	cEstr := POSICIONE("SA1",1,XFILIAL("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_XESTR")
	cTblSN:=POSICIONE("SA1",1,XFILIAL("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_ZTBPRC")
	
	IF cTblSN=="N"
		RETURN .T.
	ENDIF
	
	DBSELECTAREA("SZF")
	DBSETORDER(1)
	
	
	IF dbSeek(xFilial("SZF")+cSeg+M->CK_PRODUTO+cEstr)== .F.
		lRet:= .F.
		
		IF MSGYESNO("NÃO EXISTE TABELA DE PREÇO CADASTRADA."+CHR(10)+CHR(10)+"PRODUTO: "+Alltrim(POSICIONE("SB1",1,XFILIAL("SB1")+M->CK_PRODUTO,"B1_DESC"))+CHR(10)+"SEGMENTO: "+Alltrim(POSICIONE("SX5",1,XFILIAL("SX5")+"T3"+cSeg,"X5_DESCRI"))+"("+cEstr+" Estrela(s))"+CHR(10)+CHR(10)+"Deseja abrir o cadastro agora?")
			U_CADTBSEG()
		ENDIF
	ENDIF                                                                  
 
	M->CJ_ZSEG := POSICIONE("SA1",1,XFILIAL("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_SATIV1")
	M->CJ_ZESTR := POSICIONE("SA1",1,XFILIAL("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_XESTR")     

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




