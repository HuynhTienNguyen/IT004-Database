USE PartShipmentDB
GO

--1. Hiển thị thông tin (maNCC, tenNCC, thanhpho) của tất cả nhà cung cấp.
SELECT MANCC, TENNCC, THANHPHO
FROM NHACUNGCAP
GO

--2. Hiển thị thông tin của tất cả các phụ tùng
SELECT * FROM PHUTUNG
GO

--3. Hiển thị thông tin các nhà cung cấp ở thành phố London
SELECT * FROM NHACUNGCAP WHERE THANHPHO = 'LONDON'
GO

--4. Hiển thị mã phụ tùng, tên và màu sắc của tất cả các phụ tùng ở thành
--phố Paris.
SELECT MAPT, TENPT, MAUSAC
FROM PHUTUNG
WHERE THANHPHO = 'PARIS'
GO

--5. Hiển thị mã phụ tùng, tên, khối lượng của những phụ tùng có khối
--lượng lớn hơn 15.
SELECT MAPT, TENPT, KHOILUONG
FROM PHUTUNG
WHERE KHOILUONG >15

--6. Tìm những phụ tùng (maPT, tenPt, mausac) có khối lượng lớn hơn 15,
--không phải màu đỏ (red).
SELECT MAPT, TENPT, MAUSAC
FROM PHUTUNG
WHERE KHOILUONG > 15 AND MAUSAC != 'RED'

--7. Tìm những phụ tùng (maPT, tenPt, mausac) có khối lượng lớn hơn 15,
--màu sắc khác màu đỏ (red) và xanh (green)
SELECT MAPT, TENPT, MAUSAC
FROM PHUTUNG
WHERE KHOILUONG > 15 AND MAUSAC NOT IN ('RED', 'GREEN')

--8. Hiển thị những phụ tùng (maPT, tenPT, khối lượng) có khối lượng lớn
--hơn 15 và nhỏ hơn 20, sắp xếp theo tên phụ tùng.
SELECT MAPT, TENPT, MAUSAC
FROM PHUTUNG
WHERE KHOILUONG > 15 AND KHOILUONG < 20
ORDER BY TENPT

--9. Hiển thị những phụ tùng được vận chuyển bởi nhà cung cấp có mã số S1.
--Không hiển thị kết quả trùng. (sử dụng phép kết).
SELECT DISTINCT PT.MAPT, PT.TENPT
FROM PHUTUNG PT
JOIN VANCHUYEN VC ON PT.MAPT = VC.MAPT 
WHERE MANCC = 'S1'

--10. Hiển thị những nhà cung cấp vận chuyển phụ tùng có mã là P1 (sử dụng
--phép kết).
SELECT NCC.MANCC, TENNCC, TRANGTHAI, THANHPHO
FROM NHACUNGCAP NCC
JOIN VANCHUYEN VC ON NCC.MANCC = VC.MANCC
WHERE MAPT = 'P1'

--11. Hiển thị thông tin nhà cung cấp ở thành phố London và có vận chuyển
--phụ tùng của thành phố London. Không hiển thị kết quả trùng. (Sử dụng
--phép kết)
SELECT DISTINCT NCC.MANCC, TENNCC, TRANGTHAI, NCC.THANHPHO
FROM NHACUNGCAP NCC
JOIN VANCHUYEN VC ON NCC.MANCC = VC.MANCC
JOIN PHUTUNG PT ON PT.MAPT = VC.MAPT
WHERE NCC.THANHPHO = 'LONDON' AND PT.THANHPHO = 'LONDON'

--12. Lặp lại câu 9 nhưng sử dụng toán tử IN.
SELECT DISTINCT PT.MAPT, PT.TENPT
FROM PHUTUNG PT
WHERE MAPT IN (
	SELECT MAPT
	FROM VANCHUYEN
	WHERE MANCC = 'S1')

--13. Lặp lại câu 10 nhưng sử dụng toán tử IN
SELECT NCC.MANCC, TENNCC, TRANGTHAI, THANHPHO
FROM NHACUNGCAP NCC
WHERE MANCC IN (
	SELECT MANCC
	FROM VANCHUYEN
	WHERE MAPT = 'P1')

