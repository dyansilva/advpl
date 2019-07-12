#INCLUDE "rwmake.ch"

User Function RDREG002()
//Declaracao de Variaveis
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "RELATORIO DE TAREFA A SER REALIZADA"
Local cPict          := ""
Local titulo       := "AGENDAMENTO DE TAREFA"
Local nLin         := 132
Local cQuery		:= ""
Local cQuery1 := ""
Local cAnvisa		:=""
STATIC cVend		:=""
Local Cabec1       := "Código   Titulo da Tarefa                Informação                                         Responsável                            Data Inicial    Data Final"
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}

Private oExcel := FWMSEXCEL():New()
Private cAba1:= "Vendas"
Private cAba2:= "Devolucoes"
Private cAba3 := "Resumo"
Private cTitulo:= "Tarefas"
Private cGet4 := ""

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "RDREG002 " + RetCodUsr() // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "RDREG002" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cPerg      :=""
Private cString := "SZI"

dbSelectArea("SZI")
dbSetOrder(1)


cGet4 := "C:\RelatórioDeTarefa" + ".xls" //Campo do exel Caminho onde o arquivo vai ser salvo.
nTipo := If(aReturn[4]==1,15,18)

cQuery+=" SELECT DISTINCT SZI010.ZI_COD, SZI010.ZI_ZUSUARI, SZI010.ZI_ZTITULO ,SZI010.ZI_ZINFORM,SZI010.ZI_ZALETU, SZI010.ZI_ZDATAIN, SZI010.ZI_ZDATAFI, SZI010.ZI_ZDPARTM,SZI010.ZI_CODUSER, SZI010.ZI_NOMEUSR"
cQuery+=" FROM SZI010"
cQuery+=" WHERE SZI010.D_E_L_E_T_ <> '*'"
cQuery+=" AND SZI010.ZI_FILIAL = '"+xFilial("SZI")+"'"
cQuery+=" AND SZI010.ZI_ZDATAIN <= GETDATE() + SZI010.ZI_ZALETU"
cQuery+=" AND SZI010.ZI_ZSTATUS <> '2'"
cQuery+=" ORDER BY ZI_COD "
dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery),"TMPT", .F.,.T.)

IF TMPT->(EOF()).AND.TMPT->(BOF())
	return .T.
ELSE
	IF MSGYESNO("Existem tarefa pendente. Deseja visualizar?")
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

/*
Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS
monta a janela com a regua de processamento.
*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem

dbSelectArea(cString)
dbSetOrder(1)
dbSelectArea("TMPT")

SetRegua(RecCount())//SETREGUA -> Indica quantos registros serao processados para a regua


/*
Posicionamento do primeiro registro e loop principal. Pode-se criar ï¿½
a logica da seguinte maneira: Posiciona-se na filial corrente e pro ï¿½
cessa enquanto a filial do registro for a filial corrente. Por exem ï¿½
plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    ï¿½
ï¿½
dbSeek(xFilial())                                                   ï¿½
While !EOF() .And. xFilial() == A1_FILIAL                           ï¿½
*/
dbGoTop()
//Titulo da Tarefa que vais ser salvo no exel.
/*oExcel:AddworkSheet(cAba1)
oExcel:AddTable (cAba1, cTitulo)
oExcel:AddColumn(cAba1, cTitulo,"Cod Tarefa",1,1)
oExcel:AddColumn(cAba1, cTitulo,"Titulo",1,1)
oExcel:AddColumn(cAba1, cTitulo,"Informação da Tarefa",1,1)
oExcel:AddColumn(cAba1, cTitulo,"Responsável",1,1)
oExcel:AddColumn(cAba1, cTitulo,"Data De Inicio",1,1)
oExcel:AddColumn(cAba1, cTitulo,"Data Final",1,1)
oExcel:AddColumn(cAba1, cTitulo,"Aviso Antecipado",1,1)*/

While !EOF()
	
	//Verifica o cancelamento pelo usuario.
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
	
	// Coloque aqui a logica da impressao do seu programa...
	// Utilize PSAY para saida na impressora. Por exemplo:
	// @nLin,00 PSAY SA1->A1_COD
	
	TabelaSZJ()
	dbSelectArea("TSZJ")
	dbGoTop()
	
	IF(TMPT->ZI_CODUSER == RetCodUsr() .OR. TSZJ->ZJ_ZCODUSU == RetCodUsr())
		
