use QLBH_2020
set dateformat dmy

--I------------------

--I.2 Thêm vào thuộc tính GHICHU có kiểu dữ liệu varchar(20) cho quan hệ SANPHAM
alter table SANPHAM add GHICHU varchar(20)

--I.3 Thêm vào thuộc tính LOAIKH có kiểu dữ liệu là tinyint cho quan hệ KHACHHANG
alter table KHACHHANG add LOAIKH tinyint

--I.4 Sửa kiểu dữ liệu của thuộc tính GHICHU trong quan hệ SANPHAM thành varchar(100)
alter table SANPHAM alter column GHICHU varchar(100)

--I.5 Xóa thuộc tính GHICHU trong quan hệ SANPHAM
alter table SANPHAM drop column GHICHU

--I.6 Làm thế nào để thuộc tính LOAIKH trong quan hệ KHACHHANG có thể lưu các giá trị là: “Vang lai”, “Thuong xuyen”, “Vip”, …
alter table KHACHHANG alter column LOAIKH varchar(30)

--I.7 Đơn vị tính của sản phẩm chỉ có thể là (“cay”,”hop”,”cai”,”quyen”,”chuc”)
alter table SANPHAM add check(DVT='cay' or DVT='hop' or DVT='cai' or DVT='quyen' or DVT='chuc')

--I.8 Giá bán của sản phẩm từ 500 đồng trở lên.
alter table SANPHAM add check(GIA >= 500)

--I.9 Mỗi lần mua hàng, khách hàng phải mua ít nhất 1 sản phẩm
alter table CTHD add check(SL >= 1)


--II-----------------

--II.2 Tạo quan hệ SANPHAM1 chứa toàn bộ dữ liệu của quan hệ SANPHAM. Tạo quan hệ KHACHHANG1 chứa toàn bộ dữ liệu của quan hệ KHACHHANG
select * into SANPHAM1
from SANPHAM

select * into KHACHHANG1
from KHACHHANG

--II.3 Cập nhật giá tăng 5% đối với những sản phẩm do “Thai Lan” sản xuất (cho quan hệ SANPHAM1)
update SANPHAM1
set GIA = GIA * 1.05
where NUOCSX = 'Thai Lan'

--II.4 Cập nhật giá giảm 5% đối với những sản phẩm do “Trung Quoc” sản xuất có giá từ 10.000 trở xuống (cho quan hệ SANPHAM1)
update SANPHAM1
set GIA = GIA * 1.05
where NUOCSX = 'Trung Quoc' and GIA <= 10000

--II.5 
/*Cập nhật giá trị LOAIKH là “Vip” đối với những khách hàng đăng ký thành viên trước 
ngày 1/1/2007 có doanh số từ 10.000.000 trở lên hoặc khách hàng đăng ký thành viên từ 
1/1/2007 trở về sau có doanh số từ 2.000.000 trở lên (cho quan hệ KHACHHANG1).
update KHACHHANG1*/
set LOAIKH = 'VIP'
where (NGDK < '01/01/2007' and DOANHSO >= 10000000) or (NGDK >= '01/01/2007' and DOANHSO >= 2000000)


--III----------------

--III.1 In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất.
select MASP, TENSP
from SANPHAM
where NUOCSX = 'Trung Quoc'

--III.2 In ra danh sách các sản phẩm (MASP, TENSP) có đơn vị tính là “cay”, ”quyen”
select MASP, TENSP
from SANPHAM
where DVT = 'cay' or DVT = 'quyen'

--III.3 In ra danh sách các sản phẩm (MASP,TENSP) có mã sản phẩm bắt đầu là “B” và kết thúc là “01”.
select MASP, TENSP
from SANPHAM
where MASP like 'B_01'

--III.4 
/*In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quốc” sản xuất có giá từ 30.000 
đến 40.000.*/
select MASP, TENSP
from SANPHAM
where NUOCSX = 'Trung Quoc' and GIA >= 30000 and GIA <= 40000