--14. Lặp lại câu 9 nhưng sử dụng toán tử EXISTS
SELECT DISTINCT PT.MAPT, PT.TENPT
FROM PHUTUNG PT
WHERE EXISTS (
	SELECT MAPT
	FROM VANCHUYEN VC
	WHERE MANCC = 'S1' AND PT.MAPT = VC.MAPT)

--15. Lặp lại câu 10 nhưng sử dụng toán tử EXISTS
SELECT NCC.MANCC, TENNCC, TRANGTHAI, THANHPHO
FROM NHACUNGCAP NCC
WHERE EXISTS (
	SELECT MANCC
	FROM VANCHUYEN VC
	WHERE MAPT = 'P1' AND NCC.MANCC = VC.MANCC)

--16. Lặp lại câu 11 nhưng sử dụng truy vấn con. Sử dụng toán tử IN.
SELECT NCC.MANCC, TENNCC, TRANGTHAI, NCC.THANHPHO
FROM NHACUNGCAP NCC
WHERE THANHPHO = 'LONDON'
AND MANCC IN (
	SELECT MANCC
	FROM VANCHUYEN VC
	WHERE MAPT IN (
		SELECT MAPT
		FROM PHUTUNG
		WHERE THANHPHO = 'LONDON'
	)
)

--17. Lặp lại câu 11 nhưng dùng truy vấn con. Sử dụng toán tử EXISTS.
SELECT NCC.MANCC, TENNCC, TRANGTHAI, NCC.THANHPHO
FROM NHACUNGCAP NCC
WHERE THANHPHO = 'LONDON'
AND EXISTS (
	SELECT *
	FROM VANCHUYEN VC
	WHERE EXISTS (
		SELECT *
		FROM PHUTUNG PT
		WHERE THANHPHO = 'LONDON'
		AND NCC.MANCC = VC.MANCC AND VC.MAPT = PT.MAPT
	)
)

--18. Tìm nhà cung cấp chưa vận chuyển bất kỳ phụ tùng nào. Sử dụng NOT IN.
SELECT *
FROM NHACUNGCAP
WHERE MANCC NOT IN (
	SELECT MANCC
	FROM VANCHUYEN)

--19. Tìm nhà cung cấp chưa vận chuyển bất kỳ phụ tùng nào. Sử dụng NOT EXISTS.
SELECT *
FROM NHACUNGCAP NCC
WHERE NOT EXISTS (
	SELECT *
	FROM VANCHUYEN VC
	WHERE NCC.MANCC = VC.MANCC)

