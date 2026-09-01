-- Bai lab 6 -- du lieu mau cho MySQL
-- File nay duoc container tu chay o lan khoi tao dau tien.
USE app_MSSV;

CREATE TABLE nhanvien (
  id     INT PRIMARY KEY AUTO_INCREMENT,
  ho_ten VARCHAR(100) NOT NULL,
  email  VARCHAR(100),
  phong  VARCHAR(50),
  luong  DECIMAL(12,0)              -- COT NHAY CAM: chi truong phong duoc xem
);

CREATE TABLE hoadon (
  id        INT PRIMARY KEY AUTO_INCREMENT,
  so_hd     VARCHAR(30) NOT NULL,
  khach     VARCHAR(100),
  so_tien   DECIMAL(12,0),
  ngay_lap  DATE,
  nguoi_lap VARCHAR(50)
);

INSERT INTO nhanvien (ho_ten, email, phong, luong) VALUES
  ('Le Tuan Anh',   'anh@MSSV.lab',   'Ke toan',   15000000),
  ('Vu Dinh Bach',  'bach@MSSV.lab',  'Ke toan',   14000000),
  ('Ly Van Chien',  'chien@MSSV.lab', 'Kinh doanh',18000000),
  ('Dao Manh Cuong','cuong@MSSV.lab', 'Ke toan',   25000000);

INSERT INTO hoadon (so_hd, khach, so_tien, ngay_lap, nguoi_lap) VALUES
  ('HD-001', 'Cong ty A', 12000000, '2026-01-15', 'Le Tuan Anh'),
  ('HD-002', 'Cong ty B',  8500000, '2026-01-18', 'Vu Dinh Bach'),
  ('HD-003', 'Cong ty C', 23000000, '2026-02-02', 'Le Tuan Anh'),
  ('HD-004', 'Cong ty A',  5400000, '2026-02-11', 'Vu Dinh Bach'),
  ('HD-005', 'Cong ty D', 31000000, '2026-02-20', 'Ly Van Chien');
