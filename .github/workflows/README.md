# Workflow de Creación de Dump de Dispositivo

Este workflow de GitHub Actions permite crear un dump de un dispositivo de forma automatizada y subirlo a **GitHub** o **GitLab**.

## Cómo usar el workflow

1. Ve a la pestaña **Actions** de este repositorio
2. Selecciona el workflow **"Create Device Dump"** en el panel izquierdo
3. Haz clic en el botón **"Run workflow"** en el lado derecho
4. Completa los siguientes campos requeridos:

### Parámetros de entrada

#### 1. URL del dump del firmware
- **Campo**: `dump_url`
- **Descripción**: URL donde se encuentra el archivo de firmware a procesar
- **Formatos soportados**:
  - Enlaces directos de descarga
  - mega.nz
  - mediafire.com
  - drive.google.com
  - onedrive
  - androidfilehost.com
- **Ejemplo**: `'https://mega.nz/file/abcd1234'`
- **Nota**: Debe estar entre comillas simples si contiene caracteres especiales

#### 2. Plataforma de destino
- **Campo**: `platform`
- **Descripción**: Selecciona si quieres subir el dump a GitHub o GitLab
- **Opciones**:
  - `github` (por defecto)
  - `gitlab`
- **Nota**: Dependiendo de la plataforma seleccionada, deberás proporcionar las credenciales correspondientes

#### 3. URL del repositorio de destino
- **Campo**: `repo_url`
- **Descripción**: URL del repositorio donde se subirá el dump
- **Formato para GitHub**: `https://github.com/usuario/nombre-repositorio`
- **Formato para GitLab**: `https://gitlab.com/usuario/nombre-repositorio`
- **Ejemplo GitHub**: `https://github.com/myorg/device-dump`
- **Ejemplo GitLab**: `https://gitlab.com/mygroup/brand/device-dump`
- **Nota**: El workflow extraerá automáticamente el nombre de usuario/organización de esta URL

#### 4. Token de GitHub (solo si se selecciona GitHub)
- **Campo**: `github_token`
- **Descripción**: Token de acceso personal de GitHub con permisos de escritura
- **Permisos necesarios**:
  - `repo` (acceso completo a repositorios)
  - `workflow` (si se necesita actualizar workflows)
- **Cómo crear un token**:
  1. Ve a GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
  2. Haz clic en "Generate new token (classic)"
  3. Selecciona los permisos `repo`
  4. Genera y copia el token
- **Nota**: Este token se mantendrá seguro y no se mostrará en los logs

### Secretos necesarios para GitLab

Si seleccionas **GitLab** como plataforma, debes configurar los siguientes secretos en el repositorio:

#### GITLAB_TOKEN
- **Descripción**: Token de acceso personal de GitLab con permisos de escritura
- **Permisos necesarios**:
  - `api` (acceso completo a la API)
  - `write_repository` (escribir en repositorios)
- **Cómo configurarlo**:
  1. Crea un token en GitLab: Settings → Access Tokens
  2. Selecciona los permisos `api` y `write_repository`
  3. Copia el token
  4. En este repositorio, ve a Settings → Secrets and variables → Actions
  5. Haz clic en "New repository secret"
  6. Nombre: `GITLAB_TOKEN`
  7. Valor: Pega el token de GitLab
  8. Haz clic en "Add secret"

#### GITLAB_SSH_KEY
- **Descripción**: Clave SSH privada para autenticación con GitLab (necesaria para subir repositorios grandes)
- **Formato**: Contenido completo de tu clave privada SSH (típicamente `~/.ssh/id_rsa`)
- **Cómo configurarlo**:
  1. Genera una clave SSH si no tienes una: `ssh-keygen -t rsa -b 4096 -C "tu_email@ejemplo.com"`
  2. Añade la clave pública a GitLab: Settings → SSH Keys
  3. Copia el contenido de la clave privada: `cat ~/.ssh/id_rsa`
  4. En este repositorio, ve a Settings → Secrets and variables → Actions
  5. Haz clic en "New repository secret"
  6. Nombre: `GITLAB_SSH_KEY`
  7. Valor: Pega el contenido completo de la clave privada (incluye las líneas BEGIN y END)
  8. Haz clic en "Add secret"
- **Importante**: GitLab requiere autenticación SSH para repositorios grandes debido a limitaciones de HTTPS

## Proceso del workflow

El workflow realiza los siguientes pasos:

