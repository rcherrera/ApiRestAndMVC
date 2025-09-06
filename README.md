
 graph TD A --> B B --> C 

flowchart LR
  subgraph API["Org.Api (ASP.NET Core Web API) — /api/Organigrama"]
    GET_TREE["GET /tree<br/>→ 200 OK<br/><i>Devuelve árbol</i>"]
    POST_ITEM["POST /<br/>→ 201/200<br/><i>Crea nodo</i>"]
    PUT_ITEM["PUT /{id}<br/>→ 204 No Content<br/><i>Actualiza nodo</i>"]
    DEL_ITEM["DELETE /{id}<br/>→ 204 No Content<br/><i>Elimina nodo</i>"]
  end

  note right of API
    Códigos negocio:
    • 400 BadRequest (datos inválidos)
    • 404 NotFound (id no existe)
    • 409 Conflict (no borrar con hijos / jefe==id)
  end

  style GET_TREE fill:#e8fff5,stroke:#00a86b
  style POST_ITEM fill:#eef5ff,stroke:#2b6cb0
  style PUT_ITEM fill:#fff7e6,stroke:#c05621
  style DEL_ITEM fill:#ffeef0,stroke:#c53030


