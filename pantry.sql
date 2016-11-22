--
-- BASE DE DONNEES PANTRY
--

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

-- ====================================================================================================
-- TABLE RECIPE
--
CREATE TABLE IF NOT EXISTS Recipe(
	idreci SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id recette', -- id recette
	lbreci VARCHAR(60) NOT NULL COMMENT 'libelle recette', -- libelle recette
	dereci TEXT NOT NULL COMMENT 'description recette', -- description recette
	nvreci TINYINT UNSIGNED NOT NULL COMMENT 'niveau difficulte recette', -- niveau de difficulte recette
	tpreci TIME NOT NULL COMMENT 'temps preparation recette', -- temps de preparation
	tcreci TIME NULL COMMENT 'temps cuisson recette', -- temps de cuisson
	imreci MEDIUMBLOB NULL COMMENT 'image recette', -- image du recipe
	npreci TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'nombre personnes recette', -- nombre de personnes
	ntreci TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'note 5 etoiles recette', -- notation 5 etoiles de la recette
	tyreci ENUM('AMUSE BOUCHE', 'ENTREE', 'PLAT PRINCIPAL', 'DESERT', 'HORS D\'OEUVRE') NOT NULL COMMENT 'type de plat', -- type de plat
	CONSTRAINT pk_idreci PRIMARY KEY (idreci), -- cle primaire sur idreci
	CONSTRAINT un_recipe UNIQUE (lbreci), -- contrainte unicite sur libelle recette
	CONSTRAINT ck_nvreci CHECK (nvreci BETWEEN 1 AND 10), -- contrainte check sur nvreci
	CONSTRAINT ck_npreci CHECK (npreci BETWEEN 1 AND 20), -- contrainte check sur npreci
	CONSTRAINT ck_ntreci CHECK (ntreci BETWEEN 0 AND 5) -- contrainte check sur ntreci
	)ENGINE=InnoDB DEFAULT CHARSET=UTF8 AUTO_INCREMENT=1;

	DELIMITER $$
	CREATE TRIGGER trg_recipe_insert BEFORE INSERT ON Recipe
	FOR EACH ROW
		BEGIN
		-- trigger de mise en forme du libelle
    SET NEW.lbreci = CONCAT(UCASE(LEFT(NEW.lbreci, 1)), SUBSTRING(LOWER(NEW.lbreci), 2));
	END $$

	CREATE TRIGGER trg_recipe_update BEFORE UPDATE ON Recipe
	FOR EACH ROW
		BEGIN
		-- trigger de mise en forme du libelle
    SET NEW.lbreci = CONCAT(UCASE(LEFT(NEW.lbreci, 1)), SUBSTRING(LOWER(NEW.lbreci), 2));
	END $$
	DELIMITER ;

-- ====================================================================================================
-- TABLE UTILISATEUR
--
CREATE TABLE IF NOT EXISTS Utilisateur(
	iduser SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id user', -- id utilisateur
	ajuser TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'date ajout utilisateur', -- date ajout utilisateur
	mduser TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'date modification utilisateur', -- date modification utilisateur
	lguser VARCHAR(50) NOT NULL COMMENT 'email et login user', -- email et login utilisateur
	pwuser VARCHAR(255) NOT NULL COMMENT 'mot de passe user', -- mot de passe utilisateur
	biuser TINYINT UNSIGNED DEFAULT 0 NOT NULL COMMENT 'preference en bio', -- preference en bio de 1 a 5
	rauser TINYINT UNSIGNED DEFAULT 50 NOT NULL COMMENT 'rayon action', -- preference rayon action
	vguser BOOLEAN NOT NULL DEFAULT 0 COMMENT 'preference vegetarien',
	CONSTRAINT pk_iduser PRIMARY KEY (iduser), -- cle primaire sur iduser
	CONSTRAINT un_user UNIQUE (lguser,pwuser), -- contrainte unicite sur login et mot de passe
	CONSTRAINT ck_biuser CHECK (biuser BETWEEN 0 AND 5), -- contrainte check sur biuser
	CONSTRAINT ck_rauser CHECK (rauser BETWEEN 1 AND 50) -- contrainte check sur rauser
	)ENGINE=InnoDB DEFAULT CHARSET=UTF8 AUTO_INCREMENT=1;

	DELIMITER $$
	CREATE TRIGGER trg_utilisateur_insert BEFORE INSERT ON Utilisateur
	FOR EACH ROW
		BEGIN
			-- trigger pour limiter le mot de passe entre 6 et 30 caracteres
			IF CHAR_LENGTH(NEW.pwuser) < 6 OR CHAR_LENGTH(NEW.pwuser) > 30
				THEN
				SIGNAL SQLSTATE '44000'
				SET MESSAGE_TEXT = 'le mot de passe doit etre compris entre 6 et 30 caracteres';
			END IF;
			-- trigger pour valider le format de l'adresse email
			IF NEW.lguser REGEXP '^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$' = 0
				THEN
				SIGNAL SQLSTATE '44000'
				SET MESSAGE_TEXT = 'adresse email non valide';
			END IF;
		END $$

	CREATE TRIGGER trg_utilisateur_update BEFORE UPDATE ON Utilisateur
	FOR EACH ROW
		BEGIN
			-- trigger pour limiter le mot de passe entre 6 et 30 caracteres
			IF CHAR_LENGTH(NEW.pwuser) < 6 OR CHAR_LENGTH(NEW.pwuser) > 30
				THEN
				SIGNAL SQLSTATE '44000'
				SET MESSAGE_TEXT = 'le mot de passe doit etre compris entre 6 et 30 caracteres';
			END IF;
			-- trigger pour valider le format de l'adresse email
			IF NEW.lguser REGEXP '^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$' = 0
				THEN
				SIGNAL SQLSTATE '44000'
				SET MESSAGE_TEXT = 'adresse email non valide';
			END IF;
		END $$
	DELIMITER ;

