# Tests: Behaviour Under Failure

The system was tested under three different failure scenarios:

* dropping packes on the nfs-server from the nfs-cache server
* shutting down the vpn server
* shutting down the vpn client

In all scenarios, the system recovered from failure once the system was restored.

## Dropping Packets

To create the failure, `iptables` was used to create a rule to drop all packets from the nfs-cache
machine destined for port `2049` on the server:

    iptables -A INPUT -s 192.168.101.70 -p tcp --dport 2049 -j DROP

The outage was left in place for about 30minutes.

Normal operation was restored with:

    iptables -D INPUT -s 192.168.101.70 -p tcp --dport 2049 -j DROP

The kernel log on the `nfs-cache` server reported the server not responding, then recovered:

    Jun 28 05:40:15 nfs-cache kernel: [ 7548.460032] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 05:40:15 nfs-cache kernel: [ 7548.460045] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 05:40:15 nfs-cache kernel: [ 7548.460103] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 05:41:14 nfs-cache kernel: [ 7607.852096] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:41:14 nfs-cache kernel: [ 7607.852111] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:41:45 nfs-cache kernel: [ 7638.572197] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 05:43:15 nfs-cache kernel: [ 7728.684304] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 05:44:15 nfs-cache kernel: [ 7788.076306] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:44:20 nfs-cache kernel: [ 7793.196350] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:44:45 nfs-cache kernel: [ 7818.796402] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 05:46:15 nfs-cache kernel: [ 7908.908479] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 05:47:15 nfs-cache kernel: [ 7968.300473] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:47:25 nfs-cache kernel: [ 7978.540560] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:47:46 nfs-cache kernel: [ 7999.020729] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 05:50:15 nfs-cache kernel: [ 8148.525082] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:50:20 nfs-cache kernel: [ 8153.644799] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:50:30 nfs-cache kernel: [ 8163.884775] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:53:15 nfs-cache kernel: [ 8328.748884] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:53:26 nfs-cache kernel: [ 8338.988947] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:53:36 nfs-cache kernel: [ 8349.228951] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:56:16 nfs-cache kernel: [ 8508.973413] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:56:21 nfs-cache kernel: [ 8514.093134] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:56:31 nfs-cache kernel: [ 8524.333071] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:56:41 nfs-cache kernel: [ 8534.573101] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:59:16 nfs-cache kernel: [ 8689.197264] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:59:26 nfs-cache kernel: [ 8699.437272] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:59:36 nfs-cache kernel: [ 8709.677262] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 05:59:46 nfs-cache kernel: [ 8719.917479] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:02:16 nfs-cache kernel: [ 8869.421785] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:02:21 nfs-cache kernel: [ 8874.541541] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:02:31 nfs-cache kernel: [ 8884.781459] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:02:42 nfs-cache kernel: [ 8895.021495] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:02:52 nfs-cache kernel: [ 8905.261531] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:05:16 nfs-cache kernel: [ 9049.645651] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:05:26 nfs-cache kernel: [ 9059.885632] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:05:37 nfs-cache kernel: [ 9070.125652] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:05:47 nfs-cache kernel: [ 9080.366096] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:05:57 nfs-cache kernel: [ 9090.605700] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:08:16 nfs-cache kernel: [ 9229.869848] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:08:22 nfs-cache kernel: [ 9234.989904] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:08:32 nfs-cache kernel: [ 9245.229886] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:08:42 nfs-cache kernel: [ 9255.469852] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:08:52 nfs-cache kernel: [ 9265.709909] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:09:02 nfs-cache kernel: [ 9275.949928] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:11:17 nfs-cache kernel: [ 9410.094040] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:11:27 nfs-cache kernel: [ 9420.334053] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:11:37 nfs-cache kernel: [ 9430.574106] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:11:47 nfs-cache kernel: [ 9440.814604] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:11:58 nfs-cache kernel: [ 9451.054125] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:12:08 nfs-cache kernel: [ 9461.294108] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:13:25 nfs-cache kernel: [ 9538.285064] nfs: server 192.168.100.70 OK
    Jun 28 06:13:25 nfs-cache kernel: [ 9538.285109] nfs: server 192.168.100.70 OK
    Jun 28 06:13:25 nfs-cache kernel: [ 9538.285160] nfs: server 192.168.100.70 OK
    Jun 28 06:13:25 nfs-cache kernel: [ 9538.285166] nfs: server 192.168.100.70 OK
    Jun 28 06:13:25 nfs-cache kernel: [ 9538.285329] nfs: server 192.168.100.70 OK
    Jun 28 06:13:25 nfs-cache kernel: [ 9538.285336] nfs: server 192.168.100.70 OK
    Jun 28 06:13:25 nfs-cache kernel: [ 9538.285729] nfs: server 192.168.100.70 OK
    Jun 28 06:13:25 nfs-cache kernel: [ 9538.285853] nfs: server 192.168.100.70 OK

