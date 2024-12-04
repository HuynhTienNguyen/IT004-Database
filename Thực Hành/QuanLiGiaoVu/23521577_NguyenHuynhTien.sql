SET DATEFORMAT DMY

USE QUANLIGIAOVU_0208


--I-----------------------------------------------------
--I.1: Thêm vào 3 thuộc tính GHICHU, DIEMTB, XEPLOAI cho quan hệ HOCVIEN
ALTER TABLE HOCVIEN ADD GHICHU VARCHAR(10), DIEMTB NUMERIC(4, 2) , XEPLOAI VARCHAR(10);
GO

--I.2: Mã học viên là một chuỗi 5 ký tự, 3 ký tự đầu là mã lớp, 2 ký tự cuối cùng là số thứ tự học viên 
--trong lớp. VD: “K1101” *
CREATE FUNCTION CHECK_VALID_MAHV (@MAHV VARCHAR(5))
RETURNS TINYINT
AS
BEGIN
	IF LEFT(@MAHV, 3) IN (SELECT MALOP FROM LOP)
		RETURN 1
	RETURN 0
END
GO

CREATE FUNCTION CHECK_STT_MAHV (@MAHV VARCHAR(5), @MALOP_HV VARCHAR(3))
RETURNS TINYINT
AS
BEGIN
	IF RIGHT(@MAHV, 2) BETWEEN 01 AND (SELECT SISO FROM LOP WHERE MALOP = @MALOP_HV)
		RETURN 1
	RETURN 0
END
GO

ALTER TABLE HOCVIEN ADD CONSTRAINT CHECK_MAHV 
CHECK
(
	LEN(MAHV) = 5 AND
	DBO.CHECK_VALID_MAHV(MAHV) = 1 AND
	DBO.CHECK_STT_MAHV(MAHV, MALOP) = 1
)
GO

--I.3: Thuộc tính GIOITINH chỉ có giá trị là “Nam” hoặc “Nu”
ALTER TABLE HOCVIEN ADD CHECK (GIOITINH = 'NAM' OR GIOITINH = 'NU')
GO

--I.4: Điểm số của một lần thi có giá trị từ 0 đến 10 và cần lưu đến 2 số lẽ (VD: 6.22).
--CÁCH 1
ALTER TABLE KETQUATHI ADD CONSTRAINT CHECK_DIEM 
CHECK(
	LEN(
		SUBSTRING(
			CAST(DIEM AS VARCHAR)
			, CHARINDEX('.', DIEM) + 1
			, 3)
		) = 2
	AND DIEM BETWEEN 0 AND 10
)
GO

--CÁCH 2 DO DATATYPE CỦA TABLE VỐN LÀ NUMERIC(4,2) NÊN CHỈ CẦN QUAN TÂM GIÁ TRỊ TỪ 0-10
ALTER TABLE KETQUATHI ADD CONSTRAINT CHECK_DIEM 
CHECK(DIEM BETWEEN 0 AND 10)
GO

--I.5: Kết quả thi là “Dat” nếu điểm từ 5 đến 10 và “Khong dat” nếu điểm nhỏ hơn 5. *
--C1
ALTER TABLE KETQUATHI ADD CONSTRAINT CHECK_QDINH_KQUA
CHECK(
	(DIEM BETWEEN 5 AND 10 AND KQUA = 'DAT')
	OR (DIEM < 5 AND KQUA = 'KHONG DAT')
)
GO

--C2
ALTER TABLE KETQUATHI ADD CONSTRAINT CHECK_QDINH_KQUAA
CHECK(KQUA = IIF(DIEM BETWEEN 5 AND 10, 'DAT', 'KHONG DAT'))
GO

--I.6: Học viên thi một môn tối đa 3 lần. *
ALTER TABLE KETQUATHI ADD CONSTRAINT CK_SOLANTHI CHECK(LANTHI <= 3)
GO

--I.7: Học kỳ chỉ có giá trị từ 1 đến 3.
ALTER TABLE GIANGDAY ADD CONSTRAINT CHECK_HK
CHECK(HOCKY IN (1,2,3))
GO

--I.8: Học vị của giáo viên chỉ có thể là “CN”, “KS”, “Ths”, ”TS”, ”PTS”.
ALTER TABLE GIAOVIEN ADD CONSTRAINT CHECK_HOCVI
CHECK(HOCVI IN ('CN', 'KS', 'Ths', 'TS', 'PTS'))
GO