-- ====================================================================================================
-- TABLE CATEGORY
--
CREATE TABLE IF NOT EXISTS Category(
	lbctgr VARCHAR(50) NOT NULL COMMENT 'libelle category', -- libelle category
	CONSTRAINT pk_lbctgr PRIMARY KEY (lbctgr) -- cle primaire sur lbctgr
	)ENGINE=InnoDB DEFAULT CHARSET=UTF8;

	DELIMITER $$
	CREATE TRIGGER trg_category_insert BEFORE INSERT ON Category
	FOR EACH ROW
		BEGIN
		-- trigger de mise en forme du libelle
    SET NEW.lbctgr = CONCAT(UCASE(LEFT(NEW.lbctgr, 1)), SUBSTRING(LOWER(NEW.lbctgr), 2));
	END $$

	CREATE TRIGGER trg_category_update BEFORE UPDATE ON Category
	FOR EACH ROW
		BEGIN
		-- trigger de mise en forme du libelle
    SET NEW.lbctgr = CONCAT(UCASE(LEFT(NEW.lbctgr, 1)), SUBSTRING(LOWER(NEW.lbctgr), 2));
	END $$
	DELIMITER ;

-- ====================================================================================================
-- TABLE STORE
--
CREATE TABLE IF NOT EXISTS Store(
	idstor SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id store', -- id du store
	nmstor VARCHAR(40) NOT NULL COMMENT 'nom store', -- nom du store
	hdstor TIME NULL COMMENT 'horaires debut store', -- horaires ouverture store
	hfstor TIME NULL COMMENT 'horaires fin store', -- horaires fermeture store
	jrstor MEDIUMINT UNSIGNED NULL COMMENT 'jours ouverture store', -- jours ouverture store format 1111110
	ntstor TINYINT UNSIGNED DEFAULT 0 NULL COMMENT 'note 5 etoiles store', -- notation 5 etoiles du store
	fvstor BOOLEAN NOT NULL DEFAULT 0 COMMENT 'favoris store', -- favoris store
	bostor BOOLEAN NOT NULL DEFAULT 0 COMMENT 'bio store', -- bio store
	dvstor BOOLEAN NOT NULL DEFAULT 0 COMMENT 'drive store', -- drive store
	CONSTRAINT pk_idstor PRIMARY KEY (idstor), -- cle primaire sur idstor
	CONSTRAINT un_store UNIQUE (nmstor), -- contrainte unicite sur le nom du store
	CONSTRAINT ck_ntstor CHECK (ntstor BETWEEN 0 AND 5), -- contrainte check sur ntstor
	CONSTRAINT ck_fvstor CHECK (fvstor BETWEEN 0 AND 1), -- contrainte check sur fvstor
	CONSTRAINT ck_bostor CHECK (bostor BETWEEN 0 AND 1), -- contrainte check sur bostor
	CONSTRAINT ck_dvstor CHECK (dvstor BETWEEN 0 AND 1) -- contrainte check sur dvstor
	)ENGINE=InnoDB DEFAULT CHARSET=UTF8 AUTO_INCREMENT=1;

