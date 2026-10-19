# Script de Construcción de Instalador Kali (Versión Compatible con Ubuntu)

_Constructor de imágenes ISO del instalador de Kali Linux, vía `simple-cdd` (con `debian-cd`)._

Esta es una modificación del [script original de kali-installer](https://gitlab.com/kalilinux/build-scripts/kali-installer) adaptado para funcionar en Ubuntu y otras distribuciones basadas en Debian.

Estas imágenes pueden usarse para instalar Kali con varias personalizaciones durante la configuración, desde CD/DVD/Blu-ray/USB/tarjeta SD.

## Características

- Funciona en Ubuntu, Debian y otras distribuciones basadas en Debian
- Genera imágenes ISO estándar
- Crea automáticamente imágenes de disco `.img` crudas
- Soporte opcional para jigdo (descargas distribuidas)
- Crea archivos ZIP comprimidos con todos los archivos generados
- Configurable mediante opciones de línea de comandos y variables de entorno

## Requisitos Previos

Se recomienda construir en un host basado en Linux. Necesitarás acceso root (sudo).

### Clonar el repositorio

```console
$ sudo apt-get install --no-install-recommends git ca-certificates
$ git clone https://gitlab.com/essential_repos/kali-installer-ubuver.git
$ cd ./kali-installer-ubuver/
```

### Instalar dependencias

```console
$ sudo apt-get install --no-install-recommends \
    simple-cdd debian-cd \
    cpio \
    mtools \
    dosfstools \
    xorriso \
    zip
```

En sistemas que no son Kali (como Ubuntu), también puede necesitarse instalar `kali-archive-keyring`.

## Uso

### Ayuda

```console
$ ./build.sh --help
```

### Construcción básica

```console
$ sudo ./build.sh
```

### Opciones comunes

- `-v, --variant VARIANT`: Variante a construir (default, everything, netinst, purple)
- `-a, --arch ARCH`: Arquitectura (amd64, arm64, armhf)
- `-j, --jigdo`: Generar archivos jigdo junto con el ISO
- `-z, --zip`: Crear archivo ZIP con todos los archivos generados
- `-I, --img`: Generar imagen `.img` cruda (habilitado por defecto, usar `--no-img` para desactivar)
- `-k, --keep`: Mantener archivos temporales
- `-o, --output DIR`: Directorio de salida

### Ejemplos

```console
$ sudo ./build.sh --variant everything
$ sudo ./build.sh --variant netinst --jigdo
$ sudo ./build.sh -v default -z
$ sudo DEBUG=1 ./build.sh --keep
```

## ¿Qué es Jigdo?

Jigdo (Jigsaw Download) es un formato de descarga distribuida que permite reconstruir imágenes ISO a partir de archivos individuales descargados de mirrors. Esto reduce el espacio de almacenamiento y permite verificar integridad. Al usar `-j, --jigdo`, el script generará archivos `.jigdo`, `.template` y `.list.gz` junto con el ISO.

## Guía de Uso

Ver `GUIDE.md` para una explicación completa del funcionamiento en inglés y español.
