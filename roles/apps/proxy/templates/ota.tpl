# To add a subdomain
# 1. create a server > location entry
# 2. point the subdomain DNS to this server
# 3. launch > sudo certbot --nginx -d subdomain.opentermsarchive.org
# 4. Copy content of /etc/nginx/sites-available/ota to `OpenTermsArchive/ops/roles/infra/nginx/templates/ota.tpl`

proxy_cache_path /dev/shm/nginx-ota levels=1:2 keys_zone=ota_cache:10m max_size=1g inactive=1m use_temp_path=off;

server {
  server_name contribute.opentermsarchive.org;

  location /health-check {
    add_header Content-Type text/plain always;
    return 200 'contribute.opentermsarchive.org up and running!';
  }

  location / {
    proxy_pass http://51.75.169.235:7023$request_uri;
  }

  listen 443 ssl; # managed by Certbot
  ssl_certificate /etc/letsencrypt/live/contribute.opentermsarchive.org/fullchain.pem; # managed by Certbot
  ssl_certificate_key /etc/letsencrypt/live/contribute.opentermsarchive.org/privkey.pem; # managed by Certbot
  include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

server {
  server_name contribute.preprod.opentermsarchive.org;

  location /health-check {
    add_header Content-Type text/plain always;
    return 200 'contribute.preprod.opentermsarchive.org up and running!';
  }

  location / {
    proxy_pass http://51.75.169.235:7024$request_uri;
  }

  listen 443 ssl; # managed by Certbot
  ssl_certificate /etc/letsencrypt/live/contribute.preprod.opentermsarchive.org/fullchain.pem; # managed by Certbot
  ssl_certificate_key /etc/letsencrypt/live/contribute.preprod.opentermsarchive.org/privkey.pem; # managed by Certbot
  include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

server {
  if ($host = contribute.opentermsarchive.org) {
      return 301 https://$host$request_uri;
  } # managed by Certbot


  server_name contribute.opentermsarchive.org;
  listen 80;
  return 404; # managed by Certbot
}

server {
  if ($host = contribute.preprod.opentermsarchive.org) {
      return 301 https://$host$request_uri;
  } # managed by Certbot


  server_name contribute.preprod.opentermsarchive.org;
  listen 80;
  return 404; # managed by Certbot
}