--I.9: Lớp trưởng của một lớp phải là học viên của lớp đó.
ALTER TABLE LOP ADD CONSTRAINT LOPTR_THUOC_LOP
CHECK(
	LEFT(TRGLOP,3) = MALOP 
)
GO

--I.10: Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”
--USE TRIGGER
CREATE TRIGGER HOCVI_TRGKHOA ON KHOA
FOR INSERT
AS BEGIN 
	DECLARE @HOCVI VARCHAR(10)
	SELECT @HOCVI = GV.HOCVI
	FROM INSERTED I, GIAOVIEN GV
	WHERE I.TRGKHOA = GV.MAGV
	IF (@HOCVI NOT IN ('TS', 'PTS')) BEGIN
		PRINT(N'LỖI!!!')
		ROLLBACK TRANSACTION
	END
END
GO

--USE PROCEDURE STORE TRANSACTION
CREATE PROCEDURE HOCVI_TRKHOA (@TRGKHOA CHAR(4))
AS
	BEGIN TRAN
		INSERT INTO KHOA (MAKHOA, TENKHOA, NGTLAP, TRGKHOA)
		VALUES ('TEST','TEST',GETDATE(),@TRGKHOA)
		IF('TS' NOT IN (SELECT HOCVI FROM GIAOVIEN WHERE MAGV = @TRGKHOA)
		OR 'PTS' NOT IN (SELECT HOCVI FROM GIAOVIEN WHERE MAGV = @TRGKHOA))
			ROLLBACK TRAN
	COMMIT TRAN
GO
	

--I.11: Học viên ít nhất là 18 tuổi
--USE TRIGGER
CREATE TRIGGER HV_18TUOI ON HOCVIEN
FOR INSERT
AS BEGIN 
	DECLARE @TUOI INT
	SELECT @TUOI = YEAR(GETDATE()) - YEAR(I.NGSINH)
	FROM INSERTED I
	IF (@TUOI < 18) BEGIN
		PRINT(N'LỖI!!!!!')
		ROLLBACK TRANSACTION
	END
END
GO

--USE CHECK
ALTER TABLE HOCVIEN ADD CONSTRAINT CK_TUOI CHECK(GETDATE() - NGSINH >= 18)
GO

--I.12: Giảng dạy một môn học ngày bắt đầu (TUNGAY) phải nhỏ hơn ngày kết thúc (DENNGAY) *
--CONSTRAINT IS CONFLICT BECAUSE THE DATABASE IS ALL READY AGAINST THE CHECK CONSTRAINT
ALTER TABLE GIANGDAY ADD CONSTRAINT BD_SMALLER_KT
CHECK(DATEDIFF(SECOND,TUNGAY, DENNGAY)>0)
GO

--I.13: Giáo viên khi vào làm ít nhất là 22 tuổi.
ALTER TABLE GIAOVIEN ADD CONSTRAINT TUOI_GV
CHECK (GETDATE() - YEAR(NGSINH) >= 22)
GO

--I.14: Tất cả các môn học đều có số tín chỉ lý thuyết và tín chỉ thực hành chênh lệch nhau không quá 3.
ALTER TABLE MONHOC ADD CONSTRAINT LT_TH
CHECK(TCLT - TCTH >= -3 OR TCLT - TCTH <=3)
GO

--I.15: Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này
CREATE TRIGGER QDINH_NGAYTHI ON KETQUATHI
FOR INSERT
AS BEGIN
	DECLARE @NGAYKT SMALLDATETIME, @NGAYTHI SMALLDATETIME
	SELECT @NGAYTHI = I.NGTHI, @NGAYKT = GD.DENNGAY
	FROM INSERTED I, GIANGDAY GD, HOCVIEN HV
	WHERE GD.MALOP = HV.MALOP AND HV.MAHV = I.MAHV
	IF (DATEDIFF(SECOND, @NGAYKT, @NGAYTHI) <= 0) BEGIN
		PRINT(N'ERROR!!!!!')
		ROLLBACK TRANSACTION
	END
END
GO

--I.16: Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn.
CREATE TRIGGER LOP_3MON_1HK ON GIANGDAY 
FOR INSERT
AS BEGIN 
	DECLARE @SOMON INT
	SELECT @SOMON = COUNT(I.MAMH)
	FROM INSERTED I
	GROUP BY MALOP, HOCKY
	IF (@SOMON > 3) BEGIN
		PRINT('ERROR!!!!!')
		ROLLBACK TRANSACTION
	END
END
GO

