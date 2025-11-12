SELECT * FROM dataset.order_history_kaggle_data;

SELECT `Order Status`, COUNT(*) as total_orders FROM dataset.order_history_kaggle_data
GROUP BY `Order Status`;

SELECT 
  `Restaurant name`,
  ROUND(AVG(Rating), 2) AS media_avaliacao,
  ROUND(MAX(Rating), 2) AS max_avaliacao,
  ROUND(MIN(Rating), 2) AS min_avaliacao
FROM dataset.order_history_kaggle_data
WHERE Rating IS NOT NULL
GROUP BY `Restaurant name`
ORDER BY media_avaliacao DESC;

SELECT 
  `Restaurant name`,
  ROUND(AVG(CAST(`KPT duration (minutes)` AS DECIMAL(10,2))), 2) AS preparacao,
  ROUND(AVG(CAST(`Rider wait time (minutes)` AS DECIMAL(10,2))), 2) AS espera,
  ROUND(
    AVG(
      CAST(`KPT duration (minutes)` AS DECIMAL(10,2)) +
      CAST(`Rider wait time (minutes)` AS DECIMAL(10,2))
    ), 2
  ) AS total_tempo
FROM dataset.order_history_kaggle_data
GROUP BY `Restaurant name`
ORDER BY `Restaurant name` ASC;

SELECT
  `Restaurant name`,
  `Rating`,
  COUNT(*) AS quantidade_avaliacoes
FROM dataset.orders_full
WHERE `Rating` IS NOT NULL
GROUP BY `Restaurant name`, `Rating`
ORDER BY `Restaurant name`, `Rating`;



CREATE OR REPLACE VIEW dataset.orders_full AS
SELECT  
  *,
  CASE
    WHEN `Distance` LIKE '%<1%' THEN 0.5
    WHEN `Distance` LIKE '%>1%' THEN 1.5
    ELSE CAST(REPLACE(REPLACE(`Distance`, 'km', ''), ' ', '') AS DECIMAL(10,2))
  END AS distance_num,
  STR_TO_DATE(`Order Placed At`, '%h:%i %p, %M %e %Y') AS datetime_converted,
  DATE(STR_TO_DATE(`Order Placed At`, '%h:%i %p, %M %e %Y')) AS data_pedido,
  TIME(STR_TO_DATE(`Order Placed At`, '%h:%i %p, %M %e %Y')) AS hora_pedido,
  
  -- 🆕 Nova coluna exemplo
  CASE 
    WHEN HOUR(STR_TO_DATE(`Order Placed At`, '%h:%i %p, %M %e %Y')) BETWEEN 6 AND 11 THEN 'Manhã'
    WHEN HOUR(STR_TO_DATE(`Order Placed At`, '%h:%i %p, %M %e %Y')) BETWEEN 12 AND 17 THEN 'Tarde'
    WHEN HOUR(STR_TO_DATE(`Order Placed At`, '%h:%i %p, %M %e %Y')) BETWEEN 18 AND 23 THEN 'Noite'
    ELSE 'Madrugada'
  END AS periodo_dia
FROM dataset.order_history_kaggle_data;
SELECT * FROM dataset.orders_full;

SELECT 
  `Restaurant name`,
  MAX(CASE WHEN pedidos = max_pedidos THEN hora END) AS horario_pico,
  MAX(CASE WHEN pedidos = max_pedidos THEN pedidos END) AS qtd_pico,
  MAX(CASE WHEN pedidos = min_pedidos THEN hora END) AS horario_minimo,
  MAX(CASE WHEN pedidos = min_pedidos THEN pedidos END) AS qtd_minima
FROM (
  SELECT 
    `Restaurant name`,
    HOUR(hora_pedido) AS hora,
    COUNT(*) AS pedidos,
    MAX(COUNT(*)) OVER (PARTITION BY `Restaurant name`) AS max_pedidos,
    MIN(COUNT(*)) OVER (PARTITION BY `Restaurant name`) AS min_pedidos
  FROM dataset.orders_full
  GROUP BY `Restaurant name`, HOUR(hora_pedido)
) AS resumo
GROUP BY `Restaurant name`
ORDER BY `Restaurant name`;

SELECT 
  `Restaurant name`,
  data_pedido,
  hora_pedido,
  COUNT(*) AS qtd_pedidos
FROM dataset.orders_full
GROUP BY `Restaurant name`, data_pedido, hora_pedido
HAVING COUNT(*) = (
  SELECT MAX(contagem)
  FROM (
    SELECT 
      `Restaurant name` AS nome_restaurante,
      data_pedido,
      hora_pedido,
      COUNT(*) AS contagem
    FROM dataset.orders_full
    GROUP BY `Restaurant name`, data_pedido, hora_pedido
  ) AS temp
  WHERE temp.nome_restaurante = dataset.orders_full.`Restaurant name`
)
ORDER BY `Restaurant name`;

SELECT
  `Restaurant name`,
  GROUP_CONCAT(
    DISTINCT 
    TRIM(REGEXP_REPLACE(j.item, '[0-9]+\\s*x\\s*', '')) 
    ORDER BY TRIM(REGEXP_REPLACE(j.item, '[0-9]+\\s*x\\s*', ''))
  ) AS cardapio_resumido
  FROM dataset.orders_full,
JSON_TABLE(
  CONCAT('["', REPLACE(`Items in order`, ',', '","'), '"]'),
  "$[*]" COLUMNS (item VARCHAR(255) PATH "$")
) AS j
GROUP BY `Restaurant name`
ORDER BY `Restaurant name`;









