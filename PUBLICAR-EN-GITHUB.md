# Cómo publicar el dashboard en GitHub (paso a paso)

Tú ya tienes el repo listo (index.html + informe + evidencias + README). Solo falta subirlo.

## Opción A — con GitHub CLI (`gh`), lo más rápido
Si tienes `gh` instalado y con sesión iniciada (`gh auth login`):

```bash
git init
git add .
git commit -m "Dashboard CyberRisk 2.0 + Reto 1 completo"
git branch -M main
gh repo create cyberrisk-dashboard --public --source=. --remote=origin --push
```

Luego activa Pages:
```bash
gh api -X POST repos/:owner/cyberrisk-dashboard/pages -f "source[branch]=main" -f "source[path]=/"
```
(o manual: **Settings → Pages → Deploy from a branch → main → /root**).

## Opción B — manual (sin `gh`)
1. Crea el repositorio en https://github.com/new (nombre `cyberrisk-dashboard`, público).
2. En tu carpeta:
```bash
git init
git add .
git commit -m "Dashboard CyberRisk 2.0 + Reto 1 completo"
git branch -M main
git remote add origin https://github.com/<usuario>/cyberrisk-dashboard.git
git push -u origin main
```
3. En GitHub: **Settings → Pages → Source: Deploy from a branch → main → / (root) → Save**.
4. Espera 1–2 min: tu dashboard queda en `https://<usuario>.github.io/cyberrisk-dashboard/`.

## Pasa el enlace a tus compañeros
Comparte el repositorio y el README: cada uno clona, crea su rama (`reto2-...`),
edita **solo su bloque** en `index.html` y abre un Pull Request. Tú los fusionas en `main`
y GitHub Pages se actualiza solo.

---
**Nota:** el repo no contiene datos reales, solo el escenario académico ficticio. Aun así,
las flags y la contraseña del laboratorio están en el informe; si el profesor pide que el repo
sea privado, crea el repositorio como `--private` (GitHub Pages también funciona en privado con
cuentas con esa opción) o quita esas cadenas antes de publicar.
