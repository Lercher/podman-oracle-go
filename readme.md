# podman-oracle-go

My adventures creating a development environment
for Oracle's database and using it with go on an
OpenSUSE Linux.

Podman is a replacement for Docker. Its adavantage is
mainly that it doesn't require root rights for
running containers.

## Pulling an Oracle DBMS Using Podman

### TL;DR

* Get a docker hub account and login
* Get an Oracle License for Development
* Find and checkout the image at [Oracle Database Enterprise Edition](https://hub.docker.com/_/oracle-database-enterprise-edition?tab=description)
* `sudo -i` as we need root rights here
* as root login with podman on docker.io: `podman login docker.io`
* and then `podman pull store/oracle/database-enterprise:12.2.0.1-slim` as root, finally.

### In Detail

The first step is to get an account on the [Docker Hub](https://hub.docker.com/). Then we can pull the slim image, can't we?

````sh
lercher@linux-pm81:~> podman login docker.io
Username: lercher
Password:
Login Succeeded!
lercher@linux-pm81:~>podman pull store/oracle/database-enterprise:12.2.0.1-slim
Trying to pull docker.io/store/oracle/database-enterprise:12.2.0.1-slim...ERRO[0002] Error pulling image ref //store/oracle/database-enterprise:12.2.0.1-slim: Error initializing source docker://store/oracle/database-enterprise:12.2.0.1-slim: Error reading manifest 12.2.0.1-slim in docker.io/store/oracle/database-enterprise: errors:
denied: requested access to the resource is denied
unauthorized: authentication required

Failed
Error: error pulling image "store/oracle/database-enterprise:12.2.0.1-slim": unable to pull store/oracle/database-enterprise:12.2.0.1-slim: 1 error occurred:
        * Error initializing source docker://store/oracle/database-enterprise:12.2.0.1-slim: Error reading manifest 12.2.0.1-slim in docker.io/store/oracle/database-enterprise: errors:
denied: requested access to the resource is denied
unauthorized: authentication required
````

No. It's personalized. So:

1. Search for "Oracle Database Enterprise Edition" and then navigate to [Oracle Database Enterprise Edition](https://hub.docker.com/_/oracle-database-enterprise-edition?tab=description) on the hub.
1. You need to "Proceed to checkout" and then verify that you are licensed
1. Agree on the terms and conditions
1. The hub displays [instructions (copy)](ora.md), have a look.

Now we can pull the slim image, can't we?

````sh
lercher@linux-pm81:~> podman pull store/oracle/database-enterprise:12.2.0.1-slim
Trying to pull docker.io/store/oracle/database-enterprise:12.2.0.1-slim...Getting image source signatures
Copying blob fc60a1a28025 done
Copying blob 0c32e4ed872e done
Copying blob 9d3556e8e792 done
Copying blob 4ce27fe12c04 done
Copying blob be0a1f1e8dfd done
Copying config 27c9559d36 done
Writing manifest to image destination
Storing signatures
ERRO[1128] Error pulling image ref //store/oracle/database-enterprise:12.2.0.1-slim: Error committing the finished image: error adding layer with blob "sha256:4ce27fe12c04b284c06c42a94856b1941a9a3d1e87f6000e2426489522301309": Error processing tar file(exit status 1): there might not be enough IDs available in the namespace (requested 0:22 for /run/utmp): lchown /run/utmp: invalid argument
Failed
Error: error pulling image "store/oracle/database-enterprise:12.2.0.1-slim": unable to pull store/oracle/database-enterprise:12.2.0.1-slim: 1 error occurred:
        * Error committing the finished image: error adding layer with blob "sha256:4ce27fe12c04b284c06c42a94856b1941a9a3d1e87f6000e2426489522301309": Error processing tar file(exit status 1): there might not be enough IDs available in the namespace (requested 0:22 for /run/utmp): lchown /run/utmp: invalid argument


lercher@linux-pm81:~>
````

Well, no again. Apparently the image needs root rights. Let's try again:

````sh
lercher@linux-pm81:~> sudo podman pull store/oracle/database-enterprise:12.2.0.1-slim
[sudo] Passwort für root:
Trying to pull docker.io/store/oracle/database-enterprise:12.2.0.1-slim...ERRO[0001] Error pulling image ref //store/oracle/database-enterprise:12.2.0.1-slim: Error initializing source docker://store/oracle/database-enterprise:12.2.0.1-slim: Error reading manifest 12.2.0.1-slim in docker.io/store/oracle/database-enterprise: errors:
denied: requested access to the resource is denied
unauthorized: authentication required
Failed
Error: error pulling image "store/oracle/database-enterprise:12.2.0.1-slim": unable to pull store/oracle/database-enterprise:12.2.0.1-slim: 1 error occurred:
        * Error initializing source docker://store/oracle/database-enterprise:12.2.0.1-slim: Error reading manifest 12.2.0.1-slim in docker.io/store/oracle/database-enterprise: errors:
denied: requested access to the resource is denied
unauthorized: authentication required
````

Ah, yes, we are not logged in on docker.io, b/c we are root now. So ...

````sh
lercher@linux-pm81:~> sudo -i
linux-pm81:~ # podman login docker.io
Username: lercher
Password:
Login Succeeded!
linux-pm81:~ # podman pull store/oracle/database-enterprise:12.2.0.1-slim
Trying to pull docker.io/store/oracle/database-enterprise:12.2.0.1-slim...Getting image source signatures
Copying blob 9d3556e8e792 [=>------------------------------------] 6.2MiB / 144.0MiB
Copying blob be0a1f1e8dfd [--------------------------------------] 5.5MiB / 1.3GiB
Copying blob 0c32e4ed872e done
Copying blob fc60a1a28025 done
Copying blob 4ce27fe12c04 [==>-----------------------------------] 6.1MiB / 79.4MiB
...
````

... pull 2.4GB, *again*, as root, but finally:

````sh
linux-pm81:~ # podman pull store/oracle/database-enterprise:12.2.0.1-slim
Trying to pull docker.io/store/oracle/database-enterprise:12.2.0.1-slim...Getting image source signatures
Copying blob 9d3556e8e792 done
Copying blob be0a1f1e8dfd done
Copying blob 0c32e4ed872e done
Copying blob fc60a1a28025 done
Copying blob 4ce27fe12c04 done
Copying config 27c9559d36 done
Writing manifest to image destination
Storing signatures
27c9559d36ec85fdaa42111ebc55076a63e842ddbe67e0849cdc59b4f6a6f7a1
linux-pm81:~ # podman images
REPOSITORY                                   TAG             IMAGE ID       CREATED         SIZE
...
docker.io/store/oracle/database-enterprise   12.2.0.1-slim   27c9559d36ec   24 months ago   2.1 GB
...
linux-pm81:~ #
````

That looks like **success**. Probably we need to *run* the container as root as well:

````sh
linux-pm81:~ # exit
logout
lercher@linux-pm81:~> podman images
REPOSITORY   TAG   IMAGE ID   CREATED   SIZE
lercher@linux-pm81:~>
````

That's right, we don't have any images as unprivileged user.

### Full Story (August 2019)

````sh
lercher@linux-home:~> sudo podman version
[sudo] password for root:
Version:            1.4.4
RemoteAPI Version:  1
Go Version:         go1.12.6
OS/Arch:            linux/amd64
lercher@linux-home:~> sudo -i
linux-home:~ # podman login docker.io
Username: lercher
Password:
Login Succeeded!
linux-home:~ # podman pull store/oracle/database-enterprise:12.2.0.1-slim
Trying to pull docker.io/store/oracle/database-enterprise:12.2.0.1-slim...Getting image source signatures
Copying blob fc60a1a28025 done
Copying blob 4ce27fe12c04 done
Copying blob be0a1f1e8dfd done
Copying blob 9d3556e8e792 done
Copying blob 0c32e4ed872e done
Copying config 27c9559d36 done
Writing manifest to image destination
Storing signatures
27c9559d36ec85fdaa42111ebc55076a63e842ddbe67e0849cdc59b4f6a6f7a1
linux-home:~ #
````

## Preparing the DBMS Server

Prepare an environment file [db.env](db.env) that we intend to pass
to podman as the container environment,
with e.g. this content:

````env
DB_SID=ORA1
DB_PDB=PDB1
DB_MEMORY=3GB
DB_PASSWD=welcome1
DB_DOMAIN=fritz.box
DB_BUNDLE=basic
````

i.e.

````sh
linux-home:~ # mkdir ora
linux-home:~ # cd ora
linux-home:~/ora # cat >db.env
DB_SID=ORA1
DB_PDB=PDB1
DB_MEMORY=3GB
DB_PASSWD=welcome1
DB_DOMAIN=fritz.box
DB_BUNDLE=basic
linux-home:~/ora # ll
total 4
-rw-r--r-- 1 root root 93 Aug 18 15:40 db.env
linux-home:~/ora #
````

As *root* we prepare a data directory for the DBMS to put its database files to:

````sh
linux-home:~/ora # mkdir /oracledata
linux-home:~/ora # chmod go+rw /oracledata
````

## Running the DBMS Server

Now that we have all prerequisits, we start the container as a
background process as *root* with this command:

````sh
cd ~/ora
podman run -d -it --name oradb --env-file db.env -p 1521:1521 -v /oracledata:/ORCL store/oracle/database-enterprise:12.2.0.1-slim
````

Where

* -d run as daemon
* -it run the container interactively allocating a tty
* --name name the container `oradb`
* --env-file uses the configuration from [db.env](db.env)
* -p publish the container's port `1521` localy on the same port
* -v map the local data directory `/oracledata` into the container

In the shell for example:

````sh
linux-home:~ # cd ~/ora
linux-home:~/ora # podman run -d -it --name oradb --env-file db.env -p 1521:1521 -v /oracledata:/ORCL store/oracle/database-enterprise:12.2.0.1-slim
Error: error creating container storage: the container name "oradb" is already in use by "e7f9bf09bc91472b2c5082a6ab68dd00c157a5d9134e6fedf92577e37f9b5955". You have to remove that container to be able to reuse that name.: that name is already in use
linux-home:~/ora # podman rm oradb
e7f9bf09bc91472b2c5082a6ab68dd00c157a5d9134e6fedf92577e37f9b5955
linux-home:~/ora # podman run -d -it --name oradb --env-file db.env -p 1521:1521 -v /oracledata:/ORCL store/oracle/database-enterprise:12.2.0.1-slim
4fec17a32fab846c9c8918e49234577829244956781c309f5b5fef735216ab45
linux-home:~/ora # podman ps
CONTAINER ID  IMAGE                                                     COMMAND               CREATED        STATUS            PORTS                   NAMES
4fec17a32fab  docker.io/store/oracle/database-enterprise:12.2.0.1-slim  /bin/sh -c /bin/b...  8 seconds ago  Up 8 seconds ago  0.0.0.0:1521->1521/tcp  oradb
````

````sh
linux-home:~/ora # ls -R /oracledata/
...
linux-home:~/ora # du -h /oracledata/
...
````

as it is quite long, see [oracledata.txt](oracledata.txt) for the output of `ls -R /oracledata/`
and `du -h /oracledata/`.

## Stoping and Restarting the DBMS

This command stops the container after some time,
if it shuts down the DBMS properly
needs to be examined, so **handle with care**:

````sh
linux-home:~/ora # podman stop oradb
4fec17a32fab846c9c8918e49234577829244956781c309f5b5fef735216ab45
linux-home:~/ora # podman ps
CONTAINER ID  IMAGE  COMMAND  CREATED  STATUS  PORTS  NAMES
linux-home:~/ora #
````

To restart the container

````sh
linux-home:~/ora # podman start oradb
oradb
linux-home:~/ora # podman ps
CONTAINER ID  IMAGE                                                     COMMAND               CREATED        STATUS            PORTS                   NAMES
4fec17a32fab  docker.io/store/oracle/database-enterprise:12.2.0.1-slim  /bin/sh -c /bin/b...  9 minutes ago  Up 4 seconds ago  0.0.0.0:1521->1521/tcp  oradb
linux-home:~/ora # podman exec -it oradb bash -c "source /home/oracle/.bashrc; sqlplus system/welcome1"

SQL*Plus: Release 12.2.0.1.0 Production on Sun Aug 18 14:25:45 2019

Copyright (c) 1982, 2016, Oracle.  All rights reserved.

Last Successful login time: Sun Aug 18 2019 14:19:24 +00:00

Connected to:
Oracle Database 12c Enterprise Edition Release 12.2.0.1.0 - 64bit Production

SQL> select 1 from dual;

         1
----------
         1

SQL> exit
Disconnected from Oracle Database 12c Enterprise Edition Release 12.2.0.1.0 - 64bit Production
linux-home:~/ora #
````

## Connecting with the DBMS Server

We start the provided sqlplus in the runing container named `oradb` logging in
as `system` with the password `welcome1` that we specified in the [db.env](db.env) file:

````sh
podman exec -it oradb bash -c "source /home/oracle/.bashrc; sqlplus system/welcome1"
````

in the shell:

````sh
linux-home:~/ora # podman exec -it oradb bash -c "source /home/oracle/.bashrc; sqlplus system/welcome1"

SQL*Plus: Release 12.2.0.1.0 Production on Sun Aug 18 14:19:24 2019

Copyright (c) 1982, 2016, Oracle.  All rights reserved.

Last Successful login time: Thu Jan 26 2017 16:02:57 +00:00

Connected to:
Oracle Database 12c Enterprise Edition Release 12.2.0.1.0 - 64bit Production

SQL> select 1, 2 from dual
  2  ;

         1          2
---------- ----------
         1          2

SQL> exit
Disconnected from Oracle Database 12c Enterprise Edition Release 12.2.0.1.0 - 64bit Production
linux-home:~/ora #
````

## Building an Image With the Instaclient light and the SDK

This is our main topic, We want to build an image like that
with the current version (19.3 in August 2019):

````txt
FROM something:small
apk --no-cache add libaio glibc-2.29-r0.apk
Copy/unzip instantclient-basic-linux-12.1.0.2.0.zip and sdk
mv instantclient_12_1/* /usr/lib/
ENV LD_LIBRARY_PATH /usr/lib
````

See also
[Oracle's instructions](https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html#ic_x64_inst)
on installing the Linux client.

## Resources

* [Nutzung von Oracle Datenbanken in Docker Containern](https://apex.oracle.com/pls/apex/germancommunities/dbacommunity/tipp/6241/index.html) by Ralf Durben (in German)
* [Docker Hub](https://hub.docker.com/)
* [Instructions (copy)](ora.md) on the DBMS image's use.
* [Oracle Instant Client Downloads](https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html)
  for Linux 64bit. We need the "Basic Light Package" and the "SDK Package" as zip files.
* [Oracle's client installation instructions](https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html#ic_x64_inst)
