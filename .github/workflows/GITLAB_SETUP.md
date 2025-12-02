# Configuración de Secretos para GitLab

Este documento explica cómo configurar los secretos necesarios para usar GitLab como plataforma de destino en el workflow de dumps.

## Requisitos Previos

Para usar GitLab como plataforma de destino, necesitas configurar dos secretos en este repositorio de GitHub:

1. `GITLAB_TOKEN` - Token de acceso personal de GitLab
2. `GITLAB_SSH_KEY` - Clave SSH privada para autenticación

## Paso 1: Crear un Token de GitLab

### 1.1 Acceder a GitLab
1. Inicia sesión en [GitLab.com](https://gitlab.com) o tu instancia de GitLab
2. Ve a tu perfil (esquina superior derecha) → **Settings**

### 1.2 Crear el Token
1. En el menú lateral izquierdo, selecciona **Access Tokens**
2. Haz clic en **Add new token**
3. Completa los campos:
   - **Token name**: `DumprX2` (o el nombre que prefieras)
   - **Expiration date**: Selecciona una fecha de expiración (recomendado: 1 año)
   - **Scopes**: Marca las siguientes casillas:
     - ✅ `api` - Acceso completo a la API
     - ✅ `write_repository` - Escribir en repositorios
4. Haz clic en **Create personal access token**
5. **IMPORTANTE**: Copia el token inmediatamente (comienza con `glpat-`). No podrás verlo de nuevo.

## Paso 2: Crear una Clave SSH

### 2.1 Generar la Clave SSH (si no tienes una)

En tu terminal local, ejecuta:

```bash
ssh-keygen -t rsa -b 4096 -C "tu_email@ejemplo.com"
```

Cuando se te pida el nombre del archivo, puedes usar el predeterminado (`~/.ssh/id_rsa`) o especificar uno diferente:
- Si usas el predeterminado: presiona Enter
- Si quieres un archivo específico: escribe `/home/usuario/.ssh/gitlab_dumprx2`

**No** configures una contraseña cuando se te solicite (solo presiona Enter dos veces).

### 2.2 Añadir la Clave Pública a GitLab

1. Copia el contenido de tu clave **pública**:
   ```bash
   cat ~/.ssh/id_rsa.pub
   # O si usaste un nombre diferente:
   cat ~/.ssh/gitlab_dumprx2.pub
   ```

2. En GitLab:
   - Ve a **Settings** → **SSH Keys**
   - Pega el contenido de la clave pública en el campo **Key**
   - Dale un título descriptivo (ej: "DumprX2 Workflow")
   - Haz clic en **Add key**

### 2.3 Copiar la Clave Privada

Copia el contenido de tu clave **privada**:

```bash
cat ~/.ssh/id_rsa
# O si usaste un nombre diferente:
cat ~/.ssh/gitlab_dumprx2
```

**IMPORTANTE**: Debes copiar **todo** el contenido, incluyendo las líneas:
- `-----BEGIN OPENSSH PRIVATE KEY-----`
- `-----END OPENSSH PRIVATE KEY-----`

## Paso 3: Configurar los Secretos en GitHub

### 3.1 Acceder a la Configuración de Secretos

1. Ve a este repositorio en GitHub
2. Haz clic en **Settings** (pestaña superior)
3. En el menú lateral izquierdo, selecciona **Secrets and variables** → **Actions**

### 3.2 Añadir GITLAB_TOKEN

1. Haz clic en **New repository secret**
2. Completa los campos:
   - **Name**: `GITLAB_TOKEN`
   - **Secret**: Pega el token de GitLab que copiaste en el Paso 1.2
3. Haz clic en **Add secret**

### 3.3 Añadir GITLAB_SSH_KEY

1. Haz clic en **New repository secret**
2. Completa los campos:
   - **Name**: `GITLAB_SSH_KEY`
   - **Secret**: Pega el contenido completo de la clave privada que copiaste en el Paso 2.3
3. Haz clic en **Add secret**

## Verificación

Después de configurar ambos secretos, deberías ver en la página de secretos:

```
GITLAB_TOKEN      Updated X minutes ago
GITLAB_SSH_KEY    Updated X minutes ago
```

## Uso del Workflow

Una vez configurados los secretos, puedes usar GitLab como plataforma:

1. Ve a **Actions** → **Create Device Dump**
2. Haz clic en **Run workflow**
3. Configura los parámetros:
   - **dump_url**: URL del firmware
   - **platform**: Selecciona `gitlab`
   - **repo_url**: URL del repositorio en GitLab (ej: `https://gitlab.com/dumps/xiaomi/device`)
   - **github_token**: Dejar vacío
4. El workflow usará automáticamente los secretos `GITLAB_TOKEN` y `GITLAB_SSH_KEY`

## Solución de Problemas

### Error: "Permission denied (publickey)"
- Verifica que la clave pública esté correctamente añadida en GitLab
- Asegúrate de que la clave privada completa (con BEGIN y END) esté en el secreto `GITLAB_SSH_KEY`

### Error: "Invalid token"
- Verifica que el token de GitLab sea válido y no haya expirado
- Asegúrate de que el token tenga los permisos `api` y `write_repository`

### Error: "Failed to create project"
- Verifica que tengas permisos para crear proyectos en el grupo/organización de GitLab
- Si el grupo no existe, créalo manualmente primero en GitLab

## Seguridad

- **Nunca** compartas tus secretos públicamente
- Los secretos están encriptados en GitHub y no son visibles después de ser guardados
- Si crees que tus secretos han sido comprometidos:
  1. Revoca el token en GitLab (Settings → Access Tokens)
  2. Elimina la clave SSH de GitLab (Settings → SSH Keys)
  3. Genera nuevos secretos siguiendo esta guía
  4. Actualiza los secretos en GitHub

## Recursos Adicionales

- [Documentación de GitLab sobre Access Tokens](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html)
- [Documentación de GitLab sobre SSH Keys](https://docs.gitlab.com/ee/user/ssh.html)
- [Documentación de GitHub sobre Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
