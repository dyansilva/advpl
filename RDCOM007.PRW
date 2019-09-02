

User function RDCOM007()

Local Cabec1 := "Código   Titulo da Tarefa                Informação                                         Responsável                            Data Inicial    Data Final"
Local Cabec2 := ""
Local titulo := "Compras a receber"
Local cDesc1 := "RELATORIO DE COMPRAS QUE JÁ FORAM REALIZADA"
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

nTipo := If(aReturn[4]==1,15,18)
cQuery := " SELECT SC7010.C7_NUM, SC7010.C7_FORNECE, SC7010.C7_CONTATO, SC7010.C7_EMISSAO, SC7010.C7_DATPRF, SC7010.C7_ENCER "
cQuery += " FROM SC7010"
cQuery += " WHERE SC7010.D_E_L_E_T_ = ''"
cQuery += " AND SC7010.C7_FILIAL = '"+xFilial("SC7")+"'"
cQuery += " AND SC7010.C7_ENCER != 'E'"
cQuery += " AND SC7010.C7_DATPRF < GETDATE()"

DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"RDCOM007",.F.,)

IF RDCOM007->(EOF()).AND.RDCOM007->(BOF())
    Return .T.
else 
    If MsgYesNo("Existe pedido de compra pendente. Deseja visualizar?")
    else
        Return .T.
    EndIf
EndIf

// Monta a interface padrao com o usuario...
wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

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

	If lAbortPrint
		Pergunte(cPerg,.F.)
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	//Impressao do cabecalho do relatorio.
	If nLin > 65 // Salto de Pagina. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
	alert("n|Psay")
		@nLin,0 PSAY "________________________________________________________________________________________________________________________________________________________________"
		@nLin,00 PSAY cValToChar(RDCOM007->C7_NUM)
		@nLin,9 PSAY cValToChar(RDCOM007->C7_FORNECE)
		@nLin,41 PSAY RDCOM007->C7_CONTATO
		@nLin,91 PSAY RDCOM007->C7_EMISSAO
		@nLin,132 PSAY  RDCOM007->C7_DATPRF
		nLin++
		@nLin,0 PSAY "________________________________________________________________________________________________________________________________________________________________"

	dbselectArea("RDCOM007")
	dbSkip()
enddo

SET DEVICE TO SCREEN

//Se impressao em disco, chama o gerenciador de impressao...

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return