The client reported similar behaviour:

    Jun 28 05:40:14 ip-192-168-101-71 kernel: [ 7954.430740] nfs: server 192.168.101.70 not responding, still trying
    Jun 28 05:40:14 ip-192-168-101-71 kernel: [ 7954.430747] nfs: server 192.168.101.70 not responding, still trying
    Jun 28 05:40:14 ip-192-168-101-71 kernel: [ 7954.430749] nfs: server 192.168.101.70 not responding, still trying
    Jun 28 05:40:14 ip-192-168-101-71 kernel: [ 7954.430750] nfs: server 192.168.101.70 not responding, still trying
    Jun 28 05:40:14 ip-192-168-101-71 kernel: [ 7954.430765] nfs: server 192.168.101.70 not responding, still trying
    Jun 28 05:40:26 ip-192-168-101-71 kernel: [ 7966.206767] nfs: server 192.168.101.70 not responding, still trying
    Jun 28 06:14:14 ip-192-168-101-71 kernel: [ 9994.089539] nfs: server 192.168.101.70 OK
    Jun 28 06:14:14 ip-192-168-101-71 kernel: [ 9994.185329] nfs: server 192.168.101.70 OK
    Jun 28 06:14:14 ip-192-168-101-71 kernel: [ 9994.185487] nfs: server 192.168.101.70 OK
    Jun 28 06:14:14 ip-192-168-101-71 kernel: [ 9994.280714] nfs: server 192.168.101.70 OK
    Jun 28 06:14:14 ip-192-168-101-71 kernel: [ 9994.280743] nfs: server 192.168.101.70 OK
    Jun 28 06:14:14 ip-192-168-101-71 kernel: [ 9994.280798] nfs: server 192.168.101.70 OK

The command `fsreadall` was running during the outage. It paused while the system was down, then
carried on and finished successfully:

    ubuntu@nfs-client:~$ fsreadall -n 4 /shows/test/
    info: files: 100, bytes: 2.0 GB
    info: files: 200, bytes: 3.9 GB
    info: files: 300, bytes: 5.9 GB
    info: files: 400, bytes: 7.9 GB
    info: files: 500, bytes: 9.9 GB
    info: files: 600, bytes: 12 GB
    read 604 files (12 GB) in 40.019 minutes at 4.7339 MB/s


## Shutdown VPN Server

The outage was created on the server `vpn-server` with the command:

    systemctl stop wg-quick@wg0

It was repaired wiht:

    systemctl start wg-quick@wg0

