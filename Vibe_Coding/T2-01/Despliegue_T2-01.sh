#!/bin/bash
set -e

mkdir -p lexibridge/database lexibridge/app/static
cd lexibridge

cat << 'EOF' > docker-compose.yml
version: '3.8'

services:
  db:
    image: mariadb:10.11
    container_name: lexibridge_db
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: lexibridge_db
      MYSQL_USER: lbx_user
      MYSQL_PASSWORD: lbx_password
    volumes:
      - db_data:/var/lib/mysql
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 5s
      timeout: 5s
      retries: 10

  web:
    build: ./app
    container_name: lexibridge_web
    restart: always
    ports:
      - "8000:8000"
    environment:
      DB_HOST: db
      DB_USER: lbx_user
      DB_PASSWORD: lbx_password
      DB_NAME: lexibridge_db
    depends_on:
      db:
        condition: service_healthy

volumes:
  db_data:
EOF

cat << 'EOF' > database/init.sql
CREATE DATABASE IF NOT EXISTS lexibridge_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE lexibridge_db;

CREATE TABLE IF NOT EXISTS adaptaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    centro VARCHAR(150) NOT NULL,
    asignatura VARCHAR(150) NOT NULL,
    tipo_adaptacion ENUM('Visual', 'Auditiva', 'Cognitiva', 'LexiBridge Sign') NOT NULL,
    estado ENUM('Pendiente', 'Procesando IA', 'Validado por Docente') NOT NULL DEFAULT 'Pendiente',
    descripcion TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO adaptaciones (centro, asignatura, tipo_adaptacion, estado, descripcion) VALUES
('IES Ciudad Jardín', 'Sistemas Informáticos', 'Auditiva', 'Validado por Docente', 'Transcripción STT y subtitulado técnico sobre administración de redes y contenedores.'),
('Universidad de Sevilla', 'Inteligencia Artificial', 'LexiBridge Sign', 'Procesando IA', 'Interpretación bidireccional LSE a voz para seminario de redes Transformer.'),
('CPIFP Nuevo Desarrollo', 'Bases de Datos', 'Cognitiva', 'Pendiente', 'Simplificación de lectura fácil y desglose paso a paso de normalización SQL.'),
('Colegio San Francisco', 'Matemáticas', 'Visual', 'Validado por Docente', 'Conversión TTS y descripción de grafos y funciones mediante visión artificial.');
EOF

cat << 'EOF' > app/Dockerfile
FROM python:3.11-slim

WORKDIR /code

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

cat << 'EOF' > app/requirements.txt
fastapi==0.110.0
uvicorn==0.28.0
pymysql==1.1.0
pydantic==2.6.4
cryptography==42.0.5
EOF

cat << 'EOF' > app/main.py
import os
import pymysql
from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

app = FastAPI(title="LexiBridge API", version="1.0.0")

def get_db_connection():
    return pymysql.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "lbx_user"),
        password=os.getenv("DB_PASSWORD", "lbx_password"),
        database=os.getenv("DB_NAME", "lexibridge_db"),
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=True
    )

class AdaptacionBase(BaseModel):
    centro: str
    asignatura: str
    tipo_adaptacion: str
    estado: str
    descripcion: str

class AdaptacionOut(AdaptacionBase):
    id: int
    fecha_creacion: Optional[datetime] = None

@app.get("/api/adaptaciones", response_model=List[AdaptacionOut])
def listar_adaptaciones():
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM adaptaciones ORDER BY id DESC")
            return cursor.fetchall()
    finally:
        conn.close()

@app.post("/api/adaptaciones", response_model=AdaptacionOut, status_code=201)
def crear_adaptacion(item: AdaptacionBase):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            sql = """INSERT INTO adaptaciones (centro, asignatura, tipo_adaptacion, estado, descripcion)
                     VALUES (%s, %s, %s, %s, %s)"""
            cursor.execute(sql, (item.centro, item.asignatura, item.tipo_adaptacion, item.estado, item.descripcion))
            new_id = cursor.lastrowid
            cursor.execute("SELECT * FROM adaptaciones WHERE id = %s", (new_id,))
            return cursor.fetchone()
    finally:
        conn.close()

