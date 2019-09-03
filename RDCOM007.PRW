

User function RDCOM007()

//Declaracao de Variaveis
Local Cabec1 := "Código   Fornecedor                                                   Contato                        Data de Emissão    Data de Entrega"
Local Cabec2 := ""
Local titulo := "Compras a receber"
Local cDesc1 := "Retório de compras QUE JÁ FORAM REALIZADA"
Local cDesc2 := ""
Local cDesc3 := ""
Local cTitulo:= "Compras"
Local nLin  := 132
Local aOrd := {}
Private lAbortPrint := .F.
Private titulo := "Relatorio de compras"
Private tamanho := "M"
Private nomeprog := "RDREG002 " + RetCodUsr()
Private cString := "SC7"
Private aReturn := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nTipo := 18
Private cPerg :=""
Private CONTFL:= 01
Private m_pag := 01
Private cNome := ""

nTipo := If(aReturn[4]==1,15,18)

cQuery := " SELECT DISTINCT SC7010.C7_NUM, SC7010.C7_FORNECE, SC7010.C7_CONTATO, SC7010.C7_EMISSAO, SC7010.C7_DATPRF, SC7010.C7_ENCER, SC7010.C7_LOJA "
cQuery += " FROM SC7010"
cQuery += " WHERE SC7010.D_E_L_E_T_ = ''"
cQuery += " AND SC7010.C7_FILIAL = '"+xFilial("SC7")+"'"
cQuery += " AND SC7010.C7_ENCER != 'E'"
cQuery += " AND SC7010.C7_DATPRF < GETDATE()"
cQuery += " ORDER BY SC7010.C7_FORNECE"
dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery),"RDCOM007", .F.,.T.)

IF RDCOM007->(EOF()).AND.RDCOM007->(BOF())
	return .T.
ELSE
	IF MSGYESNO("Existem pedido de compra pendente. Deseja visualizar?")
	else
		return .T.
	ENDIF
ENDIF


wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)// Monta a interface padrao com o usuario...

Pergunte(cPerg,.T.)//Chama a pergunta

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)//RPTSTATUS monta janela com a regua de processamento.
Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem

dbSelectArea(cString)
dbSetOrder(1)
dbSelectArea("RDCOM007")

SetRegua(RecCount())//SETREGUA -> Indica quantos registros serao processados para a regua

dbGoTop()


While !EOF()
	
	
	//Impressao do cabecalho do relatório.
	If nLin > 65 // Salto de Pagina. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif

    	@nLin,0 PSAY "________________________________________________________________________________________________________________________________________________________________"
		@nLin,00 PSAY cValToChar(RDCOM007->C7_NUM)
		@nLin,9 PSAY substr(cNome,1,50) := POSICIONE("SA2",1,XFILIAL("SA2")+RDCOM007->C7_FORNECE+RDCOM007->C7_LOJA,"A2_NREDUZ")
		@nLin,70 PSAY substr(RDCOM007->C7_CONTATO,1,15)
		@nLin,105 PSAY DtoC(StoD(RDCOM007->C7_EMISSAO))
		@nLin,120 PSAY DtoC(StoD(RDCOM007->C7_DATPRF))
		nLin++
		@nLin,0 PSAY "________________________________________________________________________________________________________________________________________________________________"

	dbselectArea("RDCOM007")
	dbSkip()
	
enddo

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return
