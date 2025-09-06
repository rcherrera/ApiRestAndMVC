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
  - `Org_GetTree`  
  - `Org_Insert`  
  - `Org_Update`  
  - `Org_Delete`
- Manejo de errores con códigos semánticos (`400`, `404`, `409`) en lugar de `500`.
- Incluye **Swagger/OpenAPI** para documentación y pruebas.
- Implementación con **Dapper** y conexiones SQL seguras (`Encrypt=True`).

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
    subgraph Client[Usuario (Browser)]
        V[Views (Razor)]
    end

    subgraph MVC[Org.Mvc (ASP.NET Core MVC)]
        C[Controllers]
        S[OrgApiClient (HttpClient)]
    end

    subgraph API[Org.Api (ASP.NET Core Web API)]
        A[OrganigramaController]
        R[OrgRepo (Dapper)]
    end

    subgraph DB[(SQL Server)]
        SP_Get[Org_GetTree]
        SP_Ins[Org_Insert]
        SP_Upd[Org_Update]
        SP_Del[Org_Delete]
        T[(dbo.Organigrama)]
    end

    V -->|HTTP| C --> S -->|GET/POST/PUT/DELETE| A --> R
    R -->|EXEC| SP_Get --> T
    R -->|EXEC| SP_Ins --> T
    R -->|EXEC| SP_Upd --> T
    R -->|EXEC| SP_Del --> T

sequenceDiagram
    participant U as Usuario
    participant V as Org.Mvc/View (_Nodo modal)
    participant C as MVC Controller
    participant S as OrgApiClient
    participant A as API Controller
    participant R as OrgRepo
    participant DB as SQL Server (SP Org_Update)

    U->>V: Completa formulario de edición
    V->>C: POST /Organigrama/Editar
    C->>S: UpdateAsync(id, dto)
    S->>A: PUT /api/Organigrama/{id} (JSON)
    A->>R: UpdateAsync(...)
    R->>DB: EXEC dbo.Org_Update
    DB-->>R: filas afectadas / error
    alt OK
        A-->>S: 204 No Content
        S-->>C: éxito
        C-->>V: RedirectToAction(Index) + TempData["Ok"]
    else Error negocio
        A-->>S: 400/404/409
        S-->>C: lanza excepción
        C-->>V: RedirectToAction(Index) + TempData["Error"]
    end

