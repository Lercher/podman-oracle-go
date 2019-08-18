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

## Resources

* [Nutzung von Oracle Datenbanken in Docker Containern](https://apex.oracle.com/pls/apex/germancommunities/dbacommunity/tipp/6241/index.html) by Ralf Durben (in German)
* [Docker Hub](https://hub.docker.com/)
* [Instructions (copy)](ora.md) on the DBMS image's use.