-- ====================================================================================================
-- TABLE ADRESS
--
CREATE TABLE IF NOT EXISTS Adress(
	idadre SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id adresse', -- id adresse
	nmadre SMALLINT UNSIGNED NOT NULL COMMENT 'numero rue adresse', -- numero de rue adresse
	ruadre VARCHAR(200) NOT NULL COMMENT 'rue adresse', -- rue adresse
	cpadre VARCHAR(10) NOT NULL COMMENT 'code postal adresse', -- code postal adresse
	viadre VARCHAR(100) NOT NULL COMMENT 'ville adresse', -- ville adresse
	paadre VARCHAR(100) NOT NULL COMMENT 'pays adresse', -- pays adresse
	pcadre BOOLEAN NOT NULL DEFAULT 1 COMMENT 'adresse principale', -- principale adresse
	lvadre BOOLEAN NOT NULL DEFAULT 1 COMMENT 'adresse livraison', -- livraison adresse
	iduser SMALLINT UNSIGNED NULL COMMENT 'fk_iduser', -- fk_iduser
	idstor SMALLINT UNSIGNED NULL COMMENT 'fk_idstor', -- fk_idstor
	CONSTRAINT pk_idadre PRIMARY KEY (idadre), -- cle primaire sur idadre
	CONSTRAINT fk_utilisateur_adress FOREIGN KEY (iduser) REFERENCES Utilisateur (iduser) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_store_adress FOREIGN KEY (idstor) REFERENCES Store (idstor) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT un_utilisateur UNIQUE (iduser), -- contrainte unicite sur iduser
	CONSTRAINT un_store UNIQUE (idstor), -- contrainte unicite sur idstor
	CONSTRAINT ck_pcadre CHECK (pcadre BETWEEN 0 AND 1), -- contrainte check sur pcadre
	CONSTRAINT ck_lvadre CHECK (lvadre BETWEEN 0 AND 1), -- contrainte check sur lvadre
	CONSTRAINT ck_iduser CHECK (iduser IS NOT NULL OR idstor IS NOT NULL) -- contrainte check sur pcadre
	)ENGINE=InnoDB DEFAULT CHARSET=UTF8 AUTO_INCREMENT=1;

	DELIMITER $$
	CREATE TRIGGER trg_adress_insert BEFORE INSERT ON Adress
	FOR EACH ROW
		BEGIN
		-- trigger pour empecher que iduser et idstor soient tous les deux null
			IF NEW.iduser IS NULL AND NEW.idstor IS NULL
			THEN
				SIGNAL SQLSTATE '44000'
				SET MESSAGE_TEXT = 'iduser et idstor ne peuvent pas etre null tous les deux';
			END IF;
		-- trigger de mise en forme des donnes
    	SET NEW.cpadre = UCASE(NEW.cpadre);
    	SET NEW.viadre = UCASE(NEW.viadre);
    	SET NEW.ruadre = UCASE(NEW.ruadre);
    	SET NEW.paadre = UCASE(NEW.paadre);
		END $$

	CREATE TRIGGER trg_adress_update BEFORE UPDATE ON Adress
	FOR EACH ROW
		BEGIN
		-- trigger pour empecher que iduser et idstor soient tous les deux null
			IF NEW.iduser IS NULL AND NEW.idstor IS NULL
			THEN
				SIGNAL SQLSTATE '44000'
				SET MESSAGE_TEXT = 'iduser et idstor ne peuvent pas etre null tous les deux';
			END IF;
		-- trigger de mise en forme des donnes
		SET NEW.cpadre = UCASE(NEW.cpadre);
		SET NEW.viadre = UCASE(NEW.viadre);
		SET NEW.ruadre = UCASE(NEW.ruadre);
		SET NEW.paadre = UCASE(NEW.paadre);
		END $$
	DELIMITER ;

