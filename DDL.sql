# Скрипты должны выполняться в уже созданной БД
# Создание таблицы character - персонажи

DROP TABLE IF EXISTS `character`;
create table `character`
(
  id_character      int auto_increment
    primary key,
  id_player         int         not null,
  id_character_type smallint(6) not null,
  param1            smallint(6) not null,
  param2            smallint(6) not null,
  param3            smallint(6) not null,
  created           datetime    not null,
  modified          datetime    not null,
  lastActivity      datetime    not null
);

create trigger character_AFTER_INSERT
  after INSERT
  on `character`
  for each row
  BEGIN
    INSERT INTO character_history
    Set
      id_character = NEW.id_character, param1 = NEW.param1,
      param2       = NEW.param1, param3 = NEW.param1, modified = NEW.modified;
  END;

create trigger character_BEFORE_UPDATE
  after UPDATE
  on `character`
  for each row
  BEGIN
    if OLD.param1 != NEW.param1 OR
       OLD.param2 != NEW.param2 OR
       OLD.param3 != NEW.param3
    THEN
      INSERT INTO character_history
      Set
        id_character = NEW.id_character, param1 = NEW.param1,
        param2       = NEW.param1, param3 = NEW.param1, modified = NEW.modified;
    END IF;
  END;

# Создание таблицы character_history - история изменения персонажей
DROP TABLE IF EXISTS `character_history`;
create table character_history
(
  id_character_history int auto_increment not null,
  id_character         int                not null,
  param1               smallint(6)        not null,
  param2               smallint(6)        not null,
  param3               smallint(6)        not null,
  modified             datetime           not null,
  UNIQUE KEY `fld_id` (id_character_history, id_character)
)
  PARTITION BY HASH (id_character)
  PARTITIONS 10;

# Создание таблицы character_type - тип персонажа, базовые статы и тд
DROP TABLE IF EXISTS `character_type`;
create table character_type
(
  id_character_type int auto_increment
    primary key,
  name              varchar(20)  not null,
  discription       varchar(200) not null,
  base_param1       smallint(6)  not null,
  base_param2       smallint(6)  not null,
  base_param3       smallint(6)  not null
);
# Создание таблицы match - матчи
DROP TABLE IF EXISTS `match`;
create table `match`
(
  id_match      int auto_increment,
  id_match_type smallint(6) not null,
  character1    int         not null,
  character2    int         not null,
  score1        int         not null,
  score2        int         not null,
  started       datetime    not null,
  finished      datetime    not null,
  UNIQUE KEY `fld_id` (id_match, started)
)
  PARTITION BY RANGE ( YEAR(started) ) (
  PARTITION p_old VALUES LESS THAN (2017),
  PARTITION p_previos VALUES LESS THAN (2018),
  PARTITION p_now VALUES LESS THAN ( MAXVALUE )
  );
# Создание таблицы match_history - история матча, какие событи когда произошли
DROP TABLE IF EXISTS `match_history`;
create table match_history
(
  id_match_history        int auto_increment,
  id_match                int      not null,
  id_character            int      not null,
  id_match_history_action int      not null,
  created                 datetime not null,
  UNIQUE KEY `fld_id` (id_match_history, id_match)
)
  PARTITION BY HASH (id_match)
  PARTITIONS 10;
create trigger match_history_AFTER_INSERT
  after INSERT
  on match_history
  for each row
  BEGIN
    UPDATE `character`
    SET lastActivity = (SELECT created
                        FROM match_history
                        ORDER BY id_match_history DESC
                        LIMIT 1);
  END;

# Создание таблицы match_history_action - действия вносимые в историю матча, убийство, ачивка, поражение и тд
DROP TABLE IF EXISTS `match_history_action`;
create table match_history_action
(
  id_match_history_action int auto_increment
    primary key,
  name                    varchar(20)  not null,
  discription             varchar(200) not null
);
# Создание таблицы match_type - тип матча 2х2, 5х5 и тд
DROP TABLE IF EXISTS `match_type`;
create table match_type
(
  id_match_type smallint(6) auto_increment
    primary key,
  name          varchar(20)  not null,
  discription   varchar(200) not null
);
# Создание таблицы player - игрок, уровень, рейтинг и тд
DROP TABLE IF EXISTS `player`;
create table player
(
  id_player    int auto_increment,
  nickname     varchar(20)             not null,
  level        tinyint default '1'     not null,
  rating       smallint(6) default '0' not null,
  created      datetime                not null,
  modified     datetime                not null,
  lastActivity datetime                not null,
  UNIQUE KEY `fld_id` (id_player, lastActivity)
)
  PARTITION BY RANGE ( YEAR(lastActivity) ) (
  PARTITION p_old VALUES LESS THAN (2017),
  PARTITION p_previos VALUES LESS THAN (2018),
  PARTITION p_now VALUES LESS THAN ( MAXVALUE )
  );

