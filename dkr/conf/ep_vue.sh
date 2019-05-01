#!/usr/bin/env sh

echo "### DDT: VUE -- BUILDING"
npm run build || exit 1

# Recolecta los archivos estáticos y ejecuta servidor gunicorn
echo "### DDT: VUE -- HTTP-SERVE"
http-server dist