-- ====================================================================================================
-- TABLE FOOD
--
CREATE TABLE IF NOT EXISTS Food(
	idfood SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id food', -- id du food
	lbfood VARCHAR(50) NOT NULL COMMENT 'libelle food', -- libelle du food
	cdfood SET('') NOT NULL COMMENT 'code food', -- code food
	dlfood DATE NULL COMMENT 'date limite conso food', -- date limite de consommation du food
	ntfood TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'note 5 etoiles food', -- notation 5 etoiles du food
	blfood BOOLEAN NOT NULL DEFAULT 0 COMMENT 'blacklist food', -- blacklist du food : 0.no 1.yes
	etfood TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'etat food', -- etat du food : 0.tobuy 1.bought 2.eat
	fafood BOOLEAN NOT NULL DEFAULT 0 COMMENT 'favoris food', -- favoris food : 0.no 1.yes
	lafood VARCHAR(50) NULL COMMENT 'label food', -- label du food bio rainforest ab
	imfood MEDIUMBLOB NULL COMMENT 'image food', -- image du food
	lbctgr VARCHAR(50) NOT NULL COMMENT 'fk_lbctgr non null', -- cle etrangere sur lbctgr
	CONSTRAINT pk_idfood PRIMARY KEY (idfood), -- cle primaire sur idfood
	CONSTRAINT fk_food_category FOREIGN KEY (lbctgr) REFERENCES Category (lbctgr), -- cle etrangere sur lbctgr
	CONSTRAINT un_food UNIQUE (lbfood,lafood), -- contrainte unicite sur le libelle et le label
	CONSTRAINT ck_ntfood CHECK (ntfood BETWEEN 0 AND 5), -- contrainte check sur ntfood
	CONSTRAINT ck_etfood CHECK (etfood BETWEEN 0 AND 2), -- contrainte check sur etfood
	CONSTRAINT ck_blfood CHECK (blfood BETWEEN 0 AND 1), -- contrainte check sur blfood
	CONSTRAINT ck_fafood CHECK (fafood BETWEEN 0 AND 1) -- contrainte check sur fafood
	)ENGINE=InnoDB DEFAULT CHARSET=UTF8 AUTO_INCREMENT=1;

	DELIMITER $$
	CREATE TRIGGER trg_food_insert BEFORE INSERT ON Food
	FOR EACH ROW
		BEGIN
		-- trigger de mise en forme des donnes
		SET NEW.lbfood = CONCAT(UCASE(LEFT(NEW.lbfood, 1)), SUBSTRING(LOWER(NEW.lbfood), 2));
		SET NEW.lafood = CONCAT(UCASE(LEFT(NEW.lafood, 1)), SUBSTRING(LOWER(NEW.lafood), 2));
		END $$

	CREATE TRIGGER trg_food_update BEFORE UPDATE ON Food
	FOR EACH ROW
		BEGIN
		-- trigger de mise en forme des donnes
		SET NEW.lbfood = CONCAT(UCASE(LEFT(NEW.lbfood, 1)), SUBSTRING(LOWER(NEW.lbfood), 2));
		SET NEW.lafood = CONCAT(UCASE(LEFT(NEW.lafood, 1)), SUBSTRING(LOWER(NEW.lafood), 2));
		END $$
	DELIMITER ;

-- ====================================================================================================
-- TABLE TOOL
--
CREATE TABLE IF NOT EXISTS Tool(
	lbtool VARCHAR(50) NOT NULL COMMENT 'libelle tool', -- libelle tool
	detool VARCHAR(255) NULL COMMENT 'description tool', -- description tool
	imtool MEDIUMBLOB NULL COMMENT 'image tool', -- image tool
	CONSTRAINT pk_lbtool PRIMARY KEY (lbtool) -- cle primaire sur lbtool
	)ENGINE=InnoDB DEFAULT CHARSET=UTF8;

	DELIMITER $$
	CREATE TRIGGER trg_tool_insert BEFORE INSERT ON Tool
	FOR EACH ROW
		BEGIN
		-- trigger de mise en forme des donnes
		SET NEW.lbtool = CONCAT(UCASE(LEFT(NEW.lbtool, 1)), SUBSTRING(LOWER(NEW.lbtool), 2));
		END $$

	CREATE TRIGGER trg_tool_update BEFORE UPDATE ON Tool
	FOR EACH ROW
		BEGIN
		-- trigger de mise en forme des donnes
		SET NEW.lbtool = CONCAT(UCASE(LEFT(NEW.lbtool, 1)), SUBSTRING(LOWER(NEW.lbtool), 2));
		END $$
	DELIMITER ;