create trigger player_AFTER_INSERT
  after INSERT
  on player
  for each row
  BEGIN
    INSERT INTO player_achievement
    Set
      id_player = NEW.id_player;
    INSERT INTO player_history
    Set
      id_player = NEW.id_player,
      nickname  = NEW.nickname,
      level     = NEW.level,
      rating    = NEW.rating,
      modified  = NOW();
  END;

create trigger player_AFTER_UPDATE
  after UPDATE
  on player
  for each row
  BEGIN
    INSERT INTO player_history
    Set
      id_player = NEW.id_player,
      nickname  = NEW.nickname,
      level     = NEW.level,
      rating    = NEW.rating,
      modified  = NOW();
  END;

# Создание таблицы player_achievement - ачивки (не) полученные игроком
DROP TABLE IF EXISTS `player_achievement`;
create table player_achievement
(
  id_player_achievement int auto_increment
    primary key,
  id_player             int                   not null,
  achievement1          binary(1) default '0' not null,
  achievement2          binary(1) default '0' not null,
  achievement3          binary(1) default '0' not null
);
# Создание таблицы player_history - история развития персонажа
DROP TABLE IF EXISTS `player_history`;
create table player_history
(
  id_player_history int auto_increment,
  id_player         int         not null,
  nickname          varchar(20) not null,
  level             tinyint     not null,
  rating            smallint(6) not null,
  modified          datetime    not null,
  UNIQUE KEY `fld_id` (id_player_history, id_player)
)
  PARTITION BY HASH (id_player)
  PARTITIONS 10;
# Создание таблицы player_autorisation - авторизация игрока
DROP TABLE IF EXISTS `player_autorisation`;
create table player_autorisation
(
  id_player_autorisation int auto_increment
    primary key,
  id_player              int                                 not null,
  full_name              varchar(32) default ''              not null,
  email                  varchar(32) default ''              not null,
  login                  varchar(20) charset utf8 default '' not null,
  password               varchar(32) default ''              not null,
  created                datetime                            not null,
  constraint username
  unique (login)
)
  engine = MyISAM
  collate = utf8_unicode_ci;


create trigger player_autorisation_BEFORE_INSERT
  before INSERT
  on player_autorisation
  for each row
  BEGIN
    Set
    NEW.full_name =md5(NEW.full_name),
    NEW.password =md5(NEW.password);
  END;

# Выбрать по 3 часто используемых персонажа у трёх игроков с наивысшим рейтингом;
# пока выбираются все персонажи, не знаю как ограничить
drop procedure IF EXISTS get_3_character_from_3_highest_rating;
CREATE PROCEDURE `get_3_character_from_3_highest_rating`()
  BEGIN
    DROP TABLE IF EXISTS `time_table_for_get_3_character_from_3_highest_rating`;
    create table time_table_for_get_3_character_from_3_highest_rating
    (
      id_character      int,
      id_player         int,
      id_character_type smallint(6),
      param1            smallint(6),
      param2            smallint(6),
      param3            smallint(6),
      created           datetime,
      modified          datetime,
      lastActivity      datetime,
      countMatch        int
    );
    INSERT INTO time_table_for_get_3_character_from_3_highest_rating
      SELECT ch.*
      FROM (SELECT *
            FROM player AS pl
            ORDER BY pl.rating DESC
            LIMIT 3) AS HR
        LEFT JOIN (SELECT
                     *,
                     (
                       SELECT COUNT(*)
                       FROM `match`
                       WHERE character1 = ch.id_character OR character2 = ch.id_character
                     ) AS countMatch
                   FROM `character` AS ch
                   ORDER BY countMatch DESC) AS ch ON ch.id_player = HR.id_player
      ORDER BY ch.id_player, ch.countMatch DESC;

    (SELECT *
     FROM time_table_for_get_3_character_from_3_highest_rating AS sub
     WHERE sub.id_player = (SELECT id_player
                            FROM time_table_for_get_3_character_from_3_highest_rating AS sub
                            GROUP BY id_player
                            LIMIT 1)
     LIMIT 3)
    UNION
    (SELECT *
     FROM time_table_for_get_3_character_from_3_highest_rating AS sub
     WHERE sub.id_player = (SELECT id_player
                            FROM time_table_for_get_3_character_from_3_highest_rating AS sub
                            GROUP BY id_player
                            LIMIT 1 OFFSET 1)
     LIMIT 3)
    UNION
    (SELECT *
     FROM time_table_for_get_3_character_from_3_highest_rating AS sub
     WHERE sub.id_player = (SELECT id_player
                            FROM time_table_for_get_3_character_from_3_highest_rating AS sub
                            GROUP BY id_player
                            LIMIT 1 OFFSET 2)
     LIMIT 3);
  END;
