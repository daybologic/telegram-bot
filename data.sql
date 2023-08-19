-- MySQL dump 10.19  Distrib 10.3.37-MariaDB, for Linux (x64)
--
-- Host: localhost    Database: telegram_bot
-- ------------------------------------------------------
-- Server version	10.3.37-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `audit_event_type`
--

DROP TABLE IF EXISTS `audit_event_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audit_event_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mnemonic` char(64) NOT NULL,
  `description` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mnemonic` (`mnemonic`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_event_type`
--

LOCK TABLES `audit_event_type` WRITE;
/*!40000 ALTER TABLE `audit_event_type` DISABLE KEYS */;
INSERT INTO `audit_event_type` VALUES (1,'START','The bot has started, or restarted');
INSERT INTO `audit_event_type` VALUES (3,'MEME_ADD_FAIL','An attempt to add a meme has failed');
INSERT INTO `audit_event_type` VALUES (4,'MEME_ADD_SUCCESS','Successfully added a meme');
INSERT INTO `audit_event_type` VALUES (5,'MEME_RM_FAIL','An attempt to remove a meme has failed');
INSERT INTO `audit_event_type` VALUES (6,'MEME_RM_SUCCESS','Successfully removed a meme');
INSERT INTO `audit_event_type` VALUES (7,'WEATHER_LOCATION_UPDATE','Changed default location for a user\'s weather lookups');
INSERT INTO `audit_event_type` VALUES (8,'WEATHER_API','A weather lookup which required the API and could not be resolved via cache');
INSERT INTO `audit_event_type` VALUES (9,'WEATHER_LOOKUP','A user looked up weather for a location');
INSERT INTO `audit_event_type` VALUES (10,'CAT_API','An http.cat lookup which could not be required via cache');
INSERT INTO `audit_event_type` VALUES (11,'CAT_LOOKUP','A /cat command was used by a user');
INSERT INTO `audit_event_type` VALUES (12,'MEME_USE_SUCCESS','A /meme was used successfully (meme found)');
INSERT INTO `audit_event_type` VALUES (13,'MEME_NOT_FOUND','A meme was not found, see also COMMAND_NOT_FOUND');
INSERT INTO `audit_event_type` VALUES (15,'COMMAND_NOT_FOUND','A command was not found, see also MEME_NOT_FOUND');
INSERT INTO `audit_event_type` VALUES (16,'COUNTER_INC','A user incremented a counter');
INSERT INTO `audit_event_type` VALUES (17,'COUNTER_FETCH','A user fetched the contents of a counter');
INSERT INTO `audit_event_type` VALUES (18,'CURRENCY_API','A user performed a currency conversion which could not be resolved by cache');
INSERT INTO `audit_event_type` VALUES (19,'CURRENCY_LOOKUP','A user performed a currency conversion');
INSERT INTO `audit_event_type` VALUES (20,'ADMIN_PROMOTE','A user has been promoted to an admin');
INSERT INTO `audit_event_type` VALUES (21,'ADMIN_DEMOTE','A user has been removed as an admin');
INSERT INTO `audit_event_type` VALUES (22,'ADMIN_USER_BAN','An admin has restricted access to the bot, for another user');
INSERT INTO `audit_event_type` VALUES (23,'ADMIN_USER_UNBAN','An admin has allowed another user to access the bot, lifting an ADMIN_USER_BAN');
INSERT INTO `audit_event_type` VALUES (24,'MEME_API','A meme request could not be satisfied by cache, remote lookup required');
INSERT INTO `audit_event_type` VALUES (25,'MEME_SEARCH','Seach meme directory');
INSERT INTO `audit_event_type` VALUES (26,'MUSIC_SEARCH','Search for music');
INSERT INTO `audit_event_type` VALUES (27,'UUID_INFO','Validate a UUID or extract information');
INSERT INTO `audit_event_type` VALUES (28,'UUID_GEN','Generate one or more UUIDs');
INSERT INTO `audit_event_type` VALUES (29,'UUID_API','Remote API used for UUID generation (associated cost)');
INSERT INTO `audit_event_type` VALUES (30,'COST_AWS_LAMBDA','An action resultsed in a chargeable AWS Lambda call');
INSERT INTO `audit_event_type` VALUES (31,'COST_AWS_S3','An action resulted in a chargeable AWS S3 call');
INSERT INTO `audit_event_type` VALUES (32,'COST_AWS_DYNAMO','An action resulted in a chargeable AWS DynamoDB');
INSERT INTO `audit_event_type` VALUES (33,'GENDER_SET','User requested gender change');
INSERT INTO `audit_event_type` VALUES (34,'GENDER_API','A gender set/get resulted in a call which could not be satisfied by cache');
INSERT INTO `audit_event_type` VALUES (35,'INSULTED','User requested to be insulted');
INSERT INTO `audit_event_type` VALUES (36,'ADMIN_UNAUTH','An attempt to perform an action reserved admins has been attempted and rejected');
INSERT INTO `audit_event_type` VALUES (37,'CRASH','Unexplained bot exit!');
INSERT INTO `audit_event_type` VALUES (38,'KARMA_INC','A user recommended karma in the next life, for something');
INSERT INTO `audit_event_type` VALUES (39,'KARMA_DEC','A user unrecommended karma in the next life, for something');
INSERT INTO `audit_event_type` VALUES (40,'KARMA_GET','A user looked up the karma, for something');
INSERT INTO `audit_event_type` VALUES (41,'KARMA_REPORT','Karma report generated');
INSERT INTO `audit_event_type` VALUES (42,'COMMAND_RATE_LIMIT','Rate-limit reached; cool-off in effect');
/*!40000 ALTER TABLE `audit_event_type` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-08-19  0:06:52