-- ====================================================================================================
-- TABLE ALLERGENE
--
CREATE TABLE IF NOT EXISTS Allergene(
	lbalgn VARCHAR(50) NOT NULL COMMENT 'libelle allergene', -- libelle allergene
	CONSTRAINT pk_lbalgn PRIMARY KEY (lbalgn) -- cle primaire sur lbalgn
	)ENGINE=InnoDB DEFAULT CHARSET=UTF8;

	DELIMITER $$
	CREATE TRIGGER trg_allergene_insert BEFORE INSERT ON Allergene
	FOR EACH ROW
		BEGIN
		-- trigger de mise en forme des donnes
		SET NEW.lbalgn = CONCAT(UCASE(LEFT(NEW.lbalgn, 1)), SUBSTRING(LOWER(NEW.lbalgn), 2));
		END $$

	CREATE TRIGGER trg_allergene_update BEFORE UPDATE ON Allergene
	FOR EACH ROW
		BEGIN
		-- trigger de mise en forme des donnes
		SET NEW.lbalgn = CONCAT(UCASE(LEFT(NEW.lbalgn, 1)), SUBSTRING(LOWER(NEW.lbalgn), 2));
		END $$
	DELIMITER ;

-- ====================================================================================================
-- TABLE SHOP
--
CREATE TABLE IF NOT EXISTS Shop(
	idshop SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id shop', -- id shop
	dtshop TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'date et heure shop', -- date et heure du shop
	mdshop ENUM('CB', 'ESPECE', 'CHEQUE', 'TIQUET') NOT NULL COMMENT 'mode achat shop', -- mode achat du shop
	qtshop TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'quantite food', -- quantite du food
	htshop DECIMAL(4,2) UNSIGNED NULL COMMENT 'prix ht food', -- prix hors taxe du food
	tcshop DECIMAL(4,2) UNSIGNED NULL COMMENT 'prix ttc food', -- prix ttc du food
	pkshop DECIMAL(4,2) UNSIGNED NULL COMMENT 'prix kilo food', -- prix au kilo du food
	psshop DECIMAL(4,2) UNSIGNED NULL COMMENT 'poids food', -- poids du food
	rmshop DECIMAL(4,2) NULL COMMENT 'remise food', -- remise du food
	orshop VARCHAR(50) NULL COMMENT 'origine food', -- origine du food
	iduser SMALLINT UNSIGNED NULL COMMENT 'fk_iduser not null', -- cle etrangere sur iduser
	idstor SMALLINT UNSIGNED NULL COMMENT 'fk_idstor not null', -- cle etrangere sur idstor
	CONSTRAINT pk_idshop PRIMARY KEY (idshop), -- cle primaire sur idshop
	CONSTRAINT fk_shop_utilisateur FOREIGN KEY (iduser) REFERENCES Utilisateur (iduser) ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT fk_shop_store FOREIGN KEY (idstor) REFERENCES Store (idstor) ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT ck_qtshop CHECK (qtshop BETWEEN 1 AND 100), -- contrainte check sur qtshop
	CONSTRAINT ck_psshop CHECK (psshop BETWEEN 0.01 AND 1000.00) -- contrainte check sur psshop
	)ENGINE=InnoDB DEFAULT CHARSET=UTF8 AUTO_INCREMENT=1;

-- ====================================================================================================
-- TABLE UTILISATEUR_TOOL
--
CREATE TABLE IF NOT EXISTS Utilisateur_Tool(
	iduser SMALLINT UNSIGNED NOT NULL COMMENT 'id user', -- cle etrangere sur iduser
	lbtool VARCHAR(50) NOT NULL COMMENT 'id tool', -- cle etrangere sur lbtool
	CONSTRAINT pk_iduser_lbtool PRIMARY KEY (iduser, lbtool), -- cle primaire sur iduser et lbtool
	CONSTRAINT fk_tool_utilisateur FOREIGN KEY (iduser) REFERENCES Utilisateur (iduser) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_utilisateur_tool FOREIGN KEY (lbtool) REFERENCES Tool (lbtool) ON DELETE CASCADE ON UPDATE CASCADE
	)ENGINE=InnoDB DEFAULT CHARSET=UTF8 AUTO_INCREMENT=1;

