FROM nginx:alpine

# Instalar curl para soportar el healthcheck configurado en docker-compose
RUN apk add --no-cache curl

# Copiar la configuración personalizada de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar los archivos estáticos del frontend
COPY . /usr/share/nginx/html/

# Asegurar que index.html exista apuntando a dashboard.html
RUN cp /usr/share/nginx/html/dashboard.html /usr/share/nginx/html/index.html

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]