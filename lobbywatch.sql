-- phpMyAdmin SQL Dump
-- version 4.0.4.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Erstellungszeit: 05. Jan 2014 um 09:44
-- Server Version: 5.6.12
-- PHP-Version: 5.5.1

SET FOREIGN_KEY_CHECKS=0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Datenbank: `lobbywatch`
--
CREATE DATABASE IF NOT EXISTS `lobbywatch` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `lobbywatch`;

DELIMITER $$
--
-- Prozeduren
--
DROP PROCEDURE IF EXISTS `takeSnapshot`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `takeSnapshot`(aVisa VARCHAR(10), aBeschreibung VARCHAR(150))
    MODIFIES SQL DATA
    COMMENT 'Speichert einen Snapshot in die _log Tabellen.'
BEGIN
  DECLARE ts TIMESTAMP DEFAULT NOW();
  DECLARE sid int(11);
  INSERT INTO `snapshot` (`id`, `beschreibung`, `notizen`, `created_visa`, `created_date`, `updated_visa`, `updated_date`) VALUES (NULL, aBeschreibung, NULL, aVisa, ts, aVisa, ts);
  SELECT LAST_INSERT_ID() INTO sid;

   INSERT INTO `branche_log`
     SELECT *, null, 'snapshot', null, ts, sid FROM `branche`;

   INSERT INTO `interessenbindung_log`
     SELECT *, null, 'snapshot', null, ts, sid FROM `interessenbindung`;

   INSERT INTO `interessengruppe_log`
     SELECT *, null, 'snapshot', null, ts, sid FROM `interessengruppe`;

   INSERT INTO `in_kommission_log`
     SELECT *, null, 'snapshot', null, ts, sid FROM `in_kommission`;

   INSERT INTO `kommission_log`
     SELECT *, null, 'snapshot', null, ts, sid FROM `kommission`;

   INSERT INTO `mandat_log`
     SELECT *, null, 'snapshot', null, ts, sid FROM `mandat`;

   INSERT INTO `organisation_log`
     SELECT *, null, 'snapshot', null, ts, sid FROM `organisation`;

   INSERT INTO `organisation_beziehung_log`
     SELECT *, null, 'snapshot', null, ts, sid FROM `organisation_beziehung`;

   INSERT INTO `parlamentarier_log`
     SELECT *, null, 'snapshot', null, ts, sid FROM `parlamentarier`;

   INSERT INTO `parlamentarier_anhang_log`
     SELECT *, null, 'snapshot', null, ts, sid FROM `parlamentarier_anhang`;

   INSERT INTO `partei_log`
     SELECT *, null, 'snapshot', null, ts, sid FROM `partei`;

   INSERT INTO `zutrittsberechtigung_log`
     SELECT *, null, 'snapshot', null, ts, sid FROM `zutrittsberechtigung`;
END$$

--
-- Funktionen
--
DROP FUNCTION IF EXISTS `UTF8_URLENCODE`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `UTF8_URLENCODE`(str VARCHAR(4096) CHARSET utf8) RETURNS varchar(4096) CHARSET utf8
    DETERMINISTIC
    COMMENT 'Encode UTF-8 string as URL'
BEGIN
   -- the individual character we are converting in our loop
   -- NOTE: must be VARCHAR even though it won't vary in length
   -- CHAR(1), when used with SUBSTRING, made spaces '' instead of ' '
   DECLARE sub VARCHAR(1) CHARSET utf8;
   -- the ordinal value of the character (i.e. ñ becomes 50097)
   DECLARE val BIGINT DEFAULT 0;
   -- the substring index we use in our loop (one-based)
   DECLARE ind INT DEFAULT 1;
   -- the integer value of the individual octet of a character being encoded
   -- (which is potentially multi-byte and must be encoded one byte at a time)
   DECLARE oct INT DEFAULT 0;
   -- the encoded return string that we build up during execution
   DECLARE ret VARCHAR(4096) DEFAULT '';
   -- our loop index for looping through each octet while encoding
   DECLARE octind INT DEFAULT 0;

   IF ISNULL(str) THEN
      RETURN NULL;
   ELSE
      SET ret = '';
      -- loop through the input string one character at a time - regardless
      -- of how many bytes a character consists of
      WHILE ind <= CHAR_LENGTH(str) DO
         SET sub = MID(str, ind, 1);
         SET val = ORD(sub);
         -- these values are ones that should not be converted
         -- see http://tools.ietf.org/html/rfc3986
         IF NOT (val BETWEEN 48 AND 57 OR     -- 48-57  = 0-9
                 val BETWEEN 65 AND 90 OR     -- 65-90  = A-Z
                 val BETWEEN 97 AND 122 OR    -- 97-122 = a-z
                 -- 45 = hyphen, 46 = period, 95 = underscore, 126 = tilde
                 val IN (45, 46, 95, 126)) THEN
            -- This is not an "unreserved" char and must be encoded:
            -- loop through each octet of the potentially multi-octet character
            -- and convert each into its hexadecimal value
            -- we start with the high octect because that is the order that ORD
            -- returns them in - they need to be encoded with the most significant
            -- byte first
            SET octind = OCTET_LENGTH(sub);
            WHILE octind > 0 DO
               -- get the actual value of this octet by shifting it to the right
               -- so that it is at the lowest byte position - in other words, make
               -- the octet/byte we are working on the entire number (or in even
               -- other words, oct will no be between zero and 255 inclusive)
               SET oct = (val >> (8 * (octind - 1)));
               -- we append this to our return string with a percent sign, and then
               -- a left-zero-padded (to two characters) string of the hexadecimal
               -- value of this octet)
               SET ret = CONCAT(ret, '%', LPAD(HEX(oct), 2, 0));
               -- now we need to reset val to essentially zero out the octet that we
               -- just encoded so that our number decreases and we are only left with
               -- the lower octets as part of our integer
               SET val = (val & (POWER(256, (octind - 1)) - 1));
               SET octind = (octind - 1);
            END WHILE;
         ELSE
            -- this character was not one that needed to be encoded and can simply be
            -- added to our return string as-is
            SET ret = CONCAT(ret, sub);
         END IF;
         SET ind = (ind + 1);
      END WHILE;
   END IF;
   RETURN ret;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `branche`
--
-- Erzeugt am: 30. Dez 2013 um 04:28
--

DROP TABLE IF EXISTS `branche`;
CREATE TABLE IF NOT EXISTS `branche` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Schlüssel der Branche',
  `name` varchar(100) NOT NULL COMMENT 'Name der Branche, z.B. Gesundheit, Energie',
  `kommission_id` int(11) DEFAULT NULL COMMENT 'Zuständige Kommission im Parlament',
  `beschreibung` text NOT NULL COMMENT 'Beschreibung der Branche',
  `angaben` text COMMENT 'Angaben zur Branche',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgeändert von',
  `updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Abgeändert am',
  PRIMARY KEY (`id`),
  UNIQUE KEY `branche_name_unique` (`name`) COMMENT 'Fachlicher unique constraint',
  KEY `kommission_id` (`kommission_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Wirtschaftsbranchen' AUTO_INCREMENT=19 ;

--
-- RELATIONEN DER TABELLE `branche`:
--   `kommission_id`
--       `kommission` -> `id`
--

--
-- Trigger `branche`
--
DROP TRIGGER IF EXISTS `trg_branche_log_del_after`;
DELIMITER //
CREATE TRIGGER `trg_branche_log_del_after` AFTER DELETE ON `branche`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  UPDATE `branche_log`
    SET `state` = 'OK'
    WHERE `id` = OLD.`id` AND `created_date` = OLD.`created_date` AND action = 'delete';
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_branche_log_del_before`;
DELIMITER //
CREATE TRIGGER `trg_branche_log_del_before` BEFORE DELETE ON `branche`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `branche_log`
    SELECT *, null, 'delete', null, NOW(), null FROM `branche` WHERE id = OLD.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_branche_log_ins`;