--I.17: Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó. *
CREATE TRIGGER SISOLOP ON LOP
FOR INSERT
AS BEGIN 
	DECLARE @SISO INT, @SLHV INT, @MALOP CHAR(3)
	SELECT @SISO = I.SISO, @SLHV = COUNT(HV.MAHV), @MALOP = I.MALOP
	FROM INSERTED I
	JOIN HOCVIEN HV ON I.MALOP = HV.MALOP
	GROUP BY I.MALOP
	IF (@SISO != @SLHV) BEGIN
		PRINT('UPDATE SISO LOP.')
		UPDATE LOP
		SET SISO = @SLHV
		WHERE MALOP = @MALOP
	END
END
GO

--I.18 Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng một bộ
--không được giống nhau (“A”,”A”) và cũng không tồn tại hai bộ (“A”,”B”) và (“B”,”A”).
ALTER TABLE DIEUKIEN ADD CONSTRAINT KHAC_NHAU
CHECK(MAMH != MAMH_TRUOC)
GO

--I.19: Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau.
CREATE TRIGGER LUONG ON GIAOVIEN
FOR INSERT
AS BEGIN
	DECLARE @LUONG MONEY, @HOCVI VARCHAR(10)
	SELECT @LUONG = I.MUCLUONG, @HOCVI = I.HOCVI
	FROM INSERTED I, GIAOVIEN GV
	WHERE I.HOCVI = GV.HOCVI
	IF (@LUONG <> ALL (SELECT MUCLUONG FROM GIAOVIEN WHERE HOCVI = @HOCVI )) BEGIN
		PRINT('ERROR')
		ROLLBACK TRANSACTION
	END
END
GO

--I.20: Học viên chỉ được thi lại (lần thi >1) khi điểm của lần thi trước đó dưới 5.
CREATE TRIGGER QUYDINH_THILAI ON KETQUATHI
FOR INSERT
AS BEGIN
	DECLARE @LANTHI TINYINT, @MAHV CHAR(5), @MAMH CHAR(10)
	SELECT @LANTHI = I.LANTHI, @MAHV = I.MAHV, @MAMH = I.MAMH
	FROM INSERTED I
	IF (@LANTHI > 1) BEGIN
		IF(5 >= (SELECT DIEM FROM KETQUATHI WHERE MAHV = @MAHV AND MAMH = @MAMH AND LANTHI = @LANTHI - 1 )) BEGIN
			PRINT('ERROR')
			ROLLBACK TRANSACTION
		END
	END
END
GO

--I.21: Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học).
CREATE TRIGGER NGAYTHI ON KETQUATHI
FOR INSERT
AS BEGIN
	DECLARE @LANTHI TINYINT, @MAHV CHAR(5), @MAMH CHAR(10)
	SELECT @LANTHI = I.LANTHI, @MAHV = I.MAHV, @MAMH = I.MAMH
	FROM INSERTED I
	IF(@LANTHI <= (SELECT TOP 1 DIEM 
					FROM KETQUATHI 
					WHERE MAHV = @MAHV AND MAMH = @MAMH 
					ORDER BY LANTHI DESC)) BEGIN
		PRINT('ERROR')
		ROLLBACK TRANSACTION
	END
END
GO

--I.22: Học viên chỉ được thi những môn mà lớp của học viên đó đã học xong. * GIỐNG CÂU 15
CREATE TRIGGER QDINH_NGAYTHI ON KETQUATHI
FOR INSERT
AS BEGIN
	DECLARE @NGAYKT SMALLDATETIME, @NGAYTHI SMALLDATETIME
	SELECT @NGAYTHI = I.NGTHI, @NGAYKT = GD.DENNGAY
	FROM INSERTED I, GIANGDAY GD, HOCVIEN HV
	WHERE GD.MALOP = HV.MALOP AND HV.MAHV = I.MAHV
	IF (DATEDIFF(SECOND, @NGAYKT, @NGAYTHI) <= 0) BEGIN
		PRINT(N'ERROR!!!!!')
		ROLLBACK TRANSACTION
	END
END
GO

--I.23: Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau khi học
--xong những môn học phải học trước mới được học những môn liền sau) *






--I.24: Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách.
CREATE TRIGGER GV_MN ON GIANGDAY
FOR INSERT
AS BEGIN
	DECLARE @MAKHOA_MH CHAR(4), @MAKHOA_GV CHAR(4)
	SELECT @MAKHOA_MH = MH.MAKHOA, @MAKHOA_GV = GV.MAKHOA
	FROM INSERTED I, GIAOVIEN GV, MONHOC MH
	WHERE I.MAMH = MH.MAMH AND I.MAGV = GV.MAGV
	IF (@MAKHOA_MH != @MAKHOA_GV) BEGIN
		PRINT('ERROR')
		ROLLBACK TRANSACTION
	END
