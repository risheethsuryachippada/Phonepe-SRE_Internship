# 1. Create Root CA (Done once)
\
https://gist.github.com/fntlnz/cf14feb5a46b2eda428e000157447309


## Create Root Key

```
cd /etc/nginx
```

**Attention:** this is the key used to sign the certificate requests, anyone holding this can sign certificates on your behalf. So keep it in a safe place!

```bash
openssl genrsa -des3 -out rootCA.key 4096
```

If you want a non password protected key just remove the `-des3` option


## Create and self sign the Root Certificate

```bash
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt
```

Here we used our root key to create the root certificate that needs to be distributed in all the computers that have to trust us.


# Create a certificate (Done for each server)

This procedure needs to be followed for each server/appliance that needs a trusted certificate from our CA

## Create the certificate key

```
openssl genrsa -out nginx.mesos.com.key 2048
```

## Create the signing  (csr)

The certificate signing request is where you specify the details for the certificate you want to generate.
This request will be processed by the owner of the Root key (you in this case since you create it earlier) to generate the certificate.

**Important:** Please mind that while creating the signign request is important to specify the `Common Name` providing the IP address or domain name for the service, otherwise the certificate cannot be verified.


### Method A (Interactive)

If you generate the csr in this way, openssl will ask you questions about the certificate to generate like the organization details and the `Common Name` (CN) that is the web address you are creating the certificate for, e.g `nginx.mesos.com`.

```
openssl req -new -key nginx.mesos.com.key -out nginx.mesos.com.csr
```


## Verify the csr's content

```
openssl req -in nginx.mesos.com.csr -noout -text
```

## Generate the certificate using the `nginx.mesos` csr and key along with the CA Root key

```
openssl x509 -req -in nginx.mesos.com.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out nginx.mesos.com.crt -days 500 -sha256
```

## Verify the certificate's content

```
openssl x509 -in mydomain.com.crt -text -noout
```

# 2. Install nginx

```
sudo apt-get update
sudo apt-get install nginx
```

# 3. Enable SSL on nginx

https://www.youtube.com/watch?v=1semerKfKRc&list=TLPQMDkwNjIwMjFMpdWRE_hMuQ&index=2

edit the default file at /etc/nginx/sites-available/default

```
nano /etc/nginx/sites-available/default
```

uncomment the following lines:

```
listen 443 ssl default_server;
listen [::]:443 ssl default_server;
```

add the following lines:

```
ssl_certificate /etc/nginx/nginx.mesos.com.crt;
ssl_certificate_key /etc/nginx/nginx.mesos.com.key;
```

verify it by going to https://nginx.mesos.com or https://\<nginx-bridge-ip\>:80 you should be able to see the nginx default page.

# 4. Configure reverse-proxy

https://www.scaleway.com/en/docs/how-to-configure-nginx-reverse-proxy/

https://www.nginx.com/blog/nginx-ssl/


[What is reverse proxy?](https://kinsta.com/blog/reverse-proxy/)

[Why traefik and nginx might be used together](https://stackoverflow.com/questions/50778187/use-nginx-on-route-and-traefik-for-subdomain)

Disable the default virtual host, that is pre-configured when Nginx is istalled via Ubuntu’s packet manager apt:

```
unlink /etc/nginx/sites-enabled/default
```

Enter the directory /etc/nginx/sites-available and create a reverse proxy configuration file.

```
cd /etc/nginx/sites-available
nano reverse-proxy.conf
```

```
server {
        listen 80;
        listen [::]:80;
	listen 443 ssl;

	server_name nginx.mesos.com;
        access_log /var/log/nginx/reverse-access.log;
        error_log /var/log/nginx/reverse-error.log;
	ssl_certificate /etc/nginx/nginx.mesos.com.crt;
	ssl_certificate_key /etc/nginx/nginx.mesos.com.key;

        location / {
                    proxy_pass http://helloworld.traefik.phonepe.lc1;
  }
}
```

> Note: The proxy_pass is the label provided in application.

Copy the configuration from /etc/nginx/sites-available to /etc/nginx/sites-enabled. It is recommended to use a symbolic link.

```
ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf
```

Test the Nginx configuration file

```
nginx -t
```

restart nginx

```
service nginx restart
```