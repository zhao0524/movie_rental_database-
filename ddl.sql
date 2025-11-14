-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema camera/video equipment rental dbms
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema camera/video equipment rental dbms
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `camera/video equipment rental dbms` DEFAULT CHARACTER SET utf8mb3 ;
USE `camera/video equipment rental dbms` ;

-- -----------------------------------------------------
-- Table `camera/video equipment rental dbms`.`customer`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `camera/video equipment rental dbms`.`customer` (
  `customer_id` INT NOT NULL,
  `Full_Name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(20) NULL DEFAULT NULL,
  `status` ENUM('Acyive', 'suspended') NOT NULL,
  PRIMARY KEY (`customer_id`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE,
  UNIQUE INDEX `phone_UNIQUE` (`phone` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `camera/video equipment rental dbms`.`address`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `camera/video equipment rental dbms`.`address` (
  `address_id` INT NOT NULL,
  `customer_id` INT NOT NULL,
  `street` VARCHAR(45) NOT NULL,
  `city` VARCHAR(100) NOT NULL,
  `province` VARCHAR(50) NULL DEFAULT NULL,
  `postal_code` VARCHAR(15) NULL DEFAULT NULL,
  `country` VARCHAR(50) NULL DEFAULT NULL,
  PRIMARY KEY (`address_id`),
  INDEX `fk_address_customer` (`customer_id` ASC) VISIBLE,
  CONSTRAINT `fk_address_customer`
    FOREIGN KEY (`customer_id`)
    REFERENCES `camera/video equipment rental dbms`.`customer` (`customer_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `camera/video equipment rental dbms`.`branch`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `camera/video equipment rental dbms`.`branch` (
  `branch_id` INT NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `location` VARCHAR(150) NOT NULL,
  PRIMARY KEY (`branch_id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `camera/video equipment rental dbms`.`category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `camera/video equipment rental dbms`.`category` (
  `category_id` INT NOT NULL,
  `Name` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`category_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `camera/video equipment rental dbms`.`equipment`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `camera/video equipment rental dbms`.`equipment` (
  `equip_id` INT NOT NULL,
  `category_id` INT NOT NULL,
  `Name` VARCHAR(100) NOT NULL,
  `branch` VARCHAR(50) NOT NULL,
  `model` VARCHAR(50) NOT NULL,
  `daily_rate` DECIMAL(8,2) NOT NULL,
  `depsite` DECIMAL(8,2) NOT NULL,
  `status` ENUM('Active', 'Reserved', 'Retired', 'Maintenance') NOT NULL,
  PRIMARY KEY (`equip_id`),
  INDEX `fk_equipment_category` (`category_id` ASC) VISIBLE,
  CONSTRAINT `fk_equipment_category`
    FOREIGN KEY (`category_id`)
    REFERENCES `camera/video equipment rental dbms`.`category` (`category_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `camera/video equipment rental dbms`.`equip_info`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `camera/video equipment rental dbms`.`equip_info` (
  `equip_id` INT NOT NULL,
  `copy_id` INT NOT NULL,
  `Current_branch_id` INT NOT NULL,
  `condition` ENUM('New', 'Good', 'Fair', 'Poor') NOT NULL,
  `Purchase` DATE NOT NULL,
  `Equip_code` CHAR(9) NOT NULL,
  PRIMARY KEY (`equip_id`, `copy_id`),
  UNIQUE INDEX `Equip_code_UNIQUE` (`Equip_code` ASC) VISIBLE,
  INDEX `fk_copy_branch` (`Current_branch_id` ASC) VISIBLE,
  CONSTRAINT `fk_copy_branch`
    FOREIGN KEY (`Current_branch_id`)
    REFERENCES `camera/video equipment rental dbms`.`branch` (`branch_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_copy_equipment`
    FOREIGN KEY (`equip_id`)
    REFERENCES `camera/video equipment rental dbms`.`equipment` (`equip_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `camera/video equipment rental dbms`.`staff`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `camera/video equipment rental dbms`.`staff` (
  `staff_id` INT NOT NULL,
  `branch_id` INT NOT NULL,
  `full_name` VARCHAR(100) NOT NULL,
  `role` ENUM('Clerk', 'Manager', 'tech') NOT NULL,
  `Hiredate` DATE NOT NULL,
  PRIMARY KEY (`staff_id`),
  INDEX `fk_staff_branch` (`branch_id` ASC) VISIBLE,
  CONSTRAINT `fk_staff_branch`
    FOREIGN KEY (`branch_id`)
    REFERENCES `camera/video equipment rental dbms`.`branch` (`branch_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `camera/video equipment rental dbms`.`rental`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `camera/video equipment rental dbms`.`rental` (
  `rental_id` INT NOT NULL,
  `customer_id` INT NOT NULL,
  `staff_id` INT NOT NULL,
  `branch_id` INT NOT NULL,
  `start_date` DATE NOT NULL,
  `end_date` DATE NOT NULL,
  `return_date` DATE NULL DEFAULT NULL,
  PRIMARY KEY (`rental_id`),
  INDEX `fk_rental_customer` (`customer_id` ASC) VISIBLE,
  INDEX `fk_rental_staff` (`staff_id` ASC) VISIBLE,
  INDEX `fk_rental_branch` (`branch_id` ASC) VISIBLE,
  CONSTRAINT `fk_rental_branch`
    FOREIGN KEY (`branch_id`)
    REFERENCES `camera/video equipment rental dbms`.`branch` (`branch_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_rental_customer`
    FOREIGN KEY (`customer_id`)
    REFERENCES `camera/video equipment rental dbms`.`customer` (`customer_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_rental_staff`
    FOREIGN KEY (`staff_id`)
    REFERENCES `camera/video equipment rental dbms`.`staff` (`staff_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `camera/video equipment rental dbms`.`payment`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `camera/video equipment rental dbms`.`payment` (
  `payment_id` INT NOT NULL,
  `rental_id` INT NOT NULL,
  `amount` DECIMAL(8,2) NOT NULL,
  `method` ENUM('Cash', 'Credit', 'Debit', 'Online') NOT NULL,
  `time` TIMESTAMP NOT NULL,
  PRIMARY KEY (`payment_id`),
  INDEX `fk_payment_rental` (`rental_id` ASC) VISIBLE,
  CONSTRAINT `fk_payment_rental`
    FOREIGN KEY (`rental_id`)
    REFERENCES `camera/video equipment rental dbms`.`rental` (`rental_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `camera/video equipment rental dbms`.`rental_item`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `camera/video equipment rental dbms`.`rental_item` (
  `rental_id` INT NOT NULL,
  `equip_id` INT NOT NULL,
  `copy_id` INT NOT NULL,
  `DailyRateRental` DECIMAL(8,2) NOT NULL,
  PRIMARY KEY (`rental_id`, `equip_id`, `copy_id`),
  INDEX `fk_item_copy` (`equip_id` ASC, `copy_id` ASC) VISIBLE,
  CONSTRAINT `fk_item_copy`
    FOREIGN KEY (`equip_id` , `copy_id`)
    REFERENCES `camera/video equipment rental dbms`.`equip_info` (`equip_id` , `copy_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_item_rental`
    FOREIGN KEY (`rental_id`)
    REFERENCES `camera/video equipment rental dbms`.`rental` (`rental_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `camera/video equipment rental dbms`.`reservation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `camera/video equipment rental dbms`.`reservation` (
  `res_id` INT NOT NULL,
  `customer_id` INT NOT NULL,
  `equip_id` INT NOT NULL,
  `start_date` DATE NOT NULL,
  `end_date` DATE NOT NULL,
  `status` ENUM('pending', 'Fulfilled', 'Cancelled', 'Expired') NOT NULL,
  `reservationcol` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`res_id`),
  INDEX `fk_res_customer` (`customer_id` ASC) VISIBLE,
  INDEX `fk_res_equipment` (`equip_id` ASC) VISIBLE,
  CONSTRAINT `fk_res_customer`
    FOREIGN KEY (`customer_id`)
    REFERENCES `camera/video equipment rental dbms`.`customer` (`customer_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_res_equipment`
    FOREIGN KEY (`equip_id`)
    REFERENCES `camera/video equipment rental dbms`.`equipment` (`equip_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

USE `camera/video equipment rental dbms` ;

-- -----------------------------------------------------
-- Placeholder table for view `camera/video equipment rental dbms`.`v_branch_performance`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `camera/video equipment rental dbms`.`v_branch_performance` (`branch_id` INT, `branch` INT, `total_revenue` INT);

-- -----------------------------------------------------
-- Placeholder table for view `camera/video equipment rental dbms`.`v_current_rentals`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `camera/video equipment rental dbms`.`v_current_rentals` (`rental_id` INT, `customer` INT, `branch` INT, `start_date` INT, `end_date` INT, `return_date` INT, `days_left` INT);

-- -----------------------------------------------------
-- Placeholder table for view `camera/video equipment rental dbms`.`v_customer_total_spent`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `camera/video equipment rental dbms`.`v_customer_total_spent` (`customer_id` INT, `full_name` INT, `total_spent` INT);

-- -----------------------------------------------------
-- Placeholder table for view `camera/video equipment rental dbms`.`v_equipment_usage_summary`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `camera/video equipment rental dbms`.`v_equipment_usage_summary` (`equip_id` INT, `equipment_name` INT, `branch` INT, `model` INT, `total_rentals` INT, `total_line_items` INT);

-- -----------------------------------------------------
-- Placeholder table for view `camera/video equipment rental dbms`.`v_revenue_by_category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `camera/video equipment rental dbms`.`v_revenue_by_category` (`category_id` INT, `category_name` INT, `total_revenue` INT);

-- -----------------------------------------------------
-- Placeholder table for view `camera/video equipment rental dbms`.`v_top_equipment`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `camera/video equipment rental dbms`.`v_top_equipment` (`equip_id` INT, `equipment_name` INT, `daily_rate` INT);

-- -----------------------------------------------------
-- View `camera/video equipment rental dbms`.`v_branch_performance`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `camera/video equipment rental dbms`.`v_branch_performance`;
USE `camera/video equipment rental dbms`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `camera/video equipment rental dbms`.`v_branch_performance` AS select `b`.`branch_id` AS `branch_id`,`b`.`name` AS `branch`,`t`.`total_revenue` AS `total_revenue` from (`camera/video equipment rental dbms`.`branch` `b` join (select `r`.`branch_id` AS `branch_id`,coalesce(sum((`ri`.`DailyRateRental` * greatest((to_days(`r`.`end_date`) - to_days(`r`.`start_date`)),1))),0) AS `total_revenue` from (`camera/video equipment rental dbms`.`rental` `r` join `camera/video equipment rental dbms`.`rental_item` `ri` on((`ri`.`rental_id` = `r`.`rental_id`))) group by `r`.`branch_id`) `t` on((`t`.`branch_id` = `b`.`branch_id`))) order by `t`.`total_revenue` desc;

-- -----------------------------------------------------
-- View `camera/video equipment rental dbms`.`v_current_rentals`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `camera/video equipment rental dbms`.`v_current_rentals`;
USE `camera/video equipment rental dbms`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `camera/video equipment rental dbms`.`v_current_rentals` AS select `r`.`rental_id` AS `rental_id`,`c`.`Full_Name` AS `customer`,`b`.`name` AS `branch`,`r`.`start_date` AS `start_date`,`r`.`end_date` AS `end_date`,`r`.`return_date` AS `return_date`,greatest((to_days(`r`.`end_date`) - to_days(curdate())),0) AS `days_left` from ((`camera/video equipment rental dbms`.`rental` `r` join `camera/video equipment rental dbms`.`customer` `c` on((`c`.`customer_id` = `r`.`customer_id`))) join `camera/video equipment rental dbms`.`branch` `b` on((`b`.`branch_id` = `r`.`branch_id`))) where (`r`.`return_date` is null) order by `r`.`end_date`;

-- -----------------------------------------------------
-- View `camera/video equipment rental dbms`.`v_customer_total_spent`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `camera/video equipment rental dbms`.`v_customer_total_spent`;
USE `camera/video equipment rental dbms`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `camera/video equipment rental dbms`.`v_customer_total_spent` AS select `c`.`customer_id` AS `customer_id`,`c`.`Full_Name` AS `full_name`,(select coalesce(sum((`ri`.`DailyRateRental` * greatest((to_days(`r`.`end_date`) - to_days(`r`.`start_date`)),1))),0) from (`camera/video equipment rental dbms`.`rental_item` `ri` join `camera/video equipment rental dbms`.`rental` `r` on((`r`.`rental_id` = `ri`.`rental_id`))) where (`r`.`customer_id` = `c`.`customer_id`)) AS `total_spent` from `camera/video equipment rental dbms`.`customer` `c`;

-- -----------------------------------------------------
-- View `camera/video equipment rental dbms`.`v_equipment_usage_summary`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `camera/video equipment rental dbms`.`v_equipment_usage_summary`;
USE `camera/video equipment rental dbms`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `camera/video equipment rental dbms`.`v_equipment_usage_summary` AS select `e`.`equip_id` AS `equip_id`,`e`.`Name` AS `equipment_name`,`e`.`branch` AS `branch`,`e`.`model` AS `model`,count(distinct `ri`.`rental_id`) AS `total_rentals`,count(distinct concat(`ri`.`rental_id`,'-',`ri`.`equip_id`,'-',`ri`.`copy_id`)) AS `total_line_items` from (`camera/video equipment rental dbms`.`equipment` `e` left join `camera/video equipment rental dbms`.`rental_item` `ri` on((`ri`.`equip_id` = `e`.`equip_id`))) group by `e`.`equip_id`,`e`.`Name`,`e`.`branch`,`e`.`model` order by `total_rentals` desc;

-- -----------------------------------------------------
-- View `camera/video equipment rental dbms`.`v_revenue_by_category`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `camera/video equipment rental dbms`.`v_revenue_by_category`;
USE `camera/video equipment rental dbms`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `camera/video equipment rental dbms`.`v_revenue_by_category` AS select `c`.`category_id` AS `category_id`,`c`.`Name` AS `category_name`,sum((`ri`.`DailyRateRental` * greatest((to_days(`r`.`end_date`) - to_days(`r`.`start_date`)),1))) AS `total_revenue` from (((`camera/video equipment rental dbms`.`category` `c` left join `camera/video equipment rental dbms`.`equipment` `e` on((`e`.`category_id` = `c`.`category_id`))) left join `camera/video equipment rental dbms`.`rental_item` `ri` on((`ri`.`equip_id` = `e`.`equip_id`))) left join `camera/video equipment rental dbms`.`rental` `r` on((`r`.`rental_id` = `ri`.`rental_id`))) group by `c`.`category_id`,`c`.`Name` order by `total_revenue` desc;

-- -----------------------------------------------------
-- View `camera/video equipment rental dbms`.`v_top_equipment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `camera/video equipment rental dbms`.`v_top_equipment`;
USE `camera/video equipment rental dbms`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `camera/video equipment rental dbms`.`v_top_equipment` AS select `e`.`equip_id` AS `equip_id`,`e`.`Name` AS `equipment_name`,`e`.`daily_rate` AS `daily_rate` from `camera/video equipment rental dbms`.`equipment` `e` where (`e`.`daily_rate` > (select avg(`camera/video equipment rental dbms`.`equipment`.`daily_rate`) from `camera/video equipment rental dbms`.`equipment`));

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