--III.5
/*phẩm (MASP,TENSP) do “Trung Quoc” hoặc “Thai Lan” sản 
xuất có giá từ 30.000 đến 40.000.*/
select MASP, TENSP
from SANPHAM
where (NUOCSX = 'Trung Quoc' or NUOCSX = 'Thai Lan') and (GIA >= 30000 and GIA <= 40000)

--III.6
/*In ra các số hóa đơn, trị giá hóa đơn bán ra trong ngày 1/1/2007 và ngày 2/1/2007.*/
select SOHD, TRIGIA
from HOADON
where NGHD = '01/01/2007' or NGHD = '02/01/2007'

--III.7
/*In ra các số hóa đơn, trị giá hóa đơn trong tháng 1/2007, sắp xếp theo ngày (tăng dần) và 
trị giá của hóa đơn (giảm dần)*/
select SOHD, TRIGIA
from HOADON
where NGHD >= '01/01/2007' and NGHD < '01/02/2007'
order by NGHD ASC, TRIGIA DESC

--III.8
/*In ra danh sách các khách hàng (MAKH, HOTEN) đã mua hàng trong ngày 1/1/2007*/
select kh.MAKH, HOTEN
from KHACHHANG kh join HOADON hd on kh.MAKH = hd.MAKH
where NGHD = '01/01/2007'

--III.9
/*In ra số hóa đơn, trị giá các hóa đơn do nhân viên có tên “Nguyen Van B” lập trong ngày 
28/10/2006*/
select SOHD, TRIGIA
from NHANVIEN nv join HOADON hd on nv.MANV = hd.MANV
where nv.HOTEN = 'Nguyen Van B'

--III.10
/*In ra danh sách các sản phẩm (MASP,TENSP) được khách hàng có tên “Nguyen Van A” 
mua trong tháng 10/2006*/
select SANPHAM.MASP, SANPHAM.TENSP
from SANPHAM
join CTHD on SANPHAM.MASP = CTHD.MASP
join HOADON on HOADON.SOHD = CTHD.SOHD
join KHACHHANG on  HOADON.MAKH = KHACHHANG.MAKH
where KHACHHANG.HOTEN = 'Nguyen Van A' 
and HOADON.NGHD >= '01/10/2006' and HOADON.NGHD <= '31/10/2006'

--III.11
/*Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”.*/
select distinct HOADON.SOHD
from HOADON
join CTHD on HOADON.SOHD = CTHD.SOHD
where CTHD.MASP = 'BB01' or CTHD.MASP = 'BB02'

--III.12
/*Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm 
mua với số lượng từ 10 đến 20.*/
select distinct HOADON.SOHD
from HOADON
join CTHD on HOADON.SOHD = CTHD.SOHD
join SANPHAM on CTHD.MASP = SANPHAM.MASP
where (SANPHAM.MASP = 'BB01' or SANPHAM.MASP = 'BB02') and CTHD.SL >= '10' and CTHD.SL <= '20'

--III.13
/*Tìm các số hóa đơn mua cùng lúc 2 sản phẩm có mã số “BB01” và “BB02”, mỗi sản 
phẩm mua với số lượng từ 10 đến 20.*/
select distinct HOADON.SOHD
from HOADON
join CTHD on HOADON.SOHD = CTHD.SOHD
join SANPHAM on CTHD.MASP = SANPHAM.MASP
where SANPHAM.MASP = 'BB01' and CTHD.SL >= '10' and CTHD.SL <= '20'
intersect 
select distinct HOADON.SOHD
from HOADON
join CTHD on HOADON.SOHD = CTHD.SOHD
join SANPHAM on CTHD.MASP = SANPHAM.MASP
where SANPHAM.MASP = 'BB02' and CTHD.SL >= '10' and CTHD.SL <= '20'

--III.14
/*In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất hoặc các sản 
phẩm được bán ra trong ngày 1/1/2007.*/
select distinct sp.MASP, sp.TENSP
from SANPHAM sp
join CTHD ct on ct.MASP = sp.MASP
join HOADON hd  on hd.SOHD = ct.SOHD
where sp.NUOCSX = 'Trung Quoc' and hd.NGHD = '01/01/2007'