END
GO


--II--------------------------------------------------------------

--II.1: Tăng hệ số lương thêm 0.2 cho những giáo viên là trưởng khoa.
UPDATE GIAOVIEN
SET MUCLUONG = MUCLUONG * 1.2
WHERE MAGV IN (SELECT TRGKHOA FROM KHOA)
GO

--II.2: Cập nhật giá trị điểm trung bình tất cả các môn học (DIEMTB) của mỗi học viên (tất cả các môn
--học đều có hệ số 1 và nếu học viên thi một môn nhiều lần, chỉ lấy điểm của lần thi sau cùng)
UPDATE HOCVIEN
SET DIEMTB = DIEM_HV.DTB
FROM HOCVIEN HV 
LEFT JOIN (
	SELECT MAHV, AVG(DIEM) AS DTB
	FROM KETQUATHI KQ1
	WHERE LANTHI IN (
		SELECT TOP 1 LANTHI
		FROM KETQUATHI KQ2
		WHERE KQ1.MAMH = KQ2.MAMH AND KQ1.MAHV = KQ2.MAHV
		ORDER BY LANTHI DESC)
	GROUP BY MAHV
	) AS DIEM_HV
ON DIEM_HV.MAHV = HV.MAHV
GO

--II.3: Cập nhật giá trị cho cột GHICHU là “Cam thi” đối với trường hợp: học viên có một môn bất kỳ thi
--lần thứ 3 dưới 5 điểm.
UPDATE HOCVIEN
SET GHICHU = 'CAM THI'
WHERE MAHV IN (
	SELECT DISTINCT MAHV
	FROM KETQUATHI
	WHERE LANTHI = 3 AND DIEM < 5
	)
GO

--II.4: Cập nhật giá trị cho cột XEPLOAI trong quan hệ HOCVIEN như sau:
-- Nếu DIEMTB >= 9 thì XEPLOAI =”XS”
-- Nếu 8 <= DIEMTB < 9 thì XEPLOAI = “G”
-- Nếu 6.5 <= DIEMTB < 8 thì XEPLOAI = “K”
-- Nếu 5 <= DIEMTB < 6.5 thì XEPLOAI = “TB”
-- Nếu DIEMTB < 5 thì XEPLOAI = ”Y
UPDATE HOCVIEN
SET XEPLOAI = CASE
WHEN DIEMTB >= 9 THEN 'XS'
WHEN DIEMTB >= 8 AND DIEMTB < 9 THEN 'G'
WHEN DIEMTB >= 6.5 AND DIEMTB < 8 THEN 'K'
WHEN DIEMTB >= 5 AND DIEMTB < 6.5 THEN 'TB'
WHEN DIEMTB <5 THEN 'Y'
END
GO



--III------------------------------------------------------------------

--III.1: In ra danh sách (mã học viên, họ tên, ngày sinh, mã lớp) lớp trưởng của các lớp
SELECT HV.MAHV, HV.HO, HV.TEN, HV.NGSINH, HV.MALOP
FROM HOCVIEN HV
JOIN LOP ON HV.MAHV = LOP.TRGLOP
GO

--III.2: 
SELECT HV.MAHV, HV.HO, HV.TEN, KQ_LT.LT, HV.DIEM
FROM (
	SELECT MAHV, MAX(LANTHI) LT
	FROM KETQUATHI
	GROUP BY MAHV) AS KQ_LT
JOIN (
	SELECT DISTINCT HV.MAHV, HV.HO, HV.TEN, KQ.DIEM
	FROM HOCVIEN HV
	JOIN LOP ON HV.MALOP = LOP.MALOP
	JOIN KETQUATHI KQ ON KQ.MAHV = HV.MAHV
	WHERE LOP.MALOP = 'K12' AND KQ.MAMH = 'CTRR') AS HV ON HV.MAHV = KQ_LT.MAHV
GO

--III.3: In ra danh sách những học viên (mã học viên, họ tên) và những môn học mà học viên đó thi lần thứ 
--nhất đã đạt.
SELECT DISTINCT HV.MAHV, HV.HO + ' ' + HV.TEN AS HOTEN, MAMH
FROM HOCVIEN HV
JOIN (
	SELECT MAHV, MAMH
	FROM KETQUATHI
	WHERE LANTHI = 1 AND KQUA = 'DAT') AS KQD ON HV.MAHV = KQD.MAHV
