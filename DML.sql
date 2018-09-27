# Скрипты должны выполняться в уже созданной БД
# Скрипт заполнения БД, выполняется 1 раз
# Перед заполнением БД, таблицы должны быть созданы !

# Внесение данных о игроках и
# их регистрации

SET @i=100;
drop procedure IF EXISTS doiterate;
create procedure doiterate(IN p1 int)
  BEGIN
    label1: LOOP
      IF p1 > 0
      THEN
        #         данные о игроках
        INSERT INTO player (level, nickname, rating, created, modified)
        VALUES (p1% 100, CONCAT('test', p1), p1% 1000, NOW()-INTERVAL 10 DAY ,NOW()-INTERVAL 10 DAY);
        #         данные о их регистрации
        INSERT INTO player_autorisation
        (id_player, full_name, email, login, password, created)
        VALUES ((SELECT id_player
                 FROM player
                 WHERE player.nickname = CONCAT('test', p1)),
                CONCAT('Такой то такойтович', p1), CONCAT('trueEmail', p1, '@verno.com'),
                CONCAT('testLogin', p1), CONCAT('testPassword', p1), NOW()-INTERVAL 10 DAY);
        SET p1 = p1 - 1;
        ITERATE label1;
      END IF;
      LEAVE label1;
    END LOOP label1;
  END;
call doiterate(@i);
drop procedure doiterate;




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
                @TypeNum, 25 + @TypeNum, 25 + @TypeNum * @TypeNum, 27, NOW()-INTERVAL 10 DAY, NOW()-INTERVAL 10 DAY);
        SET @TypeNum = (@TypeNum) % 3 + 1;
        INSERT INTO `character` (id_player, id_character_type, param1,
                                 param2, param3, created, modified)
        VALUES ((SELECT id_player
                 FROM player
                 WHERE player.nickname = CONCAT('test', p1)),
                @TypeNum, 25 + @TypeNum, 29, 25 + @TypeNum * @TypeNum,NOW()-INTERVAL 7 DAY, NOW()-INTERVAL 7 DAY);
        SET p1 = p1 - 1;
        ITERATE label1;
      END IF;
      LEAVE label1;
    END LOOP label1;
  END;
call doiterate(@i);
drop procedure doiterate;

# Создание истории персонажей для игроков путем обновления персонажей

UPDATE `character`
SET param1 = param1 + 10,
  param2   = param2 + 11,
  param3   = param3 + 12,
  modified = NOW()-INTERVAL 6 DAY;
UPDATE `character`
SET param1 = param1 + 21,
  param2   = param2 + 26,
  param3   = param3 + 28,
  modified = NOW()-INTERVAL 4 DAY;

# Создание типов матчей

INSERT INTO homestead.match_type (id_match_type, name, discription) VALUES (2, '2x2', 'just 2x2');
INSERT INTO homestead.match_type (id_match_type, name, discription) VALUES (2, '2x2s', 'special 2x2');
INSERT INTO homestead.match_type (id_match_type, name, discription) VALUES (2, '3x3', 'just 3x3');
INSERT INTO homestead.match_type (id_match_type, name, discription) VALUES (2, '3x3s', 'special 3x3');
INSERT INTO homestead.match_type (id_match_type, name, discription) VALUES (2, '5x5', 'just 5x5');
INSERT INTO homestead.match_type (id_match_type, name, discription) VALUES (2, '5x5s', 'special 5x5');

# Создание типов действий в истории матчей

# Создание матчей и их истории