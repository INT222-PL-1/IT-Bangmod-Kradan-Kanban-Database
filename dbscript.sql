CREATE DATABASE IF NOT EXISTS `itb-kk`;
USE `itb-kk`;

DROP TABLE IF EXISTS task_v1;

DROP TABLE IF EXISTS task_v2;
DROP TABLE IF EXISTS status_v2;
DROP TABLE IF EXISTS board_v2;
DROP TRIGGER IF EXISTS trg_status_v2_update_predefined_status_before;
DROP TRIGGER IF EXISTS trg_status_v2_delete_predefined_status_before;

DROP TABLE IF EXISTS task_v3;
DROP TABLE IF EXISTS status_v3;
DROP TABLE IF EXISTS user_boards_v3;
DROP TABLE IF EXISTS board_v3;
DROP TABLE IF EXISTS user_v3;
DROP TRIGGER IF EXISTS trg_status_v3_update_predefined_status_before;
DROP TRIGGER IF EXISTS trg_status_v3_delete_predefined_status_before;


# ======== Version 1 ========================================

CREATE TABLE task_v1 (
    task_id INT NOT NULL AUTO_INCREMENT,
    task_title TEXT NOT NULL,
    task_description TEXT(500),
    task_assignees TEXT,
    task_status ENUM('NO_STATUS', 'TO_DO', 'DOING', 'DONE') DEFAULT 'NO_STATUS' NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT `task_v1_title_length_min1_max100` CHECK (CHAR_LENGTH(task_title) <= 100 AND task_title <> ''),
    CONSTRAINT `task_v1_description_length_min1_max100` CHECK (CHAR_LENGTH(task_description) <= 500 AND task_description <> ''),
    CONSTRAINT `task_v1_assignees_length_min1_max30` CHECK (CHAR_LENGTH(task_assignees) <= 30 AND task_assignees <> ''),
    PRIMARY KEY (task_id)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- INSERT INTO taskV1 (
--     taskTitle,
--     taskDescription,
--     taskAssignees,
--     taskStatus,
--     createdOn,
--     updatedOn
-- )
-- VALUES 
-- ('TaskTitle1TaskTitle2TaskTitle3TaskTitle4TaskTitle5TaskTitle6TaskTitle7TaskTitle8TaskTitle9TaskTitle0','Descripti1Descripti2Descripti3Descripti4Descripti5Descripti6Descripti7Descripti8Descripti9Descripti1Descripti1Descripti2Descripti3Descripti4Descripti5Descripti6Descripti7Descripti8Descripti9Descripti2Descripti1Descripti2Descripti3Descripti4Descripti5Descripti6Descripti7Descripti8Descripti9Descripti3Descripti1Descripti2Descripti3Descripti4Descripti5Descripti6Descripti7Descripti8Descripti9Descripti4Descripti1Descripti2Descripti3Descripti4Descripti5Descripti6Descripti7Descripti8Descripti9Descripti5','Assignees1Assignees2Assignees3','NO_STATUS','2024-04-22 09:00:00','2024-04-22 09:00:00'),
-- ('Repository', null, null,'TO_DO','2024-04-22  09:05:00','2024-04-22 14:00:00'),
-- ('ดาต้าเบส','ສ້າງຖານຂໍ້ມູນ','あなた、彼、彼女 (私ではありません)','DOING','2024-04-22  09:10:00','2024-04-25 00:00:00'),
-- ('_Infrastructure_','_Setup containers_','ไก่งวง กับ เพนกวิน','DONE','2024-04-22 09:15:00','2024-04-22 10:00:00');



# ======== Version 2 ========================================

CREATE TABLE status_v2 (
    status_id INT NOT NULL AUTO_INCREMENT,
    status_name VARCHAR(50) UNIQUE NOT NULL,
    status_description TEXT,
    status_color VARCHAR(7) DEFAULT '#999999',
    is_predefined BOOLEAN DEFAULT false,
    CONSTRAINT `status_v2_name_length_min1_max50` CHECK (CHAR_LENGTH(status_name) <= 50 AND status_name <> ''),
    CONSTRAINT `status_v2_description_length_min1_max200` CHECK (CHAR_LENGTH(status_description) <= 200 AND status_description <> ''),
    PRIMARY KEY (status_id)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO status_v2 (
    status_name,
    status_description,
    status_color,
    is_predefined
)
VALUES 
('No Status', 'A status has not been assigned', '#4b5563', true),
('To Do', 'The task is included in the project', '#ff5861', false),
('In Progress', 'The task is being worked on', '#ffbe00', false),
('Reviewing', 'The task is being reviewed', '#ffbe00', false),
('Testing', 'The task is being tested', '#ffbe00', false),
('Waiting', 'The task is waiting for a resource', '#ffbe00', false),
('Done', 'The task has been completed', '#00a96e', true);

DELIMITER $$

CREATE TRIGGER trg_status_v2_update_predefined_status_before
BEFORE UPDATE
ON status_v2
FOR EACH ROW 
BEGIN
	IF OLD.is_predefined = true AND NEW.is_predefined = true THEN
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot update: this status is predefined status cause it cannot update or delete';
	END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_status_v2_delete_predefined_status_before
BEFORE DELETE
ON status_v2
FOR EACH ROW 
BEGIN
	IF OLD.is_predefined = true THEN
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot delete: this status is predefined status cause it cannot update or delete';
	END IF;
END$$

DELIMITER ;

CREATE TABLE board_v2 (
    board_id INT NOT NULL AUTO_INCREMENT,
    is_task_limit_enabled BOOLEAN DEFAULT false,
    task_limit_per_status INT DEFAULT 10,
    PRIMARY KEY (board_id)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO board_v2 (
    is_task_limit_enabled,
    task_limit_per_status
)
VALUES 
(true, 10);

CREATE TABLE task_v2 (
    task_id INT NOT NULL AUTO_INCREMENT,
    task_title TEXT NOT NULL,
    task_description TEXT,
    task_assignees TEXT,
    status_id INT,
    board_id INT NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT `task_v2_title_length_min1_max100` CHECK (CHAR_LENGTH(task_title) <= 100 AND task_title <> ''),
    CONSTRAINT `task_v2_description_length_min1_max500` CHECK (CHAR_LENGTH(task_description) <= 500 AND task_description <> ''),
    CONSTRAINT `task_v2_assignees_length_min1_max30` CHECK (CHAR_LENGTH(task_assignees) <= 30 AND task_assignees <> ''),
    PRIMARY KEY (task_id),
    CONSTRAINT fk_task_v2_status_v2 FOREIGN KEY (`status_id`) REFERENCES `status_v2`(`status_id`),
    CONSTRAINT fk_task_v2_board_v2 FOREIGN KEY (`board_id`) REFERENCES `board_v2`(`board_id`)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- INSERT INTO task_v2 (
--     task_id,
--     task_title,
--     status_id,
--     created_on,
--     updated_on,
--     board_id
-- )
-- VALUES
-- (1, 'NS01', 1, '2024-05-14 09:00:00', '2024-05-14 09:00:00', 1),
-- (2, 'TD01', 2, '2024-05-14 09:10:00', '2024-05-14 09:10:00', 1),
-- (3, 'IP01', 3, '2024-05-14 09:20:00', '2024-05-14 09:20:00', 1),
-- (4, 'TD02', 2, '2024-05-14 09:30:00', '2024-05-14 09:30:00', 1),
-- (5, 'DO01', 7, '2024-05-14 09:40:00', '2024-05-14 09:40:00', 1),
-- (6, 'IP02', 3, '2024-05-14 09:50:00', '2024-05-14 09:50:00', 1);



# ======== Version 3 ========================================

CREATE TABLE user_v3 (
    oid CHAR(36) NOT NULL,
    name TEXT NOT NULL,
    username TEXT NOT NULL,
    email TEXT NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT `user_v3_name_length_min1_max100` CHECK (CHAR_LENGTH(name) <= 100 AND name <> ''),
    CONSTRAINT `user_v3_username_length_min1_max50` CHECK (CHAR_LENGTH(username) <= 50 AND username <> ''),
    CONSTRAINT `user_v3_email_length_min1_max30` CHECK (CHAR_LENGTH(email) <= 30 AND email <> ''),
    PRIMARY KEY (oid)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE board_v3 (
    board_id CHAR(10) NOT NULL,
    owner_oid CHAR(36) NOT NULL,
    board_name TEXT NOT NULL, 
    board_visibility ENUM("PRIVATE", "PUBLIC") DEFAULT 'PRIVATE',
    is_task_limit_enabled BOOLEAN DEFAULT false,
    task_limit_per_status INT DEFAULT 10,
    default_status_config CHAR(5) NULL DEFAULT '11',
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT `board_v3_name_length_min1_max120` CHECK (CHAR_LENGTH(board_name) <= 120 AND board_name <> ''),
    PRIMARY KEY (board_id)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_boards_v3 (
    user_oid CHAR(36) NOT NULL,
    board_id CHAR(10) NOT NULL,
    user_permission ENUM("read", "write") NOT NULL,
    PRIMARY KEY (user_oid, board_id, user_permission),
    CONSTRAINT `fk_user_v3_board_v3_user_oid` FOREIGN KEY (`user_oid`) REFERENCES `user_v3`(`oid`),
    CONSTRAINT `fk_user_v3_board_v3_board_id` FOREIGN KEY (`board_id`) REFERENCES `board_v3`(`board_id`)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- INSERT INTO boardV3 (
--     boardId,
--     owner_oid,
--     name,
--     is_limit_tasks,
--     task_limit_per_status,
--     default_statuses_config
-- )
-- VALUES 
-- ('a01s28f3qq', '0712334f-4982-4d26-a7ef-4ad0ff53cb18', 'ITBKK PICHET personal board', false, 10, '11');

CREATE TABLE status_v3 (
    status_id INT NOT NULL AUTO_INCREMENT,
    status_name TEXT NOT NULL,
    status_description TEXT,
    status_color VARCHAR(7) DEFAULT '#999999',
    is_predefined BOOLEAN DEFAULT false,
    board_id CHAR(10) NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT `status_v3_name_length_min1_max50` CHECK (CHAR_LENGTH(status_name) <= 50 AND status_name <> ''),
    CONSTRAINT `status_v3_description_length_min1_max200` CHECK (CHAR_LENGTH(status_description) <= 200 AND status_description <> ''),
    PRIMARY KEY (status_id),
    CONSTRAINT fk_status_v3_board_v3 FOREIGN KEY (`board_id`) REFERENCES `board_v3` (`board_id`)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DELIMITER $$

CREATE TRIGGER trg_status_v3_update_predefined_status_before
BEFORE UPDATE
ON status_v3
FOR EACH ROW 
BEGIN
    IF OLD.is_predefined = true AND NEW.is_predefined = true THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot update: this status is predefined status cause it cannot update or delete';
    END IF;
END$$

DELIMITER ; 

DELIMITER $$

CREATE TRIGGER trg_status_v3_delete_predefined_status_before
BEFORE DELETE
ON status_v3
FOR EACH ROW 
BEGIN
    IF OLD.is_predefined = true THEN
	    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete: this status is predefined status cause it cannot update or delete';
    END IF;
END$$

DELIMITER ;

INSERT INTO status_v3 (
    status_name,
    status_description,
    status_color,
    is_predefined
)
VALUES 
('No Status', 'A status has not been assigned', '#999999', true),
('To Do','The task is included in the project','#3cb371', false),
('Doing','The task is being worked on','#ffa500', false),
('Done','The task has been completed','#8142ff', true);

CREATE TABLE task_v3 (
    task_id INT NOT NULL AUTO_INCREMENT,
    task_title TEXT NOT NULL,
    task_description TEXT,
    task_assignees TEXT,
    status_id INT NOT NULL,
    board_id CHAR(10) NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT `task_v3_title_length_min1_max100` CHECK (CHAR_LENGTH(task_title) <= 100 AND task_title <> ''),
    CONSTRAINT `task_v3_description_length_min1_max500` CHECK (CHAR_LENGTH(task_description) <= 500 AND task_description <> ''),
    CONSTRAINT `task_v3_assignees_length_min1_max30` CHECK (CHAR_LENGTH(task_assignees) <= 30 AND task_assignees <> ''),
    PRIMARY KEY (task_id),
    CONSTRAINT fk_task_v3_status_v3 FOREIGN KEY (`status_id`) REFERENCES `status_v3`(`status_id`),
    CONSTRAINT fk_task_v3_board_v3 FOREIGN KEY (`board_id`) REFERENCES `board_v3`(`board_id`)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET autocommit = off; 
COMMIT;

DROP USER IF EXISTS `itb-kk-be`;
CREATE USER 'itb-kk-be' IDENTIFIED WITH mysql_native_password BY 'itb-kk';
GRANT SELECT, INSERT, UPDATE, DELETE ON `itb-kk`.* TO 'itb-kk-be'@'%'; 