@app.put("/api/adaptaciones/{item_id}", response_model=AdaptacionOut)
def actualizar_adaptacion(item_id: int, item: AdaptacionBase):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            sql = """UPDATE adaptaciones
                     SET centro=%s, asignatura=%s, tipo_adaptacion=%s, estado=%s, descripcion=%s
                     WHERE id=%s"""
            cursor.execute(sql, (item.centro, item.asignatura, item.tipo_adaptacion, item.estado, item.descripcion, item_id))
            if cursor.rowcount == 0:
                cursor.execute("SELECT id FROM adaptaciones WHERE id=%s", (item_id,))
                if not cursor.fetchone():
                    raise HTTPException(status_code=404, detail="Registro no encontrado")
            cursor.execute("SELECT * FROM adaptaciones WHERE id = %s", (item_id,))
            return cursor.fetchone()
    finally:
        conn.close()

@app.delete("/api/adaptaciones/{item_id}")
def eliminar_adaptacion(item_id: int):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("DELETE FROM adaptaciones WHERE id = %s", (item_id,))
            if cursor.rowcount == 0:
                raise HTTPException(status_code=404, detail="Registro no encontrado")
            return {"eliminado": True, "id": item_id}
    finally:
        conn.close()

app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/")
def serve_root():
    return FileResponse("static/index.html")
EOF

cat << 'EOF' > app/static/index.html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LexiBridge · IA para la Accesibilidad Educativa</title>
    <link rel="stylesheet" href="/static/styles.css">