# Вывести , длительность и результаты 10 последних матчей игрока(input parameter).

drop procedure IF EXISTS get_10_last_matches_for_player;
CREATE procedure get_10_last_matches_for_player(IN p1 int)
  BEGIN
    SELECT
      IF(character1 IN (SELECT id_character
                        FROM `character`
                        WHERE id_player = p1), character1, m.character2)   AS `персонаж`,
      DATE(m.started)                                                      AS `дата`,
      CONCAT(FLOOR(TIME_TO_SEC(TIMEDIFF(m.finished, m.started)) / 60), ' минут ',
             TIME_TO_SEC(TIMEDIFF(m.finished, m.started)) % 60, ' секунд') AS `длительность`,
      CONCAT(IF(character1 IN (SELECT id_character
                               FROM `character`
                               WHERE id_player = p1), m.score1, m.score2),
             '|',
             IF(character1 IN (SELECT id_character
                               FROM `character`
                               WHERE id_player = p1), m.score2, m.score1)) AS `результат (игрок|соперник)`
    FROM `match` AS m
    WHERE character1 IN (SELECT id_character
                         FROM `character`
                         WHERE id_player = p1)
          OR character2 IN (SELECT id_character
                            FROM `character`
                            WHERE id_player = p1)
    ORDER BY m.started DESC
    LIMIT 10;
  END;

