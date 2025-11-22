
# **Aplicativo – Llenado de la Guía de Remisión Transportista (GDI02)**

## 📌 Descripción

Este aplicativo web permite registrar empresas, conductores, vehículos y productos, además de crear Guías de Remisión Remitente y convertirlas en una Guía Transportista. Incluye validaciones, cálculos automáticos de pesos y conexión con una base de datos MariaDB mediante API REST y stored procedures.

---

## 📂 Estructura del Proyecto

```
.
├── api
│   ├── controllers
│   │   ├── conductorController.js
│   │   ├── empresaController.js
│   │   ├── guiaRemitenteController.js
│   │   ├── productoController.js
│   │   └── vehiculosController.js
│   ├── dao
│   │   ├── conductorDao.js
│   │   ├── empresaDao.js
│   │   ├── guiaRemitenteDao.js
│   │   ├── productoDao.js
│   │   ├── semirremolqueDao.js
│   │   └── tractoDao.js
│   ├── db.js
│   ├── server.js
│   └── services
│       ├── conductorService.js
│       ├── empresaService.js
│       ├── guiaRemitenteService.js
│       ├── productoService.js
│       └── vehiculosService.js
├── db
│   ├── procedimientos.sql
│   ├── reportes.sql
│   ├── script_final.sql
│   └── triggers.sql
├── package.json
├── package-lock.json
└── web
    ├── app.js
    ├── index.html
    └── styles.css
```

### 📁 Explicación de carpetas

#### **/api/**

Contiene todo el backend:

* **controllers/** → Rutas del API REST. Reciben solicitudes del frontend.
* **services/** → Lógica del negocio. Validaciones y procesos.
* **dao/** → Acceso a la base de datos. Ejecutan SQL y stored procedures.
* **db.js** → Configuración de conexión a MariaDB.
* **server.js** → Punto de entrada del backend (Express).

#### **/db/**

Archivos SQL:

* Creación de tablas
* Triggers
* Procedimientos almacenados
* Scripts finales

#### **/web/**

Frontend simple:

* **index.html** → Página principal
* **app.js** → Lógica y llamadas al backend
* **styles.css** → Estilos básicos

---

## ✔️ Requerimientos

### **Software necesario**

* Node.js 18+
* MariaDB 10.5 o superior
* Navegador moderno (Chrome/Firefox)

### **Dependencias del proyecto**

Se instalan con `npm install`:

* express
* mysql2
* cors
* dotenv

---

## 🛠️ Proceso de Instalación

### **1. Clonar el repositorio**

```bash
git clone <url_del_repositorio>
cd <carpeta_del_proyecto>
```

### **2. Instalar dependencias**

```bash
npm install
```

### **3. Crear la base de datos**

En MariaDB ejecutar:

```sql
SOURCE db/script_final.sql;
SOURCE db/procedimientos.sql;
SOURCE db/triggers.sql;
```

(El orden puede variar si ya existe la BD.)

### **4. Configurar variables de entorno**

Crear un archivo **.env** en la carpeta raíz:

```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=<tu_password>
DB_DATABASE=transportista
PORT=3000
```

### **5. Iniciar el backend**

```bash
npm start
```

### **6. Abrir el aplicativo**

Abrir el aplicativo en un navegador web:

```
http://localhost:3000
```

en el navegador (o servirlo con extensión Live Server).

---

