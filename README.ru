booty - это набор POSIX shell скриптов для создания загрузочных образов операционных систем. 

-> Как создать загрузочный ISO-образ (USB-флешку) с любым дистрибутивом?

<- booty

-> Как перенести контейнер из Docker (Podman) в загрузочный ISO-образ?

<- booty

-> Как загрузиться по сети (PXE) в любой дистрибутив?

<- booty

-> Как загрузить любой дистрибутив полностью в RAM-диск (tmpfs)?

<- booty

-> Как создать дистрибутив с использованием SquashFS + Overlay FS?

<- booty

Какие плюсы использовать booty?

1) ЭТО ПРОСТО. Настроил один раз - используешь всегда. Для создания загрузочного образа с любым дистрибутивом нужно выполнить всего одну команду.

2) ЭТО БЫСТРО. Дистрибутив загружается в оперативную память. Оперативная память - это скорость и экономия ресурса накопителей.

3) ЭТО БЕЗОПАСНО. Выполните "rm -rf /". Нажмите Reset. Операционная система вернётся в исходное состояние.

4) ЭТО НАДЁЖНО. Резервное копирование больше не нужно. 

Какие минусы использовать booty?

1) Отключение питания приведёт к потере всех данных в оперативной памяти. Храните данные в "облаке".

Зависимости:

Обязательные зависимости:

linux (и все необходимые инструменты для его сборки)
cpio (для создания initramfs)

Не обязательные зависимости:

dosfstools, grub2, grub2-efi (для установки загрузчика)
cdrkit (для создания загрузочного образа)

Совсем не обязательные зависимости:

busybox (для пользовательского окружения)
squashfs-tools (для создания файловых систем)

Установка:

# cd booty
# make install

Начало работы:

При наличии всех установленных зависимостей простой запуск команды booty test создаст полностью работоспособный загрузочный образ операционной системы.

Проверить работоспособность образа можно в виртуальной машине qemu-system-x86_64 -enable-kvm -cdrom BOOT-$(uname -m).ISO

Примеры использования:

# booty gentoo-stage3-distfiles/ boot.iso

booty создаст загрузочный образ boot.iso с операционной системой Gentoo, установленной в директории gentoo-stage3-distfiles/.

# booty gentoo-stage3-distfiles/ documents-and-settings/ boot.iso

Помимо самой операционной системы, отдельным "слоем" в образ будут включены различные документы и настройки.

Вы можете хранить дистрибутив в одном месте, все настройки, такие как /etc, /var каталоги в другом месте, а персональные данные /home в третьем месте.

Все указанные директории в процессе загрузки образа будут подключены (SquashFS) как раздельные слои (Overlay FS) друг поверх друга.

# booty gentoo-stage3-distfiles/ boot.iso --profile initramfs

При создании загрузочного образа все данные дистрибутива будут помещены в RAM-диск (initramfs), вместо создания и форматирования SquashFS файловых систем.

Такой профиль рекомендуется использовать для небольших дистрибутивов.

Возможности:

booty проводит весь процесс создания загрузочного образа "от" и "до", требуя от пользователя минимум действий, а именно, нужно только указать директорию, из которой будет создан загрузочный образ.

-> пользователь указывает директорию с дистрибутивом.

<- booty собирает ядро операционной системы.
<- booty собирает RAM-диск (initramfs).
<- booty создаёт файловую систему, копируя пользовательские данные.
<- booty создаёт универсальный загрузочный образ со всеми данными.

Использование:

# booty ДИРЕКТОРИЯ ДИРЕКТОРИЯ ДИРЕКТОРИЯ... ОБРАЗ ПАРАМЕТРЫ

Чтобы создать загрузочный ОБРАЗ укажите ДИРЕКТОРИЮ или несколько.

ПАРАМЕТРЫ могут быть:

--profile ПРОФИЛЬ

Допустимые названия профилей: initramfs overlayfs.

Профиль "initramfs" помещает все пользовательские данные в RAM-диск, профиль предназначен для небольших, компактных дистрибутивов, либо же при загрузке дистрибутива по сети (PXE).

Профиль "overlayfs" помещает все пользовательские данные в SquashFS-образы, а так же использует Overlay FS для работы, подключая каждую указанную ДИРЕКТОРИЮ как отдельный слой. Данный профиль используется по-умолчанию и рекомендуется использовать в большинстве случаев для экономии оперативной памяти.

Примечание: в процессе загрузки вы можете переключиться со SquashFS + Overlay FS на загрузку в RAM-диск (SHMFS, TMPFS, RAMFS).

Интерфейс

Интерфейс командной строки можно использовать в скриптах, чтобы автоматизировать сборки систем под различные нужды.

Внимание: внутренний интерфейс не является стабильным и может меняться (читай: ломаться) от версии к версии, поэтому все перечисленные далее команды используйте на свой страх и риск.

booty linux

booty linux_via_git

booty linux_via_http

booty linux_via_http_get_version

booty ramdisk

booty image

// UNDER CONSTRUCTION
