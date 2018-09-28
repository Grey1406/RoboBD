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
  lastActivity      varchar(45) null
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

create trigger character_AFTER_UPDATE
  after UPDATE
  on `character`
  for each row
  BEGIN
    INSERT INTO character_history
    Set
      id_character = NEW.id_character, param1 = NEW.param1,
      param2       = NEW.param1, param3 = NEW.param1, modified = NEW.modified;
  END;

# Создание таблицы character_history - история изменения персонажей
DROP TABLE IF EXISTS `character_history`;
create table character_history
(
  id_character_history int auto_increment not null
    primary key,
  id_character         int                null,
  param1               smallint(6)        not null,
  param2               smallint(6)        not null,
  param3               smallint(6)        not null,
  modified             datetime           not null
);

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
  id_match      int auto_increment
    primary key,
  id_match_type smallint(6) not null,
  character1    int         not null,
  character2    int         not null,
  score1        int         not null,
  score2        int         not null,
  started       datetime    not null,
  finished      datetime    not null
);
# Создание таблицы match_history - история матча, какие событи когда произошли
DROP TABLE IF EXISTS `match_history`;
create table match_history
(
  id_match_history        int auto_increment
    primary key,
  id_match                int      not null,
  id_character            int      not null,
  id_match_history_action int      not null,
  created                 datetime not null
);
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
  id_player    int auto_increment
    primary key,
  nickname     varchar(20)             not null,
  level        tinyint default '1'     not null,
  rating       smallint(6) default '0' not null,
  created      datetime                not null,
  modified     datetime                not null,
  lastActivity datetime                null
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
  id_player_history int auto_increment
    primary key,
  id_player         int         not null,
  nickname          varchar(20) not null,
  level             tinyint     not null,
  rating            smallint(6) not null,
  modified          datetime    not null
);
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



