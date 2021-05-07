use vk;
show TABLES;


-- ������� ������ (�������� ������� � �������� ����� ������)
-- ������ � ��� ���������� ��������� ���������
DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,-- ����� �����
  -- ��� �� �������. ������ 2 ���������� target_id � target_type
  target_id INT UNSIGNED NOT NULL,-- ������������ ������ ������� ����������� ��������
  target_type ENUM('messages', 'users', 'posts', 'media') NOT NULL, -- ���������� � ����� ������� ��������� ������ �� ������� �������� target_id
  /*
  ENUM- ��� ��������� ������ �� ���������, ��������� �� ������ ����������� ��������, 
  ������� ���� ����������� � ������������ ������� �� ����� �������� �������.
  �������� ������������ ������ ���� ��������� ��������� � ��������. 
  */
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
desc likes;

/*�������� ������ ��� ���������� (�������). 
��� ��, ������ �� ����� �������� ���� ������: 'messages', 'users', 'posts', 'media'
�������� �������e�� ������� ����� ������. ��� ��� ����� ������ ��� ���� ��� �� 
��������� ����. ������ ��������� ������� */

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
 
-- ��������� ����� (��������� ������)
INSERT INTO likes 
/*��������� � ������� �� ������, ������� ����������� 
������ SELECT � ������� messages (��� ������ ����), ��� ��������� id. � ���-�� ��������� ������� �� ����� � ������� likes 
������� � � ����. messages */
  SELECT 
    id, 
    FLOOR(1 + (RAND() * 100)), 
    FLOOR(1 + (RAND() * 100)),
    (SELECT name FROM target_types ORDER BY RAND() LIMIT 1),
    CURRENT_TIMESTAMP 
  FROM messages;

-- ��������
SELECT * FROM likes LIMIT 10;

-- ������� ������� �����
desc likes; 
alter TABLE likes
ADD CONSTRAINT likes_user_id_fk
foreign KEY (user_id) REFERENCES users(id)
on delete CASCADE;


-- �������� ������� ������
DROP TABLE IF EXISTS posts;
CREATE TABLE posts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,-- ����� �����
  community_id INT UNSIGNED,-- ������ �� community, ���� ���� ��������� (�����������) �� ���� community
  head VARCHAR(255),-- ��������� �����
  body TEXT NOT NULL,-- -- ���� �����
  media_id INT UNSIGNED, -- ������, �� ������������� ��������� (����). ���� ����� ������, �� ���� ������� ������� ������
  -- ��� ����� (����������� � ���������������� ����� �����)
  -- ����� mysql ������������ ������������ � ������������� �����, � ������� �� ������ ��������.
  is_public BOOLEAN DEFAULT TRUE,
  is_archived BOOLEAN DEFAULT FALSE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

SELECT * FROM posts LIMIT 10;-- ������� ������ � �����

-- ������� ������� �����
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

-- ������� users
desc users;
select * from users;
select  * from users where created_at > update_at;-- ���������� ������ ��� ������ ��� update ����� ������ ��� ���� created
update users set update_at = NOW() where created_at > update_at; -- ������ �� ����������


-- ������� profiles ������� ������� �����
desc profiles;
select * from profiles limit 100;
alter TABLE profiles
ADD CONSTRAINT profiles_user_id_fk
foreign KEY (user_id) REFERENCES users(id)
on delete CASCADE;

select * from profiles limit 100;
select  * from profiles where created_at > update_at;-- ���������� ������ ��� ������ ��� update ����� ������ ��� ���� created
update profiles set update_at = NOW() where created_at > update_at; -- ������ �� ����������
-- update profiles set gender = '';
-- CREATE temporary table genders (name CHAR(1));
-- insert into genders values ('F'), ('M');
-- select * from genders;
-- select name from genders order BY RAND() limit 1; -- �������� �������� ���� F � M ��������� �������
-- update profiles set gender = (select name from genders order BY RAND() limit 1); -- ������ �� ����������


