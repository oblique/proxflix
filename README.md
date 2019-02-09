## About

ProxFlix is yet another smart DNS solution to bypass geo-blocking.

## Dependencies

* Docker
* systemd
* BASH v4

## Install from DockerHub

```bash
docker pull oblique/proxflix
	docker run -v /usr/local/bin:/install oblique/proxflix instl
```

## Install from GitHub

```bash
git clone https://github.com/oblique/proxflix
cd proxflix
docker build -t oblique/proxflix .
ln -snf $PWD/proxflix /usr/local/bin/proxflix
```

## Usage

ProxFlix needs to be installed on a server to the region you are interested.
After you start it, change the DNS of your TV to the IP of your server.

### Start ProxFlix and enable it on boot

```bash
proxflix start
proxflix enable
```

### Check if it's running

```bash
proxflix status
```

### Allow an IP to use your smart DNS

```bash
proxflix add-ip 1.2.3.4
```

### Remove an IP

```bash
proxflix rm-ip 1.2.3.4
```

### List all allowed IPs

```bash
proxflix list-ips
```

### Configuration

If you want to use OpenDNS servers instead Google DNS then do:

```bash
proxflix config-set dns '208.67.222.222,208.67.220.220'
proxflix restart
```

ProxFlix by default is using iptables to allow ports `443`, `80`, `53`
only for the IPs you want. If you prefer to manage this with your own
firewall rules, then you can disable this feature with:

```bash
proxflix config-set iptables false
proxflix restart
```

ProxFlix detects if you have a global IPv6 and it creates IPv6 NAT. This
feature adds an iptables rule even if `iptables` config options is `false`.
To disable this feature do:

```bash
proxflix config-set ipv6nat false
proxflix restart
```

## License
MIT
