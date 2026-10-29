# Registro de Prompts — Proyecto LexiBridge

Este documento recoge la secuencia de *prompts* (instrucciones) utilizados durante el desarrollo y estructuración del proyecto **LexiBridge**, orientados a la optimización de tokens y a la generación automatizada de la arquitectura Fullstack con Docker.

---

## Prompt 1: Solicitud de plantilla de optimización de tokens
**Objetivo:** Obtener una estructura base para comprimir una gran cantidad de información utilizando el mínimo número de tokens posible.

```text
Tengo mucha información sobre un proyecto planteado y quiero realizar la siguiente tarea. Haz un prompt donde se haga uso de todo lo mencionado con la cantidad mas pequeña de tokens posibles.
```

---

## Prompt 2: Volcado de datos brutos y requisitos para compresión
**Objetivo:** Transformar los requisitos técnicos de la asignatura y el contenido íntegro de la presentación de *LexiBridge* en un único prompt comprimido de alta densidad.

```text
Te paso el enunciado y realiza lo anteriormente dicho:

Crear vuestra página Web orientada a vuestro proyecto de esta asignatura. Debéis usar cualquier chats de IA. La aplicación debe tener:
- Frontend
- Backend
- Una base de datos
- Contenedor que despliegue la aplicación
- Crud Básico
- Readme.MD explicando tecnologías y lo que hace.
- 
Debéis entregar enlace de github.

Datos:

LexiBridge
Un puente entre todas las formas de aprender
Plataforma de inteligencia artificial para la accesibilidad y la inclusión en el entorno educativo
Proyecto académico · Empresa ficticia
[Nombre del grupo · Asignatura · Fecha]
Aula inclusiva con tecnología de apoyo · Fotografía: SMART Technologies
01 · EL PROBLEMA
Aprender no es igual de accesible para todo el mundo
1.300 M
personas viven con discapacidad significativa en el mundo: el 16 % de la población, 1 de cada 6 personas
430 M
personas con pérdida auditiva discapacitante que necesitan rehabilitación; 34 millones son niños y niñas
70 M+
personas sordas se comunican en más de 300 lenguas de signos diferentes, lenguas naturales y completas
La barrera no está en la persona: está en materiales y canales de comunicación que no se adaptan.
Además, al menos 2.200 millones de personas viven con alguna discapacidad visual (OMS, 2019).
Tecnología de apoyo en el aula · Fotografía: Reading Rockets
Fuentes: OMS, Disability and health (2023) · OMS, World Report on Vision (2019) · OMS, Deafness and hearing loss (2024) · ONU / Federación Mundial de Sordos
LexiBridge · IA para la accesibilidad educativa
02 / 10
02 · LA SOLUCIÓN
LexiBridge adapta el contenido, no a la persona
Una plataforma de IA para colegios, institutos y universidades que convierte los materiales y la comunicación del aula en formatos accesibles para cada estudiante
Accesibilidad visual
Texto convertido en audio · lectura de documentos · descripción de imágenes y gráficos · formatos adaptados a cada necesidad
Accesibilidad auditiva
Voz convertida en texto · subtítulos automáticos · transcripción de explicaciones y clases · resúmenes del contenido
Accesibilidad cognitiva
Textos simplificados · información compleja dividida en pasos · contenidos reorganizados · explicaciones alternativas
No diagnostica discapacidades ni sustituye al profesorado ni a profesionales especializados: herramientas de apoyo y accesibilidad educativa
Función diferenciadora: LexiBridge Sign →
LexiBridge · IA para la accesibilidad educativa
03 / 10
03 · CÓMO FUNCIONA LA IA
De los datos al formato accesible
1
Datos de entrada
Texto, audio, documentos, imágenes y vídeo del aula
2
Representación
Embeddings y visión artificial convierten los datos en vectores numéricos
3
Modelos de IA
PLN, redes Transformer y modelos multimodales procesan el contenido
4
Resultado accesible
Audio, subtítulos, texto simplificado y formatos adaptados
5
Supervisión humana
El profesorado valida y el feedback guía la mejora
Ramas de IA implicadas: visión artificial · machine learning - procesamiento del lenguaje natural · IA generativa
LexiBridge · IA para la accesibilidad educativa
04 / 10
04 · LEXIBRIDGE SIGN
Un puente entre la lengua de signos y la voz
Signos → voz y texto
Voz y texto → signos
Persona que signa
Lengua de signos natural, con ritmo y expresión propios
Cámara
Vídeo de la conversación en tiempo real
Visión artificial
Detecta manos, cuerpo y expresiones faciales
Reconocimiento y traducción
Modelos Transformer interpretan la secuencia y su contexto
Texto y voz
La persona oyente recibe el mensaje
Persona oyente
Habla o escribe con naturalidad
Voz o texto
Entrada por micrófono o teclado
Procesamiento de lenguaje
La IA estructura y simplifica el mensaje
Representación accesible
Texto claro, apoyos visuales o avatar de signos
Persona que signa
Recibe la información en su lengua
Manos, cuerpo y rostro: una lengua multimodal · Foto: Pngtree
Reconocer signos ≠ traducir una lengua: la traducción automática completa sigue siendo un reto abierto de investigación (Bragg et al., ASSETS 2019)
LexiBridge · IA para la accesibilidad educativa
05 / 10
05 · DATOS Y ENTRENAMIENTO
Cómo aprende el sistema: un ciclo supervisado
DATOS
PREPROCESO
ENTRENAMIENTO
VALIDACIÓN
EVALUACIÓN
DESPLIEGUE
FEEDBACK
nueva actualización supervisada
¿De dónde salen los datos?
Datasets académicos: RWTH-PHOENIX-Weather 2014T (signos en alemán) y How2Sign (más de 80 h de ASL)
Colaboración con centros educativos y universidades, con consentimiento
Datos sintéticos y pilotos controlados con personas usuarias
Límites que reconocemos
Los datasets abiertos se concentran en pocas lenguas: ASL, DGS, CSL y BSL
La variación entre personas, ángulos de cámara, iluminación y velocidad reduce la precisión
La IA no «aprende sola» de cada alumno: cada mejora exige entrenamiento y validación supervisados
Fuentes: Duarte et al., CVPR 2021 (How2Sign) · Camgoz et al., CVPR 2020 (Sign Language Transformers) · Revisión de datasets de lenguas de signos, arXiv 2026
LexiBridge · IA para la accesibilidad educativa
06 / 10
06 · IMPACTO Y RESPONSABILIDAD
Beneficios potenciales y riesgos a gestionar
Beneficios potenciales
Autonomía: el alumnado accede al contenido sin depender de terceros
Acceso al conocimiento: mismos materiales, formatos distintos
Comunicación: nuevos canales entre estudiantes y docentes
Apoyo al profesorado: menos tiempo adaptando, más tiempo enseñando
Beneficios potenciales descritos en la literatura: no son resultados medidos de LexiBridge, una empresa ficticia
Riesgos a gestionar
Errores y sesgos: una mala traducción puede excluir o confundir
Privacidad: la voz y el vídeo del alumnado son datos sensibles
Brecha digital: no todos los centros disponen de los mismos recursos
Rol de las personas: la IA apoya; no sustituye a docentes ni intérpretes
Marco legal europeo: RGPD — el vídeo de personas que signan puede ser dato biométrico de categoría especial (art. 9) · Ley de IA (Reglamento 2024/1689) — la IA en educación puede ser de alto riesgo (Anexo III): supervisión humana, transparencia y gobernanza de datos desde el diseño
LexiBridge · IA para la accesibilidad educativa
07 / 10
07 · MODELO DE NEGOCIO
Un modelo B2B institucional
CLIENTES
Colegios e institutos
Universidades
Centros de formación profesional
OFERTA
Plataforma web accesible
Integración con las herramientas del centro
Formación y soporte
INGRESOS
Suscripción anual por centro
Licencias por volumen
API para terceros
COSTES PRINCIPALES
Desarrollo y entrenamiento de modelos · infraestructura y mantenimiento · validación con personas usuarias y profesionales · cumplimiento legal y auditorías
Diferenciación: una sola plataforma que integra accesibilidad visual, auditiva y cognitiva, con comunicación bidireccional en lengua de signos y validación con la comunidad
Los precios y las cifras serían estimaciones ilustrativas creadas para este ejercicio académico: no representan datos de mercado reales
LexiBridge · IA para la accesibilidad educativa
08 / 10
08 · CONCLUSIÓN
«La tecnología ya permite derribar parte de las barreras del aula. La siguiente frontera es la comunicación bidireccional con la lengua de signos.»
01
El problema es real y medible: millones de estudiantes conviven a diario con barreras de acceso a la información
02
La IA ya ayuda hoy: y la traducción de lengua de signos avanza, con límites que conviene reconocer
03
LexiBridge lo propone con responsabilidad: supervisión humana, privacidad y validación con la comunidad desde el diseño
LexiBridge — un puente entre todas las formas de aprender
LexiBridge · IA para la accesibilidad educativa
09 / 10
09 · FUENTES Y RECURSOS
Bibliografía
01  Disability and health
OMS, 2023 — 1.300 M de personas con discapacidad significativa (16 %)
02  World Report on Vision
OMS, 2019 — al menos 2.200 M de personas con discapacidad visual
03  Deafness and hearing loss
OMS, 2024 — 430 M con pérdida auditiva discapacitante; 34 M de niños
04  Día Internacional de las Lenguas de Signos
ONU / Federación Mundial de Sordos — +70 M de personas sordas; +300 lenguas de signos
05  Sign Language Recognition, Generation, and Translation
Bragg et al., ASSETS 2019 — retos abiertos y papel de la comunidad sorda
06  Sign Language Transformers
Camgoz et al., CVPR 2020 — reconocimiento y traducción conjuntos (RWTH-PHOENIX-2014T)
07  How2Sign
Duarte et al., CVPR 2021 — dataset multimodal de ASL, +80 h de vídeo
08  Sign-Language Datasets at Scale
arXiv, 2026 — los corpus abiertos se concentran en pocas lenguas (ASL, DGS, CSL, BSL)
09  Reglamento (UE) 2024/1689 — Ley de IA
Anexo III: la educación como ámbito potencialmente de alto riesgo
10  Reglamento (UE) 2016/679 — RGPD
Art. 9: los datos biométricos como categoría especial de datos
Estado del arte comercial: SignGemma, Google DeepMind (2025), en fase de pruebas · Imágenes: SMART Technologies, Reading Rockets, Pngtree (uso educativo) ·
LexiBridge · IA para la accesibilidad educativa
10 / 10
IAs Utilizadas
01    Gemini
Utilizado para la busqueda de información inicial
02    ChatGPT
Utilizado para la generación del logo y refinamiento de las ideas con respecto al enunciado
03    Kimi.ai
Utilizado para la generación y edición de la presentación
```