//		oExcel:AddRow(cAba1,cTitulo,{"Projeto: " + TMPT->ZI_COD ,TMPT->ZI_ZTITULO, TMPT->ZI_ZINFORM, TMPT->ZI_ZUSUARI, DtoC(StoD(TMPT->ZI_ZDATAIN)), DtoC(StoD(TMPT->ZI_ZDATAFI)), TMPT->ZI_ZALETU})
		
		@nLin,0 PSAY "________________________________________________________________________________________________________________________________________________________________"
		@nLin,00 PSAY cValToChar(TMPT->ZI_COD)
		@nLin,9 PSAY cValToChar(TMPT->ZI_ZTITULO)
		@nLin,41 PSAY TMPT->ZI_ZINFORM
		@nLin,91 PSAY TMPT->ZI_NOMEUSR
		@nLin,132 PSAY DtoC(StoD(TMPT->ZI_ZDATAIN))
		@nLin,148 PSAY DtoC(StoD(TMPT->ZI_ZDATAFI))
		nLin++
		
		While !EOF()
			
//			oExcel:AddRow(cAba1,cTitulo,{"Item: " + TSZJ->ZJ_ITEM ,Substr(TSZJ->ZJ_DESC,1,30), Substr(TSZJ->ZJ_DESC,1,30), Substr(TSZJ->ZJ_ZNOMEUS,1,10), Substr(TSZJ->ZJ_ZINFORM,1,20), DtoC(StoD(TSZJ->ZJ_ZDATA)),IIF(TSZJ->ZJ_ZSTATUS == "1","Aberto","Fechado")})
			
			@nLin,12 PSAY "Tarefa: "  + TSZJ->ZJ_ITEM
			@nLin,31 PSAY Substr(TSZJ->ZJ_DESC,1,30)
			@nLin,67 PSAY Substr(TSZJ->ZJ_ZNOMEUS,1,10)
			if (TSZJ->ZJ_ZSTATUS=="1")
				@nLin,79 PSAY "Aberto"
			elseif(TSZJ->ZJ_ZSTATUS=="2")
				@nLin,79 PSAY "Fechado"
			else
				@nLin,79 PSAY "Campo em branco"
			endif
			@nLin,88 PSAY Substr(TSZJ->ZJ_ZINFORM,1,20)
			@nLin,109 PSAY DtoC(StoD(TSZJ->ZJ_ZDATA))
			nLin++
			DBSKIP()
		enddo
		nLin++
		@nLin,0 PSAY "________________________________________________________________________________________________________________________________________________________________"
	ENDIF
	
	
	dbSelectArea("TSZJ")
	dbCloseArea()
	
	dbselectArea("TMPT")
	dbSkip()
enddo
//Exel: Caminho a ser salvo.
/*oExcel:Activate()
oExcel:GetXMLFile(cGet4)*/

//MSGINFO('Arquivo salvo no seguinte diretorio: ' + chr(10) + cGet4)
/*AbrirArquivo(cGet4)*/
//Finaliza a execucao do relatorio...

SET DEVICE TO SCREEN

//Se impressao em disco, chama o gerenciador de impressao...

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*Static Function AbrirArquivo(cGet4)

oExcelApp := MsExcel():New()
//alguns caso descomentar o codigo abaixo.
//oExcelApp:WorkBooks:Open()

IF MSGYESNO(cGet4 + chr(10)+ chr(10) + "Deseja Abrir a Planilha Agora? ")
	oExcelApp:WorkBooks:Open(cGet4) //Abre uma planilha
	oExcelApp:WorkBooks:Open(cGet4) //Abre uma planilha
	oExcelApp:SetVisible(.T.)
else
	return
endif

Return */

Static Function TabelaSZJ()
Local cQuery1 := ""


cQuery1 += " SELECT SZJ010.ZJ_ZNUM,SZJ010.ZJ_ITEM,SZJ010.ZJ_DESC,SZJ010.ZJ_ZSTATUS,SZJ010.ZJ_ZNOMEUS, SZJ010.ZJ_ZINFORM, SZJ010.ZJ_ZDATA,SZJ010.ZJ_ZCODUSU"
cQuery1 += " FROM SZJ010"
cQuery1 += " WHERE SZJ010.D_E_L_E_T_ <> '*'"
cQuery1 += " AND SZJ010.ZJ_ZDATA <= GETDATE() + SZJ010.ZJ_ZALERTA"
cQuery1 += " AND SZJ010.ZJ_ZNUM = "+TMPT->ZI_COD
IF(TMPT->ZI_CODUSER <> RetCodUsr())
	cQuery1 += " AND SZJ010.ZJ_ZCODUSU =" + RetCodUsr()
ENDIF
dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery1),"TSZJ", .F.,.T.)

return
