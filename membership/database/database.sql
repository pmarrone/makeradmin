-- MySQL Script generated by MySQL Workbench
-- Thu 27 Oct 2016 08:15:54 AM CEST
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema internal
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Table `membership_members`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `membership_members` ;

CREATE TABLE IF NOT EXISTS `membership_members` (
  `member_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(255) NOT NULL,
  `password` VARCHAR(255) NULL DEFAULT NULL,
  `reset_token` CHAR(34) NULL DEFAULT NULL,
  `reset_expire` INT(11) NULL DEFAULT NULL,
  `firstname` VARCHAR(255) NULL DEFAULT NULL,
  `lastname` VARCHAR(255) NULL DEFAULT NULL,
  `civicregno` CHAR(13) NULL DEFAULT NULL,
  `company` VARCHAR(255) NULL DEFAULT NULL,
  `orgno` VARCHAR(12) NULL DEFAULT NULL,
  `address_street` VARCHAR(255) NULL DEFAULT NULL,
  `address_extra` VARCHAR(255) NULL DEFAULT NULL,
  `address_zipcode` INT(11) NULL DEFAULT NULL,
  `address_city` VARCHAR(64) NULL DEFAULT NULL,
  `address_state_region` VARCHAR(255) NULL DEFAULT NULL,
  `address_country` CHAR(2) NULL DEFAULT 'se',
  `phone` VARCHAR(64) NULL DEFAULT NULL,
  `created_at` DATETIME NULL,
  `updated_at` DATETIME NULL,
  `deleted_at` DATETIME NULL,
  PRIMARY KEY (`member_id`),
  INDEX `index_email` (`email` ASC),
  INDEX `index_deleted` (`deleted_at` ASC),
  INDEX `index_resettoken` (`reset_token` ASC),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC));


-- -----------------------------------------------------
-- Table `membership_logins`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `membership_logins` ;

CREATE TABLE IF NOT EXISTS `membership_logins` (
  `login_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `member_id` INT UNSIGNED NULL DEFAULT NULL,
  `ip_address` VARCHAR(64) NOT NULL,
  `timestamp` DATETIME NOT NULL,
  `valid` INT(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`login_id`),
  INDEX `user_id` (`member_id` ASC),
  CONSTRAINT `fk_logins_1`
    FOREIGN KEY (`member_id`)
    REFERENCES `membership_members` (`member_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `membership_groups`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `membership_groups` ;

CREATE TABLE IF NOT EXISTS `membership_groups` (
  `group_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `parent` INT UNSIGNED NULL,
  `left` INT NULL,
  `right` INT NULL,
  `title` VARCHAR(120) NULL,
  `description` TEXT NULL,
  `created_at` DATETIME NULL,
  `updated_at` DATETIME NULL,
  `deleted_at` DATETIME NULL,
  PRIMARY KEY (`group_id`),
  INDEX `fk_groups_1_idx` (`parent` ASC),
  INDEX `index_deleted` (`deleted_at` ASC),
  INDEX `index_left` (`left` ASC),
  INDEX `index_right` (`right` ASC),
  CONSTRAINT `fk_groups_1`
    FOREIGN KEY (`parent`)
    REFERENCES `membership_groups` (`group_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `membership_roles`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `membership_roles` ;

CREATE TABLE IF NOT EXISTS `membership_roles` (
  `role_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `group_id` INT UNSIGNED NOT NULL,
  `title` VARCHAR(128) NOT NULL,
  `description` TEXT NULL,
  `created_at` DATETIME NULL,
  `updated_at` DATETIME NULL,
  `deleted_at` DATETIME NULL,
  PRIMARY KEY (`role_id`),
  INDEX `index_deleted` (`deleted_at` ASC),
  INDEX `fk_roles_1_idx` (`group_id` ASC),
  CONSTRAINT `fk_roles_1`
    FOREIGN KEY (`group_id`)
    REFERENCES `membership_groups` (`group_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `membership_members_roles`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `membership_members_roles` ;

CREATE TABLE IF NOT EXISTS `membership_members_roles` (
  `member_id` INT UNSIGNED NOT NULL,
  `role_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`member_id`, `role_id`),
  INDEX `index_member` (`member_id` ASC),
  INDEX `index_role` (`role_id` ASC),
  CONSTRAINT `fk_members_roles_1`
    FOREIGN KEY (`member_id`)
    REFERENCES `membership_members` (`member_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_members_roles_2`
    FOREIGN KEY (`role_id`)
    REFERENCES `membership_roles` (`role_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `membership_permissions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `membership_permissions` ;

CREATE TABLE IF NOT EXISTS `membership_permissions` (
  `permission_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `role_id` INT UNSIGNED NOT NULL,
  `permission` VARCHAR(100) NULL,
  `group_id` INT UNSIGNED NOT NULL,
  `created_at` DATETIME NULL,
  `updated_at` DATETIME NULL,
  `deleted_at` DATETIME NULL,
  PRIMARY KEY (`permission_id`),
  INDEX `index_deleted` (`deleted_at` ASC),
  INDEX `fk_permissions_2_idx` (`group_id` ASC),
  INDEX `fk_permissions_1_idx` (`role_id` ASC),
  CONSTRAINT `fk_permissions_1`
    FOREIGN KEY (`role_id`)
    REFERENCES `membership_roles` (`role_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_permissions_2`
    FOREIGN KEY (`group_id`)
    REFERENCES `membership_groups` (`group_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `membership_members_groups`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `membership_members_groups` ;

CREATE TABLE IF NOT EXISTS `membership_members_groups` (
  `member_id` INT UNSIGNED NOT NULL,
  `group_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`member_id`, `group_id`),
  INDEX `index_member` (`member_id` ASC),
  INDEX `index_group` (`group_id` ASC),
  CONSTRAINT `fk_members_groups_1`
    FOREIGN KEY (`member_id`)
    REFERENCES `membership_members` (`member_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_members_groups_2`
    FOREIGN KEY (`group_id`)
    REFERENCES `membership_groups` (`group_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `rfid`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `rfid` ;

CREATE TABLE IF NOT EXISTS `rfid` (
  `rfid_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `member_id` INT UNSIGNED NOT NULL,
    `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
    `description` text COLLATE utf8_unicode_ci,
    `tagid` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
    `status` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
    `startdate` datetime DEFAULT NULL,
    `enddate` datetime DEFAULT NULL,
    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` datetime DEFAULT NULL,
    PRIMARY KEY (`rfid_id`),
    KEY `rfid_tagid_index` (`tagid`)
    CONSTRAINT `fk_members_rfid_1`
      FOREIGN KEY (`member_id`)
      REFERENCES `membership_members` (`member_id`)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION)
) ENGINE=InnoDB;

ALTER TABLE `rfid` CHANGE `rfid_id` `id` int(10) unsigned NOT NULL AUTO_INCREMENT;
ALTER TABLE `rfid` CHANGE `updated_at` `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;


-- -----------------------------------------------------
-- Modes
-- -----------------------------------------------------
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


-- -----------------------------------------------------
-- Data for table `membership_groups`
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO `membership_groups` (`group_id`, `parent`, `left`, `right`, `title`, `description`, `created_at`, `updated_at`, `deleted_at`) VALUES (1, NULL, NULL, NULL, 'Makers of Sweden', 'Riksorganisationen Makers of Sweden', NULL, NULL, NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `membership_roles`
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO `membership_roles` (`role_id`, `group_id`, `title`, `description`, `created_at`, `updated_at`, `deleted_at`) VALUES (1, 1, 'Admin', 'Administratör med tillgång till hela databasen', NULL, NULL, NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `membership_permissions`
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO `membership_permissions` (`permission_id`, `role_id`, `permission`, `group_id`, `created_at`, `updated_at`, `deleted_at`) VALUES (1, 1, 'create member', 1, NULL, NULL, NULL);
INSERT INTO `membership_permissions` (`permission_id`, `role_id`, `permission`, `group_id`, `created_at`, `updated_at`, `deleted_at`) VALUES (2, 1, 'delete member', 1, NULL, NULL, NULL);
INSERT INTO `membership_permissions` (`permission_id`, `role_id`, `permission`, `group_id`, `created_at`, `updated_at`, `deleted_at`) VALUES (3, 1, 'edit member', 1, NULL, NULL, NULL);
INSERT INTO `membership_permissions` (`permission_id`, `role_id`, `permission`, `group_id`, `created_at`, `updated_at`, `deleted_at`) VALUES (4, 1, 'view member', 1, NULL, NULL, NULL);

COMMIT;

