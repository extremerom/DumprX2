# Guía del Workflow de Creación de Dumps

## ✅ Implementación Completada

Se ha creado exitosamente un workflow de GitHub Actions que permite crear dumps de dispositivos automáticamente y subirlos a **GitHub** o **GitLab**.

## 📋 Archivos Creados/Actualizados

1. `.github/workflows/dump-device.yml` - El workflow principal con soporte para GitHub y GitLab
2. `.github/workflows/README.md` - Documentación completa en español

## 🎯 Parámetros Implementados

El workflow solicita los siguientes parámetros:

### 1. URL del Dump (`dump_url`)
- **Qué es**: La URL donde se encuentra el archivo de firmware a procesar
- **Formatos soportados**: mega.nz, mediafire, gdrive, onedrive, androidfilehost, enlaces directos
- **Cómo se usa**: Se pasa como argumento al script dumper.sh

### 2. Plataforma (`platform`)
- **Qué es**: Selección entre GitHub o GitLab como destino del dump
- **Opciones**: `github` (por defecto) o `gitlab`
- **Cómo se usa**: Determina qué credenciales usar y cómo configurar el repositorio

### 3. URL del Repositorio (`repo_url`)
- **Qué es**: La URL del repositorio de GitHub o GitLab donde se subirá el dump
- **Formato GitHub**: https://github.com/usuario/repositorio
- **Formato GitLab**: https://gitlab.com/grupo/marca/repositorio
- **Cómo se usa**: El workflow extrae automáticamente el nombre de usuario/organización y lo guarda en `.github_orgname` o `.gitlab_group`

### 4. Token de GitHub (`github_token`)
- **Qué es**: Un token de acceso personal de GitHub con permisos de escritura
- **Permisos necesarios**: `repo` (acceso completo a repositorios)
- **Cómo se usa**: Se guarda en `.github_token` que el script dumper.sh utiliza para subir el dump
- **Cuándo es necesario**: Solo cuando se selecciona `platform: github`

## 🔐 Secretos de GitLab

Cuando se selecciona GitLab como plataforma, el workflow utiliza los siguientes secretos del repositorio:

### GITLAB_TOKEN
- **Qué es**: Token de acceso personal de GitLab con permisos API
- **Permisos necesarios**: `api`, `write_repository`
- **Cómo configurarlo**: Settings → Secrets and variables → Actions → New repository secret

### GITLAB_SSH_KEY
- **Qué es**: Clave SSH privada para autenticación con GitLab
- **Por qué es necesario**: GitLab requiere SSH para repositorios grandes (limitación de HTTPS)
- **Formato**: Contenido completo de `~/.ssh/id_rsa` (incluye BEGIN y END)
- **Cómo configurarlo**: Settings → Secrets and variables → Actions → New repository secret

## 🚀 Cómo Usar el Workflow

### Para GitHub:

1. Ve a la pestaña **Actions** del repositorio
2. Selecciona **"Create Device Dump"** en el panel izquierdo
3. Haz clic en **"Run workflow"**
4. Completa los campos:
   - **dump_url**: URL del firmware (ej: `https://mega.nz/file/abc123`)
   - **platform**: Selecciona `github`
   - **repo_url**: URL del repo destino (ej: `https://github.com/miorg/mi-dump`)
   - **github_token**: Tu token de GitHub
5. Haz clic en **"Run workflow"**

### Para GitLab:

**Configuración previa** (solo una vez):
1. Ve a Settings → Secrets and variables → Actions
2. Crea el secreto `GITLAB_TOKEN` con tu token de GitLab
3. Crea el secreto `GITLAB_SSH_KEY` con tu clave SSH privada

**Ejecución del workflow**:
1. Ve a la pestaña **Actions** del repositorio
2. Selecciona **"Create Device Dump"** en el panel izquierdo
3. Haz clic en **"Run workflow"**
4. Completa los campos:
   - **dump_url**: URL del firmware (ej: `https://mega.nz/file/abc123`)
   - **platform**: Selecciona `gitlab`
   - **repo_url**: URL del repo destino (ej: `https://gitlab.com/dumps/xiaomi/device`)
   - **github_token**: Dejar vacío