--III.15
/*In ra danh sách các sản phẩm (MASP,TENSP) không bán được*/
select MASP, TENSP
from SANPHAM 
except
select SANPHAM.MASP, SANPHAM.TENSP
from SANPHAM
join CTHD on SANPHAM.MASP = CTHD.MASP
join HOADON on HOADON.SOHD = CTHD.SOHD

--III.16
/*In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006.*/
select SP.MASP, SP.TENSP
from SANPHAM SP
where SP.MASP not in (select SP.MASP
					from SANPHAM SP 
					join CTHD on SP.MASP = CTHD.MASP
					join HOADON HD on CTHD.SOHD = HD.SOHD
					where HD.NGHD > '31/12/2005' and HD.NGHD < '1/1/2007')

--III.17
/*In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất không bán 
được trong năm 2006.*/
SELECT SP.MASP, SP.TENSP
FROM SANPHAM SP
WHERE SP.NUOCSX = 'Trung Quoc'
EXCEPT
SELECT SP.MASP, SP.TENSP
FROM SANPHAM SP
JOIN CTHD ON SP.MASP = CTHD.MASP
WHERE SP.NUOCSX = 'Trung Quoc'

---III.18: Tìm số hóa đơn đã mua tất cả các sản phẩm do Singapore sản xuất.
SELECT SOHD--, CTHD.MASP
FROM SANPHAM SP JOIN CTHD ON SP.MASP = CTHD.MASP
WHERE NUOCSX = 'Singapore'
GROUP BY SOHD
HAVING COUNT(DISTINCT SP.MASP) = ( 
									SELECT COUNT(DISTINCT MASP) 
									FROM SANPHAM
									WHERE SANPHAM.NUOCSX = 'Singapore'
									);

--III.19: Tìm số hóa đơn trong năm 2006 đã mua ít nhất tất cả các sản phẩm do Singapore sản xuất.
--C1 trong list SOHD năm 2006 không tồn tại bộ giá trị nào có NUOCSX là Singapore mà không có (HOADON.SOHD=CTHD.SOHD AND CTHD.MASP=SANPHAM.MASP)
SELECT SOHD
FROM HOADON
WHERE YEAR(NGHD) = 2006 
AND NOT EXISTS (SELECT * 
				FROM SANPHAM 
				WHERE NUOCSX = 'Singapore'
				AND NOT EXISTS (SELECT * 
								FROM CTHD 
								WHERE HOADON.SOHD=CTHD.SOHD 
								AND CTHD.MASP=SANPHAM.MASP))


/* CÁCH 2
SELECT HD.SOHD
FROM HOADON HD
JOIN CTHD ON HD.SOHD = CTHD.SOHD
JOIN SANPHAM SP ON CTHD.MASP = SP.MASP
WHERE YEAR(HD.NGHD) = '2006' AND SP.NUOCSX = 'Singapore'
GROUP BY HD.SOHD
HAVING COUNT(DISTINCT SP.MASP) = 
	(SELECT COUNT(*)
	FROM SANPHAM
	WHERE NUOCSX = 'Singapore')
*/

--III.20: Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua? 
SELECT COUNT(*) KETQUA
FROM HOADON HD
WHERE HD.MAKH IS NULL

--III.21: Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006. 
SELECT COUNT(DISTINCT SP.MASP) 'SO SP KHAC NHAU'
FROM SANPHAM SP
JOIN CTHD ON SP.MASP = CTHD.MASP
JOIN HOADON HD ON CTHD.SOHD = HD.SOHD
WHERE YEAR(HD.NGHD) = '2006'

--III.22: Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu ? 
SELECT MIN(HD.TRIGIA) 'GIA TRI MIN', MAX(HD.TRIGIA) 'GIA TRI MAX'
FROM HOADON HD

--III.23: Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu?
SELECT AVG(HD.TRIGIA)
FROM HOADON HD
WHERE YEAR(HD.NGHD) = '2006'