</head>
<body>
    <header class="navbar">
        <div class="container nav-content">
            <div class="logo">Lexi<span>Bridge</span></div>
            <nav>
                <a href="#problema">Problema</a>
                <a href="#solucion">Solución</a>
                <a href="#arquitectura">IA & Sign</a>
                <a href="#etica">Ética y Negocio</a>
                <a href="#crud" class="btn-nav">Gestor CRUD</a>
            </nav>
        </div>
    </header>

    <section class="hero">
        <div class="container">
            <span class="badge">Proyecto Académico · Plataforma B2B</span>
            <h1>Un puente entre todas las formas de aprender</h1>
            <p>Plataforma de inteligencia artificial para colegios, institutos, FP y universidades que adapta los materiales y la comunicación del aula a cada estudiante. No diagnostica discapacidades ni sustituye al profesorado.</p>
            <div class="hero-actions">
                <a href="#crud" class="btn-primary">Probar Gestor de Adaptaciones</a>
                <a href="#solucion" class="btn-secondary">Explorar Tecnología</a>
            </div>
        </div>
    </section>

    <section id="problema" class="section">
        <div class="container">
            <h2>01 · El Problema: La barrera está en el material, no en la persona</h2>
            <div class="grid-4">
                <div class="stat-card">
                    <h3>1.300 M</h3>
                    <p>Personas con discapacidad significativa en el mundo (16% de la población, 1 de cada 6).</p>
                </div>
                <div class="stat-card">
                    <h3>2.200 M</h3>
                    <p>Personas viven con alguna deficiencia o discapacidad visual (OMS, 2019).</p>
                </div>
                <div class="stat-card">
                    <h3>430 M</h3>
                    <p>Con pérdida auditiva discapacitante que requiere rehabilitación (34M son niños/as).</p>
                </div>
                <div class="stat-card">
                    <h3>+70 M</h3>
                    <p>Personas sordas usuarias de más de 300 lenguas de signos naturales y completas.</p>
                </div>
            </div>
        </div>
    </section>

    <section id="solucion" class="section bg-alt">
        <div class="container">
            <h2>02 · La Solución: LexiBridge adapta el contenido</h2>
            <div class="grid-3">
                <div class="card">
                    <h3>Accesibilidad Visual</h3>
                    <ul>
                        <li>Conversión de texto a voz (TTS) natural.</li>
                        <li>Lectura estructurada de documentos.</li>
                        <li>Descripción automática de imágenes y gráficos.</li>
                    </ul>
                </div>
                <div class="card">
                    <h3>Accesibilidad Auditiva</h3>
                    <ul>
                        <li>Conversión de voz a texto (STT) en tiempo real.</li>
                        <li>Subtítulos automáticos y transcripción de clases.</li>
                        <li>Generación de resúmenes estructurados.</li>
                    </ul>
                </div>
                <div class="card">
                    <h3>Accesibilidad Cognitiva</h3>
                    <ul>
                        <li>Simplificación léxica y sintáctica de textos.</li>
                        <li>Información compleja dividida en pasos secuenciales.</li>
                        <li>Explicaciones alternativas adaptadas.</li>
                    </ul>
                </div>
            </div>
        </div>
    </section>

    <section id="arquitectura" class="section">
        <div class="container">
            <h2>03 & 04 · Flujo de IA y LexiBridge Sign</h2>
            <div class="flow-box">
                <div class="step"><strong>1. Entrada</strong><span>Texto, Audio, Doc, Img, Vídeo</span></div>
                <div class="step"><strong>2. Representación</strong><span>Embeddings y Visión Artificial</span></div>
                <div class="step"><strong>3. Modelos IA</strong><span>PLN, Transformers, Multimodales, IA Gen</span></div>
                <div class="step"><strong>4. Salida</strong><span>Audio, Subtítulos, Lectura Fácil, Signos</span></div>
                <div class="step highlight"><strong>5. Supervisión</strong><span>Docente valida y retroalimenta</span></div>
            </div>

            <div class="grid-2 mt-2">
                <div class="card border-accent">
                    <h3>LexiBridge Sign: Signos → Voz y Texto</h3>
                    <p><strong>Flujo:</strong> Persona signa → Cámara de vídeo en tiempo real → Visión artificial (detecta manos, postura corporal y expresión facial) → Modelos Transformer interpretan secuencia y contexto → Salida en Texto y Voz para persona oyente.</p>
                </div>
                <div class="card border-accent">
                    <h3>LexiBridge Sign: Voz y Texto → Signos</h3>
                    <p><strong>Flujo:</strong> Persona oyente habla o escribe → Micrófono/Teclado → Procesamiento del Lenguaje Natural estructura y simplifica → Representación en texto claro, apoyo visual o avatar de lengua de signos.</p>
                </div>
            </div>
            <p class="note"><strong>Nota científica:</strong> Reconocer signos ≠ traducir una lengua. La traducción automática completa sigue siendo un reto abierto (Bragg et al., ASSETS 2019). Estado del arte de referencia: SignGemma (Google DeepMind, 2025).</p>
        </div>
    </section>

    <section id="etica" class="section bg-alt">
        <div class="container">
            <h2>05, 06 & 07 · Entrenamiento, Marco Legal UE y Modelo B2B</h2>
            <div class="grid-3">
                <div class="card">
                    <h3>Datos y Entrenamiento</h3>
                    <p><strong>Ciclo Supervisado:</strong> Datos → Preproceso → Entrenamiento → Validación → Evaluación → Despliegue → Feedback.</p>
                    <p><strong>Corpus:</strong> RWTH-PHOENIX-Weather 2014T (DGS), How2Sign (+80h ASL), convenios con centros y datos sintéticos.</p>
                    <p><strong>Límites:</strong> Concentración en ASL/DGS/CSL/BSL; sensibilidad a ángulos, iluminación y velocidad; no aprende sola sin supervisión.</p>
                </div>
                <div class="card">
                    <h3>Impacto, Ética y Legalidad</h3>
                    <p><strong>Beneficios:</strong> Autonomía estudiantil, acceso igualitario, ahorro de tiempo docente.</p>
                    <p><strong>Riesgos:</strong> Errores de traducción, brecha digital, privacidad.</p>
                    <p><strong>Marco UE:</strong> RGPD Art. 9 (vídeo signando = dato biométrico de categoría especial) y Ley de IA Reglamento 2024/1689 Anexo III (IA en educación = alto riesgo; exige supervisión humana y gobernanza).</p>
                </div>
                <div class="card">
                    <h3>Modelo de Negocio B2B</h3>
                    <p><strong>Clientes:</strong> Colegios, institutos, centros FP y universidades.</p>
                    <p><strong>Oferta:</strong> Plataforma web, integración LMS, formación y soporte.</p>
                    <p><strong>Ingresos:</strong> Suscripción anual por centro, licencias por volumen y API a terceros.</p>
                    <p><strong>Costes:</strong> I+D modelos, infraestructura cloud, validación con comunidad sorda y auditoría legal.</p>
                </div>
            </div>
        </div>
    </section>

    <section id="crud" class="section">
        <div class="container">
            <h2>Panel CRUD · Gestión de Adaptaciones y Solicitudes de Centros</h2>
            <div class="crud-layout">
                <form id="crud-form" class="card form-card">
                    <h3 id="form-title">Nueva Solicitud de Adaptación</h3>
                    <input type="hidden" id="item-id">
                    
                    <label for="centro">Centro Educativo</label>
                    <input type="text" id="centro" required placeholder="Ej: IES Ciudad Jardín">

                    <label for="asignatura">Asignatura / Módulo</label>
                    <input type="text" id="asignatura" required placeholder="Ej: Administración de Sistemas">

                    <label for="tipo_adaptacion">Módulo IA Aplicado</label>
                    <select id="tipo_adaptacion" required>
                        <option value="Visual">Accesibilidad Visual (TTS / Descripción)</option>
                        <option value="Auditiva">Accesibilidad Auditiva (STT / Subtítulos)</option>
                        <option value="Cognitiva">Accesibilidad Cognitiva (Lectura Fácil)</option>
                        <option value="LexiBridge Sign">LexiBridge Sign (Lengua de Signos)</option>
                    </select>

                    <label for="estado">Estado de Supervisión Humana</label>
                    <select id="estado" required>
                        <option value="Pendiente">Pendiente</option>
                        <option value="Procesando IA">Procesando IA</option>
                        <option value="Validado por Docente">Validado por Docente</option>
                    </select>

                    <label for="descripcion">Descripción del Material / Adaptación</label>
                    <textarea id="descripcion" rows="3" required placeholder="Detalle del material educativo a adaptar..."></textarea>

                    <div class="form-buttons">
                        <button type="submit" class="btn-primary" id="btn-save">Guardar Registro</button>
                        <button type="button" class="btn-secondary hidden" id="btn-cancel">Cancelar Edición</button>
                    </div>
                </form>

                <div class="table-container card">
                    <h3>Registros Activos en Base de Datos</h3>
                    <div class="table-responsive">
                        <table>
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Centro / Asignatura</th>
                                    <th>Módulo IA</th>
                                    <th>Estado</th>
                                    <th>Descripción</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody id="crud-table-body"></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <footer class="footer">
        <div class="container grid-2">
            <div>
                <h4>08 & 09 · Bibliografía y Fuentes Oficiales</h4>
                <ul class="ref-list">
                    <li>OMS (2019, 2023, 2024): Informes mundiales sobre visión, discapacidad y audición.</li>
                    <li>ONU / Federación Mundial de Sordos (WFD): Estadísticas de lenguas de signos.</li>
                    <li>Bragg et al. (ASSETS 2019): <em>Sign Language Recognition, Generation, and Translation</em>.</li>
                    <li>Camgoz et al. (CVPR 2020): <em>Sign Language Transformers</em> (RWTH-PHOENIX-2014T).</li>
                    <li>Duarte et al. (CVPR 2021): <em>How2Sign Multimodal Dataset</em> (+80h ASL).</li>
                    <li>arXiv (2026): <em>Sign-Language Datasets at Scale</em>.</li>
                    <li>UE: Reglamento 2016/679 (RGPD Art. 9) y Reglamento 2024/1689 (Ley de IA Anexo III).</li>
                </ul>
            </div>
            <div>
                <h4>10 · Transparencia de IAs Utilizadas en el Proyecto</h4>
                <ul class="ref-list">
                    <li><strong>Gemini:</strong> Búsqueda de información inicial y estructuración técnica.</li>
                    <li><strong>ChatGPT:</strong> Generación del logotipo y refinamiento de ideas respecto al enunciado.</li>
                    <li><strong>Kimi.ai:</strong> Generación y maquetación de la presentación.</li>
                </ul>
                <p class="mt-1">LexiBridge · Proyecto Académico (Empresa Ficticia).</p>
            </div>
        </div>
    </footer>

    <script src="/static/app.js"></script>