1. **Checkout del repositorio**: Descarga el código de DumprX
2. **Liberación de espacio en disco**: Elimina software innecesario para liberar espacio (3 pasos)
3. **Configuración de Python**: Instala Python 3.9
4. **Instalación de dependencias**: Instala todas las herramientas necesarias para procesar el firmware
5. **Instalación de uv**: Instala el gestor de paquetes Python uv
6. **Configuración de Git**: Configura el usuario de Git para hacer commits
7. **Configuración de credenciales**:
   - **Para GitHub**: Guarda el token de GitHub en un archivo `.github_token`
   - **Para GitLab**: Guarda el token en `.gitlab_token` y configura la clave SSH para autenticación
8. **Extracción del nombre de organización**: Extrae automáticamente el nombre de usuario/organización del repositorio de destino
9. **Configuración de la plataforma**: Configura los archivos necesarios según la plataforma seleccionada
10. **Ejecución del dumper**: Ejecuta el script `dumper.sh` con la URL del firmware
11. **Subida de artefactos** (solo si falla): Si el proceso falla, sube los archivos generados como artefactos

## Diferencias entre GitHub y GitLab

### GitHub
- **Autenticación**: Utiliza token HTTPS
- **Repositorio**: Se crea automáticamente si no existe
- **Límites**: Archivos hasta 100MB (con Git LFS para archivos más grandes)
- **Velocidad**: Push via HTTPS es generalmente rápido

### GitLab
- **Autenticación**: Utiliza SSH (requerido para repositorios grandes)
- **Repositorio**: Se crea automáticamente con estructura de grupos/subgrupos
- **Límites**: Similar a GitHub, pero requiere SSH para grandes volúmenes
- **Velocidad**: SSH es más confiable para repositorios grandes
- **Estructura**: Soporta grupos y subgrupos (ej: `grupo/marca/dispositivo`)

## Ejemplos de uso

### Ejemplo 1: Subir a GitHub
```yaml
dump_url: 'https://mega.nz/file/abcd1234'
platform: github
repo_url: https://github.com/myorg/xiaomi-dump
github_token: ghp_xxxxxxxxxxxx
```

### Ejemplo 2: Subir a GitLab
```yaml
dump_url: 'https://mediafire.com/file/xyz789'
platform: gitlab
repo_url: https://gitlab.com/dumps/xiaomi/redmi-note-9
github_token: (dejar vacío)
```

**Nota para GitLab**: Asegúrate de haber configurado los secretos `GITLAB_TOKEN` y `GITLAB_SSH_KEY` en el repositorio antes de ejecutar el workflow.

## Formatos de firmware soportados

El script soporta múltiples formatos de firmware:
- `.zip`, `.rar`, `.7z`, `.tar`, `.tar.gz`, `.tgz`, `.tar.md5`
- `.ozip`, `.ofp`, `.ops` (Oppo/OnePlus)
- `.kdz` (LG)
- `ruu_*.exe` (HTC)
- `system.new.dat`, `system.new.dat.br`, `system.new.dat.xz`
- `system.img`, `system-sign.img`, `UPDATE.APP`
- `*.emmc.img`, `*.img.ext4`, `system.bin`, `system-p`
- `payload.bin` (OTA A/B)
- `*.nb0`, `*chunk*`, `*.pac`, `*super*.img`, `*system*.sin`

## Resultado

Una vez completado el workflow:
- El dump del firmware se subirá automáticamente al repositorio especificado
- Se creará una nueva rama con el nombre basado en la descripción del firmware
- Se generarán archivos como:
  - `README.md` con información del dispositivo
  - `all_files.txt` con lista de todos los archivos
  - `proprietary-files.txt` con lista de archivos propietarios
  - Árboles de dispositivo TWRP y AOSP (si aplica)
  - Particiones extraídas (system, vendor, boot, etc.)

## Solución de problemas

### El workflow falla durante la descarga
- Verifica que la URL del firmware sea correcta y accesible
- Para URLs de mega.nz, mediafire, etc., asegúrate de que el enlace sea público

### Error de permisos al subir al repositorio
- Verifica que el token de GitHub tenga los permisos correctos
- Asegúrate de que el repositorio de destino existe o que tienes permisos para crearlo

### El workflow tarda mucho tiempo
- Los archivos de firmware grandes pueden tardar en descargarse y procesarse
- El workflow tiene un límite de tiempo de 6 horas

## Opciones adicionales (opcional)

Si deseas recibir notificaciones en Telegram cuando se complete el dump, puedes crear:
- Un archivo `.tg_token` con tu token de bot de Telegram
- Un archivo `.tg_chat` con tu ID de chat/canal de Telegram

Estos archivos deben agregarse al repositorio antes de ejecutar el workflow.
