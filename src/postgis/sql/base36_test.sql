CREATE EXTENSION base36;
SELECT base36_encode(0);
SELECT base36_encode(1);
SELECT base36_encode(10);
SELECT base36_encode(35);
SELECT base36_encode(36);
SELECT base36_encode(123456789);
