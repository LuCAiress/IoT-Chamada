CREATE DATABASE  IF NOT EXISTS `iot` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `iot`;
-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: localhost    Database: iot
-- ------------------------------------------------------
-- Server version	8.0.42

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `alunos_materias`
--

DROP TABLE IF EXISTS `alunos_materias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alunos_materias` (
  `id` int NOT NULL AUTO_INCREMENT,
  `aluno_id` int DEFAULT NULL,
  `materia_id` int DEFAULT NULL,
  `faltas` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_alunos_materias_aluno` (`aluno_id`),
  KEY `fk_alunos_materias_materia` (`materia_id`),
  CONSTRAINT `fk_alunos_materias_aluno` FOREIGN KEY (`aluno_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `fk_alunos_materias_materia` FOREIGN KEY (`materia_id`) REFERENCES `materias` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alunos_materias`
--

LOCK TABLES `alunos_materias` WRITE;
/*!40000 ALTER TABLE `alunos_materias` DISABLE KEYS */;
INSERT INTO `alunos_materias` VALUES (1,2,1,0),(8,3,1,0),(9,4,1,0),(10,5,1,4),(11,2,2,0),(12,3,2,0),(13,4,2,0),(14,5,2,0);
/*!40000 ALTER TABLE `alunos_materias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aulas`
--

DROP TABLE IF EXISTS `aulas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aulas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `materia_id` int DEFAULT NULL,
  `hora_inicio` time NOT NULL,
  `dias_semana` smallint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_aulas_materia` (`materia_id`),
  CONSTRAINT `fk_aulas_materia` FOREIGN KEY (`materia_id`) REFERENCES `materias` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aulas`
--

LOCK TABLES `aulas` WRITE;
/*!40000 ALTER TABLE `aulas` DISABLE KEYS */;
INSERT INTO `aulas` VALUES (1,1,'19:10:00',0),(2,2,'19:10:00',5);
/*!40000 ALTER TABLE `aulas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `materias`
--

DROP TABLE IF EXISTS `materias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `materias` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `professor_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_materias_professor` (`professor_id`),
  CONSTRAINT `fk_materias_professor` FOREIGN KEY (`professor_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `materias`
--

LOCK TABLES `materias` WRITE;
/*!40000 ALTER TABLE `materias` DISABLE KEYS */;
INSERT INTO `materias` VALUES (1,'Internet das Coisas',1),(2,'Real Time Systems',6);
/*!40000 ALTER TABLE `materias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipos_user`
--

DROP TABLE IF EXISTS `tipos_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tipos_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tipo` varchar(16) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipos_user`
--

LOCK TABLES `tipos_user` WRITE;
/*!40000 ALTER TABLE `tipos_user` DISABLE KEYS */;
INSERT INTO `tipos_user` VALUES (1,'Professor'),(2,'Aluno');
/*!40000 ALTER TABLE `tipos_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `rfid` char(8) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `tipo_user_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_usuarios_tipo_user` (`tipo_user_id`),
  CONSTRAINT `fk_usuarios_tipo_user` FOREIGN KEY (`tipo_user_id`) REFERENCES `tipos_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'4BE1D73F','Fábio',1),(2,'BA71B415','Pedro Paulo',2),(3,'E32BEE09','Lucas Lima',2),(4,'2357490A','Marcos Roriz',2),(5,'93AF710A','Gabriel Holsback',2),(6,'C776ADA9','Hudson',1);
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-06-02 19:46:41