5. Haz clic en **"Run workflow"**

## 🔍 Cómo Funciona Internamente

### Para GitHub:
```
Usuario → GitHub Actions → Workflow
                              ↓
                    1. Instala dependencias
                    2. Configura Git
                    3. Guarda token → .github_token
                    4. Extrae org → .github_orgname
                    5. Ejecuta dumper.sh
                              ↓
                    dumper.sh lee .github_token y .github_orgname
                              ↓
                    Descarga → Extrae → Sube a GitHub (HTTPS)
```

### Para GitLab:
```
Usuario → GitHub Actions → Workflow
                              ↓
                    1. Instala dependencias
                    2. Configura Git
                    3. Guarda token → .gitlab_token
                    4. Configura SSH → ~/.ssh/id_rsa
                    5. Extrae org → .gitlab_group
                    6. Ejecuta dumper.sh con PUSH_TO_GITLAB=true
                              ↓
                    dumper.sh lee .gitlab_token y .gitlab_group
                              ↓
                    Descarga → Extrae → Sube a GitLab (SSH)
```

## 🔒 Seguridad

El workflow implementa las mejores prácticas de seguridad:

- ✅ Token enmascarado en logs (no se muestra en la salida)
- ✅ Uso de variables de entorno (evita inyección de comandos)
- ✅ Permisos explícitos y mínimos
- ✅ Sin vulnerabilidades según CodeQL
- ✅ Sin alertas de seguridad

## 📦 Dependencias Instaladas Automáticamente

El workflow instala todas las herramientas necesarias:
- Herramientas de compresión: 7z, rar, zip, unzip, p7zip
- Herramientas de Android: device-tree-compiler, simg2img, lpunpack
- Utilidades: aria2, axel (descargadores), detox (limpieza de nombres)
- Python y uv (gestor de paquetes Python)
- Git LFS (para archivos grandes)

## 🎓 Ejemplo de Uso

### Ejemplo 1: GitHub
```yaml
Inputs en la interfaz de GitHub:
- dump_url: https://mega.nz/file/xxxx
- platform: github
- repo_url: https://github.com/myorg/xiaomi-dump
- github_token: ghp_xxxxxxxxxxxx

Resultado:
- El firmware se descarga de mega.nz
- Se extrae y procesa automáticamente
- Se sube a https://github.com/myorg/xiaomi-dump vía HTTPS
- Se crea una nueva rama con el nombre del firmware
```

### Ejemplo 2: GitLab
```yaml
Inputs en la interfaz de GitHub:
- dump_url: https://mediafire.com/file/yyyy
- platform: gitlab
- repo_url: https://gitlab.com/dumps/samsung/galaxy-s21
- github_token: (vacío)

Secretos configurados previamente:
- GITLAB_TOKEN: glpat_xxxxxxxxxxxx
- GITLAB_SSH_KEY: -----BEGIN OPENSSH PRIVATE KEY----- ...

Resultado:
- El firmware se descarga de mediafire
- Se extrae y procesa automáticamente
- Se sube a https://gitlab.com/dumps/samsung/galaxy-s21 vía SSH
- Se crea grupo/subgrupo automáticamente si no existe
- Se crea una nueva rama con el nombre del firmware
```

## 📚 Referencias

- Documentación completa: `.github/workflows/README.md`
- Script principal: `dumper.sh`
- Script de configuración: `setup.sh`

## ⚠️ Notas Importantes

1. El workflow puede tardar entre 30 minutos y 2 horas dependiendo del tamaño del firmware
2. El límite de tiempo es de 6 horas por ejecución
3. Si el proceso falla, los archivos generados se guardan como artefactos por 7 días
4. El token debe tener permisos para crear repositorios (si el repo no existe)