GO

--III.4:In ra danh sách học viên (mã học viên, họ tên) của lớp “K11” thi môn CTRR không đạt (ở lần thi 1)
SELECT DISTINCT HV.MAHV, HV.HO, HV.TEN
FROM HOCVIEN HV
JOIN LOP ON HV.MALOP = LOP.MALOP
JOIN KETQUATHI KQ ON HV.MAHV = KQ.MAHV
WHERE LOP.MALOP = 'K11' AND KQ.MAMH = 'CTRR' AND KQ.LANTHI = '1' AND KQUA = 'KHONG DAT'
GO

--III.5:Danh sách học viên (mã học viên, họ tên) của lớp “K” thi môn CTRR không đạt (ở tất cả các lần thi).
SELECT HV.MAHV, HV.HO, HV.TEN
FROM HOCVIEN HV
JOIN KETQUATHI KQ1 ON HV.MAHV = KQ1.MAHV
WHERE HV.MALOP LIKE 'K%' 
AND KQ1.MAMH = 'CTRR' 
AND KQ1.KQUA = 'KHONG DAT'
AND KQ1.LANTHI = (
				SELECT COUNT(*)
				FROM KETQUATHI KQ2
				WHERE KQ2.MAMH = 'CTRR' AND  KQ1.MAHV = KQ2.MAHV
				GROUP BY MAHV
				)
GO

--III.6:Tìm tên những môn học mà giáo viên có tên “Tran Tam Thanh” dạy trong học kỳ 1 năm 2006
SELECT DISTINCT MH.TENMH 
FROM GIAOVIEN GV
JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
JOIN MONHOC MH ON GD.MAMH = MH.MAMH
WHERE GV.HOTEN = 'Tran Tam Thanh' AND GD.HOCKY = '1' AND NAM = '2006'
GO

--III.7: Tìm những môn học (mã môn học, tên môn học) mà giáo viên chủ nhiệm lớp “K11” dạy trong học 
--kỳ 1 năm 2006.
SELECT MH.MAMH, MH.TENMH
FROM MONHOC MH
JOIN GIANGDAY GD ON MH.MAMH = GD.MAMH
JOIN GIAOVIEN GV ON GD.MAGV = GV.MAGV
JOIN LOP ON GV.MAGV = LOP.MAGVCN
WHERE LOP.MALOP = 'K11' AND GD.HOCKY = '1' AND GD.NAM = '2006'
GO

--III.8:Tìm họ tên lớp trưởng của các lớp mà giáo viên có tên “Nguyen To Lan” dạy môn “Co So Du Lieu”.
SELECT HO, TEN
FROM HOCVIEN
WHERE MAHV IN (
				SELECT DISTINCT TRGLOP
				FROM LOP
				JOIN GIANGDAY GD ON GD.MALOP = LOP.MALOP
				JOIN MONHOC MH ON MH.MAMH = GD.MAMH
				JOIN GIAOVIEN GV ON GV.MAGV = GD.MAGV
				WHERE GV.HOTEN = 'Nguyen To Lan' AND MH.TENMH = 'Co So Du Lieu')
GO

--III.9: In ra danh sách những môn học (mã môn học, tên môn học) phải học liền trước môn “Co So Du Lieu”.
SELECT MONHOC.MAMH, MONHOC.TENMH
FROM MONHOC
WHERE MAMH IN (
	SELECT MAMH_TRUOC
	FROM MONHOC
	JOIN DIEUKIEN ON MONHOC.MAMH = DIEUKIEN.MAMH
	WHERE MONHOC.TENMH = 'Co So Du Lieu')
GO

--III.10:	Môn “Cau Truc Roi Rac” là môn bắt buộc phải học liền trước những môn học (mã môn học, tên 
--môn học) nào.\
SELECT MONHOC.MAMH, MONHOC.TENMH
FROM MONHOC
WHERE MAMH IN (
	SELECT DIEUKIEN.MAMH
	FROM DIEUKIEN
	JOIN MONHOC ON DIEUKIEN.MAMH_TRUOC = MONHOC.MAMH
	WHERE MONHOC.TENMH = 'Cau Truc Roi Rac')
GO

