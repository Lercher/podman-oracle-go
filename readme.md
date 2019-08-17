# podman-oracle-go

My adventures creating a development environment
for Oracle's database and using it with go on an
OpenSUSE Linux.

Podman is a replacement for Docker. Its adavantage is
mainly that it doesn't require root rights for
running containers.

## Bringing an Oracle Instance Online Using Podman

1. First step is to get an account on the [Docker Hub](https://hub.docker.com/)

Then you can pull the slim image, can't you?

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



lercher@linux-pm81:~>
````

No, it's personalized:

1. Search for "Oracle Database Enterprise Edition" and then navigate to [Oracle Database Enterprise Edition](https://hub.docker.com/_/oracle-database-enterprise-edition?tab=description) on the hub.
1. You need to "Proceed to checkout" and then verify that you are licensed
1. agree the conditions

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

Well, no. Apparently the image needs root rights. Let's try again:

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



lercher@linux-pm81:~>
````

Ah, yes. So:

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

... download 2.4GB again ...

## Resources

* [Nutzung von Oracle Datenbanken in Docker Containern](https://apex.oracle.com/pls/apex/germancommunities/dbacommunity/tipp/6241/index.html) by Ralf Durben (in German)
* [Docker Hub](https://hub.docker.com/)
