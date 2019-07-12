#INCLUDE 'Protheus.ch'
#INCLUDE 'Parmtype.ch'
USER FUNCTION RDREG001()
    
    
	PRIVATE cCadastro := "Cadastro de Processos"
	PRIVATE cDelFunc := ".T.", cString := "SZI"

	PRIVATE aRotina :=  { {"Pesquisar","AxPesqui",0,1},;
						  {"Visualizar","U_BrowSZI",0,2},;
						  {"Incluir","U_BrowSZI",0,3},;
						  {"Alterar","U_BrowSZI",0,4},;
						  {"Excluir","U_BrowSZI",0,5} }
						  
	PRIVATE aCores  := { { "SZI->ZI_COD <> ''" , 'BR_VERDE' } }

	DBSelectArea(cString) ; DBSetOrder(1) ; mBrowse(6,1,22,75,cString,,,,,,aCores) ; DBCloseArea()
RETURN NIL


USER FUNCTION BrowSZI(cAlias,nReg,nOpc)

	LOCAL aButtons := {}, aHeader := {} , aCols := {}, aCampos := {}, aSize := MsAdvSize(.F.)
	LOCAL oDlg := NIL, oGetD := NIL, oEnch := NIL
	LOCAL GridOper := NIL
	

	aHeader := GenHead("SZJ") ; aCols := GenGrid(@nOpc,@aHeader)

	IF ( nOpc == 3 .OR. nOpc == 4 )
		GridOper := GD_INSERT+GD_DELETE+GD_UPDATE
	ELSEIF ( nOpc == 2 )
		GridOper := 2
	ELSEIF ( nOpc == 5)
		GridOper := 5
	ENDIF



	DEFINE MSDIALOG oDlg TITLE "Inclusão de Ocorrencias" FROM aSize[7],0 TO aSize[6],aSize[5] COLORS 0, 16777215 PIXEL
		
		
		RegToMemory(cAlias, IF( nOpc == 3, .T., .F.)) ; //IF( nOpc == 3,M->ZI_COD := GenChav(xFilial("SX5"),"ZZ","01    ",1),'     ')

		//Verifica o ultimo codigo da tabela SZI e calcula o proximo codigo que será gerado.	
		
		IF INCLUI
			M->ZI_COD:= PROXIMOSZI()
		ENDIF
		
		oEnch := MsMGet():New(cAlias,nReg,nOpc,,,,,{aSize[7]+30,0,aSize[6]-450,aSize[5]-672},,3,,,,oDlg,.F.,.T.,.F.,,.F.,.T.)
		oGetD := MsNewGetDados():New(aSize[7]+150,0,aSize[6]-298,aSize[5]-672,GridOper,"AllwaysTrue","AllwaysTrue","+ZJ_ITEM",,000,999,"AllwaysTrue","", "AllwaysTrue", oDlg, @aHeader, @aCols,,) ; oGetD:oBrowse:lUseDefaultColors := .T. ; IF(nOpc == 2 .OR. nOpc == 5,oGetD:lActive := .F.,NIL)

		IF (nOpc == 3 .OR. nOpc == 4, aButtons := CriaBut(),NIL)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| TudoOk(@oEnch,@oGetD,@oDlg,@nOpc,@aCols,@aHeader)},{|| oDlg:End()},,aButtons) CENTERED
RETURN


STATIC FUNCTION CriaBut()

	LOCAL aButtons := { {"Notificar Logistica", {|| alert("Notificar Logistica")}, "Notificar Logistica...", "Notificar Logistica", {|| .T.} },;
				  	    {"Notificar Atendimento", {|| alert("Notificar Atendimento")}, "Notificar Atendimento...", "Notificar Atendimento", {|| .T.}},;
				  	    {"Notificar Dispençao", {|| alert("Notificar Dispensaçao")}, "Notificar dispensacao...", "Notificar dispensaçao", {|| .T.}},;
				  	    {"Notificar Administrativo", {|| alert("Notificar Administrativo")}, "Notificar Administrativo...", "Notificar Administrativo", {|| .T.}},;
				  	    {"Notificar Garantia Qualidade", {|| alert("Notificar Garantia Qualidade")}, "Notificar Garantia Qualidade...", "Notificar Garantia Qualidade", {|| .T.}} }
RETURN aButtons