The kernel log on the `nfs-cache` server reported the server not responding, then recovered:

    Jun 28 06:21:58 nfs-cache kernel: [10051.118733] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 06:22:11 nfs-cache kernel: [10064.686736] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 06:22:28 nfs-cache kernel: [10081.838844] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:22:49 nfs-cache kernel: [10102.318788] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 06:23:28 nfs-cache kernel: [10141.230903] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 06:24:58 nfs-cache kernel: [10231.342973] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 06:25:29 nfs-cache kernel: [10262.062961] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:25:34 nfs-cache kernel: [10267.183026] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:26:28 nfs-cache kernel: [10321.455105] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 06:26:49 nfs-cache kernel: [10342.083305] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 06:26:49 nfs-cache kernel: [10342.083322] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 06:26:49 nfs-cache kernel: [10342.178622] nfs: server 192.168.100.70 OK
    Jun 28 06:26:49 nfs-cache kernel: [10342.178648] nfs: server 192.168.100.70 OK
    Jun 28 06:26:49 nfs-cache kernel: [10342.178745] nfs: server 192.168.100.70 OK
    Jun 28 06:26:49 nfs-cache kernel: [10342.178751] nfs: server 192.168.100.70 OK
    Jun 28 06:26:49 nfs-cache kernel: [10342.178782] nfs: server 192.168.100.70 OK
    Jun 28 06:26:49 nfs-cache kernel: [10342.178791] nfs: server 192.168.100.70 OK
    Jun 28 06:26:49 nfs-cache kernel: [10342.178818] nfs: server 192.168.100.70 OK
    Jun 28 06:26:49 nfs-cache kernel: [10342.179205] nfs: server 192.168.100.70 OK

The client reported similar behaviour:

    Jun 28 06:21:56 ip-192-168-101-71 kernel: [10456.577485] nfs: server 192.168.101.70 not responding, still trying
    Jun 28 06:21:56 ip-192-168-101-71 kernel: [10456.577492] nfs: server 192.168.101.70 not responding, still trying
    Jun 28 06:21:56 ip-192-168-101-71 kernel: [10456.577499] nfs: server 192.168.101.70 not responding, still trying
    Jun 28 06:21:57 ip-192-168-101-71 kernel: [10457.089482] nfs: server 192.168.101.70 not responding, still trying
    Jun 28 06:21:57 ip-192-168-101-71 kernel: [10457.121453] nfs: server 192.168.101.70 not responding, still trying
    Jun 28 06:22:11 ip-192-168-101-71 kernel: [10471.425471] nfs: server 192.168.101.70 not responding, still trying
    Jun 28 06:27:36 ip-192-168-101-71 kernel: [10796.143235] nfs: server 192.168.101.70 OK
    Jun 28 06:27:36 ip-192-168-101-71 kernel: [10796.143345] nfs: server 192.168.101.70 OK
    Jun 28 06:27:36 ip-192-168-101-71 kernel: [10796.143518] nfs: server 192.168.101.70 OK
    Jun 28 06:27:36 ip-192-168-101-71 kernel: [10796.143529] nfs: server 192.168.101.70 OK
    Jun 28 06:27:36 ip-192-168-101-71 kernel: [10796.143678] nfs: server 192.168.101.70 OK
    Jun 28 06:27:36 ip-192-168-101-71 kernel: [10796.143732] nfs: server 192.168.101.70 OK


### Shutdown VPN Client

The outage was created on the server `vpn-client` with the command:

    systemctl stop wg-quick@wg0

It was repaired wiht:

    systemctl start wg-quick@wg0