#Выбрать персонажа с наивысшим соотношением убийства/смерти за последний год по месяцам в разрезе уровней игроков;
drop procedure IF EXISTS get_kill_killed_table;
CREATE procedure get_kill_killed_table(IN year int)
  BEGIN
    DROP TABLE IF EXISTS `time_table_for_get_kill_killed_table`;
    create table time_table_for_get_kill_killed_table
    (
      id_character int,
      level        int,
      level_group  int,
      month        int,
      score        DOUBLE,
      kills        int
    );
    INSERT INTO time_table_for_get_kill_killed_table (id_character, level, level_group, month, score, kills)

      SELECT
        MH.id_character,
        (SELECT PL.level
         FROM `character` AS CH
           INNER JOIN player AS PL
             ON PL.id_player = CH.id_player
         WHERE CH.id_character = MH.id_character)            AS `level`,
        FLOOR((SELECT PL.level
               FROM `character` AS CH
                 INNER JOIN player AS PL
                   ON PL.id_player = CH.id_player
               WHERE CH.id_character = MH.id_character) / 2) AS `level_group`,
        MONTH(MH.created)                                    AS `month`,
        (
          SUM(IF(MH.id_match_history_action = 1, 1, 0)) /
          SUM(IF(MH.id_match_history_action IN (2, 3), 1, 0))
        )                                                    AS `score`,
        SUM(IF(MH.id_match_history_action = 1, 1, 0))        AS `kills`
      FROM match_history AS MH
      WHERE MH.created > CONCAT(year, '-00-00')
      GROUP BY MONTH(MH.created), MH.id_character
      ORDER BY MONTH(MH.created);

    #     SELECT id_character,level_group,month
    #     FROM time_table_for_get_kill_killed_table
    #     GROUP BY level_group,month
    #     ORDER BY score DESC;
    SELECT
      CONCAT(level_group * 2, "-", level_group * 2 + 1) AS `группа`,
      (SELECT CONCAT('персонаж: ', sub.id_character, ' убийств/смертей: ', sub.score, ' убийств: ', sub.kills)
       FROM time_table_for_get_kill_killed_table AS sub
       WHERE sub.level_group = main.level_group AND sub.month = 1
       ORDER BY sub.score DESC, sub.kills DESC
       LIMIT 1)                                         AS `месяц 1`,
      (SELECT CONCAT('персонаж: ', sub.id_character, ' убийств/смертей: ', sub.score, ' убийств: ', sub.kills)
       FROM time_table_for_get_kill_killed_table AS sub
       WHERE sub.level_group = main.level_group AND sub.month = 2
       ORDER BY sub.score DESC, sub.kills DESC
       LIMIT 1)                                         AS `месяц 2`,
      (SELECT CONCAT('персонаж: ', sub.id_character, ' убийств/смертей: ', sub.score, ' убийств: ', sub.kills)
       FROM time_table_for_get_kill_killed_table AS sub
       WHERE sub.level_group = main.level_group AND sub.month = 3
       ORDER BY sub.score DESC, sub.kills DESC
       LIMIT 1)                                         AS `месяц 3`,
      (SELECT CONCAT('персонаж: ', sub.id_character, ' убийств/смертей: ', sub.score, ' убийств: ', sub.kills)
       FROM time_table_for_get_kill_killed_table AS sub
       WHERE sub.level_group = main.level_group AND sub.month = 4
       ORDER BY sub.score DESC, sub.kills DESC
       LIMIT 1)                                         AS `месяц 4`,
      (SELECT CONCAT('персонаж: ', sub.id_character, ' убийств/смертей: ', sub.score, ' убийств: ', sub.kills)
       FROM time_table_for_get_kill_killed_table AS sub
       WHERE sub.level_group = main.level_group AND sub.month = 5
       ORDER BY sub.score DESC, sub.kills DESC
       LIMIT 1)                                         AS `месяц 5`,
      (SELECT CONCAT('персонаж: ', sub.id_character, ' убийств/смертей: ', sub.score, ' убийств: ', sub.kills)
       FROM time_table_for_get_kill_killed_table AS sub
       WHERE sub.level_group = main.level_group AND sub.month = 6
       ORDER BY sub.score DESC, sub.kills DESC
       LIMIT 1)                                         AS `месяц 6`,
      (SELECT CONCAT('персонаж: ', sub.id_character, ' убийств/смертей: ', sub.score, ' убийств: ', sub.kills)
       FROM time_table_for_get_kill_killed_table AS sub
       WHERE sub.level_group = main.level_group AND sub.month = 7
       ORDER BY sub.score DESC, sub.kills DESC
       LIMIT 1)                                         AS `месяц 7`,
      (SELECT CONCAT('персонаж: ', sub.id_character, ' убийств/смертей: ', sub.score, ' убийств: ', sub.kills)
       FROM time_table_for_get_kill_killed_table AS sub
       WHERE sub.level_group = main.level_group AND sub.month = 8
       ORDER BY sub.score DESC, sub.kills DESC
       LIMIT 1)                                         AS `месяц 8`,
      (SELECT CONCAT('персонаж: ', sub.id_character, ' убийств/смертей: ', sub.score, ' убийств: ', sub.kills)
       FROM time_table_for_get_kill_killed_table AS sub
       WHERE sub.level_group = main.level_group AND sub.month = 9
       ORDER BY sub.score DESC, sub.kills DESC
       LIMIT 1)                                         AS `месяц 9`,
      (SELECT CONCAT('персонаж: ', sub.id_character, ' убийств/смертей: ', sub.score, ' убийств: ', sub.kills)
       FROM time_table_for_get_kill_killed_table AS sub
       WHERE sub.level_group = main.level_group AND sub.month = 10
       ORDER BY sub.score DESC, sub.kills DESC
       LIMIT 1)                                         AS `месяц 10`,
      (SELECT CONCAT('персонаж: ', sub.id_character, ' убийств/смертей: ', sub.score, ' убийств: ', sub.kills)
       FROM time_table_for_get_kill_killed_table AS sub
       WHERE sub.level_group = main.level_group AND sub.month = 11
       ORDER BY sub.score DESC, sub.kills DESC
       LIMIT 1)                                         AS `месяц 11`,
      (SELECT CONCAT('персонаж: ', sub.id_character, ' убийств/смертей: ', sub.score, ' убийств: ', sub.kills)
       FROM time_table_for_get_kill_killed_table AS sub
       WHERE sub.level_group = main.level_group AND sub.month = 12
       ORDER BY sub.score DESC, sub.kills DESC
       LIMIT 1)                                         AS `месяц 12`
    FROM time_table_for_get_kill_killed_table AS main
    GROUP BY level_group;


    DROP TABLE IF EXISTS `time_table_for_get_kill_killed_table`;
  END;

# Архивирование