STATIC FUNCTION TudoOk(oEnch,oGetD,oDlg,nOpc,aCols,aHeader)
	
	LOCAL lOk := .T.

	IF ( nOpc == 3 .OR. nOpc == 4 )
		IF( Obrigatorio(oEnch:aGets,oEnch:aTela,,.T.) )
			IF ( ! AcolsOk(@aHeader,@oGetD:aCols,@aCols,@nOpc) )
				lOk := .F.
			ENDIF
		ELSE
			lOk := .F.
		ENDIF
		
		IF ( lOk )
			BEGIN TRANSACTION
				GravaTudo(@aHeader,@oGetD:aCols,@aCols,@nOpc) ; oDlg:END()
			END TRANSACTION
		ENDIF
	ELSEIF ( nOpc == 5 )
		DelReg() ; oDlg:END()
	ELSE
		oDlg:END()
	ENDIF
RETURN lOk


STATIC FUNCTION DelReg(cFilHeader,cFilCols)

	LOCAL aArea := GetArea()

	BEGIN TRANSACTION	
		IF ( RecLock("SZI",.F.,,.T.) )
			DBDelete() ; MsUnlock() ; DBSelectArea(cFilCols)
			IF ( ! Empty(cFilCols) )
				SET FILTER TO ZJ_ZNUM == M->ZI_COD
				DBGoTop()

				WHILE ( ! EOF() )
					IF ( RecLock(cFilCols,.F.,,.T.) )
						DBDelete() ; MsUnlock()
					ELSE
						DisarmTransaction() ; EXIT
					ENDIF
					DBSkip()
				ENDDO
				DBCloseArea() ; RestArea(aArea)
			ENDIF
		ENDIF
	END TRANSACTION
RETURN NIL




STATIC FUNCTION GravaTudo(aHeader,aCols,aColsOld,nOpc)

	LOCAL lOk := .T.

	IF ( GrvSZI(@nOpc) )
		GrvSZJ(@aHeader,@aCols,@aColsOld,@nOpc)
	ELSE
		lOk := .F. ; MsgAlert("Falha na gravação, executando rollback...","Falha Critica.")
	ENDIF
RETURN lOk


STATIC FUNCTION AcolsOk(aHeader,aCols,aColsOld,nOpc)

	LOCAL nLine := LegGrid(@aHeader,@aCols), nLasLinV := GrFEnLi(@aHeader,@aCols)
	LOCAL lOk := .T.

	IF ( nOpc == 3 )
		IF ( nLine == 0 )
			lOk := .F. ; MsgAlert("Realizar a inclusão de pelo menos um item na ocorrência!","TOTVS||")
		ELSEIF ( nLine == 1 )
			IF ( GrLiDel(@aHeader,@aCols,nLasLinV) )
				lOk := .F. ; MsgAlert("Realizar a inclusão de pelo menos um item na ocorrência!","TOTVS||")
			ELSEIF ( GrLiEmp(@aHeader,@aCols,nLasLinV) )
				lOk := .F. ; MsgAlert("Preencher os campos do item!","TOTVS||")
			ELSEIF ( ! VerCam(@aHeader,@aCols,@nLasLinV) )
				lOk := .F.
			ENDIF
		ENDIF
	ELSEIF ( nOpc == 4 )
		IF ( nLine == 0 )
			lOk := .F. ; MsgAlert("Realizar a inclusão de pelo menos um item na ocorrência!","TOTVS||")
		ELSEIF ( nLine == 1 )
			IF ( GrLiDel(@aHeader,@aCols,nLasLinV) )
				lOk := .F. ; MsgAlert("Realizar a inclusão de pelo menos um item na ocorrência!","TOTVS||")
			ELSEIF ( GrLiEmp(@aHeader,@aCols,nLasLinV) )
				lOk := .F. ; MsgAlert("Preencher os campos do item!","TOTVS||")
			ELSEIF ( ! VerCam(@aHeader,@aCols,@nLasLinV) )
				lOk := .F.
			ENDIF
		ELSE
			IF ( VerCam(aHeader,aCols,nLasLinV) )
				IF ( ! CheckAlt(@aHeader,@aCols,@aColsOld) )
					lOk := .F.
				ENDIF
			ELSE
				lOk := .F.
			ENDIF
		ENDIF
	ENDIF
RETURN lOk


STATIC FUNCTION GenHead(cAlias)

	LOCAL aArea := GetArea()
	LOCAL aHeader := {}

	DBSelectArea("SX3") ; DBSetOrder(1) ; DBSeek(cAlias)

	WHILE ( !EOF() .AND. X3_ARQUIVO == cAlias)
		IF ( (! "_FILIAL" $ X3_CAMPO ) .AND. X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL )
			AAdd(aHeader,{ALLTRIM(X3_TITULO), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_F3, X3_CONTEXT, X3_CBOX} )
		ENDIF
		DBSkip()
	ENDDO
	RestArea(aArea)
RETURN aHeader