The kernel log on the `nfs-cache` server reported the server not responding, then recovered:

    Jun 28 06:31:33 nfs-cache kernel: [10626.607419] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 06:31:33 nfs-cache kernel: [10626.607478] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 06:31:41 nfs-cache kernel: [10634.543406] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 06:31:52 nfs-cache kernel: [10645.039383] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:31:52 nfs-cache kernel: [10645.039402] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:31:52 nfs-cache kernel: [10645.039406] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:31:52 nfs-cache kernel: [10645.039410] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:31:52 nfs-cache kernel: [10645.039413] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:31:52 nfs-cache kernel: [10645.039422] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:31:52 nfs-cache kernel: [10645.039425] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:31:52 nfs-cache kernel: [10645.039429] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:31:52 nfs-cache kernel: [10645.039432] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:31:52 nfs-cache kernel: [10645.039436] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:32:33 nfs-cache kernel: [10685.999453] rpc_check_timeout: 33 callbacks suppressed
    Jun 28 06:32:33 nfs-cache kernel: [10685.999458] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:32:33 nfs-cache kernel: [10685.999474] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:32:33 nfs-cache kernel: [10685.999477] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:32:33 nfs-cache kernel: [10685.999481] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:32:33 nfs-cache kernel: [10685.999484] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:32:33 nfs-cache kernel: [10685.999488] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:32:33 nfs-cache kernel: [10685.999490] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:32:33 nfs-cache kernel: [10685.999494] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:32:33 nfs-cache kernel: [10685.999497] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:32:33 nfs-cache kernel: [10685.999500] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:33:03 nfs-cache kernel: [10716.719551] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 06:34:33 nfs-cache kernel: [10806.831656] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 06:35:33 nfs-cache kernel: [10866.223605] rpc_check_timeout: 193 callbacks suppressed
    Jun 28 06:35:33 nfs-cache kernel: [10866.223610] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:35:38 nfs-cache kernel: [10871.343750] nfs: server 192.168.100.70 not responding, timed out
    Jun 28 06:36:03 nfs-cache kernel: [10896.943720] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 06:37:34 nfs-cache kernel: [10987.055860] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 06:37:37 nfs-cache kernel: [10990.188057] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 06:37:37 nfs-cache kernel: [10990.188072] nfs: server 192.168.100.70 not responding, still trying
    Jun 28 06:37:37 nfs-cache kernel: [10990.281952] nfs: server 192.168.100.70 OK
    Jun 28 06:37:37 nfs-cache kernel: [10990.281975] nfs: server 192.168.100.70 OK
    Jun 28 06:37:37 nfs-cache kernel: [10990.281982] nfs: server 192.168.100.70 OK
    Jun 28 06:37:37 nfs-cache kernel: [10990.281987] nfs: server 192.168.100.70 OK
    Jun 28 06:37:37 nfs-cache kernel: [10990.282010] nfs: server 192.168.100.70 OK
    Jun 28 06:37:37 nfs-cache kernel: [10990.282015] nfs: server 192.168.100.70 OK
    Jun 28 06:37:37 nfs-cache kernel: [10990.282019] nfs: server 192.168.100.70 OK
    Jun 28 06:37:37 nfs-cache kernel: [10990.282062] nfs: server 192.168.100.70 OK
    Jun 28 06:37:37 nfs-cache kernel: [10990.282070] nfs: server 192.168.100.70 OK

The client kernel log reported similar behaviour:

    Jun 28 06:31:32 ip-192-168-101-71 kernel: [11032.578085] nfs: server 192.168.101.70 not responding, still trying
    Jun 28 06:31:32 ip-192-168-101-71 kernel: [11032.578092] nfs: server 192.168.101.70 not responding, still trying
    Jun 28 06:31:32 ip-192-168-101-71 kernel: [11032.578093] nfs: server 192.168.101.70 not responding, still trying
    Jun 28 06:31:32 ip-192-168-101-71 kernel: [11032.578095] nfs: server 192.168.101.70 not responding, still trying
    Jun 28 06:31:32 ip-192-168-101-71 kernel: [11032.578103] nfs: server 192.168.101.70 not responding, still trying
    Jun 28 06:31:41 ip-192-168-101-71 kernel: [11041.282086] nfs: server 192.168.101.70 not responding, still trying
    Jun 28 06:38:11 ip-192-168-101-71 kernel: [11431.015852] nfs: server 192.168.101.70 OK
    Jun 28 06:38:11 ip-192-168-101-71 kernel: [11431.109462] nfs: server 192.168.101.70 OK
    Jun 28 06:38:11 ip-192-168-101-71 kernel: [11431.109487] nfs: server 192.168.101.70 OK
    Jun 28 06:38:11 ip-192-168-101-71 kernel: [11431.109500] nfs: server 192.168.101.70 OK
    Jun 28 06:38:11 ip-192-168-101-71 kernel: [11431.109954] nfs: server 192.168.101.70 OK
    Jun 28 06:38:11 ip-192-168-101-71 kernel: [11431.110026] nfs: server 192.168.101.70 OK

