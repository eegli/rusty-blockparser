CREATE OR replace VIEW view_blocks
AS
  SELECT height,
         Lower(Hex(hash))           AS hash,
         version,
         Lower(Hex(hashprev))       AS hashPrev,
         Lower(Hex(hashmerkleroot)) AS hashMerkleRoot,
         ntime,
         nbits,
         nnonce
  FROM   blocks
  ORDER  BY height ASC;


CREATE OR replace VIEW view_balances
AS
  SELECT address,
         Cast(SUM(value) / 100000000 AS DECIMAL (16, 8)) AS balance
  FROM   tx_out
  WHERE  unspent = TRUE
  GROUP  BY address
  ORDER  BY balance DESC;  


CREATE OR replace VIEW view_transactions
AS
  SELECT Lower(Hex(t.hashblock)) hashblock,
          Lower(Hex(t.txid)) txid,
          Lower(Hex(i.hashprevout)) hashprevout,
          i.indexprevout,
          o.indexout,
          Cast(o.value / 100000000 AS DECIMAL (16, 8)) value,
          o.address
   FROM   transactions t
          join tx_in i
            ON t.txid = i.txid
          join tx_out o
            ON t.txid = o.txid;


CREATE FUNCTION target (bits float)
	RETURNS REAL DETERMINISTIC
RETURN mod(bits, 0x1000000) * pow(256, bits div 0x1000000 - 3);