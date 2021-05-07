use vk;
show TABLES;


-- Таблица лайков (Применим вариант с таблицей типов лайков)
-- Храним в ней экземпляры различных сущностей
DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,-- Автор лайка
  -- Что мы лайкаем. Задаем 2 значениями target_id и target_type
  target_id INT UNSIGNED NOT NULL,-- Идетификатор строки таблицы необходимой сущности
  target_type ENUM('messages', 'users', 'posts', 'media') NOT NULL, -- определяет в какой таблице находится строка на которую ссылаеся target_id
  /*
  ENUM- это строковый объект со значением, выбранным из списка разрешенных значений, 
  которые явно перечислены в спецификации столбца во время создания таблицы.
  Значение перечисления должно быть строковым литералом в кавычках. 
  */
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
desc likes;

/*Создание данные без генератора (фейкера). 
Что бы, откуда то брать значения ИМЕН таблиц: 'messages', 'users', 'posts', 'media'
Создадим ВРЕМЕННeую таблицу типов лайков. Она нам нужна только для того что бы 
заполнить табл. ЛАЙКОВ тестовыми данными */

DROP TABLE IF EXISTS target_types;
CREATE TEMPORARY TABLE target_types (
  name VARCHAR(100) NOT NULL UNIQUE
);
desc target_types;
INSERT INTO target_types (name) VALUES 
  ('messages'),
  ('users'),
  ('media'),
  ('posts');
select * from target_types;
 
-- Заполняем лайки (Финальный запрос)
INSERT INTO likes 
/*Вставляем в таблицу те данные, которые сгенерирует 
запрос SELECT к таблице messages (все строки ниже), для получения id. В рез-те создается столько же строк в таблице likes 
сколько и в табл. messages */
  SELECT 
    id, 
    FLOOR(1 + (RAND() * 100)), 
    FLOOR(1 + (RAND() * 100)),
    (SELECT name FROM target_types ORDER BY RAND() LIMIT 1),
    CURRENT_TIMESTAMP 
  FROM messages;

-- Проверим
SELECT * FROM likes LIMIT 10;

-- Создаем Внешние Ключи
desc likes; 
alter TABLE likes
ADD CONSTRAINT likes_user_id_fk
foreign KEY (user_id) REFERENCES users(id)
on delete CASCADE;


-- Создадим таблицу ПОСТОВ
DROP TABLE IF EXISTS posts;
CREATE TABLE posts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,-- Автор поста
  community_id INT UNSIGNED,-- Ссылка на community, если пост создается (принадлежит) от лица community
  head VARCHAR(255),-- Заголовок поста
  body TEXT NOT NULL,-- -- Тело поста
  media_id INT UNSIGNED, -- Ссылка, на прикрепляемый медиафайл (один). Если нужно больше, то надо создать таблицу связей
  -- Два флага (публичность и архивированность этого поста)
  -- Флаги mysql используются компилятором и устанавливают среду, в которой вы хотите работать.
  is_public BOOLEAN DEFAULT TRUE,
  is_archived BOOLEAN DEFAULT FALSE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

SELECT * FROM posts LIMIT 10;-- СОЗДАТЬ ДАННЫЕ в Фейке

-- Создаем Внешние Ключи
desc posts; 
alter TABLE posts
ADD CONSTRAINT posts_user_id_fk
foreign KEY (user_id) REFERENCES users(id)
on delete CASCADE;

desc posts; 
alter TABLE posts
ADD CONSTRAINT posts_community_id_fk
foreign KEY (community_id) REFERENCES communities(id)
on delete CASCADE;

desc posts; 
alter TABLE posts
ADD CONSTRAINT posts_media_id_fk
foreign KEY (media_id) REFERENCES media(id)
on delete CASCADE;

-- Таблица users
desc users;
select * from users;
select  * from users where created_at > update_at;-- Используем фильтр для поиска дат update более ранних чем дата created
update users set update_at = NOW() where created_at > update_at; -- Запрос на ОБНОВЛЕНИЕ


-- Таблица profiles Создаем Внешние Ключи
desc profiles;
select * from profiles limit 100;
alter TABLE profiles
ADD CONSTRAINT profiles_user_id_fk
foreign KEY (user_id) REFERENCES users(id)
on delete CASCADE;

select * from profiles limit 100;
select  * from profiles where created_at > update_at;-- Используем фильтр для поиска дат update более ранних чем дата created
update profiles set update_at = NOW() where created_at > update_at; -- Запрос на ОБНОВЛЕНИЕ
-- update profiles set gender = '';
-- CREATE temporary table genders (name CHAR(1));
-- insert into genders values ('F'), ('M');
-- select * from genders;
-- select name from genders order BY RAND() limit 1; -- Получить значения пола F и M случайным образом
-- update profiles set gender = (select name from genders order BY RAND() limit 1); -- Запрос на ОБНОВЛЕНИЕ


