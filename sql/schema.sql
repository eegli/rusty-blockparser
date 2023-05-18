## Needed if you want to enable compression
#SET GLOBAL innodb_file_per_table=1;
#SET GLOBAL innodb_file_format=Barracuda;


CREATE SCHEMA IF NOT EXISTS `btc_blockchain` CHARACTER SET ascii COLLATE ascii_bin;
USE `btc_blockchain`;


DROP TABLE IF EXISTS `blocks`;
CREATE TABLE `blocks` (
  `id`              int(4) unsigned AUTO_INCREMENT      NOT NULL,
  `hash` 			binary(32)                          NOT NULL,
  `height`			int(10) unsigned					NOT NULL,
  `version` 		int(11)                     		NOT NULL,
  `blocksize`		int(10) unsigned					NOT NULL,
  `hashPrev` 		binary(32)                          NOT NULL,
  `hashMerkleRoot` 	binary(32)                          NOT NULL,
  `nTime` 			int(10) unsigned                    NOT NULL,
  `nBits` 			int(10) unsigned                    NOT NULL,
  `nNonce` 			int(10) unsigned                    NOT NULL,

  PRIMARY KEY (`id`)
);
#  ROW_FORMAT=DYNAMIC;


DROP TABLE IF EXISTS `transactions`;
CREATE TABLE `transactions` (
  `id`              int(4) unsigned AUTO_INCREMENT      NOT NULL,
  `txid`            binary(32)                          NOT NULL,
  `hashBlock`       binary(32)                          NOT NULL,
  `version`         int(11) unsigned               		NOT NULL,
  `lockTime`        int(10) unsigned     				NOT NULL,

  PRIMARY KEY (`id`)
);
#  ROW_FORMAT=DYNAMIC;


DROP TABLE IF EXISTS `tx_out`;
CREATE TABLE `tx_out` (
  `id`              int(4) unsigned AUTO_INCREMENT      NOT NULL,
  `txid`            binary(32)                  		NOT NULL,
  `indexOut`        int(10) unsigned            		NOT NULL,
  `value`           bigint(8) unsigned            		NOT NULL,
  `scriptPubKey`    blob                                NOT NULL,
  `address`     	varchar(36) 					DEFAULT NULL,
  `unspent`        	bit DEFAULT TRUE                    NOT NULL,

  PRIMARY KEY (`id`)
);
#  ROW_FORMAT=DYNAMIC;


DROP TABLE IF EXISTS `tx_in`;
CREATE TABLE `tx_in` (
  `id`              int(10) unsigned AUTO_INCREMENT     NOT NULL,
  `txid`            binary(32)                          NOT NULL,
  `hashPrevOut`     binary(32)                          NOT NULL,
  `indexPrevOut`    int(10) unsigned                    NOT NULL,
  `scriptSig`       blob                                NOT NULL,
  `sequence`        int(10) unsigned                    NOT NULL,

  PRIMARY KEY (`id`)
);
#  ROW_FORMAT=DYNAMIC;



## Also consider to set following mysql settings for maximum performance
# innodb_read_io_threads 	= 3
# innodb_write_io_threads 	= 3
# innodb_buffer_pool_size 	= 6G
# innodb_autoinc_lock_mode 	= 2
# innodb_log_file_size 		= 128M
# innodb_log_buffer_size 	= 8M
# innodb_flush_method 		= O_DIRECT
# innodb_flush_log_at_trx_commit = 0
# skip-innodb_doublewrite


TRUNCATE blocks;
## Load blocks into table
LOAD DATA LOCAL INFILE 'blocks-0-75604.csv'
INTO TABLE blocks
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
(@hash, height, version, blocksize, @hashPrev, @hashMerkleRoot, nTime, nBits, nNonce)
SET hash = unhex(@hash),
	hashPrev = unhex(@hashPrev),
    hashMerkleRoot = unhex(@hashMerkleRoot);
COMMIT;


TRUNCATE transactions;
## Load transactions into table
LOAD DATA LOCAL INFILE 'transactions-0-75604.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
(@txid, @hashBlock, version, lockTime)
SET txid = unhex(@txid),
	hashBlock = unhex(@hashBlock);
COMMIT;


TRUNCATE tx_out;
## Load tx_out into table
LOAD DATA LOCAL INFILE 'tx_out-0-75604.csv'
INTO TABLE tx_out
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
(@txid, indexOut, value, @scriptPubKey, address)
SET txid = unhex(@txid),
	scriptPubKey = unhex(@scriptPubKey);
COMMIT;


TRUNCATE tx_in;
## Load tx_in into table
LOAD DATA LOCAL INFILE 'tx_in-0-75604.csv'
INTO TABLE tx_in
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
(@txid, @hashPrevOut, indexPrevOut, scriptSig, sequence)
SET txid = unhex(@txid),
	hashPrevOut = unhex(@hashPrevOut);
COMMIT;


# Add keys
ALTER TABLE `blocks` ADD UNIQUE KEY (`hash`);
ALTER TABLE `transactions` ADD KEY (`txid`);
ALTER TABLE `tx_in` ADD KEY (`hashPrevOut`, `indexPrevOut`);
ALTER TABLE `tx_out` ADD KEY (`txid`, `indexOut`),
					 ADD KEY (`address`);
ALTER TABLE `transactions` ADD FOREIGN KEY (`hashBlock`) REFERENCES blocks(`hash`);
ALTER TABLE `tx_out` ADD FOREIGN KEY (`txid`) REFERENCES transactions(`txid`);
ALTER TABLE `tx_id` ADD FOREIGN KEY (`txid`) REFERENCES transactions(`txid`);
COMMIT;