STATIC FUNCTION GenGrid(nOpc,aHeader)

	LOCAL aArea := GetArea(), aCols := {}

	IF ( nOpc == 3 )
		aCols := {Array(LEN(aHeader)+1)} ; aCols[1,LEN(aHeader)+1] := .F.

		FOR i := 1 TO LEN(aHeader) STEP 1
			IF (ALLTRIM(aHeader[i,2]) == "ZJ_ITEM" ) 
				aCols[1,i] := "01"
			ELSE
				aCols[1,i] := CriaVar(aHeader[i,2])
			ENDIF
		NEXT
	ELSE
		DBSelectArea("SZJ") ; DBSetOrder(2) ; DBSeek(xFilial("SZJ")+SZI->ZI_COD)

		WHILE ( !EOF() .AND. ZJ_ZNUM == SZI->ZI_COD )

			AAdd(aCols,Array(LEN(aHeader)+1))

			FOR i := 1 TO LEN(aHeader) STEP 1
				aCols[LEN(aCols),i] := FieldGet(FieldPos(aHeader[i,2])) 
			NEXT
			aCols[LEN(aCols),LEN(aHeader)+1] := .F. ; DBSkip()
		ENDDO
		RestArea(aArea)
	ENDIF
RETURN aCols


STATIC FUNCTION GrvSZI(nOpc)

	LOCAL aCampo := {}
	LOCAL lOk := .T.

	IF(nOpc == 3,GenChav(xFilial("SX5"),"ZZ","01    ",2),NIL)
	DBSelectArea("SX3") ; DBSetOrder(1) ; DBSeek("SZI")

	WHILE ( !EOF() .AND. X3_ARQUIVO == "SZI" )
		AAdd(aCampo,ALLTRIM(X3_CAMPO)) ; DBSkip()
	ENDDO

	DBSelectArea("SZI") ; DBSetOrder(1)

	IF ( DBSeek(xFilial("SZI")+M->ZI_COD ) )
		IF ( RecLock("SZI",.F.,,.T.) )
			FOR i := 1 TO LEN(aCampo) STEP 1
				IF ( &("SZI->"+aCampo[i]) <>  &("M->"+aCampo[i]) )
					IF ( ( ! "_FILIAL"  $ aCampo[i] ) .AND. (! aCampo[i] == "ZI_COD") )			
						&("SZI->"+aCampo[i]) := &("M->"+aCampo[i])
					ENDIF
				ENDIF
			NEXT
			MsUnlock()
		ELSE
			lOk := .F.
		ENDIF
	ELSE
		IF ( RecLock("SZI",.T.,,.T.) )
			FOR i := 1 TO LEN(aCampo) STEP 1
				IF ( "_FILIAL"  $ aCampo[i] )
					&("SZI->"+aCampo[i]) := xFilial("SZI")
				ELSE						
					&("SZI->"+aCampo[i]) := &("M->"+aCampo[i])
				ENDIF
			NEXT
			MsUnlock()
		ELSE
			lOk := .F.
		ENDIF
	ENDIF
RETURN lOk


STATIC FUNCTION GrvSZJ(aHeader,aCols,AColsOld,nOpc)
	
	LOCAL cItem := "00"
	LOCAL z := 1
	LOCAL lOk := .T.
	LOCAL aCampo := {}

	DBSelectArea("SZJ") ; DBSetOrder(2)

	SET FILTER TO ZJ_ZNUM == M->ZI_COD 
	DBGoTop()

	WHILE ( ! EOF() )
		IF ( RecLock("SZJ",.F.,,.T.) )

			IF ( aColsOld[z,(LEN(aHeader) + 1)] )
				//ZH_USRALT :=  ALLTRIM(CUSERNAME) + " - " + DTOC(DATE()) + " " + TIME()
				
				
			ENDIF
			DBDelete() ;  MsUnlock()
		ENDIF
		DBSkip() ; z++
	ENDDO


				DBSelectArea("SX3") ; DBSetOrder(1) ; DBSeek("SZJ")
				
				WHILE ( !EOF() .AND. X3_ARQUIVO == "SZJ" )
					AAdd(aCampo,ALLTRIM(X3_CAMPO)) ; DBSkip()
				ENDDO

	SET FILTER TO

	FOR i := 1 TO LEN(aCols) STEP 1
		IF ( ! aCols[i,(LEN(aHeader) + 1)]) //.AND. !Empty(aCols[i,FindVal(@aHeader,"ZH_OBS")]) )
			IF ( RecLock("SZJ",.T.,,.T.) ) 
			/*
				ZJ_FILIAL := xFilial("SZJ")
				ZJ_ITEM   :=  aCols[i][FindVal(@aHeader,"ZJ_ITEM")]
				ZJ_ZNUM := M->ZI_COD
				ZJ_COD := aCols[i][FindVal(@aHeader,"ZJ_COD")]
				ZJ_DESC := aCols[i][FindVal(@aHeader,"ZJ_DESC")]
				ZJ_ZINFORM := aCols[i][FindVal(@aHeader,"ZJ_ZINFORM")]
				*/				
								
				FOR r := 1 TO LEN(aCampo) STEP 1					
										
					IF aCampo[r]=="ZJ_FILIAL"
						ZJ_FILIAL := xFilial("SZJ")
					
					ELSEIF aCampo[r]=="ZJ_ZNUM"
							ZJ_ZNUM := M->ZI_COD
							
					ELSE
				
						&("SZJ->"+aCampo[r]) := aCols[i][FindVal(@aHeader,aCampo[r])]
						
					ENDIF
				NEXT
							 	
				MsUnlock()
			ENDIF
		ENDIF
	NEXT
	DBCloseArea()
