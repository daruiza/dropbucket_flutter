FROM nginx:stable-alpine

# FROM daruiza/dropbucket_flutter:aws

# Copiar la configuración personalizada de nginx si es necesaria
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar los archivos construidos al directorio de nginx
COPY build/web /usr/share/nginx/html

#flutter packages pub global activate webdev    
#flutter build web --no-tree-shake-icons --release
#docker build -f Dockerfile -t daruiza/dropbucket_flutter:aws .

#PARA WINDOWS
#flutter config --enable-windows-desktop
#flutter build windows --target lib/app/main.dart

#PARA ANDROID APK
#flutter build apk --release --no-tree-shake-icons