--III.24: Tính doanh thu bán hàng trong năm 2006.
SELECT SUM(HD.TRIGIA)
FROM HOADON HD
WHERE YEAR(HD.NGHD) = '2006'

--III.25: Tìm số hóa đơn có trị giá cao nhất trong năm 2006.
/*CÁCH 1*/
SELECT TOP 1 HD.TRIGIA-- WITH TIES sẽ lấy cả những giá trị bị trùng lập
FROM HOADON HD
WHERE YEAR(HD.NGHD) = '2006'
ORDER BY HD.TRIGIA DESC--The TOP N WITH TIES clause is not allowed without a corresponding ORDER BY clause.

/* CÁCH 2
SELECT HD.TRIGIA
FROM HOADON HD
WHERE YEAR(HD.NGHD) = '2006' 
AND HD.TRIGIA = (
				SELECT MAX(TRIGIA)
				FROM HOADON
				WHERE YEAR(NGHD) = '2006')
*/

--III.26: Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006.
SELECT KH.HOTEN
FROM KHACHHANG KH
JOIN HOADON HD ON KH.MAKH = HD.MAKH
WHERE YEAR(HD.NGHD) = '2006' AND HD.TRIGIA = (SELECT MAX(TRIGIA)
												FROM HOADON
												WHERE YEAR(NGHD) = 2006)

/* cách khác 
SELECT HOTEN 
FROM KHACHHANG 
WHERE MAKH IN (SELECT MAKH
				FROM HOADON
				WHERE YEAR(NGHD) = 2006
					AND TRIGIA = (SELECT MAX(TRIGIA)
									FROM HOADON
									WHERE YEAR(NGHD) = 2006))
*/

--III.27: In ra danh sách 3 khách hàng đầu tiên (MAKH, HOTEN) sắp xếp theo doanh số giảm dần.
SELECT TOP 3 KH.MAKH, KH.HOTEN
FROM KHACHHANG KH
ORDER BY DOANHSO DESC

--III.28: In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất. 
SELECT MASP, TENSP
FROM SANPHAM 
WHERE GIA IN (
			SELECT TOP 3 WITH TIES GIA
			FROM SANPHAM
			ORDER BY GIA DESC
			)

--III.29: In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 
--trong 3 mức giá cao nhất (của tất cả các sản phẩm).
SELECT MASP, TENSP
FROM SANPHAM 
WHERE NUOCSX = 'Thai Lan' AND GIA IN (
			SELECT TOP 3 WITH TIES GIA
			FROM SANPHAM
			ORDER BY GIA DESC
			)

--III.30: In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 
--trong 3 mức giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất).
SELECT MASP, TENSP
FROM SANPHAM 
WHERE NUOCSX = 'Trung Quoc' AND GIA IN (
			SELECT TOP 3 GIA
			FROM SANPHAM
			WHERE NUOCSX = 'Trung Quoc'
			ORDER BY GIA DESC
			)

--III.31: In ra danh sách khách hàng nằm trong 3 hạng cao nhất (xếp hạng theo doanh số).
SELECT TOP 3 WITH TIES MAKH, HOTEN, DOANHSO
FROM KHACHHANG
ORDER BY DOANHSO DESC

--III.32: Tính tổng số sản phẩm do “Trung Quoc” sản xuất. 
SELECT COUNT(*) 'TONG SAN PHAM DO TQ SAN XUAT'
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc'

--III.33: Tính tổng số sản phẩm của từng nước sản xuất. 
SELECT NUOCSX, COUNT(MASP) 'SL SANPHAM'
FROM SANPHAM
GROUP BY NUOCSX

--III.34: Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm. 
SELECT NUOCSX, MAX(GIA) 'GIA CAO NHAT', MIN(GIA) 'GIA THAP NHAT', AVG(GIA) 'GIA TRUNG BINH'
FROM SANPHAM
GROUP BY NUOCSX

--III.35: Tính doanh thu bán hàng mỗi ngày.
SELECT NGHD, SUM(TRIGIA) 'DOANH THU'
FROM HOADON
GROUP BY NGHD

