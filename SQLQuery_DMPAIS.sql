
BEGIN TRANSACTION;  
	DECLARE @VDATA_INI DATETIME;
	SET @VDATA_INI= GETDATE();
BEGIN TRY  

MERGE D_Pais AS Destino

USING (SELECT DISTINCT PAIS FROM STG_VENDAS) AS Origem

ON Destino.NOME_PAIS = Origem.PAIS

-- Há registro no destino e na origem
WHEN MATCHED 

THEN 
    UPDATE SET NOME_PAIS = Origem.PAIS

--Quando não há registro no destino e há na origem
WHEN NOT MATCHED 

THEN 
    INSERT (NOME_PAIS) VALUES (Origem.PAIS);

   END TRY  
BEGIN CATCH
 	IF @@TRANCOUNT > 0  
        ROLLBACK TRANSACTION; 

INSERT INTO [dbo].[LOG_CARGAS]
           ([NUMERO_ERRO],
           [SERVERIDADE_ERRO],
           [ESTADO_ERRO],
           [PROC_ERRO],
           [LINHA_ERRO],
           [MSG_ERRO],
           [SITUACAO],
           [PROCESSO],
           [DATA_INI],
		   [DATA_FIM])
     VALUES
        (ERROR_NUMBER(),
        ERROR_SEVERITY(),
        ERROR_STATE(),
        ERROR_PROCEDURE(),
        ERROR_LINE() ,
        ERROR_MESSAGE() ,
        'ERRO',
        'CARGA PAIS',
		@VDATA_INI,
		GETDATE()
		)

        
END CATCH;  

INSERT INTO LOG_CARGAS
           ([NUMERO_ERRO],
           [SERVERIDADE_ERRO],
           [ESTADO_ERRO],
           [PROC_ERRO],
           [LINHA_ERRO],
           [MSG_ERRO],
           [SITUACAO],
           [PROCESSO],
           [DATA_INI],
		   [DATA_FIM])
     VALUES
        (ERROR_NUMBER(),
        ERROR_SEVERITY(),
        ERROR_STATE(),
        ERROR_PROCEDURE(),
        ERROR_LINE() ,
        ERROR_MESSAGE() ,
        'SUCESSO',
       'CARGA PAIS',
		@VDATA_INI,
		GETDATE()
		)

IF @@TRANCOUNT > 0  
    COMMIT TRANSACTION;  
GO  

