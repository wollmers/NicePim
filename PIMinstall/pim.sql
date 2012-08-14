-- MySQL dump 10.13  Distrib 5.1.49, for debian-linux-gnu (i686)
--
-- Host: localhost    Database: pim_start
-- ------------------------------------------------------
-- Server version	5.1.49-1ubuntu8.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `actual_product`
--

DROP TABLE IF EXISTS `actual_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `actual_product` (
  `actual_product_id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `langid` int(13) NOT NULL DEFAULT '0',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `xml_updated` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`actual_product_id`),
  UNIQUE KEY `pair` (`product_id`,`langid`),
  KEY `xml_updated` (`xml_updated`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `actual_product`
--

LOCK TABLES `actual_product` WRITE;
/*!40000 ALTER TABLE `actual_product` DISABLE KEYS */;
/*!40000 ALTER TABLE `actual_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aggregate_log`
--

DROP TABLE IF EXISTS `aggregate_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aggregate_log` (
  `time_stamp` int(19) NOT NULL DEFAULT '0',
  `time_str` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`time_stamp`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aggregate_log`
--

LOCK TABLES `aggregate_log` WRITE;
/*!40000 ALTER TABLE `aggregate_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `aggregate_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aggregated_product_count`
--

DROP TABLE IF EXISTS `aggregated_product_count`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aggregated_product_count` (
  `product_id` int(13) NOT NULL DEFAULT '0',
  `count` int(10) NOT NULL DEFAULT '0',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aggregated_product_count`
--

LOCK TABLES `aggregated_product_count` WRITE;
/*!40000 ALTER TABLE `aggregated_product_count` DISABLE KEYS */;
/*!40000 ALTER TABLE `aggregated_product_count` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aggregated_request_stat`
--

DROP TABLE IF EXISTS `aggregated_request_stat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aggregated_request_stat` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `user_id` int(13) NOT NULL DEFAULT '0',
  `product_id` int(13) NOT NULL DEFAULT '0',
  `date` int(19) NOT NULL DEFAULT '0',
  `count` int(7) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `product_id` (`product_id`),
  KEY `date` (`date`),
  KEY `date_2` (`date`,`product_id`),
  KEY `product_id_2` (`product_id`,`date`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aggregated_request_stat`
--

LOCK TABLES `aggregated_request_stat` WRITE;
/*!40000 ALTER TABLE `aggregated_request_stat` DISABLE KEYS */;
/*!40000 ALTER TABLE `aggregated_request_stat` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ajax_usage`
--

DROP TABLE IF EXISTS `ajax_usage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ajax_usage` (
  `ajax_usage` int(11) NOT NULL AUTO_INCREMENT,
  `ip` varchar(64) DEFAULT NULL,
  `func` varchar(64) DEFAULT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ajax_usage`),
  KEY `ajax` (`ip`,`func`),
  KEY `updated` (`updated`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ajax_usage`
--

LOCK TABLES `ajax_usage` WRITE;
/*!40000 ALTER TABLE `ajax_usage` DISABLE KEYS */;
/*!40000 ALTER TABLE `ajax_usage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `brand_assigned_users`
--

DROP TABLE IF EXISTS `brand_assigned_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brand_assigned_users` (
  `brand_assigned_users_id` int(13) NOT NULL AUTO_INCREMENT,
  `user_id` int(13) NOT NULL DEFAULT '0',
  `supplier_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`brand_assigned_users_id`),
  KEY `user_id` (`user_id`,`supplier_id`),
  KEY `supplier_id` (`supplier_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `brand_assigned_users`
--

LOCK TABLES `brand_assigned_users` WRITE;
/*!40000 ALTER TABLE `brand_assigned_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `brand_assigned_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category` (
  `catid` int(13) NOT NULL AUTO_INCREMENT,
  `ucatid` varchar(255) DEFAULT NULL,
  `pcatid` int(13) NOT NULL DEFAULT '1',
  `sid` int(13) NOT NULL DEFAULT '0',
  `tid` int(13) DEFAULT NULL,
  `searchable` int(3) NOT NULL DEFAULT '0',
  `low_pic` varchar(255) NOT NULL DEFAULT '',
  `thumb_pic` varchar(255) DEFAULT '',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_published` int(14) DEFAULT '0',
  `watched_top10` int(3) NOT NULL DEFAULT '0',
  `visible` int(3) NOT NULL DEFAULT '0',
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`catid`),
  UNIQUE KEY `ucatid` (`ucatid`),
  UNIQUE KEY `icecat_id` (`icecat_id`),
  KEY `pcatid` (`pcatid`),
  KEY `catid` (`catid`,`sid`),
  KEY `searchable_2` (`searchable`,`catid`),
  KEY `sid_index` (`sid`),
  KEY `visible` (`visible`,`catid`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (1,'00000000',1,0,0,0,'','','2011-01-12 14:22:06',0,0,0,1);
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category_feature`
--

DROP TABLE IF EXISTS `category_feature`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category_feature` (
  `category_feature_id` int(13) NOT NULL AUTO_INCREMENT,
  `feature_id` int(13) NOT NULL DEFAULT '0',
  `catid` int(13) NOT NULL DEFAULT '0',
  `no` int(5) NOT NULL DEFAULT '0',
  `searchable` int(3) NOT NULL DEFAULT '0',
  `category_feature_group_id` int(13) NOT NULL DEFAULT '0',
  `restricted_search_values` mediumtext,
  `use_dropdown_input` char(3) DEFAULT '',
  `mandatory` tinyint(2) DEFAULT '0',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`category_feature_id`),
  UNIQUE KEY `feature_id` (`feature_id`,`catid`),
  UNIQUE KEY `icecat_id` (`icecat_id`),
  KEY `catid` (`catid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category_feature`
--

LOCK TABLES `category_feature` WRITE;
/*!40000 ALTER TABLE `category_feature` DISABLE KEYS */;
/*!40000 ALTER TABLE `category_feature` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category_feature_group`
--

DROP TABLE IF EXISTS `category_feature_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category_feature_group` (
  `category_feature_group_id` int(13) NOT NULL AUTO_INCREMENT,
  `catid` int(13) NOT NULL DEFAULT '0',
  `feature_group_id` int(13) NOT NULL DEFAULT '0',
  `no` int(15) DEFAULT '0',
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`category_feature_group_id`),
  UNIQUE KEY `uni1` (`catid`,`feature_group_id`),
  UNIQUE KEY `icecat_id` (`icecat_id`),
  KEY `catid` (`catid`,`feature_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category_feature_group`
--

LOCK TABLES `category_feature_group` WRITE;
/*!40000 ALTER TABLE `category_feature_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `category_feature_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category_feature_interval`
--

DROP TABLE IF EXISTS `category_feature_interval`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category_feature_interval` (
  `category_feature_interval_id` int(13) NOT NULL AUTO_INCREMENT,
  `category_feature_id` int(13) NOT NULL DEFAULT '0',
  `intervals` mediumtext,
  `in_each` mediumtext,
  `valid` int(13) DEFAULT NULL,
  `invalid` int(13) DEFAULT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `invalid_values` mediumtext NOT NULL,
  PRIMARY KEY (`category_feature_interval_id`),
  UNIQUE KEY `category_feature_id` (`category_feature_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category_feature_interval`
--

LOCK TABLES `category_feature_interval` WRITE;
/*!40000 ALTER TABLE `category_feature_interval` DISABLE KEYS */;
/*!40000 ALTER TABLE `category_feature_interval` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category_keywords`
--

DROP TABLE IF EXISTS `category_keywords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category_keywords` (
  `category_id` int(11) DEFAULT NULL,
  `langid` int(1) NOT NULL DEFAULT '0',
  `keywords` mediumtext,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `icecat_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `langid` (`langid`,`category_id`),
  UNIQUE KEY `icecat_id` (`icecat_id`),
  KEY `category_id` (`category_id`),
  FULLTEXT KEY `keywords` (`keywords`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category_keywords`
--

LOCK TABLES `category_keywords` WRITE;
/*!40000 ALTER TABLE `category_keywords` DISABLE KEYS */;
/*!40000 ALTER TABLE `category_keywords` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category_reverse`
--

DROP TABLE IF EXISTS `category_reverse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category_reverse` (
  `catid` int(13) NOT NULL,
  `low_pic` varchar(255) NOT NULL DEFAULT '',
  `thumb_pic` varchar(255) DEFAULT '',
  PRIMARY KEY (`catid`),
  KEY `low_pic` (`low_pic`),
  KEY `thumb_pic` (`thumb_pic`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category_reverse`
--

LOCK TABLES `category_reverse` WRITE;
/*!40000 ALTER TABLE `category_reverse` DISABLE KEYS */;
/*!40000 ALTER TABLE `category_reverse` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category_statistic`
--

DROP TABLE IF EXISTS `category_statistic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category_statistic` (
  `catid` int(11) NOT NULL DEFAULT '0',
  `score` int(11) NOT NULL DEFAULT '0',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`catid`),
  UNIQUE KEY `icecat_id` (`icecat_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category_statistic`
--

LOCK TABLES `category_statistic` WRITE;
/*!40000 ALTER TABLE `category_statistic` DISABLE KEYS */;
/*!40000 ALTER TABLE `category_statistic` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `compression_types`
--

DROP TABLE IF EXISTS `compression_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `compression_types` (
  `compression_types_id` int(13) NOT NULL AUTO_INCREMENT,
  `type` varchar(24) NOT NULL DEFAULT '',
  `description` varchar(255) NOT NULL DEFAULT '',
  `email_postscriptum` text,
  PRIMARY KEY (`compression_types_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compression_types`
--

LOCK TABLES `compression_types` WRITE;
/*!40000 ALTER TABLE `compression_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `compression_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact`
--

DROP TABLE IF EXISTS `contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact` (
  `contact_id` int(13) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `fax` varchar(255) DEFAULT NULL,
  `icq` varchar(255) DEFAULT NULL,
  `mphone` varchar(255) DEFAULT NULL,
  `person` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `street` varchar(255) DEFAULT NULL,
  `nbr` varchar(80) DEFAULT NULL,
  `zip` varchar(80) DEFAULT NULL,
  `country_id` int(13) NOT NULL DEFAULT '0',
  `company` varchar(255) DEFAULT NULL,
  `sector_id` int(13) NOT NULL DEFAULT '0',
  `email_subscribing` enum('Y','N') NOT NULL DEFAULT 'Y',
  `position` varchar(255) DEFAULT NULL,
  `supplier_contact_report_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`contact_id`),
  KEY `email` (`email`),
  KEY `supplier_contact_report_id` (`supplier_contact_report_id`,`contact_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact`
--

LOCK TABLES `contact` WRITE;
/*!40000 ALTER TABLE `contact` DISABLE KEYS */;
/*!40000 ALTER TABLE `contact` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_measure_index_map`
--

DROP TABLE IF EXISTS `content_measure_index_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_measure_index_map` (
  `content_measure` varchar(50) NOT NULL DEFAULT 'NOEDITOR',
  `quality_index` int(3) NOT NULL DEFAULT '0',
  KEY `content_measure` (`content_measure`,`quality_index`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_measure_index_map`
--

LOCK TABLES `content_measure_index_map` WRITE;
/*!40000 ALTER TABLE `content_measure_index_map` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_measure_index_map` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `country`
--

DROP TABLE IF EXISTS `country`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `country` (
  `country_id` int(13) NOT NULL AUTO_INCREMENT,
  `sid` int(13) NOT NULL DEFAULT '0',
  `code` varchar(5) DEFAULT NULL,
  `ean_prefix` varchar(10) DEFAULT NULL,
  `system_of_measurement` enum('metric','imperial') NOT NULL DEFAULT 'metric',
  PRIMARY KEY (`country_id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=MyISAM AUTO_INCREMENT=187 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `country`
--

LOCK TABLES `country` WRITE;
/*!40000 ALTER TABLE `country` DISABLE KEYS */;
INSERT INTO `country` VALUES (1,41,'AF',NULL,'metric'),(2,42,'AL',NULL,'metric'),(3,43,'DZ',NULL,'metric'),(4,44,'AD',NULL,'metric'),(5,45,'AO',NULL,'metric'),(6,46,'AG',NULL,'metric'),(7,47,'AR',NULL,'metric'),(8,48,'AM',NULL,'metric'),(9,49,'AU',NULL,'metric'),(10,50,'AT',NULL,'metric'),(11,51,'AZ',NULL,'metric'),(12,52,'BH',NULL,'metric'),(13,53,'BD',NULL,'metric'),(14,54,'BB',NULL,'metric'),(15,55,'BY',NULL,'metric'),(16,56,'BE',NULL,'metric'),(17,57,'BZ',NULL,'metric'),(18,58,'BJ',NULL,'metric'),(19,59,'BT',NULL,'metric'),(20,60,'BO',NULL,'metric'),(21,61,'BA',NULL,'metric'),(22,62,'BW',NULL,'metric'),(23,63,'BR',NULL,'metric'),(24,64,'BN',NULL,'metric'),(25,65,'BG',NULL,'metric'),(26,66,'BF',NULL,'metric'),(27,67,'BI',NULL,'metric'),(28,68,'KH',NULL,'metric'),(29,69,'CM',NULL,'metric'),(30,70,'CA',NULL,'metric'),(31,71,'CV',NULL,'metric'),(32,72,'CF',NULL,'metric'),(33,73,'TD',NULL,'metric'),(34,74,'CL',NULL,'metric'),(35,75,'CO',NULL,'metric'),(36,76,'KM',NULL,'metric'),(37,77,'CR',NULL,'metric'),(38,78,'CI',NULL,'metric'),(39,79,'HR',NULL,'metric'),(40,80,'CU',NULL,'metric'),(41,81,'CY',NULL,'metric'),(42,82,'CZ',NULL,'metric'),(43,83,'DK',NULL,'metric'),(44,84,'DJ',NULL,'metric'),(45,85,'DM',NULL,'metric'),(46,86,'DO',NULL,'metric'),(47,87,'EC',NULL,'metric'),(48,88,'EG',NULL,'metric'),(49,89,'SV',NULL,'metric'),(50,90,'GQ',NULL,'metric'),(51,91,'ER',NULL,'metric'),(52,92,'EE',NULL,'metric'),(53,93,'ET',NULL,'metric'),(54,94,'FJ',NULL,'metric'),(55,95,'FI',NULL,'metric'),(56,96,'FR',NULL,'metric'),(57,97,'GA',NULL,'metric'),(58,98,'GE',NULL,'metric'),(59,99,'DE',NULL,'metric'),(60,100,'GH',NULL,'metric'),(61,101,'GR',NULL,'metric'),(62,102,'GD',NULL,'metric'),(63,103,'GT',NULL,'metric'),(64,104,'GN',NULL,'metric'),(65,105,'GW',NULL,'metric'),(66,106,'GY',NULL,'metric'),(67,107,'HT',NULL,'metric'),(68,108,'HN',NULL,'metric'),(69,109,'HU',NULL,'metric'),(70,110,'IS',NULL,'metric'),(71,111,'IN',NULL,'metric'),(72,112,'ID',NULL,'metric'),(73,113,'IR',NULL,'metric'),(74,114,'IQ',NULL,'metric'),(75,115,'IE',NULL,'metric'),(76,116,'IL',NULL,'metric'),(77,117,'IT',NULL,'metric'),(78,118,'JM',NULL,'metric'),(79,119,'JP',NULL,'metric'),(80,120,'JO',NULL,'metric'),(81,121,'KZ',NULL,'metric'),(82,122,'KE',NULL,'metric'),(83,123,'KI',NULL,'metric'),(84,124,'KW',NULL,'metric'),(85,125,'KG',NULL,'metric'),(86,126,'LA',NULL,'metric'),(87,127,'LV',NULL,'metric'),(88,128,'LB',NULL,'metric'),(89,129,'LS',NULL,'metric'),(90,130,'LR',NULL,'metric'),(91,131,'LY',NULL,'metric'),(92,132,'LI',NULL,'metric'),(93,133,'LT',NULL,'metric'),(94,134,'LU',NULL,'metric'),(95,135,'MK',NULL,'metric'),(96,136,'MG',NULL,'metric'),(97,137,'MW',NULL,'metric'),(98,138,'MY',NULL,'metric'),(99,139,'MV',NULL,'metric'),(100,140,'ML',NULL,'metric'),(101,141,'MT',NULL,'metric'),(102,142,'MH',NULL,'metric'),(103,143,'MR',NULL,'metric'),(104,144,'MU',NULL,'metric'),(105,145,'MX',NULL,'metric'),(106,146,'FM',NULL,'metric'),(107,147,'MD',NULL,'metric'),(108,148,'MC',NULL,'metric'),(109,149,'MN',NULL,'metric'),(110,150,'ME',NULL,'metric'),(111,151,'MA',NULL,'metric'),(112,152,'MZ',NULL,'metric'),(113,153,'MM',NULL,'metric'),(114,154,'NA',NULL,'metric'),(115,155,'NR',NULL,'metric'),(116,156,'NP',NULL,'metric'),(117,157,'NL',NULL,'metric'),(118,158,'NZ',NULL,'metric'),(119,159,'NI',NULL,'metric'),(120,160,'NE',NULL,'metric'),(121,161,'NG',NULL,'metric'),(122,162,'NO',NULL,'metric'),(123,163,'OM',NULL,'metric'),(124,164,'PK',NULL,'metric'),(125,165,'PW',NULL,'metric'),(126,166,'PA',NULL,'metric'),(127,167,'PG',NULL,'metric'),(128,168,'PY',NULL,'metric'),(129,169,'PE',NULL,'metric'),(130,170,'PH',NULL,'metric'),(131,171,'PL',NULL,'metric'),(132,172,'PT',NULL,'metric'),(133,173,'QA',NULL,'metric'),(134,174,'RO',NULL,'metric'),(135,175,'RU',NULL,'metric'),(136,176,'RW',NULL,'metric'),(137,177,'KN',NULL,'metric'),(138,178,'LC',NULL,'metric'),(139,179,'VC',NULL,'metric'),(140,180,'WS',NULL,'metric'),(141,181,'SM',NULL,'metric'),(142,182,'ST',NULL,'metric'),(143,183,'SA',NULL,'metric'),(144,184,'SN',NULL,'metric'),(145,185,'RS',NULL,'metric'),(146,186,'SC',NULL,'metric'),(147,187,'SL',NULL,'metric'),(148,188,'SG',NULL,'metric'),(149,189,'SK',NULL,'metric'),(150,190,'SI',NULL,'metric'),(151,191,'SB',NULL,'metric'),(152,192,'SO',NULL,'metric'),(153,193,'Rand',NULL,'metric'),(154,194,'ES',NULL,'metric'),(155,195,'LK',NULL,'metric'),(156,196,'SD',NULL,'metric'),(157,197,'SR',NULL,'metric'),(158,198,'SZ',NULL,'metric'),(159,199,'SE',NULL,'metric'),(160,200,'CH',NULL,'metric'),(161,201,'SY',NULL,'metric'),(162,202,'TJ',NULL,'metric'),(163,203,'TZ',NULL,'metric'),(164,204,'TH',NULL,'metric'),(165,205,'TL',NULL,'metric'),(166,206,'TG',NULL,'metric'),(167,207,'TO',NULL,'metric'),(168,208,'TT',NULL,'metric'),(169,209,'TN',NULL,'metric'),(170,210,'TR',NULL,'metric'),(171,211,'TM',NULL,'metric'),(172,212,'TV',NULL,'metric'),(173,213,'UG',NULL,'metric'),(174,214,'UA',NULL,'metric'),(175,215,'AE',NULL,'metric'),(176,216,'GB',NULL,'metric'),(177,217,'US',NULL,'metric'),(178,218,'UY',NULL,'metric'),(179,219,'UZ',NULL,'metric'),(180,220,'VU',NULL,'metric'),(181,221,'VA',NULL,'metric'),(182,222,'VE',NULL,'metric'),(183,223,'VN',NULL,'metric'),(184,224,'YE',NULL,'metric'),(185,225,'ZM',NULL,'metric'),(186,226,'ZW',NULL,'metric');
/*!40000 ALTER TABLE `country` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `country_language`
--

DROP TABLE IF EXISTS `country_language`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `country_language` (
  `country_language_id` int(5) NOT NULL AUTO_INCREMENT,
  `country_id` int(13) NOT NULL DEFAULT '0',
  `langid` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`country_language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `country_language`
--

LOCK TABLES `country_language` WRITE;
/*!40000 ALTER TABLE `country_language` DISABLE KEYS */;
/*!40000 ALTER TABLE `country_language` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `country_popular`
--

DROP TABLE IF EXISTS `country_popular`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `country_popular` (
  `country_popular_id` int(13) NOT NULL AUTO_INCREMENT,
  `country_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`country_popular_id`),
  UNIQUE KEY `country_id` (`country_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `country_popular`
--

LOCK TABLES `country_popular` WRITE;
/*!40000 ALTER TABLE `country_popular` DISABLE KEYS */;
/*!40000 ALTER TABLE `country_popular` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `country_product`
--

DROP TABLE IF EXISTS `country_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `country_product` (
  `country_product_id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `country_id` int(13) NOT NULL DEFAULT '0',
  `stock` int(10) NOT NULL DEFAULT '0',
  `existed` tinyint(5) NOT NULL DEFAULT '0',
  `active` tinyint(1) NOT NULL DEFAULT '0',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`country_product_id`),
  UNIQUE KEY `product_id_2` (`product_id`,`country_id`),
  KEY `existed` (`existed`,`active`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `country_product`
--

LOCK TABLES `country_product` WRITE;
/*!40000 ALTER TABLE `country_product` DISABLE KEYS */;
/*!40000 ALTER TABLE `country_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_source`
--

DROP TABLE IF EXISTS `data_source`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_source` (
  `data_source_id` int(13) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) NOT NULL DEFAULT '',
  `update_style` char(3) DEFAULT NULL,
  `user_id` int(13) NOT NULL DEFAULT '0',
  `email` varchar(255) NOT NULL DEFAULT '',
  `send_report` int(3) DEFAULT '0',
  `configuration` mediumtext,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`data_source_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_source`
--

LOCK TABLES `data_source` WRITE;
/*!40000 ALTER TABLE `data_source` DISABLE KEYS */;
INSERT INTO `data_source` VALUES (1,'prijslijst.txt','U',2,'shestakdima@bintime.com',1,'d_uglatch@gmail.com','2011-01-12 14:29:43');
/*!40000 ALTER TABLE `data_source` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_source_category_map`
--

DROP TABLE IF EXISTS `data_source_category_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_source_category_map` (
  `data_source_category_map_id` int(13) NOT NULL AUTO_INCREMENT,
  `data_source_id` int(13) NOT NULL DEFAULT '0',
  `symbol` mediumtext,
  `catid` int(13) NOT NULL DEFAULT '0',
  `frequency` int(13) NOT NULL DEFAULT '0',
  `distributor_id` int(13) NOT NULL DEFAULT '0',
  `unused` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`data_source_category_map_id`),
  UNIQUE KEY `data_source_id_2` (`data_source_id`,`symbol`(255),`distributor_id`),
  KEY `data_source_id` (`data_source_id`),
  KEY `catid` (`catid`),
  KEY `distributor_id` (`distributor_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_source_category_map`
--

LOCK TABLES `data_source_category_map` WRITE;
/*!40000 ALTER TABLE `data_source_category_map` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_source_category_map` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_source_feature_map`
--

DROP TABLE IF EXISTS `data_source_feature_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_source_feature_map` (
  `data_source_feature_map_id` int(13) NOT NULL AUTO_INCREMENT,
  `data_source_id` int(13) NOT NULL DEFAULT '0',
  `symbol` mediumtext,
  `override_value_to` mediumtext,
  `feature_id` int(13) NOT NULL DEFAULT '0',
  `catid` int(13) NOT NULL DEFAULT '1',
  `coef` varchar(255) NOT NULL DEFAULT '',
  `format` varchar(255) DEFAULT '',
  `distributor_id` int(13) NOT NULL DEFAULT '0',
  `only_product_values` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`data_source_feature_map_id`),
  UNIQUE KEY `data_source_id` (`data_source_id`,`symbol`(255),`feature_id`,`catid`,`distributor_id`),
  KEY `feature_id` (`feature_id`),
  KEY `distributor_id` (`distributor_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_source_feature_map`
--

LOCK TABLES `data_source_feature_map` WRITE;
/*!40000 ALTER TABLE `data_source_feature_map` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_source_feature_map` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_source_supplier_map`
--

DROP TABLE IF EXISTS `data_source_supplier_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_source_supplier_map` (
  `data_source_supplier_map_id` int(13) NOT NULL AUTO_INCREMENT,
  `data_source_id` int(13) NOT NULL DEFAULT '0',
  `symbol` mediumtext,
  `supplier_id` int(13) NOT NULL DEFAULT '0',
  `distributor_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`data_source_supplier_map_id`),
  UNIQUE KEY `symbol` (`symbol`(255),`data_source_id`,`distributor_id`),
  KEY `distributor_id` (`distributor_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_source_supplier_map`
--

LOCK TABLES `data_source_supplier_map` WRITE;
/*!40000 ALTER TABLE `data_source_supplier_map` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_source_supplier_map` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `distributor`
--

DROP TABLE IF EXISTS `distributor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `distributor` (
  `distributor_id` int(13) NOT NULL AUTO_INCREMENT,
  `country_id` int(13) NOT NULL DEFAULT '0',
  `code` varchar(60) NOT NULL DEFAULT '',
  `name` varchar(100) NOT NULL DEFAULT '',
  `trust_level` int(13) NOT NULL DEFAULT '0',
  `langid` int(3) NOT NULL DEFAULT '0',
  `direct` tinyint(1) NOT NULL DEFAULT '0',
  `last_import_date` int(13) NOT NULL DEFAULT '0',
  `file_creation_date` int(13) NOT NULL DEFAULT '0',
  `source` enum('iceimport','icecat','prf') NOT NULL DEFAULT 'icecat',
  `group_code` varchar(255) NOT NULL DEFAULT '',
  `sync` tinyint(4) DEFAULT NULL,
  `visible` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`distributor_id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `distributor`
--

LOCK TABLES `distributor` WRITE;
/*!40000 ALTER TABLE `distributor` DISABLE KEYS */;
INSERT INTO `distributor` VALUES (1,2,'Euronics','Euronics',0,0,0,0,0,'icecat','Euronics',NULL,1);
/*!40000 ALTER TABLE `distributor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `distributor_pl`
--

DROP TABLE IF EXISTS `distributor_pl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `distributor_pl` (
  `distributor_pl_id` int(13) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `langid` int(11) NOT NULL DEFAULT '0',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `feed_url` varchar(255) NOT NULL,
  `feed_type` varchar(10) NOT NULL,
  `is_first_header` int(1) NOT NULL DEFAULT '1',
  `feed_login` varchar(250) NOT NULL,
  `feed_pwd` varchar(250) NOT NULL,
  `delimiter` varchar(250) NOT NULL,
  `newline` varchar(250) NOT NULL,
  `escape` varchar(1) NOT NULL DEFAULT '\\',
  `quote` varchar(1) NOT NULL DEFAULT '"',
  `user_choiced_file` varchar(250) NOT NULL DEFAULT '',
  `country_col` int(11) NOT NULL DEFAULT '0',
  `ean_col` int(11) NOT NULL DEFAULT '0',
  `name_col` int(11) NOT NULL DEFAULT '0',
  `price_vat_col` int(11) NOT NULL DEFAULT '0',
  `price_novat_col` int(11) NOT NULL DEFAULT '0',
  `desc_col` int(11) NOT NULL DEFAULT '0',
  `stock_col` int(11) NOT NULL DEFAULT '0',
  `distri_prodid_col` int(11) NOT NULL DEFAULT '0',
  `brand_col` int(11) NOT NULL DEFAULT '0',
  `brand_prodid_col` int(11) NOT NULL DEFAULT '0',
  `category_col` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`distributor_pl_id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `distributor_pl`
--

LOCK TABLES `distributor_pl` WRITE;
/*!40000 ALTER TABLE `distributor_pl` DISABLE KEYS */;
INSERT INTO `distributor_pl` VALUES (1,'Euronics','Euronics',0,1,'2011-01-11 06:55:44','http://localhost/tbl_artbook.zip','csv',1,'','',';','\\r\\n','','\"','',0,3,0,0,0,4,16,0,1,2,0);
/*!40000 ALTER TABLE `distributor_pl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `distributor_product`
--

DROP TABLE IF EXISTS `distributor_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `distributor_product` (
  `distributor_product_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `distributor_id` int(13) unsigned NOT NULL DEFAULT '0',
  `product_id` int(13) unsigned NOT NULL DEFAULT '0',
  `stock` int(10) unsigned NOT NULL DEFAULT '0',
  `dist_prod_id` varchar(235) NOT NULL DEFAULT '',
  `original_prod_id` varchar(255) NOT NULL DEFAULT '',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `active` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `original_supplier_id` mediumint(7) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`distributor_product_id`),
  UNIQUE KEY `original_prod_id` (`original_prod_id`,`distributor_id`,`product_id`),
  KEY `dist_prod_id` (`dist_prod_id`,`distributor_id`,`product_id`),
  KEY `distributor_id` (`distributor_id`,`product_id`,`active`),
  KEY `product_id` (`product_id`,`active`),
  KEY `active` (`active`),
  KEY `updated` (`updated`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `distributor_product`
--

LOCK TABLES `distributor_product` WRITE;
/*!40000 ALTER TABLE `distributor_product` DISABLE KEYS */;
/*!40000 ALTER TABLE `distributor_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `distributor_tokens`
--

DROP TABLE IF EXISTS `distributor_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `distributor_tokens` (
  `distributor_token_id` int(13) NOT NULL AUTO_INCREMENT,
  `distributor_id` int(13) NOT NULL,
  `token` varchar(255) NOT NULL,
  PRIMARY KEY (`distributor_token_id`),
  UNIQUE KEY `token2` (`distributor_id`,`token`),
  KEY `token` (`token`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `distributor_tokens`
--

LOCK TABLES `distributor_tokens` WRITE;
/*!40000 ALTER TABLE `distributor_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `distributor_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `editor_journal`
--

DROP TABLE IF EXISTS `editor_journal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `editor_journal` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `user_id` int(13) NOT NULL DEFAULT '0',
  `product_table` varchar(50) NOT NULL DEFAULT '',
  `product_table_id` int(13) NOT NULL DEFAULT '0',
  `date` int(14) NOT NULL DEFAULT '0',
  `product_id` int(13) NOT NULL DEFAULT '0',
  `supplier_id` int(13) NOT NULL DEFAULT '0',
  `prod_id` varchar(255) NOT NULL DEFAULT '',
  `catid` int(13) NOT NULL DEFAULT '0',
  `score` tinyint(2) DEFAULT '0',
  `action_type` int(13) NOT NULL DEFAULT '0',
  `content_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `user_id_2` (`user_id`,`date`),
  KEY `date_2` (`date`,`user_id`,`product_id`),
  KEY `product_table_2` (`product_id`,`user_id`,`date`,`product_table`),
  KEY `product_table` (`product_table`,`user_id`,`product_table_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `editor_journal`
--

LOCK TABLES `editor_journal` WRITE;
/*!40000 ALTER TABLE `editor_journal` DISABLE KEYS */;
/*!40000 ALTER TABLE `editor_journal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `editor_journal_custom`
--

DROP TABLE IF EXISTS `editor_journal_custom`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `editor_journal_custom` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `table_name` varchar(30) NOT NULL DEFAULT '0',
  `content_id` int(13) NOT NULL DEFAULT '0',
  `data` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `editor_journal_custom`
--

LOCK TABLES `editor_journal_custom` WRITE;
/*!40000 ALTER TABLE `editor_journal_custom` DISABLE KEYS */;
/*!40000 ALTER TABLE `editor_journal_custom` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `editor_journal_product`
--

DROP TABLE IF EXISTS `editor_journal_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `editor_journal_product` (
  `content_id` int(13) NOT NULL AUTO_INCREMENT,
  `supplier_id` int(13) NOT NULL DEFAULT '0',
  `prod_id` varchar(60) NOT NULL DEFAULT '',
  `catid` int(13) NOT NULL DEFAULT '0',
  `user_id` int(13) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `low_pic` varchar(255) NOT NULL DEFAULT '',
  `high_pic` varchar(255) NOT NULL DEFAULT '',
  `publish` char(1) NOT NULL DEFAULT '',
  `public` char(1) NOT NULL DEFAULT '',
  `thumb_pic` varchar(255) NOT NULL DEFAULT '',
  `family_id` int(13) NOT NULL DEFAULT '0',
  `series_id` int(17) NOT NULL,
  `checked_by_supereditor` tinyint(1) NOT NULL,
  PRIMARY KEY (`content_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `editor_journal_product`
--

LOCK TABLES `editor_journal_product` WRITE;
/*!40000 ALTER TABLE `editor_journal_product` DISABLE KEYS */;
/*!40000 ALTER TABLE `editor_journal_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `editor_journal_product_description`
--

DROP TABLE IF EXISTS `editor_journal_product_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `editor_journal_product_description` (
  `content_id` int(13) NOT NULL AUTO_INCREMENT,
  `langid` int(13) NOT NULL DEFAULT '0',
  `short_desc` varchar(3000) NOT NULL DEFAULT '',
  `long_desc` mediumtext NOT NULL,
  `official_url` varchar(255) NOT NULL DEFAULT '',
  `warranty_info` mediumtext NOT NULL,
  `pdf_url` varchar(255) NOT NULL DEFAULT '',
  `manual_pdf_url` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`content_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `editor_journal_product_description`
--

LOCK TABLES `editor_journal_product_description` WRITE;
/*!40000 ALTER TABLE `editor_journal_product_description` DISABLE KEYS */;
/*!40000 ALTER TABLE `editor_journal_product_description` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `editor_journal_product_ean_codes`
--

DROP TABLE IF EXISTS `editor_journal_product_ean_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `editor_journal_product_ean_codes` (
  `content_id` int(13) NOT NULL AUTO_INCREMENT,
  `ean_code` char(13) NOT NULL DEFAULT '',
  PRIMARY KEY (`content_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `editor_journal_product_ean_codes`
--

LOCK TABLES `editor_journal_product_ean_codes` WRITE;
/*!40000 ALTER TABLE `editor_journal_product_ean_codes` DISABLE KEYS */;
/*!40000 ALTER TABLE `editor_journal_product_ean_codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `editor_journal_product_feature_local_pack`
--

DROP TABLE IF EXISTS `editor_journal_product_feature_local_pack`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `editor_journal_product_feature_local_pack` (
  `content_id` int(13) NOT NULL AUTO_INCREMENT,
  `data` text NOT NULL,
  PRIMARY KEY (`content_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `editor_journal_product_feature_local_pack`
--

LOCK TABLES `editor_journal_product_feature_local_pack` WRITE;
/*!40000 ALTER TABLE `editor_journal_product_feature_local_pack` DISABLE KEYS */;
/*!40000 ALTER TABLE `editor_journal_product_feature_local_pack` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `editor_journal_product_feature_pack`
--

DROP TABLE IF EXISTS `editor_journal_product_feature_pack`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `editor_journal_product_feature_pack` (
  `content_id` int(13) NOT NULL AUTO_INCREMENT,
  `data` text NOT NULL,
  PRIMARY KEY (`content_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `editor_journal_product_feature_pack`
--

LOCK TABLES `editor_journal_product_feature_pack` WRITE;
/*!40000 ALTER TABLE `editor_journal_product_feature_pack` DISABLE KEYS */;
/*!40000 ALTER TABLE `editor_journal_product_feature_pack` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `editor_journal_product_gallery`
--

DROP TABLE IF EXISTS `editor_journal_product_gallery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `editor_journal_product_gallery` (
  `content_id` int(13) NOT NULL AUTO_INCREMENT,
  `link` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`content_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `editor_journal_product_gallery`
--

LOCK TABLES `editor_journal_product_gallery` WRITE;
/*!40000 ALTER TABLE `editor_journal_product_gallery` DISABLE KEYS */;
/*!40000 ALTER TABLE `editor_journal_product_gallery` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `editor_journal_product_multimedia_object`
--

DROP TABLE IF EXISTS `editor_journal_product_multimedia_object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `editor_journal_product_multimedia_object` (
  `content_id` int(13) NOT NULL AUTO_INCREMENT,
  `short_descr` mediumtext NOT NULL,
  `langid` int(13) NOT NULL DEFAULT '0',
  `content_type` varchar(255) NOT NULL DEFAULT '',
  `keep_as_url` tinyint(1) NOT NULL DEFAULT '0',
  `type` varchar(255) NOT NULL DEFAULT '',
  `link` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`content_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `editor_journal_product_multimedia_object`
--

LOCK TABLES `editor_journal_product_multimedia_object` WRITE;
/*!40000 ALTER TABLE `editor_journal_product_multimedia_object` DISABLE KEYS */;
/*!40000 ALTER TABLE `editor_journal_product_multimedia_object` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `editor_journal_product_name`
--

DROP TABLE IF EXISTS `editor_journal_product_name`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `editor_journal_product_name` (
  `content_id` int(13) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `langid` smallint(5) NOT NULL DEFAULT '0',
  PRIMARY KEY (`content_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `editor_journal_product_name`
--

LOCK TABLES `editor_journal_product_name` WRITE;
/*!40000 ALTER TABLE `editor_journal_product_name` DISABLE KEYS */;
/*!40000 ALTER TABLE `editor_journal_product_name` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `editor_journal_product_related`
--

DROP TABLE IF EXISTS `editor_journal_product_related`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `editor_journal_product_related` (
  `content_id` int(13) NOT NULL AUTO_INCREMENT,
  `rel_product_id` int(13) NOT NULL DEFAULT '0',
  `rel_product_name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`content_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `editor_journal_product_related`
--

LOCK TABLES `editor_journal_product_related` WRITE;
/*!40000 ALTER TABLE `editor_journal_product_related` DISABLE KEYS */;
/*!40000 ALTER TABLE `editor_journal_product_related` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feature`
--

DROP TABLE IF EXISTS `feature`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feature` (
  `feature_id` int(13) NOT NULL AUTO_INCREMENT,
  `sid` int(13) NOT NULL DEFAULT '0',
  `tid` int(13) NOT NULL DEFAULT '0',
  `measure_id` int(13) NOT NULL DEFAULT '0',
  `type` varchar(255) NOT NULL DEFAULT '',
  `class` int(3) NOT NULL DEFAULT '0',
  `limit_direction` int(3) NOT NULL DEFAULT '0',
  `searchable` int(3) NOT NULL DEFAULT '0',
  `restricted_values` mediumtext,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_published` int(14) DEFAULT '0',
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`feature_id`),
  UNIQUE KEY `icecat_id` (`icecat_id`),
  KEY `tid` (`tid`),
  KEY `sid` (`sid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feature`
--

LOCK TABLES `feature` WRITE;
/*!40000 ALTER TABLE `feature` DISABLE KEYS */;
/*!40000 ALTER TABLE `feature` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feature_autonaming`
--

DROP TABLE IF EXISTS `feature_autonaming`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feature_autonaming` (
  `feature_autonaming_id` int(13) NOT NULL AUTO_INCREMENT,
  `feature_id` int(13) NOT NULL DEFAULT '0',
  `langid` int(3) NOT NULL DEFAULT '0',
  `data_source_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`feature_autonaming_id`),
  UNIQUE KEY `feature_id` (`feature_id`,`langid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feature_autonaming`
--

LOCK TABLES `feature_autonaming` WRITE;
/*!40000 ALTER TABLE `feature_autonaming` DISABLE KEYS */;
/*!40000 ALTER TABLE `feature_autonaming` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feature_group`
--

DROP TABLE IF EXISTS `feature_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feature_group` (
  `feature_group_id` int(13) NOT NULL AUTO_INCREMENT,
  `sid` int(13) NOT NULL DEFAULT '0',
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`feature_group_id`),
  UNIQUE KEY `icecat_id` (`icecat_id`),
  KEY `sid` (`sid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feature_group`
--

LOCK TABLES `feature_group` WRITE;
/*!40000 ALTER TABLE `feature_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `feature_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feature_input_type`
--

DROP TABLE IF EXISTS `feature_input_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feature_input_type` (
  `feature_input_type_id` int(13) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `pattern` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`feature_input_type_id`),
  UNIQUE KEY `type` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feature_input_type`
--

LOCK TABLES `feature_input_type` WRITE;
/*!40000 ALTER TABLE `feature_input_type` DISABLE KEYS */;
/*!40000 ALTER TABLE `feature_input_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feature_value_mapping`
--

DROP TABLE IF EXISTS `feature_value_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feature_value_mapping` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `feature_id` int(13) NOT NULL DEFAULT '0',
  `ext_value` mediumtext,
  `int_value` mediumtext,
  PRIMARY KEY (`id`),
  KEY `feature_id` (`feature_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feature_value_mapping`
--

LOCK TABLES `feature_value_mapping` WRITE;
/*!40000 ALTER TABLE `feature_value_mapping` DISABLE KEYS */;
/*!40000 ALTER TABLE `feature_value_mapping` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feature_value_regexp`
--

DROP TABLE IF EXISTS `feature_value_regexp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feature_value_regexp` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `value_regexp_id` int(13) NOT NULL DEFAULT '0',
  `feature_id` int(13) NOT NULL DEFAULT '0',
  `no` int(13) NOT NULL DEFAULT '0',
  `active` char(1) NOT NULL DEFAULT 'N',
  PRIMARY KEY (`id`),
  KEY `feature_id` (`feature_id`,`no`),
  KEY `value_regexp_id` (`value_regexp_id`),
  KEY `active` (`active`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feature_value_regexp`
--

LOCK TABLES `feature_value_regexp` WRITE;
/*!40000 ALTER TABLE `feature_value_regexp` DISABLE KEYS */;
/*!40000 ALTER TABLE `feature_value_regexp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feature_values_group`
--

DROP TABLE IF EXISTS `feature_values_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feature_values_group` (
  `feature_values_group_id` int(13) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL DEFAULT '',
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`feature_values_group_id`),
  UNIQUE KEY `icecat_id` (`icecat_id`),
  KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feature_values_group`
--

LOCK TABLES `feature_values_group` WRITE;
/*!40000 ALTER TABLE `feature_values_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `feature_values_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feature_values_vocabulary`
--

DROP TABLE IF EXISTS `feature_values_vocabulary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feature_values_vocabulary` (
  `record_id` int(13) NOT NULL AUTO_INCREMENT,
  `key_value` varchar(200) NOT NULL DEFAULT '',
  `langid` int(3) NOT NULL DEFAULT '1',
  `feature_values_group_id` int(13) NOT NULL DEFAULT '1',
  `value` varchar(200) NOT NULL DEFAULT '',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_published` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`record_id`),
  UNIQUE KEY `key_value` (`key_value`,`langid`),
  UNIQUE KEY `icecat_id` (`icecat_id`),
  KEY `feature_values_group_id` (`feature_values_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feature_values_vocabulary`
--

LOCK TABLES `feature_values_vocabulary` WRITE;
/*!40000 ALTER TABLE `feature_values_vocabulary` DISABLE KEYS */;
/*!40000 ALTER TABLE `feature_values_vocabulary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `features_to_reupdate`
--

DROP TABLE IF EXISTS `features_to_reupdate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `features_to_reupdate` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `feature_id` int(13) NOT NULL DEFAULT '0',
  `supplier_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `feature_id` (`feature_id`,`supplier_id`),
  KEY `supplier_id` (`supplier_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `features_to_reupdate`
--

LOCK TABLES `features_to_reupdate` WRITE;
/*!40000 ALTER TABLE `features_to_reupdate` DISABLE KEYS */;
/*!40000 ALTER TABLE `features_to_reupdate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `generate_report_bg_processes`
--

DROP TABLE IF EXISTS `generate_report_bg_processes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `generate_report_bg_processes` (
  `generate_report_bg_processes_id` int(13) NOT NULL AUTO_INCREMENT,
  `bg_user_id` int(13) NOT NULL DEFAULT '0',
  `bg_start_date` int(13) NOT NULL DEFAULT '0',
  `bg_stage` varchar(255) NOT NULL DEFAULT '',
  `bg_max_value` int(13) NOT NULL DEFAULT '0',
  `bg_current_value` int(13) NOT NULL DEFAULT '0',
  `email` mediumtext,
  `from_day` varchar(255) DEFAULT NULL,
  `from_month` varchar(255) DEFAULT NULL,
  `from_year` varchar(255) DEFAULT NULL,
  `mail_class_format` varchar(255) DEFAULT NULL,
  `period` varchar(255) DEFAULT NULL,
  `reload` varchar(255) DEFAULT NULL,
  `request_partner_id` varchar(255) DEFAULT NULL,
  `request_user_id` varchar(255) DEFAULT NULL,
  `search_catid` varchar(255) DEFAULT NULL,
  `search_edit_user_id` varchar(255) DEFAULT NULL,
  `search_prod_id` varchar(255) DEFAULT NULL,
  `search_supplier_id` varchar(255) DEFAULT NULL,
  `subtotal_1` varchar(255) DEFAULT NULL,
  `subtotal_2` varchar(255) DEFAULT NULL,
  `subtotal_3` varchar(255) DEFAULT NULL,
  `to_day` varchar(255) DEFAULT NULL,
  `to_month` varchar(255) DEFAULT NULL,
  `to_year` varchar(255) DEFAULT NULL,
  `name` varchar(60) DEFAULT NULL,
  `class` varchar(60) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `request_country_id` varchar(255) DEFAULT NULL,
  `email_attachment_compression` varchar(255) DEFAULT NULL,
  `search_product_country_id` varchar(255) DEFAULT NULL,
  `search_product_distributor_id` varchar(255) DEFAULT NULL,
  `search_product_onstock` varchar(255) DEFAULT NULL,
  `search_supplier_type` varchar(255) DEFAULT NULL,
  `include_top_cats` varchar(255) DEFAULT NULL,
  `include_top_product` varchar(255) DEFAULT NULL,
  `search_catid_name` varchar(255) DEFAULT NULL,
  `search_catid_old` varchar(255) DEFAULT NULL,
  `search_catid_selected` varchar(255) DEFAULT NULL,
  `search_catid_value_selected` varchar(255) DEFAULT NULL,
  `bg_end_date` int(13) NOT NULL DEFAULT '0',
  `include_top_owner` varchar(255) DEFAULT NULL,
  `include_top_supplier` varchar(255) DEFAULT NULL,
  `connection_id` bigint(25) NOT NULL DEFAULT '0',
  PRIMARY KEY (`generate_report_bg_processes_id`),
  KEY `bg_user_id` (`bg_user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `generate_report_bg_processes`
--

LOCK TABLES `generate_report_bg_processes` WRITE;
/*!40000 ALTER TABLE `generate_report_bg_processes` DISABLE KEYS */;
/*!40000 ALTER TABLE `generate_report_bg_processes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `generic_operation`
--

DROP TABLE IF EXISTS `generic_operation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `generic_operation` (
  `generic_operation_id` int(13) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `code` varchar(255) NOT NULL DEFAULT '',
  `parameter` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`generic_operation_id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `generic_operation`
--

LOCK TABLES `generic_operation` WRITE;
/*!40000 ALTER TABLE `generic_operation` DISABLE KEYS */;
/*!40000 ALTER TABLE `generic_operation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `google_translations`
--

DROP TABLE IF EXISTS `google_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `google_translations` (
  `google_translations_id` int(13) NOT NULL AUTO_INCREMENT,
  `source_text` mediumtext NOT NULL,
  `source_text_md5` varchar(100) NOT NULL,
  `source_langid` int(13) NOT NULL,
  `trans_text` mediumtext NOT NULL,
  `trans_text_md5` varchar(100) NOT NULL,
  `trans_langid` int(13) NOT NULL,
  PRIMARY KEY (`google_translations_id`),
  UNIQUE KEY `source_text_md5` (`source_text_md5`,`source_langid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `google_translations`
--

LOCK TABLES `google_translations` WRITE;
/*!40000 ALTER TABLE `google_translations` DISABLE KEYS */;
/*!40000 ALTER TABLE `google_translations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `imperial_metric`
--

DROP TABLE IF EXISTS `imperial_metric`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `imperial_metric` (
  `value` varchar(255) NOT NULL DEFAULT '',
  `unit` varchar(60) NOT NULL DEFAULT '',
  `r_unit` varchar(60) NOT NULL DEFAULT '',
  `type` varchar(60) NOT NULL DEFAULT '',
  `product_id` int(13) NOT NULL DEFAULT '0',
  `probability` int(13) NOT NULL DEFAULT '0',
  `metric_value` varchar(255) NOT NULL DEFAULT '',
  `metric_unit` varchar(60) NOT NULL DEFAULT '',
  `imperial_value` varchar(255) NOT NULL DEFAULT '',
  `imperial_unit` varchar(60) NOT NULL DEFAULT '',
  UNIQUE KEY `value` (`value`,`type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `imperial_metric`
--

LOCK TABLES `imperial_metric` WRITE;
/*!40000 ALTER TABLE `imperial_metric` DISABLE KEYS */;
/*!40000 ALTER TABLE `imperial_metric` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `language`
--

DROP TABLE IF EXISTS `language`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `language` (
  `langid` int(3) NOT NULL AUTO_INCREMENT,
  `sid` int(13) NOT NULL DEFAULT '0',
  `code` varchar(32) NOT NULL DEFAULT '',
  `short_code` varchar(5) NOT NULL DEFAULT '',
  `published` char(1) NOT NULL DEFAULT 'N',
  `backup_langid` int(3) DEFAULT NULL,
  `icecat_id` int(3) DEFAULT NULL,
  PRIMARY KEY (`langid`),
  UNIQUE KEY `icecat_id` (`icecat_id`),
  KEY `short_code` (`short_code`)
) ENGINE=MyISAM AUTO_INCREMENT=41 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `language`
--

LOCK TABLES `language` WRITE;
/*!40000 ALTER TABLE `language` DISABLE KEYS */;
INSERT INTO `language` VALUES (1,1,'english','EN','N',NULL,1),(2,2,'dutch','NL','N',NULL,2),(3,3,'french','FR','N',NULL,3),(4,4,'german','DE','N',NULL,4),(5,5,'italian','IT','N',NULL,5),(6,6,'spanish','ES','N',NULL,6),(7,7,'danish','DK','N',NULL,7),(8,8,'russian','RU','N',NULL,8),(9,9,'us english','US','N',NULL,9),(10,10,'brazilian-portuguese','BR','N',NULL,10),(11,11,'portuguese','PT','N',NULL,11),(12,12,'chinese','ZH','N',NULL,12),(13,13,'swedish','SV','N',NULL,13),(14,14,'polish','PL','N',NULL,14),(15,15,'czech','CZ','N',NULL,15),(16,16,'hungarian','HU','N',NULL,16),(17,17,'finnish','FI','N',NULL,17),(18,18,'greek','EL','N',NULL,18),(19,19,'norwegian','NO','N',NULL,19),(20,20,'turkish','TR','N',NULL,20),(21,21,'bulgarian','BG','N',NULL,21),(22,22,'georgian','KA','N',NULL,22),(23,23,'romanian','RO','N',NULL,23),(24,24,'serbian','SR','N',NULL,24),(25,25,'ukrainian','UK','N',NULL,25),(26,26,'japanese','JA','N',NULL,26),(27,27,'catalan','CA','N',NULL,27),(28,28,'argentinian-spanish','ES_AR','N',NULL,28),(29,29,'croatian','HR','N',NULL,29),(30,30,'arabic','AR','N',NULL,30),(31,31,'vietnamese','VI','N',NULL,31),(32,32,'korean','KO','N',NULL,32),(33,33,'macedonian','MK','N',NULL,33),(34,34,'slovenian','SL','N',NULL,34),(35,35,'singapore-english','EN_SG','N',NULL,35),(36,36,'south africa-english','EN_ZA','N',NULL,36),(37,37,'traditional chinese','ZH_TW','N',NULL,37),(38,38,'hebrew','HE','N',NULL,38),(39,39,'lithuanian','LT','N',NULL,39),(40,40,'latvian','LV','N',NULL,40);
/*!40000 ALTER TABLE `language` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `language_blacklist`
--

DROP TABLE IF EXISTS `language_blacklist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `language_blacklist` (
  `language_blacklist_id` int(13) NOT NULL AUTO_INCREMENT,
  `langid` int(3) NOT NULL,
  `value` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`language_blacklist_id`),
  KEY `langid` (`langid`,`value`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `language_blacklist`
--

LOCK TABLES `language_blacklist` WRITE;
/*!40000 ALTER TABLE `language_blacklist` DISABLE KEYS */;
/*!40000 ALTER TABLE `language_blacklist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mail_dispatch`
--

DROP TABLE IF EXISTS `mail_dispatch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mail_dispatch` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `subject` varchar(255) NOT NULL DEFAULT '',
  `plain_body` mediumtext,
  `html_body` mediumtext,
  `to_groups` mediumtext NOT NULL,
  `to_emails` mediumtext NOT NULL,
  `single_email` varchar(70) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  `date_queued` int(17) NOT NULL DEFAULT '0',
  `date_delivered` int(17) NOT NULL DEFAULT '0',
  `message_type` tinyint(2) NOT NULL DEFAULT '0',
  `attachment_name` varchar(255) DEFAULT NULL,
  `attachment_content_type` varchar(255) DEFAULT NULL,
  `attachment_body` mediumblob,
  `status` tinyint(2) NOT NULL DEFAULT '0',
  `salutation` varchar(255) NOT NULL DEFAULT '',
  `footer` text,
  `sent_emails` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mail_dispatch`
--

LOCK TABLES `mail_dispatch` WRITE;
/*!40000 ALTER TABLE `mail_dispatch` DISABLE KEYS */;
/*!40000 ALTER TABLE `mail_dispatch` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `measure`
--

DROP TABLE IF EXISTS `measure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `measure` (
  `measure_id` int(13) NOT NULL AUTO_INCREMENT,
  `sid` int(13) NOT NULL DEFAULT '0',
  `tid` int(13) NOT NULL DEFAULT '0',
  `sign` varchar(255) DEFAULT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_published` int(14) DEFAULT '0',
  `system_of_measurement` enum('metric','imperial') NOT NULL DEFAULT 'metric',
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`measure_id`),
  UNIQUE KEY `icecat_id` (`icecat_id`),
  KEY `sid` (`sid`),
  KEY `tid` (`tid`),
  KEY `updated` (`updated`),
  KEY `last_published` (`last_published`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `measure`
--

LOCK TABLES `measure` WRITE;
/*!40000 ALTER TABLE `measure` DISABLE KEYS */;
/*!40000 ALTER TABLE `measure` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `measure_related`
--

DROP TABLE IF EXISTS `measure_related`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `measure_related` (
  `measure_related_id` int(13) NOT NULL AUTO_INCREMENT,
  `measure_id` int(13) NOT NULL DEFAULT '0',
  `related_measure_id` int(13) NOT NULL DEFAULT '0',
  `factor` decimal(18,10) NOT NULL DEFAULT '0.0000000000',
  `term` decimal(8,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`measure_related_id`),
  UNIQUE KEY `measure_id` (`measure_id`,`related_measure_id`),
  KEY `related_measure_id` (`related_measure_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `measure_related`
--

LOCK TABLES `measure_related` WRITE;
/*!40000 ALTER TABLE `measure_related` DISABLE KEYS */;
/*!40000 ALTER TABLE `measure_related` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `measure_sign`
--

DROP TABLE IF EXISTS `measure_sign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `measure_sign` (
  `measure_sign_id` int(13) NOT NULL AUTO_INCREMENT,
  `measure_id` int(13) NOT NULL DEFAULT '0',
  `langid` int(13) NOT NULL DEFAULT '0',
  `value` varchar(255) NOT NULL DEFAULT '',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_published` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`measure_sign_id`),
  UNIQUE KEY `measure_id` (`measure_id`,`langid`),
  UNIQUE KEY `icecat_id` (`icecat_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `measure_sign`
--

LOCK TABLES `measure_sign` WRITE;
/*!40000 ALTER TABLE `measure_sign` DISABLE KEYS */;
/*!40000 ALTER TABLE `measure_sign` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `measure_value_regexp`
--

DROP TABLE IF EXISTS `measure_value_regexp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `measure_value_regexp` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `value_regexp_id` int(13) NOT NULL DEFAULT '0',
  `measure_id` int(13) NOT NULL DEFAULT '0',
  `no` int(13) NOT NULL DEFAULT '0',
  `active` char(1) NOT NULL DEFAULT 'N',
  PRIMARY KEY (`id`),
  KEY `measure_id` (`measure_id`,`no`),
  KEY `value_regexp_id` (`value_regexp_id`),
  KEY `active` (`active`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `measure_value_regexp`
--

LOCK TABLES `measure_value_regexp` WRITE;
/*!40000 ALTER TABLE `measure_value_regexp` DISABLE KEYS */;
/*!40000 ALTER TABLE `measure_value_regexp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `platform`
--

DROP TABLE IF EXISTS `platform`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `platform` (
  `platform_id` int(13) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`platform_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `platform`
--

LOCK TABLES `platform` WRITE;
/*!40000 ALTER TABLE `platform` DISABLE KEYS */;
/*!40000 ALTER TABLE `platform` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `process_class`
--

DROP TABLE IF EXISTS `process_class`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `process_class` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) NOT NULL DEFAULT '',
  `max_processes` int(3) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `process_class`
--

LOCK TABLES `process_class` WRITE;
/*!40000 ALTER TABLE `process_class` DISABLE KEYS */;
/*!40000 ALTER TABLE `process_class` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `process_queue`
--

DROP TABLE IF EXISTS `process_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `process_queue` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `process_class_id` int(13) NOT NULL DEFAULT '0',
  `command` char(100) NOT NULL DEFAULT '',
  `product_id` int(13) NOT NULL DEFAULT '0',
  `prio` int(2) NOT NULL DEFAULT '0',
  `queued_date` int(11) NOT NULL DEFAULT '0',
  `started_date` int(11) NOT NULL DEFAULT '0',
  `finished_date` int(11) NOT NULL DEFAULT '0',
  `process_status_id` int(2) NOT NULL DEFAULT '1',
  `pid` int(8) NOT NULL DEFAULT '0',
  `exit_code` int(3) NOT NULL DEFAULT '0',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `langid_list` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `process_class_id` (`process_class_id`,`command`,`product_id`,`langid_list`),
  KEY `product_id` (`product_id`),
  KEY `process_status_id_2` (`process_status_id`,`prio`),
  KEY `command` (`command`),
  KEY `langid_list` (`langid_list`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='InnoDB free: 0 kB';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `process_queue`
--

LOCK TABLES `process_queue` WRITE;
/*!40000 ALTER TABLE `process_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `process_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `process_status`
--

DROP TABLE IF EXISTS `process_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `process_status` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `process_status`
--

LOCK TABLES `process_status` WRITE;
/*!40000 ALTER TABLE `process_status` DISABLE KEYS */;
/*!40000 ALTER TABLE `process_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product` (
  `product_id` int(13) NOT NULL AUTO_INCREMENT,
  `supplier_id` int(13) NOT NULL DEFAULT '0',
  `prod_id` varchar(60) NOT NULL DEFAULT '',
  `catid` int(13) NOT NULL DEFAULT '0',
  `user_id` int(13) NOT NULL DEFAULT '1',
  `launch_date` int(17) DEFAULT NULL,
  `obsolence_date` int(17) DEFAULT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `low_pic` varchar(255) NOT NULL DEFAULT '',
  `high_pic` varchar(255) NOT NULL DEFAULT '',
  `publish` char(1) NOT NULL DEFAULT 'N',
  `public` char(1) NOT NULL DEFAULT 'Y',
  `thumb_pic` varchar(255) DEFAULT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `date_added` date NOT NULL DEFAULT '0000-00-00',
  `family_id` int(13) NOT NULL DEFAULT '0',
  `dname` varchar(255) NOT NULL DEFAULT '',
  `topseller` varchar(255) NOT NULL DEFAULT '',
  `low_pic_size` int(13) DEFAULT '0',
  `high_pic_size` int(13) DEFAULT '0',
  `thumb_pic_size` int(13) DEFAULT '0',
  `high_pic_width` int(13) NOT NULL DEFAULT '0',
  `high_pic_height` int(13) NOT NULL DEFAULT '0',
  `low_pic_width` int(13) NOT NULL DEFAULT '0',
  `low_pic_height` int(13) NOT NULL DEFAULT '0',
  `high_pic_origin` varchar(255) NOT NULL DEFAULT '',
  `icecat_id` int(13) DEFAULT NULL,
  `series_id` int(17) NOT NULL DEFAULT '1',
  `checked_by_supereditor` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`product_id`),
  UNIQUE KEY `prod_id_2` (`prod_id`,`supplier_id`),
  KEY `user_id` (`user_id`),
  KEY `date_added` (`date_added`),
  KEY `name` (`name`),
  KEY `supplier_id_2` (`supplier_id`,`catid`),
  KEY `publish` (`publish`,`public`),
  KEY `catid` (`catid`,`updated`),
  KEY `updated` (`updated`),
  KEY `icecat_id` (`icecat_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_active`
--

DROP TABLE IF EXISTS `product_active`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_active` (
  `product_id` int(13) NOT NULL DEFAULT '0',
  `active` int(1) NOT NULL DEFAULT '0',
  `stock` int(13) NOT NULL DEFAULT '0',
  KEY `product_id` (`product_id`,`active`),
  KEY `active` (`active`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_active`
--

LOCK TABLES `product_active` WRITE;
/*!40000 ALTER TABLE `product_active` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_active` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_award`
--

DROP TABLE IF EXISTS `product_award`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_award` (
  `product_award_id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `award_group` varchar(60) NOT NULL DEFAULT '',
  `award_code` varchar(60) NOT NULL DEFAULT '',
  `award_name` varchar(120) NOT NULL DEFAULT '',
  `high_award_url` varchar(255) NOT NULL DEFAULT '',
  `low_award_url` varchar(255) NOT NULL DEFAULT '',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_award_id`),
  UNIQUE KEY `product_id` (`product_id`,`award_code`),
  KEY `award_group` (`award_group`,`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_award`
--

LOCK TABLES `product_award` WRITE;
/*!40000 ALTER TABLE `product_award` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_award` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_bullet`
--

DROP TABLE IF EXISTS `product_bullet`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_bullet` (
  `product_bullet_id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `product_bullet_group_id` int(13) NOT NULL DEFAULT '0',
  `code` varchar(255) NOT NULL DEFAULT '',
  `langid` int(5) NOT NULL DEFAULT '0',
  `value` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`product_bullet_id`),
  KEY `product_id_2` (`product_id`,`langid`),
  KEY `product_bullet_group_id` (`product_bullet_group_id`),
  KEY `code` (`code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_bullet`
--

LOCK TABLES `product_bullet` WRITE;
/*!40000 ALTER TABLE `product_bullet` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_bullet` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_bullet_group`
--

DROP TABLE IF EXISTS `product_bullet_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_bullet_group` (
  `product_bullet_group_id` int(13) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) NOT NULL DEFAULT '',
  `langid` int(5) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`product_bullet_group_id`),
  KEY `code` (`code`),
  KEY `product_bullet_group_id` (`product_bullet_group_id`,`langid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_bullet_group`
--

LOCK TABLES `product_bullet_group` WRITE;
/*!40000 ALTER TABLE `product_bullet_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_bullet_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_bundled`
--

DROP TABLE IF EXISTS `product_bundled`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_bundled` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `bndl_product_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_id` (`product_id`,`bndl_product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_bundled`
--

LOCK TABLES `product_bundled` WRITE;
/*!40000 ALTER TABLE `product_bundled` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_bundled` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_complaint`
--

DROP TABLE IF EXISTS `product_complaint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_complaint` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `supplier_id` int(13) NOT NULL DEFAULT '0',
  `prod_id` varchar(235) NOT NULL DEFAULT '',
  `user_id` int(13) NOT NULL DEFAULT '0',
  `fuser_id` int(13) NOT NULL DEFAULT '0',
  `message` mediumtext,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `complaint_status_id` tinyint(2) DEFAULT '0',
  `email` varchar(255) DEFAULT '',
  `name` varchar(255) DEFAULT '',
  `subject` varchar(255) DEFAULT NULL,
  `company` varchar(255) NOT NULL DEFAULT '',
  `internal` tinyint(2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `supplier_id` (`supplier_id`),
  KEY `product_id` (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_complaint`
--

LOCK TABLES `product_complaint` WRITE;
/*!40000 ALTER TABLE `product_complaint` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_complaint` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_complaint_history`
--

DROP TABLE IF EXISTS `product_complaint_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_complaint_history` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `complaint_id` int(13) NOT NULL DEFAULT '0',
  `complaint_status_id` tinyint(2) DEFAULT '0',
  `user_id` int(13) NOT NULL DEFAULT '0',
  `message` mediumtext,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `complaint_id` (`complaint_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_complaint_history`
--

LOCK TABLES `product_complaint_history` WRITE;
/*!40000 ALTER TABLE `product_complaint_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_complaint_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_complaint_status`
--

DROP TABLE IF EXISTS `product_complaint_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_complaint_status` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `code` tinyint(2) DEFAULT '0',
  `sid` int(13) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_complaint_status`
--

LOCK TABLES `product_complaint_status` WRITE;
/*!40000 ALTER TABLE `product_complaint_status` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_complaint_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_csv`
--

DROP TABLE IF EXISTS `product_csv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_csv` (
  `product_id` int(13) NOT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `quality` varchar(10) DEFAULT NULL,
  `supplier_id` int(13) DEFAULT NULL,
  `prod_id` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_csv`
--

LOCK TABLES `product_csv` WRITE;
/*!40000 ALTER TABLE `product_csv` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_csv` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_deleted`
--

DROP TABLE IF EXISTS `product_deleted`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_deleted` (
  `product_id` int(13) NOT NULL,
  `del_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `catid` int(13) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL,
  `supplier_id` int(13) NOT NULL DEFAULT '0',
  `user_id` int(13) NOT NULL DEFAULT '0',
  `prod_id` varchar(235) NOT NULL DEFAULT '',
  `map_product_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`product_id`),
  KEY `del_time` (`del_time`),
  KEY `supplier_id` (`supplier_id`),
  KEY `map_product_id` (`map_product_id`,`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_deleted`
--

LOCK TABLES `product_deleted` WRITE;
/*!40000 ALTER TABLE `product_deleted` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_deleted` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_description`
--

DROP TABLE IF EXISTS `product_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_description` (
  `product_description_id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `langid` int(13) NOT NULL DEFAULT '0',
  `short_desc` varchar(3000) NOT NULL DEFAULT '',
  `long_desc` mediumtext NOT NULL,
  `specs_url` varchar(255) NOT NULL DEFAULT '',
  `support_url` varchar(255) NOT NULL DEFAULT '',
  `official_url` varchar(255) NOT NULL DEFAULT '',
  `warranty_info` mediumtext,
  `option_field_1` mediumtext,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `pdf_url` varchar(255) NOT NULL DEFAULT '',
  `option_field_2` mediumtext,
  `pdf_size` int(13) DEFAULT '0',
  `manual_pdf_url` varchar(255) NOT NULL DEFAULT '',
  `manual_pdf_size` int(13) DEFAULT '0',
  `pdf_url_origin` varchar(255) NOT NULL DEFAULT '',
  `manual_pdf_url_origin` varchar(255) NOT NULL DEFAULT '',
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`product_description_id`),
  UNIQUE KEY `product_id` (`product_id`,`langid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_description`
--

LOCK TABLES `product_description` WRITE;
/*!40000 ALTER TABLE `product_description` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_description` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_description_reverse`
--

DROP TABLE IF EXISTS `product_description_reverse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_description_reverse` (
  `product_description_id` int(13) NOT NULL,
  `pdf_url` varchar(255) NOT NULL DEFAULT '',
  `manual_pdf_url` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`product_description_id`),
  KEY `pdf_url` (`pdf_url`),
  KEY `manual_pdf_url` (`manual_pdf_url`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_description_reverse`
--

LOCK TABLES `product_description_reverse` WRITE;
/*!40000 ALTER TABLE `product_description_reverse` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_description_reverse` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_ean_codes`
--

DROP TABLE IF EXISTS `product_ean_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_ean_codes` (
  `ean_id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `ean_code` char(13) NOT NULL DEFAULT '',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ean_id`),
  UNIQUE KEY `ean_code` (`ean_code`),
  KEY `product_id` (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_ean_codes`
--

LOCK TABLES `product_ean_codes` WRITE;
/*!40000 ALTER TABLE `product_ean_codes` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_ean_codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_family`
--

DROP TABLE IF EXISTS `product_family`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_family` (
  `family_id` int(17) NOT NULL AUTO_INCREMENT,
  `parent_family_id` int(17) NOT NULL DEFAULT '1',
  `supplier_id` int(17) NOT NULL DEFAULT '0',
  `sid` int(13) NOT NULL DEFAULT '0',
  `tid` int(13) NOT NULL DEFAULT '0',
  `low_pic` varchar(255) DEFAULT NULL,
  `thumb_pic` varchar(255) DEFAULT NULL,
  `catid` int(13) NOT NULL DEFAULT '0',
  `data_source_id` int(13) NOT NULL DEFAULT '0',
  `symbol` varchar(120) NOT NULL DEFAULT '',
  `icecat_id` int(17) DEFAULT NULL,
  PRIMARY KEY (`family_id`),
  UNIQUE KEY `icecat_id` (`icecat_id`),
  KEY `supplier_id_3` (`supplier_id`,`sid`),
  KEY `sid` (`sid`,`supplier_id`),
  KEY `supplier_id` (`supplier_id`,`catid`,`data_source_id`),
  KEY `symbol` (`symbol`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_family`
--

LOCK TABLES `product_family` WRITE;
/*!40000 ALTER TABLE `product_family` DISABLE KEYS */;
INSERT INTO `product_family` VALUES (1,0,0,0,0,NULL,NULL,0,0,'',NULL);
/*!40000 ALTER TABLE `product_family` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_family_reverse`
--

DROP TABLE IF EXISTS `product_family_reverse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_family_reverse` (
  `family_id` int(17) NOT NULL,
  `low_pic` varchar(255) DEFAULT NULL,
  `thumb_pic` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`family_id`),
  KEY `low_pic` (`low_pic`),
  KEY `thumb_pic` (`thumb_pic`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_family_reverse`
--

LOCK TABLES `product_family_reverse` WRITE;
/*!40000 ALTER TABLE `product_family_reverse` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_family_reverse` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_feature`
--

DROP TABLE IF EXISTS `product_feature`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_feature` (
  `product_feature_id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `category_feature_id` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `value` varchar(20000) NOT NULL DEFAULT '',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`product_feature_id`),
  UNIQUE KEY `category_feature_id_2` (`category_feature_id`,`product_id`),
  KEY `product_id` (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_feature`
--

LOCK TABLES `product_feature` WRITE;
/*!40000 ALTER TABLE `product_feature` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_feature` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_feature_local`
--

DROP TABLE IF EXISTS `product_feature_local`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_feature_local` (
  `product_feature_local_id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `category_feature_id` int(13) NOT NULL DEFAULT '0',
  `value` varchar(15000) NOT NULL DEFAULT '',
  `langid` int(5) NOT NULL DEFAULT '0',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`product_feature_local_id`),
  UNIQUE KEY `category_feature_id` (`category_feature_id`,`product_id`,`langid`),
  KEY `product_id` (`product_id`,`langid`),
  KEY `langid` (`langid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_feature_local`
--

LOCK TABLES `product_feature_local` WRITE;
/*!40000 ALTER TABLE `product_feature_local` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_feature_local` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_gallery`
--

DROP TABLE IF EXISTS `product_gallery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_gallery` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `link` varchar(255) NOT NULL DEFAULT '',
  `thumb_link` varchar(255) NOT NULL DEFAULT '',
  `height` int(10) NOT NULL DEFAULT '0',
  `width` int(10) NOT NULL DEFAULT '0',
  `size` int(15) NOT NULL DEFAULT '0',
  `quality` tinyint(2) DEFAULT '0',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `thumb_size` int(15) NOT NULL DEFAULT '0',
  `link_origin` varchar(255) NOT NULL DEFAULT '',
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_id_2` (`product_id`,`link`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_gallery`
--

LOCK TABLES `product_gallery` WRITE;
/*!40000 ALTER TABLE `product_gallery` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_gallery` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_gallery_imported`
--

DROP TABLE IF EXISTS `product_gallery_imported`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_gallery_imported` (
  `product_gallery_imported_id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `type` varchar(60) NOT NULL DEFAULT '',
  `content_length` int(13) NOT NULL DEFAULT '0',
  `data_source_id` int(13) NOT NULL DEFAULT '0',
  `product_gallery_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`product_gallery_imported_id`),
  UNIQUE KEY `product_id` (`product_id`,`type`),
  KEY `data_source_id` (`data_source_id`),
  KEY `product_gallery_id` (`product_gallery_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_gallery_imported`
--

LOCK TABLES `product_gallery_imported` WRITE;
/*!40000 ALTER TABLE `product_gallery_imported` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_gallery_imported` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_gallery_reverse`
--

DROP TABLE IF EXISTS `product_gallery_reverse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_gallery_reverse` (
  `id` int(13) NOT NULL,
  `link` varchar(255) NOT NULL DEFAULT '',
  `thumb_link` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `link` (`link`),
  KEY `thumb_link` (`thumb_link`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_gallery_reverse`
--

LOCK TABLES `product_gallery_reverse` WRITE;
/*!40000 ALTER TABLE `product_gallery_reverse` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_gallery_reverse` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_html_key`
--

DROP TABLE IF EXISTS `product_html_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_html_key` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `user_id` int(13) NOT NULL DEFAULT '0',
  `product_id` int(13) NOT NULL DEFAULT '0',
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `html_key` varchar(255) NOT NULL DEFAULT '',
  `action` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_html_key`
--

LOCK TABLES `product_html_key` WRITE;
/*!40000 ALTER TABLE `product_html_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_html_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_index_cache`
--

DROP TABLE IF EXISTS `product_index_cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_index_cache` (
  `product_index_cache_id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `xml_info` mediumtext,
  `csv_info` mediumtext,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_index_cache_id`),
  KEY `product_id` (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_index_cache`
--

LOCK TABLES `product_index_cache` WRITE;
/*!40000 ALTER TABLE `product_index_cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_index_cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_interest_score`
--

DROP TABLE IF EXISTS `product_interest_score`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_interest_score` (
  `product_id` int(13) NOT NULL DEFAULT '0',
  `product_requested` int(10) DEFAULT NULL,
  `describe_requests` int(10) DEFAULT NULL,
  `score` int(10) DEFAULT NULL,
  `status` tinyint(1) DEFAULT '0',
  `responsible_user_id` int(5) DEFAULT NULL,
  `updated` int(17) DEFAULT NULL,
  `language_flag` int(13) NOT NULL DEFAULT '0',
  `name` varchar(255) DEFAULT NULL,
  `prod_id` varchar(235) DEFAULT NULL,
  `catid` int(13) DEFAULT NULL,
  `sid` int(13) DEFAULT NULL,
  `user_id` int(13) DEFAULT NULL,
  `supplier` varchar(255) DEFAULT NULL,
  `supplier_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`product_id`),
  KEY `score` (`score`),
  KEY `product_id` (`product_id`,`score`),
  KEY `status_2` (`status`,`score`),
  KEY `product_id_2` (`product_id`,`status`),
  KEY `catid` (`catid`),
  KEY `supplier` (`supplier`),
  KEY `name` (`name`),
  KEY `status2` (`status`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_interest_score`
--

LOCK TABLES `product_interest_score` WRITE;
/*!40000 ALTER TABLE `product_interest_score` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_interest_score` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_local`
--

DROP TABLE IF EXISTS `product_local`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_local` (
  `product_local_id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `product_id_local` int(13) NOT NULL DEFAULT '0',
  `supplier_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`product_local_id`),
  UNIQUE KEY `product_id` (`product_id`,`product_id_local`),
  KEY `product_id_local` (`product_id_local`),
  KEY `supplier_id` (`supplier_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_local`
--

LOCK TABLES `product_local` WRITE;
/*!40000 ALTER TABLE `product_local` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_local` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_map`
--

DROP TABLE IF EXISTS `product_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_map` (
  `product_map_id` int(13) NOT NULL AUTO_INCREMENT,
  `pattern` mediumtext NOT NULL,
  `code` varchar(255) NOT NULL DEFAULT '',
  `supplier_id` int(13) NOT NULL DEFAULT '0',
  `map_supplier_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`product_map_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_map`
--

LOCK TABLES `product_map` WRITE;
/*!40000 ALTER TABLE `product_map` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_map` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_modification_time`
--

DROP TABLE IF EXISTS `product_modification_time`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_modification_time` (
  `product_id` int(13) NOT NULL DEFAULT '0',
  `modification_time` int(13) NOT NULL DEFAULT '0',
  `picture_content_length` int(13) NOT NULL DEFAULT '0',
  `picture_high_md5_checksum` char(32) DEFAULT NULL,
  `picture_low_md5_checksum` char(32) DEFAULT NULL,
  PRIMARY KEY (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_modification_time`
--

LOCK TABLES `product_modification_time` WRITE;
/*!40000 ALTER TABLE `product_modification_time` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_modification_time` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_multimedia_object`
--

DROP TABLE IF EXISTS `product_multimedia_object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_multimedia_object` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `link` varchar(255) NOT NULL DEFAULT '',
  `short_descr` mediumtext NOT NULL,
  `langid` int(13) NOT NULL DEFAULT '0',
  `size` int(15) NOT NULL DEFAULT '0',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `content_type` varchar(255) NOT NULL DEFAULT '',
  `keep_as_url` int(1) NOT NULL DEFAULT '0',
  `type` varchar(255) NOT NULL DEFAULT 'standard',
  `height` int(13) NOT NULL DEFAULT '0',
  `width` int(13) NOT NULL DEFAULT '0',
  `data_source_id` int(13) NOT NULL DEFAULT '0',
  `link_origin` varchar(255) NOT NULL DEFAULT '',
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `data_source_id` (`data_source_id`,`product_id`),
  KEY `type` (`type`),
  KEY `product_id` (`product_id`,`updated`),
  KEY `product_id_2` (`product_id`,`langid`),
  KEY `icecat_id` (`icecat_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_multimedia_object`
--

LOCK TABLES `product_multimedia_object` WRITE;
/*!40000 ALTER TABLE `product_multimedia_object` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_multimedia_object` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_multimedia_object_reverse`
--

DROP TABLE IF EXISTS `product_multimedia_object_reverse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_multimedia_object_reverse` (
  `id` int(13) NOT NULL,
  `link` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `link` (`link`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_multimedia_object_reverse`
--

LOCK TABLES `product_multimedia_object_reverse` WRITE;
/*!40000 ALTER TABLE `product_multimedia_object_reverse` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_multimedia_object_reverse` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_name`
--

DROP TABLE IF EXISTS `product_name`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_name` (
  `product_name_id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `langid` int(5) NOT NULL DEFAULT '0',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_name_id`),
  KEY `product_id2` (`product_id`,`langid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_name`
--

LOCK TABLES `product_name` WRITE;
/*!40000 ALTER TABLE `product_name` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_name` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_original_data`
--

DROP TABLE IF EXISTS `product_original_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_original_data` (
  `product_original_data_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(13) DEFAULT NULL,
  `distributor_id` int(13) DEFAULT NULL,
  `original_prodid` varchar(255) DEFAULT NULL,
  `original_cat` varchar(255) DEFAULT NULL,
  `original_vendor` varchar(255) DEFAULT NULL,
  `original_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`product_original_data_id`),
  UNIQUE KEY `distributor_id` (`distributor_id`,`product_id`),
  KEY `product_id` (`product_id`),
  KEY `product_original_data_id` (`product_original_data_id`,`product_id`,`distributor_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_original_data`
--

LOCK TABLES `product_original_data` WRITE;
/*!40000 ALTER TABLE `product_original_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_original_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_pim`
--

DROP TABLE IF EXISTS `product_pim`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_pim` (
  `product_pim_id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL,
  `langid` smallint(6) NOT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`product_pim_id`),
  UNIQUE KEY `product_id` (`product_id`,`langid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_pim`
--

LOCK TABLES `product_pim` WRITE;
/*!40000 ALTER TABLE `product_pim` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_pim` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_price`
--

DROP TABLE IF EXISTS `product_price`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_price` (
  `product_id` int(13) NOT NULL AUTO_INCREMENT,
  `price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `stock` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_price`
--

LOCK TABLES `product_price` WRITE;
/*!40000 ALTER TABLE `product_price` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_price` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_related`
--

DROP TABLE IF EXISTS `product_related`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_related` (
  `product_related_id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `rel_product_id` int(13) NOT NULL DEFAULT '0',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `preferred_option` tinyint(1) NOT NULL DEFAULT '0',
  `data_source_id` int(13) NOT NULL DEFAULT '0',
  `compatible` int(1) NOT NULL DEFAULT '0',
  `order` smallint(5) unsigned NOT NULL DEFAULT '65535',
  PRIMARY KEY (`product_related_id`),
  UNIQUE KEY `product_id` (`product_id`,`rel_product_id`),
  KEY `rel_product_id` (`rel_product_id`),
  KEY `data_source_id` (`data_source_id`,`product_id`,`rel_product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_related`
--

LOCK TABLES `product_related` WRITE;
/*!40000 ALTER TABLE `product_related` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_related` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_restrictions`
--

DROP TABLE IF EXISTS `product_restrictions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_restrictions` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `supplier_id` int(13) NOT NULL DEFAULT '0',
  `langid` int(13) NOT NULL DEFAULT '0',
  `subscription_level` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `supplier_id` (`supplier_id`,`langid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_restrictions`
--

LOCK TABLES `product_restrictions` WRITE;
/*!40000 ALTER TABLE `product_restrictions` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_restrictions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_restrictions_details`
--

DROP TABLE IF EXISTS `product_restrictions_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_restrictions_details` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `restriction_id` int(13) NOT NULL DEFAULT '0',
  `product_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `supplier_id` (`restriction_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_restrictions_details`
--

LOCK TABLES `product_restrictions_details` WRITE;
/*!40000 ALTER TABLE `product_restrictions_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_restrictions_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_reverse`
--

DROP TABLE IF EXISTS `product_reverse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_reverse` (
  `product_id` int(13) NOT NULL,
  `low_pic` varchar(255) NOT NULL DEFAULT '',
  `high_pic` varchar(255) NOT NULL DEFAULT '',
  `thumb_pic` varchar(255) DEFAULT '',
  PRIMARY KEY (`product_id`),
  KEY `low_pic` (`low_pic`),
  KEY `high_pic` (`high_pic`),
  KEY `thumb_pic` (`thumb_pic`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_reverse`
--

LOCK TABLES `product_reverse` WRITE;
/*!40000 ALTER TABLE `product_reverse` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_reverse` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_review`
--

DROP TABLE IF EXISTS `product_review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_review` (
  `product_review_id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `langid` int(13) NOT NULL DEFAULT '0',
  `review_group` varchar(60) NOT NULL DEFAULT '',
  `review_code` varchar(60) NOT NULL DEFAULT '',
  `review_id` int(13) NOT NULL DEFAULT '0',
  `score` int(13) NOT NULL DEFAULT '0',
  `url` varchar(255) NOT NULL DEFAULT '',
  `logo_url` varchar(255) NOT NULL DEFAULT '',
  `value` text,
  `value_good` text,
  `value_bad` text,
  `postscriptum` text,
  `review_award_name` varchar(120) NOT NULL DEFAULT '',
  `high_review_award_url` varchar(255) NOT NULL DEFAULT '',
  `low_review_award_url` varchar(255) NOT NULL DEFAULT '',
  `date_added` date DEFAULT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_review_id`),
  UNIQUE KEY `product_id` (`product_id`,`review_id`,`langid`),
  KEY `date_added` (`date_added`),
  KEY `review_group` (`review_group`,`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_review`
--

LOCK TABLES `product_review` WRITE;
/*!40000 ALTER TABLE `product_review` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_review` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_series`
--

DROP TABLE IF EXISTS `product_series`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_series` (
  `series_id` int(17) NOT NULL AUTO_INCREMENT,
  `sid` int(13) NOT NULL,
  `tid` int(13) NOT NULL,
  `supplier_id` int(17) NOT NULL,
  `catid` int(13) NOT NULL,
  `family_id` int(17) NOT NULL,
  PRIMARY KEY (`series_id`),
  KEY `sid` (`sid`),
  KEY `supplier_id` (`supplier_id`),
  KEY `family_id` (`family_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_series`
--

LOCK TABLES `product_series` WRITE;
/*!40000 ALTER TABLE `product_series` DISABLE KEYS */;
INSERT INTO `product_series` VALUES (1,0,0,0,0,0);
/*!40000 ALTER TABLE `product_series` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_statistic`
--

DROP TABLE IF EXISTS `product_statistic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_statistic` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `score` int(13) NOT NULL DEFAULT '0',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_statistic`
--

LOCK TABLES `product_statistic` WRITE;
/*!40000 ALTER TABLE `product_statistic` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_statistic` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_summary_description`
--

DROP TABLE IF EXISTS `product_summary_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_summary_description` (
  `product_summary_description_id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `langid` int(5) NOT NULL DEFAULT '0',
  `short_summary_description` text,
  `long_summary_description` text,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`product_summary_description_id`),
  UNIQUE KEY `product_id` (`product_id`,`langid`),
  KEY `langid` (`langid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_summary_description`
--

LOCK TABLES `product_summary_description` WRITE;
/*!40000 ALTER TABLE `product_summary_description` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_summary_description` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_xmlfeature_cache`
--

DROP TABLE IF EXISTS `product_xmlfeature_cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_xmlfeature_cache` (
  `feature_id` int(13) DEFAULT NULL,
  `xmlfeature_chunk` longtext,
  `langid` int(3) NOT NULL DEFAULT '1',
  `updated` int(14) DEFAULT NULL,
  UNIQUE KEY `feat_lang` (`feature_id`,`langid`),
  KEY `feature_id` (`feature_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_xmlfeature_cache`
--

LOCK TABLES `product_xmlfeature_cache` WRITE;
/*!40000 ALTER TABLE `product_xmlfeature_cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_xmlfeature_cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `relation`
--

DROP TABLE IF EXISTS `relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relation` (
  `relation_id` int(13) NOT NULL AUTO_INCREMENT,
  `relation_group_id` int(13) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `include_set_id` int(13) NOT NULL DEFAULT '0',
  `exclude_set_id` int(13) NOT NULL DEFAULT '0',
  `include_set_id_2` int(13) NOT NULL DEFAULT '0',
  `exclude_set_id_2` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`relation_id`),
  KEY `relation_group_id` (`relation_group_id`),
  KEY `include_set_id` (`include_set_id`),
  KEY `exclude_set_id` (`exclude_set_id`),
  KEY `include_set_id_2` (`include_set_id_2`),
  KEY `exclude_set_id_2` (`exclude_set_id_2`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `relation`
--

LOCK TABLES `relation` WRITE;
/*!40000 ALTER TABLE `relation` DISABLE KEYS */;
/*!40000 ALTER TABLE `relation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `relation_exact_values`
--

DROP TABLE IF EXISTS `relation_exact_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relation_exact_values` (
  `exact_value` tinyint(1) NOT NULL AUTO_INCREMENT,
  `exact_value_text` varchar(60) NOT NULL DEFAULT '',
  PRIMARY KEY (`exact_value`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `relation_exact_values`
--

LOCK TABLES `relation_exact_values` WRITE;
/*!40000 ALTER TABLE `relation_exact_values` DISABLE KEYS */;
/*!40000 ALTER TABLE `relation_exact_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `relation_group`
--

DROP TABLE IF EXISTS `relation_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relation_group` (
  `relation_group_id` int(13) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`relation_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `relation_group`
--

LOCK TABLES `relation_group` WRITE;
/*!40000 ALTER TABLE `relation_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `relation_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `relation_rule`
--

DROP TABLE IF EXISTS `relation_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relation_rule` (
  `relation_rule_id` int(13) NOT NULL AUTO_INCREMENT,
  `supplier_id` int(13) NOT NULL DEFAULT '0',
  `supplier_family_id` int(13) NOT NULL DEFAULT '0',
  `catid` int(13) NOT NULL DEFAULT '0',
  `feature_id` int(13) NOT NULL DEFAULT '0',
  `feature_value` varchar(255) NOT NULL DEFAULT '',
  `exact_value` tinyint(1) NOT NULL DEFAULT '1',
  `prod_id` varchar(60) NOT NULL DEFAULT '',
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `end_date` date NOT NULL DEFAULT '0000-00-00',
  PRIMARY KEY (`relation_rule_id`),
  KEY `supplier_id` (`supplier_id`,`catid`,`feature_id`,`feature_value`),
  KEY `catid` (`catid`,`feature_id`),
  KEY `feature_id` (`feature_id`,`feature_value`),
  KEY `feature_value` (`feature_value`),
  KEY `prod_id` (`prod_id`),
  KEY `exact_value` (`exact_value`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `relation_rule`
--

LOCK TABLES `relation_rule` WRITE;
/*!40000 ALTER TABLE `relation_rule` DISABLE KEYS */;
/*!40000 ALTER TABLE `relation_rule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `relation_set`
--

DROP TABLE IF EXISTS `relation_set`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relation_set` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `relation_set_id` int(13) NOT NULL DEFAULT '0',
  `relation_rule_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `relation_set_id` (`relation_set_id`,`relation_rule_id`),
  KEY `relation_rule_id` (`relation_rule_id`,`relation_set_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `relation_set`
--

LOCK TABLES `relation_set` WRITE;
/*!40000 ALTER TABLE `relation_set` DISABLE KEYS */;
/*!40000 ALTER TABLE `relation_set` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_type`
--

DROP TABLE IF EXISTS `report_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_type` (
  `report_type_id` int(3) NOT NULL AUTO_INCREMENT,
  `description` mediumtext,
  `report_type` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`report_type_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_type`
--

LOCK TABLES `report_type` WRITE;
/*!40000 ALTER TABLE `report_type` DISABLE KEYS */;
/*!40000 ALTER TABLE `report_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `request`
--

DROP TABLE IF EXISTS `request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request` (
  `request_id` int(13) NOT NULL AUTO_INCREMENT,
  `user_id` int(13) NOT NULL DEFAULT '0',
  `ext_request_id` varchar(255) DEFAULT NULL,
  `login` varchar(255) DEFAULT NULL,
  `status` int(3) DEFAULT NULL,
  `ip` varchar(255) DEFAULT NULL,
  `date` int(17) NOT NULL DEFAULT '0',
  PRIMARY KEY (`request_id`),
  KEY `date` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `request`
--

LOCK TABLES `request` WRITE;
/*!40000 ALTER TABLE `request` DISABLE KEYS */;
/*!40000 ALTER TABLE `request` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `request_history`
--

DROP TABLE IF EXISTS `request_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_history` (
  `login` char(40) NOT NULL,
  `password` enum('Y','N') NOT NULL DEFAULT 'N',
  `ip` char(15) NOT NULL,
  `url` varchar(255) NOT NULL,
  `date` int(13) NOT NULL,
  KEY `login` (`login`),
  KEY `ip` (`ip`),
  KEY `date` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `request_history`
--

LOCK TABLES `request_history` WRITE;
/*!40000 ALTER TABLE `request_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `request_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `request_product`
--

DROP TABLE IF EXISTS `request_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_product` (
  `request_product_id` int(13) NOT NULL AUTO_INCREMENT,
  `request_id` int(13) NOT NULL DEFAULT '0',
  `rproduct_id` int(13) NOT NULL DEFAULT '0',
  `rprod_id` varchar(255) DEFAULT NULL,
  `rsupplier_id` varchar(255) DEFAULT NULL,
  `rsupplier_name` varchar(255) DEFAULT NULL,
  `product_found` char(3) DEFAULT NULL,
  `code` int(3) DEFAULT NULL,
  `date` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`request_product_id`),
  KEY `request_id` (`request_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `request_product`
--

LOCK TABLES `request_product` WRITE;
/*!40000 ALTER TABLE `request_product` DISABLE KEYS */;
/*!40000 ALTER TABLE `request_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `request_repository`
--

DROP TABLE IF EXISTS `request_repository`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_repository` (
  `request_repository_id` int(13) NOT NULL AUTO_INCREMENT,
  `date` int(13) NOT NULL DEFAULT '0',
  `user_id` int(13) NOT NULL DEFAULT '0',
  `product_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`request_repository_id`),
  KEY `date` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `request_repository`
--

LOCK TABLES `request_repository` WRITE;
/*!40000 ALTER TABLE `request_repository` DISABLE KEYS */;
/*!40000 ALTER TABLE `request_repository` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sector`
--

DROP TABLE IF EXISTS `sector`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sector` (
  `sector_id` int(13) NOT NULL AUTO_INCREMENT,
  `dummy` char(1) DEFAULT NULL,
  PRIMARY KEY (`sector_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sector`
--

LOCK TABLES `sector` WRITE;
/*!40000 ALTER TABLE `sector` DISABLE KEYS */;
/*!40000 ALTER TABLE `sector` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sector_name`
--

DROP TABLE IF EXISTS `sector_name`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sector_name` (
  `sector_name_id` int(13) NOT NULL AUTO_INCREMENT,
  `sector_id` int(13) NOT NULL DEFAULT '0',
  `langid` int(5) NOT NULL DEFAULT '1',
  `name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`sector_name_id`),
  UNIQUE KEY `sector_id` (`sector_id`,`langid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sector_name`
--

LOCK TABLES `sector_name` WRITE;
/*!40000 ALTER TABLE `sector_name` DISABLE KEYS */;
/*!40000 ALTER TABLE `sector_name` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `session`
--

DROP TABLE IF EXISTS `session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `session` (
  `sessid` int(13) NOT NULL AUTO_INCREMENT,
  `code` char(48) NOT NULL DEFAULT '',
  `updated` int(17) DEFAULT NULL,
  PRIMARY KEY (`sessid`),
  UNIQUE KEY `code` (`code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `session`
--

LOCK TABLES `session` WRITE;
/*!40000 ALTER TABLE `session` DISABLE KEYS */;
/*!40000 ALTER TABLE `session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sid_index`
--

DROP TABLE IF EXISTS `sid_index`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sid_index` (
  `sid` int(13) NOT NULL AUTO_INCREMENT,
  `dummy` int(1) DEFAULT NULL,
  PRIMARY KEY (`sid`)
) ENGINE=MyISAM AUTO_INCREMENT=227 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sid_index`
--

LOCK TABLES `sid_index` WRITE;
/*!40000 ALTER TABLE `sid_index` DISABLE KEYS */;
INSERT INTO `sid_index` VALUES (1,0),(2,0),(3,0),(4,0),(5,0),(6,0),(7,0),(8,0),(9,0),(10,0),(11,0),(12,0),(13,0),(14,0),(15,0),(16,0),(17,0),(18,0),(19,0),(20,0),(21,0),(22,0),(23,0),(24,0),(25,0),(26,0),(27,0),(28,0),(29,0),(30,0),(31,0),(32,0),(33,0),(34,0),(35,0),(36,0),(37,0),(38,0),(39,0),(40,0),(41,0),(42,0),(43,0),(44,0),(45,0),(46,0),(47,0),(48,0),(49,0),(50,0),(51,0),(52,0),(53,0),(54,0),(55,0),(56,0),(57,0),(58,0),(59,0),(60,0),(61,0),(62,0),(63,0),(64,0),(65,0),(66,0),(67,0),(68,0),(69,0),(70,0),(71,0),(72,0),(73,0),(74,0),(75,0),(76,0),(77,0),(78,0),(79,0),(80,0),(81,0),(82,0),(83,0),(84,0),(85,0),(86,0),(87,0),(88,0),(89,0),(90,0),(91,0),(92,0),(93,0),(94,0),(95,0),(96,0),(97,0),(98,0),(99,0),(100,0),(101,0),(102,0),(103,0),(104,0),(105,0),(106,0),(107,0),(108,0),(109,0),(110,0),(111,0),(112,0),(113,0),(114,0),(115,0),(116,0),(117,0),(118,0),(119,0),(120,0),(121,0),(122,0),(123,0),(124,0),(125,0),(126,0),(127,0),(128,0),(129,0),(130,0),(131,0),(132,0),(133,0),(134,0),(135,0),(136,0),(137,0),(138,0),(139,0),(140,0),(141,0),(142,0),(143,0),(144,0),(145,0),(146,0),(147,0),(148,0),(149,0),(150,0),(151,0),(152,0),(153,0),(154,0),(155,0),(156,0),(157,0),(158,0),(159,0),(160,0),(161,0),(162,0),(163,0),(164,0),(165,0),(166,0),(167,0),(168,0),(169,0),(170,0),(171,0),(172,0),(173,0),(174,0),(175,0),(176,0),(177,0),(178,0),(179,0),(180,0),(181,0),(182,0),(183,0),(184,0),(185,0),(186,0),(187,0),(188,0),(189,0),(190,0),(191,0),(192,0),(193,0),(194,0),(195,0),(196,0),(197,0),(198,0),(199,0),(200,0),(201,0),(202,0),(203,0),(204,0),(205,0),(206,0),(207,0),(208,0),(209,0),(210,0),(211,0),(212,0),(213,0),(214,0),(215,0),(216,0),(217,0),(218,0),(219,0),(220,0),(221,0),(222,0),(223,0),(224,0),(225,0),(226,0);
/*!40000 ALTER TABLE `sid_index` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stat_query`
--

DROP TABLE IF EXISTS `stat_query`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_query` (
  `stat_query_id` int(13) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) NOT NULL DEFAULT '',
  `period` int(3) NOT NULL DEFAULT '0',
  `supplier_id` int(13) NOT NULL DEFAULT '0',
  `catid` int(13) NOT NULL DEFAULT '0',
  `edit_user_id` int(13) NOT NULL DEFAULT '0',
  `request_user_id` int(13) NOT NULL DEFAULT '0',
  `subtotal_1` int(3) NOT NULL DEFAULT '0',
  `subtotal_2` int(3) NOT NULL DEFAULT '0',
  `subtotal_3` int(3) NOT NULL DEFAULT '0',
  `email` mediumtext,
  `mail_class_format` char(3) NOT NULL DEFAULT 'DSV',
  `request_partner_id` int(13) DEFAULT NULL,
  `request_country_id` int(13) DEFAULT NULL,
  `email_attachment_compression` varchar(5) NOT NULL DEFAULT 'gz',
  `product_distributor_id` int(13) NOT NULL DEFAULT '0',
  `product_country_id` int(13) NOT NULL DEFAULT '0',
  `product_onstock` tinyint(1) NOT NULL DEFAULT '0',
  `supplier_type` enum('','Y','N') NOT NULL DEFAULT '',
  `include_top_product` int(1) NOT NULL DEFAULT '1',
  `include_top_cats` int(1) NOT NULL DEFAULT '1',
  `include_top_owner` int(1) NOT NULL DEFAULT '0',
  `include_top_supplier` int(1) NOT NULL DEFAULT '0',
  `include_top_request_country` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`stat_query_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stat_query`
--

LOCK TABLES `stat_query` WRITE;
/*!40000 ALTER TABLE `stat_query` DISABLE KEYS */;
/*!40000 ALTER TABLE `stat_query` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_report`
--

DROP TABLE IF EXISTS `stock_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stock_report` (
  `stock_report_id` int(13) NOT NULL AUTO_INCREMENT,
  `supplier_id` int(13) NOT NULL DEFAULT '0',
  `mail_to` text,
  `mail_cc` varchar(255) NOT NULL DEFAULT '',
  `active` tinyint(1) NOT NULL DEFAULT '0',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `time` varchar(7) NOT NULL DEFAULT 'noon',
  PRIMARY KEY (`stock_report_id`),
  UNIQUE KEY `supplier_id` (`supplier_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_report`
--

LOCK TABLES `stock_report` WRITE;
/*!40000 ALTER TABLE `stock_report` DISABLE KEYS */;
/*!40000 ALTER TABLE `stock_report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscription_levels`
--

DROP TABLE IF EXISTS `subscription_levels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscription_levels` (
  `subscription_level` tinyint(2) NOT NULL DEFAULT '0',
  `value` varchar(12) NOT NULL DEFAULT 'None',
  PRIMARY KEY (`subscription_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscription_levels`
--

LOCK TABLES `subscription_levels` WRITE;
/*!40000 ALTER TABLE `subscription_levels` DISABLE KEYS */;
/*!40000 ALTER TABLE `subscription_levels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supplier`
--

DROP TABLE IF EXISTS `supplier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `supplier` (
  `supplier_id` int(13) NOT NULL AUTO_INCREMENT,
  `user_id` int(13) NOT NULL DEFAULT '1',
  `name` varchar(255) NOT NULL DEFAULT '',
  `low_pic` varchar(255) DEFAULT NULL,
  `thumb_pic` varchar(255) DEFAULT NULL,
  `acknowledge` char(1) NOT NULL DEFAULT 'N',
  `is_sponsor` char(1) NOT NULL DEFAULT 'N',
  `public_login` varchar(80) DEFAULT '',
  `public_password` varchar(80) DEFAULT '',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_published` int(14) DEFAULT '0',
  `ftp_homedir` varchar(255) DEFAULT NULL,
  `template` mediumtext,
  `folder_name` varchar(255) NOT NULL DEFAULT '',
  `suppress_offers` char(1) NOT NULL DEFAULT 'N',
  `last_name` varchar(255) NOT NULL DEFAULT '',
  `prod_id_regexp` text,
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`supplier_id`),
  UNIQUE KEY `icecat_id` (`icecat_id`),
  KEY `is_sponsor` (`is_sponsor`),
  KEY `name` (`name`),
  KEY `public_login` (`public_login`),
  KEY `folder_name` (`folder_name`),
  FULLTEXT KEY `fulltext_name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier`
--

LOCK TABLES `supplier` WRITE;
/*!40000 ALTER TABLE `supplier` DISABLE KEYS */;
/*!40000 ALTER TABLE `supplier` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supplier_contact`
--

DROP TABLE IF EXISTS `supplier_contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `supplier_contact` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `supplier_id` int(13) NOT NULL DEFAULT '0',
  `person` varchar(255) NOT NULL DEFAULT '',
  `company` varchar(255) DEFAULT NULL,
  `zip` varchar(80) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `telephone` varchar(255) DEFAULT NULL,
  `fax` varchar(255) DEFAULT NULL,
  `country_id` int(13) DEFAULT NULL,
  `email` varchar(255) NOT NULL DEFAULT '',
  `position` varchar(255) DEFAULT NULL,
  `default_manager` char(2) DEFAULT 'N',
  `use4mail` char(2) DEFAULT 'N',
  `interval_id` int(11) NOT NULL,
  `report_lang` int(2) NOT NULL DEFAULT '1',
  `report_format` varchar(10) NOT NULL DEFAULT 'html',
  PRIMARY KEY (`id`),
  KEY `supplier_id` (`supplier_id`),
  KEY `interval_id` (`interval_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier_contact`
--

LOCK TABLES `supplier_contact` WRITE;
/*!40000 ALTER TABLE `supplier_contact` DISABLE KEYS */;
/*!40000 ALTER TABLE `supplier_contact` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supplier_contact_category_family`
--

DROP TABLE IF EXISTS `supplier_contact_category_family`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `supplier_contact_category_family` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `catid` int(13) NOT NULL DEFAULT '1',
  `family_id` int(13) NOT NULL DEFAULT '1',
  `include_subcat` char(2) DEFAULT 'N',
  `include_subfamily` char(2) DEFAULT 'N',
  `contact_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `contact_id_2_2` (`contact_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier_contact_category_family`
--

LOCK TABLES `supplier_contact_category_family` WRITE;
/*!40000 ALTER TABLE `supplier_contact_category_family` DISABLE KEYS */;
/*!40000 ALTER TABLE `supplier_contact_category_family` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supplier_contact_report`
--

DROP TABLE IF EXISTS `supplier_contact_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `supplier_contact_report` (
  `supplier_contact_report_id` int(13) NOT NULL AUTO_INCREMENT,
  `default_manager` varchar(2) DEFAULT 'N',
  `use4mail` varchar(2) DEFAULT 'N',
  `interval_id` int(11) NOT NULL DEFAULT '0',
  `report_lang` int(3) NOT NULL DEFAULT '1',
  `report_format` varchar(10) NOT NULL DEFAULT 'html',
  PRIMARY KEY (`supplier_contact_report_id`),
  KEY `interval_id` (`interval_id`,`supplier_contact_report_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier_contact_report`
--

LOCK TABLES `supplier_contact_report` WRITE;
/*!40000 ALTER TABLE `supplier_contact_report` DISABLE KEYS */;
/*!40000 ALTER TABLE `supplier_contact_report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supplier_reverse`
--

DROP TABLE IF EXISTS `supplier_reverse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `supplier_reverse` (
  `supplier_id` int(13) NOT NULL,
  `low_pic` varchar(255) DEFAULT NULL,
  `thumb_pic` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`supplier_id`),
  KEY `low_pic` (`low_pic`),
  KEY `thumb_pic` (`thumb_pic`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier_reverse`
--

LOCK TABLES `supplier_reverse` WRITE;
/*!40000 ALTER TABLE `supplier_reverse` DISABLE KEYS */;
/*!40000 ALTER TABLE `supplier_reverse` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supplier_sales_report`
--

DROP TABLE IF EXISTS `supplier_sales_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `supplier_sales_report` (
  `sales_report_id` int(13) NOT NULL AUTO_INCREMENT,
  `supplier_id` int(13) DEFAULT NULL,
  `mailto` mediumtext NOT NULL,
  `mailcc` mediumtext,
  `mailbcc` mediumtext,
  `report_type_id` int(3) NOT NULL DEFAULT '1',
  `active` int(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`sales_report_id`),
  UNIQUE KEY `supplier_id2` (`supplier_id`,`report_type_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier_sales_report`
--

LOCK TABLES `supplier_sales_report` WRITE;
/*!40000 ALTER TABLE `supplier_sales_report` DISABLE KEYS */;
/*!40000 ALTER TABLE `supplier_sales_report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supplier_url`
--

DROP TABLE IF EXISTS `supplier_url`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `supplier_url` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `supplier_id` int(13) NOT NULL DEFAULT '0',
  `url` varchar(255) NOT NULL DEFAULT '',
  `country_id` int(13) DEFAULT NULL,
  `langid` int(13) NOT NULL DEFAULT '0',
  `description` mediumtext NOT NULL,
  PRIMARY KEY (`id`),
  KEY `supplier_id` (`supplier_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier_url`
--

LOCK TABLES `supplier_url` WRITE;
/*!40000 ALTER TABLE `supplier_url` DISABLE KEYS */;
/*!40000 ALTER TABLE `supplier_url` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supplier_users`
--

DROP TABLE IF EXISTS `supplier_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `supplier_users` (
  `supplier_users_id` int(13) NOT NULL AUTO_INCREMENT,
  `supplier_id` int(13) NOT NULL DEFAULT '0',
  `user_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`supplier_users_id`),
  UNIQUE KEY `supplier_id` (`supplier_id`,`user_id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier_users`
--

LOCK TABLES `supplier_users` WRITE;
/*!40000 ALTER TABLE `supplier_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `supplier_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tex`
--

DROP TABLE IF EXISTS `tex`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tex` (
  `tex_id` int(13) NOT NULL AUTO_INCREMENT,
  `tid` int(13) NOT NULL DEFAULT '0',
  `langid` int(3) NOT NULL DEFAULT '0',
  `value` mediumtext,
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`tex_id`),
  UNIQUE KEY `icecat_id` (`icecat_id`),
  KEY `tid` (`tid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tex`
--

LOCK TABLES `tex` WRITE;
/*!40000 ALTER TABLE `tex` DISABLE KEYS */;
/*!40000 ALTER TABLE `tex` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tid_index`
--

DROP TABLE IF EXISTS `tid_index`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tid_index` (
  `tid` int(13) NOT NULL AUTO_INCREMENT,
  `dummy` int(1) DEFAULT NULL,
  PRIMARY KEY (`tid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tid_index`
--

LOCK TABLES `tid_index` WRITE;
/*!40000 ALTER TABLE `tid_index` DISABLE KEYS */;
/*!40000 ALTER TABLE `tid_index` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `time_interval`
--

DROP TABLE IF EXISTS `time_interval`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `time_interval` (
  `interval_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`interval_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `time_interval`
--

LOCK TABLES `time_interval` WRITE;
/*!40000 ALTER TABLE `time_interval` DISABLE KEYS */;
/*!40000 ALTER TABLE `time_interval` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `track_column_name`
--

DROP TABLE IF EXISTS `track_column_name`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `track_column_name` (
  `track_column_name_id` int(13) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `order` int(3) NOT NULL,
  `symbol` varchar(255) NOT NULL,
  `is_restricted` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`track_column_name_id`),
  UNIQUE KEY `symbol` (`symbol`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `track_column_name`
--

LOCK TABLES `track_column_name` WRITE;
/*!40000 ALTER TABLE `track_column_name` DISABLE KEYS */;
/*!40000 ALTER TABLE `track_column_name` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `track_list`
--

DROP TABLE IF EXISTS `track_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `track_list` (
  `track_list_id` int(13) NOT NULL AUTO_INCREMENT,
  `feed_config_id` varchar(50) NOT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `feed_url` varchar(255) NOT NULL,
  `feed_type` varchar(10) NOT NULL,
  `is_first_header` int(1) NOT NULL DEFAULT '1',
  `feed_login` varchar(250) NOT NULL,
  `feed_pwd` varchar(250) NOT NULL,
  `delimiter` varchar(250) NOT NULL,
  `newline` varchar(250) NOT NULL,
  `escape` varchar(1) NOT NULL DEFAULT '\\',
  `quote` varchar(1) NOT NULL DEFAULT '"',
  `user_choiced_file` varchar(250) NOT NULL DEFAULT '',
  `ean_cols` varchar(30) NOT NULL,
  `name_col` int(11) NOT NULL DEFAULT '0',
  `brand_col` int(11) NOT NULL DEFAULT '0',
  `brand_prodid_col` int(11) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `deadline_date` int(15) NOT NULL DEFAULT '0',
  `created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `user_id` int(13) NOT NULL DEFAULT '0',
  `priority` enum('1','2','3') NOT NULL DEFAULT '3',
  `is_open` int(1) NOT NULL DEFAULT '1',
  `reminder_period` int(10) NOT NULL DEFAULT '0',
  `ext_col1` int(5) NOT NULL DEFAULT '0',
  `ext_col2` int(5) NOT NULL DEFAULT '0',
  `ext_col3` int(11) NOT NULL DEFAULT '0',
  `ext_col1_name` varchar(255) NOT NULL DEFAULT '',
  `ext_col2_name` varchar(255) NOT NULL DEFAULT '',
  `ext_col3_name` varchar(255) NOT NULL DEFAULT '',
  `rules` text NOT NULL,
  `goal_coverage` int(5) NOT NULL DEFAULT '100',
  PRIMARY KEY (`track_list_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `track_list`
--

LOCK TABLES `track_list` WRITE;
/*!40000 ALTER TABLE `track_list` DISABLE KEYS */;
/*!40000 ALTER TABLE `track_list` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `track_list_editor`
--

DROP TABLE IF EXISTS `track_list_editor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `track_list_editor` (
  `track_list_editor_id` int(13) NOT NULL AUTO_INCREMENT,
  `track_list_id` int(13) NOT NULL,
  `user_id` int(13) NOT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`track_list_editor_id`),
  UNIQUE KEY `owner` (`track_list_id`,`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `track_list_editor`
--

LOCK TABLES `track_list_editor` WRITE;
/*!40000 ALTER TABLE `track_list_editor` DISABLE KEYS */;
/*!40000 ALTER TABLE `track_list_editor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `track_list_lang`
--

DROP TABLE IF EXISTS `track_list_lang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `track_list_lang` (
  `track_list_editor_id` int(13) NOT NULL AUTO_INCREMENT,
  `track_list_id` int(13) NOT NULL,
  `langid` int(13) NOT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`track_list_editor_id`),
  UNIQUE KEY `lang` (`track_list_id`,`langid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `track_list_lang`
--

LOCK TABLES `track_list_lang` WRITE;
/*!40000 ALTER TABLE `track_list_lang` DISABLE KEYS */;
/*!40000 ALTER TABLE `track_list_lang` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `track_product`
--

DROP TABLE IF EXISTS `track_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `track_product` (
  `track_product_id` int(13) NOT NULL AUTO_INCREMENT,
  `track_list_id` int(13) NOT NULL,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `feed_prod_id` varchar(255) NOT NULL DEFAULT '',
  `by_ean_prod_id` int(1) NOT NULL DEFAULT '0',
  `map_prod_id` varchar(250) NOT NULL,
  `rule_supplier_id` int(13) NOT NULL DEFAULT '0',
  `feed_supplier` varchar(255) NOT NULL DEFAULT '',
  `is_reverse_rule` int(1) NOT NULL DEFAULT '1',
  `rule_prod_id` varchar(255) NOT NULL DEFAULT '',
  `rule_user_id` int(13) NOT NULL DEFAULT '0',
  `supplier_id` int(13) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `ext_col1` varchar(255) NOT NULL DEFAULT '',
  `ext_col2` varchar(255) NOT NULL DEFAULT '',
  `ext_col3` varchar(255) NOT NULL DEFAULT '',
  `remarks` text NOT NULL,
  `is_parked` int(1) NOT NULL DEFAULT '0',
  `quality` varchar(40) NOT NULL DEFAULT '',
  `described_date` datetime NOT NULL,
  `updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,
  `extr_langs` varchar(255) NOT NULL DEFAULT '',
  `extr_pdf_langs` varchar(255) NOT NULL,
  `extr_man_langs` varchar(255) NOT NULL,
  `extr_rel_count` int(5) DEFAULT NULL,
  `extr_feat_count` int(5) DEFAULT NULL,
  `extr_quality` varchar(40) NOT NULL DEFAULT '',
  `track_product_status` varchar(40) NOT NULL DEFAULT '',
  `eans_joined` varchar(255) NOT NULL DEFAULT '',
  `extr_ean` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`track_product_id`),
  KEY `product_id_indx` (`product_id`),
  KEY `track_list_id_indx` (`track_list_id`),
  KEY `supplier_id` (`supplier_id`),
  KEY `rule_user_id` (`rule_user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `track_product`
--

LOCK TABLES `track_product` WRITE;
/*!40000 ALTER TABLE `track_product` DISABLE KEYS */;
/*!40000 ALTER TABLE `track_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `track_product_ean`
--

DROP TABLE IF EXISTS `track_product_ean`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `track_product_ean` (
  `track_product_ean_id` int(13) NOT NULL AUTO_INCREMENT,
  `track_product_id` int(13) NOT NULL,
  `ean` varchar(50) NOT NULL DEFAULT '',
  `product_id` varchar(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`track_product_ean_id`),
  KEY `track_product_id` (`track_product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `track_product_ean`
--

LOCK TABLES `track_product_ean` WRITE;
/*!40000 ALTER TABLE `track_product_ean` DISABLE KEYS */;
/*!40000 ALTER TABLE `track_product_ean` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `track_restricted_columns`
--

DROP TABLE IF EXISTS `track_restricted_columns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `track_restricted_columns` (
  `track_restricted_columns_id` int(13) NOT NULL AUTO_INCREMENT,
  `track_list_id` int(13) NOT NULL,
  `track_column_name_id` int(13) NOT NULL,
  PRIMARY KEY (`track_restricted_columns_id`),
  UNIQUE KEY `track_list_id` (`track_list_id`,`track_column_name_id`),
  KEY `track_column_name_id` (`track_column_name_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `track_restricted_columns`
--

LOCK TABLES `track_restricted_columns` WRITE;
/*!40000 ALTER TABLE `track_restricted_columns` DISABLE KEYS */;
/*!40000 ALTER TABLE `track_restricted_columns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `track_user_columns`
--

DROP TABLE IF EXISTS `track_user_columns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `track_user_columns` (
  `track_user_columns_id` int(13) NOT NULL AUTO_INCREMENT,
  `user_id` int(13) NOT NULL,
  `track_list_id` int(13) NOT NULL,
  `track_column_name_id` int(13) NOT NULL,
  PRIMARY KEY (`track_user_columns_id`),
  UNIQUE KEY `user_id` (`user_id`,`track_list_id`,`track_column_name_id`),
  KEY `track_column_name_id` (`track_column_name_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `track_user_columns`
--

LOCK TABLES `track_user_columns` WRITE;
/*!40000 ALTER TABLE `track_user_columns` DISABLE KEYS */;
/*!40000 ALTER TABLE `track_user_columns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `uploaded_image`
--

DROP TABLE IF EXISTS `uploaded_image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uploaded_image` (
  `uploaded_image_id` int(13) NOT NULL AUTO_INCREMENT,
  `referenced` int(7) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uploaded_image_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `uploaded_image`
--

LOCK TABLES `uploaded_image` WRITE;
/*!40000 ALTER TABLE `uploaded_image` DISABLE KEYS */;
/*!40000 ALTER TABLE `uploaded_image` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_group_measure_map`
--

DROP TABLE IF EXISTS `user_group_measure_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_group_measure_map` (
  `user_group` varchar(50) NOT NULL DEFAULT '',
  `measure` varchar(50) NOT NULL DEFAULT 'NOEDITOR',
  KEY `user_group` (`user_group`,`measure`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_group_measure_map`
--

LOCK TABLES `user_group_measure_map` WRITE;
/*!40000 ALTER TABLE `user_group_measure_map` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_group_measure_map` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `user_id` int(13) NOT NULL AUTO_INCREMENT,
  `login` char(40) DEFAULT NULL,
  `user_group` varchar(255) NOT NULL DEFAULT 'shop',
  `password` varchar(255) NOT NULL DEFAULT '',
  `pers_cid` int(13) DEFAULT NULL,
  `bill_cid` int(13) DEFAULT NULL,
  `tech_cid` int(13) DEFAULT NULL,
  `sales_cid` int(13) DEFAULT NULL,
  `access_restriction` int(3) NOT NULL DEFAULT '0',
  `access_restriction_ip` mediumtext NOT NULL,
  `reference` mediumtext,
  `login_expiration_date` varchar(30) DEFAULT NULL,
  `subscription_level` tinyint(2) DEFAULT '0',
  `statistic_enabled` char(3) NOT NULL DEFAULT 'No',
  `public_password` varchar(80) DEFAULT '88123g88o',
  `access_repository` varchar(64) DEFAULT '0000000000000000000000000000000000000000000000000000000000000000',
  `user_partner_id` int(13) NOT NULL DEFAULT '0',
  `access_via_ftp` int(1) NOT NULL DEFAULT '0',
  `organization` varchar(255) DEFAULT NULL,
  `collection_point` varchar(255) NOT NULL DEFAULT '',
  `platform` varchar(255) NOT NULL DEFAULT '',
  `logo_pic` varchar(255) NOT NULL DEFAULT '',
  `is_implementation_partner` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `login` (`login`),
  KEY `user_partner_id` (`user_partner_id`),
  KEY `pers_cid` (`pers_cid`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'nobody','noeditor','',NULL,NULL,NULL,NULL,0,'',NULL,NULL,0,'No','88123g88o','0000000000000000000000000000000000000000000000000000000000000000',0,0,NULL,'','','',0),(2,'root','superuser','root',NULL,NULL,NULL,NULL,0,'',NULL,NULL,4,'No','88123g88o','0000000000000000000000000000000000000000000000000000000000000000',0,0,NULL,'','','',0),(3,'supplier','shop','SUPPLIER',NULL,NULL,NULL,NULL,0,'',NULL,NULL,0,'No','88123g88o','0000000000000000000000000000000000000000000000000000000000000000',0,0,NULL,'','','',0),(4,'icecat','shop','ICECAT',NULL,NULL,NULL,NULL,0,'',NULL,NULL,0,'No','88123g88o','0000000000000000000000000000000000000000000000000000000000000000',0,0,NULL,'','','',0);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `value_regexp`
--

DROP TABLE IF EXISTS `value_regexp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `value_regexp` (
  `value_regexp_id` int(13) NOT NULL AUTO_INCREMENT,
  `pattern` varchar(255) NOT NULL DEFAULT '',
  `parameter1` varchar(255) NOT NULL DEFAULT '',
  `parameter2` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`value_regexp_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `value_regexp`
--

LOCK TABLES `value_regexp` WRITE;
/*!40000 ALTER TABLE `value_regexp` DISABLE KEYS */;
/*!40000 ALTER TABLE `value_regexp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `value_regexp_bg_processes`
--

DROP TABLE IF EXISTS `value_regexp_bg_processes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `value_regexp_bg_processes` (
  `value_regexp_bg_processes_id` int(13) NOT NULL AUTO_INCREMENT,
  `measure_id` int(13) NOT NULL DEFAULT '0',
  `user_id` int(13) NOT NULL DEFAULT '0',
  `start_date` int(13) NOT NULL DEFAULT '0',
  `stage` varchar(255) NOT NULL DEFAULT '',
  `max_value` int(13) NOT NULL DEFAULT '0',
  `current_value` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`value_regexp_bg_processes_id`),
  KEY `measure_id` (`measure_id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `value_regexp_bg_processes`
--

LOCK TABLES `value_regexp_bg_processes` WRITE;
/*!40000 ALTER TABLE `value_regexp_bg_processes` DISABLE KEYS */;
/*!40000 ALTER TABLE `value_regexp_bg_processes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vendor_notification_queue`
--

DROP TABLE IF EXISTS `vendor_notification_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vendor_notification_queue` (
  `id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `updated` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_id` (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vendor_notification_queue`
--

LOCK TABLES `vendor_notification_queue` WRITE;
/*!40000 ALTER TABLE `vendor_notification_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `vendor_notification_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `virtual_category`
--

DROP TABLE IF EXISTS `virtual_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `virtual_category` (
  `virtual_category_id` int(13) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `category_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`virtual_category_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `virtual_category`
--

LOCK TABLES `virtual_category` WRITE;
/*!40000 ALTER TABLE `virtual_category` DISABLE KEYS */;
/*!40000 ALTER TABLE `virtual_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `virtual_category_product`
--

DROP TABLE IF EXISTS `virtual_category_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `virtual_category_product` (
  `virtual_category_product_id` int(13) NOT NULL AUTO_INCREMENT,
  `product_id` int(13) NOT NULL DEFAULT '0',
  `virtual_category_id` int(13) NOT NULL DEFAULT '0',
  PRIMARY KEY (`virtual_category_product_id`),
  UNIQUE KEY `vcatid` (`product_id`,`virtual_category_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `virtual_category_product`
--

LOCK TABLES `virtual_category_product` WRITE;
/*!40000 ALTER TABLE `virtual_category_product` DISABLE KEYS */;
/*!40000 ALTER TABLE `virtual_category_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vocabulary`
--

DROP TABLE IF EXISTS `vocabulary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vocabulary` (
  `record_id` int(13) NOT NULL AUTO_INCREMENT,
  `sid` int(13) NOT NULL DEFAULT '0',
  `langid` int(3) NOT NULL DEFAULT '0',
  `value` varchar(255) DEFAULT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_published` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `icecat_id` int(13) DEFAULT NULL,
  PRIMARY KEY (`record_id`),
  UNIQUE KEY `sid_2` (`sid`,`langid`),
  UNIQUE KEY `icecat_id` (`icecat_id`),
  KEY `langid` (`langid`),
  KEY `updated` (`updated`),
  KEY `last_published` (`last_published`)
) ENGINE=MyISAM AUTO_INCREMENT=605 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vocabulary`
--

LOCK TABLES `vocabulary` WRITE;
/*!40000 ALTER TABLE `vocabulary` DISABLE KEYS */;
INSERT INTO `vocabulary` VALUES (1,1,1,'English','2011-01-14 13:01:21','0000-00-00 00:00:00',1),(2,2,1,'Dutch','2011-01-14 13:01:21','0000-00-00 00:00:00',3),(3,3,1,'French','2011-01-14 13:01:22','0000-00-00 00:00:00',6071),(4,4,1,'German','2011-01-14 13:01:22','0000-00-00 00:00:00',14088),(5,5,1,'Italian','2011-01-14 13:01:22','0000-00-00 00:00:00',14091),(6,6,1,'Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',14094),(7,7,1,'Danish','2011-01-14 13:01:21','0000-00-00 00:00:00',39312),(8,8,1,'Russian','2011-01-14 13:01:22','0000-00-00 00:00:00',40173),(9,9,1,'US English','2011-01-14 13:01:22','0000-00-00 00:00:00',40179),(10,10,1,'Brazilian-Portuguese','2011-01-14 13:01:22','0000-00-00 00:00:00',40185),(11,11,1,'Portuguese-Portuguese','2011-01-14 13:01:22','0000-00-00 00:00:00',40191),(12,12,1,'Chinese','2011-01-14 13:01:22','0000-00-00 00:00:00',40197),(13,13,1,'Swedish','2011-01-14 13:01:22','0000-00-00 00:00:00',40203),(14,14,1,'Polish','2011-01-14 13:01:22','0000-00-00 00:00:00',40209),(15,15,1,'Czech','2011-01-14 13:01:22','0000-00-00 00:00:00',40215),(16,16,1,'Hungarian','2011-01-14 13:01:22','0000-00-00 00:00:00',40221),(17,17,1,'Finnish','2011-01-14 13:01:21','0000-00-00 00:00:00',40227),(18,18,1,'Greek','2011-01-14 13:01:21','0000-00-00 00:00:00',113508),(19,19,1,'Norwegian','2011-01-14 13:01:22','0000-00-00 00:00:00',118813),(20,20,1,'Turkish','2011-01-14 13:01:22','0000-00-00 00:00:00',118819),(21,21,1,'Bulgarian','2011-01-14 13:01:21','0000-00-00 00:00:00',147616),(22,22,1,'Georgian','2011-01-14 13:01:22','0000-00-00 00:00:00',154954),(23,23,1,'Romanian','2011-01-14 13:01:22','0000-00-00 00:00:00',169100),(24,24,1,'Serbian','2011-01-14 13:01:22','0000-00-00 00:00:00',170887),(25,25,1,'Ukrainian','2011-01-14 13:01:22','0000-00-00 00:00:00',198046),(26,26,1,'Japanese','2011-01-14 13:01:21','0000-00-00 00:00:00',224188),(27,27,1,'Catalan','2011-01-14 13:01:22','0000-00-00 00:00:00',231955),(28,28,1,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244259),(29,29,1,'Croatian','2011-01-14 13:01:22','0000-00-00 00:00:00',270273),(30,30,1,'Arabic','2011-01-14 13:01:21','0000-00-00 00:00:00',286712),(31,31,1,'Vietnamese','2011-01-14 13:01:22','0000-00-00 00:00:00',295712),(32,32,1,'Korean','2011-01-14 13:01:21','0000-00-00 00:00:00',316981),(33,33,1,'Macedonian','2011-01-14 13:01:21','0000-00-00 00:00:00',412005),(34,34,1,'Slovenian','2011-01-14 13:01:22','0000-00-00 00:00:00',412011),(35,35,1,'Singapore English','2011-01-14 13:01:22','0000-00-00 00:00:00',478520),(36,36,1,'South Africa English','2011-01-14 13:01:22','0000-00-00 00:00:00',494304),(37,37,1,'Traditional Chinese','2011-01-14 13:01:22','0000-00-00 00:00:00',511192),(38,38,1,'Hebrew','2011-01-14 13:01:22','0000-00-00 00:00:00',521767),(39,39,1,'Lithuanian','2011-01-14 13:01:22','0000-00-00 00:00:00',551521),(40,40,1,'Latvian','2011-01-14 13:01:22','0000-00-00 00:00:00',582746),(41,41,1,'Afghanistan','2011-01-12 14:22:05','0000-00-00 00:00:00',41),(42,42,1,'Albania','2011-01-12 14:22:05','0000-00-00 00:00:00',42),(43,43,1,'Algeria','2011-01-12 14:22:05','0000-00-00 00:00:00',43),(44,44,1,'Andorra','2011-01-12 14:22:05','0000-00-00 00:00:00',44),(45,45,1,'Angola','2011-01-12 14:22:05','0000-00-00 00:00:00',45),(46,46,1,'Antigua and Barbuda','2011-01-12 14:22:05','0000-00-00 00:00:00',46),(47,47,1,'Argentina','2011-01-12 14:22:05','0000-00-00 00:00:00',47),(48,48,1,'Armenia','2011-01-12 14:22:05','0000-00-00 00:00:00',48),(49,49,1,'Australia','2011-01-12 14:22:05','0000-00-00 00:00:00',49),(50,50,1,'Austria','2011-01-12 14:22:05','0000-00-00 00:00:00',50),(51,51,1,'Azerbaijan','2011-01-12 14:22:05','0000-00-00 00:00:00',51),(52,52,1,'Bahrain','2011-01-12 14:22:05','0000-00-00 00:00:00',52),(53,53,1,'Bangladesh','2011-01-12 14:22:05','0000-00-00 00:00:00',53),(54,54,1,'Barbados','2011-01-12 14:22:05','0000-00-00 00:00:00',54),(55,55,1,'Belarus','2011-01-12 14:22:05','0000-00-00 00:00:00',55),(56,56,1,'Belgium','2011-01-12 14:22:05','0000-00-00 00:00:00',56),(57,57,1,'Belize','2011-01-12 14:22:05','0000-00-00 00:00:00',57),(58,58,1,'Benin','2011-01-12 14:22:05','0000-00-00 00:00:00',58),(59,59,1,'Bhutan','2011-01-12 14:22:05','0000-00-00 00:00:00',59),(60,60,1,'Bolivia','2011-01-12 14:22:05','0000-00-00 00:00:00',60),(61,61,1,'Bosnia and Herzegovina','2011-01-12 14:22:05','0000-00-00 00:00:00',61),(62,62,1,'Botswana','2011-01-12 14:22:05','0000-00-00 00:00:00',62),(63,63,1,'Brazil','2011-01-12 14:22:05','0000-00-00 00:00:00',63),(64,64,1,'Brunei','2011-01-12 14:22:05','0000-00-00 00:00:00',64),(65,65,1,'Bulgaria','2011-01-12 14:22:05','0000-00-00 00:00:00',65),(66,66,1,'Burkina Faso','2011-01-12 14:22:05','0000-00-00 00:00:00',66),(67,67,1,'Burundi','2011-01-12 14:22:05','0000-00-00 00:00:00',67),(68,68,1,'Cambodia','2011-01-12 14:22:05','0000-00-00 00:00:00',68),(69,69,1,'Cameroon','2011-01-12 14:22:05','0000-00-00 00:00:00',69),(70,70,1,'Canada','2011-01-12 14:22:05','0000-00-00 00:00:00',70),(71,71,1,'Cape Verde','2011-01-12 14:22:05','0000-00-00 00:00:00',71),(72,72,1,'Central African Republic','2011-01-12 14:22:05','0000-00-00 00:00:00',72),(73,73,1,'Chad','2011-01-12 14:22:05','0000-00-00 00:00:00',73),(74,74,1,'Chile','2011-01-12 14:22:05','0000-00-00 00:00:00',74),(75,75,1,'Colombia','2011-01-12 14:22:05','0000-00-00 00:00:00',75),(76,76,1,'Comoros','2011-01-12 14:22:05','0000-00-00 00:00:00',76),(77,77,1,'Costa Rica','2011-01-12 14:22:05','0000-00-00 00:00:00',77),(78,78,1,'Cote d\'Ivoire (Ivory Coast)','2011-01-12 14:22:05','0000-00-00 00:00:00',78),(79,79,1,'Croatia','2011-01-12 14:22:05','0000-00-00 00:00:00',79),(80,80,1,'Cuba','2011-01-12 14:22:05','0000-00-00 00:00:00',80),(81,81,1,'Cyprus','2011-01-12 14:22:05','0000-00-00 00:00:00',81),(82,82,1,'Czech Republic','2011-01-12 14:22:05','0000-00-00 00:00:00',82),(83,83,1,'Denmark','2011-01-12 14:22:05','0000-00-00 00:00:00',83),(84,84,1,'Djibouti','2011-01-12 14:22:05','0000-00-00 00:00:00',84),(85,85,1,'Dominica','2011-01-12 14:22:05','0000-00-00 00:00:00',85),(86,86,1,'Dominican Republic','2011-01-12 14:22:05','0000-00-00 00:00:00',86),(87,87,1,'Ecuador','2011-01-12 14:22:05','0000-00-00 00:00:00',87),(88,88,1,'Egypt','2011-01-12 14:22:05','0000-00-00 00:00:00',88),(89,89,1,'El Salvador','2011-01-12 14:22:05','0000-00-00 00:00:00',89),(90,90,1,'Equatorial Guinea','2011-01-12 14:22:05','0000-00-00 00:00:00',90),(91,91,1,'Eritrea','2011-01-12 14:22:05','0000-00-00 00:00:00',91),(92,92,1,'Estonia','2011-01-12 14:22:05','0000-00-00 00:00:00',92),(93,93,1,'Ethiopia','2011-01-12 14:22:05','0000-00-00 00:00:00',93),(94,94,1,'Fiji','2011-01-12 14:22:05','0000-00-00 00:00:00',94),(95,95,1,'Finland','2011-01-12 14:22:05','0000-00-00 00:00:00',95),(96,96,1,'France','2011-01-12 14:22:05','0000-00-00 00:00:00',96),(97,97,1,'Gabon','2011-01-12 14:22:05','0000-00-00 00:00:00',97),(98,98,1,'Georgia','2011-01-12 14:22:05','0000-00-00 00:00:00',98),(99,99,1,'Germany','2011-01-12 14:22:05','0000-00-00 00:00:00',99),(100,100,1,'Ghana','2011-01-12 14:22:05','0000-00-00 00:00:00',100),(101,101,1,'Greece','2011-01-12 14:22:05','0000-00-00 00:00:00',101),(102,102,1,'Grenada','2011-01-12 14:22:05','0000-00-00 00:00:00',102),(103,103,1,'Guatemala','2011-01-12 14:22:05','0000-00-00 00:00:00',103),(104,104,1,'Guinea','2011-01-12 14:22:05','0000-00-00 00:00:00',104),(105,105,1,'Guinea-Bissau','2011-01-12 14:22:05','0000-00-00 00:00:00',105),(106,106,1,'Guyana','2011-01-12 14:22:05','0000-00-00 00:00:00',106),(107,107,1,'Haiti','2011-01-12 14:22:05','0000-00-00 00:00:00',107),(108,108,1,'Honduras','2011-01-12 14:22:05','0000-00-00 00:00:00',108),(109,109,1,'Hungary','2011-01-12 14:22:05','0000-00-00 00:00:00',109),(110,110,1,'Iceland','2011-01-12 14:22:05','0000-00-00 00:00:00',110),(111,111,1,'India','2011-01-12 14:22:05','0000-00-00 00:00:00',111),(112,112,1,'Indonesia','2011-01-12 14:22:05','0000-00-00 00:00:00',112),(113,113,1,'Iran','2011-01-12 14:22:05','0000-00-00 00:00:00',113),(114,114,1,'Iraq','2011-01-12 14:22:05','0000-00-00 00:00:00',114),(115,115,1,'Ireland','2011-01-12 14:22:05','0000-00-00 00:00:00',115),(116,116,1,'Israel','2011-01-12 14:22:05','0000-00-00 00:00:00',116),(117,117,1,'Italy','2011-01-12 14:22:05','0000-00-00 00:00:00',117),(118,118,1,'Jamaica','2011-01-12 14:22:05','0000-00-00 00:00:00',118),(119,119,1,'Japan','2011-01-12 14:22:05','0000-00-00 00:00:00',119),(120,120,1,'Jordan','2011-01-12 14:22:05','0000-00-00 00:00:00',120),(121,121,1,'Kazakhstan','2011-01-12 14:22:05','0000-00-00 00:00:00',121),(122,122,1,'Kenya','2011-01-12 14:22:05','0000-00-00 00:00:00',122),(123,123,1,'Kiribati','2011-01-12 14:22:05','0000-00-00 00:00:00',123),(124,124,1,'Kuwait','2011-01-12 14:22:05','0000-00-00 00:00:00',124),(125,125,1,'Kyrgyzstan','2011-01-12 14:22:05','0000-00-00 00:00:00',125),(126,126,1,'Laos','2011-01-12 14:22:05','0000-00-00 00:00:00',126),(127,127,1,'Latvia','2011-01-12 14:22:05','0000-00-00 00:00:00',127),(128,128,1,'Lebanon','2011-01-12 14:22:05','0000-00-00 00:00:00',128),(129,129,1,'Lesotho','2011-01-12 14:22:05','0000-00-00 00:00:00',129),(130,130,1,'Liberia','2011-01-12 14:22:05','0000-00-00 00:00:00',130),(131,131,1,'Libya','2011-01-12 14:22:05','0000-00-00 00:00:00',131),(132,132,1,'Liechtenstein','2011-01-12 14:22:05','0000-00-00 00:00:00',132),(133,133,1,'Lithuania','2011-01-12 14:22:05','0000-00-00 00:00:00',133),(134,134,1,'Luxembourg','2011-01-12 14:22:05','0000-00-00 00:00:00',134),(135,135,1,'Macedonia','2011-01-12 14:22:05','0000-00-00 00:00:00',135),(136,136,1,'Madagascar','2011-01-12 14:22:05','0000-00-00 00:00:00',136),(137,137,1,'Malawi','2011-01-12 14:22:05','0000-00-00 00:00:00',137),(138,138,1,'Malaysia','2011-01-12 14:22:05','0000-00-00 00:00:00',138),(139,139,1,'Maldives','2011-01-12 14:22:05','0000-00-00 00:00:00',139),(140,140,1,'Mali','2011-01-12 14:22:05','0000-00-00 00:00:00',140),(141,141,1,'Malta','2011-01-12 14:22:05','0000-00-00 00:00:00',141),(142,142,1,'Marshall Islands','2011-01-12 14:22:05','0000-00-00 00:00:00',142),(143,143,1,'Mauritania','2011-01-12 14:22:05','0000-00-00 00:00:00',143),(144,144,1,'Mauritius','2011-01-12 14:22:05','0000-00-00 00:00:00',144),(145,145,1,'Mexico','2011-01-12 14:22:05','0000-00-00 00:00:00',145),(146,146,1,'Micronesia','2011-01-12 14:22:05','0000-00-00 00:00:00',146),(147,147,1,'Moldova','2011-01-12 14:22:05','0000-00-00 00:00:00',147),(148,148,1,'Monaco','2011-01-12 14:22:05','0000-00-00 00:00:00',148),(149,149,1,'Mongolia','2011-01-12 14:22:05','0000-00-00 00:00:00',149),(150,150,1,'Montenegro','2011-01-12 14:22:05','0000-00-00 00:00:00',150),(151,151,1,'Morocco','2011-01-12 14:22:05','0000-00-00 00:00:00',151),(152,152,1,'Mozambique','2011-01-12 14:22:05','0000-00-00 00:00:00',152),(153,153,1,'Myanmar (Burma)','2011-01-12 14:22:05','0000-00-00 00:00:00',153),(154,154,1,'Namibia','2011-01-12 14:22:05','0000-00-00 00:00:00',154),(155,155,1,'Nauru','2011-01-12 14:22:05','0000-00-00 00:00:00',155),(156,156,1,'Nepal','2011-01-12 14:22:05','0000-00-00 00:00:00',156),(157,157,1,'Netherlands','2011-01-12 14:22:05','0000-00-00 00:00:00',157),(158,158,1,'New Zealand','2011-01-12 14:22:05','0000-00-00 00:00:00',158),(159,159,1,'Nicaragua','2011-01-12 14:22:05','0000-00-00 00:00:00',159),(160,160,1,'Niger','2011-01-12 14:22:05','0000-00-00 00:00:00',160),(161,161,1,'Nigeria','2011-01-12 14:22:05','0000-00-00 00:00:00',161),(162,162,1,'Norway','2011-01-12 14:22:05','0000-00-00 00:00:00',162),(163,163,1,'Oman','2011-01-12 14:22:05','0000-00-00 00:00:00',163),(164,164,1,'Pakistan','2011-01-12 14:22:05','0000-00-00 00:00:00',164),(165,165,1,'Palau','2011-01-12 14:22:05','0000-00-00 00:00:00',165),(166,166,1,'Panama','2011-01-12 14:22:05','0000-00-00 00:00:00',166),(167,167,1,'Papua New Guinea','2011-01-12 14:22:05','0000-00-00 00:00:00',167),(168,168,1,'Paraguay','2011-01-12 14:22:05','0000-00-00 00:00:00',168),(169,169,1,'Peru','2011-01-12 14:22:05','0000-00-00 00:00:00',169),(170,170,1,'Philippines','2011-01-12 14:22:05','0000-00-00 00:00:00',170),(171,171,1,'Poland','2011-01-12 14:22:05','0000-00-00 00:00:00',171),(172,172,1,'Portugal','2011-01-12 14:22:05','0000-00-00 00:00:00',172),(173,173,1,'Qatar','2011-01-12 14:22:05','0000-00-00 00:00:00',173),(174,174,1,'Romania','2011-01-12 14:22:05','0000-00-00 00:00:00',174),(175,175,1,'Russia','2011-01-12 14:22:05','0000-00-00 00:00:00',175),(176,176,1,'Rwanda','2011-01-12 14:22:05','0000-00-00 00:00:00',176),(177,177,1,'Saint Kitts and Nevis','2011-01-12 14:22:05','0000-00-00 00:00:00',177),(178,178,1,'Saint Lucia','2011-01-12 14:22:05','0000-00-00 00:00:00',178),(179,179,1,'Saint Vincent and the Grenadines','2011-01-12 14:22:05','0000-00-00 00:00:00',179),(180,180,1,'Samoa','2011-01-12 14:22:05','0000-00-00 00:00:00',180),(181,181,1,'San Marino','2011-01-12 14:22:05','0000-00-00 00:00:00',181),(182,182,1,'Sao Tome and Principe','2011-01-12 14:22:05','0000-00-00 00:00:00',182),(183,183,1,'Saudi Arabia','2011-01-12 14:22:05','0000-00-00 00:00:00',183),(184,184,1,'Senegal','2011-01-12 14:22:05','0000-00-00 00:00:00',184),(185,185,1,'Serbia','2011-01-12 14:22:05','0000-00-00 00:00:00',185),(186,186,1,'Seychelles','2011-01-12 14:22:05','0000-00-00 00:00:00',186),(187,187,1,'Sierra Leone','2011-01-12 14:22:05','0000-00-00 00:00:00',187),(188,188,1,'Singapore','2011-01-12 14:22:05','0000-00-00 00:00:00',188),(189,189,1,'Slovakia','2011-01-12 14:22:05','0000-00-00 00:00:00',189),(190,190,1,'Slovenia','2011-01-12 14:22:05','0000-00-00 00:00:00',190),(191,191,1,'Solomon Islands','2011-01-12 14:22:05','0000-00-00 00:00:00',191),(192,192,1,'Somalia','2011-01-12 14:22:05','0000-00-00 00:00:00',192),(193,193,1,'South Africa','2011-01-12 14:22:05','0000-00-00 00:00:00',193),(194,194,1,'Spain','2011-01-12 14:22:05','0000-00-00 00:00:00',194),(195,195,1,'Sri Lanka','2011-01-12 14:22:05','0000-00-00 00:00:00',195),(196,196,1,'Sudan','2011-01-12 14:22:05','0000-00-00 00:00:00',196),(197,197,1,'Suriname','2011-01-12 14:22:05','0000-00-00 00:00:00',197),(198,198,1,'Swaziland','2011-01-12 14:22:05','0000-00-00 00:00:00',198),(199,199,1,'Sweden','2011-01-12 14:22:05','0000-00-00 00:00:00',199),(200,200,1,'Switzerland','2011-01-12 14:22:05','0000-00-00 00:00:00',200),(201,201,1,'Syria','2011-01-12 14:22:05','0000-00-00 00:00:00',201),(202,202,1,'Tajikistan','2011-01-12 14:22:05','0000-00-00 00:00:00',202),(203,203,1,'Tanzania','2011-01-12 14:22:05','0000-00-00 00:00:00',203),(204,204,1,'Thailand','2011-01-12 14:22:05','0000-00-00 00:00:00',204),(205,205,1,'Timor-Leste (East Timor)','2011-01-12 14:22:05','0000-00-00 00:00:00',205),(206,206,1,'Togo','2011-01-12 14:22:05','0000-00-00 00:00:00',206),(207,207,1,'Tonga','2011-01-12 14:22:05','0000-00-00 00:00:00',207),(208,208,1,'Trinidad and Tobago','2011-01-12 14:22:05','0000-00-00 00:00:00',208),(209,209,1,'Tunisia','2011-01-12 14:22:05','0000-00-00 00:00:00',209),(210,210,1,'Turkey','2011-01-12 14:22:05','0000-00-00 00:00:00',210),(211,211,1,'Turkmenistan','2011-01-12 14:22:05','0000-00-00 00:00:00',211),(212,212,1,'Tuvalu','2011-01-12 14:22:05','0000-00-00 00:00:00',212),(213,213,1,'Uganda','2011-01-12 14:22:05','0000-00-00 00:00:00',213),(214,214,1,'Ukraine','2011-01-12 14:22:05','0000-00-00 00:00:00',214),(215,215,1,'United Arab Emirates','2011-01-12 14:22:05','0000-00-00 00:00:00',215),(216,216,1,'United Kingdom','2011-01-12 14:22:05','0000-00-00 00:00:00',216),(217,217,1,'United States','2011-01-12 14:22:05','0000-00-00 00:00:00',217),(218,218,1,'Uruguay','2011-01-12 14:22:05','0000-00-00 00:00:00',218),(219,219,1,'Uzbekistan','2011-01-12 14:22:05','0000-00-00 00:00:00',219),(220,220,1,'Vanuatu','2011-01-12 14:22:05','0000-00-00 00:00:00',220),(221,221,1,'Vatican City','2011-01-12 14:22:05','0000-00-00 00:00:00',221),(222,222,1,'Venezuela','2011-01-12 14:22:05','0000-00-00 00:00:00',222),(223,223,1,'Vietnam','2011-01-12 14:22:05','0000-00-00 00:00:00',223),(224,224,1,'Yemen','2011-01-12 14:22:05','0000-00-00 00:00:00',224),(225,225,1,'Zambia','2011-01-12 14:22:05','0000-00-00 00:00:00',225),(226,226,1,'Zimbabwe','2011-01-12 14:22:05','0000-00-00 00:00:00',226),(227,33,2,'Macedonian','2011-01-14 13:01:21','0000-00-00 00:00:00',412006),(228,33,3,'Macedonian','2011-01-14 13:01:21','0000-00-00 00:00:00',412007),(229,33,4,'Macedonian','2011-01-14 13:01:21','0000-00-00 00:00:00',412008),(230,33,5,'Macedonian','2011-01-14 13:01:21','0000-00-00 00:00:00',412009),(231,33,6,'Macedonian','2011-01-14 13:01:21','0000-00-00 00:00:00',412010),(232,32,2,'Korean','2011-01-14 13:01:21','0000-00-00 00:00:00',316982),(233,32,3,'Korean','2011-01-14 13:01:21','0000-00-00 00:00:00',316983),(234,32,4,'Korean','2011-01-14 13:01:21','0000-00-00 00:00:00',316984),(235,32,5,'Korean','2011-01-14 13:01:21','0000-00-00 00:00:00',316985),(236,32,6,'Korean','2011-01-14 13:01:21','0000-00-00 00:00:00',316986),(237,21,8,'Болгарский','2011-01-14 13:01:21','0000-00-00 00:00:00',198042),(238,21,25,'Болгарська','2011-01-14 13:01:21','0000-00-00 00:00:00',205079),(239,7,2,'Danish','2011-01-14 13:01:21','0000-00-00 00:00:00',39313),(240,7,3,'Danish','2011-01-14 13:01:21','0000-00-00 00:00:00',39314),(241,7,4,'Danish','2011-01-14 13:01:21','0000-00-00 00:00:00',39315),(242,7,5,'Danish','2011-01-14 13:01:21','0000-00-00 00:00:00',39316),(243,7,6,'Danish','2011-01-14 13:01:21','0000-00-00 00:00:00',39317),(244,7,7,'Danish','2011-01-14 13:01:21','0000-00-00 00:00:00',39318),(245,7,8,'Датский','2011-01-14 13:01:21','0000-00-00 00:00:00',198028),(246,7,9,'Danish','2011-01-14 13:01:21','0000-00-00 00:00:00',40294),(247,7,10,'Danish','2011-01-14 13:01:21','0000-00-00 00:00:00',40295),(248,7,11,'Danish','2011-01-14 13:01:21','0000-00-00 00:00:00',40296),(249,7,12,'Danish','2011-01-14 13:01:21','0000-00-00 00:00:00',40297),(250,7,13,'Danish','2011-01-14 13:01:21','0000-00-00 00:00:00',40298),(251,7,14,'Danish','2011-01-14 13:01:21','0000-00-00 00:00:00',40299),(252,7,15,'Danish','2011-01-14 13:01:21','0000-00-00 00:00:00',40300),(253,7,16,'Danish','2011-01-14 13:01:21','0000-00-00 00:00:00',40301),(254,7,17,'Danish','2011-01-14 13:01:21','0000-00-00 00:00:00',40302),(255,7,25,'Датська','2011-01-14 13:01:21','0000-00-00 00:00:00',205065),(256,7,35,'Danish','2011-01-14 13:01:21','0000-00-00 00:00:00',486120),(257,26,2,'Japanese','2011-01-14 13:01:21','0000-00-00 00:00:00',224189),(258,26,3,'Japanese','2011-01-14 13:01:21','0000-00-00 00:00:00',224190),(259,26,4,'Japanese','2011-01-14 13:01:21','0000-00-00 00:00:00',224191),(260,26,5,'Japanese','2011-01-14 13:01:21','0000-00-00 00:00:00',224192),(261,26,6,'Japanese','2011-01-14 13:01:21','0000-00-00 00:00:00',224193),(262,26,8,'Японский','2011-01-14 13:01:21','0000-00-00 00:00:00',224194),(263,26,25,'Японська','2011-01-14 13:01:21','0000-00-00 00:00:00',224195),(264,26,26,'Japanese','2011-01-14 13:01:21','0000-00-00 00:00:00',224196),(265,17,2,'Finnish','2011-01-14 13:01:21','0000-00-00 00:00:00',40228),(266,17,3,'Finnish','2011-01-14 13:01:21','0000-00-00 00:00:00',40229),(267,17,4,'Finnish','2011-01-14 13:01:21','0000-00-00 00:00:00',40230),(268,17,5,'Finnish','2011-01-14 13:01:21','0000-00-00 00:00:00',40231),(269,17,6,'Finnish','2011-01-14 13:01:21','0000-00-00 00:00:00',40232),(270,17,8,'Финский','2011-01-14 13:01:21','0000-00-00 00:00:00',198038),(271,17,12,'','2011-01-14 13:01:21','0000-00-00 00:00:00',50895),(272,17,25,'Фінська','2011-01-14 13:01:21','0000-00-00 00:00:00',205075),(273,2,3,'Dutch','2011-01-14 13:01:21','0000-00-00 00:00:00',6074),(274,2,4,'Dutch','2011-01-14 13:01:21','0000-00-00 00:00:00',14099),(275,2,5,'Dutch','2011-01-14 13:01:21','0000-00-00 00:00:00',18231),(276,2,6,'Dutch','2011-01-14 13:01:21','0000-00-00 00:00:00',22363),(277,2,7,'Hollandsk','2011-01-14 13:01:21','0000-00-00 00:00:00',34054),(278,2,8,'Голландский','2011-01-14 13:01:21','0000-00-00 00:00:00',198023),(279,2,9,'Dutch','2011-01-14 13:01:21','0000-00-00 00:00:00',40244),(280,2,10,'Dutch','2011-01-14 13:01:21','0000-00-00 00:00:00',40245),(281,2,11,'Dutch','2011-01-14 13:01:21','0000-00-00 00:00:00',40246),(282,2,12,'Dutch','2011-01-14 13:01:21','0000-00-00 00:00:00',40247),(283,2,13,'Dutch','2011-01-14 13:01:21','0000-00-00 00:00:00',40248),(284,2,14,'Dutch','2011-01-14 13:01:21','0000-00-00 00:00:00',40249),(285,2,15,'Dutch','2011-01-14 13:01:21','0000-00-00 00:00:00',40250),(286,2,16,'Dutch','2011-01-14 13:01:21','0000-00-00 00:00:00',40251),(287,2,17,'Dutch','2011-01-14 13:01:21','0000-00-00 00:00:00',40252),(288,2,25,'Голландська','2011-01-14 13:01:21','0000-00-00 00:00:00',205060),(289,2,31,'Viễn thông','2011-01-14 13:01:21','0000-00-00 00:00:00',302603),(290,2,32,'통신','2011-01-14 13:01:21','0000-00-00 00:00:00',342040),(291,2,35,'Dutch','2011-01-14 13:01:21','0000-00-00 00:00:00',486115),(292,1,3,'English','2011-01-14 13:01:21','0000-00-00 00:00:00',6073),(293,1,4,'English','2011-01-14 13:01:21','0000-00-00 00:00:00',14098),(294,1,5,'English','2011-01-14 13:01:21','0000-00-00 00:00:00',18230),(295,1,6,'English','2011-01-14 13:01:21','0000-00-00 00:00:00',22362),(296,1,7,'Engelsk','2011-01-14 13:01:21','0000-00-00 00:00:00',34053),(297,1,8,'Английский','2011-01-14 13:01:21','0000-00-00 00:00:00',198022),(298,1,9,'English','2011-01-14 13:01:21','0000-00-00 00:00:00',40234),(299,1,10,'English','2011-01-14 13:01:21','0000-00-00 00:00:00',40235),(300,1,11,'English','2011-01-14 13:01:21','0000-00-00 00:00:00',40236),(301,1,12,'English','2011-01-14 13:01:21','0000-00-00 00:00:00',40237),(302,1,13,'English','2011-01-14 13:01:21','0000-00-00 00:00:00',40238),(303,1,14,'English','2011-01-14 13:01:21','0000-00-00 00:00:00',40239),(304,1,15,'English','2011-01-14 13:01:21','0000-00-00 00:00:00',40240),(305,1,16,'English','2011-01-14 13:01:21','0000-00-00 00:00:00',40241),(306,1,17,'English','2011-01-14 13:01:21','0000-00-00 00:00:00',40242),(307,1,23,'Birou','2011-01-14 13:01:21','0000-00-00 00:00:00',286325),(308,1,25,'Англійська','2011-01-14 13:01:21','0000-00-00 00:00:00',205059),(309,1,31,'Văn phòng','2011-01-14 13:01:21','0000-00-00 00:00:00',302602),(310,1,32,'사무실','2011-01-14 13:01:21','0000-00-00 00:00:00',342039),(311,1,35,'English','2011-01-14 13:01:21','0000-00-00 00:00:00',486114),(312,18,2,'Greek','2011-01-14 13:01:21','0000-00-00 00:00:00',113509),(313,18,3,'Greek','2011-01-14 13:01:21','0000-00-00 00:00:00',113510),(314,18,4,'Greek','2011-01-14 13:01:21','0000-00-00 00:00:00',113511),(315,18,5,'Greek','2011-01-14 13:01:21','0000-00-00 00:00:00',113512),(316,18,6,'Greek','2011-01-14 13:01:21','0000-00-00 00:00:00',113513),(317,18,8,'Греческий','2011-01-14 13:01:21','0000-00-00 00:00:00',198039),(318,18,25,'Грецька','2011-01-14 13:01:21','0000-00-00 00:00:00',205076),(319,30,2,'Arabic','2011-01-14 13:01:22','0000-00-00 00:00:00',286713),(320,30,3,'Arabic','2011-01-14 13:01:22','0000-00-00 00:00:00',286714),(321,30,4,'Arabic','2011-01-14 13:01:22','0000-00-00 00:00:00',286715),(322,30,5,'Arabic','2011-01-14 13:01:22','0000-00-00 00:00:00',286716),(323,30,6,'Arabic','2011-01-14 13:01:22','0000-00-00 00:00:00',286717),(324,16,2,'Hungarian','2011-01-14 13:01:22','0000-00-00 00:00:00',40222),(325,16,3,'Hungarian','2011-01-14 13:01:22','0000-00-00 00:00:00',40223),(326,16,4,'Hungarian','2011-01-14 13:01:22','0000-00-00 00:00:00',40224),(327,16,5,'Hungarian','2011-01-14 13:01:22','0000-00-00 00:00:00',40225),(328,16,6,'Hungarian','2011-01-14 13:01:22','0000-00-00 00:00:00',40226),(329,16,8,'Венгерский','2011-01-14 13:01:22','0000-00-00 00:00:00',198037),(330,16,12,'','2011-01-14 13:01:22','0000-00-00 00:00:00',50894),(331,16,25,'Угорська','2011-01-14 13:01:22','0000-00-00 00:00:00',205074),(332,27,2,'Catalan','2011-01-14 13:01:22','0000-00-00 00:00:00',231956),(333,27,3,'Catalan','2011-01-14 13:01:22','0000-00-00 00:00:00',231957),(334,27,4,'Catalan','2011-01-14 13:01:22','0000-00-00 00:00:00',231958),(335,27,5,'Catalan','2011-01-14 13:01:22','0000-00-00 00:00:00',231959),(336,27,6,'Catalan','2011-01-14 13:01:22','0000-00-00 00:00:00',231960),(337,27,8,'Каталанский','2011-01-14 13:01:22','0000-00-00 00:00:00',231962),(338,27,25,'Каталанська','2011-01-14 13:01:22','0000-00-00 00:00:00',231963),(339,27,27,'Català','2011-01-14 13:01:22','0000-00-00 00:00:00',231961),(340,25,2,'Ukrainian','2011-01-14 13:01:22','0000-00-00 00:00:00',198047),(341,25,3,'Ukrainian','2011-01-14 13:01:22','0000-00-00 00:00:00',198048),(342,25,4,'Ukrainian','2011-01-14 13:01:22','0000-00-00 00:00:00',198049),(343,25,5,'Ukrainian','2011-01-14 13:01:22','0000-00-00 00:00:00',198050),(344,25,6,'Ukrainian','2011-01-14 13:01:22','0000-00-00 00:00:00',198051),(345,25,8,'Украинский','2011-01-14 13:01:22','0000-00-00 00:00:00',198052),(346,25,25,'Українська','2011-01-14 13:01:22','0000-00-00 00:00:00',198053),(347,28,2,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244260),(348,28,3,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244261),(349,28,4,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244262),(350,28,5,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244263),(351,28,6,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244264),(352,28,7,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244265),(353,28,8,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244266),(354,28,9,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244267),(355,28,10,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244268),(356,28,11,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244269),(357,28,12,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244270),(358,28,13,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244271),(359,28,14,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244272),(360,28,15,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244273),(361,28,16,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244274),(362,28,17,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244275),(363,28,18,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244276),(364,28,19,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244277),(365,28,20,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244278),(366,28,21,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244279),(367,28,22,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244280),(368,28,23,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244281),(369,28,24,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244282),(370,28,25,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244283),(371,28,26,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244284),(372,28,27,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244285),(373,28,28,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',244286),(374,28,35,'Argentinian-Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',493121),(375,40,2,'Latvian','2011-01-14 13:01:22','0000-00-00 00:00:00',582747),(376,40,3,'Latvian','2011-01-14 13:01:22','0000-00-00 00:00:00',582748),(377,40,4,'Latvian','2011-01-14 13:01:22','0000-00-00 00:00:00',582749),(378,40,5,'Latvian','2011-01-14 13:01:22','0000-00-00 00:00:00',582750),(379,40,6,'Latvian','2011-01-14 13:01:22','0000-00-00 00:00:00',582751),(380,40,7,'Latvian','2011-01-14 13:01:22','0000-00-00 00:00:00',582752),(381,40,8,'Латвийский','2011-01-14 13:01:22','0000-00-00 00:00:00',582753),(382,40,9,'Latvian','2011-01-14 13:01:22','0000-00-00 00:00:00',582754),(383,40,10,'Latvian','2011-01-14 13:01:22','0000-00-00 00:00:00',582755),(384,40,11,'Latvian','2011-01-14 13:01:22','0000-00-00 00:00:00',582756),(385,40,12,'Latvian','2011-01-14 13:01:22','0000-00-00 00:00:00',582757),(386,40,25,'Латиська','2011-01-14 13:01:22','0000-00-00 00:00:00',582759),(387,40,40,'Latviešu','2011-01-14 13:01:22','0000-00-00 00:00:00',582758),(388,20,2,'Turkish','2011-01-14 13:01:22','0000-00-00 00:00:00',118820),(389,20,3,'Turkish','2011-01-14 13:01:22','0000-00-00 00:00:00',118821),(390,20,4,'Turkish','2011-01-14 13:01:22','0000-00-00 00:00:00',118822),(391,20,5,'Turkish','2011-01-14 13:01:22','0000-00-00 00:00:00',118823),(392,20,6,'Turkish','2011-01-14 13:01:22','0000-00-00 00:00:00',118824),(393,20,8,'Турецкий','2011-01-14 13:01:22','0000-00-00 00:00:00',198041),(394,20,25,'Турецька','2011-01-14 13:01:22','0000-00-00 00:00:00',205078),(395,14,2,'Polish','2011-01-14 13:01:22','0000-00-00 00:00:00',40210),(396,14,3,'Polish','2011-01-14 13:01:22','0000-00-00 00:00:00',40211),(397,14,4,'Polish','2011-01-14 13:01:22','0000-00-00 00:00:00',40212),(398,14,5,'Polish','2011-01-14 13:01:22','0000-00-00 00:00:00',40213),(399,14,6,'Polish','2011-01-14 13:01:22','0000-00-00 00:00:00',40214),(400,14,8,'Польский','2011-01-14 13:01:22','0000-00-00 00:00:00',198035),(401,14,12,'','2011-01-14 13:01:22','0000-00-00 00:00:00',50892),(402,14,25,'Польська','2011-01-14 13:01:22','0000-00-00 00:00:00',205072),(403,24,2,'Serbian','2011-01-14 13:01:22','0000-00-00 00:00:00',170888),(404,24,3,'Serbian','2011-01-14 13:01:22','0000-00-00 00:00:00',170889),(405,24,4,'Serbian','2011-01-14 13:01:22','0000-00-00 00:00:00',170890),(406,24,5,'Serbian','2011-01-14 13:01:22','0000-00-00 00:00:00',170891),(407,24,6,'Serbian','2011-01-14 13:01:22','0000-00-00 00:00:00',170892),(408,24,8,'Сербский','2011-01-14 13:01:22','0000-00-00 00:00:00',198045),(409,24,25,'Сербська','2011-01-14 13:01:22','0000-00-00 00:00:00',205082),(410,10,2,'Brazilian-Portuguese','2011-01-14 13:01:22','0000-00-00 00:00:00',40186),(411,10,3,'Brazilian-Portuguese','2011-01-14 13:01:22','0000-00-00 00:00:00',40187),(412,10,4,'Brazilian-Portuguese','2011-01-14 13:01:22','0000-00-00 00:00:00',40188),(413,10,5,'Brazilian-Portuguese','2011-01-14 13:01:22','0000-00-00 00:00:00',40189),(414,10,6,'Brazilian-Portuguese','2011-01-14 13:01:22','0000-00-00 00:00:00',40190),(415,10,8,'Бразильский-португальский','2011-01-14 13:01:22','0000-00-00 00:00:00',198031),(416,10,12,'','2011-01-14 13:01:22','0000-00-00 00:00:00',50888),(417,10,25,'Португальська-Бразилія','2011-01-14 13:01:22','0000-00-00 00:00:00',205068),(418,31,2,'Vietnamese','2011-01-14 13:01:22','0000-00-00 00:00:00',295713),(419,31,3,'Vietnamese','2011-01-14 13:01:22','0000-00-00 00:00:00',295714),(420,31,4,'Vietnamese','2011-01-14 13:01:22','0000-00-00 00:00:00',295715),(421,31,5,'Vietnamese','2011-01-14 13:01:22','0000-00-00 00:00:00',295716),(422,31,6,'Vietnamese','2011-01-14 13:01:22','0000-00-00 00:00:00',295717),(423,35,2,'Singapore English','2011-01-14 13:01:22','0000-00-00 00:00:00',478521),(424,35,3,'Singapore English','2011-01-14 13:01:22','0000-00-00 00:00:00',478522),(425,35,4,'Singapore English','2011-01-14 13:01:22','0000-00-00 00:00:00',478523),(426,35,5,'Singapore English','2011-01-14 13:01:22','0000-00-00 00:00:00',478524),(427,35,6,'Singapore English','2011-01-14 13:01:22','0000-00-00 00:00:00',478525),(428,11,2,'Portuguese-Portuguese','2011-01-14 13:01:22','0000-00-00 00:00:00',40192),(429,11,3,'Portuguese-Portuguese','2011-01-14 13:01:22','0000-00-00 00:00:00',40193),(430,11,4,'Portuguese-Portuguese','2011-01-14 13:01:22','0000-00-00 00:00:00',40194),(431,11,5,'Portuguese-Portuguese','2011-01-14 13:01:22','0000-00-00 00:00:00',40195),(432,11,6,'Portuguese-Portuguese','2011-01-14 13:01:22','0000-00-00 00:00:00',40196),(433,11,8,'Португальский-португальский','2011-01-14 13:01:22','0000-00-00 00:00:00',198032),(434,11,12,'','2011-01-14 13:01:22','0000-00-00 00:00:00',50889),(435,11,25,'Португальcька-Португалія','2011-01-14 13:01:22','0000-00-00 00:00:00',205069),(436,22,8,'Грузинский','2011-01-14 13:01:22','0000-00-00 00:00:00',198043),(437,22,25,'Грузинська','2011-01-14 13:01:22','0000-00-00 00:00:00',205080),(438,13,2,'Swedish','2011-01-14 13:01:22','0000-00-00 00:00:00',40204),(439,13,3,'Swedish','2011-01-14 13:01:22','0000-00-00 00:00:00',40205),(440,13,4,'Swedish','2011-01-14 13:01:22','0000-00-00 00:00:00',40206),(441,13,5,'Swedish','2011-01-14 13:01:22','0000-00-00 00:00:00',40207),(442,13,6,'Swedish','2011-01-14 13:01:22','0000-00-00 00:00:00',40208),(443,13,8,'Шведский','2011-01-14 13:01:22','0000-00-00 00:00:00',198034),(444,13,12,'','2011-01-14 13:01:22','0000-00-00 00:00:00',50891),(445,13,25,'Швецька','2011-01-14 13:01:22','0000-00-00 00:00:00',205071),(446,23,2,'Romanian','2011-01-14 13:01:22','0000-00-00 00:00:00',169101),(447,23,3,'Romanian','2011-01-14 13:01:22','0000-00-00 00:00:00',169102),(448,23,4,'Romanian','2011-01-14 13:01:22','0000-00-00 00:00:00',169103),(449,23,5,'Romanian','2011-01-14 13:01:22','0000-00-00 00:00:00',169104),(450,23,6,'Romanian','2011-01-14 13:01:22','0000-00-00 00:00:00',169105),(451,23,8,'Румынский','2011-01-14 13:01:22','0000-00-00 00:00:00',198044),(452,23,25,'Румунська','2011-01-14 13:01:22','0000-00-00 00:00:00',205081),(453,29,2,'Croatian','2011-01-14 13:01:22','0000-00-00 00:00:00',270274),(454,29,3,'Croatian','2011-01-14 13:01:22','0000-00-00 00:00:00',270275),(455,29,4,'Croatian','2011-01-14 13:01:22','0000-00-00 00:00:00',270276),(456,29,5,'Croatian','2011-01-14 13:01:22','0000-00-00 00:00:00',270277),(457,29,6,'Croatian','2011-01-14 13:01:22','0000-00-00 00:00:00',270278),(458,29,29,'Hrvatski','2011-01-14 13:01:22','0000-00-00 00:00:00',270280),(459,6,2,'Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',14095),(460,6,3,'Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',14096),(461,6,4,'Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',18228),(462,6,5,'','2011-01-14 13:01:22','0000-00-00 00:00:00',106485),(463,6,6,'Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',26492),(464,6,7,'Spansk','2011-01-14 13:01:22','0000-00-00 00:00:00',38094),(465,6,8,'Испанский','2011-01-14 13:01:22','0000-00-00 00:00:00',198027),(466,6,9,'Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',40284),(467,6,10,'Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',40285),(468,6,11,'Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',40286),(469,6,12,'Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',40287),(470,6,13,'Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',40288),(471,6,14,'Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',40289),(472,6,15,'Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',40290),(473,6,16,'Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',40291),(474,6,17,'Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',40292),(475,6,25,'Іспанська','2011-01-14 13:01:22','0000-00-00 00:00:00',205064),(476,6,35,'Spanish','2011-01-14 13:01:22','0000-00-00 00:00:00',486119),(477,39,2,'Lithuanian','2011-01-14 13:01:22','0000-00-00 00:00:00',551522),(478,39,3,'Lithuanian','2011-01-14 13:01:22','0000-00-00 00:00:00',551523),(479,39,4,'Lithuanian','2011-01-14 13:01:22','0000-00-00 00:00:00',551524),(480,39,5,'Lithuanian','2011-01-14 13:01:22','0000-00-00 00:00:00',551525),(481,39,6,'Lithuanian','2011-01-14 13:01:22','0000-00-00 00:00:00',551526),(482,39,8,'Литовский','2011-01-14 13:01:22','0000-00-00 00:00:00',582761),(483,39,25,'Литовська','2011-01-14 13:01:22','0000-00-00 00:00:00',582760),(484,39,39,'Lietuvių','2011-01-14 13:01:22','0000-00-00 00:00:00',582762),(485,36,2,'South Africa English','2011-01-14 13:01:22','0000-00-00 00:00:00',494305),(486,36,3,'South Africa English','2011-01-14 13:01:22','0000-00-00 00:00:00',494306),(487,36,4,'South Africa English','2011-01-14 13:01:22','0000-00-00 00:00:00',494307),(488,36,5,'South Africa English','2011-01-14 13:01:22','0000-00-00 00:00:00',494308),(489,36,6,'South Africa English','2011-01-14 13:01:22','0000-00-00 00:00:00',494309),(490,3,2,'French','2011-01-14 13:01:22','0000-00-00 00:00:00',6072),(491,3,3,'French','2011-01-14 13:01:22','0000-00-00 00:00:00',8815),(492,3,4,'French','2011-01-14 13:01:22','0000-00-00 00:00:00',16579),(493,3,5,'','2011-01-14 13:01:22','0000-00-00 00:00:00',103145),(494,3,6,'French','2011-01-14 13:01:22','0000-00-00 00:00:00',24843),(495,3,7,'Fransk','2011-01-14 13:01:22','0000-00-00 00:00:00',36551),(496,3,8,'Французский','2011-01-14 13:01:22','0000-00-00 00:00:00',198024),(497,3,9,'French','2011-01-14 13:01:22','0000-00-00 00:00:00',40254),(498,3,10,'French','2011-01-14 13:01:22','0000-00-00 00:00:00',40255),(499,3,11,'French','2011-01-14 13:01:22','0000-00-00 00:00:00',40256),(500,3,12,'French','2011-01-14 13:01:22','0000-00-00 00:00:00',40257),(501,3,13,'French','2011-01-14 13:01:22','0000-00-00 00:00:00',40258),(502,3,14,'French','2011-01-14 13:01:22','0000-00-00 00:00:00',40259),(503,3,15,'French','2011-01-14 13:01:22','0000-00-00 00:00:00',40260),(504,3,16,'French','2011-01-14 13:01:22','0000-00-00 00:00:00',40261),(505,3,17,'French','2011-01-14 13:01:22','0000-00-00 00:00:00',40262),(506,3,25,'Французька','2011-01-14 13:01:22','0000-00-00 00:00:00',205061),(507,3,35,'French','2011-01-14 13:01:22','0000-00-00 00:00:00',486116),(508,9,2,'US English','2011-01-14 13:01:22','0000-00-00 00:00:00',40180),(509,9,3,'US English','2011-01-14 13:01:22','0000-00-00 00:00:00',40181),(510,9,4,'US English','2011-01-14 13:01:22','0000-00-00 00:00:00',40182),(511,9,5,'US English','2011-01-14 13:01:22','0000-00-00 00:00:00',40183),(512,9,6,'US English','2011-01-14 13:01:22','0000-00-00 00:00:00',40184),(513,9,8,'Американский английский','2011-01-14 13:01:22','0000-00-00 00:00:00',198030),(514,9,12,'','2011-01-14 13:01:22','0000-00-00 00:00:00',50887),(515,9,25,'Англійська США','2011-01-14 13:01:22','0000-00-00 00:00:00',205067),(516,12,2,'Chinese','2011-01-14 13:01:22','0000-00-00 00:00:00',40198),(517,12,3,'Chinese','2011-01-14 13:01:22','0000-00-00 00:00:00',40199),(518,12,4,'Chinese','2011-01-14 13:01:22','0000-00-00 00:00:00',40200),(519,12,5,'Chinese','2011-01-14 13:01:22','0000-00-00 00:00:00',40201),(520,12,6,'Chinese','2011-01-14 13:01:22','0000-00-00 00:00:00',40202),(521,12,8,'Китайский','2011-01-14 13:01:22','0000-00-00 00:00:00',198033),(522,12,12,'','2011-01-14 13:01:22','0000-00-00 00:00:00',50890),(523,12,25,'Китайська','2011-01-14 13:01:22','0000-00-00 00:00:00',205070),(524,15,2,'Czech','2011-01-14 13:01:22','0000-00-00 00:00:00',40216),(525,15,3,'Czech','2011-01-14 13:01:22','0000-00-00 00:00:00',40217),(526,15,4,'Czech','2011-01-14 13:01:22','0000-00-00 00:00:00',40218),(527,15,5,'Czech','2011-01-14 13:01:22','0000-00-00 00:00:00',40219),(528,15,6,'Czech','2011-01-14 13:01:22','0000-00-00 00:00:00',40220),(529,15,8,'Чешский','2011-01-14 13:01:22','0000-00-00 00:00:00',198036),(530,15,12,'','2011-01-14 13:01:22','0000-00-00 00:00:00',50893),(531,15,25,'Чеська','2011-01-14 13:01:22','0000-00-00 00:00:00',205073),(532,8,2,'Russian','2011-01-14 13:01:22','0000-00-00 00:00:00',40174),(533,8,3,'Russian','2011-01-14 13:01:22','0000-00-00 00:00:00',40175),(534,8,4,'Russian','2011-01-14 13:01:22','0000-00-00 00:00:00',40176),(535,8,5,'Russian','2011-01-14 13:01:22','0000-00-00 00:00:00',40177),(536,8,6,'Russian','2011-01-14 13:01:22','0000-00-00 00:00:00',40178),(537,8,7,'Russian','2011-01-14 13:01:22','0000-00-00 00:00:00',40303),(538,8,8,'Русский','2011-01-14 13:01:22','0000-00-00 00:00:00',198029),(539,8,9,'Russian','2011-01-14 13:01:22','0000-00-00 00:00:00',40305),(540,8,10,'Russian','2011-01-14 13:01:22','0000-00-00 00:00:00',40306),(541,8,11,'Russian','2011-01-14 13:01:22','0000-00-00 00:00:00',40307),(542,8,12,'Russian','2011-01-14 13:01:22','0000-00-00 00:00:00',40308),(543,8,13,'Russian','2011-01-14 13:01:22','0000-00-00 00:00:00',40309),(544,8,14,'Russian','2011-01-14 13:01:22','0000-00-00 00:00:00',40310),(545,8,15,'Russian','2011-01-14 13:01:22','0000-00-00 00:00:00',40311),(546,8,16,'Russian','2011-01-14 13:01:22','0000-00-00 00:00:00',40312),(547,8,17,'Russian','2011-01-14 13:01:22','0000-00-00 00:00:00',40313),(548,8,25,'Російська','2011-01-14 13:01:22','0000-00-00 00:00:00',205066),(549,8,35,'Russian','2011-01-14 13:01:22','0000-00-00 00:00:00',486121),(550,4,2,'German','2011-01-14 13:01:22','0000-00-00 00:00:00',14089),(551,4,3,'German','2011-01-14 13:01:22','0000-00-00 00:00:00',14090),(552,4,4,'German','2011-01-14 13:01:22','0000-00-00 00:00:00',18226),(553,4,5,'','2011-01-14 13:01:22','0000-00-00 00:00:00',104573),(554,4,6,'German','2011-01-14 13:01:22','0000-00-00 00:00:00',26490),(555,4,7,'Tysk','2011-01-14 13:01:22','0000-00-00 00:00:00',38092),(556,4,8,'Немецкий','2011-01-14 13:01:22','0000-00-00 00:00:00',198025),(557,4,9,'German','2011-01-14 13:01:22','0000-00-00 00:00:00',40264),(558,4,10,'German','2011-01-14 13:01:22','0000-00-00 00:00:00',40265),(559,4,11,'German','2011-01-14 13:01:22','0000-00-00 00:00:00',40266),(560,4,12,'German','2011-01-14 13:01:22','0000-00-00 00:00:00',40267),(561,4,13,'German','2011-01-14 13:01:22','0000-00-00 00:00:00',40268),(562,4,14,'German','2011-01-14 13:01:22','0000-00-00 00:00:00',40269),(563,4,15,'German','2011-01-14 13:01:22','0000-00-00 00:00:00',40270),(564,4,16,'German','2011-01-14 13:01:22','0000-00-00 00:00:00',40271),(565,4,17,'German','2011-01-14 13:01:22','0000-00-00 00:00:00',40272),(566,4,25,'Німецька','2011-01-14 13:01:22','0000-00-00 00:00:00',205062),(567,4,35,'German','2011-01-14 13:01:22','0000-00-00 00:00:00',486117),(568,34,2,'Slovenian','2011-01-14 13:01:22','0000-00-00 00:00:00',412012),(569,34,3,'Slovenian','2011-01-14 13:01:22','0000-00-00 00:00:00',412013),(570,34,4,'Slovenian','2011-01-14 13:01:22','0000-00-00 00:00:00',412014),(571,34,5,'Slovenian','2011-01-14 13:01:22','0000-00-00 00:00:00',412015),(572,34,6,'Slovenian','2011-01-14 13:01:22','0000-00-00 00:00:00',412016),(573,37,2,'Traditional Chinese','2011-01-14 13:01:22','0000-00-00 00:00:00',511193),(574,37,3,'Traditional Chinese','2011-01-14 13:01:22','0000-00-00 00:00:00',511194),(575,37,4,'Traditional Chinese','2011-01-14 13:01:22','0000-00-00 00:00:00',511195),(576,37,5,'Traditional Chinese','2011-01-14 13:01:22','0000-00-00 00:00:00',511196),(577,37,6,'Traditional Chinese','2011-01-14 13:01:22','0000-00-00 00:00:00',511197),(578,19,2,'Norwegian','2011-01-14 13:01:22','0000-00-00 00:00:00',118814),(579,19,3,'Norwegian','2011-01-14 13:01:22','0000-00-00 00:00:00',118815),(580,19,4,'Norwegian','2011-01-14 13:01:22','0000-00-00 00:00:00',118816),(581,19,5,'Norwegian','2011-01-14 13:01:22','0000-00-00 00:00:00',118817),(582,19,6,'Norwegian','2011-01-14 13:01:22','0000-00-00 00:00:00',118818),(583,19,8,'Норвежский','2011-01-14 13:01:22','0000-00-00 00:00:00',198040),(584,19,25,'Норвезька','2011-01-14 13:01:22','0000-00-00 00:00:00',205077),(585,5,2,'Italian','2011-01-14 13:01:22','0000-00-00 00:00:00',14092),(586,5,3,'Italian','2011-01-14 13:01:22','0000-00-00 00:00:00',14093),(587,5,4,'Italian','2011-01-14 13:01:22','0000-00-00 00:00:00',18227),(588,5,5,'','2011-01-14 13:01:22','0000-00-00 00:00:00',104579),(589,5,6,'Italian','2011-01-14 13:01:22','0000-00-00 00:00:00',26491),(590,5,7,'Italiensk','2011-01-14 13:01:22','0000-00-00 00:00:00',38093),(591,5,8,'Итальянский','2011-01-14 13:01:22','0000-00-00 00:00:00',198026),(592,5,9,'Italian','2011-01-14 13:01:22','0000-00-00 00:00:00',40274),(593,5,10,'Italian','2011-01-14 13:01:22','0000-00-00 00:00:00',40275),(594,5,11,'Italian','2011-01-14 13:01:22','0000-00-00 00:00:00',40276),(595,5,12,'Italian','2011-01-14 13:01:22','0000-00-00 00:00:00',40277),(596,5,13,'Italian','2011-01-14 13:01:22','0000-00-00 00:00:00',40278),(597,5,14,'Italian','2011-01-14 13:01:22','0000-00-00 00:00:00',40279),(598,5,15,'Italian','2011-01-14 13:01:22','0000-00-00 00:00:00',40280),(599,5,16,'Italian','2011-01-14 13:01:22','0000-00-00 00:00:00',40281),(600,5,17,'Italian','2011-01-14 13:01:22','0000-00-00 00:00:00',40282),(601,5,25,'Італійська','2011-01-14 13:01:22','0000-00-00 00:00:00',205063),(602,5,35,'Italian','2011-01-14 13:01:22','0000-00-00 00:00:00',486118),(603,2,2,'Dutch','2011-01-14 13:01:21','0000-00-00 00:00:00',4),(604,1,2,'English','2011-01-14 13:01:21','0000-00-00 00:00:00',2);
/*!40000 ALTER TABLE `vocabulary` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-02-11 11:59:17