-- ������� messages ������� ������� �����
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
-- select FLOOR (1 + RAND() * 100);-- ��������� ���������� ������ ����� RAND(). FLOOR-��������� �� ������� �����.
-- update messages set -- ������ �� ����������
-- from_user_id = FLOOR (1 + RAND() * 100),
-- to_user_id = FLOOR (1 + RAND() * 100);
-- ���� from_user_id � to_user_id �������� �������
-- select * from messages where from_user_id = to_user_id;
-- update messages set to_user_id = to_user_id + 1 where from_user_id = to_user_id;


-- ������� media ������� ������� �����
desc media;
select * from media limit 10;
alter TABLE media
ADD CONSTRAINT media_user_id_fk
foreign KEY (user_id) REFERENCES users(id)
on delete CASCADE;
-- update media set
-- user_id = FLOOR (1 + RAND() * 100);

-- ������� filename 
-- ��� ����� ����������? 
-- http://dropbox.com/vk/filename.ext ����������� ����: �����������������.��������� ����������
CREATE temporary table extensions (name VARCHAR(10)); -- ������� ��������� �������
insert into extensions values ('mp4'), ('mp3'), ('png'), ('avi');
select * from extensions;-- ��������� ������� ���������� �������
-- ��������� �������� ������ 
update media  set filename = concat(
-- ������� concat ���������� ��� ���� ���������, ������������� ����� ������� � ���� ������. �.�. ���������� 4 ������ (��. ��������� ����) � ����.
'http://dropbox.com/vk/',
filename,
'.',
(select name from extensions order BY RAND() limit 1))-- ������ ����������. ���� ���������� ��. �� ��������� (extensions) �������
;
select * from media limit 10;

-- ������� size
-- update media set size = FLOOR (1000 + RAND() * 1000000000 where sise < 10000);-- ������ ������� � ������ - sise < 10000)

-- ������� metadata
-- ���� ������� ����� ������.
-- ������ ���������� ���-�� �����: '{"ouner": "Ferst Last"}', �.�. '{"����": "�������� - ��� �������"}'
update media set metadata = CONCAT(
-- update media - ������ �� ���������� � ��������� (set) ��� ������� metadata ����-�������� ���� ������ �� ����������.
'{"ouner": "',
(select CONCAT(first_name, ' ', last_name) 
from users where users.id = media.user_id),
'"}'
);
select * from media limit 20;
desc media; -- �������� ��������� ������� 
alter table media modify COLUMN metadata JSON; -- ��. 8-� ��� ��������

-- ������� media_types, ������� media_types_id
select * from media_types;
delete from media_types;
insert into media_types (name) values
('image'),
('audio'),
('video');
TRUNCATE media_types;
update media set;
media_type_id =FLOOR(1 + RAND() * 3);


-- ������� frendship
select * from friendship limit 10;
-- update friendship set
-- user_id = FLOOR (1 + RAND() * 100),
-- friend_id = FLOOR (1 + RAND() * 100);
select * from friendshep_statuses;-- ����� 8 ��������. �����! �������, � ���������� ���
TRUNCATE friendshep_statuses;
insert into friendshep_statuses (name) values
('Requested'),
('Confirmed'),
('Rejected');
select * from friendship;
update friendship set
friend_status_id = FLOOR(1 + RAND() * 3);
update friendship  set -- ��. 11-� ��� ��������
confirmed_at = created_at,
created_at = confirmed_at;
-- WHERE user_id = 3 AND friend_id = 7;

-- ������� ������� �����
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


-- ������� ����� (communities)
select * from communities;
-- DELETE from communities where id > 30;
select * from communities;
select  * from communities where created_at > update_at;-- ���������� ������ ��� ������ ��� update ����� ������ ��� ���� created
update communities set update_at = NOW() where created_at > update_at; -- ������ �� ����������
desc communities;