---

## Prompt 3: Ejecución del prompt optimizado (Generación Fullstack + Script de despliegue)
**Objetivo:** Generar el árbol de directorios y un script automatizado en Bash capaz de crear todos los archivos del proyecto (Frontend, Backend FastAPI, Base de datos MariaDB, Docker Compose y README) y levantar los contenedores.

```text
[TAREA]
Desarrolla webapp fullstack contenedorizada + CRUD básico + README.md para proyecto académico "LexiBridge".

[REQ_TECNICOS]
- Frontend: Landing page con [CONTENIDO] + interfaz CRUD.
- Backend: API REST para el CRUD.
- BD: Relacional o NoSQL persistente.
- Despliegue: Dockerfile + docker-compose.yml (levantar todo en 1 comando).
- CRUD: Gestión de "Adaptaciones de Material" o "Solicitudes de Centros" (Crear, Leer, Actualizar, Borrar).
- README.md: Explicación del proyecto, stack tecnológico, arquitectura e instrucciones de despliegue para GitHub.

[CONTENIDO]
Nombre: LexiBridge ("Un puente entre todas las formas de aprender").
Concepto: Plataforma IA B2B para accesibilidad e inclusión educativa (colegios, FP, universidades). Adapta contenido, no a la persona. No diagnostica ni sustituye docentes.
1. Problema (OMS/ONU): 1.300M personas discapacidad significativa (16%, 1/6); 2.200M visual; 430M auditiva discapacitante (34M niños); +70M sordos (+300 lenguas signos). Barrera en materiales no adaptados.
2. Solución:
- Visual: TTS, lectura docs, descripción imágenes/gráficos.
- Auditiva: STT, subtítulos, transcripción clases, resúmenes.
- Cognitiva: Textos simplificados, división en pasos, reorganización.
3. Flujo IA: 1.Entrada (texto/audio/doc/img/vídeo) -> 2.Representación (Embeddings/Visión Artificial) -> 3.Modelos (PLN/Transformers/Multimodales/IA Gen) -> 4.Salida accesible -> 5.Supervisión humana (docente valida y da feedback).
4. LexiBridge Sign (Diferenciador): Traducción bidireccional tiempo real.
- Signos->Voz/Texto: Cámara -> Visión artificial (manos/cuerpo/rostro) -> Transformer -> Texto/Voz.
- Voz/Texto->Signos: Micrófono/Teclado -> PLN -> Texto claro/apoyo visual/avatar signos.
- Nota: Reconocer!=Traducir (reto abierto, Bragg 2019). Estado del arte: SignGemma (DeepMind, 2025).
5. Datos/Entrenamiento: Ciclo supervisado (Datos->Preproceso->Entrenamiento->Validación->Evaluación->Despliegue->Feedback). Fuentes: RWTH-PHOENIX-Weather 2014T (DGS), How2Sign (+80h ASL), convenios centros, datos sintéticos. Límites: Corpus centrados en ASL/DGS/CSL/BSL, sensibilidad a ángulo/luz/velocidad, no aprende sola sin supervisión.
6. Impacto/Ética/Legal:
- Beneficios: Autonomía, acceso igualitario, comunicación, ahorro tiempo docente.
- Riesgos: Sesgos/errores traducción, privacidad, brecha digital.
- Legal (UE): RGPD Art.9 (vídeo signando = dato biométrico categoría especial); Ley IA 2024/1689 Anexo III (IA en educación = alto riesgo; exige supervisión humana, transparencia y gobernanza).
7. Negocio (B2B): Clientes (Colegios/Institutos/FP/Univ). Oferta (Web, integración LMS, soporte). Ingresos (Suscripción anual, licencias volumen, API). Costes (I+D modelos, infra, validación comunitaria, auditoría legal).
8. Bibliografía: OMS (2019, 2023, 2024), ONU/WFD, Bragg (ASSETS 2019), Camgoz (CVPR 2020), Duarte (CVPR 2021), arXiv (2026), RGPD (2016/679), AI Act (2024/1689).
9. IAs usadas en el proyecto: Gemini (búsqueda info), ChatGPT (logo/refinamiento), Kimi.ai (presentación).

[SALIDA]
Entrega árbol de directorios y script listo para ejecutar y realizar el despliegue completo de todos los archivos (Frontend, Backend, BD, Docker, README.md) listos para copiar y subir a GitHub. Sin texto introductorio ni explicaciones fuera del código.
```

---

## Prompt 4: Documentación de la conversación
**Objetivo:** Generar un archivo Markdown con el historial de prompts empleados en el chat.

```text
hazme un .md con un registro de prompts de esta conversación
```