-- ====================================================================================================
-- TABLE USER_ALLERGENE
--
CREATE TABLE IF NOT EXISTS Utilisateur_Allergene(
	iduser SMALLINT UNSIGNED NOT NULL COMMENT 'id user', -- cle etrangere sur iduser
	lbalgn VARCHAR(50) NOT NULL COMMENT 'id allergene', -- cle etrangere sur lbalgn
	CONSTRAINT pk_iduser_lbalgn PRIMARY KEY (iduser, lbalgn), -- cle primaire sur iduser et lbalgn
	CONSTRAINT fk_allergene_utilisateur FOREIGN KEY (iduser) REFERENCES Utilisateur (iduser) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_utilisateur_allergene FOREIGN KEY (lbalgn) REFERENCES Allergene (lbalgn) ON DELETE CASCADE ON UPDATE CASCADE
	)ENGINE=InnoDB DEFAULT CHARSET=UTF8 AUTO_INCREMENT=1;

-- ====================================================================================================
-- TABLE FOOD_ALLERGENE
--
CREATE TABLE IF NOT EXISTS Food_Allergene(
	idfood SMALLINT UNSIGNED NOT NULL COMMENT 'id food', -- cle etrangere sur idfood
	lbalgn VARCHAR(50) NOT NULL COMMENT 'id algn', -- cle etrangere sur lbalgn
	indpre TINYINT UNSIGNED NOT NULL COMMENT 'indice de presence allergene', -- indice de presence allergene
	CONSTRAINT pk_idfood_lbalgn PRIMARY KEY (idfood, lbalgn), -- cle primaire sur idfood et lbalgn
	CONSTRAINT ck_indpre CHECK (indpre BETWEEN 0 AND 2), -- contrainte check sur indpre
	CONSTRAINT fk_allergene_food FOREIGN KEY (idfood) REFERENCES Food (idfood) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_food_allergene FOREIGN KEY (lbalgn) REFERENCES Allergene (lbalgn) ON DELETE CASCADE ON UPDATE CASCADE
	)ENGINE=InnoDB DEFAULT CHARSET=UTF8 AUTO_INCREMENT=1;

-- ====================================================================================================
-- TABLE FOOD_SHOP
--
CREATE TABLE IF NOT EXISTS Food_Shop(
	idfood SMALLINT UNSIGNED NOT NULL COMMENT 'id food', -- cle etrangere sur idfood
	idshop SMALLINT UNSIGNED NOT NULL COMMENT 'id shop', -- cle etrangere sur idshop
	CONSTRAINT pk_idfood_idshop PRIMARY KEY (idfood, idshop), -- cle primaire sur idfood et idshop
	CONSTRAINT fk_shop_food FOREIGN KEY (idfood) REFERENCES Food (idfood) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_food_shop FOREIGN KEY (idshop) REFERENCES Shop (idshop) ON DELETE CASCADE ON UPDATE CASCADE
	)ENGINE=InnoDB DEFAULT CHARSET=UTF8 AUTO_INCREMENT=1;

-- ====================================================================================================
-- TABLE FOOD_RECIPE
--
CREATE TABLE IF NOT EXISTS Food_Recipe(
	idfood SMALLINT UNSIGNED NOT NULL COMMENT 'id food', -- cle etrangere sur idfood
	idreci SMALLINT UNSIGNED NOT NULL COMMENT 'id reci', -- cle etrangere sur idreci
	CONSTRAINT pk_idfood_idreci PRIMARY KEY (idfood, idreci), -- cle primaire sur idfood et idreci
	CONSTRAINT fk_recipe_food FOREIGN KEY (idfood) REFERENCES Food (idfood) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_food_recipe FOREIGN KEY (idreci) REFERENCES Recipe (idreci) ON DELETE CASCADE ON UPDATE CASCADE
	)ENGINE=InnoDB DEFAULT CHARSET=UTF8 AUTO_INCREMENT=1;

-- ====================================================================================================
-- TABLE TOOL_RECIPE
--
CREATE TABLE IF NOT EXISTS Tool_Recipe(
	lbtool VARCHAR(50) NOT NULL COMMENT 'id tool', -- cle etrangere sur lbtool
	idreci SMALLINT UNSIGNED NOT NULL COMMENT 'id reci', -- cle etrangere sur idreci
	CONSTRAINT pk_lbtool_idreci PRIMARY KEY (lbtool, idreci), -- cle primaire sur lbtool et idreci
	CONSTRAINT fk_recipe_tool FOREIGN KEY (lbtool) REFERENCES Tool (lbtool) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_tool_recipe FOREIGN KEY (idreci) REFERENCES Recipe (idreci) ON DELETE CASCADE ON UPDATE CASCADE
	)ENGINE=InnoDB DEFAULT CHARSET=UTF8 AUTO_INCREMENT=1;

