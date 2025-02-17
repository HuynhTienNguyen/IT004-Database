CREATE DATABASE DB_MADE02
GO

USE DB_MADE02
GO
SET DATEFORMAT DMY

CREATE TABLE DOITUYEN
(
		MADT VARCHAR(5) PRIMARY KEY,
		TENHLV VARCHAR(50),
		QUOCGIA VARCHAR(20),
		CHAULUC VARCHAR(10),
		DIEM INT
)
CREATE TABLE CAUTHU
(
		MACT VARCHAR(5) PRIMARY KEY,
		TENCT VARCHAR(50),
		NGSINH SMALLDATETIME,
		VITRI VARCHAR(10),
)

CREATE TABLE THUOCDT
(
		MACT VARCHAR(5) PRIMARY KEY,
		MADT VARCHAR(5),
)
CREATE TABLE FINALWC
(
		MAFWC VARCHAR(5) PRIMARY KEY,
		NUOCTC VARCHAR(20),
		NAM INT,
		NGBD SMALLDATETIME,
		TONGKP INT,
)
CREATE TABLE KETQUA
(
		MAKQ VARCHAR(5) PRIMARY KEY,
		MADT VARCHAR(5),
		MAFWC VARCHAR(5),
		TONGSOBT INT,
		THUHANG INT,
		HUYCHUONG VARCHAR(5),
)

ALTER TABLE THUOCDT ADD CONSTRAINT PK_MADT FOREIGN KEY (MADT) REFERENCES DOITUYEN (MADT)

INSERT INTO DOITUYEN VALUES ('DT001', 'Paulo Bento', 'Han Quoc', 'Chau A', 72)
INSERT INTO DOITUYEN VALUES ('DT002', 'Fernando Santos', 'Bo Dao Nha', 'Chau Au', 222)
INSERT INTO DOITUYEN VALUES ('DT003', 'Lionel Scaloni', 'Argentina', 'Chau My', 100)

INSERT INTO CAUTHU VALUES ('CT001', 'Lionel Messi', '24/06/1987', 'Tien dao')
INSERT INTO CAUTHU VALUES ('CT002', 'Cristiano Ronaldo', '05/02/1985', 'Tien dao')
INSERT INTO CAUTHU VALUES ('CT003', 'Bruno Fernandes', '08/09/1994', 'Tien ve')

INSERT INTO THUOCDT VALUES ('CT001', 'DT003')
INSERT INTO THUOCDT VALUES ('CT002', 'DT002')
INSERT INTO THUOCDT VALUES ('CT003', 'DT001')

INSERT INTO FINALWC VALUES ('WC001', 'Qatar', 2022, '20/11/2022', 13)
INSERT INTO FINALWC VALUES ('WC002', 'Nga', 2018, '14/06/2018', 8)
INSERT INTO FINALWC VALUES ('WC003', 'Brazil', 2014, '12/06/2014', 7)

INSERT INTO KETQUA VALUES ('KQ001', 'DT001', 'WC001', 4, 9, NULL)
INSERT INTO KETQUA VALUES ('KQ002', 'DT002', 'WC001', 15, 3, 'Vang')
INSERT INTO KETQUA VALUES ('KQ003', 'DT003', 'WC001', 16, 5, 'Bac')

SELECT * FROM DOITUYEN
SELECT * FROM CAUTHU
SELECT * FROM THUOCDT
SELECT * FROM FINALWC
SELECT * FROM KETQUA

--3 
CREATE TRIGGER CHK_TRIG_VODICH
ON KETQUA FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @MADT VARCHAR(5)
	SELECT @MADT = MADT FROM INSERTED
	IF (@MADT IN (
					SELECT MADT
					FROM INSERTED
					WHERE HUYCHUONG = 'Vang' AND TONGSOBT >= 4
					AND MADT IN (
									SELECT TOP 2 MADT
									FROM DOITUYEN
									ORDER BY DIEM DESC))
		)
		BEGIN
			PRINT N'CAP NHAT THANH CONG'
		END
END

--4
CREATE TRIGGER CHK_TRIG_CT
ON THUOCDT FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @MACT VARCHAR(5)
	SELECT @MACT = MACT FROM INSERTED
	IF (COUNT(@MACT) > 1)
			PRINT 'MOI CAU THU CHI THUOC MOT DOI TUYEN DUY NHAT'
END

--5
SELECT CT.MACT, CT.TENCT
FROM CAUTHU CT
JOIN THUOCDT TDT ON CT.MACT = TDT.MACT
WHERE VITRI = 'Tien dao' 
	  AND MADT IN (
				SELECT DT.MADT
				FROM DOITUYEN DT
				JOIN KETQUA KQ ON DT.MADT = KQ.MADT
				JOIN FINALWC FWC ON FWC.MAFWC = KQ.MAFWC
				WHERE DT.CHAULUC = 'Chau A' AND FWC.NUOCTC = 'Nga'
)

--6
SELECT CT.MACT, CT.TENCT
FROM CAUTHU CT
JOIN THUOCDT TDT ON CT.MACT = TDT.MACT
WHERE VITRI = 'Tien dao' 
	  AND MADT IN (
				SELECT MADT
				FROM KETQUA
				GROUP BY MADT
				HAVING COUNT(MADT) = (
										SELECT TOP 1 COUNT(MADT)
										FROM KETQUA
										GROUP BY MADT
										ORDER BY MADT DESC
										)
					  AND COUNT(HUYCHUONG) = (
										SELECT TOP 1 COUNT(HUYCHUONG)
										FROM KETQUA
										GROUP BY MADT
										ORDER BY MADT ASC
							)
	)

--7
SELECT TENCT
FROM CAUTHU CT
JOIN THUOCDT TDT ON TDT.MACT = CT.MACT
WHERE TDT.MADT NOT IN (
						SELECT MADT
						FROM KETQUA KQ
						WHERE HUYCHUONG = 'Vang'
)

--8
SELECT CT.MACT, CT.TENCT
FROM CAUTHU CT
JOIN THUOCDT TDT ON TDT.MACT = CT.MACT
JOIN KETQUA KQ ON KQ.MADT = TDT.MADT
JOIN FINALWC FWC ON FWC.MAFWC = KQ.MAFWC
JOIN DOITUYEN DT ON DT.MADT = KQ.MADT
WHERE DT.QUOCGIA = FWC.NUOCTC
AND TDT.MADT IN ( 
					SELECT MADT
					FROM KETQUA
					WHERE HUYCHUONG IS NOT NULL
					)