</body>
</html>
EOF

cat << 'EOF' > app/static/styles.css
:root {
    --bg: #0f172a;
    --bg-alt: #1e293b;
    --card: #1e293b;
    --text: #f8fafc;
    --muted: #94a3b8;
    --primary: #38bdf8;
    --primary-hover: #0284c7;
    --accent: #818cf8;
    --danger: #ef4444;
    --success: #22c55e;
    --border: #334155;
}

* { box-sizing: border-box; margin: 0; padding: 0; }
body {
    font-family: system-ui, -apple-system, sans-serif;
    background-color: var(--bg);
    color: var(--text);
    line-height: 1.6;
}
.container { max-width: 1200px; margin: 0 auto; padding: 0 1.5rem; }

.navbar {
    position: sticky; top: 0; z-index: 100;
    background: rgba(15, 23, 42, 0.9);
    backdrop-filter: blur(8px);
    border-bottom: 1px solid var(--border);
    padding: 1rem 0;
}
.nav-content { display: flex; justify-content: space-between; align-items: center; }
.logo { font-size: 1.5rem; font-weight: 800; letter-spacing: -0.5px; }
.logo span { color: var(--primary); }
nav a {
    color: var(--text); text-decoration: none; margin-left: 1.5rem;
    font-size: 0.95rem; transition: color 0.2s;
}
nav a:hover { color: var(--primary); }
.btn-nav {
    background: var(--primary); color: #0f172a !important;
    padding: 0.5rem 1rem; border-radius: 6px; font-weight: 600;
}

