USE MASTER

ALTER DATABASE HK1_03 SET SINGLE_USER WITH ROLLBACK IMMEDIATE

DROP DATABASE HK1_03
-----------
CREATE DATABASE HK1_03

SET DATEFORMAT DMY
USE HK1_03


--1
CREATE TABLE NHACUNGCAP
(
	 MANCC CHAR(5) PRIMARY KEY,
	 TENNCC VARCHAR(40),
	 QUOCGIA VARCHAR(40),
	 LOAINCC VARCHAR(40)
)

CREATE TABLE DUOCPHAM
(
	MADP CHAR(4) PRIMARY KEY,
	TENDP VARCHAR(40),
	LOAIDP VARCHAR(40),
	GIA MONEY
)

CREATE TABLE PHIEUNHAP
(
	SOPN CHAR(5) PRIMARY KEY,
	NGNHAP SMALLDATETIME,
	MANCC CHAR(5),
	LOAINHAP VARCHAR(40)
)

CREATE TABLE CTPN
(
	SOPN CHAR(5),
	MADP CHAR(4),
	SOLUONG INT,
	CONSTRAINT CTPN_KC PRIMARY KEY (SOPN, MADP)
)
------------
ALTER TABLE PHIEUNHAP ADD CONSTRAINT MANCC
FOREIGN KEY (MANCC) REFERENCES NHACUNGCAP(MANCC)

ALTER TABLE CTPN ADD CONSTRAINT SOPN
FOREIGN KEY (SOPN) REFERENCES PHIEUNHAP(SOPN)

ALTER TABLE CTPN ADD CONSTRAINT MAPN
FOREIGN KEY (MADP) REFERENCES DUOCPHAM(MADP)

--2
INSERT INTO NHACUNGCAP VALUES
('NCC01', 'PHUC HUNG', 'VIET NAM', 'THUOGN XUYEN'),
('NCC02', 'J.B PHARMACEUTICALS', 'INDIA', 'VANG LAI'),
('NCC03', 'SAPHARCO', 'SINGAPORE', 'VANG LAI')

INSERT INTO DUOCPHAM VALUES
('DP01', 'THUOC HO PH', 'SIRO', 120000),
('DP02', 'ZECUF HERBAL COUCHREMEDY', 'VIEN NEN', 200000),
('DP03', 'COTRIM', 'VIEN SUI', 80000)

INSERT INTO PHIEUNHAP VALUES
('00001', '22/11/2017', 'NCC01', 'NOI DIA'),
('00002', '4/12/2017', 'NCC03', 'NHAP KHAU'),
('00003', '10/12/2017', 'NCC02', 'NHAP KHAU')

INSERT INTO CTPN VALUES
('00001', 'DP01', 100),
('00001', 'DP02', 200),
('00003', 'DP03', 543)

--3
GO
CREATE TRIGGER GIA_SIRO_HON100K ON DUOCPHAM
AFTER INSERT, UPDATE
AS BEGIN
	DECLARE @LOAIDP VARCHAR(40), @GIA MONEY
	SELECT @LOAIDP = I.LOAIDP, @GIA = I.GIA
	FROM INSERTED I
	IF(@LOAIDP = 'SIRO') BEGIN
		IF(@GIA < 100000) BEGIN
			PRINT('GIA SIRO RE HON 100K')
			ROLLBACK TRANSACTION
		END
	END
END

--4
GO
CREATE TRIGGER NHAPKHAU ON PHIEUNHAP
AFTER INSERT, UPDATE
AS BEGIN
	DECLARE @LOAINHAP VARCHAR(40), @QUOCGIA VARCHAR(40)
	SELECT @LOAINHAP = I.LOAINHAP, @QUOCGIA = NCC.QUOCGIA
	FROM INSERTED I
	JOIN NHACUNGCAP NCC ON I.MANCC = NCC.MANCC
	IF (@QUOCGIA != 'VIET NAM' AND @LOAINHAP != 'NHAP KHAU')
	BEGIN
		PRINT('SAI LOAINHAP!')
		ROLLBACK TRANSACTION
	END
END

--5
SELECT *
FROM PHIEUNHAP
WHERE YEAR(NGNHAP) = 2017 AND MONTH(NGNHAP) = 12
ORDER BY NGNHAP ASC

--6
SELECT *
FROM DUOCPHAM
WHERE MADP IN (
	SELECT TOP 1 MADP
	FROM CTPN CT
	GROUP BY MADP
	ORDER BY SUM(SOLUONG) DESC
)

--7
SELECT *
FROM DUOCPHAM DP
WHERE MADP IN (
	SELECT CT.MADP
	FROM CTPN CT
	JOIN PHIEUNHAP PN ON CT.SOPN = PN.SOPN
	JOIN NHACUNGCAP NCC ON NCC.MANCC = PN.MANCC
	WHERE LOAINCC = 'THUOGN XUYEN'
	EXCEPT
	SELECT CT.MADP
	FROM CTPN CT
	JOIN PHIEUNHAP PN ON CT.SOPN = PN.SOPN
	JOIN NHACUNGCAP NCC ON NCC.MANCC = PN.MANCC
	WHERE LOAINCC = 'VANG LAI'
)

--8
SELECT *
FROM NHACUNGCAP NCC
WHERE MANCC IN (
	SELECT PN.MANCC
	FROM PHIEUNHAP PN
	JOIN CTPN CT ON PN.SOPN = CT.SOPN
	JOIN DUOCPHAM DP ON CT.MADP = DP.MADP
	WHERE DP.GIA > 100000 AND YEAR(PN.NGNHAP) = 2017
	GROUP BY PN.MANCC
	HAVING COUNT(CT.MADP) = (
		SELECT COUNT(*)
		FROM DUOCPHAM 
		WHERE GIA > 100000)
)