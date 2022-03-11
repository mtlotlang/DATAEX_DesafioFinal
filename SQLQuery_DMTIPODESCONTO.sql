
BEGIN TRANSACTION;  
	DECLARE @VDATA_INI DATETIME;
	SET @VDATA_INI= GETDATE();
BEGIN TRY  

MERGE D_Desconto AS Destino

USING (SELECT DISTINCT TIPO_DESCONTO FROM STG_VENDAS) AS Origem

ON Destino.TIPO_DESCONTO = Origem.TIPO_DESCONTO

-- Há registro no destino e na origem
WHEN MATCHED 

THEN 
    UPDATE SET TIPO_DESCONTO = Origem.TIPO_DESCONTO

--Quando não há registro no destino e há na origem
WHEN NOT MATCHED 

THEN 
    INSERT (TIPO_DESCONTO) VALUES (Origem.TIPO_DESCONTO);

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
        'CARGA TIPO_DESCONTO',
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
       'CARGA TIPO_DESCONTO',
		@VDATA_INI,
		GETDATE()
		)

IF @@TRANCOUNT > 0  
    COMMIT TRANSACTION;  
GO  