--III.11: Tìm họ tên giáo viên dạy môn CTRR cho cả hai lớp “K11” và “K12” trong cùng học kỳ 1 năm 2006.
SELECT  MAGV, HOTEN
FROM GIAOVIEN
WHERE MAGV IN (
			SELECT GIAOVIEN.MAGV
			FROM GIAOVIEN
			JOIN GIANGDAY ON GIAOVIEN.MAGV = GIANGDAY.MAGV
			WHERE MAMH = 'CTRR' AND HOCKY = '1' AND NAM = '2006' AND MALOP = 'K11'
			UNION
			SELECT GIAOVIEN.MAGV
			FROM GIAOVIEN
			JOIN GIANGDAY ON GIAOVIEN.MAGV = GIANGDAY.MAGV
			WHERE MAMH = 'CTRR' AND HOCKY = '1' AND NAM = '2006' AND MALOP = 'K12'
			)
GO

--III.12: Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng chưa thi lại môn này
SELECT HV.MAHV, HV.HO, HV.TEN
FROM HOCVIEN HV
JOIN KETQUATHI KQ ON HV.MAHV = KQ.MAHV
WHERE KQ.MAMH = 'CSDL' AND KQ.KQUA = 'KHONG DAT'
AND HV.MAHV IN (
			SELECT KQT.MAHV
			FROM KETQUATHI KQT
			WHERE KQT.MAMH = 'CSDL'
			GROUP BY KQT.MAHV
			HAVING COUNT(*) = 1)
GO

--III.13: Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào.
SELECT GV.MAGV, GV.HOTEN
FROM GIAOVIEN GV
LEFT JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
WHERE GD.MAMH IS NULL
GO

--III.14: Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào thuộc 
--khoa giáo viên đó phụ trách.
SELECT MAGV, HOTEN
FROM GIAOVIEN
WHERE MAGV NOT IN (
		SELECT GV.MAGV
		FROM GIAOVIEN GV
		JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
		JOIN MONHOC MH ON GD.MAMH = MH.MAMH
		WHERE GV.MAKHOA = MH.MAKHOA
		)
GO

--III.15:Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn “Khong dat” hoặc thi lần 
--thứ 2 môn CTRR được 5 điểm
SELECT MAHV, HO + ' ' + TEN AS HOTEN
FROM HOCVIEN
WHERE  MALOP = 'K11'
AND MAHV IN	(
		SELECT DISTINCT MAHV
		FROM KETQUATHI
		WHERE KQUA = 'KHONG DAT' AND LANTHI > 2
		UNION
		SELECT DISTINCT MAHV
		FROM KETQUATHI
		WHERE DIEM = 5 AND LANTHI = 2 AND MAMH = 'CTRR'
	)
GO

--III.16: Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm học. 
SELECT MAGV, HOTEN
FROM GIAOVIEN
WHERE MAGV IN (
	SELECT MAGV
	FROM GIANGDAY
	WHERE MAMH = 'CTRR' 
	GROUP BY MAGV, HOCKY, NAM
	HAVING COUNT(MALOP) > 1
)
GO

--III.17: Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng). 
SELECT HV.MAHV, KQ.DIEM
FROM HOCVIEN HV
JOIN KETQUATHI KQ ON HV.MAHV = KQ.MAHV
WHERE KQ.MAMH = 'CSDL' 
AND KQ.LANTHI IN (
	SELECT TOP 1 KQT.LANTHI
	FROM KETQUATHI KQT
	WHERE HV.MAHV = KQT.MAHV AND KQT.MAMH = 'CSDL'
	ORDER BY KQT.LANTHI DESC
	)
GO

--III.18: Danh sách học viên và điểm thi môn “Co So Du Lieu” (chỉ lấy điểm cao nhất của các lần thi).
SELECT MAHV, DIEM
FROM KETQUATHI KQ1
WHERE MAMH = 'CSDL'
AND DIEM IN (
	SELECT TOP 1 DIEM
	FROM KETQUATHI KQ2
	WHERE MAMH = 'CSDL'
	AND KQ2.MAHV = KQ1.MAHV
	ORDER BY DIEM DESC)
GO

--III.19: Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất. 
SELECT TOP 1 WITH TIES MAKHOA, TENKHOA
FROM KHOA 
ORDER BY  NGTLAP ASC
GO

--III.20: Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”.
SELECT COUNT (*) SL_PGS_GS
FROM GIAOVIEN
WHERE HOCHAM IN ('GS', 'PGS')
GO

--III.21: Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa. 
SELECT MAKHOA, COUNT(*) SL
FROM GIAOVIEN
WHERE HOCVI IN ('CN', 'KS', 'Ths', 'TS', 'PTS')
GROUP BY MAKHOA
GO

