---ROBERTO HERRERA--
--SCRIPTS PARA BASE DE DATOS ---
--- LA BASE DE DATOS ESTA EN AZURE SQL ---
---sqlsrvgt.database.windows.net---

-- Tabla base (recursiva)
CREATE TABLE dbo.Organigrama (
    Id          INT          IDENTITY(1,1) PRIMARY KEY,
    Puesto      NVARCHAR(80) NOT NULL,
    Nombre      NVARCHAR(80) NOT NULL,
    JefeId      INT          NULL,
    CONSTRAINT FK_Organigrama_Organigrama
        FOREIGN KEY (JefeId) REFERENCES dbo.Organigrama(Id)
);

-- Datos de ejemplo
INSERT dbo.Organigrama (Puesto, Nombre, JefeId) VALUES
('Gerente','Pedro', NULL),
('Sub Gerente','Pablo', 1),
('Supervisor','Juan', 2),
('Sub Gerente','José', 1),
('Supervisor','Carlos', 4),
('Supervisor','Diego', 4);


--un solo stored procedures utilizando CTE para obtener árbol (flatten con nivel + ruta)

CREATE OR ALTER PROCEDURE dbo.Org_GetTree
AS
BEGIN
    SET NOCOUNT ON;
    ;WITH OrgCTE AS (
	-- para los que no tengan jefe
        SELECT 
            o.Id, o.Puesto, o.Nombre, o.JefeId,
            0 AS Nivel, -- creamos campo Ruta que sera un nvarchar, que sera un casteo del Id concatenando ceros de derecha a izquierda( 6 ceros)
            CAST(RIGHT('000000'+CAST(o.Id AS VARCHAR(6)),6) AS NVARCHAR(4000)) AS Ruta
        FROM dbo.Organigrama o
        WHERE o.JefeId IS NULL
        UNION ALL
		-- para los que tengan jefe
        SELECT 
            c.Id, c.Puesto, c.Nombre, c.JefeId,
            p.Nivel + 1,
            p.Ruta + '-' + RIGHT('000000'+CAST(c.Id AS VARCHAR(6)),6)
        FROM dbo.Organigrama c
        JOIN OrgCTE p ON p.Id = c.JefeId
    )
    SELECT Id, Puesto, Nombre, JefeId, Nivel, Ruta
    FROM OrgCTE
    ORDER BY Ruta; -- orden natural jerárquico
END


--crud

CREATE OR ALTER PROCEDURE dbo.Org_Insert
    @Puesto NVARCHAR(80), @Nombre NVARCHAR(80), @JefeId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @JefeId IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.Organigrama WHERE Id=@JefeId)
        THROW 50001, 'JefeId no existe', 1;

    INSERT dbo.Organigrama (Puesto, Nombre, JefeId)
    VALUES (@Puesto, @Nombre, @JefeId);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO

CREATE OR ALTER PROCEDURE dbo.Org_Update
    @Id INT, @Puesto NVARCHAR(80), @Nombre NVARCHAR(80), @JefeId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS(SELECT 1 FROM dbo.Organigrama WHERE Id=@Id)
        THROW 50002, 'Aun no existe registro', 1;

    IF @JefeId = @Id
        THROW 50003, 'Un nodo no puede ser su propio jefe', 1; --50003

    IF @JefeId IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.Organigrama WHERE Id=@JefeId)
        THROW 50004, 'JefeId no existe', 1;

    UPDATE dbo.Organigrama
    SET Puesto=@Puesto, Nombre=@Nombre, JefeId=@JefeId
    WHERE Id=@Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.Org_Delete
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT 1 FROM dbo.Organigrama WHERE JefeId=@Id)
        THROW 50005, 'No puede eliminar un nodo con hijos', 1; --50005

    DELETE dbo.Organigrama WHERE Id=@Id;
END
GO
