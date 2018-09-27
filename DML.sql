# Скрипты должны выполняться в уже созданной БД
# Скрипт заполнения БД, выполняется 1 раз
# Перед заполнением БД, таблицы должны быть созданы !

# Внесение данных о игроках и
# их регистрации

SET @countPlayers = 100;
SET @countMatches = 1000;
drop procedure IF EXISTS doiterate;
create procedure doiterate(IN p1 int)
  BEGIN
    label1: LOOP
      IF p1 > 0
      THEN
        #         данные о игроках
        INSERT INTO player (level, nickname, rating, created, modified)
        VALUES (p1 % 100, CONCAT('test', p1), p1 % 1000, NOW() - INTERVAL 10 DAY, NOW() - INTERVAL 10 DAY);
        #         данные о их регистрации
        INSERT INTO player_autorisation
        (id_player, full_name, email, login, password, created)
        VALUES ((SELECT id_player
                 FROM player
                 WHERE player.nickname = CONCAT('test', p1)),
                CONCAT('Такой то такойтович', p1), CONCAT('trueEmail', p1, '@verno.com'),
                CONCAT('testLogin', p1), CONCAT('testPassword', p1), NOW() - INTERVAL 10 DAY);
        SET p1 = p1 - 1;
        ITERATE label1;
      END IF;
      LEAVE label1;
    END LOOP label1;
  END;
call doiterate(@countPlayers);
drop procedure doiterate;
# Создание истории игроков путем обновления

UPDATE player
SET level  = level + ROUND(RAND() * 4, 0),
  rating   = rating + ROUND(RAND() * 30, 0),
  modified = NOW() - INTERVAL ROUND(RAND() * 3, 0) + 3 DAY;
UPDATE player
SET level  = level + ROUND(RAND() * 4, 0),
  rating   = rating + ROUND(RAND() * 30, 0),
  modified = NOW() - INTERVAL ROUND(RAND() * 3, 0) DAY;

# Создание типов персонажей

INSERT INTO character_type (name, discription, base_param1, base_param2, base_param3)
VALUES ('Warrior', 'true warrior', 10, 20, 30);
INSERT INTO character_type (name, discription, base_param1, base_param2, base_param3)
VALUES ('Mage', 'true mage', 30, 15, 15);
INSERT INTO character_type (name, discription, base_param1, base_param2, base_param3)
VALUES ('Rogue', 'true rogue', 15, 30, 15);

# Создание персонажей для игроков

create procedure doiterate(IN p1 int)
  BEGIN
    SET @TypeNum = 1;
    label1: LOOP
      IF p1 > 0
      THEN
        SET @TypeNum = (@TypeNum) % 3 + 1;
        INSERT INTO `character` (id_player, id_character_type, param1,
                                 param2, param3, created, modified)
        VALUES ((SELECT id_player
                 FROM player
                 WHERE player.nickname = CONCAT('test', p1)),
                @TypeNum, 25 + @TypeNum, 25 + @TypeNum * @TypeNum, 27, NOW() - INTERVAL ROUND(RAND() * 3, 0) + 8 DAY,
                NOW() - INTERVAL 10 DAY);
        SET @TypeNum = (@TypeNum) % 3 + 1;
        SET @newdate = NOW() - INTERVAL ROUND(RAND() * 2, 0) + 6 DAY;
        INSERT INTO `character` (id_player, id_character_type, param1,
                                 param2, param3, created, modified)
        VALUES ((SELECT id_player
                 FROM player
                 WHERE player.nickname = CONCAT('test', p1)),
                @TypeNum, 25 + @TypeNum, 29, 25 + @TypeNum * @TypeNum, @newdate, @newdate);
        SET p1 = p1 - 1;
        ITERATE label1;
      END IF;
      LEAVE label1;
    END LOOP label1;
  END;
call doiterate(@countPlayers);
drop procedure doiterate;

# Создание истории персонажей для игроков путем обновления персонажей

UPDATE `character`
SET param1 = param1 + ROUND(RAND() * 30, 0),
  param2   = param2 + ROUND(RAND() * 30, 0),
  param3   = param3 + ROUND(RAND() * 30, 0),
  modified = NOW() - INTERVAL ROUND(RAND() * 3, 0) + 3 DAY;
UPDATE `character`
SET param1 = param1 + ROUND(RAND() * 30, 0),
  param2   = param2 + ROUND(RAND() * 30, 0),
  param3   = param3 + ROUND(RAND() * 30, 0),
  modified = NOW() - INTERVAL ROUND(RAND() * 3, 0) DAY;

# Создание типов матчей

