# **Подготовка носителей**

Сперва зануляем суперблоки на дисках, которые будем использовать в raid-массиве:

```
sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e}
```

Далее удалим метаданные и подписи на дисках:

```
sudo wipefs --all --force /dev/sd{b,c,d,e}
```

# **Создание RAID-массива**

После подготовки дисков приступим к созданию RAID:

```
sudo mdadm --create --verbose /dev/md0 -l 10 -n 4 /dev/sd{b,c,d,e}
```
В данном случае создаём массив уровня 10 (-l 10), где используется 4 диска (-n 4) 
и называется устройство RAID /dev/md0.

# **Создание конфигурации mdadm**

Для начала создадим директорию, где будет находится наша конфигурация RAID:

```
sudo mkdir /etc/mdadm/
```

Далее создадим сам конфигурационный файл и добавим в него нужные данные:

```
sudo sh -c 'echo "DEVICE partitions" > /etc/mdadm/mdadm.conf'
sudo mdadm --detail --scan --verbose | sudo sh -c "awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf"
```

# **Создание разделов, файловой системы и монтирование**

Создаём таблицу разделов GPT на устройстве RAID:

```
sudo parted -s /dev/md0 mklabel gpt
```

Создаём партиции:
```
sudo parted /dev/md0 mkpart primary ext4 0% 20%
sudo parted /dev/md0 mkpart primary ext4 20% 40%
sudo parted /dev/md0 mkpart primary ext4 40% 60%
sudo parted /dev/md0 mkpart primary ext4 60% 80%
sudo parted /dev/md0 mkpart primary ext4 80% 100%
```

Затем создаём файловую системму (ext4) на полученных партициях:

```
sudo mkfs.ext4 /dev/md0p1
sudo mkfs.ext4 /dev/md0p2
sudo mkfs.ext4 /dev/md0p3
sudo mkfs.ext4 /dev/md0p4
sudo mkfs.ext4 /dev/md0p5
```

Теперь создадим каталоги куда будем монтировать наши устройства:

```
sudo mkdir --parent /mnt/soft_raid/part_{1,2,3,4,5}
```

Монтируем к созданным каталогам полученные ранее партиции:

```
for i in $(seq 1 5); do sudo mount /dev/md0p$i /mnt/soft_raid/part_$i; done
```

Смотрим статистику по файловой системе с помощью команды `df -h` и получаем вывод:

```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        40G  4,8G   36G  12% /
devtmpfs        488M     0  488M   0% /dev
tmpfs           496M     0  496M   0% /dev/shm
tmpfs           496M  6,8M  489M   2% /run
tmpfs           496M     0  496M   0% /sys/fs/cgroup
tmpfs           100M     0  100M   0% /run/user/1000
/dev/md0p1       91M  1,6M   83M   2% /mnt/soft_raid/part_1
/dev/md0p2       92M  1,6M   84M   2% /mnt/soft_raid/part_2
/dev/md0p3       93M  1,6M   85M   2% /mnt/soft_raid/part_3
/dev/md0p4       92M  1,6M   84M   2% /mnt/soft_raid/part_4
/dev/md0p5       91M  1,6M   83M   2% /mnt/soft_raid/part_5
```

# **Сохраняем проект в репозиторий**

Переходим в папку с проектом:

```
cd /disk_subsystem_quest
```

Создаём репозиторий Git:

```
git init
```

Добавляем наш удалённый репозиторий для проекта:

```
git remote add origin https://github.com/krantser/disk_subsystem_quest.git
```

Просмотрим изменения:

```
git status
```

Добавляем файлы для отслеживания:

```
git add Vagrantfile README.md
```