# Архивирование в отдельную таблицу игроков, давно не заходивших в игру*;
DROP TABLE IF EXISTS `archive_player`;
create table archive_player
(
  id_player    int auto_increment,
  nickname     varchar(20)             not null,
  level        tinyint default '1'     not null,
  rating       smallint(6) default '0' not null,
  created      datetime                not null,
  modified     datetime                not null,
  lastActivity datetime                not null,
  UNIQUE KEY `fld_id` (id_player, lastActivity)
)
  PARTITION BY RANGE ( YEAR(lastActivity) ) (
  PARTITION p_old VALUES LESS THAN (2017),
  PARTITION p_previos VALUES LESS THAN (2018),
  PARTITION p_now VALUES LESS THAN ( MAXVALUE )
  );
DROP TABLE IF EXISTS `archive_player_achievement`;
create table archive_player_achievement
(
  id_player_achievement int auto_increment
    primary key,
  id_player             int                   not null,
  achievement1          binary(1) default '0' not null,
  achievement2          binary(1) default '0' not null,
  achievement3          binary(1) default '0' not null
);
DROP TABLE IF EXISTS `archive_player_history`;
create table archive_player_history
(
  id_player_history int auto_increment,
  id_player         int         not null,
  nickname          varchar(20) not null,
  level             tinyint     not null,
  rating            smallint(6) not null,
  modified          datetime    not null,
  UNIQUE KEY `fld_id` (id_player_history, id_player)
)
  PARTITION BY HASH (id_player)
  PARTITIONS 10;

drop procedure IF EXISTS store_archive_player_activity_less_then;
CREATE procedure store_archive_player_activity_less_then(IN date DATETIME)
  BEGIN
    SET @Data=date;
    #     Архивирование ачивок
    INSERT INTO archive_player_achievement SELECT *
                                           FROM player_achievement AS pa
                                           WHERE (SELECT lastActivity
                                                  FROM player
                                                  WHERE player.id_player = pa.id_player) < @Data;
    DELETE FROM player_achievement
    WHERE (SELECT lastActivity
           FROM player
           WHERE player.id_player = id_player) < @Data;
    #     Архивирование истории
    INSERT INTO archive_player_history SELECT *
                                       FROM player_history AS ph
                                       WHERE (SELECT lastActivity
                                              FROM player
                                              WHERE player.id_player = ph.id_player) < @Data;
    DELETE FROM player_history
    WHERE (SELECT lastActivity
           FROM player
           WHERE player.id_player = id_player) < @Data;
    #     Архивирование игрока
    INSERT INTO archive_player SELECT *
                               FROM player
                               WHERE player.lastActivity < @Data;
    DELETE FROM player
    WHERE player.lastActivity < @Data;
  END;

#Архивирование в отдельную таблицу результатов матчей*.
DROP TABLE IF EXISTS `archive_match`;
create table `archive_match`
(
  id_match      int auto_increment,
  id_match_type smallint(6) not null,
  character1    int         not null,
  character2    int         not null,
  score1        int         not null,
  score2        int         not null,
  started       datetime    not null,
  finished      datetime    not null,
  UNIQUE KEY `fld_id` (id_match, started)
)
  PARTITION BY RANGE ( YEAR(started) ) (
  PARTITION p_old VALUES LESS THAN (2017),
  PARTITION p_previos VALUES LESS THAN (2018),
  PARTITION p_now VALUES LESS THAN ( MAXVALUE )
  );
DROP TABLE IF EXISTS `archive_match_history`;
create table archive_match_history
(
  id_match_history        int auto_increment,
  id_match                int      not null,
  id_character            int      not null,
  id_match_history_action int      not null,
  created                 datetime not null,
  UNIQUE KEY `fld_id` (id_match_history, id_match)
)
  PARTITION BY HASH (id_match)
  PARTITIONS 10;

drop procedure IF EXISTS store_archive_match_started_less_then;
CREATE procedure store_archive_match_started_less_then(IN date DATETIME)
  BEGIN
    #     Архивирование истории матча
    INSERT INTO archive_match_history (SELECT *
                                      FROM match_history AS MH
                                      WHERE (SELECT started
                                             FROM `match`
                                             WHERE `match`.id_match = MH.id_match) < date);
    DELETE FROM match_history
    WHERE (SELECT started
           FROM `match`
           WHERE `match`.id_match = id_match) < '2015-01-01';
    #     Архивирование матча
    INSERT INTO archive_match (SELECT *
                              FROM `match`
                              WHERE `match`.started < date);
    DELETE FROM `match`
    WHERE `match`.started < date;
  END;


