﻿CREATE DATABASE BAITHI1
GO

USE BAITHI1
GO
SET DATEFORMAT dmy

CREATE TABLE KHACHHANG
(
	MAKH VARCHAR(4) PRIMARY KEY,
	TENKH VARCHAR(40),
	NGAYSINH DATE,
	LOAIKH VARCHAR(30),
)
CREATE TABLE PHIM
(
	MAP VARCHAR(4) PRIMARY KEY,
	TENP VARCHAR(50),
	GIOIHANTUOI INT,
	NGAYCHIEU DATE,
)
CREATE TABLE HOADON
(
	SOHD VARCHAR(5) PRIMARY KEY,
	NGHD DATE,
	MAKH VARCHAR(4),
	KHUYENMAI INT,
)
ALTER TABLE HOADON ADD CONSTRAINT FK_MAKH FOREIGN KEY (MAKH) REFERENCES KHACHHANG (MAKH)
CREATE TABLE CTHD
(
	SOHD VARCHAR(5),
	MAP VARCHAR(4),
	SOLUONG INT,
	FOREIGN KEY (SOHD) REFERENCES HOADON (SOHD),
	FOREIGN KEY (MAP) REFERENCES PHIM (MAP)
)

INSERT INTO KHACHHANG VALUES ('KH01', 'Tran Thanh Long', '22-12-2000', 'Vang lai'),
							 ('KH02', 'Nguyen Thanh Phong', '03-07-1999', 'Thuong xuyen'),
							 ('KH03', 'Nguyen Viet Truong', '16-10-2001', 'Vang lai')

INSERT INTO PHIM VALUES ('DA01', 'AVATAR: DONG CHAY CUA NUOC', 13, '01-12-2022'),
						('DA02', 'AM LUONG HUY DIET', 16, '18-12-2022'),
						('DA03', 'CUOC DIEU HANH THAM LANG', 13, '20-12-2022')

INSERT INTO HOADON VALUES ('00001', '22-11-2022', 'KH01', 5),
						  ('00002', '04-12-2022', 'KH03', 5),
						  ('00003', '10-12-2022', 'KH02', 10)
INSERT INTO CTHD VALUES ('00001', 'DA01', 5),
						('00002', 'DA02', 2),
						('00003', 'DA03', 1)

SELECT * FROM KHACHHANG
SELECT * FROM PHIM
SELECT * FROM HOADON
SELECT * FROM CTHD


--3
ALTER TABLE PHIM ADD CONSTRAINT CHK_NGCHIEU CHECK ((GIOIHANTUOI <> 16) OR (NGAYCHIEU > '15-12-2022')) --Kiểm tra giới hạn tuổi không phải 16 hoặc ngày chiếu phim lớn hơn 15/12/2022
														--vì ngày chiếu phim lớn hơn 15/12/2022 chắc chắn sẽ là phim giới hạn tuổi 16 (liên quan đến CTRR 1 tí :))) )

--4
SELECT * FROM HOADON
WHERE MONTH(NGHD) BETWEEN 9 AND 12
	  AND YEAR(NGHD) = 2022
ORDER BY KHUYENMAI ASC

--5
SELECT * FROM PHIM
WHERE MAP IN (
				SELECT TOP 1 MAP
				FROM CTHD
				JOIN HOADON HD ON HD.SOHD = CTHD.SOHD
				WHERE MONTH(NGHD) = 12
				GROUP BY MAP
				ORDER BY SUM(SOLUONG) ASC
				)
				
--6
SELECT * FROM PHIM
JOIN CTHD ON CTHD.MAP = PHIM.MAP
JOIN HOADON HD ON HD.SOHD = CTHD.SOHD
WHERE MONTH(NGHD) = 12
HAVING COUNT(CTHD.SOHD)=(
						SELECT TOP 1 COUNT(CT2.SOHD) AS DOANHSO
						FROM CTHD CT2
						JOIN HOADON HD2 ON HD2.SOHD = CT2.SOHD
						WHERE MONTH(NGHD) = 12
						GROUP BY CT2.MAP
						ORDER BY DOANHSO DESC
						)