--20. Tìm nhà cung cấp chưa vận chuyển bất kỳ phụ tùng nào. Sử dụng outer
--JOIN (Phép kết ngoài
SELECT NCC.MANCC, TENNCC, TRANGTHAI, NCC.THANHPHO
FROM NHACUNGCAP NCC
LEFT JOIN VANCHUYEN VC ON NCC.MANCC = VC.MANCC
WHERE VC.MAPT IS NULL

--21. Có tất cả nhiêu nhà cung cấp?
SELECT COUNT (*) SL_NCC
FROM NHACUNGCAP

--22. Có tất cả bao nhiêu nhà cung cấp ở London?
SELECT COUNT (*) SL_NCC_LONDON
FROM NHACUNGCAP
WHERE THANHPHO = 'LONDON'

--23. Hiển thị trị giá cao nhất, thấp nhất của trangthai của các nhà cung cấp.
SELECT MAX(TRANGTHAI) MAX_TRANGTHAI, MIN(TRANGTHAI) MIN_TRANGTHAI
FROM NHACUNGCAP

--24. Hiển thị giá trị cao nhất, thấp nhất của trangthai trong table
--nhacungcap ở thành phố London.
SELECT MAX(TRANGTHAI) MAX_TRANGTHAI, MIN(TRANGTHAI) MIN_TRANGTHAI
FROM NHACUNGCAP
WHERE THANHPHO = 'LONDON'

--25. Mỗi nhà cung cấp vận chuyển bao nhiêu phụ tùng? Chỉ hiển thị mã nhà
--cung cấp, tổng số phụ tùng đã vận chuyển.
SELECT NCC.MANCC, COUNT(*) SL_PT
FROM NHACUNGCAP NCC
JOIN VANCHUYEN VC ON NCC.MANCC = VC.MANCC
GROUP BY NCC.MANCC

--26. Mỗi nhà cung cấp vận chuyển bao nhiêu phụ tùng? Hiển thị mã nhà cung
--cấp, tên, thành phố của nhà cung cấp và tổng số phụ tùng đã vận chuyển
SELECT NCC.MANCC, NCC.TENNCC, NCC.THANHPHO, SUM(SOLUONG) SL_PT
FROM NHACUNGCAP NCC
JOIN VANCHUYEN VC ON NCC.MANCC = VC.MANCC
GROUP BY NCC.MANCC, NCC.TENNCC, NCC.THANHPHO

--27. Nhà cung cấp nào đã vận chuyển tổng cộng nhiều hơn 500 phụ tùng? Chỉ
--hiển thị mã nhà cung cấp
SELECT MANCC
FROM VANCHUYEN
GROUP BY MANCC
HAVING SUM(SOLUONG) > 500

--28. Nhà cung cấp nào đã vận chuyển nhiều hơn 300 phụ tùng màu đỏ (red).
--Chỉ hiển thị mã nhà cung cấp.
SELECT NCC.MANCC
FROM NHACUNGCAP NCC
JOIN VANCHUYEN VC ON NCC.MANCC = VC.MANCC
WHERE VC.MAPT IN (
	SELECT MAPT
	FROM PHUTUNG
	WHERE MAUSAC = 'RED')
GROUP BY NCC.MANCC
HAVING SUM(VC.SOLUONG) > 300

--29. Nhà cung cấp nào đã vận chuyển nhiều hơn 300 phụ tùng màu đỏ (red).
--Hiển thị mã nhà cung cấp, tên, thành phố và số lượng phụ tùng màu đỏ đã
--vận chuyển.
SELECT NCC.MANCC, NCC.TENNCC, NCC.THANHPHO, SUM(VC.SOLUONG) SL_SP_RED
FROM NHACUNGCAP NCC
JOIN VANCHUYEN VC ON NCC.MANCC = VC.MANCC
WHERE VC.MAPT IN (
	SELECT MAPT
	FROM PHUTUNG
	WHERE MAUSAC = 'RED')
GROUP BY NCC.MANCC, NCC.TENNCC, NCC.THANHPHO
HAVING SUM(VC.SOLUONG) > 300

--30. Có bao nhiêu nhà cung cấp ở mỗi thành phố.
SELECT THANHPHO, COUNT(MANCC) AS SL_NCC
FROM NHACUNGCAP
GROUP BY THANHPHO

--31. Nhà cung cấp nào đã vận chuyển nhiều phụ tùng nhất. Hiển thị tên nhà
--cung cấp và số lượng phụ tùng đã vận chuyển.
SELECT TOP 1 WITH TIES NCC.TENNCC, SUM(VC.SOLUONG) AS SL
FROM NHACUNGCAP NCC
LEFT JOIN VANCHUYEN VC ON NCC.MANCC = VC.MANCC
GROUP BY NCC.MANCC, NCC.TENNCC
ORDER BY SUM(VC.SOLUONG) DESC

--32. Thành phố nào có cả nhà cung cấp và phụ tùng.
SELECT DISTINCT THANHPHO
FROM NHACUNGCAP
INTERSECT
SELECT DISTINCT THANHPHO
FROM PHUTUNG

--33. Viết câu lệnh SQL để insert nhà cung cấp mới: S6, Duncan, 30, Paris.
INSERT INTO NHACUNGCAP VALUES ('S6', 'Duncan', '30', 'Paris' )

--34.Viết câu lệnh SQL để thay đổi thanh phố S6 (ở câu 33) thành Sydney.
UPDATE NHACUNGCAP
SET THANHPHO = 'Sydney'
WHERE MANCC = 'S6'

--35. Viết câu lệnh SQL tăng trangthai của nhà cung cấp ở London lên thêm 10.
UPDATE NHACUNGCAP
SET TRANGTHAI = TRANGTHAI + 10
WHERE THANHPHO = 'LONDON'

--36. Viết câu lệnh SQL xoá nhà cung cấp S6
DELETE FROM NHACUNGCAP
WHERE MANCC = 'S6'