.hero { padding: 5rem 0 4rem; text-align: center; border-bottom: 1px solid var(--border); }
.badge {
    background: rgba(56, 189, 248, 0.15); color: var(--primary);
    padding: 0.35rem 0.85rem; border-radius: 999px; font-size: 0.85rem; font-weight: 600;
}
.hero h1 { font-size: 2.8rem; margin: 1.2rem 0; color: #fff; }
.hero p { max-width: 760px; margin: 0 auto 2rem; color: var(--muted); font-size: 1.1rem; }
.hero-actions { display: flex; gap: 1rem; justify-content: center; }

.btn-primary, .btn-secondary, .btn-danger, .btn-edit {
    padding: 0.65rem 1.25rem; border-radius: 6px; font-weight: 600;
    cursor: pointer; border: none; text-decoration: none; display: inline-block; font-size: 0.9rem;
}
.btn-primary { background: var(--primary); color: #0f172a; }
.btn-primary:hover { background: var(--primary-hover); color: #fff; }
.btn-secondary { background: transparent; color: var(--text); border: 1px solid var(--border); }
.btn-danger { background: rgba(239, 68, 68, 0.2); color: #fca5a5; padding: 0.35rem 0.65rem; }
.btn-edit { background: rgba(56, 189, 248, 0.2); color: var(--primary); padding: 0.35rem 0.65rem; margin-right: 0.4rem; }

.section { padding: 4rem 0; }
.bg-alt { background-color: #0b1120; border-top: 1px solid var(--border); border-bottom: 1px solid var(--border); }
h2 { font-size: 1.8rem; margin-bottom: 2rem; color: var(--primary); }
h3 { font-size: 1.25rem; margin-bottom: 0.75rem; color: #fff; }

.grid-4 { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 1.5rem; }
.grid-3 { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1.5rem; }
.grid-2 { display: grid; grid-template-columns: repeat(auto-fit, minmax(420px, 1fr)); gap: 1.5rem; }

.card, .stat-card {
    background: var(--card); border: 1px solid var(--border);
    border-radius: 10px; padding: 1.5rem;
}
.stat-card h3 { font-size: 2.4rem; color: var(--primary); }
.card ul { padding-left: 1.2rem; color: var(--muted); }
.card li { margin-bottom: 0.5rem; }
.card p { color: var(--muted); margin-bottom: 0.75rem; font-size: 0.95rem; }
.border-accent { border-left: 4px solid var(--accent); }

.flow-box {
    display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 1rem; margin-bottom: 1.5rem;
}
.step {
    background: var(--card); border: 1px solid var(--border);
    padding: 1rem; border-radius: 8px; text-align: center;
}
.step strong { display: block; color: var(--primary); margin-bottom: 0.3rem; }
.step span { font-size: 0.85rem; color: var(--muted); }
.step.highlight { border-color: var(--success); }

.mt-2 { margin-top: 2rem; }
.mt-1 { margin-top: 1rem; color: var(--muted); }
.note { margin-top: 1.2rem; font-size: 0.9rem; color: var(--muted); font-style: italic; }

.crud-layout { display: grid; grid-template-columns: 1fr 2fr; gap: 1.5rem; align-items: start; }
@media (max-width: 900px) { .crud-layout { grid-template-columns: 1fr; } }

.form-card label { display: block; font-size: 0.85rem; font-weight: 600; margin: 0.75rem 0 0.3rem; color: var(--muted); }
.form-card input, .form-card select, .form-card textarea {
    width: 100%; padding: 0.6rem; border-radius: 6px;
    border: 1px solid var(--border); background: #0f172a; color: var(--text);
}
.form-buttons { margin-top: 1.2rem; display: flex; gap: 0.5rem; }
.hidden { display: none; }

.table-responsive { overflow-x: auto; }
table { width: 100%; border-collapse: collapse; font-size: 0.9rem; }
th, td { padding: 0.75rem; text-align: left; border-bottom: 1px solid var(--border); }
th { color: var(--primary); font-weight: 600; }
.tag {
    padding: 0.2rem 0.55rem; border-radius: 4px; font-size: 0.78rem; font-weight: 600;
    background: rgba(129, 140, 248, 0.15); color: var(--accent);
}

.footer { padding: 3rem 0; background: #070b14; border-top: 1px solid var(--border); font-size: 0.88rem; }
.footer h4 { color: var(--primary); margin-bottom: 0.75rem; }
.ref-list { list-style: none; color: var(--muted); }
.ref-list li { margin-bottom: 0.4rem; }
EOF

cat << 'EOF' > app/static/app.js
const API_URL = '/api/adaptaciones';

const form = document.getElementById('crud-form');
const formTitle = document.getElementById('form-title');
const itemIdInput = document.getElementById('item-id');
const centroInput = document.getElementById('centro');
const asignaturaInput = document.getElementById('asignatura');
const tipoInput = document.getElementById('tipo_adaptacion');
const estadoInput = document.getElementById('estado');
const descripcionInput = document.getElementById('descripcion');
const btnCancel = document.getElementById('btn-cancel');
const tableBody = document.getElementById('crud-table-body');

let currentItems = [];

async function fetchAdaptaciones() {
    const res = await fetch(API_URL);
    currentItems = await res.json();
    renderTable(currentItems);
}

function renderTable(items) {
    tableBody.innerHTML = '';
    items.forEach(item => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>#${item.id}</td>
            <td><strong>${escapeHtml(item.centro)}</strong><br><small>${escapeHtml(item.asignatura)}</small></td>
            <td><span class="tag">${escapeHtml(item.tipo_adaptacion)}</span></td>
            <td>${escapeHtml(item.estado)}</td>
            <td>${escapeHtml(item.descripcion)}</td>
            <td>
                <button class="btn-edit" data-id="${item.id}">Editar</button>
                <button class="btn-danger" data-delete="${item.id}">Borrar</button>
            </td>
        `;
        tableBody.appendChild(tr);
    });
}

tableBody.addEventListener('click', async (e) => {
    const editId = e.target.getAttribute('data-id');
    const deleteId = e.target.getAttribute('data-delete');

    if (editId) {
        const item = currentItems.find(i => i.id === parseInt(editId));
        if (item) {
            itemIdInput.value = item.id;
            centroInput.value = item.centro;
            asignaturaInput.value = item.asignatura;
            tipoInput.value = item.tipo_adaptacion;
            estadoInput.value = item.estado;
            descripcionInput.value = item.descripcion;
            formTitle.textContent = `Editando Registro #${item.id}`;
            btnCancel.classList.remove('hidden');
        }
    }

    if (deleteId) {
        await fetch(`${API_URL}/${deleteId}`, { method: 'DELETE' });
        await fetchAdaptaciones();
    }
});

form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const payload = {
        centro: centroInput.value.trim(),
        asignatura: asignaturaInput.value.trim(),
        tipo_adaptacion: tipoInput.value,
        estado: estadoInput.value,
        descripcion: descripcionInput.value.trim()
    };

    const id = itemIdInput.value;
    if (id) {
        await fetch(`${API_URL}/${id}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
    } else {
        await fetch(API_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
    }

    resetForm();
    await fetchAdaptaciones();
});

btnCancel.addEventListener('click', resetForm);

function resetForm() {
    form.reset();
    itemIdInput.value = '';
    formTitle.textContent = 'Nueva Solicitud de Adaptación';
    btnCancel.classList.add('hidden');
}

function escapeHtml(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

document.addEventListener('DOMContentLoaded', fetchAdaptaciones);
EOF

cat << 'EOF' > README.md
# LexiBridge — Un puente entre todas las formas de aprender

Plataforma web B2B basada en Inteligencia Artificial para la accesibilidad e inclusión educativa en colegios, institutos, centros de FP y universidades. Adapta los materiales y canales de comunicación del aula (accesibilidad visual, auditiva, cognitiva y traducción bidireccional de lengua de signos mediante **LexiBridge Sign**) bajo supervisión docente y cumplimiento del RGPD (Art. 9) y la Ley de IA de la UE (Reglamento 2024/1689, Anexo III).

---

## Arquitectura y Stack Tecnológico

La aplicación sigue una arquitectura multicapa completamente contenedorizada:

1. **Frontend:** HTML5 semántico, CSS3 moderno (Grid/Flexbox, diseño accesible de alto contraste) y JavaScript Vanilla (ES6+ Fetch API). Incluye la Landing Page con toda la fundamentación teórica, ética, legal y de negocio de LexiBridge, integrada con el panel interactivo CRUD.
2. **Backend:** API REST desarrollada en **Python 3.11** con **FastAPI** y servida mediante **Uvicorn**. Gestiona los endpoints HTTP (`GET`, `POST`, `PUT`, `DELETE`) y sirve los archivos estáticos.
3. **Base de Datos:** **MariaDB 10.11** con persistencia en volumen Docker y script de inicialización automática (`init.sql`). Conector `PyMySQL`.
4. **Despliegue:** Orquestación mediante **Docker** y **Docker Compose** con `healthcheck` para garantizar la disponibilidad de la base de datos antes de iniciar el servicio web.

---

## Funcionalidades del CRUD

El módulo CRUD permite gestionar las **Solicitudes de Adaptación de Material Educativo** de los centros clientes:
- **Crear (`POST /api/adaptaciones`):** Registra una nueva adaptación indicando centro educativo, asignatura, módulo de IA (`Visual`, `Auditiva`, `Cognitiva`, `LexiBridge Sign`), estado de supervisión humana y descripción.
- **Leer (`GET /api/adaptaciones`):** Lista en tiempo real todas las adaptaciones almacenadas en MariaDB.
- **Actualizar (`PUT /api/adaptaciones/{id}`):** Permite modificar cualquier campo o actualizar el estado de validación docente.
- **Borrar (`DELETE /api/adaptaciones/{id}`):** Elimina registros de la base de datos.

---

## Instrucciones de Despliegue

### Requisitos previos
- Tener instalado `Docker` y `Docker Compose`.

### Ejecución en un solo comando
Desde la raíz del proyecto (`lexibridge/`), ejecutar:

```bash
docker compose up -d --build