INSERT INTO match_type (name, discription) VALUES ('2x2', 'just 2x2');
INSERT INTO match_type (name, discription) VALUES ('2x2s', 'special 2x2');
INSERT INTO match_type (name, discription) VALUES ('3x3', 'just 3x3');
INSERT INTO match_type (name, discription) VALUES ('3x3s', 'special 3x3');
INSERT INTO match_type (name, discription) VALUES ('5x5', 'just 5x5');
INSERT INTO match_type (name, discription) VALUES ('5x5s', 'special 5x5');

# Создание типов действий в истории матчей

INSERT INTO match_history_action (id_match_history_action, name, discription)
VALUES (1, 'kill_p', 'kill another player');
INSERT INTO match_history_action (id_match_history_action, name, discription)
VALUES (2, 'killed_p', 'killed by another player');
INSERT INTO match_history_action (id_match_history_action, name, discription)
VALUES (3, 'killed_m', 'killed be mob');
INSERT INTO match_history_action (id_match_history_action, name, discription)
VALUES (4, 'get_ach', 'get achievement');

# Создание матчей и их истории

create procedure doiterate(IN p1 int)
  BEGIN
    SET @TypeNum = 1;
    label1: LOOP
      IF p1 > 0
      THEN
        SET @T1C1 = (SELECT id_character
                     FROM `character`
                     ORDER BY RAND()
                     LIMIT 1);
        SET @T1C2 = (SELECT id_character
                     FROM `character`
                     ORDER BY RAND()
                     LIMIT 1);
        SET @T2C1 = (SELECT id_character
                     FROM `character`
                     ORDER BY RAND()
                     LIMIT 1);
        SET @T2C2 = (SELECT id_character
                     FROM `character`
                     ORDER BY RAND()
                     LIMIT 1);
        #         данные о матче
        SET @jsonT1 = CONCAT(N'{"player1":', @T1C1, ',"player2":', @T1C2, '}');
        SET @jsonT2 = CONCAT(N'{"player1":', @T2C1, ',"player2":', @T2C2, '}');
        SET @jsonRes = CONCAT(N'{"team1result":', ROUND(RAND() * 100, 0),
                              ',"team2result":', ROUND(RAND() * 100, 0),
                              '}');
        INSERT INTO `match`
        (id_match_type, team1, team2, match_result, started, finished)
        VALUES (@TypeNum, @jsonT1, @jsonT2, @jsonRes, NOW(), NOW());
        # внесение записей в историю мачта

        SET @id = (SELECT id_match
                   FROM `match`
                   ORDER BY id_match DESC
                   LIMIT 1);
        INSERT INTO `match_history`
        (id_match, id_character, id_match_history_action, created)
        VALUES (@id, @T1C1, (SELECT id_match_history_action
                             FROM match_history_action
                             ORDER BY RAND()
                             LIMIT 1), NOW());
        INSERT INTO `match_history`
        (id_match, id_character, id_match_history_action, created)
        VALUES (@id, @T1C2, (SELECT id_match_history_action
                             FROM match_history_action
                             ORDER BY RAND()
                             LIMIT 1), NOW());
        INSERT INTO `match_history`
        (id_match, id_character, id_match_history_action, created)
        VALUES (@id, @T2C1, (SELECT id_match_history_action
                             FROM match_history_action
                             ORDER BY RAND()
                             LIMIT 1), NOW());
        INSERT INTO `match_history`
        (id_match, id_character, id_match_history_action, created)
        VALUES (@id, @T2C2, (SELECT id_match_history_action
                             FROM match_history_action
                             ORDER BY RAND()
                             LIMIT 1), NOW());
        INSERT INTO `match_history`
        (id_match, id_character, id_match_history_action, created)
        VALUES (@id, @T1C1, (SELECT id_match_history_action
                             FROM match_history_action
                             ORDER BY RAND()
                             LIMIT 1), NOW());
        INSERT INTO `match_history`
        (id_match, id_character, id_match_history_action, created)
        VALUES (@id, @T1C2, (SELECT id_match_history_action
                             FROM match_history_action
                             ORDER BY RAND()
                             LIMIT 1), NOW());
        INSERT INTO `match_history`
        (id_match, id_character, id_match_history_action, created)
        VALUES (@id, @T2C1, (SELECT id_match_history_action
                             FROM match_history_action
                             ORDER BY RAND()
                             LIMIT 1), NOW());
        INSERT INTO `match_history`
        (id_match, id_character, id_match_history_action, created)
        VALUES (@id, @T2C2, (SELECT id_match_history_action
                             FROM match_history_action
                             ORDER BY RAND()
                             LIMIT 1), NOW());


        SET @TypeNum = (@TypeNum) % 6 + 1;
        SET p1 = p1 - 1;
        ITERATE label1;
      END IF;
      LEAVE label1;
    END LOOP label1;
  END;
call doiterate(@countMatches);
drop procedure doiterate;

