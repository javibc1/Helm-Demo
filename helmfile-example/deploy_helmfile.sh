# Añadir y actualizar repos de helm
helmfile --environment dev repos
# Desplegar todos los charts del helmfile
helmfile --environment dev apply --suppress-secrets --skip-deps
# Destruir todos los charts del helmfile
helmfile --environment dev destroy