-- ������� ����� (communities_users)
select * from communities_users;
update communities_users set
user_id = FLOOR (1 + RAND() * 100),
communities_id = FLOOR (1 + RAND() * 30);

-- ������� ������� �����
desc communities_users;
select * from communities_users limit 10;
alter TABLE communities_users
ADD CONSTRAINT communities_users_communities_id_fk
foreign KEY (communities_id) REFERENCES communities(id)
on delete CASCADE;

-- ������� ������� �����
alter TABLE communities_users
ADD CONSTRAINT communities_users_users_id_fk
foreign KEY (users_id) REFERENCES users(id)
on delete CASCADE;

-- ������� orders
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id)
) COMMENT = '������';

-- ������� ������� �����
desc orders;
select * from orders limit 10;
alter TABLE orders
ADD CONSTRAINT orders_user_id_fk
foreign KEY (user_id) REFERENCES users(id)
on delete CASCADE;

-- ������� orders_products
DROP TABLE IF EXISTS orders_products;
CREATE TABLE orders_products (
  id SERIAL PRIMARY KEY,
  order_id BIGINT UNSIGNED,
  product_id INT UNSIGNED,
  total INT UNSIGNED DEFAULT 1 COMMENT '���������� ���������� �������� �������',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = '������ ������';

-- ������� ������� �����
desc orders_products;
select * from orders_products limit 10;
alter TABLE orders_products
ADD CONSTRAINT orders_products_order_id_fk
foreign KEY (order_id) REFERENCES orders(id)
on delete CASCADE;


-- ������ ��� ������ BIGINT unsigned �� INT unsigned 
ALTER TABLE orders_products MODIFY COLUMN id int unsigned;
desc storehouses;


-- ������� storehouses_products
DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id BIGINT UNSIGNED,
  product_id BIGINT UNSIGNED,
  value INT UNSIGNED COMMENT '����� �������� ������� �� ������',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = '������ �� ������';

desc storehouses;
select * from storehouses limit 10;

-- ���������� �������, ����� ��� ���������� � ������� ���������� �������� value
select * from storehouses_products limit 10;
select id, storehouse_id, product_id, value, created_at, updated_at
from storehouses_products
order by value;
-- ��� �� ���������� value, �� �������� ���� � ����� �������
select * from storehouses_products
order by if(value > 0,0,1), value;



/*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
��� � ��� � �����: 
���� �������, �� ��� ������, �� � �������� �������. ������������ ������, �������� � vk. 
� ����� ���������� ������ � ������� ����. ������� �������� ������� ���� - ������!
����� ��� ������������?
*/

-- ������� ������� �����
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






-- ������� discounts
DROP TABLE IF EXISTS discounts;
CREATE TABLE discounts (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  product_id BIGINT UNSIGNED,
  discount FLOAT UNSIGNED COMMENT '�������� ������ �� 0.0 �� 1.0',
  started_at DATETIME,
  finished_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id),
  KEY index_of_product_id(product_id)
) COMMENT = '������';

-- ������� ������� �����
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
-- ������ ��� ������ BIGINT unsigned �� INT unsigned 
ALTER TABLE catalogs MODIFY COLUMN id int unsigned;
select * from catalogs;
DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT '�������� �������',
  UNIQUE unique_name(name(10))
) COMMENT = '������� ��������-��������';

INSERT INTO catalogs VALUES
  (DEFAULT, '����������'),
  (DEFAULT, '���.�����'),
  (DEFAULT, '����������');
 
desc orders_products;
desc products;
-- ������ ��� ������ BIGINT unsigned �� INT unsigned 
ALTER TABLE orders_products MODIFY COLUMN product_id bigint unsigned;
-- ������� ������� �����
alter TABLE orders_products
ADD CONSTRAINT orders_products_product_id_fk
foreign KEY (product_id) REFERENCES products(id)
on delete CASCADE;

alter TABLE products
ADD CONSTRAINT products_catalog_id_fk
foreign KEY (catalog_id) REFERENCES catalogs(id)
on delete CASCADE;