-- Таблица messages Создаем Внешние Ключи
desc messages;
select * from messages;
alter TABLE messages
add CONSTRAINT messages_from_user_id_fk
foreign KEY (from_user_id) REFERENCES users(id)
on delete cascade,
add CONSTRAINT messages_to_user_id_fk
foreign KEY (to_user_id) REFERENCES users(id)
on delete CASCADE;

select * from messages limit 10;
-- select FLOOR (1 + RAND() * 100);-- Генерация случайного целого числа RAND(). FLOOR-избавляет от дробной части.
-- update messages set -- Запрос на обновление
-- from_user_id = FLOOR (1 + RAND() * 100),
-- to_user_id = FLOOR (1 + RAND() * 100);
-- Если from_user_id и to_user_id СЛУЧАЙНО СОВПАЛИ
-- select * from messages where from_user_id = to_user_id;
-- update messages set to_user_id = to_user_id + 1 where from_user_id = to_user_id;


-- Таблица media Создаем Внешние Ключи
desc media;
select * from media limit 10;
alter TABLE media
ADD CONSTRAINT media_user_id_fk
foreign KEY (user_id) REFERENCES users(id)
on delete CASCADE;
-- update media set
-- user_id = FLOOR (1 + RAND() * 100);

-- СТОЛБЕЦ filename 
-- Где взять расширение? 
-- http://dropbox.com/vk/filename.ext Прописываем путь: имяфайлаИЗтаблицы.случайное расширение
CREATE temporary table extensions (name VARCHAR(10)); -- Создаем ВРЕМЕННУЮ таблицу
insert into extensions values ('mp4'), ('mp3'), ('png'), ('avi');
select * from extensions;-- Временная таблица расширений создана
-- Компануем основной запрос 
update media  set filename = concat(
-- Функция concat объеденяет все свои параметры, перечисленные через ЗАПЯТУЮ в ОДНУ строку. Т.е. объеденяет 4 строки (см. следующие ниже) в одну.
'http://dropbox.com/vk/',
filename,
'.',
(select name from extensions order BY RAND() limit 1))-- строка расширения. Сами расширения см. во временной (extensions) таблице
;
select * from media limit 10;

-- СТОЛБЕЦ size
-- update media set size = FLOOR (1000 + RAND() * 1000000000 where sise < 10000);-- Нижняя граница в байтах - sise < 10000)

-- СТОЛБЕЦ metadata
-- Сюда помещае любой объект.
-- Должно получиться что-то вроде: '{"ouner": "Ferst Last"}', т.е. '{"КЛЮЧ": "ЗНАЧЕНИЕ - Имя Фамилия"}'
update media set metadata = CONCAT(
-- update media - запрос на обновление и вставляем (set) для столбца metadata ключ-значение ОДНУ строку из нескольких.
'{"ouner": "',
(select CONCAT(first_name, ' ', last_name) 
from users where users.id = media.user_id),
'"}'
);
select * from media limit 20;
desc media; -- Просмотр структуры таблицы 
alter table media modify COLUMN metadata JSON; -- См. 8-ю стр вебинара

-- Таблица media_types, СТОЛБЕЦ media_types_id
select * from media_types;
delete from media_types;
insert into media_types (name) values
('image'),
('audio'),
('video');
TRUNCATE media_types;
update media set;
media_type_id =FLOOR(1 + RAND() * 3);


-- Таблица frendship
select * from friendship limit 10;
-- update friendship set
-- user_id = FLOOR (1 + RAND() * 100),
-- friend_id = FLOOR (1 + RAND() * 100);
select * from friendshep_statuses;-- Видим 8 статусов. Много! Сделаем, и проименуем три
TRUNCATE friendshep_statuses;
insert into friendshep_statuses (name) values
('Requested'),
('Confirmed'),
('Rejected');
select * from friendship;
update friendship set
friend_status_id = FLOOR(1 + RAND() * 3);
update friendship  set -- См. 11-ю стр вебинара
confirmed_at = created_at,
created_at = confirmed_at;
-- WHERE user_id = 3 AND friend_id = 7;

-- Создаем Внешние Ключи
desc friendship;
select * from friendship limit 10;
alter TABLE friendship
ADD CONSTRAINT friendship_user_id_fk
foreign KEY (user_id) REFERENCES users(id)
on delete CASCADE;

desc friendship;
select * from friendship limit 10;
alter TABLE friendship
ADD CONSTRAINT friendship_friend_status_id_fk
foreign KEY (friend_status_id) REFERENCES friendshep_statuses(id)
on delete CASCADE;

desc friendship;
select * from friendship limit 10;
alter TABLE friendship
ADD CONSTRAINT friendship_friend_id_fk
foreign KEY (friend_id) REFERENCES users(id)
on delete CASCADE;


-- Таблица Групп (communities)
select * from communities;
-- DELETE from communities where id > 30;
select * from communities;
select  * from communities where created_at > update_at;-- Используем фильтр для поиска дат update более ранних чем дата created
update communities set update_at = NOW() where created_at > update_at; -- Запрос на ОБНОВЛЕНИЕ
desc communities;