DELIMITER //
CREATE TRIGGER `trg_branche_log_ins` AFTER INSERT ON `branche`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `branche_log`
    SELECT *, null, 'insert', null, NOW(), null FROM `branche` WHERE id = NEW.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_branche_log_upd`;
DELIMITER //
CREATE TRIGGER `trg_branche_log_upd` AFTER UPDATE ON `branche`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `branche_log`
    SELECT *, null, 'update', null, NOW(), null FROM `branche` WHERE id = NEW.id ;
end
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `branche_log`
--
-- Erzeugt am: 30. Dez 2013 um 05:51
--

DROP TABLE IF EXISTS `branche_log`;
CREATE TABLE IF NOT EXISTS `branche_log` (
  `id` int(11) NOT NULL COMMENT 'Technischer Schlüssel der Live-Daten',
  `name` varchar(100) NOT NULL COMMENT 'Name der Branche, z.B. Gesundheit, Energie',
  `kommission_id` int(11) DEFAULT NULL COMMENT 'Zuständige Kommission im Parlament',
  `beschreibung` text NOT NULL COMMENT 'Beschreibung der Branche',
  `angaben` text COMMENT 'Angaben zur Branche',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NULL DEFAULT NULL COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgeändert von',
  `updated_date` timestamp NULL DEFAULT NULL COMMENT 'Abgeändert am',
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Log-Schlüssel',
  `action` enum('insert','update','delete','snapshot') NOT NULL COMMENT 'Aktionstyp',
  `state` varchar(20) DEFAULT NULL COMMENT 'Status der Aktion',
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Datum der Aktion',
  `snapshot_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel zu einem Snapshot',
  PRIMARY KEY (`log_id`),
  KEY `kommission_id` (`kommission_id`),
  KEY `fk_branche_log_snapshot_id` (`snapshot_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Wirtschaftsbranchen' AUTO_INCREMENT=19 ;

--
-- RELATIONEN DER TABELLE `branche_log`:
--   `snapshot_id`
--       `snapshot` -> `id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `interessenbindung`
--
-- Erzeugt am: 30. Dez 2013 um 15:20
--

DROP TABLE IF EXISTS `interessenbindung`;
CREATE TABLE IF NOT EXISTS `interessenbindung` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Schlüssel der Interessenbindung',
  `parlamentarier_id` int(11) NOT NULL COMMENT 'Fremdschlüssel Parlamentarier',
  `organisation_id` int(11) NOT NULL COMMENT 'Fremdschlüssel Organisation',
  `art` enum('mitglied','geschaeftsfuehrend','vorstand','taetig','beirat') NOT NULL DEFAULT 'mitglied' COMMENT 'Art der Interessenbindung',
  `deklarationstyp` enum('deklarationspflichtig','nicht deklarationspflicht') NOT NULL COMMENT 'Ist diese Interessenbindung deklarationspflichtig?',
  `status` enum('deklariert','nicht-deklariert') NOT NULL DEFAULT 'deklariert' COMMENT 'Status der Interessenbindung',
  `verguetung` int(11) DEFAULT NULL COMMENT 'Monatliche Vergütung CHF für Tätigkeiten aus dieser Interessenbindung, z.B. Entschädigung für Beiratsfunktion.',
  `beschreibung` varchar(150) DEFAULT NULL COMMENT 'Bezeichung der Interessenbindung. Möglichst kurz. Bezeichnung wird zur Auswertung wahrscheinlich nicht gebraucht.',
  `von` date DEFAULT NULL COMMENT 'Beginn der Interessenbindung, leer (NULL) = unbekannt',
  `bis` date DEFAULT NULL COMMENT 'Ende der Interessenbindung, leer (NULL) = aktuell gültig, nicht leer = historischer Eintrag',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `autorisiert_datum` date DEFAULT NULL COMMENT 'Autorisiert am',
  `autorisiert_visa` varchar(10) DEFAULT NULL COMMENT 'Autorisiert durch. Sonstige Angaben als Notiz erfassen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgeändert von',
  `updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Abgeändert am',
  PRIMARY KEY (`id`),
  UNIQUE KEY `interessenbindung_art_parlamentarier_organisation_unique` (`art`,`parlamentarier_id`,`organisation_id`,`bis`) COMMENT 'Fachlicher unique constraint',
  KEY `idx_parlam` (`parlamentarier_id`),
  KEY `idx_lobbyorg` (`organisation_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Interessenbindungen von Parlamentariern' AUTO_INCREMENT=337 ;

--
-- RELATIONEN DER TABELLE `interessenbindung`:
--   `organisation_id`
--       `organisation` -> `id`
--   `parlamentarier_id`
--       `parlamentarier` -> `id`
--

--
-- Trigger `interessenbindung`
--
DROP TRIGGER IF EXISTS `trg_interessenbindung_log_del_after`;
DELIMITER //
CREATE TRIGGER `trg_interessenbindung_log_del_after` AFTER DELETE ON `interessenbindung`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  UPDATE `interessenbindung_log`
    SET `state` = 'OK'
    WHERE `id` = OLD.`id` AND `created_date` = OLD.`created_date` AND action = 'delete';
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_interessenbindung_log_del_before`;
DELIMITER //
CREATE TRIGGER `trg_interessenbindung_log_del_before` BEFORE DELETE ON `interessenbindung`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `interessenbindung_log`
    SELECT *, null, 'delete', null, NOW(), null FROM `interessenbindung` WHERE id = OLD.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_interessenbindung_log_ins`;
DELIMITER //
CREATE TRIGGER `trg_interessenbindung_log_ins` AFTER INSERT ON `interessenbindung`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `interessenbindung_log`
    SELECT *, null, 'insert', null, NOW(), null FROM `interessenbindung` WHERE id = NEW.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_interessenbindung_log_upd`;
DELIMITER //
CREATE TRIGGER `trg_interessenbindung_log_upd` AFTER UPDATE ON `interessenbindung`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `interessenbindung_log`
    SELECT *, null, 'update', null, NOW(), null FROM `interessenbindung` WHERE id = NEW.id ;
end
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `interessenbindung_log`
--
-- Erzeugt am: 30. Dez 2013 um 05:51
--

DROP TABLE IF EXISTS `interessenbindung_log`;
CREATE TABLE IF NOT EXISTS `interessenbindung_log` (
  `id` int(11) NOT NULL COMMENT 'Technischer Schlüssel der Live-Daten',
  `parlamentarier_id` int(11) NOT NULL COMMENT 'Fremdschlüssel Parlamentarier',
  `organisation_id` int(11) NOT NULL COMMENT 'Fremdschlüssel Organisation',
  `art` enum('mitglied','geschaeftsfuehrend','vorstand','taetig','beirat') NOT NULL DEFAULT 'mitglied' COMMENT 'Art der Interessenbindung',
  `deklarationstyp` enum('deklarationspflichtig','nicht deklarationspflicht') NOT NULL COMMENT 'Ist diese Interessenbindung deklarationspflichtig?',
  `status` enum('deklariert','nicht-deklariert') NOT NULL DEFAULT 'deklariert' COMMENT 'Status der Interessenbindung',
  `verguetung` int(11) DEFAULT NULL COMMENT 'Monatliche Vergütung CHF für Tätigkeiten aus dieser Interessenbindung, z.B. Entschädigung für Beiratsfunktion.',
  `beschreibung` varchar(150) DEFAULT NULL COMMENT 'Bezeichung der Interessenbindung. Möglichst kurz. Bezeichnung wird zur Auswertung wahrscheinlich nicht gebraucht.',
  `von` date DEFAULT NULL COMMENT 'Beginn der Interessenbindung, leer (NULL) = unbekannt',
  `bis` date DEFAULT NULL COMMENT 'Ende der Interessenbindung, leer (NULL) = aktuell gültig, nicht leer = historischer Eintrag',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `autorisiert_datum` date DEFAULT NULL COMMENT 'Autorisiert am',
  `autorisiert_visa` varchar(10) DEFAULT NULL COMMENT 'Autorisiert durch. Sonstige Angaben als Notiz erfassen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NULL DEFAULT NULL COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgeändert von',
  `updated_date` timestamp NULL DEFAULT NULL COMMENT 'Abgeändert am',
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Log-Schlüssel',
  `action` enum('insert','update','delete','snapshot') NOT NULL COMMENT 'Aktionstyp',
  `state` varchar(20) DEFAULT NULL COMMENT 'Status der Aktion',
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Datum der Aktion',
  `snapshot_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel zu einem Snapshot',
  PRIMARY KEY (`log_id`),
  KEY `idx_parlam` (`parlamentarier_id`),
  KEY `idx_lobbyorg` (`organisation_id`),
  KEY `fk_interessenbindung_log_snapshot_id` (`snapshot_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Interessenbindungen von Parlamentariern' AUTO_INCREMENT=321 ;

--
-- RELATIONEN DER TABELLE `interessenbindung_log`:
--   `snapshot_id`
--       `snapshot` -> `id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `interessengruppe`
--
-- Erzeugt am: 30. Dez 2013 um 04:28
--

DROP TABLE IF EXISTS `interessengruppe`;
CREATE TABLE IF NOT EXISTS `interessengruppe` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Schlüssel der Interessengruppe',
  `name` varchar(150) NOT NULL COMMENT 'Bezeichnung der Interessengruppe',
  `branche_id` int(11) NOT NULL COMMENT 'Fremdschlüssel Branche',
  `beschreibung` text NOT NULL COMMENT 'Eingrenzung und Beschreibung zur Interessengruppe',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgeändert von',
  `updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Abgeändert am',
  PRIMARY KEY (`id`),
  UNIQUE KEY `interessengruppe_name_unique` (`name`) COMMENT 'Fachlicher unique constraint',
  KEY `idx_lobbytyp` (`branche_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Interessengruppen einer Branche' AUTO_INCREMENT=10 ;

--
-- RELATIONEN DER TABELLE `interessengruppe`:
--   `branche_id`
--       `branche` -> `id`
--

--
-- Trigger `interessengruppe`
--
DROP TRIGGER IF EXISTS `trg_interessengruppe_log_del_after`;
DELIMITER //
CREATE TRIGGER `trg_interessengruppe_log_del_after` AFTER DELETE ON `interessengruppe`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  UPDATE `interessengruppe_log`
    SET `state` = 'OK'
    WHERE `id` = OLD.`id` AND `created_date` = OLD.`created_date` AND action = 'delete';
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_interessengruppe_log_del_before`;
DELIMITER //
CREATE TRIGGER `trg_interessengruppe_log_del_before` BEFORE DELETE ON `interessengruppe`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `interessengruppe_log`
    SELECT *, null, 'delete', null, NOW(), null FROM `interessengruppe` WHERE id = OLD.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_interessengruppe_log_ins`;
DELIMITER //
CREATE TRIGGER `trg_interessengruppe_log_ins` AFTER INSERT ON `interessengruppe`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `interessengruppe_log`
    SELECT *, null, 'insert', null, NOW(), null FROM `interessengruppe` WHERE id = NEW.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_interessengruppe_log_upd`;
DELIMITER //
CREATE TRIGGER `trg_interessengruppe_log_upd` AFTER UPDATE ON `interessengruppe`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `interessengruppe_log`
    SELECT *, null, 'update', null, NOW(), null FROM `interessengruppe` WHERE id = NEW.id ;
end
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `interessengruppe_log`
--
-- Erzeugt am: 30. Dez 2013 um 05:51
--

DROP TABLE IF EXISTS `interessengruppe_log`;
CREATE TABLE IF NOT EXISTS `interessengruppe_log` (
  `id` int(11) NOT NULL COMMENT 'Technischer Schlüssel der Live-Daten',
  `name` varchar(150) NOT NULL COMMENT 'Bezeichnung der Interessengruppe',
  `branche_id` int(11) NOT NULL COMMENT 'Fremdschlüssel Branche',
  `beschreibung` text NOT NULL COMMENT 'Eingrenzung und Beschreibung zur Interessengruppe',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NULL DEFAULT NULL COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgeändert von',
  `updated_date` timestamp NULL DEFAULT NULL COMMENT 'Abgeändert am',
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Log-Schlüssel',
  `action` enum('insert','update','delete','snapshot') NOT NULL COMMENT 'Aktionstyp',
  `state` varchar(20) DEFAULT NULL COMMENT 'Status der Aktion',
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Datum der Aktion',
  `snapshot_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel zu einem Snapshot',
  PRIMARY KEY (`log_id`),
  KEY `idx_lobbytyp` (`branche_id`),
  KEY `fk_interessengruppe_log_snapshot_id` (`snapshot_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Interessengruppen einer Branche' AUTO_INCREMENT=10 ;

--
-- RELATIONEN DER TABELLE `interessengruppe_log`:
--   `snapshot_id`
--       `snapshot` -> `id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `in_kommission`
--
-- Erzeugt am: 30. Dez 2013 um 15:21
--

DROP TABLE IF EXISTS `in_kommission`;
CREATE TABLE IF NOT EXISTS `in_kommission` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Schlüssel einer Kommissionszugehörigkeit',
  `parlamentarier_id` int(11) NOT NULL COMMENT 'Fremdschlüssel des Parlamentariers',
  `kommission_id` int(11) NOT NULL COMMENT 'Fremdschlüssel der Kommission',
  `funktion` enum('praesident','vizepraesident','mitglied') NOT NULL DEFAULT 'mitglied' COMMENT 'Funktion des Parlamentariers in der Kommission',
  `von` date DEFAULT NULL COMMENT 'Beginn der Kommissionszugehörigkeit, leer (NULL) = unbekannt',
  `bis` date DEFAULT NULL COMMENT 'Ende der Kommissionszugehörigkeit, leer (NULL) = aktuell gültig, nicht leer = historischer Eintrag',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgäendert von',
  `updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Abgäendert am',
  PRIMARY KEY (`id`),
  UNIQUE KEY `in_kommission_parlamentarier_kommission_funktion_unique` (`funktion`,`parlamentarier_id`,`kommission_id`,`bis`) COMMENT 'Fachlicher unique constraint',
  KEY `parlamentarier_id` (`parlamentarier_id`),
  KEY `kommissions_id` (`kommission_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Kommissionszugehörigkeit von Parlamentariern' AUTO_INCREMENT=117 ;

--
-- RELATIONEN DER TABELLE `in_kommission`:
--   `kommission_id`
--       `kommission` -> `id`
--   `parlamentarier_id`
--       `parlamentarier` -> `id`
--

--
-- Trigger `in_kommission`
--
DROP TRIGGER IF EXISTS `trg_in_kommission_log_del_after`;
DELIMITER //
CREATE TRIGGER `trg_in_kommission_log_del_after` AFTER DELETE ON `in_kommission`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  UPDATE `in_kommission_log`
    SET `state` = 'OK'
    WHERE `id` = OLD.`id` AND `created_date` = OLD.`created_date` AND action = 'delete';
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_in_kommission_log_del_before`;
DELIMITER //
CREATE TRIGGER `trg_in_kommission_log_del_before` BEFORE DELETE ON `in_kommission`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `in_kommission_log`
    SELECT *, null, 'delete', null, NOW(), null FROM `in_kommission` WHERE id = OLD.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_in_kommission_log_ins`;
DELIMITER //
CREATE TRIGGER `trg_in_kommission_log_ins` AFTER INSERT ON `in_kommission`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `in_kommission_log`
    SELECT *, null, 'insert', null, NOW(), null FROM `in_kommission` WHERE id = NEW.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_in_kommission_log_upd`;
DELIMITER //
CREATE TRIGGER `trg_in_kommission_log_upd` AFTER UPDATE ON `in_kommission`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `in_kommission_log`
    SELECT *, null, 'update', null, NOW(), null FROM `in_kommission` WHERE id = NEW.id ;
end
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `in_kommission_log`
--
-- Erzeugt am: 30. Dez 2013 um 05:51
--

DROP TABLE IF EXISTS `in_kommission_log`;
CREATE TABLE IF NOT EXISTS `in_kommission_log` (
  `id` int(11) NOT NULL COMMENT 'Technischer Schlüssel der Live-Daten',
  `parlamentarier_id` int(11) NOT NULL COMMENT 'Fremdschlüssel des Parlamentariers',
  `kommission_id` int(11) NOT NULL COMMENT 'Fremdschlüssel der Kommission',
  `funktion` enum('praesident','vizepraesident','mitglied') NOT NULL DEFAULT 'mitglied' COMMENT 'Funktion des Parlamentariers in der Kommission',
  `von` date DEFAULT NULL COMMENT 'Beginn der Kommissionszugehörigkeit, leer (NULL) = unbekannt',
  `bis` date DEFAULT NULL COMMENT 'Ende der Kommissionszugehörigkeit, leer (NULL) = aktuell gültig, nicht leer = historischer Eintrag',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NULL DEFAULT NULL COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgäendert von',
  `updated_date` timestamp NULL DEFAULT NULL COMMENT 'Abgeändert am',
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Log-Schlüssel',
  `action` enum('insert','update','delete','snapshot') NOT NULL COMMENT 'Aktionstyp',
  `state` varchar(20) DEFAULT NULL COMMENT 'Status der Aktion',
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Datum der Aktion',
  `snapshot_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel zu einem Snapshot',
  PRIMARY KEY (`log_id`),
  KEY `parlamentarier_id` (`parlamentarier_id`),
  KEY `kommissions_id` (`kommission_id`),
  KEY `fk_in_kommission_log_snapshot_id` (`snapshot_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Kommissionszugehörigkeit von Parlamentariern' AUTO_INCREMENT=110 ;

--
-- RELATIONEN DER TABELLE `in_kommission_log`:
--   `snapshot_id`
--       `snapshot` -> `id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `kommission`
--
-- Erzeugt am: 30. Dez 2013 um 04:28
--

DROP TABLE IF EXISTS `kommission`;
CREATE TABLE IF NOT EXISTS `kommission` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Schlüssel der Kommission',
  `abkuerzung` varchar(15) NOT NULL COMMENT 'Kürzel der Kommission',
  `name` varchar(100) NOT NULL COMMENT 'Ausgeschriebener Name der Kommission',
  `typ` enum('kommission','subkommission','spezialkommission') NOT NULL DEFAULT 'kommission' COMMENT 'Typ einer Kommission (Spezialkommission ist eine Delegation im weiteren Sinne).',
  `beschreibung` text COMMENT 'Beschreibung der Kommission',
  `sachbereiche` text NOT NULL COMMENT 'Liste der Sachbereiche der Kommission, abgetrennt durch ";".',
  `mutter_kommission_id` int(11) DEFAULT NULL COMMENT 'Zugehörige Kommission von Delegationen im engeren Sinne (=Subkommissionen).  Also die "Oberkommission".',
  `parlament_url` varchar(255) DEFAULT NULL COMMENT 'Link zur Seite auf Parlament.ch',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgeändert von',
  `updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Abgeändert am',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_ko_unique_name` (`name`) COMMENT 'Fachlicher unique constraint',
  UNIQUE KEY `kommission_abkuerzung_unique` (`abkuerzung`) COMMENT 'Fachlicher unique constraint',
  UNIQUE KEY `kommission_name_unique` (`name`) COMMENT 'Fachlicher unique constraint',
  KEY `zugehoerige_kommission` (`mutter_kommission_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Parlamententskommissionen' AUTO_INCREMENT=44 ;

--
-- RELATIONEN DER TABELLE `kommission`:
--   `mutter_kommission_id`
--       `kommission` -> `id`
--

--
-- Trigger `kommission`
--
DROP TRIGGER IF EXISTS `trg_kommission_log_del_after`;
DELIMITER //
CREATE TRIGGER `trg_kommission_log_del_after` AFTER DELETE ON `kommission`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  UPDATE `kommission_log`
    SET `state` = 'OK'
    WHERE `id` = OLD.`id` AND `created_date` = OLD.`created_date` AND action = 'delete';
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_kommission_log_del_before`;
DELIMITER //
CREATE TRIGGER `trg_kommission_log_del_before` BEFORE DELETE ON `kommission`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `kommission_log`
    SELECT *, null, 'delete', null, NOW(), null FROM `kommission` WHERE id = OLD.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_kommission_log_ins`;
DELIMITER //
CREATE TRIGGER `trg_kommission_log_ins` AFTER INSERT ON `kommission`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `kommission_log`
    SELECT *, null, 'insert', null, NOW(), null FROM `kommission` WHERE id = NEW.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_kommission_log_upd`;
DELIMITER //
CREATE TRIGGER `trg_kommission_log_upd` AFTER UPDATE ON `kommission`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `kommission_log`
    SELECT *, null, 'update', null, NOW(), null FROM `kommission` WHERE id = NEW.id ;
end
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `kommission_log`
--
-- Erzeugt am: 30. Dez 2013 um 05:51
--

DROP TABLE IF EXISTS `kommission_log`;
CREATE TABLE IF NOT EXISTS `kommission_log` (
  `id` int(11) NOT NULL COMMENT 'Technischer Schlüssel der Live-Daten',
  `abkuerzung` varchar(15) NOT NULL COMMENT 'Kürzel der Kommission',
  `name` varchar(100) NOT NULL COMMENT 'Ausgeschriebener Name der Kommission',
  `typ` enum('kommission','subkommission','spezialkommission') NOT NULL DEFAULT 'kommission' COMMENT 'Typ einer Kommission (Spezialkommission ist eine Delegation im weiteren Sinne).',
  `beschreibung` text COMMENT 'Beschreibung der Kommission',
  `sachbereiche` text NOT NULL COMMENT 'Liste der Sachbereiche der Kommission, abgetrennt durch ";".',
  `mutter_kommission_id` int(11) DEFAULT NULL COMMENT 'Zugehörige Kommission von Delegationen im engeren Sinne (=Subkommissionen).  Also die "Oberkommission".',
  `parlament_url` varchar(255) DEFAULT NULL COMMENT 'Link zur Seite auf Parlament.ch',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NULL DEFAULT NULL COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgeändert von',
  `updated_date` timestamp NULL DEFAULT NULL COMMENT 'Abgeändert am',
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Log-Schlüssel',
  `action` enum('insert','update','delete','snapshot') NOT NULL COMMENT 'Aktionstyp',
  `state` varchar(20) DEFAULT NULL COMMENT 'Status der Aktion',
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Datum der Aktion',
  `snapshot_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel zu einem Snapshot',
  PRIMARY KEY (`log_id`),
  KEY `zugehoerige_kommission` (`mutter_kommission_id`),
  KEY `fk_kommission_log_snapshot_id` (`snapshot_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Parlamententskommissionen' AUTO_INCREMENT=28 ;

--
-- RELATIONEN DER TABELLE `kommission_log`:
--   `snapshot_id`
--       `snapshot` -> `id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `mandat`
--
-- Erzeugt am: 30. Dez 2013 um 15:26
--

DROP TABLE IF EXISTS `mandat`;
CREATE TABLE IF NOT EXISTS `mandat` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `zutrittsberechtigung_id` int(11) NOT NULL COMMENT 'Fremdschlüssel Zutrittsberechtigung.',
  `organisation_id` int(11) NOT NULL COMMENT 'Fremdschlüssel Organisation',
  `art` enum('mitglied','geschaeftsfuehrend','vorstand','taetig','beirat') DEFAULT NULL COMMENT 'Art der Funktion des Mandatsträgers innerhalb der Organisation',
  `verguetung` int(11) DEFAULT NULL COMMENT 'Monatliche Vergütung CHF für Tätigkeiten aus dieses Mandates, z.B. Entschädigung für Beiratsfunktion.',
  `beschreibung` varchar(150) DEFAULT NULL COMMENT 'Umschreibung des Mandates. Beschreibung wird zur Auswertung wahrscheinlich nicht gebraucht.',
  `von` date DEFAULT NULL COMMENT 'Beginn des Mandates, leer (NULL) = unbekannt',
  `bis` date DEFAULT NULL COMMENT 'Ende des Mandates, leer (NULL) = aktuell gültig, nicht leer = historischer Eintrag',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `autorisiert_datum` date DEFAULT NULL COMMENT 'Autorisiert am',
  `autorisiert_visa` varchar(10) DEFAULT NULL COMMENT 'Autorisiert durch. Sonstige Angaben als Notiz erfassen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgäendert von',
  `updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Abgäendert am',
  PRIMARY KEY (`id`),
  UNIQUE KEY `mandat_zutrittsberechtigung_organisation_art_unique` (`art`,`zutrittsberechtigung_id`,`organisation_id`,`bis`) COMMENT 'Fachlicher unique constraint',
  KEY `organisations_id` (`organisation_id`),
  KEY `zutrittsberechtigung_id` (`zutrittsberechtigung_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Mandate der Zugangsberechtigten' AUTO_INCREMENT=4 ;

--
-- RELATIONEN DER TABELLE `mandat`:
--   `organisation_id`
--       `organisation` -> `id`
--   `zutrittsberechtigung_id`
--       `zutrittsberechtigung` -> `id`
--

--
-- Trigger `mandat`
--
DROP TRIGGER IF EXISTS `trg_mandat_log_del_after`;
DELIMITER //
CREATE TRIGGER `trg_mandat_log_del_after` AFTER DELETE ON `mandat`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  UPDATE `mandat_log`
    SET `state` = 'OK'
    WHERE `id` = OLD.`id` AND `created_date` = OLD.`created_date` AND action = 'delete';
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_mandat_log_del_before`;
DELIMITER //
CREATE TRIGGER `trg_mandat_log_del_before` BEFORE DELETE ON `mandat`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `mandat_log`
    SELECT *, null, 'delete', null, NOW(), null FROM `mandat` WHERE id = OLD.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_mandat_log_ins`;
DELIMITER //
CREATE TRIGGER `trg_mandat_log_ins` AFTER INSERT ON `mandat`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `mandat_log`
    SELECT *, null, 'insert', null, NOW(), null FROM `mandat` WHERE id = NEW.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_mandat_log_upd`;
DELIMITER //
CREATE TRIGGER `trg_mandat_log_upd` AFTER UPDATE ON `mandat`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `mandat_log`
    SELECT *, null, 'update', null, NOW(), null FROM `mandat` WHERE id = NEW.id ;
end
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `mandat_log`
--
-- Erzeugt am: 30. Dez 2013 um 05:51
--

DROP TABLE IF EXISTS `mandat_log`;
CREATE TABLE IF NOT EXISTS `mandat_log` (
  `id` int(11) NOT NULL COMMENT 'Technischer Schlüssel der Live-Daten',
  `zutrittsberechtigung_id` int(11) NOT NULL COMMENT 'Fremdschlüssel Zutrittsberechtigung.',
  `organisation_id` int(11) NOT NULL COMMENT 'Fremdschlüssel Organisation',
  `art` enum('mitglied','geschaeftsfuehrend','vorstand','taetig','beirat') DEFAULT NULL COMMENT 'Art der Funktion des Mandatsträgers innerhalb der Organisation',
  `verguetung` int(11) DEFAULT NULL COMMENT 'Monatliche Vergütung CHF für Tätigkeiten aus dieses Mandates, z.B. Entschädigung für Beiratsfunktion.',
  `beschreibung` varchar(150) DEFAULT NULL COMMENT 'Umschreibung des Mandates. Beschreibung wird zur Auswertung wahrscheinlich nicht gebraucht.',
  `von` date DEFAULT NULL COMMENT 'Beginn des Mandates, leer (NULL) = unbekannt',
  `bis` date DEFAULT NULL COMMENT 'Ende des Mandates, leer (NULL) = aktuell gültig, nicht leer = historischer Eintrag',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `autorisiert_datum` date DEFAULT NULL COMMENT 'Autorisiert am',
  `autorisiert_visa` varchar(10) DEFAULT NULL COMMENT 'Autorisiert durch. Sonstige Angaben als Notiz erfassen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NULL DEFAULT NULL COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgäendert von',
  `updated_date` timestamp NULL DEFAULT NULL COMMENT 'Abgeändert am',
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Log-Schlüssel',
  `action` enum('insert','update','delete','snapshot') NOT NULL COMMENT 'Aktionstyp',
  `state` varchar(20) DEFAULT NULL COMMENT 'Status der Aktion',
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Datum der Aktion',
  `snapshot_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel zu einem Snapshot',
  PRIMARY KEY (`log_id`),
  KEY `organisations_id` (`organisation_id`),
  KEY `zutrittsberechtigung_id` (`zutrittsberechtigung_id`),
  KEY `fk_mandat_log_snapshot_id` (`snapshot_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Mandate der Zugangsberechtigten' AUTO_INCREMENT=4 ;

--
-- RELATIONEN DER TABELLE `mandat_log`:
--   `snapshot_id`
--       `snapshot` -> `id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `mil_grad`
--
-- Erzeugt am: 30. Dez 2013 um 05:16
--

DROP TABLE IF EXISTS `mil_grad`;
CREATE TABLE IF NOT EXISTS `mil_grad` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Schlüssel Militärischer Grad',
  `name` varchar(30) NOT NULL COMMENT 'Name des militärischen Grades',
  `abkuerzung` varchar(10) NOT NULL COMMENT 'Abkürzung des militärischen Grades',
  `typ` enum('Mannschaft','Unteroffizier','Hoeherer Unteroffizier','Offizier','Hoeherer Stabsoffizier') NOT NULL COMMENT 'Stufe des militärischen Grades',
  `ranghoehe` int(11) NOT NULL COMMENT 'Ranghöhe des Grades',
  `anzeigestufe` int(11) NOT NULL COMMENT 'Anzeigestufe, je höher desto selektiver, >=0 = alle werden angezeigt, >0 = Standardanzeige',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgäendert von',
  `updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Abgäendert am',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_unique` (`name`),
  UNIQUE KEY `abkuerzung_unique` (`abkuerzung`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Militärische Grade (Armee XXI)' AUTO_INCREMENT=24 ;

--
-- Trigger `mil_grad`
--
DROP TRIGGER IF EXISTS `trg_mil_grad_log_del_after`;
DELIMITER //
CREATE TRIGGER `trg_mil_grad_log_del_after` AFTER DELETE ON `mil_grad`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  UPDATE `mil_grad_log`
    SET `state` = 'OK'
    WHERE `id` = OLD.`id` AND `created_date` = OLD.`created_date` AND action = 'delete';
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_mil_grad_log_del_before`;
DELIMITER //
CREATE TRIGGER `trg_mil_grad_log_del_before` BEFORE DELETE ON `mil_grad`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `mil_grad_log`
    SELECT *, null, 'delete', null, NOW(), null FROM `mil_grad` WHERE id = OLD.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_mil_grad_log_ins`;
DELIMITER //
CREATE TRIGGER `trg_mil_grad_log_ins` AFTER INSERT ON `mil_grad`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `mil_grad_log`
    SELECT *, null, 'insert', null, NOW(), null FROM `mil_grad` WHERE id = NEW.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_mil_grad_log_upd`;
DELIMITER //
CREATE TRIGGER `trg_mil_grad_log_upd` AFTER UPDATE ON `mil_grad`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `mil_grad_log`
    SELECT *, null, 'update', null, NOW(), null FROM `mil_grad` WHERE id = NEW.id ;
end
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `mil_grad_log`
--
-- Erzeugt am: 30. Dez 2013 um 05:51
--

DROP TABLE IF EXISTS `mil_grad_log`;
CREATE TABLE IF NOT EXISTS `mil_grad_log` (
  `id` int(11) NOT NULL COMMENT 'Technischer Schlüssel der Live-Daten',
  `name` varchar(30) NOT NULL COMMENT 'Name des militärischen Grades',
  `abkuerzung` varchar(10) NOT NULL COMMENT 'Abkürzung des militärischen Grades',
  `typ` enum('Mannschaft','Unteroffizier','Hoeherer Unteroffizier','Offizier','Hoeherer Stabsoffizier') NOT NULL COMMENT 'Stufe des militärischen Grades',
  `ranghoehe` int(11) NOT NULL COMMENT 'Ranghöhe des Grades',
  `anzeigestufe` int(11) NOT NULL COMMENT 'Anzeigestufe, je höher desto selektiver, >=0 = alle werden angezeigt, >0 = Standardanzeige',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NULL DEFAULT NULL COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgäendert von',
  `updated_date` timestamp NULL DEFAULT NULL COMMENT 'Abgeändert am',
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Log-Schlüssel',
  `action` enum('insert','update','delete','snapshot') NOT NULL COMMENT 'Aktionstyp',
  `state` varchar(20) DEFAULT NULL COMMENT 'Status der Aktion',
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Datum der Aktion',
  `snapshot_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel zu einem Snapshot',
  PRIMARY KEY (`log_id`),
  KEY `fk_mil_grad_log_snapshot_id` (`snapshot_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Militärische Grade (Armee XXI)' AUTO_INCREMENT=1 ;

--
-- RELATIONEN DER TABELLE `mil_grad_log`:
--   `snapshot_id`
--       `snapshot` -> `id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `organisation`
--
-- Erzeugt am: 30. Dez 2013 um 04:29
--

DROP TABLE IF EXISTS `organisation`;
CREATE TABLE IF NOT EXISTS `organisation` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Schlüssel der Lobbyorganisation',
  `name_de` varchar(150) NOT NULL COMMENT 'Name der Organisation. Sollte nur juristischem Namen entsprechen, ohne Zusätze, wie Adresse.',
  `name_fr` varchar(150) DEFAULT NULL COMMENT 'Französischer Name',
  `name_it` varchar(150) DEFAULT NULL COMMENT 'Italienischer Name',
  `ort` varchar(100) DEFAULT NULL COMMENT 'Ort der Organisation',
  `rechtsform` enum('AG','GmbH','Stiftung','Verein','Informelle Gruppe','Parlamentarische Gruppe','Oeffentlich-rechtlich','Einzelunternehmen','KG') DEFAULT NULL COMMENT 'Rechtsform der Organisation',
  `typ` set('EinzelOrganisation','DachOrganisation','MitgliedsOrganisation','LeistungsErbringer','dezidierteLobby') NOT NULL COMMENT 'Typ der Organisation. Beziehungen können über Organisation_Beziehung eingegeben werden.',
  `vernehmlassung` enum('immer','punktuell','nie') NOT NULL COMMENT 'Häufigkeit der Vernehmlassungsteilnahme',
  `interessengruppe_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel Interessengruppe. Über die Interessengruppe wird eine Branche zugeordnet.',
  `branche_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel Branche.',
  `url` varchar(255) DEFAULT NULL COMMENT 'Link zur Webseite',
  `handelsregister_url` varchar(255) DEFAULT NULL COMMENT 'Link zum Eintrag im Handelsregister',
  `beschreibung` text NOT NULL COMMENT 'Beschreibung der Lobbyorganisation',
  `ALT_parlam_verbindung` set('einzel','mehrere','mitglied','exekutiv','kommission') NOT NULL COMMENT 'Bisherige Verbindung der Organisation ins Parlament',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgeändert von',
  `updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Abgeändert am',
  PRIMARY KEY (`id`),
  UNIQUE KEY `organisation_name_de_unique` (`name_de`) COMMENT 'Fachlicher unique constraint',
  UNIQUE KEY `organisation_name_fr_unique` (`name_fr`) COMMENT 'Fachlicher unique constraint',
  UNIQUE KEY `organisation_name_it_unique` (`name_it`) COMMENT 'Fachlicher unique constraint',
  KEY `idx_lobbytyp` (`branche_id`),
  KEY `idx_lobbygroup` (`interessengruppe_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Liste der Lobbyorganisationen' AUTO_INCREMENT=350 ;

--
-- RELATIONEN DER TABELLE `organisation`:
--   `interessengruppe_id`
--       `interessengruppe` -> `id`
--   `branche_id`
--       `branche` -> `id`
--

--
-- Trigger `organisation`
--
DROP TRIGGER IF EXISTS `trg_organisation_log_del_after`;
DELIMITER //
CREATE TRIGGER `trg_organisation_log_del_after` AFTER DELETE ON `organisation`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  UPDATE `organisation_log`
    SET `state` = 'OK'
    WHERE `id` = OLD.`id` AND `created_date` = OLD.`created_date` AND action = 'delete';
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_organisation_log_del_before`;
DELIMITER //
CREATE TRIGGER `trg_organisation_log_del_before` BEFORE DELETE ON `organisation`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `organisation_log`
    SELECT *, null, 'delete', null, NOW(), null FROM `organisation` WHERE id = OLD.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_organisation_log_ins`;
DELIMITER //
CREATE TRIGGER `trg_organisation_log_ins` AFTER INSERT ON `organisation`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `organisation_log`
    SELECT *, null, 'insert', null, NOW(), null FROM `organisation` WHERE id = NEW.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_organisation_log_upd`;
DELIMITER //
CREATE TRIGGER `trg_organisation_log_upd` AFTER UPDATE ON `organisation`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `organisation_log`
    SELECT *, null, 'update', null, NOW(), null FROM `organisation` WHERE id = NEW.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_organisation_name_ins`;
DELIMITER //
CREATE TRIGGER `trg_organisation_name_ins` BEFORE INSERT ON `organisation`
 FOR EACH ROW thisTrigger: begin
    IF @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
    if new.name_de IS NULL AND new.name_fr IS NULL AND new.name_it IS NULL then
        call organisation_name_de_fr_it_must_be_set;
    end if;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_organisation_name_upd`;
DELIMITER //
CREATE TRIGGER `trg_organisation_name_upd` BEFORE UPDATE ON `organisation`
 FOR EACH ROW thisTrigger: begin
    IF @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
    if new.name_de IS NULL AND new.name_fr IS NULL AND new.name_it IS NULL then
        call organisation_name_de_fr_it_must_be_set;
    end if;
end
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `organisation_beziehung`
--
-- Erzeugt am: 30. Dez 2013 um 15:21
--

DROP TABLE IF EXISTS `organisation_beziehung`;
CREATE TABLE IF NOT EXISTS `organisation_beziehung` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Schlüssel einer Organisationsbeziehung',
  `organisation_id` int(11) NOT NULL COMMENT 'Fremdschlüssel Organisation.',
  `ziel_organisation_id` int(11) NOT NULL COMMENT 'Fremdschlüssel der Zielorganisation.',
  `art` enum('arbeitet fuer','mitglied von') NOT NULL COMMENT 'Beschreibt die Beziehung einer Organisation zu einer Zielorgansation',
  `von` date DEFAULT NULL COMMENT 'Beginn der Organisationsbeziehung, leer (NULL) = unbekannt',
  `bis` date DEFAULT NULL COMMENT 'Ende der Organisationsbeziehung, leer (NULL) = aktuell gültig, nicht leer = historischer Eintrag',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgäendert von',
  `updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Abgäendert am',
  PRIMARY KEY (`id`),
  UNIQUE KEY `organisation_beziehung_organisation_zielorganisation_art_unique` (`art`,`organisation_id`,`ziel_organisation_id`,`bis`) COMMENT 'Fachlicher unique constraint',
  KEY `organisation_id` (`organisation_id`),
  KEY `ziel_organisation_id` (`ziel_organisation_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Beschreibt die Beziehung von Organisationen zueinander' AUTO_INCREMENT=6 ;

--
-- RELATIONEN DER TABELLE `organisation_beziehung`:
--   `organisation_id`
--       `organisation` -> `id`
--   `ziel_organisation_id`
--       `organisation` -> `id`
--

--
-- Trigger `organisation_beziehung`
--
DROP TRIGGER IF EXISTS `trg_organisation_beziehung_log_del_after`;
DELIMITER //
CREATE TRIGGER `trg_organisation_beziehung_log_del_after` AFTER DELETE ON `organisation_beziehung`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  UPDATE `organisation_beziehung_log`
    SET `state` = 'OK'
    WHERE `id` = OLD.`id` AND `created_date` = OLD.`created_date` AND action = 'delete';
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_organisation_beziehung_log_del_before`;
DELIMITER //
CREATE TRIGGER `trg_organisation_beziehung_log_del_before` BEFORE DELETE ON `organisation_beziehung`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `organisation_beziehung_log`
    SELECT *, null, 'delete', null, NOW(), null FROM `organisation_beziehung` WHERE id = OLD.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_organisation_beziehung_log_ins`;
DELIMITER //
CREATE TRIGGER `trg_organisation_beziehung_log_ins` AFTER INSERT ON `organisation_beziehung`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `organisation_beziehung_log`
    SELECT *, null, 'insert', null, NOW(), null FROM `organisation_beziehung` WHERE id = NEW.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_organisation_beziehung_log_upd`;
DELIMITER //
CREATE TRIGGER `trg_organisation_beziehung_log_upd` AFTER UPDATE ON `organisation_beziehung`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `organisation_beziehung_log`
    SELECT *, null, 'update', null, NOW(), null FROM `organisation_beziehung` WHERE id = NEW.id ;
end
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `organisation_beziehung_log`
--
-- Erzeugt am: 30. Dez 2013 um 05:51
--

DROP TABLE IF EXISTS `organisation_beziehung_log`;
CREATE TABLE IF NOT EXISTS `organisation_beziehung_log` (
  `id` int(11) NOT NULL COMMENT 'Technischer Schlüssel der Live-Daten',
  `organisation_id` int(11) NOT NULL COMMENT 'Fremdschlüssel Organisation.',
  `ziel_organisation_id` int(11) NOT NULL COMMENT 'Fremdschlüssel der Zielorganisation.',
  `art` enum('arbeitet fuer','mitglied von') NOT NULL COMMENT 'Beschreibt die Beziehung einer Organisation zu einer Zielorgansation',
  `von` date DEFAULT NULL COMMENT 'Beginn der Organisationsbeziehung, leer (NULL) = unbekannt',
  `bis` date DEFAULT NULL COMMENT 'Ende der Organisationsbeziehung, leer (NULL) = aktuell gültig, nicht leer = historischer Eintrag',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NULL DEFAULT NULL COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgäendert von',
  `updated_date` timestamp NULL DEFAULT NULL COMMENT 'Abgeändert am',
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Log-Schlüssel',
  `action` enum('insert','update','delete','snapshot') NOT NULL COMMENT 'Aktionstyp',
  `state` varchar(20) DEFAULT NULL COMMENT 'Status der Aktion',
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Datum der Aktion',
  `snapshot_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel zu einem Snapshot',
  PRIMARY KEY (`log_id`),
  KEY `organisation_id` (`organisation_id`),
  KEY `ziel_organisation_id` (`ziel_organisation_id`),
  KEY `fk_organisation_beziehung_log_snapshot_id` (`snapshot_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Beschreibt die Beziehung von Organisationen zueinander' AUTO_INCREMENT=6 ;

--
-- RELATIONEN DER TABELLE `organisation_beziehung_log`:
--   `snapshot_id`
--       `snapshot` -> `id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `organisation_log`
--
-- Erzeugt am: 30. Dez 2013 um 05:51
--

DROP TABLE IF EXISTS `organisation_log`;
CREATE TABLE IF NOT EXISTS `organisation_log` (
  `id` int(11) NOT NULL COMMENT 'Technischer Schlüssel der Live-Daten',
  `name_de` varchar(150) NOT NULL COMMENT 'Name der Organisation. Sollte nur juristischem Namen entsprechen, ohne Zusätze, wie Adresse.',
  `name_fr` varchar(150) DEFAULT NULL COMMENT 'Französischer Name',
  `name_it` varchar(150) DEFAULT NULL COMMENT 'Italienischer Name',
  `ort` varchar(100) DEFAULT NULL COMMENT 'Ort der Organisation',
  `rechtsform` enum('AG','GmbH','Stiftung','Verein','Informelle Gruppe','Parlamentarische Gruppe','Oeffentlich-rechtlich','Einzelunternehmen','KG') DEFAULT NULL COMMENT 'Rechtsform der Organisation',
  `typ` set('EinzelOrganisation','DachOrganisation','MitgliedsOrganisation','LeistungsErbringer','dezidierteLobby') NOT NULL COMMENT 'Typ der Organisation. Beziehungen können über Organisation_Beziehung eingegeben werden.',
  `vernehmlassung` enum('immer','punktuell','nie') NOT NULL COMMENT 'Häufigkeit der Vernehmlassungsteilnahme',
  `interessengruppe_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel Interessengruppe. Über die Interessengruppe wird eine Branche zugeordnet.',
  `branche_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel Branche.',
  `url` varchar(255) DEFAULT NULL COMMENT 'Link zur Webseite',
  `handelsregister_url` varchar(255) DEFAULT NULL COMMENT 'Link zum Eintrag im Handelsregister',
  `beschreibung` text NOT NULL COMMENT 'Beschreibung der Lobbyorganisation',
  `ALT_parlam_verbindung` set('einzel','mehrere','mitglied','exekutiv','kommission') NOT NULL COMMENT 'Bisherige Verbindung der Organisation ins Parlament',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NULL DEFAULT NULL COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgeändert von',
  `updated_date` timestamp NULL DEFAULT NULL COMMENT 'Abgeändert am',
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Log-Schlüssel',
  `action` enum('insert','update','delete','snapshot') NOT NULL COMMENT 'Aktionstyp',
  `state` varchar(20) DEFAULT NULL COMMENT 'Status der Aktion',
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Datum der Aktion',
  `snapshot_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel zu einem Snapshot',
  PRIMARY KEY (`log_id`),
  KEY `idx_lobbytyp` (`branche_id`),
  KEY `idx_lobbygroup` (`interessengruppe_id`),
  KEY `fk_organisation_log_snapshot_id` (`snapshot_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Liste der Lobbyorganisationen' AUTO_INCREMENT=346 ;

--
-- RELATIONEN DER TABELLE `organisation_log`:
--   `snapshot_id`
--       `snapshot` -> `id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `parlamentarier`
--
-- Erzeugt am: 30. Dez 2013 um 04:29
--

DROP TABLE IF EXISTS `parlamentarier`;
CREATE TABLE IF NOT EXISTS `parlamentarier` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Schlüssel des Parlamentariers',
  `nachname` varchar(100) NOT NULL COMMENT 'Nachname des Parlamentariers',
  `vorname` varchar(50) NOT NULL COMMENT 'Vornahme des Parlamentariers',
  `zweiter_vorname` varchar(50) DEFAULT NULL COMMENT 'Zweiter Vorname des Parlamentariers',
  `ratstyp` enum('NR','SR') NOT NULL COMMENT 'National- oder Ständerat?',
  `kanton` enum('AG','AR','AI','BL','BS','BE','FR','GE','GL','GR','JU','LU','NE','NW','OW','SH','SZ','SO','SG','TI','TG','UR','VD','VS','ZG','ZH') NOT NULL COMMENT 'Kantonskürzel',
  `partei_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel Partei. Leer bedeutet parteilos.',
  `parteifunktion` enum('mitglied','praesident','vizepraesident') NOT NULL DEFAULT 'mitglied' COMMENT 'Funktion des Parlamentariers in der Partei',
  `fraktionsfunktion` enum('mitglied','praesident','vizepraesident') DEFAULT 'mitglied' COMMENT 'Funktion des Parlamentariers in der Fraktion',
  `im_rat_seit` date NOT NULL COMMENT 'Jahr der Zugehörigkeit zum Parlament',
  `im_rat_bis` date DEFAULT NULL COMMENT 'Austrittsdatum aus dem Parlament. Leer (NULL) = aktuell im Rat, nicht leer = historischer Eintrag',
  `ratsunterbruch_von` date DEFAULT NULL COMMENT 'Unterbruch in der Ratstätigkeit von, leer (NULL) = kein Unterbruch',
  `ratsunterbruch_bis` date DEFAULT NULL COMMENT 'Unterbruch in der Ratstätigkeit bis, leer (NULL) = kein Unterbruch',
  `beruf` varchar(150) DEFAULT NULL COMMENT 'Beruf des Parlamentariers',
  `beruf_interessengruppe_id` int(11) DEFAULT NULL COMMENT 'Zuordnung (Fremdschlüssel) zu Interessengruppe für den Beruf des Parlamentariers',
  `militaerischer_grad` int(11) DEFAULT NULL COMMENT 'Militärischer Grad, leer (NULL) = kein Militärdienst',
  `geschlecht` enum('M','F') DEFAULT 'M' COMMENT 'Geschlecht des Parlamentariers, M=Mann, F=Frau',
  `geburtstag` date DEFAULT NULL COMMENT 'Geburtstag des Parlamentariers',
  `photo` varchar(255) DEFAULT NULL COMMENT 'Photo des Parlamentariers (JPEG/jpg)',
  `photo_dateiname` varchar(255) DEFAULT NULL COMMENT 'Photodateiname ohne Erweiterung',
  `photo_dateierweiterung` varchar(15) DEFAULT NULL COMMENT 'Erweiterung der Photodatei',
  `photo_dateiname_voll` varchar(255) DEFAULT NULL COMMENT 'Photodateiname mit Erweiterung',
  `photo_mime_type` varchar(100) DEFAULT NULL COMMENT 'MIME Type des Photos',
  `kleinbild` varchar(80) DEFAULT 'leer.png' COMMENT 'Bild 44x62 px oder leer.png',
  `sitzplatz` int(11) DEFAULT NULL COMMENT 'Sitzplatznr im Parlament. Siehe Sitzordnung auf parlament.ch',
  `email` varchar(100) DEFAULT NULL COMMENT 'E-Mail-Adresse des Parlamentariers',
  `parlament_url` varchar(255) DEFAULT NULL COMMENT 'Link zur Biographie auf Parlament.ch',
  `homepage` varchar(150) DEFAULT NULL COMMENT 'Homepage des Parlamentariers',
  `ALT_kommission` varchar(255) DEFAULT NULL COMMENT 'Kommissionen als Einträge in Tabelle "in_kommission" erfassen. Wird später entfernt. Mitglied in Kommission(en) als Freitext',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgeändert von',
  `updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Abgeändert am',
  PRIMARY KEY (`id`),
  UNIQUE KEY `parlamentarier_nachname_vorname_unique` (`nachname`,`vorname`) COMMENT 'Fachlicher unique constraint',
  UNIQUE KEY `parlamentarier_rat_sitzplatz` (`ratstyp`,`sitzplatz`) COMMENT 'Fachlicher unique constraint',
  KEY `idx_partei` (`partei_id`),
  KEY `beruf_branche_id` (`beruf_interessengruppe_id`),
  KEY `militaerischer_grad` (`militaerischer_grad`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Liste der Parlamentarier' AUTO_INCREMENT=39 ;

--
-- MIME TYPEN DER TABELLE `parlamentarier`:
--   `kleinbild`
--       `Image_JPEG`
--   `photo`
--       `Image_JPEG`
--

--
-- RELATIONEN DER TABELLE `parlamentarier`:
--   `beruf_interessengruppe_id`
--       `interessengruppe` -> `id`
--   `militaerischer_grad`
--       `mil_grad` -> `id`
--   `partei_id`
--       `partei` -> `id`
--

--
-- Trigger `parlamentarier`
--
DROP TRIGGER IF EXISTS `trg_parlamentarier_log_del_after`;
DELIMITER //
CREATE TRIGGER `trg_parlamentarier_log_del_after` AFTER DELETE ON `parlamentarier`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  UPDATE `parlamentarier_log`
    SET `state` = 'OK'
    WHERE `id` = OLD.`id` AND `created_date` = OLD.`created_date` AND action = 'delete';
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_parlamentarier_log_del_before`;
DELIMITER //
CREATE TRIGGER `trg_parlamentarier_log_del_before` BEFORE DELETE ON `parlamentarier`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `parlamentarier_log`
    SELECT *, null, 'delete', null, NOW(), null FROM `parlamentarier` WHERE id = OLD.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_parlamentarier_log_ins`;
DELIMITER //
CREATE TRIGGER `trg_parlamentarier_log_ins` AFTER INSERT ON `parlamentarier`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `parlamentarier_log`
    SELECT *, null, 'insert', null, NOW(), null FROM `parlamentarier` WHERE id = NEW.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_parlamentarier_log_upd`;
DELIMITER //
CREATE TRIGGER `trg_parlamentarier_log_upd` AFTER UPDATE ON `parlamentarier`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `parlamentarier_log`
    SELECT *, null, 'update', null, NOW(), null FROM `parlamentarier` WHERE id = NEW.id ;
end
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `parlamentarier_anhang`
--
-- Erzeugt am: 30. Dez 2013 um 04:29
--

DROP TABLE IF EXISTS `parlamentarier_anhang`;
CREATE TABLE IF NOT EXISTS `parlamentarier_anhang` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Schlüssel des Parlamentarieranhangs',
  `parlamentarier_id` int(11) NOT NULL COMMENT 'Fremdschlüssel eines Parlamentariers',
  `datei` varchar(255) NOT NULL COMMENT 'Datei',
  `dateiname` varchar(255) NOT NULL COMMENT 'Dateiname ohne Erweiterung',
  `dateierweiterung` varchar(15) DEFAULT NULL COMMENT 'Erweiterung der Datei',
  `dateiname_voll` varchar(255) NOT NULL COMMENT 'Dateiname inkl. Erweiterung',
  `mime_type` varchar(100) NOT NULL COMMENT 'MIME Type der Datei',
  `encoding` varchar(20) NOT NULL COMMENT 'Encoding der Datei',
  `beschreibung` varchar(150) NOT NULL COMMENT 'Beschreibung des Anhangs',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgäendert von',
  `updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Abgäendert am',
  PRIMARY KEY (`id`),
  KEY `parlamentarier_id` (`parlamentarier_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Anhänge zu Parlamentariern' AUTO_INCREMENT=1 ;

--
-- MIME TYPEN DER TABELLE `parlamentarier_anhang`:
--   `datei`
--       `Application_Octetstream`
--

--
-- RELATIONEN DER TABELLE `parlamentarier_anhang`:
--   `parlamentarier_id`
--       `parlamentarier` -> `id`
--

--
-- Trigger `parlamentarier_anhang`
--
DROP TRIGGER IF EXISTS `trg_parlamentarier_anhang_log_del_after`;
DELIMITER //
CREATE TRIGGER `trg_parlamentarier_anhang_log_del_after` AFTER DELETE ON `parlamentarier_anhang`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  UPDATE `parlamentarier_anhang_log`
    SET `state` = 'OK'
    WHERE `id` = OLD.`id` AND `created_date` = OLD.`created_date` AND action = 'delete';
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_parlamentarier_anhang_log_del_before`;
DELIMITER //
CREATE TRIGGER `trg_parlamentarier_anhang_log_del_before` BEFORE DELETE ON `parlamentarier_anhang`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `parlamentarier_anhang_log`
    SELECT *, null, 'delete', null, NOW(), null FROM `parlamentarier_anhang` WHERE id = OLD.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_parlamentarier_anhang_log_ins`;
DELIMITER //
CREATE TRIGGER `trg_parlamentarier_anhang_log_ins` AFTER INSERT ON `parlamentarier_anhang`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `parlamentarier_anhang_log`
    SELECT *, null, 'insert', null, NOW(), null FROM `parlamentarier_anhang` WHERE id = NEW.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_parlamentarier_anhang_log_upd`;
DELIMITER //
CREATE TRIGGER `trg_parlamentarier_anhang_log_upd` AFTER UPDATE ON `parlamentarier_anhang`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `parlamentarier_anhang_log`
    SELECT *, null, 'update', null, NOW(), null FROM `parlamentarier_anhang` WHERE id = NEW.id ;
end
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `parlamentarier_anhang_log`
--
-- Erzeugt am: 30. Dez 2013 um 05:51
--

DROP TABLE IF EXISTS `parlamentarier_anhang_log`;
CREATE TABLE IF NOT EXISTS `parlamentarier_anhang_log` (
  `id` int(11) NOT NULL COMMENT 'Technischer Schlüssel der Live-Daten',
  `parlamentarier_id` int(11) NOT NULL COMMENT 'Fremdschlüssel eines Parlamentariers',
  `datei` varchar(255) NOT NULL COMMENT 'Datei',
  `dateiname` varchar(255) NOT NULL COMMENT 'Dateiname ohne Erweiterung',
  `dateierweiterung` varchar(15) DEFAULT NULL COMMENT 'Erweiterung der Datei',
  `dateiname_voll` varchar(255) NOT NULL COMMENT 'Dateiname inkl. Erweiterung',
  `mime_type` varchar(100) NOT NULL COMMENT 'MIME Type der Datei',
  `encoding` varchar(20) NOT NULL COMMENT 'Encoding der Datei',
  `beschreibung` varchar(150) NOT NULL COMMENT 'Beschreibung des Anhangs',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NULL DEFAULT NULL COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgäendert von',
  `updated_date` timestamp NULL DEFAULT NULL COMMENT 'Abgeändert am',
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Log-Schlüssel',
  `action` enum('insert','update','delete','snapshot') NOT NULL COMMENT 'Aktionstyp',
  `state` varchar(20) DEFAULT NULL COMMENT 'Status der Aktion',
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Datum der Aktion',
  `snapshot_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel zu einem Snapshot',
  PRIMARY KEY (`log_id`),
  KEY `parlamentarier_id` (`parlamentarier_id`),
  KEY `fk_parlamentarier_anhang_log_snapshot_id` (`snapshot_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Anhänge zu Parlamentariern' AUTO_INCREMENT=1 ;

--
-- RELATIONEN DER TABELLE `parlamentarier_anhang_log`:
--   `snapshot_id`
--       `snapshot` -> `id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `parlamentarier_log`
--
-- Erzeugt am: 30. Dez 2013 um 05:51
--

DROP TABLE IF EXISTS `parlamentarier_log`;
CREATE TABLE IF NOT EXISTS `parlamentarier_log` (
  `id` int(11) NOT NULL COMMENT 'Technischer Schlüssel der Live-Daten',
  `nachname` varchar(100) NOT NULL COMMENT 'Nachname des Parlamentariers',
  `vorname` varchar(50) NOT NULL COMMENT 'Vornahme des Parlamentariers',
  `zweiter_vorname` varchar(50) DEFAULT NULL COMMENT 'Zweiter Vorname des Parlamentariers',
  `ratstyp` enum('NR','SR') NOT NULL COMMENT 'National- oder Ständerat?',
  `kanton` enum('AG','AR','AI','BL','BS','BE','FR','GE','GL','GR','JU','LU','NE','NW','OW','SH','SZ','SO','SG','TI','TG','UR','VD','VS','ZG','ZH') NOT NULL COMMENT 'Kantonskürzel',
  `partei_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel Partei. Leer bedeutet parteilos.',
  `parteifunktion` enum('mitglied','praesident','vizepraesident') NOT NULL DEFAULT 'mitglied' COMMENT 'Funktion des Parlamentariers in der Partei',
  `fraktionsfunktion` enum('mitglied','praesident','vizepraesident') DEFAULT 'mitglied' COMMENT 'Funktion des Parlamentariers in der Fraktion',
  `im_rat_seit` date NOT NULL COMMENT 'Jahr der Zugehörigkeit zum Parlament',
  `im_rat_bis` date DEFAULT NULL COMMENT 'Austrittsdatum aus dem Parlament. Leer (NULL) = aktuell im Rat, nicht leer = historischer Eintrag',
  `ratsunterbruch_von` date DEFAULT NULL COMMENT 'Unterbruch in der Ratstätigkeit von, leer (NULL) = kein Unterbruch',
  `ratsunterbruch_bis` date DEFAULT NULL COMMENT 'Unterbruch in der Ratstätigkeit bis, leer (NULL) = kein Unterbruch',
  `beruf` varchar(150) DEFAULT NULL COMMENT 'Beruf des Parlamentariers',
  `beruf_interessengruppe_id` int(11) DEFAULT NULL COMMENT 'Zuordnung (Fremdschlüssel) zu Interessengruppe für den Beruf des Parlamentariers',
  `militaerischer_grad` int(11) DEFAULT NULL COMMENT 'Militärischer Grad, leer (NULL) = kein Militärdienst',
  `geschlecht` enum('M','F') DEFAULT 'M' COMMENT 'Geschlecht des Parlamentariers, M=Mann, F=Frau',
  `geburtstag` date DEFAULT NULL COMMENT 'Geburtstag des Parlamentariers',
  `photo` varchar(255) DEFAULT NULL COMMENT 'Photo des Parlamentariers (JPEG/jpg)',
  `photo_dateiname` varchar(255) DEFAULT NULL COMMENT 'Photodateiname ohne Erweiterung',
  `photo_dateierweiterung` varchar(15) DEFAULT NULL COMMENT 'Erweiterung der Photodatei',
  `photo_dateiname_voll` varchar(255) DEFAULT NULL COMMENT 'Photodateiname mit Erweiterung',
  `photo_mime_type` varchar(100) DEFAULT NULL COMMENT 'MIME Type des Photos',
  `kleinbild` varchar(80) DEFAULT 'leer.png' COMMENT 'Bild 44x62 px oder leer.png',
  `sitzplatz` int(11) DEFAULT NULL COMMENT 'Sitzplatznr im Parlament. Siehe Sitzordnung auf parlament.ch',
  `email` varchar(100) DEFAULT NULL COMMENT 'E-Mail-Adresse des Parlamentariers',
  `parlament_url` varchar(255) DEFAULT NULL COMMENT 'Link zur Biographie auf Parlament.ch',
  `homepage` varchar(150) DEFAULT NULL COMMENT 'Homepage des Parlamentariers',
  `ALT_kommission` varchar(255) DEFAULT NULL COMMENT 'Kommissionen als Einträge in Tabelle "in_kommission" erfassen. Wird später entfernt. Mitglied in Kommission(en) als Freitext',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NULL DEFAULT NULL COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgeändert von',
  `updated_date` timestamp NULL DEFAULT NULL COMMENT 'Abgeändert am',
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Log-Schlüssel',
  `action` enum('insert','update','delete','snapshot') NOT NULL COMMENT 'Aktionstyp',
  `state` varchar(20) DEFAULT NULL COMMENT 'Status der Aktion',
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Datum der Aktion',
  `snapshot_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel zu einem Snapshot',
  PRIMARY KEY (`log_id`),
  KEY `idx_partei` (`partei_id`),
  KEY `beruf_branche_id` (`beruf_interessengruppe_id`),
  KEY `militaerischer_grad` (`militaerischer_grad`),
  KEY `fk_parlamentarier_log_snapshot_id` (`snapshot_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Liste der Parlamentarier' AUTO_INCREMENT=39 ;

--
-- RELATIONEN DER TABELLE `parlamentarier_log`:
--   `snapshot_id`
--       `snapshot` -> `id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `partei`
--
-- Erzeugt am: 05. Jan 2014 um 08:34
--

DROP TABLE IF EXISTS `partei`;
CREATE TABLE IF NOT EXISTS `partei` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Schlüssel der Partei',
  `abkuerzung` varchar(20) NOT NULL COMMENT 'Parteiabkürzung',
  `name` varchar(100) DEFAULT NULL COMMENT 'Ausgeschriebener Name der Partei',
  `gruendung` date DEFAULT NULL COMMENT 'Gründungsjahr der Partei. Wenn der genaue Tag unbekannt ist, den 1. Januar wählen.',
  `position` enum('links','rechts','mitte','') DEFAULT NULL COMMENT 'Politische Position der Partei',
  `homepage` varchar(255) DEFAULT NULL COMMENT 'Homepage der Partei',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgeändert von',
  `updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Abgeändert am',
  PRIMARY KEY (`id`),
  UNIQUE KEY `partei_abkuerzung_unique` (`abkuerzung`) COMMENT 'Fachlicher unique constraint',
  UNIQUE KEY `partei_name_unique` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Politische Parteien des Parlamentes' AUTO_INCREMENT=9 ;

--
-- Trigger `partei`
--
DROP TRIGGER IF EXISTS `trg_partei_log_del_after`;
DELIMITER //
CREATE TRIGGER `trg_partei_log_del_after` AFTER DELETE ON `partei`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  UPDATE `partei_log`
    SET `state` = 'OK'
    WHERE `id` = OLD.`id` AND `created_date` = OLD.`created_date` AND action = 'delete';
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_partei_log_del_before`;
DELIMITER //
CREATE TRIGGER `trg_partei_log_del_before` BEFORE DELETE ON `partei`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `partei_log`
    SELECT *, null, 'delete', null, NOW(), null FROM `partei` WHERE id = OLD.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_partei_log_ins`;
DELIMITER //
CREATE TRIGGER `trg_partei_log_ins` AFTER INSERT ON `partei`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `partei_log`
    SELECT *, null, 'insert', null, NOW(), null FROM `partei` WHERE id = NEW.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_partei_log_upd`;
DELIMITER //
CREATE TRIGGER `trg_partei_log_upd` AFTER UPDATE ON `partei`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `partei_log`
    SELECT *, null, 'update', null, NOW(), null FROM `partei` WHERE id = NEW.id ;
end
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `partei_log`
--
-- Erzeugt am: 05. Jan 2014 um 08:34
--

DROP TABLE IF EXISTS `partei_log`;
CREATE TABLE IF NOT EXISTS `partei_log` (
  `id` int(11) NOT NULL COMMENT 'Technischer Schlüssel der Live-Daten',
  `abkuerzung` varchar(20) NOT NULL COMMENT 'Parteiabkürzung',
  `name` varchar(100) DEFAULT NULL COMMENT 'Ausgeschriebener Name der Partei',
  `gruendung` date DEFAULT NULL COMMENT 'Gründungsjahr der Partei. Wenn der genaue Tag unbekannt ist, den 1. Januar wählen.',
  `position` enum('links','rechts','mitte','') DEFAULT NULL COMMENT 'Politische Position der Partei',
  `homepage` varchar(255) DEFAULT NULL COMMENT 'Homepage der Partei',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NULL DEFAULT NULL COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgeändert von',
  `updated_date` timestamp NULL DEFAULT NULL COMMENT 'Abgeändert am',
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Log-Schlüssel',
  `action` enum('insert','update','delete','snapshot') NOT NULL COMMENT 'Aktionstyp',
  `state` varchar(20) DEFAULT NULL COMMENT 'Status der Aktion',
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Datum der Aktion',
  `snapshot_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel zu einem Snapshot',
  PRIMARY KEY (`log_id`),
  KEY `fk_partei_log_snapshot_id` (`snapshot_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Politische Parteien des Parlamentes' AUTO_INCREMENT=20 ;

--
-- RELATIONEN DER TABELLE `partei_log`:
--   `snapshot_id`
--       `snapshot` -> `id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `snapshot`
--
-- Erzeugt am: 30. Dez 2013 um 05:51
--

DROP TABLE IF EXISTS `snapshot`;
CREATE TABLE IF NOT EXISTS `snapshot` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Schlüssel des Snapshots',
  `beschreibung` varchar(150) NOT NULL COMMENT 'Beschreibung des Snapshots',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Eintrge am besten mit Datum und Visa versehen.',
  `created_visa` varchar(10) NOT NULL COMMENT 'Erstellt von',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Erstellt am',
  `updated_visa` varchar(10) NOT NULL COMMENT 'Abgeändert von',
  `updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Abgeändert am',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Lobbywatch snapshots' AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `user`
--
-- Erzeugt am: 31. Dez 2013 um 07:30
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE IF NOT EXISTS `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Schlüssel User',
  `name` varchar(10) NOT NULL,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='PHP Generator users' AUTO_INCREMENT=8 ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `user_permission`
--
-- Erzeugt am: 31. Dez 2013 um 10:20
--

DROP TABLE IF EXISTS `user_permission`;
CREATE TABLE IF NOT EXISTS `user_permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Schlüssel User Persmissions',
  `user_id` int(11) NOT NULL,
  `page_name` varchar(500) DEFAULT NULL,
  `permission_name` varchar(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='PHP Generator user permissions' AUTO_INCREMENT=152 ;

-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_branche`
--
DROP VIEW IF EXISTS `v_branche`;
CREATE TABLE IF NOT EXISTS `v_branche` (
`id` int(11)
,`name` varchar(100)
,`kommission_id` int(11)
,`beschreibung` text
,`angaben` text
,`notizen` text
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_interessenbindung`
--
DROP VIEW IF EXISTS `v_interessenbindung`;
CREATE TABLE IF NOT EXISTS `v_interessenbindung` (
`id` int(11)
,`parlamentarier_id` int(11)
,`organisation_id` int(11)
,`art` enum('mitglied','geschaeftsfuehrend','vorstand','taetig','beirat')
,`deklarationstyp` enum('deklarationspflichtig','nicht deklarationspflicht')
,`status` enum('deklariert','nicht-deklariert')
,`verguetung` int(11)
,`beschreibung` varchar(150)
,`von` date
,`bis` date
,`notizen` text
,`autorisiert_datum` date
,`autorisiert_visa` varchar(10)
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_interessenbindung_authorisierungs_email`
--
DROP VIEW IF EXISTS `v_interessenbindung_authorisierungs_email`;
CREATE TABLE IF NOT EXISTS `v_interessenbindung_authorisierungs_email` (
`parlamentarier_name` varchar(151)
,`geschlecht` varchar(1)
,`organisation_name` varchar(454)
,`rechtsform` varchar(23)
,`ort` varchar(100)
,`art` enum('mitglied','geschaeftsfuehrend','vorstand','taetig','beirat')
,`beschreibung` varchar(150)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_interessenbindung_liste`
--
DROP VIEW IF EXISTS `v_interessenbindung_liste`;
CREATE TABLE IF NOT EXISTS `v_interessenbindung_liste` (
`organisation_name` varchar(454)
,`id` int(11)
,`parlamentarier_id` int(11)
,`organisation_id` int(11)
,`art` enum('mitglied','geschaeftsfuehrend','vorstand','taetig','beirat')
,`deklarationstyp` enum('deklarationspflichtig','nicht deklarationspflicht')
,`status` enum('deklariert','nicht-deklariert')
,`verguetung` int(11)
,`beschreibung` varchar(150)
,`von` date
,`bis` date
,`notizen` text
,`autorisiert_datum` date
,`autorisiert_visa` varchar(10)
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_interessenbindung_liste_indirekt`
--
DROP VIEW IF EXISTS `v_interessenbindung_liste_indirekt`;
CREATE TABLE IF NOT EXISTS `v_interessenbindung_liste_indirekt` (
`beziehung` varchar(8)
,`organisation_name` varchar(454)
,`id` int(11)
,`parlamentarier_id` int(11)
,`organisation_id` int(11)
,`art` varchar(18)
,`deklarationstyp` varchar(25)
,`status` varchar(16)
,`verguetung` int(11)
,`beschreibung` varchar(150)
,`von` date
,`bis` date
,`notizen` text
,`autorisiert_datum` date
,`autorisiert_visa` varchar(10)
,`freigabe_visa` varchar(7)
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_interessengruppe`
--
DROP VIEW IF EXISTS `v_interessengruppe`;
CREATE TABLE IF NOT EXISTS `v_interessengruppe` (
`id` int(11)
,`name` varchar(150)
,`branche_id` int(11)
,`beschreibung` text
,`notizen` text
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_in_kommission`
--
DROP VIEW IF EXISTS `v_in_kommission`;
CREATE TABLE IF NOT EXISTS `v_in_kommission` (
`id` int(11)
,`parlamentarier_id` int(11)
,`kommission_id` int(11)
,`funktion` enum('praesident','vizepraesident','mitglied')
,`von` date
,`bis` date
,`notizen` text
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_in_kommission_liste`
--
DROP VIEW IF EXISTS `v_in_kommission_liste`;
CREATE TABLE IF NOT EXISTS `v_in_kommission_liste` (
`abkuerzung` varchar(15)
,`name` varchar(100)
,`id` int(11)
,`parlamentarier_id` int(11)
,`kommission_id` int(11)
,`funktion` enum('praesident','vizepraesident','mitglied')
,`von` date
,`bis` date
,`notizen` text
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_in_kommission_parlamentarier`
--
DROP VIEW IF EXISTS `v_in_kommission_parlamentarier`;
CREATE TABLE IF NOT EXISTS `v_in_kommission_parlamentarier` (
`parlamentarier_name` varchar(152)
,`abkuerzung` varchar(20)
,`id` int(11)
,`parlamentarier_id` int(11)
,`kommission_id` int(11)
,`funktion` enum('praesident','vizepraesident','mitglied')
,`von` date
,`bis` date
,`notizen` text
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_kommission`
--
DROP VIEW IF EXISTS `v_kommission`;
CREATE TABLE IF NOT EXISTS `v_kommission` (
`anzeige_name` varchar(118)
,`id` int(11)
,`abkuerzung` varchar(15)
,`name` varchar(100)
,`typ` enum('kommission','subkommission','spezialkommission')
,`beschreibung` text
,`sachbereiche` text
,`mutter_kommission_id` int(11)
,`parlament_url` varchar(255)
,`notizen` text
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_last_updated_branche`
--
DROP VIEW IF EXISTS `v_last_updated_branche`;
CREATE TABLE IF NOT EXISTS `v_last_updated_branche` (
`table_name` varchar(7)
,`name` varchar(7)
,`anzahl_eintraege` bigint(21)
,`last_visa` varchar(10)
,`last_updated` timestamp
,`last_updated_id` int(11)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_last_updated_interessenbindung`
--
DROP VIEW IF EXISTS `v_last_updated_interessenbindung`;
CREATE TABLE IF NOT EXISTS `v_last_updated_interessenbindung` (
`table_name` varchar(17)
,`name` varchar(17)
,`anzahl_eintraege` bigint(21)
,`last_visa` varchar(10)
,`last_updated` timestamp
,`last_updated_id` int(11)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_last_updated_interessengruppe`
--
DROP VIEW IF EXISTS `v_last_updated_interessengruppe`;
CREATE TABLE IF NOT EXISTS `v_last_updated_interessengruppe` (
`table_name` varchar(16)
,`name` varchar(16)
,`anzahl_eintraege` bigint(21)
,`last_visa` varchar(10)
,`last_updated` timestamp
,`last_updated_id` int(11)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_last_updated_in_kommission`
--
DROP VIEW IF EXISTS `v_last_updated_in_kommission`;
CREATE TABLE IF NOT EXISTS `v_last_updated_in_kommission` (
`table_name` varchar(13)
,`name` varchar(13)
,`anzahl_eintraege` bigint(21)
,`last_visa` varchar(10)
,`last_updated` timestamp
,`last_updated_id` int(11)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_last_updated_kommission`
--
DROP VIEW IF EXISTS `v_last_updated_kommission`;
CREATE TABLE IF NOT EXISTS `v_last_updated_kommission` (
`table_name` varchar(10)
,`name` varchar(10)
,`anzahl_eintraege` bigint(21)
,`last_visa` varchar(10)
,`last_updated` timestamp
,`last_updated_id` int(11)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_last_updated_mandat`
--
DROP VIEW IF EXISTS `v_last_updated_mandat`;
CREATE TABLE IF NOT EXISTS `v_last_updated_mandat` (
`table_name` varchar(6)
,`name` varchar(6)
,`anzahl_eintraege` bigint(21)
,`last_visa` varchar(10)
,`last_updated` timestamp
,`last_updated_id` int(11)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_last_updated_organisation`
--
DROP VIEW IF EXISTS `v_last_updated_organisation`;
CREATE TABLE IF NOT EXISTS `v_last_updated_organisation` (
`table_name` varchar(12)
,`name` varchar(12)
,`anzahl_eintraege` bigint(21)
,`last_visa` varchar(10)
,`last_updated` timestamp
,`last_updated_id` int(11)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_last_updated_organisation_beziehung`
--
DROP VIEW IF EXISTS `v_last_updated_organisation_beziehung`;
CREATE TABLE IF NOT EXISTS `v_last_updated_organisation_beziehung` (
`table_name` varchar(22)
,`name` varchar(22)
,`anzahl_eintraege` bigint(21)
,`last_visa` varchar(10)
,`last_updated` timestamp
,`last_updated_id` int(11)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_last_updated_parlamentarier`
--
DROP VIEW IF EXISTS `v_last_updated_parlamentarier`;
CREATE TABLE IF NOT EXISTS `v_last_updated_parlamentarier` (
`table_name` varchar(14)
,`name` varchar(14)
,`anzahl_eintraege` bigint(21)
,`last_visa` varchar(10)
,`last_updated` timestamp
,`last_updated_id` int(11)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_last_updated_parlamentarier_anhang`
--
DROP VIEW IF EXISTS `v_last_updated_parlamentarier_anhang`;
CREATE TABLE IF NOT EXISTS `v_last_updated_parlamentarier_anhang` (
`table_name` varchar(21)
,`name` varchar(20)
,`anzahl_eintraege` bigint(21)
,`last_visa` varchar(10)
,`last_updated` timestamp
,`last_updated_id` int(11)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_last_updated_partei`
--
DROP VIEW IF EXISTS `v_last_updated_partei`;
CREATE TABLE IF NOT EXISTS `v_last_updated_partei` (
`table_name` varchar(6)
,`name` varchar(6)
,`anzahl_eintraege` bigint(21)
,`last_visa` varchar(10)
,`last_updated` timestamp
,`last_updated_id` int(11)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_last_updated_tables`
--
DROP VIEW IF EXISTS `v_last_updated_tables`;
CREATE TABLE IF NOT EXISTS `v_last_updated_tables` (
`table_name` varchar(22)
,`name` varchar(22)
,`anzahl_eintraege` bigint(21)
,`last_visa` varchar(10)
,`last_updated` timestamp
,`last_updated_id` int(11)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_last_updated_tables_unordered`
--
DROP VIEW IF EXISTS `v_last_updated_tables_unordered`;
CREATE TABLE IF NOT EXISTS `v_last_updated_tables_unordered` (
`table_name` varchar(22)
,`name` varchar(22)
,`anzahl_eintraege` bigint(21)
,`last_visa` varchar(10)
,`last_updated` timestamp
,`last_updated_id` int(11)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_last_updated_zutrittsberechtigung`
--
DROP VIEW IF EXISTS `v_last_updated_zutrittsberechtigung`;
CREATE TABLE IF NOT EXISTS `v_last_updated_zutrittsberechtigung` (
`table_name` varchar(20)
,`name` varchar(20)
,`anzahl_eintraege` bigint(21)
,`last_visa` varchar(10)
,`last_updated` timestamp
,`last_updated_id` int(11)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_mandat`
--
DROP VIEW IF EXISTS `v_mandat`;
CREATE TABLE IF NOT EXISTS `v_mandat` (
`id` int(11)
,`zutrittsberechtigung_id` int(11)
,`organisation_id` int(11)
,`art` enum('mitglied','geschaeftsfuehrend','vorstand','taetig','beirat')
,`verguetung` int(11)
,`beschreibung` varchar(150)
,`von` date
,`bis` date
,`notizen` text
,`autorisiert_datum` date
,`autorisiert_visa` varchar(10)
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_mil_grad`
--
DROP VIEW IF EXISTS `v_mil_grad`;
CREATE TABLE IF NOT EXISTS `v_mil_grad` (
`id` int(11)
,`name` varchar(30)
,`abkuerzung` varchar(10)
,`typ` enum('Mannschaft','Unteroffizier','Hoeherer Unteroffizier','Offizier','Hoeherer Stabsoffizier')
,`ranghoehe` int(11)
,`anzeigestufe` int(11)
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_organisation`
--
DROP VIEW IF EXISTS `v_organisation`;
CREATE TABLE IF NOT EXISTS `v_organisation` (
`anzeige_name` varchar(454)
,`name` varchar(454)
,`id` int(11)
,`name_de` varchar(150)
,`name_fr` varchar(150)
,`name_it` varchar(150)
,`ort` varchar(100)
,`rechtsform` enum('AG','GmbH','Stiftung','Verein','Informelle Gruppe','Parlamentarische Gruppe','Oeffentlich-rechtlich','Einzelunternehmen','KG')
,`typ` set('EinzelOrganisation','DachOrganisation','MitgliedsOrganisation','LeistungsErbringer','dezidierteLobby')
,`vernehmlassung` enum('immer','punktuell','nie')
,`interessengruppe_id` int(11)
,`branche_id` int(11)
,`url` varchar(255)
,`handelsregister_url` varchar(255)
,`beschreibung` text
,`ALT_parlam_verbindung` set('einzel','mehrere','mitglied','exekutiv','kommission')
,`notizen` text
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_organisation_beziehung`
--
DROP VIEW IF EXISTS `v_organisation_beziehung`;
CREATE TABLE IF NOT EXISTS `v_organisation_beziehung` (
`id` int(11)
,`organisation_id` int(11)
,`ziel_organisation_id` int(11)
,`art` enum('arbeitet fuer','mitglied von')
,`von` date
,`bis` date
,`notizen` text
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_organisation_beziehung_arbeitet_fuer`
--
DROP VIEW IF EXISTS `v_organisation_beziehung_arbeitet_fuer`;
CREATE TABLE IF NOT EXISTS `v_organisation_beziehung_arbeitet_fuer` (
`organisation_name` varchar(454)
,`id` int(11)
,`organisation_id` int(11)
,`ziel_organisation_id` int(11)
,`art` enum('arbeitet fuer','mitglied von')
,`von` date
,`bis` date
,`notizen` text
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_organisation_beziehung_auftraggeber_fuer`
--
DROP VIEW IF EXISTS `v_organisation_beziehung_auftraggeber_fuer`;
CREATE TABLE IF NOT EXISTS `v_organisation_beziehung_auftraggeber_fuer` (
`organisation_name` varchar(454)
,`id` int(11)
,`organisation_id` int(11)
,`ziel_organisation_id` int(11)
,`art` enum('arbeitet fuer','mitglied von')
,`von` date
,`bis` date
,`notizen` text
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_organisation_beziehung_mitglieder`
--
DROP VIEW IF EXISTS `v_organisation_beziehung_mitglieder`;
CREATE TABLE IF NOT EXISTS `v_organisation_beziehung_mitglieder` (
`organisation_name` varchar(454)
,`id` int(11)
,`organisation_id` int(11)
,`ziel_organisation_id` int(11)
,`art` enum('arbeitet fuer','mitglied von')
,`von` date
,`bis` date
,`notizen` text
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_organisation_beziehung_mitglied_von`
--
DROP VIEW IF EXISTS `v_organisation_beziehung_mitglied_von`;
CREATE TABLE IF NOT EXISTS `v_organisation_beziehung_mitglied_von` (
`organisation_name` varchar(454)
,`id` int(11)
,`organisation_id` int(11)
,`ziel_organisation_id` int(11)
,`art` enum('arbeitet fuer','mitglied von')
,`von` date
,`bis` date
,`notizen` text
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_organisation_parlamentarier`
--
DROP VIEW IF EXISTS `v_organisation_parlamentarier`;
CREATE TABLE IF NOT EXISTS `v_organisation_parlamentarier` (
`parlamentarier_name` varchar(152)
,`id` int(11)
,`parlamentarier_id` int(11)
,`organisation_id` int(11)
,`art` enum('mitglied','geschaeftsfuehrend','vorstand','taetig','beirat')
,`deklarationstyp` enum('deklarationspflichtig','nicht deklarationspflicht')
,`status` enum('deklariert','nicht-deklariert')
,`verguetung` int(11)
,`beschreibung` varchar(150)
,`von` date
,`bis` date
,`notizen` text
,`autorisiert_datum` date
,`autorisiert_visa` varchar(10)
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_organisation_parlamentarier_indirekt`
--
DROP VIEW IF EXISTS `v_organisation_parlamentarier_indirekt`;
CREATE TABLE IF NOT EXISTS `v_organisation_parlamentarier_indirekt` (
`beziehung` varchar(8)
,`parlamentarier_name` varchar(152)
,`id` int(11)
,`parlamentarier_id` int(11)
,`organisation_id` int(11)
,`art` varchar(18)
,`deklarationstyp` varchar(25)
,`status` varchar(16)
,`verguetung` int(11)
,`beschreibung` varchar(150)
,`von` date
,`bis` date
,`notizen` text
,`autorisiert_datum` date
,`autorisiert_visa` varchar(10)
,`freigabe_visa` varchar(7)
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
,`connector_organisation_id` int(11)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_parlamentarier`
--
DROP VIEW IF EXISTS `v_parlamentarier`;
CREATE TABLE IF NOT EXISTS `v_parlamentarier` (
`anzeige_name` varchar(152)
,`name` varchar(151)
,`id` int(11)
,`nachname` varchar(100)
,`vorname` varchar(50)
,`zweiter_vorname` varchar(50)
,`ratstyp` enum('NR','SR')
,`kanton` enum('AG','AR','AI','BL','BS','BE','FR','GE','GL','GR','JU','LU','NE','NW','OW','SH','SZ','SO','SG','TI','TG','UR','VD','VS','ZG','ZH')
,`partei_id` int(11)
,`parteifunktion` enum('mitglied','praesident','vizepraesident')
,`fraktionsfunktion` enum('mitglied','praesident','vizepraesident')
,`im_rat_seit` date
,`im_rat_bis` date
,`ratsunterbruch_von` date
,`ratsunterbruch_bis` date
,`beruf` varchar(150)
,`beruf_interessengruppe_id` int(11)
,`militaerischer_grad` int(11)
,`geschlecht` enum('M','F')
,`geburtstag` date
,`photo` varchar(255)
,`photo_dateiname` varchar(255)
,`photo_dateierweiterung` varchar(15)
,`photo_dateiname_voll` varchar(255)
,`photo_mime_type` varchar(100)
,`kleinbild` varchar(80)
,`sitzplatz` int(11)
,`email` varchar(100)
,`parlament_url` varchar(255)
,`homepage` varchar(150)
,`ALT_kommission` varchar(255)
,`notizen` text
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_parlamentarier_anhang`
--
DROP VIEW IF EXISTS `v_parlamentarier_anhang`;
CREATE TABLE IF NOT EXISTS `v_parlamentarier_anhang` (
`parlamentarier_id2` int(11)
,`id` int(11)
,`parlamentarier_id` int(11)
,`datei` varchar(255)
,`dateiname` varchar(255)
,`dateierweiterung` varchar(15)
,`dateiname_voll` varchar(255)
,`mime_type` varchar(100)
,`encoding` varchar(20)
,`beschreibung` varchar(150)
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_parlamentarier_authorisierungs_email`
--
DROP VIEW IF EXISTS `v_parlamentarier_authorisierungs_email`;
CREATE TABLE IF NOT EXISTS `v_parlamentarier_authorisierungs_email` (
`id` int(11)
,`parlamentarier_name` varchar(152)
,`email` varchar(100)
,`email_text_html` text
,`email_text_for_url` varchar(4096)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_partei`
--
DROP VIEW IF EXISTS `v_partei`;
CREATE TABLE IF NOT EXISTS `v_partei` (
`anzeige_name` varchar(123)
,`id` int(11)
,`abkuerzung` varchar(20)
,`name` varchar(100)
,`gruendung` date
,`position` enum('links','rechts','mitte','')
,`homepage` varchar(255)
,`notizen` text
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_user`
--
DROP VIEW IF EXISTS `v_user`;
CREATE TABLE IF NOT EXISTS `v_user` (
`id` int(11)
,`name` varchar(10)
,`password` varchar(255)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_user_permission`
--
DROP VIEW IF EXISTS `v_user_permission`;
CREATE TABLE IF NOT EXISTS `v_user_permission` (
`id` int(11)
,`user_id` int(11)
,`page_name` varchar(500)
,`permission_name` varchar(6)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_zutrittsberechtigung`
--
DROP VIEW IF EXISTS `v_zutrittsberechtigung`;
CREATE TABLE IF NOT EXISTS `v_zutrittsberechtigung` (
`anzeige_name` varchar(152)
,`name` varchar(151)
,`id` int(11)
,`parlamentarier_id` int(11)
,`nachname` varchar(100)
,`vorname` varchar(50)
,`funktion` varchar(150)
,`beruf` varchar(150)
,`beruf_interessengruppe_id` int(11)
,`geschlecht` enum('M','F')
,`von` date
,`bis` date
,`notizen` text
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`ALT_lobbyorganisation_id` int(11)
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_zutrittsberechtigung_authorisierungs_email`
--
DROP VIEW IF EXISTS `v_zutrittsberechtigung_authorisierungs_email`;
CREATE TABLE IF NOT EXISTS `v_zutrittsberechtigung_authorisierungs_email` (
`parlamentarier_name` varchar(151)
,`geschlecht` varchar(1)
,`zutrittsberechtigung_name` varchar(151)
,`funktion` varchar(150)
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_zutrittsberechtigung_mandate`
--
DROP VIEW IF EXISTS `v_zutrittsberechtigung_mandate`;
CREATE TABLE IF NOT EXISTS `v_zutrittsberechtigung_mandate` (
`parlamentarier_id` int(11)
,`organisation_name` varchar(454)
,`zutrittsberechtigung_name` varchar(152)
,`funktion` varchar(150)
,`id` int(11)
,`zutrittsberechtigung_id` int(11)
,`organisation_id` int(11)
,`art` enum('mitglied','geschaeftsfuehrend','vorstand','taetig','beirat')
,`verguetung` int(11)
,`beschreibung` varchar(150)
,`von` date
,`bis` date
,`notizen` text
,`autorisiert_datum` date
,`autorisiert_visa` varchar(10)
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_zutrittsberechtigung_mit_mandaten`
--
DROP VIEW IF EXISTS `v_zutrittsberechtigung_mit_mandaten`;
CREATE TABLE IF NOT EXISTS `v_zutrittsberechtigung_mit_mandaten` (
`organisation_name` varchar(454)
,`zutrittsberechtigung_name` varchar(152)
,`funktion` varchar(150)
,`parlamentarier_id` int(11)
,`id` int(11)
,`zutrittsberechtigung_id` int(11)
,`organisation_id` int(11)
,`art` enum('mitglied','geschaeftsfuehrend','vorstand','taetig','beirat')
,`verguetung` int(11)
,`beschreibung` varchar(150)
,`von` date
,`bis` date
,`notizen` text
,`autorisiert_datum` date
,`autorisiert_visa` varchar(10)
,`freigabe_visa` enum('otto','rebecca','thomas','bane','roland')
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `v_zutrittsberechtigung_mit_mandaten_indirekt`
--
DROP VIEW IF EXISTS `v_zutrittsberechtigung_mit_mandaten_indirekt`;
CREATE TABLE IF NOT EXISTS `v_zutrittsberechtigung_mit_mandaten_indirekt` (
`beziehung` varchar(8)
,`organisation_name` varchar(454)
,`zutrittsberechtigung_name` varchar(152)
,`funktion` varchar(150)
,`parlamentarier_id` int(11)
,`id` int(11)
,`zutrittsberechtigung_id` int(11)
,`organisation_id` int(11)
,`art` varchar(18)
,`verguetung` int(11)
,`beschreibung` varchar(150)
,`von` date
,`bis` date
,`notizen` text
,`autorisiert_datum` date
,`autorisiert_visa` varchar(10)
,`freigabe_visa` varchar(7)
,`freigabe_datum` timestamp
,`created_visa` varchar(10)
,`created_date` timestamp
,`updated_visa` varchar(10)
,`updated_date` timestamp
);
-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `zutrittsberechtigung`
--
-- Erzeugt am: 30. Dez 2013 um 15:22
--

DROP TABLE IF EXISTS `zutrittsberechtigung`;
CREATE TABLE IF NOT EXISTS `zutrittsberechtigung` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Schlüssel der Zugangsberechtigung',
  `parlamentarier_id` int(11) NOT NULL COMMENT 'Fremdschlüssel zu Parlamentarier',
  `nachname` varchar(100) NOT NULL COMMENT 'Nachname des berechtigten Persion',
  `vorname` varchar(50) NOT NULL COMMENT 'Vorname der berechtigten Person',
  `funktion` varchar(150) DEFAULT NULL COMMENT 'Angegebene Funktion bei der Zugangsberechtigung',
  `beruf` varchar(150) DEFAULT NULL COMMENT 'Beruf des Parlamentariers',
  `beruf_interessengruppe_id` int(11) DEFAULT NULL COMMENT 'Fremschlüssel zur Interessengruppe für den Beruf',
  `geschlecht` enum('M','F') DEFAULT 'M' COMMENT 'Geschlecht des Parlamentariers, M=Mann, F=Frau',
  `von` date DEFAULT NULL COMMENT 'Beginn der Zugangsberechtigung, leer (NULL) = unbekannt',
  `bis` date DEFAULT NULL COMMENT 'Ende der Zugangsberechtigung, leer (NULL) = aktuell gültig, nicht leer = historischer Eintrag',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `ALT_lobbyorganisation_id` int(11) DEFAULT NULL COMMENT 'Wird später entfernt. Fremschlüssel zur Lobbyorganisation',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgeändert von',
  `updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Abgeändert am',
  PRIMARY KEY (`id`),
  UNIQUE KEY `zutrittsberechtigung_nachname_vorname_unique` (`nachname`,`vorname`,`parlamentarier_id`,`bis`) COMMENT 'Fachlicher unique constraint',
  KEY `idx_parlam` (`parlamentarier_id`),
  KEY `idx_lobbygroup` (`beruf_interessengruppe_id`),
  KEY `idx_lobbyorg` (`ALT_lobbyorganisation_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Dauerhafter Badge für einen Gast ("Götti")' AUTO_INCREMENT=63 ;

--
-- RELATIONEN DER TABELLE `zutrittsberechtigung`:
--   `beruf_interessengruppe_id`
--       `interessengruppe` -> `id`
--   `ALT_lobbyorganisation_id`
--       `organisation` -> `id`
--   `parlamentarier_id`
--       `parlamentarier` -> `id`
--

--
-- Trigger `zutrittsberechtigung`
--
DROP TRIGGER IF EXISTS `trg_zutrittsberechtigung_log_del_after`;
DELIMITER //
CREATE TRIGGER `trg_zutrittsberechtigung_log_del_after` AFTER DELETE ON `zutrittsberechtigung`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  UPDATE `zutrittsberechtigung_log`
    SET `state` = 'OK'
    WHERE `id` = OLD.`id` AND `created_date` = OLD.`created_date` AND action = 'delete';
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_zutrittsberechtigung_log_del_before`;
DELIMITER //
CREATE TRIGGER `trg_zutrittsberechtigung_log_del_before` BEFORE DELETE ON `zutrittsberechtigung`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `zutrittsberechtigung_log`
    SELECT *, null, 'delete', null, NOW(), null FROM `zutrittsberechtigung` WHERE id = OLD.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_zutrittsberechtigung_log_ins`;
DELIMITER //
CREATE TRIGGER `trg_zutrittsberechtigung_log_ins` AFTER INSERT ON `zutrittsberechtigung`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `zutrittsberechtigung_log`
    SELECT *, null, 'insert', null, NOW(), null FROM `zutrittsberechtigung` WHERE id = NEW.id ;
end
//
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_zutrittsberechtigung_log_upd`;
DELIMITER //
CREATE TRIGGER `trg_zutrittsberechtigung_log_upd` AFTER UPDATE ON `zutrittsberechtigung`
 FOR EACH ROW thisTrigger: begin
  IF @disable_table_logging IS NOT NULL OR @disable_triggers IS NOT NULL THEN LEAVE thisTrigger; END IF;
  INSERT INTO `zutrittsberechtigung_log`
    SELECT *, null, 'update', null, NOW(), null FROM `zutrittsberechtigung` WHERE id = NEW.id ;
end
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `zutrittsberechtigung_log`
--
-- Erzeugt am: 30. Dez 2013 um 05:51
--

DROP TABLE IF EXISTS `zutrittsberechtigung_log`;
CREATE TABLE IF NOT EXISTS `zutrittsberechtigung_log` (
  `id` int(11) NOT NULL COMMENT 'Technischer Schlüssel der Live-Daten',
  `parlamentarier_id` int(11) NOT NULL COMMENT 'Fremdschlüssel zu Parlamentarier',
  `nachname` varchar(100) NOT NULL COMMENT 'Nachname des berechtigten Persion',
  `vorname` varchar(50) NOT NULL COMMENT 'Vorname der berechtigten Person',
  `funktion` varchar(150) DEFAULT NULL COMMENT 'Angegebene Funktion bei der Zugangsberechtigung',
  `beruf` varchar(150) DEFAULT NULL COMMENT 'Beruf des Parlamentariers',
  `beruf_interessengruppe_id` int(11) DEFAULT NULL COMMENT 'Fremschlüssel zur Interessengruppe für den Beruf',
  `geschlecht` enum('M','F') DEFAULT 'M' COMMENT 'Geschlecht des Parlamentariers, M=Mann, F=Frau',
  `von` date DEFAULT NULL COMMENT 'Beginn der Zugangsberechtigung, leer (NULL) = unbekannt',
  `bis` date DEFAULT NULL COMMENT 'Ende der Zugangsberechtigung, leer (NULL) = aktuell gültig, nicht leer = historischer Eintrag',
  `notizen` text COMMENT 'Interne Notizen zu diesem Eintrag. Einträge am besten mit Datum und Visa versehen.',
  `freigabe_visa` enum('otto','rebecca','thomas','bane','roland') DEFAULT NULL COMMENT 'Freigabe von (Freigabe = Daten sind fertig)',
  `freigabe_datum` timestamp NULL DEFAULT NULL COMMENT 'Freigabedatum (Freigabe = Daten sind fertig)',
  `ALT_lobbyorganisation_id` int(11) DEFAULT NULL COMMENT 'Wird später entfernt. Fremschlüssel zur Lobbyorganisation',
  `created_visa` varchar(10) NOT NULL COMMENT 'Datensatz erstellt von',
  `created_date` timestamp NULL DEFAULT NULL COMMENT 'Erstellt am',
  `updated_visa` varchar(10) DEFAULT NULL COMMENT 'Abgeändert von',
  `updated_date` timestamp NULL DEFAULT NULL COMMENT 'Abgeändert am',
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Technischer Log-Schlüssel',
  `action` enum('insert','update','delete','snapshot') NOT NULL COMMENT 'Aktionstyp',
  `state` varchar(20) DEFAULT NULL COMMENT 'Status der Aktion',
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Datum der Aktion',
  `snapshot_id` int(11) DEFAULT NULL COMMENT 'Fremdschlüssel zu einem Snapshot',
  PRIMARY KEY (`log_id`),
  KEY `idx_parlam` (`parlamentarier_id`),
  KEY `idx_lobbygroup` (`beruf_interessengruppe_id`),
  KEY `idx_lobbyorg` (`ALT_lobbyorganisation_id`),
  KEY `fk_zutrittsberechtigung_log_snapshot_id` (`snapshot_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Dauerhafter Badge für einen Gast ("Götti")' AUTO_INCREMENT=62 ;

--
-- RELATIONEN DER TABELLE `zutrittsberechtigung_log`:
--   `snapshot_id`
--       `snapshot` -> `id`
--

-- --------------------------------------------------------

--
-- Struktur des Views `v_branche`
--
DROP TABLE IF EXISTS `v_branche`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_branche` AS select `t`.`id` AS `id`,`t`.`name` AS `name`,`t`.`kommission_id` AS `kommission_id`,`t`.`beschreibung` AS `beschreibung`,`t`.`angaben` AS `angaben`,`t`.`notizen` AS `notizen`,`t`.`freigabe_visa` AS `freigabe_visa`,`t`.`freigabe_datum` AS `freigabe_datum`,`t`.`created_visa` AS `created_visa`,`t`.`created_date` AS `created_date`,`t`.`updated_visa` AS `updated_visa`,`t`.`updated_date` AS `updated_date` from `branche` `t`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_interessenbindung`
--
DROP TABLE IF EXISTS `v_interessenbindung`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_interessenbindung` AS select `t`.`id` AS `id`,`t`.`parlamentarier_id` AS `parlamentarier_id`,`t`.`organisation_id` AS `organisation_id`,`t`.`art` AS `art`,`t`.`deklarationstyp` AS `deklarationstyp`,`t`.`status` AS `status`,`t`.`verguetung` AS `verguetung`,`t`.`beschreibung` AS `beschreibung`,`t`.`von` AS `von`,`t`.`bis` AS `bis`,`t`.`notizen` AS `notizen`,`t`.`autorisiert_datum` AS `autorisiert_datum`,`t`.`autorisiert_visa` AS `autorisiert_visa`,`t`.`freigabe_visa` AS `freigabe_visa`,`t`.`freigabe_datum` AS `freigabe_datum`,`t`.`created_visa` AS `created_visa`,`t`.`created_date` AS `created_date`,`t`.`updated_visa` AS `updated_visa`,`t`.`updated_date` AS `updated_date` from `interessenbindung` `t`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_interessenbindung_authorisierungs_email`
--
DROP TABLE IF EXISTS `v_interessenbindung_authorisierungs_email`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_interessenbindung_authorisierungs_email` AS select `parlamentarier`.`name` AS `parlamentarier_name`,ifnull(`parlamentarier`.`geschlecht`,'') AS `geschlecht`,`organisation`.`anzeige_name` AS `organisation_name`,ifnull(`organisation`.`rechtsform`,'') AS `rechtsform`,ifnull(`organisation`.`ort`,'') AS `ort`,`interessenbindung`.`art` AS `art`,`interessenbindung`.`beschreibung` AS `beschreibung` from ((`v_interessenbindung` `interessenbindung` join `v_organisation` `organisation` on((`interessenbindung`.`organisation_id` = `organisation`.`id`))) join `v_parlamentarier` `parlamentarier` on((`interessenbindung`.`parlamentarier_id` = `parlamentarier`.`id`))) group by `parlamentarier`.`id` order by `organisation`.`anzeige_name`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_interessenbindung_liste`
--
DROP TABLE IF EXISTS `v_interessenbindung_liste`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_interessenbindung_liste` AS select `organisation`.`anzeige_name` AS `organisation_name`,`interessenbindung`.`id` AS `id`,`interessenbindung`.`parlamentarier_id` AS `parlamentarier_id`,`interessenbindung`.`organisation_id` AS `organisation_id`,`interessenbindung`.`art` AS `art`,`interessenbindung`.`deklarationstyp` AS `deklarationstyp`,`interessenbindung`.`status` AS `status`,`interessenbindung`.`verguetung` AS `verguetung`,`interessenbindung`.`beschreibung` AS `beschreibung`,`interessenbindung`.`von` AS `von`,`interessenbindung`.`bis` AS `bis`,`interessenbindung`.`notizen` AS `notizen`,`interessenbindung`.`autorisiert_datum` AS `autorisiert_datum`,`interessenbindung`.`autorisiert_visa` AS `autorisiert_visa`,`interessenbindung`.`freigabe_visa` AS `freigabe_visa`,`interessenbindung`.`freigabe_datum` AS `freigabe_datum`,`interessenbindung`.`created_visa` AS `created_visa`,`interessenbindung`.`created_date` AS `created_date`,`interessenbindung`.`updated_visa` AS `updated_visa`,`interessenbindung`.`updated_date` AS `updated_date` from (`v_interessenbindung` `interessenbindung` join `v_organisation` `organisation` on((`interessenbindung`.`organisation_id` = `organisation`.`id`))) order by `organisation`.`anzeige_name`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_interessenbindung_liste_indirekt`
--
DROP TABLE IF EXISTS `v_interessenbindung_liste_indirekt`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_interessenbindung_liste_indirekt` AS select 'direkt' AS `beziehung`,`interessenbindung_liste`.`organisation_name` AS `organisation_name`,`interessenbindung_liste`.`id` AS `id`,`interessenbindung_liste`.`parlamentarier_id` AS `parlamentarier_id`,`interessenbindung_liste`.`organisation_id` AS `organisation_id`,`interessenbindung_liste`.`art` AS `art`,`interessenbindung_liste`.`deklarationstyp` AS `deklarationstyp`,`interessenbindung_liste`.`status` AS `status`,`interessenbindung_liste`.`verguetung` AS `verguetung`,`interessenbindung_liste`.`beschreibung` AS `beschreibung`,`interessenbindung_liste`.`von` AS `von`,`interessenbindung_liste`.`bis` AS `bis`,`interessenbindung_liste`.`notizen` AS `notizen`,`interessenbindung_liste`.`autorisiert_datum` AS `autorisiert_datum`,`interessenbindung_liste`.`autorisiert_visa` AS `autorisiert_visa`,`interessenbindung_liste`.`freigabe_visa` AS `freigabe_visa`,`interessenbindung_liste`.`freigabe_datum` AS `freigabe_datum`,`interessenbindung_liste`.`created_visa` AS `created_visa`,`interessenbindung_liste`.`created_date` AS `created_date`,`interessenbindung_liste`.`updated_visa` AS `updated_visa`,`interessenbindung_liste`.`updated_date` AS `updated_date` from `v_interessenbindung_liste` `interessenbindung_liste` union select 'indirekt' AS `beziehung`,`organisation`.`anzeige_name` AS `organisation_name`,`interessenbindung`.`id` AS `id`,`interessenbindung`.`parlamentarier_id` AS `parlamentarier_id`,`interessenbindung`.`organisation_id` AS `organisation_id`,`interessenbindung`.`art` AS `art`,`interessenbindung`.`deklarationstyp` AS `deklarationstyp`,`interessenbindung`.`status` AS `status`,`interessenbindung`.`verguetung` AS `verguetung`,`interessenbindung`.`beschreibung` AS `beschreibung`,`interessenbindung`.`von` AS `von`,`interessenbindung`.`bis` AS `bis`,`interessenbindung`.`notizen` AS `notizen`,`interessenbindung`.`autorisiert_datum` AS `autorisiert_datum`,`interessenbindung`.`autorisiert_visa` AS `autorisiert_visa`,`interessenbindung`.`freigabe_visa` AS `freigabe_visa`,`interessenbindung`.`freigabe_datum` AS `freigabe_datum`,`interessenbindung`.`created_visa` AS `created_visa`,`interessenbindung`.`created_date` AS `created_date`,`interessenbindung`.`updated_visa` AS `updated_visa`,`interessenbindung`.`updated_date` AS `updated_date` from ((`v_interessenbindung` `interessenbindung` join `v_organisation_beziehung` `organisation_beziehung` on((`interessenbindung`.`organisation_id` = `organisation_beziehung`.`organisation_id`))) join `v_organisation` `organisation` on((`organisation_beziehung`.`ziel_organisation_id` = `organisation`.`id`))) where (`organisation_beziehung`.`art` = 'arbeitet fuer') order by `beziehung`,`organisation_name`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_interessengruppe`
--
DROP TABLE IF EXISTS `v_interessengruppe`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_interessengruppe` AS select `t`.`id` AS `id`,`t`.`name` AS `name`,`t`.`branche_id` AS `branche_id`,`t`.`beschreibung` AS `beschreibung`,`t`.`notizen` AS `notizen`,`t`.`freigabe_visa` AS `freigabe_visa`,`t`.`freigabe_datum` AS `freigabe_datum`,`t`.`created_visa` AS `created_visa`,`t`.`created_date` AS `created_date`,`t`.`updated_visa` AS `updated_visa`,`t`.`updated_date` AS `updated_date` from `interessengruppe` `t`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_in_kommission`
--
DROP TABLE IF EXISTS `v_in_kommission`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_in_kommission` AS select `t`.`id` AS `id`,`t`.`parlamentarier_id` AS `parlamentarier_id`,`t`.`kommission_id` AS `kommission_id`,`t`.`funktion` AS `funktion`,`t`.`von` AS `von`,`t`.`bis` AS `bis`,`t`.`notizen` AS `notizen`,`t`.`freigabe_visa` AS `freigabe_visa`,`t`.`freigabe_datum` AS `freigabe_datum`,`t`.`created_visa` AS `created_visa`,`t`.`created_date` AS `created_date`,`t`.`updated_visa` AS `updated_visa`,`t`.`updated_date` AS `updated_date` from `in_kommission` `t`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_in_kommission_liste`
--
DROP TABLE IF EXISTS `v_in_kommission_liste`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_in_kommission_liste` AS select `kommission`.`abkuerzung` AS `abkuerzung`,`kommission`.`name` AS `name`,`in_kommission`.`id` AS `id`,`in_kommission`.`parlamentarier_id` AS `parlamentarier_id`,`in_kommission`.`kommission_id` AS `kommission_id`,`in_kommission`.`funktion` AS `funktion`,`in_kommission`.`von` AS `von`,`in_kommission`.`bis` AS `bis`,`in_kommission`.`notizen` AS `notizen`,`in_kommission`.`freigabe_visa` AS `freigabe_visa`,`in_kommission`.`freigabe_datum` AS `freigabe_datum`,`in_kommission`.`created_visa` AS `created_visa`,`in_kommission`.`created_date` AS `created_date`,`in_kommission`.`updated_visa` AS `updated_visa`,`in_kommission`.`updated_date` AS `updated_date` from (`v_in_kommission` `in_kommission` join `v_kommission` `kommission` on((`in_kommission`.`kommission_id` = `kommission`.`id`))) order by `kommission`.`abkuerzung`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_in_kommission_parlamentarier`
--
DROP TABLE IF EXISTS `v_in_kommission_parlamentarier`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_in_kommission_parlamentarier` AS select `parlamentarier`.`anzeige_name` AS `parlamentarier_name`,`partei`.`abkuerzung` AS `abkuerzung`,`in_kommission`.`id` AS `id`,`in_kommission`.`parlamentarier_id` AS `parlamentarier_id`,`in_kommission`.`kommission_id` AS `kommission_id`,`in_kommission`.`funktion` AS `funktion`,`in_kommission`.`von` AS `von`,`in_kommission`.`bis` AS `bis`,`in_kommission`.`notizen` AS `notizen`,`in_kommission`.`freigabe_visa` AS `freigabe_visa`,`in_kommission`.`freigabe_datum` AS `freigabe_datum`,`in_kommission`.`created_visa` AS `created_visa`,`in_kommission`.`created_date` AS `created_date`,`in_kommission`.`updated_visa` AS `updated_visa`,`in_kommission`.`updated_date` AS `updated_date` from ((`v_in_kommission` `in_kommission` join `v_parlamentarier` `parlamentarier` on((`in_kommission`.`parlamentarier_id` = `parlamentarier`.`id`))) left join `v_partei` `partei` on((`parlamentarier`.`partei_id` = `partei`.`id`))) order by `parlamentarier`.`anzeige_name`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_kommission`
--
DROP TABLE IF EXISTS `v_kommission`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_kommission` AS select concat(`t`.`name`,' (',`t`.`abkuerzung`,')') AS `anzeige_name`,`t`.`id` AS `id`,`t`.`abkuerzung` AS `abkuerzung`,`t`.`name` AS `name`,`t`.`typ` AS `typ`,`t`.`beschreibung` AS `beschreibung`,`t`.`sachbereiche` AS `sachbereiche`,`t`.`mutter_kommission_id` AS `mutter_kommission_id`,`t`.`parlament_url` AS `parlament_url`,`t`.`notizen` AS `notizen`,`t`.`freigabe_visa` AS `freigabe_visa`,`t`.`freigabe_datum` AS `freigabe_datum`,`t`.`created_visa` AS `created_visa`,`t`.`created_date` AS `created_date`,`t`.`updated_visa` AS `updated_visa`,`t`.`updated_date` AS `updated_date` from `kommission` `t`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_last_updated_branche`
--
DROP TABLE IF EXISTS `v_last_updated_branche`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_last_updated_branche` AS (select 'branche' AS `table_name`,'Branche' AS `name`,(select count(0) from `branche`) AS `anzahl_eintraege`,`t`.`updated_visa` AS `last_visa`,`t`.`updated_date` AS `last_updated`,`t`.`id` AS `last_updated_id` from `branche` `t` order by `t`.`updated_date` desc limit 1);

-- --------------------------------------------------------

--
-- Struktur des Views `v_last_updated_interessenbindung`
--
DROP TABLE IF EXISTS `v_last_updated_interessenbindung`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_last_updated_interessenbindung` AS (select 'interessenbindung' AS `table_name`,'Interessenbindung' AS `name`,(select count(0) from `interessenbindung`) AS `anzahl_eintraege`,`t`.`updated_visa` AS `last_visa`,`t`.`updated_date` AS `last_updated`,`t`.`id` AS `last_updated_id` from `interessenbindung` `t` order by `t`.`updated_date` desc limit 1);

-- --------------------------------------------------------

--
-- Struktur des Views `v_last_updated_interessengruppe`
--
DROP TABLE IF EXISTS `v_last_updated_interessengruppe`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_last_updated_interessengruppe` AS (select 'interessengruppe' AS `table_name`,'Interessengruppe' AS `name`,(select count(0) from `interessengruppe`) AS `anzahl_eintraege`,`t`.`updated_visa` AS `last_visa`,`t`.`updated_date` AS `last_updated`,`t`.`id` AS `last_updated_id` from `interessengruppe` `t` order by `t`.`updated_date` desc limit 1);

-- --------------------------------------------------------

--
-- Struktur des Views `v_last_updated_in_kommission`
--
DROP TABLE IF EXISTS `v_last_updated_in_kommission`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_last_updated_in_kommission` AS (select 'in_kommission' AS `table_name`,'In Kommission' AS `name`,(select count(0) from `in_kommission`) AS `anzahl_eintraege`,`t`.`updated_visa` AS `last_visa`,`t`.`updated_date` AS `last_updated`,`t`.`id` AS `last_updated_id` from `in_kommission` `t` order by `t`.`updated_date` desc limit 1);

-- --------------------------------------------------------

--
-- Struktur des Views `v_last_updated_kommission`
--
DROP TABLE IF EXISTS `v_last_updated_kommission`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_last_updated_kommission` AS (select 'kommission' AS `table_name`,'Kommission' AS `name`,(select count(0) from `kommission`) AS `anzahl_eintraege`,`t`.`updated_visa` AS `last_visa`,`t`.`updated_date` AS `last_updated`,`t`.`id` AS `last_updated_id` from `kommission` `t` order by `t`.`updated_date` desc limit 1);

-- --------------------------------------------------------

--
-- Struktur des Views `v_last_updated_mandat`
--
DROP TABLE IF EXISTS `v_last_updated_mandat`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_last_updated_mandat` AS (select 'mandat' AS `table_name`,'Mandat' AS `name`,(select count(0) from `mandat`) AS `anzahl_eintraege`,`t`.`updated_visa` AS `last_visa`,`t`.`updated_date` AS `last_updated`,`t`.`id` AS `last_updated_id` from `mandat` `t` order by `t`.`updated_date` desc limit 1);

-- --------------------------------------------------------

--
-- Struktur des Views `v_last_updated_organisation`
--
DROP TABLE IF EXISTS `v_last_updated_organisation`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_last_updated_organisation` AS (select 'organisation' AS `table_name`,'Organisation' AS `name`,(select count(0) from `organisation`) AS `anzahl_eintraege`,`t`.`updated_visa` AS `last_visa`,`t`.`updated_date` AS `last_updated`,`t`.`id` AS `last_updated_id` from `organisation` `t` order by `t`.`updated_date` desc limit 1);

-- --------------------------------------------------------

--
-- Struktur des Views `v_last_updated_organisation_beziehung`
--
DROP TABLE IF EXISTS `v_last_updated_organisation_beziehung`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_last_updated_organisation_beziehung` AS (select 'organisation_beziehung' AS `table_name`,'Organisation Beziehung' AS `name`,(select count(0) from `organisation_beziehung`) AS `anzahl_eintraege`,`t`.`updated_visa` AS `last_visa`,`t`.`updated_date` AS `last_updated`,`t`.`id` AS `last_updated_id` from `organisation_beziehung` `t` order by `t`.`updated_date` desc limit 1);

-- --------------------------------------------------------

--
-- Struktur des Views `v_last_updated_parlamentarier`
--
DROP TABLE IF EXISTS `v_last_updated_parlamentarier`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_last_updated_parlamentarier` AS (select 'parlamentarier' AS `table_name`,'Parlamentarier' AS `name`,(select count(0) from `parlamentarier`) AS `anzahl_eintraege`,`t`.`updated_visa` AS `last_visa`,`t`.`updated_date` AS `last_updated`,`t`.`id` AS `last_updated_id` from `parlamentarier` `t` order by `t`.`updated_date` desc limit 1);

-- --------------------------------------------------------

--
-- Struktur des Views `v_last_updated_parlamentarier_anhang`
--
DROP TABLE IF EXISTS `v_last_updated_parlamentarier_anhang`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_last_updated_parlamentarier_anhang` AS (select 'parlamentarier_anhang' AS `table_name`,'Parlamentarieranhang' AS `name`,(select count(0) from `parlamentarier_anhang`) AS `anzahl_eintraege`,`t`.`updated_visa` AS `last_visa`,`t`.`updated_date` AS `last_updated`,`t`.`id` AS `last_updated_id` from `parlamentarier_anhang` `t` order by `t`.`updated_date` desc limit 1);

-- --------------------------------------------------------

--
-- Struktur des Views `v_last_updated_partei`
--
DROP TABLE IF EXISTS `v_last_updated_partei`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_last_updated_partei` AS (select 'partei' AS `table_name`,'Partei' AS `name`,(select count(0) from `partei`) AS `anzahl_eintraege`,`t`.`updated_visa` AS `last_visa`,`t`.`updated_date` AS `last_updated`,`t`.`id` AS `last_updated_id` from `partei` `t` order by `t`.`updated_date` desc limit 1);

-- --------------------------------------------------------

--
-- Struktur des Views `v_last_updated_tables`
--
DROP TABLE IF EXISTS `v_last_updated_tables`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_last_updated_tables` AS select `v_last_updated_tables_unordered`.`table_name` AS `table_name`,`v_last_updated_tables_unordered`.`name` AS `name`,`v_last_updated_tables_unordered`.`anzahl_eintraege` AS `anzahl_eintraege`,`v_last_updated_tables_unordered`.`last_visa` AS `last_visa`,`v_last_updated_tables_unordered`.`last_updated` AS `last_updated`,`v_last_updated_tables_unordered`.`last_updated_id` AS `last_updated_id` from `v_last_updated_tables_unordered` order by `v_last_updated_tables_unordered`.`last_updated` desc;

-- --------------------------------------------------------

--
-- Struktur des Views `v_last_updated_tables_unordered`
--
DROP TABLE IF EXISTS `v_last_updated_tables_unordered`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_last_updated_tables_unordered` AS select `v_last_updated_branche`.`table_name` AS `table_name`,`v_last_updated_branche`.`name` AS `name`,`v_last_updated_branche`.`anzahl_eintraege` AS `anzahl_eintraege`,`v_last_updated_branche`.`last_visa` AS `last_visa`,`v_last_updated_branche`.`last_updated` AS `last_updated`,`v_last_updated_branche`.`last_updated_id` AS `last_updated_id` from `v_last_updated_branche` union select `v_last_updated_interessenbindung`.`table_name` AS `table_name`,`v_last_updated_interessenbindung`.`name` AS `name`,`v_last_updated_interessenbindung`.`anzahl_eintraege` AS `anzahl_eintraege`,`v_last_updated_interessenbindung`.`last_visa` AS `last_visa`,`v_last_updated_interessenbindung`.`last_updated` AS `last_updated`,`v_last_updated_interessenbindung`.`last_updated_id` AS `last_updated_id` from `v_last_updated_interessenbindung` union select `v_last_updated_interessengruppe`.`table_name` AS `table_name`,`v_last_updated_interessengruppe`.`name` AS `name`,`v_last_updated_interessengruppe`.`anzahl_eintraege` AS `anzahl_eintraege`,`v_last_updated_interessengruppe`.`last_visa` AS `last_visa`,`v_last_updated_interessengruppe`.`last_updated` AS `last_updated`,`v_last_updated_interessengruppe`.`last_updated_id` AS `last_updated_id` from `v_last_updated_interessengruppe` union select `v_last_updated_in_kommission`.`table_name` AS `table_name`,`v_last_updated_in_kommission`.`name` AS `name`,`v_last_updated_in_kommission`.`anzahl_eintraege` AS `anzahl_eintraege`,`v_last_updated_in_kommission`.`last_visa` AS `last_visa`,`v_last_updated_in_kommission`.`last_updated` AS `last_updated`,`v_last_updated_in_kommission`.`last_updated_id` AS `last_updated_id` from `v_last_updated_in_kommission` union select `v_last_updated_kommission`.`table_name` AS `table_name`,`v_last_updated_kommission`.`name` AS `name`,`v_last_updated_kommission`.`anzahl_eintraege` AS `anzahl_eintraege`,`v_last_updated_kommission`.`last_visa` AS `last_visa`,`v_last_updated_kommission`.`last_updated` AS `last_updated`,`v_last_updated_kommission`.`last_updated_id` AS `last_updated_id` from `v_last_updated_kommission` union select `v_last_updated_mandat`.`table_name` AS `table_name`,`v_last_updated_mandat`.`name` AS `name`,`v_last_updated_mandat`.`anzahl_eintraege` AS `anzahl_eintraege`,`v_last_updated_mandat`.`last_visa` AS `last_visa`,`v_last_updated_mandat`.`last_updated` AS `last_updated`,`v_last_updated_mandat`.`last_updated_id` AS `last_updated_id` from `v_last_updated_mandat` union select `v_last_updated_organisation`.`table_name` AS `table_name`,`v_last_updated_organisation`.`name` AS `name`,`v_last_updated_organisation`.`anzahl_eintraege` AS `anzahl_eintraege`,`v_last_updated_organisation`.`last_visa` AS `last_visa`,`v_last_updated_organisation`.`last_updated` AS `last_updated`,`v_last_updated_organisation`.`last_updated_id` AS `last_updated_id` from `v_last_updated_organisation` union select `v_last_updated_organisation_beziehung`.`table_name` AS `table_name`,`v_last_updated_organisation_beziehung`.`name` AS `name`,`v_last_updated_organisation_beziehung`.`anzahl_eintraege` AS `anzahl_eintraege`,`v_last_updated_organisation_beziehung`.`last_visa` AS `last_visa`,`v_last_updated_organisation_beziehung`.`last_updated` AS `last_updated`,`v_last_updated_organisation_beziehung`.`last_updated_id` AS `last_updated_id` from `v_last_updated_organisation_beziehung` union select `v_last_updated_parlamentarier`.`table_name` AS `table_name`,`v_last_updated_parlamentarier`.`name` AS `name`,`v_last_updated_parlamentarier`.`anzahl_eintraege` AS `anzahl_eintraege`,`v_last_updated_parlamentarier`.`last_visa` AS `last_visa`,`v_last_updated_parlamentarier`.`last_updated` AS `last_updated`,`v_last_updated_parlamentarier`.`last_updated_id` AS `last_updated_id` from `v_last_updated_parlamentarier` union select `v_last_updated_parlamentarier_anhang`.`table_name` AS `table_name`,`v_last_updated_parlamentarier_anhang`.`name` AS `name`,`v_last_updated_parlamentarier_anhang`.`anzahl_eintraege` AS `anzahl_eintraege`,`v_last_updated_parlamentarier_anhang`.`last_visa` AS `last_visa`,`v_last_updated_parlamentarier_anhang`.`last_updated` AS `last_updated`,`v_last_updated_parlamentarier_anhang`.`last_updated_id` AS `last_updated_id` from `v_last_updated_parlamentarier_anhang` union select `v_last_updated_partei`.`table_name` AS `table_name`,`v_last_updated_partei`.`name` AS `name`,`v_last_updated_partei`.`anzahl_eintraege` AS `anzahl_eintraege`,`v_last_updated_partei`.`last_visa` AS `last_visa`,`v_last_updated_partei`.`last_updated` AS `last_updated`,`v_last_updated_partei`.`last_updated_id` AS `last_updated_id` from `v_last_updated_partei` union select `v_last_updated_zutrittsberechtigung`.`table_name` AS `table_name`,`v_last_updated_zutrittsberechtigung`.`name` AS `name`,`v_last_updated_zutrittsberechtigung`.`anzahl_eintraege` AS `anzahl_eintraege`,`v_last_updated_zutrittsberechtigung`.`last_visa` AS `last_visa`,`v_last_updated_zutrittsberechtigung`.`last_updated` AS `last_updated`,`v_last_updated_zutrittsberechtigung`.`last_updated_id` AS `last_updated_id` from `v_last_updated_zutrittsberechtigung`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_last_updated_zutrittsberechtigung`
--
DROP TABLE IF EXISTS `v_last_updated_zutrittsberechtigung`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_last_updated_zutrittsberechtigung` AS (select 'zutrittsberechtigung' AS `table_name`,'Zutrittsberechtigung' AS `name`,(select count(0) from `zutrittsberechtigung`) AS `anzahl_eintraege`,`t`.`updated_visa` AS `last_visa`,`t`.`updated_date` AS `last_updated`,`t`.`id` AS `last_updated_id` from `zutrittsberechtigung` `t` order by `t`.`updated_date` desc limit 1);

-- --------------------------------------------------------

--
-- Struktur des Views `v_mandat`
--
DROP TABLE IF EXISTS `v_mandat`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_mandat` AS select `t`.`id` AS `id`,`t`.`zutrittsberechtigung_id` AS `zutrittsberechtigung_id`,`t`.`organisation_id` AS `organisation_id`,`t`.`art` AS `art`,`t`.`verguetung` AS `verguetung`,`t`.`beschreibung` AS `beschreibung`,`t`.`von` AS `von`,`t`.`bis` AS `bis`,`t`.`notizen` AS `notizen`,`t`.`autorisiert_datum` AS `autorisiert_datum`,`t`.`autorisiert_visa` AS `autorisiert_visa`,`t`.`freigabe_visa` AS `freigabe_visa`,`t`.`freigabe_datum` AS `freigabe_datum`,`t`.`created_visa` AS `created_visa`,`t`.`created_date` AS `created_date`,`t`.`updated_visa` AS `updated_visa`,`t`.`updated_date` AS `updated_date` from `mandat` `t`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_mil_grad`
--
DROP TABLE IF EXISTS `v_mil_grad`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_mil_grad` AS select `t`.`id` AS `id`,`t`.`name` AS `name`,`t`.`abkuerzung` AS `abkuerzung`,`t`.`typ` AS `typ`,`t`.`ranghoehe` AS `ranghoehe`,`t`.`anzeigestufe` AS `anzeigestufe`,`t`.`created_visa` AS `created_visa`,`t`.`created_date` AS `created_date`,`t`.`updated_visa` AS `updated_visa`,`t`.`updated_date` AS `updated_date` from `mil_grad` `t` order by `t`.`ranghoehe`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_organisation`
--
DROP TABLE IF EXISTS `v_organisation`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_organisation` AS select concat_ws('; ',`t`.`name_de`,`t`.`name_fr`,`t`.`name_it`) AS `anzeige_name`,concat_ws('; ',`t`.`name_de`,`t`.`name_fr`,`t`.`name_it`) AS `name`,`t`.`id` AS `id`,`t`.`name_de` AS `name_de`,`t`.`name_fr` AS `name_fr`,`t`.`name_it` AS `name_it`,`t`.`ort` AS `ort`,`t`.`rechtsform` AS `rechtsform`,`t`.`typ` AS `typ`,`t`.`vernehmlassung` AS `vernehmlassung`,`t`.`interessengruppe_id` AS `interessengruppe_id`,`t`.`branche_id` AS `branche_id`,`t`.`url` AS `url`,`t`.`handelsregister_url` AS `handelsregister_url`,`t`.`beschreibung` AS `beschreibung`,`t`.`ALT_parlam_verbindung` AS `ALT_parlam_verbindung`,`t`.`notizen` AS `notizen`,`t`.`freigabe_visa` AS `freigabe_visa`,`t`.`freigabe_datum` AS `freigabe_datum`,`t`.`created_visa` AS `created_visa`,`t`.`created_date` AS `created_date`,`t`.`updated_visa` AS `updated_visa`,`t`.`updated_date` AS `updated_date` from `organisation` `t`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_organisation_beziehung`
--
DROP TABLE IF EXISTS `v_organisation_beziehung`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_organisation_beziehung` AS select `t`.`id` AS `id`,`t`.`organisation_id` AS `organisation_id`,`t`.`ziel_organisation_id` AS `ziel_organisation_id`,`t`.`art` AS `art`,`t`.`von` AS `von`,`t`.`bis` AS `bis`,`t`.`notizen` AS `notizen`,`t`.`freigabe_visa` AS `freigabe_visa`,`t`.`freigabe_datum` AS `freigabe_datum`,`t`.`created_visa` AS `created_visa`,`t`.`created_date` AS `created_date`,`t`.`updated_visa` AS `updated_visa`,`t`.`updated_date` AS `updated_date` from `organisation_beziehung` `t`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_organisation_beziehung_arbeitet_fuer`
--
DROP TABLE IF EXISTS `v_organisation_beziehung_arbeitet_fuer`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_organisation_beziehung_arbeitet_fuer` AS select `organisation`.`anzeige_name` AS `organisation_name`,`organisation_beziehung`.`id` AS `id`,`organisation_beziehung`.`organisation_id` AS `organisation_id`,`organisation_beziehung`.`ziel_organisation_id` AS `ziel_organisation_id`,`organisation_beziehung`.`art` AS `art`,`organisation_beziehung`.`von` AS `von`,`organisation_beziehung`.`bis` AS `bis`,`organisation_beziehung`.`notizen` AS `notizen`,`organisation_beziehung`.`freigabe_visa` AS `freigabe_visa`,`organisation_beziehung`.`freigabe_datum` AS `freigabe_datum`,`organisation_beziehung`.`created_visa` AS `created_visa`,`organisation_beziehung`.`created_date` AS `created_date`,`organisation_beziehung`.`updated_visa` AS `updated_visa`,`organisation_beziehung`.`updated_date` AS `updated_date` from (`v_organisation_beziehung` `organisation_beziehung` join `v_organisation` `organisation` on((`organisation_beziehung`.`ziel_organisation_id` = `organisation`.`id`))) where (`organisation_beziehung`.`art` = 'arbeitet fuer') order by `organisation`.`anzeige_name`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_organisation_beziehung_auftraggeber_fuer`
--
DROP TABLE IF EXISTS `v_organisation_beziehung_auftraggeber_fuer`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_organisation_beziehung_auftraggeber_fuer` AS select `organisation`.`anzeige_name` AS `organisation_name`,`organisation_beziehung`.`id` AS `id`,`organisation_beziehung`.`organisation_id` AS `organisation_id`,`organisation_beziehung`.`ziel_organisation_id` AS `ziel_organisation_id`,`organisation_beziehung`.`art` AS `art`,`organisation_beziehung`.`von` AS `von`,`organisation_beziehung`.`bis` AS `bis`,`organisation_beziehung`.`notizen` AS `notizen`,`organisation_beziehung`.`freigabe_visa` AS `freigabe_visa`,`organisation_beziehung`.`freigabe_datum` AS `freigabe_datum`,`organisation_beziehung`.`created_visa` AS `created_visa`,`organisation_beziehung`.`created_date` AS `created_date`,`organisation_beziehung`.`updated_visa` AS `updated_visa`,`organisation_beziehung`.`updated_date` AS `updated_date` from (`v_organisation_beziehung` `organisation_beziehung` join `v_organisation` `organisation` on((`organisation_beziehung`.`organisation_id` = `organisation`.`id`))) where (`organisation_beziehung`.`art` = 'arbeitet fuer') order by `organisation`.`anzeige_name`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_organisation_beziehung_mitglieder`
--
DROP TABLE IF EXISTS `v_organisation_beziehung_mitglieder`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_organisation_beziehung_mitglieder` AS select `organisation`.`anzeige_name` AS `organisation_name`,`organisation_beziehung`.`id` AS `id`,`organisation_beziehung`.`organisation_id` AS `organisation_id`,`organisation_beziehung`.`ziel_organisation_id` AS `ziel_organisation_id`,`organisation_beziehung`.`art` AS `art`,`organisation_beziehung`.`von` AS `von`,`organisation_beziehung`.`bis` AS `bis`,`organisation_beziehung`.`notizen` AS `notizen`,`organisation_beziehung`.`freigabe_visa` AS `freigabe_visa`,`organisation_beziehung`.`freigabe_datum` AS `freigabe_datum`,`organisation_beziehung`.`created_visa` AS `created_visa`,`organisation_beziehung`.`created_date` AS `created_date`,`organisation_beziehung`.`updated_visa` AS `updated_visa`,`organisation_beziehung`.`updated_date` AS `updated_date` from (`v_organisation_beziehung` `organisation_beziehung` join `v_organisation` `organisation` on((`organisation_beziehung`.`organisation_id` = `organisation`.`id`))) where (`organisation_beziehung`.`art` = 'mitglied von') order by `organisation`.`anzeige_name`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_organisation_beziehung_mitglied_von`
--
DROP TABLE IF EXISTS `v_organisation_beziehung_mitglied_von`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_organisation_beziehung_mitglied_von` AS select `organisation`.`anzeige_name` AS `organisation_name`,`organisation_beziehung`.`id` AS `id`,`organisation_beziehung`.`organisation_id` AS `organisation_id`,`organisation_beziehung`.`ziel_organisation_id` AS `ziel_organisation_id`,`organisation_beziehung`.`art` AS `art`,`organisation_beziehung`.`von` AS `von`,`organisation_beziehung`.`bis` AS `bis`,`organisation_beziehung`.`notizen` AS `notizen`,`organisation_beziehung`.`freigabe_visa` AS `freigabe_visa`,`organisation_beziehung`.`freigabe_datum` AS `freigabe_datum`,`organisation_beziehung`.`created_visa` AS `created_visa`,`organisation_beziehung`.`created_date` AS `created_date`,`organisation_beziehung`.`updated_visa` AS `updated_visa`,`organisation_beziehung`.`updated_date` AS `updated_date` from (`v_organisation_beziehung` `organisation_beziehung` join `v_organisation` `organisation` on((`organisation_beziehung`.`ziel_organisation_id` = `organisation`.`id`))) where (`organisation_beziehung`.`art` = 'mitglied von') order by `organisation`.`anzeige_name`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_organisation_parlamentarier`
--
DROP TABLE IF EXISTS `v_organisation_parlamentarier`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_organisation_parlamentarier` AS select `parlamentarier`.`anzeige_name` AS `parlamentarier_name`,`interessenbindung`.`id` AS `id`,`interessenbindung`.`parlamentarier_id` AS `parlamentarier_id`,`interessenbindung`.`organisation_id` AS `organisation_id`,`interessenbindung`.`art` AS `art`,`interessenbindung`.`deklarationstyp` AS `deklarationstyp`,`interessenbindung`.`status` AS `status`,`interessenbindung`.`verguetung` AS `verguetung`,`interessenbindung`.`beschreibung` AS `beschreibung`,`interessenbindung`.`von` AS `von`,`interessenbindung`.`bis` AS `bis`,`interessenbindung`.`notizen` AS `notizen`,`interessenbindung`.`autorisiert_datum` AS `autorisiert_datum`,`interessenbindung`.`autorisiert_visa` AS `autorisiert_visa`,`interessenbindung`.`freigabe_visa` AS `freigabe_visa`,`interessenbindung`.`freigabe_datum` AS `freigabe_datum`,`interessenbindung`.`created_visa` AS `created_visa`,`interessenbindung`.`created_date` AS `created_date`,`interessenbindung`.`updated_visa` AS `updated_visa`,`interessenbindung`.`updated_date` AS `updated_date` from (`v_interessenbindung` `interessenbindung` join `v_parlamentarier` `parlamentarier` on((`interessenbindung`.`parlamentarier_id` = `parlamentarier`.`id`))) order by `parlamentarier`.`anzeige_name`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_organisation_parlamentarier_indirekt`
--
DROP TABLE IF EXISTS `v_organisation_parlamentarier_indirekt`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_organisation_parlamentarier_indirekt` AS select 'direkt' AS `beziehung`,`organisation_parlamentarier`.`parlamentarier_name` AS `parlamentarier_name`,`organisation_parlamentarier`.`id` AS `id`,`organisation_parlamentarier`.`parlamentarier_id` AS `parlamentarier_id`,`organisation_parlamentarier`.`organisation_id` AS `organisation_id`,`organisation_parlamentarier`.`art` AS `art`,`organisation_parlamentarier`.`deklarationstyp` AS `deklarationstyp`,`organisation_parlamentarier`.`status` AS `status`,`organisation_parlamentarier`.`verguetung` AS `verguetung`,`organisation_parlamentarier`.`beschreibung` AS `beschreibung`,`organisation_parlamentarier`.`von` AS `von`,`organisation_parlamentarier`.`bis` AS `bis`,`organisation_parlamentarier`.`notizen` AS `notizen`,`organisation_parlamentarier`.`autorisiert_datum` AS `autorisiert_datum`,`organisation_parlamentarier`.`autorisiert_visa` AS `autorisiert_visa`,`organisation_parlamentarier`.`freigabe_visa` AS `freigabe_visa`,`organisation_parlamentarier`.`freigabe_datum` AS `freigabe_datum`,`organisation_parlamentarier`.`created_visa` AS `created_visa`,`organisation_parlamentarier`.`created_date` AS `created_date`,`organisation_parlamentarier`.`updated_visa` AS `updated_visa`,`organisation_parlamentarier`.`updated_date` AS `updated_date`,`organisation_parlamentarier`.`organisation_id` AS `connector_organisation_id` from `v_organisation_parlamentarier` `organisation_parlamentarier` union select 'indirekt' AS `beziehung`,`parlamentarier`.`anzeige_name` AS `parlamentarier_name`,`interessenbindung`.`id` AS `id`,`interessenbindung`.`parlamentarier_id` AS `parlamentarier_id`,`interessenbindung`.`organisation_id` AS `organisation_id`,`interessenbindung`.`art` AS `art`,`interessenbindung`.`deklarationstyp` AS `deklarationstyp`,`interessenbindung`.`status` AS `status`,`interessenbindung`.`verguetung` AS `verguetung`,`interessenbindung`.`beschreibung` AS `beschreibung`,`interessenbindung`.`von` AS `von`,`interessenbindung`.`bis` AS `bis`,`interessenbindung`.`notizen` AS `notizen`,`interessenbindung`.`autorisiert_datum` AS `autorisiert_datum`,`interessenbindung`.`autorisiert_visa` AS `autorisiert_visa`,`interessenbindung`.`freigabe_visa` AS `freigabe_visa`,`interessenbindung`.`freigabe_datum` AS `freigabe_datum`,`interessenbindung`.`created_visa` AS `created_visa`,`interessenbindung`.`created_date` AS `created_date`,`interessenbindung`.`updated_visa` AS `updated_visa`,`interessenbindung`.`updated_date` AS `updated_date`,`organisation_beziehung`.`ziel_organisation_id` AS `connector_organisation_id` from ((`v_organisation_beziehung` `organisation_beziehung` join `v_interessenbindung` `interessenbindung` on((`organisation_beziehung`.`organisation_id` = `interessenbindung`.`organisation_id`))) join `v_parlamentarier` `parlamentarier` on((`interessenbindung`.`parlamentarier_id` = `parlamentarier`.`id`))) where (`organisation_beziehung`.`art` = 'arbeitet fuer') order by `beziehung`,`parlamentarier_name`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_parlamentarier`
--
DROP TABLE IF EXISTS `v_parlamentarier`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_parlamentarier` AS select concat(`t`.`nachname`,', ',`t`.`vorname`) AS `anzeige_name`,concat(`t`.`vorname`,' ',`t`.`nachname`) AS `name`,`t`.`id` AS `id`,`t`.`nachname` AS `nachname`,`t`.`vorname` AS `vorname`,`t`.`zweiter_vorname` AS `zweiter_vorname`,`t`.`ratstyp` AS `ratstyp`,`t`.`kanton` AS `kanton`,`t`.`partei_id` AS `partei_id`,`t`.`parteifunktion` AS `parteifunktion`,`t`.`fraktionsfunktion` AS `fraktionsfunktion`,`t`.`im_rat_seit` AS `im_rat_seit`,`t`.`im_rat_bis` AS `im_rat_bis`,`t`.`ratsunterbruch_von` AS `ratsunterbruch_von`,`t`.`ratsunterbruch_bis` AS `ratsunterbruch_bis`,`t`.`beruf` AS `beruf`,`t`.`beruf_interessengruppe_id` AS `beruf_interessengruppe_id`,`t`.`militaerischer_grad` AS `militaerischer_grad`,`t`.`geschlecht` AS `geschlecht`,`t`.`geburtstag` AS `geburtstag`,`t`.`photo` AS `photo`,`t`.`photo_dateiname` AS `photo_dateiname`,`t`.`photo_dateierweiterung` AS `photo_dateierweiterung`,`t`.`photo_dateiname_voll` AS `photo_dateiname_voll`,`t`.`photo_mime_type` AS `photo_mime_type`,`t`.`kleinbild` AS `kleinbild`,`t`.`sitzplatz` AS `sitzplatz`,`t`.`email` AS `email`,`t`.`parlament_url` AS `parlament_url`,`t`.`homepage` AS `homepage`,`t`.`ALT_kommission` AS `ALT_kommission`,`t`.`notizen` AS `notizen`,`t`.`freigabe_visa` AS `freigabe_visa`,`t`.`freigabe_datum` AS `freigabe_datum`,`t`.`created_visa` AS `created_visa`,`t`.`created_date` AS `created_date`,`t`.`updated_visa` AS `updated_visa`,`t`.`updated_date` AS `updated_date` from `parlamentarier` `t`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_parlamentarier_anhang`
--
DROP TABLE IF EXISTS `v_parlamentarier_anhang`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_parlamentarier_anhang` AS select `t`.`parlamentarier_id` AS `parlamentarier_id2`,`t`.`id` AS `id`,`t`.`parlamentarier_id` AS `parlamentarier_id`,`t`.`datei` AS `datei`,`t`.`dateiname` AS `dateiname`,`t`.`dateierweiterung` AS `dateierweiterung`,`t`.`dateiname_voll` AS `dateiname_voll`,`t`.`mime_type` AS `mime_type`,`t`.`encoding` AS `encoding`,`t`.`beschreibung` AS `beschreibung`,`t`.`freigabe_visa` AS `freigabe_visa`,`t`.`freigabe_datum` AS `freigabe_datum`,`t`.`created_visa` AS `created_visa`,`t`.`created_date` AS `created_date`,`t`.`updated_visa` AS `updated_visa`,`t`.`updated_date` AS `updated_date` from `parlamentarier_anhang` `t`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_parlamentarier_authorisierungs_email`
--
DROP TABLE IF EXISTS `v_parlamentarier_authorisierungs_email`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_parlamentarier_authorisierungs_email` AS select `parlamentarier`.`id` AS `id`,`parlamentarier`.`anzeige_name` AS `parlamentarier_name`,`parlamentarier`.`email` AS `email`,concat((case `parlamentarier`.`geschlecht` when 'M' then concat('<p>Sehr geehrter Herr ',`parlamentarier`.`nachname`,'</p>') when 'F' then concat('<p>Sehr geehrte Frau ',`parlamentarier`.`nachname`,'</p>') else concat('<p>Sehr geehrte(r) Herr/Frau ',`parlamentarier`.`nachname`,'</p>') end),'<p>[Einleitung]</p>','<p>Ihre <b>Interessenbindungen</b>:</p>','<ul>',group_concat(distinct concat('<li>',`organisation`.`anzeige_name`,if((isnull(`organisation`.`rechtsform`) or (trim(`organisation`.`rechtsform`) = '')),'',concat(', ',`organisation`.`rechtsform`)),if((isnull(`organisation`.`ort`) or (trim(`organisation`.`ort`) = '')),'',concat(', ',`organisation`.`ort`)),', ',`interessenbindung`.`art`,', ',`interessenbindung`.`beschreibung`) order by `organisation`.`anzeige_name` ASC separator ' '),'</ul>','<p>Ihre <b>Gäste</b>:</p>','<ul>',group_concat(distinct concat('<li>',`zutrittsberechtigung`.`name`,', ',`zutrittsberechtigung`.`funktion`) order by `organisation`.`anzeige_name` ASC separator ' '),'</ul>','<p>Mit freundlichen Grüssen,<br></p>') AS `email_text_html`,`UTF8_URLENCODE`(concat((case `parlamentarier`.`geschlecht` when 'M' then concat('Sehr geehrter Herr ',`parlamentarier`.`nachname`,'\r\n') when 'F' then concat('Sehr geehrte Frau ',`parlamentarier`.`nachname`,'\r\n') else concat('Sehr geehrte(r) Herr/Frau ',`parlamentarier`.`nachname`,'\r\n') end),'\r\n[Ersetze Text mit HTML-Vorlage]\r\n','Ihre Interessenbindungen:\r\n',group_concat(distinct concat('* ',`organisation`.`anzeige_name`,if((isnull(`organisation`.`rechtsform`) or (trim(`organisation`.`rechtsform`) = '')),'',concat(', ',`organisation`.`rechtsform`)),if((isnull(`organisation`.`ort`) or (trim(`organisation`.`ort`) = '')),'',concat(', ',`organisation`.`ort`)),', ',`interessenbindung`.`art`,', ',`interessenbindung`.`beschreibung`,'\r\n') order by `organisation`.`anzeige_name` ASC separator ' '),'\r\nIhre Gäste:\r\n',group_concat(distinct concat('* ',`zutrittsberechtigung`.`name`,', ',`zutrittsberechtigung`.`funktion`,'\r\n') order by `organisation`.`anzeige_name` ASC separator ' '),'\r\nMit freundlichen Grüssen,\r\n')) AS `email_text_for_url` from (((`v_parlamentarier` `parlamentarier` left join `v_interessenbindung` `interessenbindung` on((`interessenbindung`.`parlamentarier_id` = `parlamentarier`.`id`))) left join `v_organisation` `organisation` on((`interessenbindung`.`organisation_id` = `organisation`.`id`))) left join `v_zutrittsberechtigung` `zutrittsberechtigung` on((`zutrittsberechtigung`.`parlamentarier_id` = `parlamentarier`.`id`))) group by `parlamentarier`.`id`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_partei`
--
DROP TABLE IF EXISTS `v_partei`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_partei` AS select concat(`t`.`name`,' (',`t`.`abkuerzung`,')') AS `anzeige_name`,`t`.`id` AS `id`,`t`.`abkuerzung` AS `abkuerzung`,`t`.`name` AS `name`,`t`.`gruendung` AS `gruendung`,`t`.`position` AS `position`,`t`.`homepage` AS `homepage`,`t`.`notizen` AS `notizen`,`t`.`freigabe_visa` AS `freigabe_visa`,`t`.`freigabe_datum` AS `freigabe_datum`,`t`.`created_visa` AS `created_visa`,`t`.`created_date` AS `created_date`,`t`.`updated_visa` AS `updated_visa`,`t`.`updated_date` AS `updated_date` from `partei` `t`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_user`
--
DROP TABLE IF EXISTS `v_user`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_user` AS select `t`.`id` AS `id`,`t`.`name` AS `name`,`t`.`password` AS `password` from `user` `t`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_user_permission`
--
DROP TABLE IF EXISTS `v_user_permission`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_user_permission` AS select `t`.`id` AS `id`,`t`.`user_id` AS `user_id`,`t`.`page_name` AS `page_name`,`t`.`permission_name` AS `permission_name` from `user_permission` `t`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_zutrittsberechtigung`
--
DROP TABLE IF EXISTS `v_zutrittsberechtigung`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_zutrittsberechtigung` AS select concat(`t`.`nachname`,', ',`t`.`vorname`) AS `anzeige_name`,concat(`t`.`vorname`,' ',`t`.`nachname`) AS `name`,`t`.`id` AS `id`,`t`.`parlamentarier_id` AS `parlamentarier_id`,`t`.`nachname` AS `nachname`,`t`.`vorname` AS `vorname`,`t`.`funktion` AS `funktion`,`t`.`beruf` AS `beruf`,`t`.`beruf_interessengruppe_id` AS `beruf_interessengruppe_id`,`t`.`geschlecht` AS `geschlecht`,`t`.`von` AS `von`,`t`.`bis` AS `bis`,`t`.`notizen` AS `notizen`,`t`.`freigabe_visa` AS `freigabe_visa`,`t`.`freigabe_datum` AS `freigabe_datum`,`t`.`ALT_lobbyorganisation_id` AS `ALT_lobbyorganisation_id`,`t`.`created_visa` AS `created_visa`,`t`.`created_date` AS `created_date`,`t`.`updated_visa` AS `updated_visa`,`t`.`updated_date` AS `updated_date` from `zutrittsberechtigung` `t`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_zutrittsberechtigung_authorisierungs_email`
--
DROP TABLE IF EXISTS `v_zutrittsberechtigung_authorisierungs_email`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_zutrittsberechtigung_authorisierungs_email` AS select `parlamentarier`.`name` AS `parlamentarier_name`,ifnull(`parlamentarier`.`geschlecht`,'') AS `geschlecht`,`zutrittsberechtigung`.`name` AS `zutrittsberechtigung_name`,`zutrittsberechtigung`.`funktion` AS `funktion` from (`v_zutrittsberechtigung` `zutrittsberechtigung` join `v_parlamentarier` `parlamentarier` on((`zutrittsberechtigung`.`parlamentarier_id` = `parlamentarier`.`id`))) group by `parlamentarier`.`id`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_zutrittsberechtigung_mandate`
--
DROP TABLE IF EXISTS `v_zutrittsberechtigung_mandate`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_zutrittsberechtigung_mandate` AS select `zutrittsberechtigung`.`parlamentarier_id` AS `parlamentarier_id`,`organisation`.`anzeige_name` AS `organisation_name`,`zutrittsberechtigung`.`anzeige_name` AS `zutrittsberechtigung_name`,`zutrittsberechtigung`.`funktion` AS `funktion`,`mandat`.`id` AS `id`,`mandat`.`zutrittsberechtigung_id` AS `zutrittsberechtigung_id`,`mandat`.`organisation_id` AS `organisation_id`,`mandat`.`art` AS `art`,`mandat`.`verguetung` AS `verguetung`,`mandat`.`beschreibung` AS `beschreibung`,`mandat`.`von` AS `von`,`mandat`.`bis` AS `bis`,`mandat`.`notizen` AS `notizen`,`mandat`.`autorisiert_datum` AS `autorisiert_datum`,`mandat`.`autorisiert_visa` AS `autorisiert_visa`,`mandat`.`freigabe_visa` AS `freigabe_visa`,`mandat`.`freigabe_datum` AS `freigabe_datum`,`mandat`.`created_visa` AS `created_visa`,`mandat`.`created_date` AS `created_date`,`mandat`.`updated_visa` AS `updated_visa`,`mandat`.`updated_date` AS `updated_date` from ((`v_zutrittsberechtigung` `zutrittsberechtigung` join `v_mandat` `mandat` on((`zutrittsberechtigung`.`id` = `mandat`.`zutrittsberechtigung_id`))) join `v_organisation` `organisation` on((`mandat`.`organisation_id` = `organisation`.`id`))) order by `organisation`.`anzeige_name`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_zutrittsberechtigung_mit_mandaten`
--
DROP TABLE IF EXISTS `v_zutrittsberechtigung_mit_mandaten`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_zutrittsberechtigung_mit_mandaten` AS select `organisation`.`anzeige_name` AS `organisation_name`,`zutrittsberechtigung`.`anzeige_name` AS `zutrittsberechtigung_name`,`zutrittsberechtigung`.`funktion` AS `funktion`,`zutrittsberechtigung`.`parlamentarier_id` AS `parlamentarier_id`,`mandat`.`id` AS `id`,`mandat`.`zutrittsberechtigung_id` AS `zutrittsberechtigung_id`,`mandat`.`organisation_id` AS `organisation_id`,`mandat`.`art` AS `art`,`mandat`.`verguetung` AS `verguetung`,`mandat`.`beschreibung` AS `beschreibung`,`mandat`.`von` AS `von`,`mandat`.`bis` AS `bis`,`mandat`.`notizen` AS `notizen`,`mandat`.`autorisiert_datum` AS `autorisiert_datum`,`mandat`.`autorisiert_visa` AS `autorisiert_visa`,`mandat`.`freigabe_visa` AS `freigabe_visa`,`mandat`.`freigabe_datum` AS `freigabe_datum`,`mandat`.`created_visa` AS `created_visa`,`mandat`.`created_date` AS `created_date`,`mandat`.`updated_visa` AS `updated_visa`,`mandat`.`updated_date` AS `updated_date` from ((`v_zutrittsberechtigung` `zutrittsberechtigung` left join `v_mandat` `mandat` on((`zutrittsberechtigung`.`id` = `mandat`.`zutrittsberechtigung_id`))) left join `v_organisation` `organisation` on((`mandat`.`organisation_id` = `organisation`.`id`))) order by `zutrittsberechtigung`.`anzeige_name`;

-- --------------------------------------------------------

--
-- Struktur des Views `v_zutrittsberechtigung_mit_mandaten_indirekt`
--
DROP TABLE IF EXISTS `v_zutrittsberechtigung_mit_mandaten_indirekt`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_zutrittsberechtigung_mit_mandaten_indirekt` AS select 'direkt' AS `beziehung`,`zutrittsberechtigung`.`organisation_name` AS `organisation_name`,`zutrittsberechtigung`.`zutrittsberechtigung_name` AS `zutrittsberechtigung_name`,`zutrittsberechtigung`.`funktion` AS `funktion`,`zutrittsberechtigung`.`parlamentarier_id` AS `parlamentarier_id`,`zutrittsberechtigung`.`id` AS `id`,`zutrittsberechtigung`.`zutrittsberechtigung_id` AS `zutrittsberechtigung_id`,`zutrittsberechtigung`.`organisation_id` AS `organisation_id`,`zutrittsberechtigung`.`art` AS `art`,`zutrittsberechtigung`.`verguetung` AS `verguetung`,`zutrittsberechtigung`.`beschreibung` AS `beschreibung`,`zutrittsberechtigung`.`von` AS `von`,`zutrittsberechtigung`.`bis` AS `bis`,`zutrittsberechtigung`.`notizen` AS `notizen`,`zutrittsberechtigung`.`autorisiert_datum` AS `autorisiert_datum`,`zutrittsberechtigung`.`autorisiert_visa` AS `autorisiert_visa`,`zutrittsberechtigung`.`freigabe_visa` AS `freigabe_visa`,`zutrittsberechtigung`.`freigabe_datum` AS `freigabe_datum`,`zutrittsberechtigung`.`created_visa` AS `created_visa`,`zutrittsberechtigung`.`created_date` AS `created_date`,`zutrittsberechtigung`.`updated_visa` AS `updated_visa`,`zutrittsberechtigung`.`updated_date` AS `updated_date` from `v_zutrittsberechtigung_mit_mandaten` `zutrittsberechtigung` union select 'indirekt' AS `beziehung`,`organisation`.`name` AS `organisation_name`,`zutrittsberechtigung`.`anzeige_name` AS `zutrittsberechtigung_name`,`zutrittsberechtigung`.`funktion` AS `funktion`,`zutrittsberechtigung`.`parlamentarier_id` AS `parlamentarier_id`,`mandat`.`id` AS `id`,`mandat`.`zutrittsberechtigung_id` AS `zutrittsberechtigung_id`,`mandat`.`organisation_id` AS `organisation_id`,`mandat`.`art` AS `art`,`mandat`.`verguetung` AS `verguetung`,`mandat`.`beschreibung` AS `beschreibung`,`mandat`.`von` AS `von`,`mandat`.`bis` AS `bis`,`mandat`.`notizen` AS `notizen`,`mandat`.`autorisiert_datum` AS `autorisiert_datum`,`mandat`.`autorisiert_visa` AS `autorisiert_visa`,`mandat`.`freigabe_visa` AS `freigabe_visa`,`mandat`.`freigabe_datum` AS `freigabe_datum`,`mandat`.`created_visa` AS `created_visa`,`mandat`.`created_date` AS `created_date`,`mandat`.`updated_visa` AS `updated_visa`,`mandat`.`updated_date` AS `updated_date` from (((`v_zutrittsberechtigung` `zutrittsberechtigung` join `v_mandat` `mandat` on((`zutrittsberechtigung`.`id` = `mandat`.`zutrittsberechtigung_id`))) join `v_organisation_beziehung` `organisation_beziehung` on((`mandat`.`organisation_id` = `organisation_beziehung`.`organisation_id`))) join `v_organisation` `organisation` on((`organisation_beziehung`.`ziel_organisation_id` = `organisation`.`id`))) where (`organisation_beziehung`.`art` = 'arbeitet fuer') order by `beziehung`,`organisation_name`;

--
-- Constraints der exportierten Tabellen
--

--
-- Constraints der Tabelle `branche`
--
ALTER TABLE `branche`
  ADD CONSTRAINT `fk_kommission_id` FOREIGN KEY (`kommission_id`) REFERENCES `kommission` (`id`);

--
-- Constraints der Tabelle `branche_log`
--
ALTER TABLE `branche_log`
  ADD CONSTRAINT `fk_branche_log_snapshot_id` FOREIGN KEY (`snapshot_id`) REFERENCES `snapshot` (`id`);

--
-- Constraints der Tabelle `interessenbindung`
--
ALTER TABLE `interessenbindung`
  ADD CONSTRAINT `fk_ib_org` FOREIGN KEY (`organisation_id`) REFERENCES `organisation` (`id`),
  ADD CONSTRAINT `fk_ib_parlam` FOREIGN KEY (`parlamentarier_id`) REFERENCES `parlamentarier` (`id`);

--
-- Constraints der Tabelle `interessenbindung_log`
--
ALTER TABLE `interessenbindung_log`
  ADD CONSTRAINT `fk_interessenbindung_log_snapshot_id` FOREIGN KEY (`snapshot_id`) REFERENCES `snapshot` (`id`);

--
-- Constraints der Tabelle `interessengruppe`
--
ALTER TABLE `interessengruppe`
  ADD CONSTRAINT `fk_lg_lt` FOREIGN KEY (`branche_id`) REFERENCES `branche` (`id`);

--
-- Constraints der Tabelle `interessengruppe_log`
--
ALTER TABLE `interessengruppe_log`
  ADD CONSTRAINT `fk_interessengruppe_log_snapshot_id` FOREIGN KEY (`snapshot_id`) REFERENCES `snapshot` (`id`);

--
-- Constraints der Tabelle `in_kommission`
--
ALTER TABLE `in_kommission`
  ADD CONSTRAINT `fk_in_kommission_id` FOREIGN KEY (`kommission_id`) REFERENCES `kommission` (`id`),
  ADD CONSTRAINT `fk_in_parlamentarier_id` FOREIGN KEY (`parlamentarier_id`) REFERENCES `parlamentarier` (`id`);

--
-- Constraints der Tabelle `in_kommission_log`
--
ALTER TABLE `in_kommission_log`
  ADD CONSTRAINT `fk_in_kommission_log_snapshot_id` FOREIGN KEY (`snapshot_id`) REFERENCES `snapshot` (`id`);

--
-- Constraints der Tabelle `kommission`
--
ALTER TABLE `kommission`
  ADD CONSTRAINT `fk_parent_kommission_id` FOREIGN KEY (`mutter_kommission_id`) REFERENCES `kommission` (`id`);

--
-- Constraints der Tabelle `kommission_log`
--
ALTER TABLE `kommission_log`
  ADD CONSTRAINT `fk_kommission_log_snapshot_id` FOREIGN KEY (`snapshot_id`) REFERENCES `snapshot` (`id`);

--
-- Constraints der Tabelle `mandat`
--
ALTER TABLE `mandat`
  ADD CONSTRAINT `fk_organisations_id` FOREIGN KEY (`organisation_id`) REFERENCES `organisation` (`id`),
  ADD CONSTRAINT `fk_zugangsberechtigung_id` FOREIGN KEY (`zutrittsberechtigung_id`) REFERENCES `zutrittsberechtigung` (`id`);

--
-- Constraints der Tabelle `mandat_log`
--
ALTER TABLE `mandat_log`
  ADD CONSTRAINT `fk_mandat_log_snapshot_id` FOREIGN KEY (`snapshot_id`) REFERENCES `snapshot` (`id`);

--
-- Constraints der Tabelle `mil_grad_log`
--
ALTER TABLE `mil_grad_log`
  ADD CONSTRAINT `fk_mil_grad_log_snapshot_id` FOREIGN KEY (`snapshot_id`) REFERENCES `snapshot` (`id`);

--
-- Constraints der Tabelle `organisation`
--
ALTER TABLE `organisation`
  ADD CONSTRAINT `fk_lo_lg` FOREIGN KEY (`interessengruppe_id`) REFERENCES `interessengruppe` (`id`),
  ADD CONSTRAINT `fk_lo_lt` FOREIGN KEY (`branche_id`) REFERENCES `branche` (`id`);

--
-- Constraints der Tabelle `organisation_beziehung`
--
ALTER TABLE `organisation_beziehung`
  ADD CONSTRAINT `fk_quell_organisation_id` FOREIGN KEY (`organisation_id`) REFERENCES `organisation` (`id`),
  ADD CONSTRAINT `fk_ziel_organisation_id` FOREIGN KEY (`ziel_organisation_id`) REFERENCES `organisation` (`id`);

--
-- Constraints der Tabelle `organisation_beziehung_log`
--
ALTER TABLE `organisation_beziehung_log`
  ADD CONSTRAINT `fk_organisation_beziehung_log_snapshot_id` FOREIGN KEY (`snapshot_id`) REFERENCES `snapshot` (`id`);

--
-- Constraints der Tabelle `organisation_log`
--
ALTER TABLE `organisation_log`
  ADD CONSTRAINT `fk_organisation_log_snapshot_id` FOREIGN KEY (`snapshot_id`) REFERENCES `snapshot` (`id`);

--
-- Constraints der Tabelle `parlamentarier`
--
ALTER TABLE `parlamentarier`
  ADD CONSTRAINT `fk_beruf_interessengruppe_id` FOREIGN KEY (`beruf_interessengruppe_id`) REFERENCES `interessengruppe` (`id`),
  ADD CONSTRAINT `fk_mil_grad` FOREIGN KEY (`militaerischer_grad`) REFERENCES `mil_grad` (`id`),
  ADD CONSTRAINT `fk_partei_id` FOREIGN KEY (`partei_id`) REFERENCES `partei` (`id`);

--
-- Constraints der Tabelle `parlamentarier_anhang`
--
ALTER TABLE `parlamentarier_anhang`
  ADD CONSTRAINT `fk_parlam_anhang` FOREIGN KEY (`parlamentarier_id`) REFERENCES `parlamentarier` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `parlamentarier_anhang_log`
--
ALTER TABLE `parlamentarier_anhang_log`
  ADD CONSTRAINT `fk_parlamentarier_anhang_log_snapshot_id` FOREIGN KEY (`snapshot_id`) REFERENCES `snapshot` (`id`);

--
-- Constraints der Tabelle `parlamentarier_log`
--
ALTER TABLE `parlamentarier_log`
  ADD CONSTRAINT `fk_parlamentarier_log_snapshot_id` FOREIGN KEY (`snapshot_id`) REFERENCES `snapshot` (`id`);

--
-- Constraints der Tabelle `partei_log`
--
ALTER TABLE `partei_log`
  ADD CONSTRAINT `fk_partei_log_snapshot_id` FOREIGN KEY (`snapshot_id`) REFERENCES `snapshot` (`id`);

--
-- Constraints der Tabelle `zutrittsberechtigung`
--
ALTER TABLE `zutrittsberechtigung`
  ADD CONSTRAINT `fk_zb_lg` FOREIGN KEY (`beruf_interessengruppe_id`) REFERENCES `interessengruppe` (`id`),
  ADD CONSTRAINT `fk_zb_lo` FOREIGN KEY (`ALT_lobbyorganisation_id`) REFERENCES `organisation` (`id`),
  ADD CONSTRAINT `fk_zb_parlam` FOREIGN KEY (`parlamentarier_id`) REFERENCES `parlamentarier` (`id`);

--
-- Constraints der Tabelle `zutrittsberechtigung_log`
--
ALTER TABLE `zutrittsberechtigung_log`
  ADD CONSTRAINT `fk_zutrittsberechtigung_log_snapshot_id` FOREIGN KEY (`snapshot_id`) REFERENCES `snapshot` (`id`);
SET FOREIGN_KEY_CHECKS=1;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;