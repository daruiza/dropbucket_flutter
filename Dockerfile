FROM nginx:stable-alpine

# Instalar Certbot para obtener certificados SSL
# RUN apk add --no-cache certbot certbot-nginx

# Copiar la configuración personalizada de nginx si es necesaria
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar los archivos construidos al directorio de nginx
COPY build/web /usr/share/nginx/html

# Script de entrada para generar certificados al iniciar
# COPY /asistirensalud.space/fullchain.pem /etc/letsencrypt/live/www.asistirensalud.space/fullchain.pem
# COPY /asistirensalud.space/private.key /etc/letsencrypt/live/www.asistirensalud.space/privkey.pem

# EXPOSE 8831 443
EXPOSE 8831
# CMD ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

#flutter packages pub global activate webdev
#flutter build web --web-renderer=html
#flutter build web --no-tree-shake-icons --release
#docker build -f Dockerfile -t daruiza/dropbucket_flutter:aws .
#docker push daruiza/dropbucket_flutter:aws

#PARA WINDOWS
#flutter config --enable-windows-desktop
#flutter build windows --target lib/app/main.dart

#PARA ANDROID APK
#flutter build apk --release --no-tree-shake-icons


#Para producción ssl https certificados
#docker exec -it dropbucket_flutter certbot --nginx -d www.asistirensalud.space --non-interactive --agree-tos -m daruiza@gmail.com
#cada 3 meses
#docker exec -it dropbucket_flutter certbot renew

# Combianción de archivos para el certificado
#cat certificate.crt ca_bundle.crt > fullchain.pem

