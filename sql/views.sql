CREATE OR replace VIEW view_balances
AS
  SELECT address,
         Cast(SUM(value) / 100000000 AS DECIMAL (16, 8)) AS balance
  FROM   tx_out
  WHERE  unspent = TRUE
  GROUP  BY address
  ORDER  BY balance DESC;  


CREATE OR REPLACE VIEW view_transactions 
AS 
  SELECT b.height,
        i.hashprevout,
        i.indexprevout,
        t.txid,
        o.indexout,
        o.address,
        o.value
  FROM transactions t
          JOIN blocks b
                ON b.hash = t.hashblock
          JOIN tx_in i
                ON t.txid = i.txid
          JOIN tx_out o
                ON i.txid = o.txid;


CREATE FUNCTION target (bits float)
	RETURNS REAL DETERMINISTIC
RETURN mod(bits, 0x1000000) * pow(256, bits div 0x1000000 - 3);