CREATE DATABASE THUCHANH
GO

USE THUCHANH
GO
SET DATEFORMAT DMY
--1
CREATE TABLE NHASANXUAT
(
	MANSX VARCHAR(6) PRIMARY KEY,
	TENNSX VARCHAR(30),
	NUOCTS VARCHAR(30),
	NAMTL INT,
)

CREATE TABLE SANPHAM
(
	MASP VARCHAR(5) PRIMARY KEY,
	MANSX VARCHAR(6),
	TENSP VARCHAR(50),
	MAU VARCHAR(15),
	LOAISP VARCHAR(30),
	GIA MONEY
)

CREATE TABLE PHIEUNHAP
(
	MAPN VARCHAR(5) PRIMARY KEY,
	MANSX VARCHAR(6),
	TRIGIA MONEY,
	NGNHAP DATE
)

CREATE TABLE CTPN
(
	MAPN VARCHAR(5),
	MASP VARCHAR(5),
	SOLUONG INT,
	FOREIGN KEY (MAPN) REFERENCES PHIEUNHAP (MAPN),
	FOREIGN KEY (MASP) REFERENCES SANPHAM (MASP)
)
--2
INSERT INTO NHASANXUAT VALUES ('NSX001', 'Apple', 'My', 1976),
							  ('NSX002', 'Huawei', 'Trung Quoc', 1987),
							  ('NSX003', 'Xiaomi', 'Trung Quoc', 2010)

INSERT INTO SANPHAM VALUES ('SP001', 'NSX001', 'iPhone 6', 'Trang', 'Dien thoai', 8000000),
						   ('SP002', 'NSX002', 'Mate 40 Pro', 'Den', 'Dien thoai', 15000000),
						   ('SP003', 'NSX001', 'MacBook Air M1', 'Hong', 'May tinh', 21000000)

INSERT INTO PHIEUNHAP VALUES ('PN001', 'NSX001', 145000000, '15-03-2024'),
							 ('PN002', 'NSX002', 150000000, '02-05-2024'),
							 ('PN003', 'NSX001', 88000000, '26-05-2024')

INSERT INTO CTPN VALUES ('PN001', 'SP001', 5),
						('PN001', 'SP003', 5),
						('PN002', 'SP002', 10),
						('PN003', 'SP001', 11)

--3
ALTER TABLE SANPHAM 
ADD CONSTRAINT CHK_GIA 
CHECK (GIA > 8000000 OR LOAISP <> 'May tinh')

--4
CREATE TRIGGER CHK_TRIG_NGNHAP
ON PHIEUNHAP FOR INSERT
AS
BEGIN
		DECLARE @NGNHAP DATE
		SELECT @NGNHAP = NGNHAP FROM INSERTED
		IF YEAR(@NGNHAP) < (
								SELECT NAMTL
								FROM NHASANXUAT NSX
								JOIN INSERTED ON NSX.MANSX = INSERTED.MANSX
							)
			BEGIN
				PRINT N'Thoi gian nhap hang phai tu thoi gian thanh lap cua nha san xuat tro di'
				ROLLBACK TRANSACTION
			END
END

--5
SELECT MANSX, TENNSX
FROM NHASANXUAT
WHERE NUOCTS = 'Trung Quoc'

--6
SELECT SP.MASP, SP.TENSP
FROM SANPHAM SP
JOIN CTPN ON CTPN.MASP = SP.MASP
JOIN PHIEUNHAP PN ON PN.MAPN = SP.MASP
WHERE YEAR(NGNHAP) = 2024 AND MONTH(NGNHAP) = 5
ORDER BY NGNHAP ASC

--7
SELECT NSX.MANSX, TENNSX
FROM NHASANXUAT NSX
JOIN PHIEUNHAP PN ON NSX.MANSX = PN.MANSX
JOIN CTPN ON CTPN.MAPN = PN.MAPN
GROUP BY NSX.MANSX, NSX.TENNSX
HAVING COUNT(DISTINCT CTPN.MASP) - 4 < (
											SELECT TOP 1 COUNT(DISTINCT MASP)
											FROM CTPN
											GROUP BY MAPN
											ORDER BY COUNT(DISTINCT MASP) DESC
									)
--8
SELECT PN.MAPN, PN.NGNHAP
FROM PHIEUNHAP PN
JOIN CTPN ON CTPN.MAPN = PN.MAPN
JOIN SANPHAM SP ON SP.MASP = CTPN.MASP
WHERE SP.MANSX IN (
					SELECT MANSX
					FROM NHASANXUAT NSX
					WHERE NUOCTS = 'My'
				   )
GROUP BY PN.MAPN, PN.NGNHAP
HAVING COUNT(DISTINCT CTPN.MASP) = (
								SELECT COUNT(SP2.MASP)
								FROM SANPHAM SP2
								JOIN NHASANXUAT NSX2 ON NSX2.MANSX = SP2.MANSX
								WHERE NSX2.NUOCTS = 'My'
						)

--9
SELECT PN.MAPN, NSX.TENNSX, SUM(SOLUONG) AS Tong_so_luong
FROM PHIEUNHAP PN, NHASANXUAT NSX, CTPN
WHERE NSX.MANSX = PN.MANSX AND CTPN.MAPN = PN.MAPN
GROUP BY PN.MAPN, NSX.TENNSX
