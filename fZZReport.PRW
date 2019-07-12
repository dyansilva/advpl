
/*
TESTANDO NOVA TELA
*/

#include "protheus.ch"
User function fZZReport() // u_fZZReport()
	Local oReport	
	oReport := ReportDef()
	oReport:PrintDialog()
Return
	
Static Function ReportDef()	
	Local oReport
	Local oSection
	Local oSection1
	Local oSection2
	
	oReport:= TReport():New("fZZReport","Log de divergencia Pedidos de Cliente",,{|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de erros encontrados durante o processo de importação dos dados.")
	oReport:SetLandscape()    
	oReport:HideParamPage()	
	

	oSection:= TRSection():New(oReport,"Cliente",{},{})
	TRCell():New(oSection,"CNPJ" 	,,"CNPJ"	,"@!",30,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"CODIGO" 	,,"Codigo"	,"@!",25,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"LOJA" 	,,"Loja"	,"@!",15,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"NOME" 	,,"Nome"	,"@!",50,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"CIDADE" 	,,"Cidade"  ,"@!",50,/*lPixel*/,/*{|| code-block de impressao }*/)

	oSection:SetLineStyle()		
Return oReport
	
Static Function PrintReport(oReport)
	Local oSection := oReport:Section(1)
	Local aCliente := {}
	
	oSection:SetTotalInLine(.F.)
	
	aadd(aCliente,{"28154847000101","000001","01","NOME EMPRESA 1","SAO PAULO"})
	aadd(aCliente,{"28154847000102","000002","01","NOME EMPRESA 2","SAO PAULO"})
	aadd(aCliente,{"28154847000103","000003","01","NOME EMPRESA 3","SAO PAULO"})
	aadd(aCliente,{"28154847000104","000004","01","NOME EMPRESA 4","RIO DE JANEIRO"})
	
	oReport:SetMeter(Len(aCliente))
	
	oReport:IncMeter()		
	oSection:Init()
	For i:= 1 to len(aCliente)
		If oReport:Cancel()
			Exit
		EndIf
		
		oReport:IncMeter()		
		oSection:Cell("CNPJ"):SetValue(transform(aCliente[1,1], "@R 99.999.999/9999-99"))
		oSection:Cell("CODIGO"):SetValue(aCliente[1,2])
		oSection:Cell("LOJA"):SetValue(aCliente[1,3])
		oSection:Cell("NOME"):SetValue(aCliente[1,4])
		oSection:Cell("CIDADE"):SetValue(aCliente[1,5])
		oSection:PrintLine()		
		oReport:ThinLine()
	Next  
	oReport:ThinLine()
	oSection:Finish()

Return