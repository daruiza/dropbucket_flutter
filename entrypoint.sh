#!/bin/sh

DOMAIN="www.asistirensalud.online"
EMAIL="daruiza@gmail.com"

# Verificar si el certificado ya existe
if [ ! -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "Obteniendo certificado SSL para $DOMAIN..."
    certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL
else
    # Si Certbot falla, continuar sin HTTPS
    if [ $? -ne 0 ]; then
        echo "Error al obtener el certificado SSL. Iniciando Nginx sin HTTPS..."
        sed -i '/ssl_certificate/d' /etc/nginx/conf.d/default.conf
        sed -i '/ssl_certificate_key/d' /etc/nginx/conf.d/default.conf
        sed -i 's/listen 443 ssl;/listen 80;/g' /etc/nginx/conf.d/default.conf
    fi
fi

# Renovar certificados automáticamente (en segundo plano)
certbot renew --quiet &

# Iniciar Nginx
echo "Iniciando Nginx..."
nginx -g "daemon off;"