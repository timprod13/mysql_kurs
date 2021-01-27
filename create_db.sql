DROP DATABASE IF EXISTS fitness_club;
CREATE DATABASE fitness_club;
USE fitness_club;

DROP TABLE IF EXISTS users; -- таблица с данными пользователей
CREATE TABLE users (
	id SERIAL PRIMARY KEY COMMENT 'Является как id пользователя, так и номером клубной карты', 
    firstname VARCHAR(50) COMMENT 'Имя',
    lastname VARCHAR(50) COMMENT 'Фамилия',
    email VARCHAR(120) UNIQUE COMMENT 'e-mail',
 	password_hash VARCHAR(100) COMMENT 'Пароль',
	phone BIGINT UNSIGNED UNIQUE COMMENT 'Номер телефона', 
	INDEX users_firstname_lastname_idx(firstname, lastname)
)

DROP TABLE IF EXISTS profiles; -- таблица с расширенными данными пользователей
CREATE TABLE profiles (
	user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    gender CHAR(1) COMMENT 'Пол',
    birthday DATE COMMENT 'День рождения',
	photo_id BIGINT UNSIGNED NULL COMMENT 'id фотографии',
    created_at DATETIME DEFAULT NOW() COMMENT 'Дата создания профиля'
);

ALTER TABLE profiles ADD CONSTRAINT fk_user_id -- прописываем зависимость id профилей от id пользователей 
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE 
    ON DELETE RESTRICT;

DROP TABLE IF EXISTS subscriptions; -- таблица с данными о клубных картах
CREATE TABLE subscriptions (
	user_id BIGINT UNSIGNED NOT NULL UNIQUE,
	card_num BIGINT UNSIGNED COMMENT 'Номер клубной карты',
    `status` ENUM('gym', 'pool', 'full', 'family') COMMENT 'Тип клубной карты пользователя',
    expire_date DATETIME NOT NULL COMMENT 'Дата окончания действия клубной карты'
);   

ALTER TABLE subscriptions ADD CONSTRAINT fc_user_id -- прописываем зависимость id клубных карт от id пользователей 
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE 
    ON DELETE RESTRICT;
   
DROP TABLE IF EXISTS messages; -- таблица общения внутри системы членов клуба с преподавателями и между собой 
CREATE TABLE messages (
	id SERIAL, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
	from_user_id BIGINT UNSIGNED NOT NULL COMMENT 'id отправителя',
    to_user_id BIGINT UNSIGNED NOT NULL COMMENT 'id получателя',
    body TEXT COMMENT 'Текст сообщения',
    -- дописать строку включения медиафайлов в сообщение
    created_at DATETIME DEFAULT NOW() COMMENT 'Время создания сообщения', -- можно будет даже не упоминать это поле при вставке
    FOREIGN KEY (from_user_id) REFERENCES users(id),
    FOREIGN KEY (to_user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS sections; -- таблица с секциями и преподавателями в качестве администраторов
CREATE TABLE sections(
	id SERIAL,
	name VARCHAR(150),
	admin_user_id BIGINT UNSIGNED NOT NULL,
	INDEX sections_name_idx(name),
	foreign key (admin_user_id) references users(id)
);

DROP TABLE IF EXISTS users_sections; -- таблица с указанием, в какую секцию записан пользователь
CREATE TABLE users_sections(
	user_id BIGINT UNSIGNED NOT NULL,
	section_id BIGINT UNSIGNED NOT NULL,
  	PRIMARY KEY (user_id, section_id), -- чтобы не было двух записей о пользователе и секции
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (section_id) REFERENCES sections(id)
);

DROP TABLE IF EXISTS media_types; -- таблица для хранения данных о типах медиафайлов
CREATE TABLE media_types(
	id SERIAL,
    name VARCHAR(255), 
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS media; -- таблица для хранения данных о медиафайлах
CREATE TABLE media(
	id SERIAL,
    media_type_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
  	body text,
    filename VARCHAR(255),
    -- file blob,    	
    size INT,
	metadata JSON,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (media_type_id) REFERENCES media_types(id)
);

-- по идее нужно ещё ставить оценки тренерам?

DROP TABLE IF EXISTS `photo_albums`; -- фотоальбомы для "выкладывания" фото с занятий, соревнований
CREATE TABLE `photo_albums` (
	`id` SERIAL,
	`name` varchar(255) DEFAULT NULL,
    `user_id` BIGINT UNSIGNED DEFAULT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
  	PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `photos`;
CREATE TABLE `photos` (
	id SERIAL,
	`album_id` BIGINT UNSIGNED NULL,
	`media_id` BIGINT UNSIGNED NOT NULL,

	FOREIGN KEY (album_id) REFERENCES photo_albums(id),
    FOREIGN KEY (media_id) REFERENCES media(id)
);

ALTER TABLE fitness_club.profiles 
ADD CONSTRAINT profiles_fk_1 
FOREIGN KEY (photo_id) REFERENCES media(id);

DROP TABLE IF EXISTS news_poll; -- таблица новостной ленты  
CREATE TABLE news_poll (
	id SERIAL, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
	news_user_id BIGINT UNSIGNED NOT NULL COMMENT 'id пользователя, написавшего новость',
    body TEXT COMMENT 'Текст новости',
    media_id BIGINT UNSIGNED NOT NULL COMMENT 'Иллюстрация к новости',
    created_at DATETIME DEFAULT NOW() COMMENT 'Время создания новости',
    FOREIGN KEY (news_user_id) REFERENCES users(id),
    FOREIGN KEY (media_id) REFERENCES media(id)
);

DROP TABLE IF EXISTS reviews; -- таблица с отзывами пользователей
CREATE TABLE reviews (
	id SERIAL, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
	review_user_id BIGINT UNSIGNED NOT NULL COMMENT 'id пользователя, написавшего отзыв',
    body TEXT COMMENT 'Текст отзыва',
    created_at DATETIME DEFAULT NOW() COMMENT 'Время создания отзыва',
    FOREIGN KEY (review_user_id) REFERENCES users(id)
);

