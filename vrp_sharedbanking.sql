CREATE TABLE IF NOT EXISTS `vrp_sharedbanking` (
  `user_id` int(11) NOT NULL,
  `user_money` int(200) NOT NULL,
  `bank_account` varchar(200) DEFAULT NULL,
  `bank_id` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