--III.36: Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006.
SELECT MASP, SUM(SL) 'SL TUNG SAN PHAM'
FROM HOADON JOIN CTHD ON HOADON.SOHD = CTHD.SOHD
WHERE NGHD BETWEEN '01/10/2006' AND '31/10/2006'
GROUP BY MASP
/*CÁCH KHÁC 
SELECT MASP, SUM(SL) AS TONGSLSP
FROM CTHD 
WHERE SOHD IN (SELECT SOHD
				FROM HOADON
				WHERE MONTH(NGHD) = 10 
					AND YEAR(NGHD) = 2006)
GROUP BY MASP
*/

--III.37: Tính doanh thu bán hàng của từng tháng trong năm 2006.
SELECT MONTH(NGHD) 'THANG', SUM(TRIGIA) 'DOANH THU'
FROM HOADON
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD)

--III.38: Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau.
SELECT SOHD, COUNT(MASP) 'SL SANPHAM'
FROM CTHD
GROUP BY SOHD
HAVING COUNT(MASP) > 3

--III.39: Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau). 
SELECT CTHD.SOHD
FROM CTHD
JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
WHERE SANPHAM.NUOCSX = 'Viet Nam'
GROUP BY CTHD.SOHD
HAVING COUNT(SANPHAM.MASP) = 3

--III.40: Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất. 
SELECT MAKH, HOTEN
FROM KHACHHANG
WHERE MAKH IN (
			SELECT TOP 1 MAKH
			FROM HOADON
			GROUP BY MAKH
			ORDER BY COUNT(SOHD) DESC)

--III.41: Tháng mấy trong năm 2006, doanh số bán hàng cao nhất ?
SELECT TOP 1 MONTH(NGHD) 'THANG', SUM(TRIGIA) 'DOANHSO'
FROM HOADON 
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD)
ORDER BY SUM(TRIGIA) DESC

--III.42: Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006. 
SELECT MASP, TENSP
FROM SANPHAM
WHERE MASP IN (
			SELECT TOP 1 WITH TIES MASP
			FROM CTHD 
			JOIN HOADON HD ON CTHD.SOHD = HD.SOHD
			WHERE YEAR(HD.NGHD) = 2006
			GROUP BY CTHD.MASP
			ORDER BY SUM(CTHD.SL) ASC)

--III.43: Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất.
SELECT B.MAXNUOCSX, S.MASP, S.TENSP, GIAMAX
FROM (
	SELECT NUOCSX MAXNUOCSX, MAX(GIA) GIAMAX
	FROM SANPHAM
	GROUP BY NUOCSX) AS B LEFT JOIN SANPHAM S
ON S.NUOCSX = B.MAXNUOCSX
WHERE B.GIAMAX = S.GIA

/* BIỂU DIỄN ON VỚI 2 ĐIỀU KIỆN
SELECT B.MAXNUOCSX, S.MASP, S.TENSP, GIAMAX
FROM (
	SELECT NUOCSX MAXNUOCSX, MAX(GIA) GIAMAX
	FROM SANPHAM
	GROUP BY NUOCSX) AS B LEFT JOIN SANPHAM S
ON S.NUOCSX = B.MAXNUOCSX AND B.GIAMAX = S.GIA
*/

--III.44: Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau. 
SELECT NUOCSX
FROM SANPHAM 
GROUP BY NUOCSX
HAVING COUNT(DISTINCT GIA) >= 3

--III.45: Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều 
--nhất.
SELECT TOP 1 TOP10DS.MAKH, COUNT(HD.SOHD) SOLANMUA
FROM (
	SELECT TOP 10 MAKH, MAX(DOANHSO) DOANHSO
	FROM KHACHHANG
	GROUP BY MAKH
	ORDER BY MAX(DOANHSO) DESC
	) AS TOP10DS
JOIN HOADON AS HD ON TOP10DS.MAKH = HD.MAKH
GROUP BY TOP10DS.MAKH
ORDER BY COUNT(HD.SOHD) DESC
