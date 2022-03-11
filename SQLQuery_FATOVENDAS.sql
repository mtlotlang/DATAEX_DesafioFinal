BEGIN TRANSACTION;  
   DECLARE @VDATA_INI DATETIME;
    DECLARE @VPROCESSO VARCHAR(30);
    SET @VDATA_INI= GETDATE();
    SET @VPROCESSO= 'CARGA FATO VENDAS'
BEGIN TRY  

MERGE FATO_VENDAS AS Destino

USING (
SELECT SEG.ID_SEGMENTO AS SEGMENTO,
       PS.ID_PAIS AS PAIS,
       PRD.ID_PRODUTO AS PRODUTO,
       DSC.ID_DESCONTO AS TIPO_DESCONTO,
       CAST(REPLACE(VEND.QTDE_VENDAS,',','.') AS decimal(10,2)) AS QTDE_VENDAS,
       CAST(REPLACE(VEND.PRECO_CUSTO,',','.') AS decimal(10,2)) AS PRECO_CUSTO,
       CAST(REPLACE(VEND.PRECO_VENDA,',','.') AS decimal(10,2)) AS PRECO_VENDA,
       CAST(REPLACE(VEND.VENDAS_BRUTA,',','.') AS decimal(10,2)) AS VENDAS_BRUTA,
       CAST(REPLACE(VEND.DESCONTO,',','.') AS decimal(10,2)) AS DESCONTO,
       CAST(REPLACE(VEND.VENDAS,',','.') AS decimal(10,2)) AS VENDAS,
       CAST(REPLACE(VEND.CUSTO_VENDA,',','.') AS decimal(10,2)) AS CUSTO_VENDA,
       CAST(REPLACE(VEND.LUCRO,',','.') AS decimal(10,2)) AS LUCRO,
       CAST(VEND.DATA_VENDA AS date) AS DATA_VENDA

  FROM STG_VENDAS VEND
   LEFT JOIN D_SEGMENTO SEG
	ON SEG.NOME_SEGMENTO = VEND.SEGMENTO

   LEFT JOIN D_Pais PS
	ON PS.NOME_PAIS = VEND.PAIS

  LEFT JOIN D_Produto PRD
	ON PRD.NOME_PRODUTO = VEND.PRODUTO

  LEFT JOIN D_Desconto DSC
	ON DSC.TIPO_DESCONTO = VEND.TIPO_DESCONTO

) AS Origem

ON Destino.DATA_VENDA = Origem.DATA_VENDA

-- Há registro no destino e na origem
WHEN MATCHED 

THEN 
    UPDATE SET  ID_SEGMENTO= origem.SEGMENTO, 
                ID_PAIS= origem.PAIS,
                ID_PRODUTO= origem.PRODUTO,
                ID_DESCONTO= origem.TIPO_DESCONTO,
                QTDE_VENDAS= origem.QTDE_VENDAS,
                PRECO_CUSTO= origem.PRECO_CUSTO,
                PRECO_VENDA= origem.PRECO_VENDA,
                VENDA_BRUTA= origem.VENDAS_BRUTA,
                VLR_DESCONTO= origem.DESCONTO,
                VLR_VENDA= origem.VENDAS,
                CUSTO_VENDA= origem.CUSTO_VENDA,
                LUCRO= origem.LUCRO,
                DATA_VENDA= origem.DATA_VENDA

--Quando não há registro no destino e há na origem
WHEN NOT MATCHED 

THEN 
   INSERT  
           (ID_SEGMENTO,
           ID_PAIS,
           ID_PRODUTO,
           ID_DESCONTO,
           QTDE_VENDAS,
           PRECO_CUSTO,
           PRECO_VENDA,
           VENDA_BRUTA,
           VLR_DESCONTO,
           VLR_VENDA,
           CUSTO_VENDA,
           LUCRO,
           DATA_VENDA)
     VALUES
           (origem.SEGMENTO, 
           origem.PAIS,
           origem.PRODUTO,
           origem.TIPO_DESCONTO,
           origem.QTDE_VENDAS,
           origem.PRECO_CUSTO,
           origem.PRECO_VENDA,
           origem.VENDAS_BRUTA,
           origem.DESCONTO,
           origem.VENDAS,
           origem.CUSTO_VENDA,
           origem.LUCRO,
           origem.DATA_VENDA
           );

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
        @VPROCESSO,
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
        @VPROCESSO,
      @VDATA_INI,
      GETDATE()
      )

IF @@TRANCOUNT > 0  
    COMMIT TRANSACTION;  
GO  