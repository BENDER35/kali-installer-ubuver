# Script Guide / Guía del Script

## English

### Overview

This script builds custom Kali Linux installer ISO images using `simple-cdd` (which wraps `debian-cd`). It's designed to work on Debian, Ubuntu, and other Debian-based systems.

### How it works

1. **Validation**: Checks OS compatibility, validates arguments, and checks for required packages (`debian-cd`, `simple-cdd`).
2. **Configuration**: Sets up build environment variables based on user options (architecture, branch, variant, mirror, etc.)
3. **Proxy Detection**: Automatically detects apt-caching proxies (apt-cacher-ng, squid-deb-proxy) on localhost if using default mirror.
4. **Build Process**: 
   - Copies debian-cd templates to `simple-cdd/debian-cd/`
   - Configures profiles based on selected variant (default, everything, netinst, purple)
   - Sets up preseed files for unattended installation
   - Invokes `build-simple-cdd` to generate the ISO
   - Optionally copies ISO as raw `.img` disk image (if `-I/--img` is used)
5. **Post-processing**: Moves files to output directory, generates checksums, optionally creates ZIP archive

### Key Files

- `build.sh`: Main build script
- `build_ins_kali`: Command installed by the `.deb` package (wrapper for `build.sh`)
- `build-in-container.sh`: Container-based build wrapper (Docker/Podman)
- `simple-cdd/`: Simple-CDD configuration (profiles, hooks, etc.)
- `kali-config/`: Variant-specific configurations (packages, bootloaders)
- `Dockerfile`: Container build environment

### Build Variants

- **default**: Standard Kali installer with core metapackages
- **everything**: Includes all Kali metapackages (larger ISO)
- **netinst**: Minimal network installer (smaller, downloads packages during install)
- **purple**: Kali Purple variant for defensive security

### Output naming

The generated ISO keeps the Kali version where it was before and appends the
version number installed by the release after the architecture:
`kali-linux-<kali-version>-<project>-<variant>-<arch>-<installed-version>.iso`
(e.g. `kali-linux-rolling-installer-netinst-amd64-2026.4.2.iso`).

### Jigdo Support

Jigdo (Jigsaw Download) allows distributed reconstruction of ISO images. When enabled with `-j/--jigdo`:
- Generates `.jigdo` and `.template` files
- Also generates `.list.gz` with package listing
- Helps with verification and distributed mirroring
- Configured via `DOJIGDO`, `MAXISOS`, `MAXJIGDOS` in debian-cd environment


### External APT repositories

You can inject a custom APT repository with a GPG key and install packages from it in the target system:

```bash
sudo ./build.sh -v default \
  -r https://repo.example.com/debian \
  --repo-suite stable \
  --repo-comp main \
  --repo-key https://repo.example.com/repo.key \
  --repo-packages "package1 package2"
```

If `--repo-key` points to a local file, it is copied into the ISO via `all_extras`. The `kali.postinst` script will import it into `/etc/apt/keyrings/`, create a deb822 `.sources` file in `/etc/apt/sources.list.d/`, run `apt-get update`, and install the requested packages.

### Common Use Cases

```bash
# Using the script directly
sudo ./build.sh

# Using the installed deb command
sudo build_ins_kali

# Basic build (creates .iso only; add -I to also create .img)
sudo build_ins_kali

# Build with jigdo, zip, and raw .img output
sudo build_ins_kali -v everything -j -z -I

# Build for ARM64 with custom mirror
sudo build_ins_kali -a arm64 -m http://kali.download/kali

# Keep temp files and debug
sudo DEBUG=1 build_ins_kali -k
```

---

## Español

### Resumen

Este script construye imágenes ISO personalizadas del instalador de Kali Linux usando `simple-cdd` (que envuelve a `debian-cd`). Está diseñado para funcionar en Debian, Ubuntu y otras distribuciones basadas en Debian.

### ¿Cómo funciona?

1. **Validación**: Verifica la compatibilidad del SO, valida argumentos y comprueba paquetes requeridos (`debian-cd`, `simple-cdd`).
2. **Configuración**: Establece variables de entorno según las opciones del usuario (arquitectura, rama, variante, mirror, etc.)
3. **Detección de proxy**: Detecta automáticamente proxies de caché APT (apt-cacher-ng, squid-deb-proxy) en localhost si usa el mirror por defecto.
4. **Proceso de construcción**:
   - Copia plantillas de debian-cd a `simple-cdd/debian-cd/`
   - Configura perfiles según la variante seleccionada
   - Configura archivos preseed para instalación desatendida
   - Invoca `build-simple-cdd` para generar el ISO
   - Opcionalmente copia el ISO como imagen de disco `.img` cruda (si se usa `-I/--img`)
5. **Post-procesamiento**: Mueve archivos al directorio de salida, genera checksums, opcionalmente crea ZIP

### Archivos clave

- `build.sh`: Script principal
- `build_ins_kali`: Comando instalado por el paquete `.deb` (wrapper de `build.sh`)
- `build-in-container.sh`: Versión para contenedores (Docker/Podman)
- `simple-cdd/`: Configuración de Simple-CDD
- `kali-config/`: Configuraciones específicas por variante
- `Dockerfile`: Entorno para contenedor

### Variantes disponibles

- **default**: Instalador estándar con metapaquetes básicos
- **everything**: Incluye todos los metapaquetes (ISO más grande)
- **netinst**: Instalador mínimo por red (más pequeño, descarga paquetes durante instalación)
- **purple**: Variante Kali Purple para ciberseguridad defensiva

### Nombrado de la salida

El ISO generado conserva la versión de Kali donde estaba antes y añade el
número de versión que instala la release después de la arquitectura:
`kali-linux-<version-kali>-<proyecto>-<variante>-<arq>-<version-instalada>.iso`
(ej. `kali-linux-rolling-installer-netinst-amd64-2026.4.2.iso`).

### Soporte para Jigdo

Jigdo permite reconstruir imágenes ISO de forma distribuida. Con `-j/--jigdo`:
- Genera archivos `.jigdo` y `.template`
- Genera `.list.gz` con lista de paquetes
- Facilita verificación y mirroring distribuido
- Configurado vía variables de debian-cd


### Repositorios APT externos

Es posible añadir un repositorio APT personalizado con su clave GPG e instalar paquetes en el sistema final:

```bash
sudo ./build.sh -v default \
  -r https://repo.example.com/debian \
  --repo-suite stable \
  --repo-comp main \
  --repo-key https://repo.example.com/repo.key \
  --repo-packages "paquete1 paquete2"
```

Si `--repo-key` apunta a un archivo local, se copia al ISO con `all_extras`. El script `kali.postinst` lo importa en `/etc/apt/keyrings/`, crea un fichero `.sources` en formato deb822 en `/etc/apt/sources.list.d/`, ejecuta `apt-get update` e instala los paquetes solicitados.

### Casos de uso comunes

```bash
# Usando el script directamente
sudo ./build.sh

# Usando el comando instalado por el deb
sudo build_ins_kali

# Construcción básica (crea .iso; añadir -I para crear también .img)
sudo build_ins_kali

# Construir con jigdo, zip e imagen .img
sudo build_ins_kali -v everything -j -z -I

# ARM64 con mirror personalizado
sudo build_ins_kali -a arm64 -m http://kali.download/kali

# Modo debug con archivos temporales
sudo DEBUG=1 build_ins_kali -k
```
