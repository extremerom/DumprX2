# Manejo de Archivos del Sistema (System Files)

## Problema Común: Error al Subir Archivos del Sistema

Cuando se extraen dumps de firmware, particularmente los directorios `system/`, estos pueden contener:
- Miles de archivos
- Archivos binarios grandes (.spv, .so, .apk, etc.)
- Certificados y configuraciones

Al intentar hacer `git push` de todos estos archivos a la vez, es común encontrar errores como:
```
error: RPC failed; HTTP 500 curl 22 The requested URL returned error: 500
send-pack: unexpected disconnect while reading sideband packet
```

Este error ocurre porque:
1. El tamaño total de los archivos excede los límites de GitHub
2. Hay demasiados archivos en un solo commit
3. Archivos binarios grandes no están configurados para Git LFS

## Solución: Organización en Commits Múltiples

Este repositorio incluye herramientas para manejar este problema:

### 1. Configuración de Git LFS

El archivo `.gitattributes` ya está configurado para rastrear automáticamente archivos binarios grandes con Git LFS:

- `*.spv` - Archivos binarios de shaders (imagefilter program binary)
- `*.img` - Imágenes de particiones
- `*.bin` - Archivos binarios
- `*.so` - Librerías compartidas
- `*.apk` - Aplicaciones Android
- `*.jar` - Archivos Java

**Asegúrate de tener Git LFS instalado:**
```bash
# Ubuntu/Debian
sudo apt-get install git-lfs

# Inicializar en el repositorio
git lfs install
```

### 2. Script de Organización Automática

Usa el script `organize_system_files.sh` para analizar y obtener recomendaciones:

```bash
./organize_system_files.sh system/
```

Este script:
- Analiza el directorio system
- Cuenta archivos y calcula tamaños
- Proporciona comandos específicos para dividir los commits

### 3. Estrategia de Commits Recomendada

Divide los archivos del sistema en **5 partes**:

#### Parte 1: Archivos SPV (Commit Separado)
Los archivos `.spv` son binarios de shaders y deben ir en un commit aparte:

```bash
# Opción 1: Usando find (más portable)
find system -name "*.spv" -type f -exec git add {} +
git commit -m "Add SPV shader binary files"
git push origin <branch-name>

# Opción 2: Usando globbing (requiere: shopt -s globstar)
shopt -s globstar
git add system/**/*.spv
git commit -m "Add SPV shader binary files"
git push origin <branch-name>
```

#### Parte 2: Archivos de Configuración XML/CONF/TXT
```bash
# Opción 1: Usando find (más portable)
find system -path "*/etc/*" \( -name "*.xml" -o -name "*.conf" -o -name "*.txt" \) -type f -exec git add {} +
git commit -m "Add system configuration files (Part 1/5)"
git push origin <branch-name>

# Opción 2: Usando globbing (requiere: shopt -s globstar)
shopt -s globstar
git add system/**/etc/**/*.xml
git add system/**/etc/**/*.conf  
git add system/**/etc/**/*.txt
git commit -m "Add system configuration files (Part 1/5)"
git push origin <branch-name>
```

#### Parte 3: Certificados
```bash
# Usando rutas específicas
git add system/system/etc/epdg/certificates/ 2>/dev/null || git add system/etc/epdg/certificates/
git commit -m "Add certificate files (Part 2/5)"
git push origin <branch-name>
```

#### Parte 4: Archivos Init y Servicios
```bash
# Usando rutas específicas
git add system/system/etc/init/ 2>/dev/null || git add system/etc/init/
git commit -m "Add init and service files (Part 3/5)"
git push origin <branch-name>
```

#### Parte 5: Configuración de Fuentes y Display
```bash
# Opción 1: Usando find
find system -path "*/etc/font*" -o -path "*/etc/display*" | xargs -r git add
git commit -m "Add font and display configuration (Part 4/5)"
git push origin <branch-name>

# Opción 2: Usando globbing (requiere: shopt -s globstar)
shopt -s globstar
git add system/**/etc/font*
git add system/**/etc/display*
git commit -m "Add font and display configuration (Part 4/5)"
git push origin <branch-name>
```

#### Parte 6: Archivos Restantes
```bash
git add system/
git commit -m "Add remaining system files (Part 5/5)"
git push origin <branch-name>
```

### 4. Verificación

Después de cada push, verifica que no haya errores:
```bash
git status
git log --oneline -5
```

## Ignorar el Directorio System

El archivo `.gitignore` está configurado para ignorar el directorio `system/` por defecto. Esto previene commits accidentales de archivos grandes.

Para agregar archivos del sistema:
1. Usa el script `organize_system_files.sh` para planificar
2. Usa `git add -f` para forzar la adición de archivos específicos
3. O temporalmente comenta la línea `system/` en `.gitignore`

## Troubleshooting

### Error: "this exceeds GitHub's file size limit"
- Asegúrate de que Git LFS esté instalado y configurado
- Verifica que `.gitattributes` incluya los tipos de archivo problemáticos
- Usa `git lfs track "*.extension"` para archivos adicionales

### Error: "pack exceeds maximum allowed size"
- Divide en commits más pequeños
- Haz push después de cada commit en lugar de acumular varios commits

### Error: "The remote end hung up unexpectedly"
- Reduce el tamaño de cada commit
- Aumenta el buffer de git: `git config http.postBuffer 524288000`
- Usa conexión de red más estable

## Ejemplo Completo

```bash
# 1. Instalar Git LFS
sudo apt-get install git-lfs
git lfs install

# 2. Analizar el directorio system
./organize_system_files.sh system/

# 3. Seguir las recomendaciones del script
# (Hacer commits por partes como se indica arriba)

# 4. Verificar
git log --oneline
git lfs ls-files  # Ver archivos rastreados por LFS
```

## Referencias

- [Git LFS Documentation](https://git-lfs.github.com/)
- [GitHub File Size Limits](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github)
- [Best Practices for Large Repositories](https://docs.github.com/en/repositories/working-with-files/managing-large-files)
