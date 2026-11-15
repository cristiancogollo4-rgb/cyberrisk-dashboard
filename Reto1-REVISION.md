# Revisión del Reto 1 — ¿qué me falta? (tu parte)

**Tu rol:** Líder Red Team · **Tu reto:** The Marketplace (Nivel 1, techo 3.0).
Esta hoja separa lo que **ya está**, lo que **solo tú puedes completar** (datos del equipo) y lo que es **de tus compañeros**.

---

## ✅ Lo que YA está completo del Reto 1

| Apartado de la rúbrica | Estado | Dónde está |
|---|---|---|
| Reconocimiento y enumeración (nmap, robots.txt, auth JWT) | ✅ | Informe §6.1 · Fig. 1–3 |
| Explotación controlada (6 hallazgos H-01a…f, 3 flags) | ✅ | Informe §6.2–6.3 · Fig. 4–21 |
| Evidencias técnicas (21 capturas) | ✅ | carpeta `evidencias/` |
| Informe Red Team consolidado (resumen + tabla de hallazgos) | ✅ | Informe §7 |
| Clasificación OWASP 2025 (con CWE cuando aplica) | ✅ | Informe §8 |
| Blue Team Nivel 1 (detección + registros + contramedidas) | ✅ | Informe §9 |
| Análisis de impacto CID | ✅ | Informe §10 |
| Riesgos derivados de Marketplace (R-01…R-05) | ✅ | Informe §11 |
| Mapa de calor | ✅ | Informe §12 + dashboard |
| Controles ISO 27001:2022 | ✅ | Informe §13 |
| Contramedidas + plan de tratamiento + riesgo residual | ✅ | Informe §14–15 |
| Uso ético de IA (prompts, resultados, validación, ajustes) | ✅ | Informe §17 (reforzado) |
| Aporte extraordinario: dashboard interactivo (panel Reto 1) | ✅ | `Dashboard-CyberRisk.html` |

**Conclusión: tu reto está técnicamente completo.** Lo que queda son datos administrativos y la coordinación con el equipo.

---

## ✏️ Lo que SOLO TÚ debes completar (no se puede inventar)

Son los campos entre `[corchetes]` del informe y el dashboard:

1. **Portada (§1):** nombre del equipo, tu nombre y apellido, apellidos de Andre y Wilson, nombre del docente.
2. **Dashboard (encabezado):** `[Nombre]` del equipo.
3. **Lecciones aprendidas (§18):** la línea "De equipo: cómo se coordinaron, qué mejorarían".
4. **Uso de IA (§17):** si usaste **otra** herramienta (ChatGPT, Gemini…), añádela; si solo fue Claude, borra esa necesidad.

> Nada de esto es técnico: son 5 minutos de rellenar datos reales del equipo.

---

## 🔎 Opcional — para subir nota en TU reto (no obligatorio en Nivel 1)

- **Capturas más legibles:** si alguna figura quedó pequeña, recórtala a la zona útil (nmap, el token, la flag).
- **Enumeración:** si tienes la salida de `gobuster`/`ffuf`, añádela como anexo (refuerza "reconocimiento", 10%).
- **Sustentación:** prepara explicar en voz alta la *cadena* (XSS → sesión → SQLi → SSH → sudo/tar → docker → root) y **por qué sqlmap falló**: es tu mejor punto para la defensa oral.

---

## 👥 Lo que es de TUS COMPAÑEROS (déjalo en sus manos)

| Entregable | Responsable sugerido | Nota |
|---|---|---|
| Reto 2 — PHP2Shell (explotación + mitigación CVE) | Red Team / compañero | ⚠ CVE de oct-2026: documentar solo lo verificado, sin inventar |
| Reto 3 — dOOMs Day (investigación Blue Team, logs, IoC, timeline) | Andre (Blue Team) | Se evalúa por calidad de la investigación |
| Reto 4 — Mr-Robot (web + escalada, 3 keys) | Red Team / compañero | TryHackMe o VulnHub |
| Paneles 2–4 del dashboard | cada responsable de reto | Plantilla ya lista en `Dashboard-CyberRisk.html` |
| Consolidar riesgos R-06+ de retos 2–4 en la matriz única | Wilson (Riesgos) | La matriz actual solo cubre Reto 1 |
| Ampliar OWASP con H-02/H-03 (PHP2Shell, Mr-Robot) | quien haga cada reto | §8 del informe |
| Unir todo en el PDF final (20 apartados) | Todos | El informe actual es la base |

---

## Archivos de tu entrega (Reto 1)

- `Informe-CyberRisk2.0.html` — informe completo (exportar a PDF: abrir → Ctrl+P → Guardar como PDF).
- `Dashboard-CyberRisk.html` — dashboard interactivo (aporte extraordinario).
- `evidencias/` — 21 capturas (mantener junto al HTML al exportar).
- `Reto1-Marketplace-COMPLETO.md` y `Reto1-Marketplace-PasoAPaso.md` — desarrollo técnico y walkthrough.