--III.22: Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt).
SELECT MON, SL_DAT, SL_KHONGDAT
FROM (
	SELECT KQ.MAMH AS MON, COUNT(*) AS SL_DAT
	FROM KETQUATHI KQ
	WHERE KQ.KQUA = 'DAT'
	GROUP BY KQ.MAMH) AS TK_DAT
	JOIN 
	(
	SELECT KQ.MAMH, COUNT(*) AS SL_KHONGDAT
	FROM KETQUATHI KQ
	WHERE KQ.LANTHI = (
		SELECT TOP 1 KQT.LANTHI
		FROM KETQUATHI KQT
		WHERE KQT.MAMH = KQ.MAMH AND KQT.MAHV = KQ.MAHV
		GROUP BY KQT.MAMH, KQT.MAHV, KQT.LANTHI
		ORDER BY KQT.LANTHI DESC
		) AND KQ.KQUA = 'KHONG DAT'
	GROUP BY KQ.MAMH
	) AS TK_KHONGDAT
	ON TK_DAT.MON = TK_KHONGDAT.MAMH
GO

--III.23:  Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho lớp đó ít 
--nhất một môn học. 
SELECT MAGV, HOTEN
FROM GIAOVIEN
WHERE MAGV IN (
	SELECT MAGV
	FROM GIANGDAY GD
	JOIN LOP ON GD.MAGV = LOP.MAGVCN
	WHERE GD.MALOP = LOP.MALOP)
GO

--III.24: Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất. 
SELECT HO + ' ' + TEN AS HOTEN
FROM HOCVIEN
WHERE MAHV IN (
	SELECT TOP 1 WITH TIES TRGLOP
	FROM LOP
	ORDER BY SISO DESC)
GO

--III.25: Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả các lần thi). 
--lấy ho ten của lớp trưởng
SELECT HV.HO + ' ' + HV.TEN AS HOTEN
FROM HOCVIEN HV
JOIN LOP ON HV.MAHV = LOP.TRGLOP
--xét xem lớp trưởng đang xét có rớt trên 3 môn không
WHERE HV.MAHV IN(
	SELECT MAHV
	FROM KETQUATHI KQ1
	WHERE KQ1.MAHV = HV.MAHV
	-- tìm những MAMH không đạt ở TẤT CẢ CÁC LẦN THI của lớp trưởng đang xét
	AND KQ1.MAMH IN (
		SELECT KQ2.MAMH
		FROM KETQUATHI KQ2
		WHERE KQ2.MAHV = HV.MAHV
		GROUP BY KQ2.MAMH
		--nếu tổng số lần thi của môn học đang xét bằng với số lần thi của môn học đó với kết quả không đạt thì môn học này sẽ không đạt ở tất cả các lần thi 
		HAVING COUNT(*) = (
			SELECT COUNT(*)
			FROM KETQUATHI KQ3
			WHERE KQ3.MAHV = HV.MAHV AND KQ3.MAMH = KQ2.MAMH AND KQUA = 'KHONG DAT'
			GROUP BY KQ3.MAMH)
		)
	GROUP BY KQ1.MAHV
	HAVING COUNT(*) > 3
	)
GO

--III.26: Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất.
SELECT MAHV, HO + ' ' + TEN AS HOTEN
FROM HOCVIEN 
WHERE MAHV IN (
	SELECT TOP 1 WITH TIES MAHV
	FROM KETQUATHI KQ
	GROUP BY MAHV
	ORDER BY (
		SELECT COUNT(*)
		FROM KETQUATHI KQT
		WHERE KQT.MAHV = KQ.MAHV AND KQT.DIEM <= 10 AND KQT.DIEM >= 9
		)DESC
	)
GO

--III.27: Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất.
SELECT HV.MAHV, HV.HO + ' ' + HV.TEN AS HOTEN, LOP.MALOP
FROM HOCVIEN HV
JOIN LOP ON HV.MALOP = LOP.MALOP
WHERE HV.MAHV IN (
	SELECT TOP 1 HV1.MAHV
	FROM HOCVIEN HV1
	JOIN LOP L1 ON HV1.MALOP = L1.MALOP
	JOIN KETQUATHI KQ1 ON KQ1.MAHV = HV1.MAHV
	WHERE L1.MALOP = LOP.MALOP
	AND KQ1.DIEM >= 9
	GROUP BY HV1.MAHV
	ORDER BY COUNT(KQ1.MAMH) DESC) 
GO

--III.28: Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao nhiêu lớp. 
SELECT DISTINCT NAM, HOCKY, MAGV
	, COUNT(DISTINCT MALOP) AS SL_LOP
	, COUNT(DISTINCT MAMH) AS SL_MON
