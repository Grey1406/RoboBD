# Скрипты должны выполняться в уже созданной БД
# Скрипт заполнения БД, выполняется 1 раз
# При повторном выполнении возможны ошибки
# Перед заполнением БД, таблицы должны быть созданы !

# Внесение данных о игроках и
# их регистрации

SET @countPlayers = 40;
SET @countMatches = 200;
drop procedure IF EXISTS doiterate;
create procedure doiterate(IN p1 int)
  BEGIN
    label1: LOOP
      IF p1 > 0
      THEN
        SET @Date = NOW() - INTERVAL ROUND(RAND() * 200, 0) + 300 DAY;
        #         данные о игроках
        INSERT INTO player (level, nickname, rating, created, modified, lastActivity)
        VALUES (1, CONCAT('test', p1), 1, @Date, @Date, @Date);
        #         данные о их регистрации
        INSERT INTO player_autorisation
        (id_player, full_name, email, login, password, created)
        VALUES ((SELECT id_player
                 FROM player
                 WHERE player.nickname = CONCAT('test', p1)),
                CONCAT('Такой то такойтович', p1), CONCAT('trueEmail', p1, '@verno.com'),
                CONCAT('testLogin', p1), CONCAT('testPassword', p1), @Date);
        SET p1 = p1 - 1;
        ITERATE label1;
      END IF;
      LEAVE label1;
    END LOOP label1;
  END;
call doiterate(@countPlayers);
drop procedure doiterate;

# Создание истории игроков путем обновления

create procedure updatePlayer(IN p1 int)
  BEGIN
    label1: LOOP
      IF p1 > 0
      THEN
        UPDATE player
        SET level      = level + ROUND(RAND() * 3, 0),
          rating       = rating + ROUND(RAND() * 20, 0),
          modified     = modified + INTERVAL ROUND(RAND() * 50, 0) DAY,
          lastActivity = modified;
        SET p1 = p1 - 1;
        ITERATE label1;
      END IF;
      LEAVE label1;
    END LOOP label1;
  END;
call updatePlayer(2);

# Создание типов персонажей

INSERT INTO character_type (name, discription, base_param1, base_param2, base_param3)
VALUES ('Warrior', 'true warrior', 10, 20, 30);
INSERT INTO character_type (name, discription, base_param1, base_param2, base_param3)
VALUES ('Mage', 'true mage', 30, 15, 15);
INSERT INTO character_type (name, discription, base_param1, base_param2, base_param3)
VALUES ('Rogue', 'true rogue', 15, 30, 15);

# Создание типов матчей

INSERT INTO match_type (name, discription) VALUES ('vs', 'player vs player');
INSERT INTO match_type (name, discription) VALUES ('p_vs_m', 'players vs mobs');
INSERT INTO match_type (name, discription) VALUES ('p_vs_b', 'players vs Boss');
INSERT INTO match_type (name, discription) VALUES ('special1', 'special1');
INSERT INTO match_type (name, discription) VALUES ('special2', 'special2');
INSERT INTO match_type (name, discription) VALUES ('special3', 'special3');

# Создание типов действий в истории матчей

INSERT INTO match_history_action (id_match_history_action, name, discription)
VALUES (1, 'kill_p', 'kill another player');
INSERT INTO match_history_action (id_match_history_action, name, discription)
VALUES (2, 'killed_p', 'killed by another player');
INSERT INTO match_history_action (id_match_history_action, name, discription)
VALUES (3, 'killed_m', 'killed be mob');
INSERT INTO match_history_action (id_match_history_action, name, discription)
VALUES (4, 'get_ach', 'get achievement');

# Создание персонажей для игроков и их истории

create procedure createCharacter(IN p1 int, IN p2 DATETIME)
  BEGIN
    SET @TypeNum = 1;
    label1: LOOP
      IF p1 > 0
      THEN
        SET @TypeNum = (@TypeNum) % 3 + 1;
        SET @Date = p2 - INTERVAL ROUND(RAND() * 200, 0) DAY;
        INSERT INTO `character` (id_player, id_character_type, param1,
                                 param2, param3, created, modified, lastActivity)
        VALUES ((SELECT id_player
                 FROM player
                 WHERE player.nickname = CONCAT('test', p1)),
                @TypeNum, 25 + @TypeNum, 25 + @TypeNum * @TypeNum, 27, @Date, @Date, @Date);
        SET @TypeNum = (@TypeNum) % 3 + 1;
        SET p1 = p1 - 1;
        ITERATE label1;
      END IF;
      LEAVE label1;
    END LOOP label1;
  END;

# Создание истории персонажей для игроков путем обновления персонажей


create procedure updateCharacter(IN p1 int)
  BEGIN
    label1: LOOP
      IF p1 > 0
      THEN
        UPDATE `character`
        SET param1     = param1 + ROUND(RAND() * 10, 0),
          param2       = param2 + ROUND(RAND() * 10, 0),
          param3       = param3 + ROUND(RAND() * 10, 0),
          modified     = modified + INTERVAL ROUND(RAND() * 50, 0) DAY,
          lastActivity = modified;
        SET p1 = p1 - 1;
        ITERATE label1;
      END IF;
      LEAVE label1;
    END LOOP label1;
  END;
call updateCharacter(2);

# Создание матчей и их истории

