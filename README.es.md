<div align="center">
  <img src="kali-logo-matrix.svg" alt="Kali logo (matrix style)" width="160"/>
</div>

# Script de Construcción de Instalador Kali (Versión Compatible con Ubuntu)

_Constructor de imágenes ISO del instalador de Kali Linux, vía `simple-cdd` (con `debian-cd`)._

Esta es una modificación del [script original de kali-installer](https://gitlab.com/kalilinux/build-scripts/kali-installer) adaptado para funcionar en Ubuntu y otras distribuciones basadas en Debian.

Estas imágenes pueden usarse para instalar Kali con varias personalizaciones durante la configuración, desde CD/DVD/Blu-ray/USB/tarjeta SD.

## Características

- Funciona en Ubuntu, Debian y otras distribuciones basadas en Debian
- Genera imágenes ISO estándar
- Salida opcional de imagen de disco `.img` cruda
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

### Instalar desde paquete Debian

```console
$ sudo dpkg -i kali-installer-ubuver.deb
$ build_ins_kali --help
$ sudo build_ins_kali -v everything -z
```

El instalador preguntará si desea usar `~/isos_kali` como directorio de salida.

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
- `-I, --img`: Generar imagen `.img` cruda (opcional, deshabilitado por defecto)
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

## Nombrado de la salida

El ISO generado conserva la versión de Kali donde estaba antes y añade el
número de versión instalado por la release después de la arquitectura
(ej. `kali-linux-rolling-installer-netinst-amd64-2026.4.2.iso`).

## Guía de Uso

Ver `GUIDE.md` para una explicación completa del funcionamiento en inglés y español.