FROM GIANGDAY GD
GROUP BY NAM, HOCKY, MAGV
GO

--III.29: Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất. 
SELECT NAM, HOCKY, MAGV
FROM GIANGDAY GD1
GROUP BY NAM, HOCKY, MAGV
HAVING COUNT(*) >= ALL (
						SELECT COUNT(*)
						FROM GIANGDAY GD2
						WHERE GD2.NAM = GD1.NAM AND GD2.HOCKY = GD1.HOCKY
						GROUP BY NAM, HOCKY, MAGV)
GO

--III.30: Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1) nhất. 
SELECT MH.MAMH, MH.TENMH
FROM MONHOC MH
WHERE MH.MAMH IN (
	SELECT TOP 1 WITH TIES KQ.MAMH
	FROM KETQUATHI KQ
	WHERE KQ.LANTHI = 1 AND KQUA = 'KHONG DAT'
	GROUP BY KQ.MAMH
	ORDER BY COUNT(*) DESC
	)
GO

--III.31: Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1).
SELECT MAHV, HO + ' ' + TEN AS HOTEN
FROM HOCVIEN
WHERE MAHV NOT IN (
	SELECT MAHV
	FROM KETQUATHI 
	WHERE LANTHI = 1 AND KQUA = 'KHONG DAT')
AND MAHV IN (
	SELECT MAHV
	FROM KETQUATHI)
GO

--III.32:  Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng). 
SELECT DISTINCT HV.MAHV, HV.HO + ' ' + TEN AS HOTEN
FROM HOCVIEN HV
WHERE MAHV IN (
SELECT MAHV
FROM KETQUATHI KQ
WHERE LANTHI IN (
	SELECT COUNT(KQT.LANTHI)
	FROM KETQUATHI KQT
	WHERE KQT.MAHV = KQ.MAHV AND KQT.MAMH = KQ.MAMH
	)
	AND KQUA = 'DAT'
GROUP BY KQ.MAHV
HAVING COUNT(KQ.MAMH) = (
	SELECT COUNT(DISTINCT MAMH)
	FROM KETQUATHI KQT
	WHERE KQT.MAHV = KQ.MAHV
	GROUP BY KQT.MAHV
	)
)
GO

--III.33: Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt (chỉ xét lần thi thứ 1).
SELECT MAHV, HO + ' ' + TEN AS HOTEN
FROM HOCVIEN HV
WHERE MAHV IN (
	SELECT MAHV
	FROM KETQUATHI KQ
	WHERE KQ.MAHV = HV.MAHV AND KQUA = 'DAT' AND LANTHI = 1
	GROUP BY MAHV
	HAVING COUNT(MAMH) = (SELECT COUNT(DISTINCT MAMH)
							FROM KETQUATHI KQT
							WHERE KQT.MAHV = KQ.MAHV
							)
	)
GO


--III.34: * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt (chỉ xét lần thi sau cùng).
SELECT MAHV, HO + ' ' + TEN AS HOTEN
FROM HOCVIEN HV
WHERE MAHV IN (
	SELECT MAHV
	FROM KETQUATHI KQ
	WHERE KQUA = 'DAT'
	--LAN THI SAU CUNG
	AND LANTHI = (
		SELECT COUNT(LANTHI)
		FROM KETQUATHI KQT
		WHERE KQT.MAHV = KQ.MAHV AND KQT.MAMH = KQ.MAMH
		GROUP BY MAHV) 
	GROUP BY MAHV
	--TAT CA CAC LAN THI
	HAVING COUNT(MAMH) = (
		SELECT COUNT(DISTINCT MAMH)
		FROM KETQUATHI KQT
		WHERE KQT.MAHV = KQ.MAHV
		)
	)
GO

--III.35: Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần thi sau 
--cùng).
SELECT KQ1.MAMH, HV.MAHV, HV.HO + ' ' + HV.TEN AS HOTEN, KQ1.DIEM
FROM KETQUATHI KQ1
JOIN HOCVIEN HV ON KQ1.MAHV = HV.MAHV
WHERE HV.MAHV IN (
	SELECT TOP 1 WITH TIES MAHV
	FROM KETQUATHI KQ2
	WHERE KQ1.MAMH = KQ2.MAMH 
	AND LANTHI = (
		SELECT COUNT(LANTHI)
		FROM KETQUATHI KQ3
		WHERE KQ2.MAHV = KQ3.MAHV AND KQ2.MAMH = KQ3.MAMH
		)
	ORDER BY DIEM DESC
)
ORDER BY KQ1.MAMH
GO