create procedure createMatch(IN p1 int, IN p2 DATETIME)
  BEGIN
    SET @TypeNum = 1;
    label1: LOOP
      IF p1 > 0
      THEN
        SET @DateStart = p2 - INTERVAL ROUND(RAND() * 200, 0) DAY;
        SET @DateEND = @DateStart + INTERVAL ROUND(RAND() * 20, 0) MINUTE;
        SET @Character1 = (SELECT id_character
                           FROM `character`
                           ORDER BY RAND()
                           LIMIT 1);
        SET @Character2 = (SELECT id_character
                           FROM `character`
                           ORDER BY RAND()
                           LIMIT 1);
        SET @Score1 = ROUND(RAND() * 100, 0);
        SET @Score2 = ROUND(RAND() * 100, 0);
        INSERT INTO `match`
        (id_match_type, character1, character2, score1, score2, started, finished)
        VALUES (@TypeNum, @Character1, @Character2, @Score1, @Score2, @DateStart, @DateEND);

        # внесение записей в историю мачта

        SET @id = (SELECT id_match
                   FROM `match`
                   ORDER BY id_match DESC
                   LIMIT 1);

        SET @DateAction = @DateStart + INTERVAL ROUND(RAND() * TIME_TO_SEC(TIMEDIFF(@DateEND, @DateStart))) SECOND;
        INSERT INTO `match_history`
        (id_match, id_character, id_match_history_action, created)
        VALUES (@id, @Character1, (SELECT id_match_history_action
                                   FROM match_history_action
                                   ORDER BY RAND()
                                   LIMIT 1), @DateAction);
        SET @DateAction = @DateStart + INTERVAL ROUND(RAND() * TIME_TO_SEC(TIMEDIFF(@DateEND, @DateStart))) SECOND;
        INSERT INTO `match_history`
        (id_match, id_character, id_match_history_action, created)
        VALUES (@id, @Character1, (SELECT id_match_history_action
                                   FROM match_history_action
                                   ORDER BY RAND()
                                   LIMIT 1), @DateAction);
        SET @DateAction = @DateStart + INTERVAL ROUND(RAND() * TIME_TO_SEC(TIMEDIFF(@DateEND, @DateStart))) SECOND;
        INSERT INTO `match_history`
        (id_match, id_character, id_match_history_action, created)
        VALUES (@id, @Character1, (SELECT id_match_history_action
                                   FROM match_history_action
                                   ORDER BY RAND()
                                   LIMIT 1), @DateAction);
        SET @DateAction = @DateStart + INTERVAL ROUND(RAND() * TIME_TO_SEC(TIMEDIFF(@DateEND, @DateStart))) SECOND;
        INSERT INTO `match_history`
        (id_match, id_character, id_match_history_action, created)
        VALUES (@id, @Character1, (SELECT id_match_history_action
                                   FROM match_history_action
                                   ORDER BY RAND()
                                   LIMIT 1), @DateAction);
        SET @DateAction = @DateStart + INTERVAL ROUND(RAND() * TIME_TO_SEC(TIMEDIFF(@DateEND, @DateStart))) SECOND;
        INSERT INTO `match_history`
        (id_match, id_character, id_match_history_action, created)
        VALUES (@id, @Character2, (SELECT id_match_history_action
                                   FROM match_history_action
                                   ORDER BY RAND()
                                   LIMIT 1), @DateAction);
        SET @DateAction = @DateStart + INTERVAL ROUND(RAND() * TIME_TO_SEC(TIMEDIFF(@DateEND, @DateStart))) SECOND;
        INSERT INTO `match_history`
        (id_match, id_character, id_match_history_action, created)
        VALUES (@id, @Character2, (SELECT id_match_history_action
                                   FROM match_history_action
                                   ORDER BY RAND()
                                   LIMIT 1), @DateAction);
        SET @DateAction = @DateStart + INTERVAL ROUND(RAND() * TIME_TO_SEC(TIMEDIFF(@DateEND, @DateStart))) SECOND;
        INSERT INTO `match_history`
        (id_match, id_character, id_match_history_action, created)
        VALUES (@id, @Character2, (SELECT id_match_history_action
                                   FROM match_history_action
                                   ORDER BY RAND()
                                   LIMIT 1), @DateAction);
        SET @DateAction = @DateStart + INTERVAL ROUND(RAND() * TIME_TO_SEC(TIMEDIFF(@DateEND, @DateStart))) SECOND;
        INSERT INTO `match_history`
        (id_match, id_character, id_match_history_action, created)
        VALUES (@id, @Character2, (SELECT id_match_history_action
                                   FROM match_history_action
                                   ORDER BY RAND()
                                   LIMIT 1), @DateAction);
        SET @TypeNum = (@TypeNum) % 6 + 1;
        SET p1 = p1 - 1;
        ITERATE label1;
      END IF;
      LEAVE label1;
    END LOOP label1;
  END;

# 1 пачка
call createCharacter(@countPlayers, NOW() - INTERVAL 200 day);
call createMatch(@countMatches, NOW() - INTERVAL 200 day);
call updatePlayer(2);
call updateCharacter(2);
# 2 пачка
call createCharacter(@countPlayers, NOW() - INTERVAL 100 day);
call createMatch(@countMatches * 2, NOW() - INTERVAL 100 day);
call updatePlayer(1);
call updateCharacter(1);
# 3 пачка
call createCharacter(@countPlayers, NOW());
call createMatch(@countMatches * 2, NOW());
call updatePlayer(1);
call updateCharacter(1);

# Сброс процедур
drop procedure createCharacter;
drop procedure createMatch;
drop procedure updatePlayer;
drop procedure updateCharacter;
