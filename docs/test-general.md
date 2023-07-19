# Tests: General Operation Results

## Test Setup

Test files were created on `nfs-server`, then on `nfs-client`, the following two commands were run:

    ubuntu@nfs-client:~$ fsreadall -n 4 /shows/test
    info: files: 100, bytes: 1.6 GB
    info: files: 200, bytes: 3.1 GB
    info: files: 300, bytes: 4.5 GB
    info: files: 400, bytes: 6.1 GB
    info: files: 500, bytes: 7.5 GB
    info: files: 600, bytes: 9.0 GB
    info: files: 700, bytes: 10 GB
    info: files: 800, bytes: 12 GB
    read 801 files (12 GB) in 19.5 minutes at 9.72 MB/s

    ubuntu@nfs-client:~$ fsreadall -n 4 /shows/test
    info: files: 100, bytes: 1.6 GB
    info: files: 200, bytes: 3.1 GB
    info: files: 300, bytes: 4.5 GB
    info: files: 400, bytes: 6.1 GB
    info: files: 500, bytes: 7.5 GB
    info: files: 600, bytes: 9.0 GB
    info: files: 700, bytes: 10 GB
    info: files: 800, bytes: 12 GB
    read 801 files (12 GB) in 3.4 minutes at 55.08 MB/s

The second run completed in much less time as the data was all coming from the local cache server (as would be expected).

The graphana graphs below confirm what is expected.


|                       Run 1                       |                     Run 2                          |
|:-------------------------------------------------:|:--------------------------------------------------:|
| ![](/docs/screenshots/run01-nfs-client.png)       | ![](/docs/screenshots/run02-nfs-client.png)        |
| ![](/docs/screenshots/run01-nfs-cache-egress.png) | ![](/docs/screenshots/run02-nfs-cache-egress.png)  |
| ![](/docs/screenshots/run01-nfs-cache-ingress.png)| ![](/docs/screenshots/run02-nfs-cache-ingress.png) |
| ![](/docs/screenshots/run01-nfs-server.png)       | ![](/docs/screenshots/run02-nfs-server.png)        |