-- Таблица Связи (communities_users)
select * from communities_users;
update communities_users set
user_id = FLOOR (1 + RAND() * 100),
communities_id = FLOOR (1 + RAND() * 30);

-- Создаем Внешние Ключи
desc communities_users;
select * from communities_users limit 10;
alter TABLE communities_users
ADD CONSTRAINT communities_users_communities_id_fk
foreign KEY (communities_id) REFERENCES communities(id)
on delete CASCADE;

-- Создаем Внешние Ключи
alter TABLE communities_users
ADD CONSTRAINT communities_users_users_id_fk
foreign KEY (users_id) REFERENCES users(id)
on delete CASCADE;

-- Таблица orders
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id)
) COMMENT = 'Заказы';

-- Создаем Внешние Ключи
desc orders;
select * from orders limit 10;
alter TABLE orders
ADD CONSTRAINT orders_user_id_fk
foreign KEY (user_id) REFERENCES users(id)
on delete CASCADE;

-- Таблица orders_products
DROP TABLE IF EXISTS orders_products;
CREATE TABLE orders_products (
  id SERIAL PRIMARY KEY,
  order_id BIGINT UNSIGNED,
  product_id INT UNSIGNED,
  total INT UNSIGNED DEFAULT 1 COMMENT 'Количество заказанных товарных позиций',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Состав заказа';

-- Создаем Внешние Ключи
desc orders_products;
select * from orders_products limit 10;
alter TABLE orders_products
ADD CONSTRAINT orders_products_order_id_fk
foreign KEY (order_id) REFERENCES orders(id)
on delete CASCADE;


-- Меняем тип данных BIGINT unsigned на INT unsigned 
ALTER TABLE orders_products MODIFY COLUMN id int unsigned;
desc storehouses;


-- Таблица storehouses_products
DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id BIGINT UNSIGNED,
  product_id BIGINT UNSIGNED,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Запасы на складе';

desc storehouses;
select * from storehouses limit 10;

-- СОРТИРОВКА записей, чтобы они выводились в порядке увеличения значения value
select * from storehouses_products limit 10;
select id, storehouse_id, product_id, value, created_at, updated_at
from storehouses_products
order by value;
-- Так же СОРТИРОВКА value, но значения НОЛЬ в конце таблицы
select * from storehouses_products
order by if(value > 0,0,1), value;



/*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Как я Вам и писал: 
Была таблица, но без данных, но с внешними ключами. Сгенерировал данные, сохранил в vk. 
В обоих редакторах данные в таблице вижу. Пытаюсь добавить Внешний ключ - Ошибка!
Вроде все перепроверил?
*/

-- Создаем Внешние Ключи
desc storehouses_products;
alter TABLE storehouses_products
ADD CONSTRAINT storehouses_products_storehouse_id_fk
foreign KEY (storehouse_id) REFERENCES storehouses(id)
on delete CASCADE;

desc storehouses_products;
alter TABLE storehouses_products
ADD CONSTRAINT storehouses_product_product_id_fk
foreign KEY (product_id) REFERENCES products(id)
on delete CASCADE;






-- Таблица discounts
DROP TABLE IF EXISTS discounts;
CREATE TABLE discounts (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  product_id BIGINT UNSIGNED,
  discount FLOAT UNSIGNED COMMENT 'Величина скидки от 0.0 до 1.0',
  started_at DATETIME,
  finished_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id),
  KEY index_of_product_id(product_id)
) COMMENT = 'Скидки';

-- Создаем Внешние Ключи
desc discounts;
desc users;
alter TABLE discounts
ADD CONSTRAINT discounts_user_id_fk
foreign KEY (user_id) REFERENCES users(id)
on delete CASCADE;

desc discounts;
alter TABLE discounts
ADD CONSTRAINT discounts_product_id_fk
foreign KEY (product_id) REFERENCES products(id)
on delete CASCADE;

desc catalogs;
-- Меняем тип данных BIGINT unsigned на INT unsigned 
ALTER TABLE catalogs MODIFY COLUMN id int unsigned;
select * from catalogs;
DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO catalogs VALUES
  (DEFAULT, 'Процессоры'),
  (DEFAULT, 'Мат.платы'),
  (DEFAULT, 'Видеокарты');
 
desc orders_products;
desc products;
-- Меняем тип данных BIGINT unsigned на INT unsigned 
ALTER TABLE orders_products MODIFY COLUMN product_id bigint unsigned;
-- Создаем Внешние Ключи
alter TABLE orders_products
ADD CONSTRAINT orders_products_product_id_fk
foreign KEY (product_id) REFERENCES products(id)
on delete CASCADE;

alter TABLE products
ADD CONSTRAINT products_catalog_id_fk
foreign KEY (catalog_id) REFERENCES catalogs(id)
on delete CASCADE;



