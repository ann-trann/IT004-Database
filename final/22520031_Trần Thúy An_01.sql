CREATE DATABASE QLBC
USE QLBC

CREATE TABLE VUNGMIEN(
	MAVM CHAR(5) NOT NULL,
	TENVM VARCHAR(20),
	CHIEUDAIBB INT,
	CONSTRAINT PK_VM PRIMARY KEY (MAVM)
)
CREATE TABLE TAU(
	SOIMO CHAR(6),
	TENTAU VARCHAR(30),
	CONGDUNG VARCHAR(20),
	CONSTRAINT PK_TAU PRIMARY KEY (SOIMO)
)
CREATE TABLE BENCANG(
	MABC CHAR(5),
	TENBC VARCHAR(30),
	SLTOIDA INT,
	LOAIBC VARCHAR(10),
	CHIPHI MONEY,
	MAVM CHAR(5),
	CONSTRAINT PK_BC PRIMARY KEY (MABC)
)
CREATE TABLE CAPCANG(
	MABC CHAR(5),
	SOIMO CHAR(6),
	NGAYCC SMALLDATETIME,
	NGAYRC SMALLDATETIME,
	SOTIEN MONEY,
	CONSTRAINT PK_CC PRIMARY KEY (MABC, SOIMO)
)

------------

ALTER TABLE BENCANG ADD CONSTRAINT FK_BC_VM FOREIGN KEY (MAVM) REFERENCES VUNGMIEN(MAVM)

ALTER TABLE CAPCANG ADD CONSTRAINT FK_CC_BC FOREIGN KEY (MABC) REFERENCES BENCANG(MABC)
ALTER TABLE CAPCANG ADD CONSTRAINT FK_CC_TAU FOREIGN KEY (SOIMO) REFERENCES TAU(SOIMO)

------------

INSERT INTO VUNGMIEN VALUES ('VM001', 'Mien Bac', 633.88)
INSERT INTO VUNGMIEN VALUES ('VM002', 'Mien Trung', 2089.35)
INSERT INTO VUNGMIEN VALUES ('VM003', 'Mien Nam', 934.46)

INSERT INTO TAU VALUES ('IMO101', 'CMA CGM Montmartre', 'Cho hang')
INSERT INTO TAU VALUES ('IMO102', 'Taxiarchis', 'Cho dau')
INSERT INTO TAU VALUES ('IMO103', 'Arafura Lily', 'Du lich')

INSERT INTO BENCANG VALUES ('BC201', 'Cang Sai Gon', 100, 'Loai A', 1840000, 'VM003')
INSERT INTO BENCANG VALUES ('BC202', 'Cang Hai Phong', 50, 'Loai B', 2314990, 'VM001')
INSERT INTO BENCANG VALUES ('BC203', 'Cang Da Nang', 529, 'Loai A', 1820390, 'VM002')

INSERT INTO CAPCANG VALUES ('BC201', 'IMO101', '01/12/2023 0:00', '02/12/2023 0:00', 22080000)
INSERT INTO CAPCANG VALUES ('BC201', 'IMO102', '01/12/2023 0:00', '01/12/2023 1:00', 1840000)
INSERT INTO CAPCANG VALUES ('BC202', 'IMO103', '01/12/2023 0:00', '02/12/2023 23:00', 55559760)

---------------------------

-- 3.
UPDATE BENCANG
SET SLTOIDA = 500
WHERE TENBC = 'Cang Da Nang'


-- 4.
ALTER TABLE CAPCANG
ADD CONSTRAINT chk_ngay CHECK (NGAYRC >= NGAYCC)


-- 6.
SELECT BC.TENBC, T.TENTAU, CC.NGAYCC
FROM CAPCANG CC
	 JOIN BENCANG BC ON BC.MABC = CC.MABC
	 JOIN TAU T ON T.SOIMO = CC.SOIMO
	 JOIN VUNGMIEN VM ON VM.MAVM = BC.MAVM
WHERE VM.CHIEUDAIBB > 300
	  AND VM.TENVM = 'Mien Nam'
	  AND BC.LOAIBC = 'Loai B'


-- 7.
SELECT CONCAT(BC.MABC, ' - ', TENBC) AS BENCANG, SOIMO, CHIPHI, DATEPART(HOUR, NGAYRC) AS GIO, SOTIEN
FROM BENCANG BC
	JOIN CAPCANG CC ON CC.MABC = BC.MABC
WHERE MONTH(NGAYCC) = 1 AND YEAR(NGAYCC) = 2024


-- 8. 
SELECT TOP 3 WITH TIES CC.MABC,
					   T.SOIMO,
					   T.TENTAU,
					   SUM(SOTIEN) AS TONGPHICC
FROM CAPCANG CC
	 JOIN TAU T ON T.SOIMO = CC.SOIMO
GROUP BY CC.MABC, T.SOIMO, T.TENTAU
ORDER BY SUM(SOTIEN) ASC


-- 9
SELECT TOP 1 WITH TIES
	   BC.TENBC,
	   T.SOIMO,
	   T.TENTAU,
	   COUNT(*) AS SOLANCC
FROM CAPCANG CC 
	 JOIN TAU T ON T.SOIMO = CC.SOIMO
	 JOIN BENCANG BC ON BC.MABC = CC.MABC
WHERE MONTH(CC.NGAYCC) = 10
GROUP BY BC.MABC, BC.TENBC, CC.MABC, T.SOIMO, T.TENTAU
ORDER BY COUNT(*) DESC

-- 10. 
SELECT DISTINCT TENVM
FROM VUNGMIEN VM1
WHERE NOT EXISTS (
	SELECT VM2.MAVM
	FROM VUNGMIEN VM2
		JOIN BENCANG BC ON BC.MAVM = VM2.MAVM
		JOIN CAPCANG CC ON CC.MABC = BC.MABC
		JOIN TAU ON TAU.SOIMO = CC.SOIMO
	WHERE VM2.MAVM = VM1.MAVM
		  AND TAU.CONGDUNG NOT IN ('Cho khach', 'Quan su')
)

-- 11.
SELECT TAU.SOIMO, TENTAU
FROM TAU
WHERE NOT EXISTS(
			SELECT *
			FROM BENCANG BC
			WHERE NOT EXISTS(
						SELECT *
						FROM CAPCANG CC
						WHERE CC.SOIMO = TAU.SOIMO AND CC.MABC = BC.MABC	))





