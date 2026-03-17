/*
Navicat MySQL Data Transfer

Source Server         : localhost_3306
Source Server Version : 80017
Source Host           : localhost:3306
Source Database       : mekanrp

Target Server Type    : MYSQL
Target Server Version : 80017
File Encoding         : 65001

Date: 2026-03-17 13:57:19
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for `accounts`
-- ----------------------------
DROP TABLE IF EXISTS `accounts`;
CREATE TABLE `accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `password` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `salt` char(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `serial` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `ip` varchar(39) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `banned` tinyint(1) NOT NULL DEFAULT '0',
  `register_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `last_login` datetime DEFAULT NULL,
  `admin_level` tinyint(2) NOT NULL DEFAULT '0',
  `manager_level` tinyint(1) NOT NULL DEFAULT '0',
  `admin_reports` int(11) NOT NULL DEFAULT '0',
  `admin_note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `max_characters` tinyint(3) NOT NULL DEFAULT '3',
  `admin_jailed` tinyint(1) NOT NULL DEFAULT '0',
  `admin_jail_time` int(11) NOT NULL DEFAULT '0',
  `admin_jail_by` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `admin_jail_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `donater` tinyint(1) NOT NULL DEFAULT '0',
  `youtuber` tinyint(1) NOT NULL DEFAULT '0',
  `rp_plus` tinyint(1) NOT NULL DEFAULT '0',
  `balance` int(11) NOT NULL DEFAULT '0',
  `promo_used` tinyint(1) NOT NULL DEFAULT '0',
  `total_hours_played` int(11) NOT NULL DEFAULT '0',
  `rp_confirm` tinyint(1) NOT NULL DEFAULT '0',
  `probation_status` tinyint(1) NOT NULL,
  `probation_end` int(11) NOT NULL,
  `probation_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of accounts
-- ----------------------------

-- ----------------------------
-- Table structure for `admin_history`
-- ----------------------------
DROP TABLE IF EXISTS `admin_history`;
CREATE TABLE `admin_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `user_char` int(11) NOT NULL DEFAULT '0',
  `admin` int(11) NOT NULL DEFAULT '0',
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `action` tinyint(4) NOT NULL DEFAULT '6',
  `duration` int(11) NOT NULL DEFAULT '0',
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of admin_history
-- ----------------------------

-- ----------------------------
-- Table structure for `atms`
-- ----------------------------
DROP TABLE IF EXISTS `atms`;
CREATE TABLE `atms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `rotation` float NOT NULL,
  `interior` int(11) NOT NULL DEFAULT '0',
  `dimension` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of atms
-- ----------------------------

-- ----------------------------
-- Table structure for `bank_history`
-- ----------------------------
DROP TABLE IF EXISTS `bank_history`;
CREATE TABLE `bank_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `character_id` int(11) NOT NULL,
  `action` tinyint(4) NOT NULL,
  `amount` int(11) NOT NULL,
  `timestamp` datetime NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of bank_history
-- ----------------------------

-- ----------------------------
-- Table structure for `bans`
-- ----------------------------
DROP TABLE IF EXISTS `bans`;
CREATE TABLE `bans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `serial` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `ip` varchar(39) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `admin` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `date` datetime DEFAULT NULL,
  `end_tick` int(11) DEFAULT '-1',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of bans
-- ----------------------------

-- ----------------------------
-- Table structure for `businesses`
-- ----------------------------
DROP TABLE IF EXISTS `businesses`;
CREATE TABLE `businesses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `interior_id` int(11) NOT NULL,
  `owner_char_id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(128) NOT NULL DEFAULT 'İsimsiz İşyeri',
  `is_open` tinyint(1) NOT NULL DEFAULT '0',
  `image_url` text,
  `advertisement_text` varchar(255) DEFAULT 'İşyerimiz hizmetinizdedir!',
  `interior_name` varchar(128) DEFAULT 'Bilinmeyen Lokasyon',
  `position_x` float DEFAULT '0',
  `position_y` float DEFAULT '0',
  `position_z` float DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `interior_id` (`interior_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of businesses
-- ----------------------------

-- ----------------------------
-- Table structure for `characters`
-- ----------------------------
DROP TABLE IF EXISTS `characters`;
CREATE TABLE `characters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(22) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `x` float NOT NULL DEFAULT '0',
  `y` float NOT NULL DEFAULT '0',
  `z` float NOT NULL DEFAULT '0',
  `rotation` float NOT NULL DEFAULT '0',
  `interior` int(11) NOT NULL DEFAULT '0',
  `dimension` int(11) NOT NULL,
  `health` float NOT NULL DEFAULT '100',
  `armor` float NOT NULL DEFAULT '0',
  `skin` int(11) NOT NULL DEFAULT '240',
  `clothing_id` int(11) NOT NULL DEFAULT '0',
  `model` int(11) NOT NULL DEFAULT '0',
  `money` int(11) NOT NULL DEFAULT '1000',
  `bank_money` int(11) NOT NULL DEFAULT '0',
  `age` tinyint(3) NOT NULL DEFAULT '16',
  `gender` tinyint(1) NOT NULL DEFAULT '0',
  `height` smallint(5) NOT NULL DEFAULT '150',
  `weight` smallint(5) NOT NULL DEFAULT '50',
  `race` tinyint(3) NOT NULL DEFAULT '1',
  `identity_number` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `cked` tinyint(1) NOT NULL DEFAULT '0',
  `ck_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `walking_style` int(11) NOT NULL DEFAULT '118',
  `fighting_style` int(11) NOT NULL DEFAULT '4',
  `creation_date` datetime DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `last_area` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `max_vehicles` tinyint(3) NOT NULL DEFAULT '5',
  `max_interiors` tinyint(3) NOT NULL DEFAULT '5',
  `tags` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `custom_animation` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `faction_leader` tinyint(1) NOT NULL DEFAULT '0',
  `hours_played` int(11) NOT NULL DEFAULT '0',
  `minutes_played` int(11) NOT NULL DEFAULT '0',
  `level` tinyint(3) NOT NULL DEFAULT '1',
  `box_hours` int(11) NOT NULL DEFAULT '0',
  `box_count` int(11) NOT NULL DEFAULT '0',
  `pd_jailed` tinyint(1) NOT NULL DEFAULT '0',
  `restrained` tinyint(1) NOT NULL DEFAULT '0',
  `restrained_item` tinyint(2) NOT NULL DEFAULT '0',
  `hunger` tinyint(3) NOT NULL DEFAULT '100',
  `thirst` tinyint(3) NOT NULL DEFAULT '100',
  `car_license` tinyint(1) NOT NULL DEFAULT '0',
  `bike_license` tinyint(1) NOT NULL DEFAULT '0',
  `boat_license` tinyint(1) NOT NULL DEFAULT '0',
  `job` tinyint(1) NOT NULL DEFAULT '0',
  `duty` tinyint(1) NOT NULL DEFAULT '0',
  `mechanic` tinyint(1) NOT NULL DEFAULT '0',
  `weapon_order_rights` int(11) NOT NULL DEFAULT '0',
  `has_weapon_order` tinyint(1) NOT NULL DEFAULT '0',
  `ikametkah` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `ikametkah_last_change` datetime DEFAULT NULL,
  `is_dead` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Oyuncu baygın mı? 1=Evet, 0=Hayır',
  `death_x` float DEFAULT NULL COMMENT 'Baygın olduğu X koordinatı',
  `death_y` float DEFAULT NULL COMMENT 'Baygın olduğu Y koordinatı',
  `death_z` float DEFAULT NULL COMMENT 'Baygın olduğu Z koordinatı',
  `death_rotation` float DEFAULT NULL COMMENT 'Baygın olduğu rotasyon',
  `death_interior` int(11) DEFAULT NULL COMMENT 'Baygın olduğu interior',
  `death_dimension` int(11) DEFAULT NULL COMMENT 'Baygın olduğu dimension',
  `death_time` timestamp NULL DEFAULT NULL COMMENT 'Ne zaman bayıldı',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_is_dead` (`is_dead`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of characters
-- ----------------------------

-- ----------------------------
-- Table structure for `characters_faction`
-- ----------------------------
DROP TABLE IF EXISTS `characters_faction`;
CREATE TABLE `characters_faction` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `character_id` int(11) NOT NULL,
  `faction_id` int(11) NOT NULL,
  `faction_rank` int(11) NOT NULL,
  `faction_leader` int(11) NOT NULL,
  `faction_phone` int(11) DEFAULT NULL,
  `faction_perks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of characters_faction
-- ----------------------------

-- ----------------------------
-- Table structure for `clothing`
-- ----------------------------
DROP TABLE IF EXISTS `clothing`;
CREATE TABLE `clothing` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `skin` int(11) NOT NULL,
  `url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `owner` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of clothing
-- ----------------------------

-- ----------------------------
-- Table structure for `duty_allowed`
-- ----------------------------
DROP TABLE IF EXISTS `duty_allowed`;
CREATE TABLE `duty_allowed` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `faction` int(11) NOT NULL,
  `itemID` int(11) NOT NULL,
  `itemValue` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of duty_allowed
-- ----------------------------

-- ----------------------------
-- Table structure for `duty_custom`
-- ----------------------------
DROP TABLE IF EXISTS `duty_custom`;
CREATE TABLE `duty_custom` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `faction_id` int(11) NOT NULL,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `skins` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `locations` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `items` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of duty_custom
-- ----------------------------

-- ----------------------------
-- Table structure for `duty_locations`
-- ----------------------------
DROP TABLE IF EXISTS `duty_locations`;
CREATE TABLE `duty_locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `faction_id` int(11) NOT NULL,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `x` int(11) DEFAULT NULL,
  `y` int(11) DEFAULT NULL,
  `z` int(11) DEFAULT NULL,
  `radius` int(11) DEFAULT NULL,
  `dimension` int(11) DEFAULT '0',
  `interior` int(11) DEFAULT '0',
  `vehicle_id` int(11) DEFAULT NULL,
  `model` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of duty_locations
-- ----------------------------

-- ----------------------------
-- Table structure for `elevators`
-- ----------------------------
DROP TABLE IF EXISTS `elevators`;
CREATE TABLE `elevators` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `x` decimal(10,6) DEFAULT '0.000000',
  `y` decimal(10,6) DEFAULT '0.000000',
  `z` decimal(10,6) DEFAULT '0.000000',
  `tpx` decimal(10,6) DEFAULT '0.000000',
  `tpy` decimal(10,6) DEFAULT '0.000000',
  `tpz` decimal(10,6) DEFAULT '0.000000',
  `dimensionwithin` int(11) DEFAULT '0',
  `interiorwithin` int(11) DEFAULT '0',
  `dimension` int(11) DEFAULT '0',
  `interior` int(11) DEFAULT '0',
  `car` tinyint(3) unsigned DEFAULT '0',
  `disabled` tinyint(3) unsigned DEFAULT '0',
  `rot` decimal(10,6) DEFAULT '0.000000',
  `tprot` decimal(10,6) DEFAULT '0.000000',
  `oneway` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of elevators
-- ----------------------------

-- ----------------------------
-- Table structure for `factions`
-- ----------------------------
DROP TABLE IF EXISTS `factions`;
CREATE TABLE `factions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `money` bigint(20) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `rank_order` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `motd` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `fnote` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `max_interiors` int(11) unsigned NOT NULL DEFAULT '20',
  `max_vehicles` int(11) unsigned NOT NULL DEFAULT '40',
  `before_tax_value` int(6) NOT NULL DEFAULT '0',
  `before_wage_charge` int(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of factions
-- ----------------------------

-- ----------------------------
-- Table structure for `faction_ranks`
-- ----------------------------
DROP TABLE IF EXISTS `faction_ranks`;
CREATE TABLE `faction_ranks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `faction_id` int(11) DEFAULT NULL,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `permissions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `isDefault` int(11) NOT NULL DEFAULT '0',
  `isLeader` int(11) NOT NULL DEFAULT '0',
  `wage` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of faction_ranks
-- ----------------------------

-- ----------------------------
-- Table structure for `feedbacks`
-- ----------------------------
DROP TABLE IF EXISTS `feedbacks`;
CREATE TABLE `feedbacks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL,
  `from_id` int(11) NOT NULL,
  `star_count` tinyint(1) NOT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of feedbacks
-- ----------------------------

-- ----------------------------
-- Table structure for `gates`
-- ----------------------------
DROP TABLE IF EXISTS `gates`;
CREATE TABLE `gates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `objectID` int(11) NOT NULL,
  `startX` float NOT NULL,
  `startY` float NOT NULL,
  `startZ` float NOT NULL,
  `startRX` float NOT NULL,
  `startRY` float NOT NULL,
  `startRZ` float NOT NULL,
  `endX` float NOT NULL,
  `endY` float NOT NULL,
  `endZ` float NOT NULL,
  `endRX` float NOT NULL,
  `endRY` float NOT NULL,
  `endRZ` float NOT NULL,
  `gateType` tinyint(3) unsigned NOT NULL,
  `autocloseTime` int(11) NOT NULL,
  `movementTime` int(11) NOT NULL,
  `objectDimension` int(11) NOT NULL,
  `objectInterior` int(11) NOT NULL,
  `gateSecurityParameters` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `creator` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL DEFAULT '',
  `createdDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `adminNote` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL DEFAULT '',
  `triggerDistance` float DEFAULT NULL,
  `triggerDistanceVehicle` float DEFAULT NULL,
  `sound` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT 'metalgate',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of gates
-- ----------------------------

-- ----------------------------
-- Table structure for `giveaway`
-- ----------------------------
DROP TABLE IF EXISTS `giveaway`;
CREATE TABLE `giveaway` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of giveaway
-- ----------------------------

-- ----------------------------
-- Table structure for `information_icons`
-- ----------------------------
DROP TABLE IF EXISTS `information_icons`;
CREATE TABLE `information_icons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `x` float DEFAULT NULL,
  `y` float DEFAULT NULL,
  `z` float DEFAULT NULL,
  `interior` float DEFAULT NULL,
  `dimension` float DEFAULT NULL,
  `created_by` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of information_icons
-- ----------------------------

-- ----------------------------
-- Table structure for `interiors`
-- ----------------------------
DROP TABLE IF EXISTS `interiors`;
CREATE TABLE `interiors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `x` float DEFAULT '0',
  `y` float DEFAULT '0',
  `z` float DEFAULT '0',
  `type` int(11) DEFAULT '0',
  `owner` int(11) DEFAULT '-1',
  `locked` int(11) DEFAULT '0',
  `cost` int(11) DEFAULT '0',
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `interior` int(11) DEFAULT '0',
  `interiorx` float DEFAULT '0',
  `interiory` float DEFAULT '0',
  `interiorz` float DEFAULT '0',
  `dimensionwithin` int(11) DEFAULT '0',
  `interiorwithin` int(11) DEFAULT '0',
  `angle` float DEFAULT '0',
  `angleexit` float DEFAULT '0',
  `supplies` int(11) DEFAULT '0',
  `safepositionX` float DEFAULT NULL,
  `safepositionY` float DEFAULT NULL,
  `safepositionZ` float DEFAULT NULL,
  `safepositionRZ` float DEFAULT NULL,
  `disabled` tinyint(3) unsigned DEFAULT '0',
  `last_used` datetime NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  `deleted` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL DEFAULT '0',
  `deletedDate` datetime DEFAULT NULL,
  `createdDate` datetime DEFAULT NULL,
  `creator` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `keypad_lock` int(11) DEFAULT NULL,
  `keypad_lock_pw` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `keypad_lock_auto` tinyint(1) DEFAULT NULL,
  `faction` int(11) DEFAULT '0',
  `furniture` int(1) NOT NULL DEFAULT '1',
  `interior_id` int(11) DEFAULT NULL,
  `tokenUsed` int(1) NOT NULL DEFAULT '0',
  `settings` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of interiors
-- ----------------------------

-- ----------------------------
-- Table structure for `interior_business`
-- ----------------------------
DROP TABLE IF EXISTS `interior_business`;
CREATE TABLE `interior_business` (
  `intID` int(11) NOT NULL,
  `cashbox` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`intID`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of interior_business
-- ----------------------------

-- ----------------------------
-- Table structure for `interior_logs`
-- ----------------------------
DROP TABLE IF EXISTS `interior_logs`;
CREATE TABLE `interior_logs` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `date` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `intID` int(11) DEFAULT NULL,
  `action` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `actor` int(11) DEFAULT NULL,
  PRIMARY KEY (`log_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of interior_logs
-- ----------------------------

-- ----------------------------
-- Table structure for `interior_notes`
-- ----------------------------
DROP TABLE IF EXISTS `interior_notes`;
CREATE TABLE `interior_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intid` int(11) NOT NULL,
  `creator` int(11) NOT NULL DEFAULT '0',
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `date` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of interior_notes
-- ----------------------------

-- ----------------------------
-- Table structure for `interior_textures`
-- ----------------------------
DROP TABLE IF EXISTS `interior_textures`;
CREATE TABLE `interior_textures` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `interior` int(11) NOT NULL,
  `texture` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of interior_textures
-- ----------------------------

-- ----------------------------
-- Table structure for `items`
-- ----------------------------
DROP TABLE IF EXISTS `items`;
CREATE TABLE `items` (
  `index` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `type` tinyint(3) unsigned NOT NULL,
  `owner` int(10) unsigned NOT NULL,
  `itemID` int(11) NOT NULL,
  `itemValue` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `protected` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`index`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of items
-- ----------------------------

-- ----------------------------
-- Table structure for `jailed`
-- ----------------------------
DROP TABLE IF EXISTS `jailed`;
CREATE TABLE `jailed` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `character_id` int(11) NOT NULL,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `jail_time` bigint(20) NOT NULL,
  `conviction_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `charges` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `cell` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `fine` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of jailed
-- ----------------------------

-- ----------------------------
-- Table structure for `jobs`
-- ----------------------------
DROP TABLE IF EXISTS `jobs`;
CREATE TABLE `jobs` (
  `jobID` int(11) NOT NULL DEFAULT '0',
  `jobCharID` int(11) NOT NULL DEFAULT '-1',
  `jobLevel` int(11) NOT NULL DEFAULT '1',
  `jobProgress` int(11) NOT NULL DEFAULT '0',
  `jobTruckingRuns` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of jobs
-- ----------------------------

-- ----------------------------
-- Table structure for `jobs_trucker_orders`
-- ----------------------------
DROP TABLE IF EXISTS `jobs_trucker_orders`;
CREATE TABLE `jobs_trucker_orders` (
  `orderID` int(11) NOT NULL AUTO_INCREMENT,
  `orderX` float NOT NULL DEFAULT '0',
  `orderY` float NOT NULL DEFAULT '0',
  `orderZ` float NOT NULL DEFAULT '0',
  `orderName` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `orderInterior` int(11) NOT NULL DEFAULT '0',
  `orderSupplies` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  PRIMARY KEY (`orderID`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of jobs_trucker_orders
-- ----------------------------

-- ----------------------------
-- Table structure for `lifeinvader_accounts`
-- ----------------------------
DROP TABLE IF EXISTS `lifeinvader_accounts`;
CREATE TABLE `lifeinvader_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `character_id` int(11) NOT NULL,
  `display_name` varchar(64) NOT NULL,
  `created_at` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `character_id` (`character_id`),
  KEY `character_id_idx` (`character_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of lifeinvader_accounts
-- ----------------------------

-- ----------------------------
-- Table structure for `lifeinvader_likes`
-- ----------------------------
DROP TABLE IF EXISTS `lifeinvader_likes`;
CREATE TABLE `lifeinvader_likes` (
  `post_id` int(11) NOT NULL,
  `character_id` int(11) NOT NULL,
  `created_at` int(11) NOT NULL,
  PRIMARY KEY (`post_id`,`character_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of lifeinvader_likes
-- ----------------------------

-- ----------------------------
-- Table structure for `lifeinvader_posts`
-- ----------------------------
DROP TABLE IF EXISTS `lifeinvader_posts`;
CREATE TABLE `lifeinvader_posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `character_id` int(11) NOT NULL,
  `content` varchar(280) NOT NULL,
  `created_at` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `character_id_idx` (`character_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of lifeinvader_posts
-- ----------------------------

-- ----------------------------
-- Table structure for `logs`
-- ----------------------------
DROP TABLE IF EXISTS `logs`;
CREATE TABLE `logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `log_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of logs
-- ----------------------------

-- ----------------------------
-- Table structure for `maps`
-- ----------------------------
DROP TABLE IF EXISTS `maps`;
CREATE TABLE `maps` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `preview` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `purposes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `used_by` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `reasons` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `approved` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `enabled` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `uploader` int(10) unsigned NOT NULL,
  `type` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL DEFAULT 'exterior',
  `upload_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `reviewer` int(10) unsigned DEFAULT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of maps
-- ----------------------------

-- ----------------------------
-- Table structure for `maps_objects`
-- ----------------------------
DROP TABLE IF EXISTS `maps_objects`;
CREATE TABLE `maps_objects` (
  `index` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `map_id` int(10) unsigned NOT NULL,
  `id` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `interior` int(11) NOT NULL,
  `dimension` int(11) DEFAULT NULL,
  `collisions` tinyint(1) DEFAULT NULL,
  `breakable` tinyint(1) DEFAULT NULL,
  `radius` double unsigned DEFAULT NULL,
  `model` int(10) unsigned NOT NULL,
  `lodModel` int(10) unsigned DEFAULT NULL,
  `posX` double NOT NULL,
  `posY` double NOT NULL,
  `posZ` double NOT NULL,
  `rotX` double NOT NULL,
  `rotY` double NOT NULL,
  `rotZ` double NOT NULL,
  `doublesided` tinyint(1) unsigned DEFAULT NULL,
  `scale` double unsigned DEFAULT NULL,
  `alpha` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`index`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of maps_objects
-- ----------------------------

-- ----------------------------
-- Table structure for `market_history`
-- ----------------------------
DROP TABLE IF EXISTS `market_history`;
CREATE TABLE `market_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `price` int(11) NOT NULL,
  `purchased_at` datetime NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of market_history
-- ----------------------------

-- ----------------------------
-- Table structure for `mechanics`
-- ----------------------------
DROP TABLE IF EXISTS `mechanics`;
CREATE TABLE `mechanics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `employees` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `interior` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of mechanics
-- ----------------------------

-- ----------------------------
-- Table structure for `objects`
-- ----------------------------
DROP TABLE IF EXISTS `objects`;
CREATE TABLE `objects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model` int(11) NOT NULL DEFAULT '0',
  `posX` float(12,7) NOT NULL DEFAULT '0.0000000',
  `posY` float(12,7) NOT NULL DEFAULT '0.0000000',
  `posZ` float(12,7) NOT NULL DEFAULT '0.0000000',
  `rotX` float(12,7) NOT NULL DEFAULT '0.0000000',
  `rotY` float(12,7) NOT NULL DEFAULT '0.0000000',
  `rotZ` float(12,7) NOT NULL DEFAULT '0.0000000',
  `interior` int(11) NOT NULL,
  `dimension` int(11) NOT NULL,
  `comment` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `solid` int(11) NOT NULL DEFAULT '1',
  `doublesided` int(11) NOT NULL DEFAULT '0',
  `scale` float(12,7) DEFAULT NULL,
  `breakable` int(11) NOT NULL DEFAULT '0',
  `alpha` int(11) NOT NULL DEFAULT '255',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of objects
-- ----------------------------

-- ----------------------------
-- Table structure for `phones`
-- ----------------------------
DROP TABLE IF EXISTS `phones`;
CREATE TABLE `phones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `character_id` int(10) unsigned NOT NULL,
  `phone_number` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `phone_number` (`phone_number`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of phones
-- ----------------------------

-- ----------------------------
-- Table structure for `phone_call_history`
-- ----------------------------
DROP TABLE IF EXISTS `phone_call_history`;
CREATE TABLE `phone_call_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `caller_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `receiver_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `call_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `in_call_time` bigint(20) DEFAULT NULL,
  `created_at` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of phone_call_history
-- ----------------------------

-- ----------------------------
-- Table structure for `phone_contacts`
-- ----------------------------
DROP TABLE IF EXISTS `phone_contacts`;
CREATE TABLE `phone_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `target_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `is_favorite` tinyint(1) NOT NULL DEFAULT '0',
  `is_blocked` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of phone_contacts
-- ----------------------------

-- ----------------------------
-- Table structure for `phone_gallery`
-- ----------------------------
DROP TABLE IF EXISTS `phone_gallery`;
CREATE TABLE `phone_gallery` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `photo_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `size_width` int(11) DEFAULT '0',
  `size_height` int(11) DEFAULT '0',
  `exif_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `exif_location` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of phone_gallery
-- ----------------------------

-- ----------------------------
-- Table structure for `radio_stations`
-- ----------------------------
DROP TABLE IF EXISTS `radio_stations`;
CREATE TABLE `radio_stations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `station_name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `source` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `owner` int(11) NOT NULL DEFAULT '0',
  `register_date` datetime DEFAULT NULL,
  `expire_date` datetime DEFAULT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `order` int(5) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of radio_stations
-- ----------------------------

-- ----------------------------
-- Table structure for `shops`
-- ----------------------------
DROP TABLE IF EXISTS `shops`;
CREATE TABLE `shops` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `x` float DEFAULT '0',
  `y` float DEFAULT '0',
  `z` float DEFAULT '0',
  `rotation` float NOT NULL DEFAULT '0',
  `interior` int(11) DEFAULT '0',
  `dimension` int(11) DEFAULT '0',
  `type` tinyint(4) DEFAULT '0',
  `skin` int(11) DEFAULT '-1',
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of shops
-- ----------------------------

-- ----------------------------
-- Table structure for `staff_changelogs`
-- ----------------------------
DROP TABLE IF EXISTS `staff_changelogs`;
CREATE TABLE `staff_changelogs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `team` int(11) NOT NULL,
  `from_rank` int(11) NOT NULL,
  `to_rank` int(11) DEFAULT NULL,
  `by` int(11) DEFAULT NULL,
  `details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of staff_changelogs
-- ----------------------------

-- ----------------------------
-- Table structure for `tempobjects`
-- ----------------------------
DROP TABLE IF EXISTS `tempobjects`;
CREATE TABLE `tempobjects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model` int(11) NOT NULL DEFAULT '0',
  `posX` float(12,7) NOT NULL DEFAULT '0.0000000',
  `posY` float(12,7) NOT NULL DEFAULT '0.0000000',
  `posZ` float(12,7) NOT NULL DEFAULT '0.0000000',
  `rotX` float(12,7) NOT NULL DEFAULT '0.0000000',
  `rotY` float(12,7) NOT NULL DEFAULT '0.0000000',
  `rotZ` float(12,7) NOT NULL DEFAULT '0.0000000',
  `interior` int(11) NOT NULL,
  `dimension` int(11) NOT NULL,
  `comment` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `solid` int(11) DEFAULT '1',
  `doublesided` int(11) DEFAULT '0',
  `scale` float(12,7) DEFAULT '1.0000000',
  `breakable` int(11) DEFAULT '0',
  `alpha` int(11) NOT NULL DEFAULT '255',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of tempobjects
-- ----------------------------

-- ----------------------------
-- Table structure for `transferler`
-- ----------------------------
DROP TABLE IF EXISTS `transferler`;
CREATE TABLE `transferler` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_account_id` int(11) NOT NULL,
  `target_account_id` int(11) NOT NULL,
  `sender_name` varchar(64) NOT NULL,
  `target_name` varchar(64) NOT NULL,
  `amount` int(11) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `created_at` datetime NOT NULL,
  `approved_by` varchar(64) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `rejected_by` varchar(64) DEFAULT NULL,
  `rejected_at` datetime DEFAULT NULL,
  `rejection_reason` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of transferler
-- ----------------------------

-- ----------------------------
-- Table structure for `twitteracc`
-- ----------------------------
DROP TABLE IF EXISTS `twitteracc`;
CREATE TABLE `twitteracc` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phone_number` bigint(20) NOT NULL,
  `full_name` varchar(64) NOT NULL,
  `created_at` int(11) NOT NULL,
  `last_tweet_at` int(11) DEFAULT NULL,
  `password` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `phone_number` (`phone_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of twitteracc
-- ----------------------------

-- ----------------------------
-- Table structure for `vehicles`
-- ----------------------------
DROP TABLE IF EXISTS `vehicles`;
CREATE TABLE `vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model` int(11) DEFAULT '0',
  `x` decimal(10,6) DEFAULT '0.000000',
  `y` decimal(10,6) DEFAULT '0.000000',
  `z` decimal(10,6) DEFAULT '0.000000',
  `rotx` decimal(10,6) DEFAULT '0.000000',
  `roty` decimal(10,6) DEFAULT '0.000000',
  `rotz` decimal(10,6) DEFAULT '0.000000',
  `currx` decimal(10,6) DEFAULT '0.000000',
  `curry` decimal(10,6) DEFAULT '0.000000',
  `currz` decimal(10,6) DEFAULT '0.000000',
  `currrx` decimal(10,6) DEFAULT '0.000000',
  `currry` decimal(10,6) DEFAULT '0.000000',
  `currrz` decimal(10,6) NOT NULL DEFAULT '0.000000',
  `fuel` int(11) DEFAULT '100',
  `engine` int(11) DEFAULT '0',
  `locked` int(11) DEFAULT '0',
  `lights` int(11) DEFAULT '0',
  `sirens` int(11) DEFAULT '0',
  `paintjob` int(11) DEFAULT '0',
  `hp` float DEFAULT '1000',
  `color1` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT '0',
  `color2` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT '0',
  `color3` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `color4` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `plate` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `faction` int(11) DEFAULT '-1',
  `owner` int(11) DEFAULT '-1',
  `job` int(11) DEFAULT '-1',
  `tinted` int(11) DEFAULT '0',
  `dimension` int(11) DEFAULT '0',
  `interior` int(11) DEFAULT '0',
  `currdimension` int(11) DEFAULT '0',
  `currinterior` int(11) DEFAULT '0',
  `enginebroke` int(11) DEFAULT '0',
  `handbrake` int(11) DEFAULT '0',
  `safepositionX` float DEFAULT NULL,
  `safepositionY` float DEFAULT NULL,
  `safepositionZ` float DEFAULT NULL,
  `safepositionRZ` float DEFAULT NULL,
  `upgrades` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `upgrade_items` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `wheelStates` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT '[ [ 0, 0, 0, 0 ] ]',
  `panelStates` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT '[ [ 0, 0, 0, 0, 0, 0, 0 ] ]',
  `doorStates` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT '[ [ 0, 0, 0, 0, 0, 0 ] ]',
  `odometer` int(11) DEFAULT '0',
  `headlights` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT '[ [ 255, 255, 255 ] ]',
  `variant1` int(11) DEFAULT NULL,
  `variant2` int(11) DEFAULT NULL,
  `suspensionLowerLimit` float DEFAULT NULL,
  `driveType` char(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `deleted` int(11) NOT NULL DEFAULT '0',
  `stolen` tinyint(4) NOT NULL DEFAULT '0',
  `last_used` datetime DEFAULT NULL,
  `creationDate` datetime DEFAULT NULL,
  `createdBy` int(11) DEFAULT NULL,
  `registered` int(11) NOT NULL DEFAULT '1',
  `vehicle_shop_id` int(11) NOT NULL DEFAULT '0',
  `textures` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL DEFAULT '[ [ ] ]',
  `neon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `plate_design` tinyint(1) NOT NULL DEFAULT '1',
  `activity` tinyint(1) NOT NULL DEFAULT '1',
  `fines` int(11) NOT NULL DEFAULT '0',
  `armor` int(11) DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of vehicles
-- ----------------------------

-- ----------------------------
-- Table structure for `vehicles_custom`
-- ----------------------------
DROP TABLE IF EXISTS `vehicles_custom`;
CREATE TABLE `vehicles_custom` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `brand` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `model` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `year` int(11) DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `handling` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `tax` int(11) DEFAULT NULL,
  `createdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `createdby` int(11) NOT NULL DEFAULT '0',
  `updatedate` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updatedby` int(11) NOT NULL DEFAULT '0',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `doortype` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of vehicles_custom
-- ----------------------------

-- ----------------------------
-- Table structure for `vehicles_shop`
-- ----------------------------
DROP TABLE IF EXISTS `vehicles_shop`;
CREATE TABLE `vehicles_shop` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vehmtamodel` int(11) DEFAULT '0',
  `vehbrand` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `vehmodel` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `vehyear` int(11) DEFAULT '2014',
  `vehprice` int(11) DEFAULT '0',
  `vehtax` int(11) DEFAULT '0',
  `createdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `createdby` int(11) NOT NULL DEFAULT '0',
  `updatedate` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updatedby` int(11) NOT NULL DEFAULT '0',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `handling` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `duration` int(11) NOT NULL DEFAULT '1000',
  `enabled` int(11) NOT NULL DEFAULT '0',
  `spawnto` tinyint(4) NOT NULL DEFAULT '0',
  `doortype` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of vehicles_shop
-- ----------------------------

-- ----------------------------
-- Table structure for `vehicle_logs`
-- ----------------------------
DROP TABLE IF EXISTS `vehicle_logs`;
CREATE TABLE `vehicle_logs` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `vehID` int(11) DEFAULT NULL,
  `action` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `actor` int(11) DEFAULT NULL,
  PRIMARY KEY (`log_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of vehicle_logs
-- ----------------------------

-- ----------------------------
-- Table structure for `vehicle_notes`
-- ----------------------------
DROP TABLE IF EXISTS `vehicle_notes`;
CREATE TABLE `vehicle_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vehid` int(11) NOT NULL,
  `creator` int(11) NOT NULL DEFAULT '0',
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `date` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of vehicle_notes
-- ----------------------------

-- ----------------------------
-- Table structure for `vips`
-- ----------------------------
DROP TABLE IF EXISTS `vips`;
CREATE TABLE `vips` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `char_id` int(11) NOT NULL,
  `vip_type` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `vip_end_tick` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of vips
-- ----------------------------

-- ----------------------------
-- Table structure for `weapon_orders`
-- ----------------------------
DROP TABLE IF EXISTS `weapon_orders`;
CREATE TABLE `weapon_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `weapon_code` int(10) unsigned NOT NULL,
  `character_id` int(10) unsigned NOT NULL,
  `given_time` int(10) unsigned NOT NULL,
  `receive_time` int(10) unsigned NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of weapon_orders
-- ----------------------------

-- ----------------------------
-- Table structure for `wearables`
-- ----------------------------
DROP TABLE IF EXISTS `wearables`;
CREATE TABLE `wearables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bone` int(11) NOT NULL DEFAULT '1',
  `x` float NOT NULL DEFAULT '0',
  `y` float NOT NULL DEFAULT '0',
  `z` float NOT NULL DEFAULT '0',
  `rx` float DEFAULT '0',
  `ry` float NOT NULL DEFAULT '0',
  `rz` float NOT NULL DEFAULT '0',
  `sz` float NOT NULL DEFAULT '1',
  `sy` float NOT NULL DEFAULT '1',
  `sx` float NOT NULL DEFAULT '1',
  `model` int(11) NOT NULL,
  `owner` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of wearables
-- ----------------------------

-- ----------------------------
-- Table structure for `worlditems`
-- ----------------------------
DROP TABLE IF EXISTS `worlditems`;
CREATE TABLE `worlditems` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `itemid` int(11) DEFAULT '0',
  `itemvalue` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `x` float DEFAULT '0',
  `y` float DEFAULT '0',
  `z` float DEFAULT '0',
  `dimension` int(11) DEFAULT '0',
  `interior` int(11) DEFAULT '0',
  `creationdate` datetime DEFAULT NULL,
  `rx` float DEFAULT '0',
  `ry` float DEFAULT '0',
  `rz` float DEFAULT '0',
  `creator` int(10) unsigned DEFAULT '0',
  `protected` int(11) NOT NULL DEFAULT '0',
  `perm_use` int(11) NOT NULL DEFAULT '1',
  `perm_move` int(11) NOT NULL DEFAULT '1',
  `perm_pickup` int(11) NOT NULL DEFAULT '1',
  `perm_use_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `perm_move_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `perm_pickup_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of worlditems
-- ----------------------------

-- ----------------------------
-- Table structure for `worlditems_data`
-- ----------------------------
DROP TABLE IF EXISTS `worlditems_data`;
CREATE TABLE `worlditems_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item` int(11) NOT NULL,
  `key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of worlditems_data
-- ----------------------------
