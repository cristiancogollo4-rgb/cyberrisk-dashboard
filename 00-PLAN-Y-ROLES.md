# CyberRisk 2.0 — Plan de trabajo, explicación y reparto de roles

**Equipo:** (tú), Andre y Wilson — 3 integrantes
**Asignatura:** Ciberseguridad · **Empresa ficticia:** InnovaSec S.A.S.

---

## 1. ¿Qué les están pidiendo, en una frase?

Actuar como una **consultora de ciberseguridad** que:
1. **Ataca** (Red Team) 4 laboratorios autorizados y documenta vulnerabilidades.
2. **Defiende** (Blue Team) proponiendo detección, contención y prevención.
3. **Gestiona el riesgo** (ISO 27001 + MAGERIT/INCIBE) convirtiendo los hallazgos técnicos en riesgos organizacionales con plan de tratamiento.
4. Entrega **un único PDF** de 20 apartados y sustenta 10–15 min.

> La nota NO depende de cuántas flags saquen, sino de la **calidad del análisis, la documentación, las evidencias y la sustentación**. Un equipo que completa los 4 retos puede sacar 4.5, pero si documenta mal, baja.

---

## 2. Sistema de niveles (techo de nota)

| Nivel | Retos requeridos | Nota máx |
|-------|------------------|----------|
| 1 | Marketplace | 3.0 |
| 2 | + PHP2Shell | 3.5 |
| 3 | + dOOMs Day | 4.0 |
| 4 | + Mr-Robot | 4.5 |
| 5 | Los 4 + aporte extraordinario (dashboard, detección avanzada, Purple Team) | 5.0 |

**Nota final = el menor valor entre (nota ponderada de la rúbrica) y (techo del nivel completado).**

**Recomendación realista para 3 personas en 1 semana:** apuntar a **Nivel 3–4** con documentación impecable, y si sobra tiempo, un **aporte extraordinario ligero** (el dashboard) para habilitar el techo de 5.0. Vale más un Nivel 3 brillante que un Nivel 4 a medias.

---

## 3. Reparto de roles (son 4 roles y ustedes 3)

El enunciado define 4 roles de *liderazgo*. Como son 3, uno asume doble liderazgo. Propuesta:

| Integrante | Rol líder | Qué coordina |
|-----------|-----------|--------------|
| **(tú)** | **Líder Red Team** | Reconocimiento, enumeración, explotación de los 4 labs, captura de evidencias. |
| **Andre** | **Líder Blue Team** + **Líder Auditor ISO** | Análisis defensivo, IoCs, investigación dOOMs Day, controles ISO 27001 y plan de tratamiento. |
| **Wilson** | **Líder Análisis de Riesgos** | Matriz MAGERIT/INCIBE, impacto/probabilidad, mapa de calor, OWASP mapping. |

> **Importante:** los roles son de liderazgo, NO división exclusiva. En la sustentación el profe puede preguntar a cualquiera sobre cualquier fase. **Todos deben entender los 4 labs.** Hagan una reunión de 1h donde el líder Red Team explica cada explotación al resto.

Alternativa más equilibrada en carga (Andre va muy cargado arriba): tú llevas Red Team + Blue Team de los labs que atacas; Andre lleva ISO + plan de tratamiento; Wilson lleva Riesgos + OWASP + la investigación dOOMs Day. Decidan según fortalezas.

---

## 4. Cronograma sugerido (1 semana)

| Día | Actividad | Responsable principal |
|-----|-----------|----------------------|
| **1** | Montar entorno (Kali/THM VPN, cuentas HTB/VulnHub). Resolver **Marketplace** completo (3 flags). | Red Team (todos acompañan) |
| **2** | **PHP2Shell**: análisis de los CVE, explotación controlada, mitigación. | Red Team + Blue Team |
| **3** | **dOOMs Day** (Sherlock): análisis de logs, IoCs, timeline. | Blue Team |
| **4** | **Mr-Robot** (3 keys). | Red Team |
| **5** | Clasificación OWASP + **Matriz de riesgos** + mapa de calor. | Riesgos |
| **6** | Controles **ISO 27001** + plan de tratamiento + contramedidas + (opcional) dashboard. | Auditor ISO |
| **7** | Consolidar PDF, revisar evidencias, ensayar sustentación. | Todos |

---

## 5. Entorno técnico que necesitan

- **Kali Linux** (VM o nativo) con: `nmap`, `gobuster`/`ffuf`, `wpscan`, `hydra`, `sqlmap`, `burpsuite`, `netcat`, `john`/`hashcat`.
- **TryHackMe:** cuenta + conexión OpenVPN (o AttackBox en navegador) para Marketplace, PHP2Shell y Mr-Robot (opción A).
- **Hack The Box:** cuenta para el Sherlock **dOOMs Day** (se descargan archivos de evidencia, no se ataca una máquina viva).
- **VulnHub (opción B de Mr-Robot):** descargar la OVA e importar en VirtualBox/VMware en red host-only.

> **Capturas:** desde el minuto 1 tomen screenshots de TODO (comandos y resultados). Nombren los archivos `lab-fase-descripcion.png`. Las evidencias valen 10% y sin ellas no se da por completado un reto.

---

## 6. Reglas éticas (no romperlas, afectan la nota)

- Solo los labs autorizados. Nada de sistemas reales, webs públicas ni DoS.
- No credenciales reales ni datos personales.
- No publicar flags/exploits fuera del contexto académico.
- Documentar el uso de IA (prompts, resultados, validaciones) — apartado 17, vale 5%.
