booty - это набор POSIX shell скриптов для создания загрузочных образов операционных систем.

- [booty](#booty)
    - [Quick Start](#quick-start)
    - [Interface](#Interface)
        - [booty build](#booty-build)
        - [booty linux](#booty-linux)
        - [booty ramdisk](#booty-ramdisk)
        - [booty image](#booty-image)
        - [booty run](#booty-run)
        - [import / export](#import--export)
    - [Boot Options](#boot-options)
        - [booty.use-shmfs](#booty.use-shmfs)
        - [booty.use-overlayfs](#booty.use-overlayfs)
        - [booty.search-rootfs](#booty.search-rootfs)
        - [booty.copy-to-ram](#booty.copy-to-ram)
        - [booty.rootfs-changes](#booty.rootfs-changes)
    - [Known Issues](#known-issues)
        - [init as symlink](#init-as-symlink)

## Quick Start

```sh
make install
booty build
qemu-system-x86_64 -cdrom BOOT-x86_64.ISO
```

## Interface

Вы можете использовать программный интерфейс (API) в ваших скриптах для создания загрузочных образов.

### booty build

```sh
booty build
```

Команда выполняет весь цикл сборки загрузочного образа.

```sh
booty build ДИРЕКТОРИЯ ДИРЕКТОРИЯ ДИРЕКТОРИЯ ...
```

Вы можете указать одну или несколько директорий, которые будут использованы для создания загрузочного образа.

```sh
booty build ОБРАЗ ДИРЕКТОРИЯ ...
```
Вы можете указать название файла с образом в начале или в конце списка. Это не обязательный параметр.

Значение по-умолчанию: `BOOT-$(uname -m).ISO`

```sh
booty build ДИРЕКТОРИЯ -- ПАРАМЕТРЫ ЗАГРУЗКИ
```

Через два минуса `--` вы можете задать параметры загрузки, которые будут использованы загрузчиком.

По-умолчанию вам будет предложено стандартное меню загрузчика с небольшой задержкой и список из нескольких вариантов для загрузки с различными опциями, но если установить параметры загрузки, то тогда система будет загружена моментально с указанными параметрами.

![GRUB2](https://github.com/sp00f1ng/booty/blob/htdocs/grub2-menu.png?raw=true)

### booty linux

```sh
booty linux
```

Команда скачивает исходный код Linux и собирает ядро, предоставляя готовые к установке файлы.

Все дополнительные параметры не обязательны.

Опция `--kernel-name` задаёт имя ядра, это всегда linux. Зарезервированная опция.

Опция `--kernel-version` задаёт версию ядра, которую необходимо загрузить.

Опция `--kernel-release` задаёт уникальное имя, когда необходимо собрать различные конфигурации одной и той же версии ядра.

Опция `--config-file` задаёт конфигурационный файл, с которым необходимо собрать ядро.

Опция `--install-path` задаёт путь, куда будут установлены файлы ядра.

Опция `--force` принудительно скачивает исходный код ядра и собирает его.

По-умолчанию скачивается последняя версия ядра Linux и собирается с конфигурацией `defconfig` и `kvm_guest.config`.

По-умолчанию ядро устанавливается в директорию `$PWD/root-XXXXXXXXXX`.

Исходный код ядра всегда сохраняется в директории `$XDG_CACHE_HOME/.booty` или `$HOME/.cache/booty`.

Архив `linux-release#version.pkg.tar` с файлами ядра всегда сохраняется в кэше.

Переменная release задаётся автоматически, md5-сумма файла конфигурации. При сборке одной и той же версии ядра с разной конфигурацией вы получите две версии ядра.

При повторном запуске команды, если ядро было собрано ранее, оно будет установлено сразу.

Для принудительной загрузки исходного кода и сборки ядра используйте опцию `--force`, либо очистите кэш.

### booty ramdisk

```sh
booty ramdisk
```

Команда собирает initrd или initramfs образ используя данные хост-системы, на которой была запущена.

Все дополнительные параметры не обязательны.

Опция `--install-path` задаёт директорию для установки базового окружения.

Опция `--image` задаёт имя образа.

По-умолчанию базовое окружение устанавливается в директорию `ramdisk-XXXXXXXXXX`, после чего создаётся загрузочный образ `ramdisk-XXXXXXXXXX`.

### booty image

### booty run

```sh
booty run ФУНКЦИЯ
```

Данная команда служит для отладки приложения и предназначена только для разработчиков.

Команда запускает любую внутреннюю функцию приложения. `booty run linux_via_http_get_version`

### import / export

For saving and loading features you can run "exportroot" and "importroot".

Well you have installed a "chroot" and you want to save the system state
for future use, so run:

```sh
# booty export linux-chroot/ > vanilla-system-state.img
```

And then, when you want to setup another system from this linux-chroot/, run:

```sh
# booty import linux-chroot/ < vanilla-system-state.img
```

It's usable when you only have one system state and many configurations.

## Boot Options

booty's /init script can handle some kernel options ("cheats") while system boots.

### booty.use-shmfs

All system data will be extracted to the pure "tmpfs" filesystem and then continue booting.

This action may require a lot of RAM.

Example, you have rootfs.cpio image with 1GB system stored in initrd image, and before
system will be loaded completly they needed a 2GB of RAM: 1GB for rootfs.cpio and
one more 1GB for extracted data. Use this with carefully. But if your image stores on
ISO (not in initrd) you need only 1GB free of RAM.

### booty.use-overlayfs

All system data will be mounted as overlays.

### booty.search-rootfs

Option required argument: `booty.search-rootfs=file` or `booty.search-rootfs=directory`.

Search selected file or the directory with overlays on storage devices while booting.

By default all created overlays stores in /system/overlays directory, but you can create
own overlay with naming "filesystem.squashfs", put in root of your HDD and set this option:

```sh
booty.search-rootfs=/filesystem.squashfs
```

### booty.copy-to-ram

Will copy overlays to the RAM before mounting.

For example, you can boot with USB and unplug your USB-stick after system boots.

### booty.rootfs-changes

While using Overlay FS all your data stores in SHMFS (tmpfs, ramffs) by default, but you can
create a empty file on your storage device, then create any supported by kernel filesystem on
this file (image) and use it as storage for your data, instead of storing data in temporarely SHMFS.

Example `booty.rootfs-changes=/dev/sda1` for using whole /dev/sda1 as storage for any changes.
While reboots cache-data is keep. Storage (file with filesystem) must be created manually.

## Known Issues

### init as symlink

## Proof of Concept

----

По всем вопросам, пожеланиям и предложениям пишите на форуме <a href="https://www.linux.org.ru/forum/">www.linux.org.ru/forum/</a> с пометкой <b>booty</b>.
