[Install cephadm utility](https://docs.ceph.com/en/latest/cephadm/install/#distribution-specific-installations) on your intended mon-1 host as root user(in my case, kolla-1)

```
(root)# apt install -y cephadm
```

Add repo:

```
cephadm bootstrap --mon-ip <MON-IP> \
  --initial-dashboard-user admin \
  --initial-dashboard-password YOURPASSWORD \
  --dashboard-password-noupdate \
  --allow-fqdn-hostname
```
Output of this can be found [here](https://gist.github.com/anande/872dff44eddd5039cb26fa7ae9cf6b8e)

### Install ceph CLI

By default ceph commands cant be directly run, one needs to enter the cephadm shell to run the commands:

```
root@kolla-1:~# cephadm shell
Inferring fsid 7171f0d9-3e14-11f0-8055-fa163e2353fb
Inferring config /var/lib/ceph/7171f0d9-3e14-11f0-8055-fa163e2353fb/mon.kolla-1/config
This is a development version of cephadm.
For information regarding the latest stable release:
    https://docs.ceph.com/docs/squid/cephadm/install
root@kolla-1:/# ceph -s 
  cluster:
    id:     7171f0d9-3e14-11f0-8055-fa163e2353fb
    health: HEALTH_WARN
            OSD count 0 < osd_pool_default_size 3
 
  services:
    mon: 1 daemons, quorum kolla-1 (age 9m)
    mgr: kolla-1.ialwwt(active, since 3m)
    osd: 0 osds: 0 up, 0 in
 
  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:
```

You can install the ceph-common package, which contains all of the ceph commands, including ceph, rbd, mount.ceph (for mounting CephFS file systems), etc.:

```
cephadm install ceph-common
```

After installing this pkg, one can run commands from outside the cephadm shell:

```
root@kolla-1:~# ceph health
HEALTH_WARN OSD count 0 < osd_pool_default_size 3
```

### Copy ssh ceph.pub key to other intended mon hosts:

```
root@kolla-1:~# ssh-copy-id -f -i /etc/ceph/ceph.pub root@kolla-2
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/etc/ceph/ceph.pub"
root@kolla-2's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'root@kolla-2'"
and check to make sure that only the key(s) you wanted were added.

root@kolla-1:~# ssh-copy-id -f -i /etc/ceph/ceph.pub root@kolla-3
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/etc/ceph/ceph.pub"
root@kolla-3's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'root@kolla-3'"
and check to make sure that only the key(s) you wanted were added.
```

### Tell Ceph that the new node is part of the cluster:

```
root@kolla-1:~# ceph orch host add kolla-3 192.168.10.12 --labels _admin
Added host 'kolla-3' with addr '192.168.10.12'

root@kolla-1:~# ceph orch host add kolla-2 192.168.10.155 --labels _admin
Added host 'kolla-2' with addr '192.168.10.155'

root@kolla-1:~# ceph -s
  cluster:
    id:     7171f0d9-3e14-11f0-8055-fa163e2353fb
    health: HEALTH_WARN
            1 stray daemon(s) not managed by cephadm
            OSD count 0 < osd_pool_default_size 3
 
  services:
    mon: 1 daemons, quorum kolla-1 (age 2m)
    mgr: kolla-1.ialwwt(active, since 52m)
    osd: 0 osds: 0 up, 0 in
 
  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:     
 
  progress:
    Updating ceph-exporter deployment (+1 -> 2) (0s)
      [............................]
```

The progress bar increments from `(+1 -> 2)` to `(+1 -> 3)`  
One can also check the ps output on these nodes:
```
root@kolla-1:~# ceph orch ps kolla-3
NAME                   HOST     PORTS             STATUS         REFRESHED  AGE  MEM USE  MEM LIM  VERSION  IMAGE ID      CONTAINER ID  
ceph-exporter.kolla-3  kolla-3                    running (78s)    15s ago  78s    6632k        -  19.2.2   4892a7ef541b  347669a31f3b  
crash.kolla-3          kolla-3                    running (74s)    15s ago  74s    10.1M        -  19.2.2   4892a7ef541b  56511cd86ab4  
mgr.kolla-3.aduswk     kolla-3  *:8443,9283,8765  running (67s)    15s ago  67s     472M        -  19.2.2   4892a7ef541b  1a79ce1100aa  
mon.kolla-3            kolla-3                    running (62s)    15s ago  63s    29.5M    2048M  19.2.2   4892a7ef541b  bb649fe9ebb4  
node-exporter.kolla-3  kolla-3  *:9100            running (71s)    15s ago  71s    7052k        -  1.7.0    72c9c2088986  5457db478629


root@kolla-1:~# ceph orch ps kolla-2
NAME                   HOST     PORTS   STATUS         REFRESHED  AGE  MEM USE  MEM LIM  VERSION  IMAGE ID      CONTAINER ID  
ceph-exporter.kolla-2  kolla-2          running (37s)    18s ago  37s    5835k        -  19.2.2   4892a7ef541b  90134b3b78ed  
crash.kolla-2          kolla-2          running (33s)    18s ago  33s    10.1M        -  19.2.2   4892a7ef541b  1d52028a08c4  
mon.kolla-2            kolla-2          running (25s)    18s ago  25s    27.4M    2048M  19.2.2   4892a7ef541b  8dee61cac5ea  
node-exporter.kolla-2  kolla-2  *:9100  running (30s)    18s ago  30s    2939k        -  1.7.0    72c9c2088986  4abd1a5d78d8
```

Add specific OSD disks from intended OSD nodes to ceph cluster:

```
root@kolla-1:~# ceph orch daemon add osd kolla-2:/dev/vdd
Created osd(s) 2 on host 'kolla-2'

root@kolla-1:~# ceph orch daemon add osd kolla-2:/dev/vde
Created osd(s) 0 on host 'kolla-2'

root@kolla-1:~# ceph orch daemon add osd kolla-2:/dev/vdf
Created osd(s) 1 on host 'kolla-2'

root@kolla-1:~# ceph osd stat
3 osds: 3 up (since 40s), 3 in (since 113s); epoch: e21

root@kolla-1:~# ceph osd tree
ID  CLASS  WEIGHT   TYPE NAME         STATUS  REWEIGHT  PRI-AFF
-1         0.02939  root default                               
-3         0.02939      host kolla-2                           
 0    hdd  0.00980          osd.0         up   1.00000  1.00000
 1    hdd  0.00980          osd.1         up   1.00000  1.00000
 2    hdd  0.00980          osd.2         up   1.00000  1.00000
```

You can also add multiple osd disks in a single command:

```
root@kolla-1:~# ceph orch daemon add osd kolla-3:/dev/vdd,/dev/vde,/dev/vdf                      
Created osd(s) 3,4,5 on host 'kolla-3'


root@kolla-1:~# ceph osd tree
ID  CLASS  WEIGHT   TYPE NAME         STATUS  REWEIGHT  PRI-AFF
-1         0.05878  root default                               
-3         0.02939      host kolla-2                           
 0    hdd  0.00980          osd.0         up   1.00000  1.00000
 1    hdd  0.00980          osd.1         up   1.00000  1.00000
 2    hdd  0.00980          osd.2         up   1.00000  1.00000
-5         0.02939      host kolla-3                           
 3    hdd  0.00980          osd.3         up   1.00000  1.00000
 4    hdd  0.00980          osd.4         up   1.00000  1.00000
 5    hdd  0.00980          osd.5         up   1.00000  1.00000
```

### Create respective ceph pools for glance, cinder and nova
<!-- ```
ceph osd pool create volumes 128
ceph osd pool create backups 128
ceph osd pool create images 128
ceph osd pool create vms 128
``` -->

root@kolla-1:~# ceph osd pool create images 64 64 replicated
pool 'images' created
root@kolla-1:~# ceph osd pool create volumes 64 64 replicated
pool 'volumes' created
root@kolla-1:~# ceph osd pool create vms 64 64 replicated
pool 'vms' created
root@kolla-1:~# ceph osd pool create backups 64 64 replicated
pool 'backups' created

### Initialize the pools
```
root@kolla-1:~# rbd pool init images
root@kolla-1:~# rbd pool init volumes
root@kolla-1:~# rbd pool init backups
root@kolla-1:~# rbd pool init vms
```

The 128 is the pg_num value, it's very important to choose a good value according to your cluster size.

After you create the pools, you must set the application metadata on the pool.

```
root@kolla-1:~# ceph osd pool application enable volumes cinder --yes-i-really-mean-it 
enabled application 'cinder' on pool 'volumes'

root@kolla-1:~# ceph osd pool application enable backups cinder --yes-i-really-mean-it
enabled application 'cinder' on pool 'backups'

root@kolla-1:~# ceph osd pool application enable images glance --yes-i-really-mean-it
enabled application 'glance' on pool 'images'

root@kolla-1:~# ceph osd pool application enable vms nova --yes-i-really-mean-it
enabled application 'nova' on pool 'vms'
```

### Confirm the application metadata has been enabled on respective pools
```
root@kolla-1:~# for i in vms images backups volumes;do ceph osd pool application get $i;done
{
    "nova": {},
    "rbd": {}
}
{
    "glance": {},
    "rbd": {}
}
{
    "cinder": {},
    "rbd": {}
}
{
    "cinder": {},
    "rbd": {}
}
```

Then, create the Ceph users for the respective servcies w.r.t `globals.yaml`  
[From the mon host]
<!-- ```
ceph auth create client.cinder \
        mon 'allow r' \
        osd 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=backups'
ceph auth create client.glance \
        mon 'allow r' \
        osd 'allow class-read object_prefix rbd_children, allow rwx pool=images'
ceph auth create client.nova \
        mon 'allow r' \
        osd 'allow class-read object_prefix rbd_children, allow rwx pool=vms'
``` -->
```
root@kolla-1:~# ceph auth get-or-create client.glance \
                mon 'profile rbd' \
                osd 'profile rbd pool=images' \
                -o /etc/ceph/ceph.client.glance.keyring

root@kolla-1:~# ceph auth ls | grep -A3 glance
client.glance
        key: AQBLBztou7+bGxAAKn0NHtLdRiDiTaR24/2KGg==
        caps: [mon] profile rbd
        caps: [osd] profile rbd pool=images

root@kolla-1:~# ceph auth get-or-create client.cinder \
                mon 'profile rbd' \
                osd 'profile rbd pool=volumes' \
                -o /etc/ceph/ceph.client.cinder.keyring

root@kolla-1:~# ceph auth ls | grep -A3 cinder
client.cinder
        key: AQAhCDtokaIPJBAA2B8rx/LjW08hVXP/NVIq2g==
        caps: [mon] profile rbd
        caps: [osd] profile rbd pool=volumes

root@kolla-1:~# ceph auth get-or-create client.cinder-backup \
                mon 'profile rbd' 
                osd 'profile rbd pool=backups' 
                -o /etc/ceph/ceph.client.cinder-backup.keyring

root@kolla-1:~# ceph auth ls | grep -A3 cinder-backup
client.cinder-backup
        key: AQAVCTtoOggoJBAA9NeZKL9dVg09YE1k5bUVrA==
        caps: [mon] profile rbd
        caps: [osd] profile rbd pool=backups

root@kolla-1:~# ceph auth get-or-create client.nova \
                mon 'profile rbd' \
                osd 'profile rbd pool=vms' \
                -o /etc/ceph/ceph.client.nova.keyring

root@kolla-1:~# ceph auth ls | grep -A3 nova
client.nova
        key: AQDACDto505gKhAAxveaU51I05bn8uKUjZ60hA==
        caps: [mon] profile rbd
        caps: [osd] profile rbd pool=vms
```

Finally, get the keyrings for each user and copy them to the `/etc/kolla/config/<service>` directories.
```
root@kolla-1:~# mkdir -p /etc/kolla/config/cinder/cinder-volume
root@kolla-1:~# ceph auth get-key client.cinder > /etc/kolla/config/cinder/cinder-volume/ceph.client.cinder.keyring

root@kolla-1:~# mkdir -p /etc/kolla/config/cinder/cinder-backup
root@kolla-1:~# ceph auth get-key client.cinder-backup > /etc/kolla/config/cinder/cinder-backup/ceph.client.cinder-backup.keyring

root@kolla-1:~# mkdir -p /etc/kolla/config/glance/
root@kolla-1:~# ceph auth get-key client.glance > /etc/kolla/config/glance/ceph.client.glance.keyring

root@kolla-1:~# mkdir -p /etc/kolla/config/nova/
root@kolla-1:~# ceph auth get-key client.nova > /etc/kolla/config/nova/ceph.client.nova.keyring
```

### Modify the `globals.yaml` accordingly
```
########################
# Glance - Image Options
########################
# Configure image backend.
glance_backend_ceph: "yes"
glance_backend_file: "no"
...
################################
# Cinder - Block Storage Options
################################
# Enable / disable Cinder backends
cinder_backend_ceph: "yes"
....
cinder_backup_driver: "ceph"
...
########################
# Nova - Compute Options
########################
nova_backend_ceph: "yes"

# Glance
ceph_glance_user: "glance"
ceph_glance_keyring: "client.{{ ceph_glance_user }}.keyring"
ceph_glance_pool_name: "images"
# Cinder
ceph_cinder_user: "cinder"
ceph_cinder_keyring: "client.{{ ceph_cinder_user }}.keyring"
ceph_cinder_pool_name: "volumes"
# Cinder-Backup
ceph_cinder_backup_user: "cinder-backup"
ceph_cinder_backup_keyring: "client.{{ ceph_cinder_backup_user }}.keyring"
ceph_cinder_backup_pool_name: "backups"
# Nova
ceph_nova_keyring: "{{ ceph_cinder_keyring }}"
ceph_nova_user: "{{ ceph_cinder_user }}"
ceph_nova_pool_name: "vms"
```

### Set ceph credentials:
```
root@kolla-1:~# ceph auth caps client.cinder-backup mon 'allow r' osd 'allow class-read object_prefix rbd_data, allow rwx pool=cinder-backup'
[client.cinder-backup]
        key = AQAVCTtoOggoJBAA9NeZKL9dVg09YE1k5bUVrA==
        caps mon = "allow r"
        caps osd = "allow class-read object_prefix rbd_data, allow rwx pool=cinder-backup"
updated caps for client.cinder-backup
```