RETURN

STATIC FUNCTION FindVal(aHeader,cCampo)
LOCAL nVal

	nVal := aScan(aHeader, { |x|  ALLTRIM(x[2]) == cCampo})

RETURN nVal


STATIC FUNCTION GenChav(cFil,cTabela,cChave,cOp)

	LOCAL aArea := GetArea()
	LOCAL cResult AS CHARACTER

	DBSelectArea("SX5") ; DBSetOrder(1)

	IF ( DBSeek(cFil+cTabela+cChave) )
		IF ( cOp == 1 )
			cResult := X5_DESCRI
		ELSEIF ( cOp == 2)
			IF ( RecLock("SX5",.F.,,.T.) )
				X5_DESCRI := soma1(ALLTRIM(X5_DESCRI)) ; X5_DESCSPA := soma1(ALLTRIM(X5_DESCSPA)) ; X5_DESCENG := soma1(ALLTRIM(X5_DESCENG))
				MsUnlock()
			ENDIF
		ENDIF
	ENDIF
	DBCloseArea() ; RestArea(aArea)
RETURN cResult


STATIC FUNCTION LegGrid(aHeader,aCols)
	
	LOCAL nContador := 0

	FOR i := 1 TO LEN(aCols) STEP 1
		IF ( ! aCols[i,(LEN(aHeader) + 1)] )
			nContador++
		ENDIF
	NEXT
RETURN nContador


STATIC FUNCTION GrLiEmp(aHeader,aCols,nLinha)

	LOCAL lOk := .T.

	FOR x := 1 TO LEN(aHeader) STEP 1			
		IF ( ! Empty(aCols[nLinha,x]) .AND. (! "_ITEM" $ aHeader[x,2]) )
			lOk := .F. ; EXIT
		ENDIF
	NEXT
RETURN lOk


STATIC FUNCTION GrFEnLi(aHeader,aCols)
	
	FOR x := 1 TO LEN(aHeader) STEP 1
		IF ( ! aCols[x,(LEN(aHeader) + 1)] )
			EXIT
		ENDIF
	NEXT
RETURN x

STATIC FUNCTION GrLiDel(aHeader,aCols,nLinha)

	LOCAL lOk := .T.

	IF ( ! aCols[nLinha,(LEN(aHeader) + 1)] )
		lOk := .F.
	ENDIF
RETURN lOk


STATIC FUNCTION CheckAlt(aHeader,aCols,aColsOld)

	LOCAL lReturn := .F., lOk := .T.

	IF ( LegGrid(@aHeader,@aCols) <> LegGrid(@aHeader,@aColsOld) )
		lReturn := .T.
	ELSE
		FOR x := 1 TO LEN(aCols) STEP 1
			IF ( lOk )
				FOR	y := 1 TO LEN(aHeader) STEP 1
					lOk := .F. ; lReturn := .T. ; EXIT
				NEXT
			ELSE
				EXIT
			ENDIF
		NEXT
	ENDIF
RETURN lReturn



STATIC FUNCTION VerCam(aHeader,aCols,nLasLinV)

	LOCAL lOk := .T.

	FOR w := nLasLinV TO LEN(aCols) STEP 1
		IF ( ! GrLiDel(@aHeader,@aCols,w) )
			IF ( GrLiEmp(@aHeader,@aCols,w) )
				lOk := .F. ; MsgAlert("Preencher os campos da linha " + cValToChar(w) + ".") ; EXIT
						
			ENDIF
				
			
		ENDIF
	NEXT
RETURN lOk


STATIC FUNCTION PROXIMOSZI

Local cProximo

DBSELECTAREA("SZI")
DBSETORDER(1)

dbGoBottom()

cProximo:= Soma1(SZI->ZI_COD)
RETURN cProximo
