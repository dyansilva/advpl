#include "rwmake.ch" 

User Function RDFAT061()

Local cQuery:= ""
Static cAliTMP := GetNextAlias() 

cQuery:=" SELECT SZD010.ZD_CLIFOR, SZD010.ZD_LOJA, SZD010.ZD_NOM ,SZD010.ZD_CODDOC, SZD010.ZD_NOMDOC, SZD010.ZD_EMISSAO, SZD010.ZD_VENCTO, SZD010.ZD_CONTATO, SZD010.ZD_TEL, SZD010.ZD_EMAIL, SZD010.ZD_BLQPD"
cQuery+=" FROM SZD010"
cQuery+=" WHERE SZD010.D_E_L_E_T_ <> '*'"
cQuery+=" AND SZD010.ZD_FILIAL = '"+xFilial("SZD")+"'"
cQuery+=" AND SZD010.ZD_VENCTO <= GETDATE() + SZD010.ZD_ALERT"
cQuery+=" AND SZD010.ZD_ZCLIFOR = 'F'"
cQuery+=" ORDER BY ZD_NOM"


dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery),cAliTMP, .f., .t.) 

	IF (cAliTMP)->(EOF()).AND.(cAliTMP)->(BOF())  	
	
	ELSE		
		IF MSGYESNO("Existem Documentos De Fornecedor Pendentes, deseja vizualizalos agora?")		
			PrintTest()
		ENDIF
	ENDIF
   
return .T.



#include "TOTVS.CH"
//---------------------------------------------------------
// Exemplo de Impressão e Visualização
//---------------------------------------------------------
Static Function PrintTest() 

Local cQuery:= ""
Local cAliTMP2 := GetNextAlias() 
local nLinha:= 0
Local cTitulo:=" Cliente                         Documento                          Dt. Emissão   Dt. Vencto   Tel.     E-mail  "
Local nItens:=1
Private cAcesso := Repl(" ",10)

  DEFINE DIALOG OMAINWND TITLE "Documentos Fornecedor" FROM 180,180 TO 900,1200 PIXEL

    // Monta objeto para impressão
    oPrint := TMSPrinter():New("Documentacao")

    // Define orientação da página para Retrato
    // pode ser usado oPrint:SetLandscape para Paisagem
    //oPrint:SetPortrait()
    oPrint:SetLandscape()
    
    // Mostra janela de configuração de impressão
    oPrint:Setup()

    // Inicia página
    oPrint:StartPage()            
    
    // Insere imagem
    oPrint:SayBitmap(10,10,"C:\Dir\Totvs.png",200,200)

    // Insere texto formatado
    oFont1 := TFont():New('Courier new',,-18,.T.)
  //  oPrint:Say(214,10,"Lista de Documentação",oFont1)
    
    // Insere texto formatado e com mudança de Cor
    oFont2 := TFont():New('Tahoma',,-25,.T.)
   // oPrint:Say(268,10,"Linha para teste de impressão[Tahoma 25]",oFont2,,CLR_HRED)
  
    oFont3 := TFont():New('Courier new',,-12,.T.)
  //  oPrint:Say(214,10,"Lista de Documentação",oFont1)

cQuery:="SELECT SZD010.ZD_CLIFOR, SZD010.ZD_LOJA, SZD010.ZD_NOM ,SZD010.ZD_CODDOC, SZD010.ZD_NOMDOC, SZD010.ZD_EMISSAO, SZD010.ZD_VENCTO, SZD010.ZD_CONTATO, SZD010.ZD_TEL, SZD010.ZD_EMAIL, SZD010.ZD_BLQPD"
cQuery+=" FROM SZD010"
cQuery+=" WHERE SZD010.D_E_L_E_T_ <> '*'"
cQuery+=" AND SZD010.ZD_FILIAL = '"+xFilial("SZD")+"'"
cQuery+=" AND SZD010.ZD_VENCTO <= GETDATE() + SZD010.ZD_ALERT"
cQuery+=" AND SZD010.ZD_ZCLIFOR = 'F'"
cQuery+=" ORDER BY ZD_NOM"


dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery),cAliTMP2, .f., .t.) 

oFont1 := TFont():New('Courier new',,-18,.T.)
oPrint:Say(20,20,"Relatorio de Documentação Fornecedor",oFont1)

oFont1 := TFont():New('Courier new',,-12,.T.)
//Imprime Titulo
oPrint:Say(100,10,cTitulo,oFont3)


oFont1 := TFont():New('Courier new',,-09,.T.)
nLinha:= 200

	dbGoTop()
	While !EOF()
	
	 	//oFont3 := TFont():New('Courier new',,-10,.T.)  
	 	
		oPrint:Say(nLinha,10,"-"+SUBSTR((cAliTMP2)->ZD_NOM,0,35),oFont1)
	       
	    oPrint:Say(nLinha,900,(cAliTMP2)->ZD_CODDOC+"-"+SUBSTR((cAliTMP2)->ZD_NOMDOC,0,30))
	    	
	    oPrint:Say(nLinha,1800,DtoC(StoD((cAliTMP2)->ZD_EMISSAO,oFont1)))
	    	
	    oPrint:Say(nLinha,2115,DtoC(StoD((cAliTMP2)->ZD_VENCTO,oFont1)))
	    	
	    oPrint:Say(nLinha,2395,SUBSTR((cAliTMP2)->ZD_TEL,0,13))
	    	
	    oPrint:Say(nLinha,2700,(cAliTMP2)->ZD_EMAIL,oFont1)
	    nLinha+=50	
	    nItens+=1
	    //Nova Página
		  	if nItens>=30
		  	  // Inicia página
		  	  oPrint:EndPage()
		  	  oPrint:StartPage()
		  	  //Imprime Titulo
		  	  oPrint:Say(100,10,cTitulo,oFont3)
		  	  nLinha:=200  
		  	 nItens:=1
		    endif      	    	    	    	    
	    
	 (cAliTMP2)->(dbSkip())  
	endDo  

dbCloseArea()
    // Visualiza a impressão
  //  oPrint:EndPage()

    // Termina a página
    oPrint:EndPage()
                       
    // Mostra tela de visualização de impressão
    oPrint:Preview() 
	
//  ACTIVATE DIALOG OMAINWND CENTERED 
Return
