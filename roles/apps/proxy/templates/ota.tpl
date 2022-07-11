proxy_cache_path /dev/shm/nginx-ota levels=1:2 keys_zone=ota_cache:10m max_size=1g inactive=1m use_temp_path=off;

{% for cert in certbot_certs %}
  {% for domain in cert.domains %}

server {
  server_name {{ domain }};
  listen 80;

{% if enable_https %}
  return 301 https://$server_name$request_uri;
}

server {
  server_name {{ domain }};
  listen 443 ssl http2;

  ssl_certificate /etc/letsencrypt/live/{{ domain }}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/{{ domain }}/privkey.pem;
  ssl_session_timeout 1d;
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:50m;
{% endif %}

  location /health-check {
    add_header Content-Type text/plain always;
    return 200 '{{ domain }} up and running!';
  }

  location / {
    proxy_pass http://$server_name:{{ports[domain]}}$request_uri;
  }
}

  {% endfor %}
{% endfor %}
