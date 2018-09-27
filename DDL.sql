# Скрипты должны выполняться в уже созданной БД
# Создание таблицы character - персонажи
create table `character`
(
  id_character int auto_increment
    primary key,
  id_player int not null,
  id_character_type smallint(6) not null,
  param1 smallint(6) not null,
  param2 smallint(6) not null,
  param3 smallint(6) not null,
  created datetime not null,
  modified datetime not null
)
;
# Создание таблицы character_history - история изменения персонажей
create table character_history
(
  id_character_history int not null
    primary key,
  param1 smallint(6) not null,
  param2 smallint(6) not null,
  param3 smallint(6) not null,
  modified datetime not null
)
;
# Создание таблицы character_type - тип персонажа, базовые статы и тд
create table character_type
(
  id_character_type int auto_increment
    primary key,
  name varchar(20) not null,
  discription varchar(200) not null,
  base_param1 smallint(6) not null,
  base_param2 smallint(6) not null,
  base_param3 smallint(6) not null
)
;
# Создание таблицы match - матчи
create table `match`
(
  id_match int auto_increment
    primary key,
  id_match_type smallint(6) not null,
  team1 varchar(200) not null comment 'JSON',
  team2 varchar(200) not null comment 'JSON',
  match_result varchar(200) not null comment 'JSON',
  started datetime not null,
  finished datetime not null
)
;
# Создание таблицы match_history - история матча, какие событи когда произошли
create table match_history
(
  id_match_history int auto_increment
    primary key,
  id_match int not null,
  id_character int not null,
  id_match_history_action int not null,
  created datetime not null
)
;
# Создание таблицы match_history_action - действия вносимые в историю матча, убийство, ачивка, поражение и тд
create table match_history_action
(
  id_match_history_action int auto_increment
    primary key,
  name varchar(20) not null,
  discription varchar(200) not null
)
;
# Создание таблицы match_type - тип матча 2х2, 5х5 и тд
create table match_type
(
  id_match_type smallint(6) auto_increment
    primary key,
  name varchar(20) not null,
  discription varchar(200) not null
)
;
# Создание таблицы player - игрок, уровень, рейтинг и тд
create table player
(
  id_player int auto_increment
    primary key,
  level tinyint default '1' not null,
  rating smallint(6) default '0' not null,
  created datetime not null,
  modified datetime not null
)
;
# Создание таблицы player_achievement - ачивки (не) полученные игроком
create table player_achievement
(
  id int auto_increment
    primary key,
  achievement1 binary(1) default '0' not null,
  achievement2 binary(1) default '0' not null,
  achievement3 binary(1) default '0' not null
)
;
# Создание таблицы player_history - история развития персонажа
create table player_history
(
  id_player_history int auto_increment
    primary key,
  id_player int not null,
  level tinyint not null,
  rating smallint(6) not null,
  modified datetime not null
)
;
# Создание таблицы player_autorisation - авторизация игрока
create table player_autorisation
(
  id_player_autorisation int auto_increment
    primary key,
  id_player int not null,
  full_name varchar(32) default '' not null,
  email varchar(32) default '' not null,
  login varchar(20) charset utf8 default '' not null,
  password varchar(32) default '' not null,
  created datetime not null,
  constraint username
  unique (login)
)
  engine=MyISAM collate=utf8_unicode_ci
;



