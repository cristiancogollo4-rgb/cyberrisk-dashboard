# CyberRisk 2.0 — Dashboard del equipo

Dashboard interactivo de la Hackathon **CyberRisk 2.0: The Next Level** (InnovaSec S.A.S., escenario ficticio).
Visualización de hallazgos, riesgos y prioridades por reto, más el informe técnico del laboratorio.

**Sitio publicado (GitHub Pages):** `https://<usuario>.github.io/<repositorio>/`

---

## Estado del equipo

| Reto | Laboratorio | Responsable | Estado |
|------|-------------|-------------|--------|
| 1 | The Marketplace (web) | **Cristian Felipe Cogollo Rodríguez** | ✅ Completo |
| 2 | PHP2Shell (CVE 2026) | **Andrey David Morales Díaz** | ✅ Completo (flag + cadena RCE; evidencias en `evidencias-reto2/`) |
| 3 | dOOMs Day (Blue Team) | **Andrey David Morales Díaz** | ✅ Completo (12/12 preguntas; evidencias en `evidencias-reto3/`) |
| 4 | Mr-Robot (web + escalada) | Wilson Javier Gómez Mantilla | ⏳ Pendiente |

---

## Estructura del repositorio

```
index.html                 ← Dashboard (página principal de GitHub Pages)
Informe-CyberRisk2.0.html  ← Informe técnico completo (20 apartados) — FUENTE a editar
Informe-CyberRisk2.0.pdf   ← PDF consolidado (ENTREGABLE final, apartados 12/13)
generar-pdf.bat            ← Regenera el PDF desde el HTML (doble clic)
evidencias/                ← Capturas del Reto 1 (mk-00…mk-21)
evidencias-reto2/          ← Capturas del Reto 2 (php-00…php-02)
evidencias-reto3/          ← Capturas del Reto 3 (dd-00…dd-12c)
Reto1-Marketplace-COMPLETO.md   ← Desarrollo técnico Reto 1
Reto1-Marketplace-PasoAPaso.md  ← Walkthrough Reto 1
README.md                  ← Este archivo
```

## ⚠ IMPORTANTE — El entregable final es el PDF

El entregable oficial (apartados 12 y 13 del enunciado) es **un único PDF**: `Informe-CyberRisk2.0.pdf`.
Ese PDF se genera a partir de **`Informe-CyberRisk2.0.html`**, que es el archivo que se edita.

**Flujo para todo el equipo:**
1. Edita el contenido en **`Informe-CyberRisk2.0.html`** (tu apartado 6 del reto, hallazgos, etc.)
   y/o tu panel en `index.html`.
2. **Regenera el PDF**: doble clic en **`generar-pdf.bat`** (usa Edge/Chrome, no instala nada).
   - Alternativa: abre el HTML en el navegador → **Ctrl+P → Guardar como PDF**.
3. Sube los cambios (HTML, PDF y tus evidencias) en tu rama y abre el Pull Request.

> No edites el `.pdf` a mano: siempre se **regenera** desde el HTML para que quede consistente.
> El PDF actual cubre el **Nivel 1 (Reto 1)**; se vuelve a generar cuando se sumen los retos 2–4.

Cuando cada compañero haga su reto, añade sus evidencias en su **propia carpeta** para no chocar:
`evidencias-reto2/`, `evidencias-reto3/`, `evidencias-reto4/`.

---

## Cómo cada compañero sube su avance

Cada reto tiene **su propio bloque** en `index.html`, marcado con un comentario grande:

```html
<!-- ====  RETO 2 · PHP2Shell  — EDITA SOLO ESTE BLOQUE  ========== -->
<section class="panel" id="r2"> ... </section>
```

**Reglas de oro para no pisar el trabajo de otros:**
1. Edita **únicamente** el `<section>` de tu reto (`id="r2"`, `"r3"` o `"r4"`). No toques `id="r1"`.
2. Copia el formato del panel del **Reto 1** (`id="r1"`): KPIs, tarjetas de hallazgos, mapa de calor y barras de prioridad.
3. Pon tu nombre en el `[nombre]` de tu panel y actualiza tu fila en la tabla de este README.
4. Añade tus capturas en tu carpeta `evidencias-retoN/`.

### Flujo de trabajo recomendado (evita conflictos)
```bash
git clone https://github.com/<usuario>/<repositorio>.git
cd <repositorio>
git checkout -b reto2-miavance      # una rama por persona
# ...editas tu bloque en index.html...
git add .
git commit -m "Reto 2: panel PHP2Shell"
git push -u origin reto2-miavance
# luego abre un Pull Request en GitHub y lo fusionamos
```
Trabajar en **ramas separadas** + Pull Request es lo más seguro para 3 personas.

---

## Cómo publicar en GitHub Pages (una sola vez)

1. Sube el repositorio a GitHub (ver más abajo).
2. En GitHub: **Settings → Pages**.
3. En *Source* elige **Deploy from a branch**, rama `main`, carpeta `/ (root)`. Guarda.
4. En 1–2 minutos el dashboard estará en `https://<usuario>.github.io/<repositorio>/`.

> En GitHub Pages el botón "Ver informe" y las imágenes **sí** cargan (se sirven por HTTP).
> Al abrir el `index.html` con doble clic desde el disco también funciona.

---

## ⚠ Integridad académica

Los CVE del Reto 2 (PHP2Shell, oct-2026) y el Reto 3 son del escenario de la actividad:
documentar **solo lo verificado en el laboratorio**, sin inventar detalles técnicos (apartado 10 del enunciado).
