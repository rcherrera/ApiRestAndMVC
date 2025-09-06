# 📂 Proyecto: Organigrama Empresarial (.NET 8 + SQL Server)

Este repositorio contiene dos aplicaciones complementarias desarrolladas en **ASP.NET Core 8** que en conjunto permiten **gestionar y visualizar un organigrama jerárquico de empleados** a partir de una tabla recursiva en SQL Server.

---

## ⚙️ Org.Api (Web API REST)

Proyecto **API RESTful** construido con ASP.NET Core:

- Endpoints bajo `/api/Organigrama` para operaciones CRUD:
  - **GET** `/tree` → devuelve la jerarquía completa en formato árbol.  
  - **POST** → inserta un nuevo nodo (empleado/puesto).  
  - **PUT {id}** → actualiza un nodo existente.  
  - **DELETE {id}** → elimina un nodo (validando dependencias).
- Usa **Stored Procedures** en SQL Server:
  - Org_GetTree
  - Org_Insert  
  - Org_Update
  - Org_Delete
- Manejo de errores con códigos semánticos (400, 404, 409) en lugar de 500.
- Incluye **Swagger/OpenAPI** para documentación y pruebas.
- Implementación con **Dapper** y conexiones SQL seguras (Encrypt=True).

---

## 🎨 Org.Mvc (Frontend MVC)

Proyecto **ASP.NET Core MVC** que consume la API:

- Interfaz web que renderiza el **árbol jerárquico de empleados** usando recursividad en vistas parciales.
- Formularios para **crear, editar y eliminar** empleados/puestos desde la UI.
- Manejo de feedback al usuario con **Bootstrap 5** (mensajes de éxito/error, validación de formularios).
- Servicios centralizados (`OrgApiClient`) para consumir la API REST.
- Separación de capas:
  - **Models** → entidades de UI  
  - **Controllers** → orquestan llamadas al API  
  - **Views** → despliegan el organigrama y formularios.

---

## 🛠️ Tecnologías utilizadas

- **.NET 8**  
- **ASP.NET Core MVC**  
- **ASP.NET Core Web API**  
- **SQL Server + Stored Procedures**  
- **Dapper**  
- **Bootstrap 5**  
- **Swagger / Swashbuckle**

---

## 📊 Diagramas

### 1) Arquitectura (MVC + API + SQL)

```mermaid
flowchart LR
  subgraph Client["Usuario (Browser)"]
    V["Views Razor"]
  end

  subgraph MVC["Org.Mvc (ASP.NET Core MVC)"]
    C["Controllers"]
    S["OrgApiClient (HttpClient)"]
  end

  subgraph API["Org.Api (ASP.NET Core Web API)"]
    A["OrganigramaController"]
    R["OrgRepo (Dapper)"]
  end
```

```mermaid
erDiagram
    Organigrama {
        INT Id PK
        NVARCHAR(80) Puesto
        NVARCHAR(80) Nombre
        INT JefeId FK "nullable -> self(Id)"
    }
    Organigrama ||--o{ Organigrama : Jefe
```

```mermaid
graph TD
    A["1 Gerente Pedro"]
    B["2 SubGerente Pablo"]
    C["3 Supervisor Juan"]
    D["4 SubGerente José"]
    E["5 Supervisor Carlos"]
    F["6 Supervisor Diego"]

    A --> B --> C
    A --> D --> E
    D --> F
```

```mermaid
flowchart LR
  subgraph API["/api/Organigrama"]
    GET_TREE["GET /tree → 200"]
    POST_ITEM["POST / → 201/200"]
    PUT_ITEM["PUT /{id} → 204"]
    DEL_ITEM["DELETE /{id} → 204"]
  end

```
Endpoints
```mermaid
sequenceDiagram
    participant U as Usuario
    participant IIS2 as IIS (MVC - site2)
    participant K2 as Kestrel (Org.Mvc.dll)
    participant IIS1 as IIS (API - site1)
    participant K1 as Kestrel (Org.Api.dll)
    participant DB as SQL Server

    U->>IIS2: GET https://.../site2/
    IIS2->>K2: Proxy (aspNetCoreModuleV2)
    K2-->>U: Renderiza Index

    U->>K2: Acciones (crear/editar/eliminar)
    K2->>IIS1: HttpClient → https://.../site1/api/Organigrama/...
    IIS1->>K1: Proxy (aspNetCoreModuleV2)
    K1->>DB: SPs (GetTree/Insert/Update/Delete)
    DB-->>K1: Resultado
    K1-->>K2: 200/201/204/4xx
    K2-->>U: Redirect + mensajes
```


```mermaid
mindmap
  root((Organigrama Empresarial))
    Sistema
      NET 8
      ASP.NET Core
      SQL Server
      Swagger
    Org.Api Web API
      Endpoints
        GET api-Organigrama-tree
        POST api-Organigrama
        PUT api-Organigrama-id
        DELETE api-Organigrama-id
      Logica de datos
        Dapper
        SPs Org_GetTree
        SPs Org_Insert
        SPs Org_Update
        SPs Org_Delete
      Errores
        400 Datos invalidos
        404 No existe
        409 Regla de negocio
      Seguridad
        ConnectionString en variable de entorno
        Encrypt True
    Org.Mvc Frontend MVC
      Vistas
        Recursivas Nodo
        Bootstrap 5
      Acciones
        Crear
        Editar
        Eliminar
      Cliente API
        OrgApiClient HttpClient
        BaseUrl configurable
      CSRF
        AntiForgeryToken
    Datos Modelo
      Tabla dbo-Organigrama
        Id PK
        Puesto
        Nombre
        JefeId nullable self FK
      Arbol
        Diccionario Id OrgNode
        Enlaces Padre Hijo
        Raices JefeId null
    Despliegue IIS Kestrel
      Site1 Org.Api
        web.config OutOfProcess
        Swagger habilitado
      Site2 Org.Mvc
        web.config OutOfProcess
        Consume API de Site1
      WebDAV
        Deshabilitar PUT y DELETE
    Troubleshooting
      404 Ruta o PathBase incorrecto
      405 WebDAV bloquea metodos
      500 Conexion SQL o SP
      Debug logs stdout
      Endpoint debug temporal
    Roadmap
      Modales de edicion
      Autenticacion JWT Identity
      Internacionalizacion multiempresa
```
