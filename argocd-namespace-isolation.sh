NAMESPACE=argocd
oc new-project $NAMESPACE
oc apply -f https://raw.githubusercontent.com/argoproj/argo-cd/v1.7.8/manifests/namespace-install.yaml
oc patch deployment argocd-redis -p '{"spec": {"template": {"spec": {"securityContext": null}}}}'
oc create route passthrough argocd --service=argocd-server --port=https --insecure-policy=Redirect
ROUTE=$(oc get route argocd -o jsonpath='{ .spec.host }')
echo "Ruta = $ROUTE"

oc new-project argocd-managed --skip-config-write
oc new-project demo --skip-config-write

PASSWORD=$(oc get pod -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[*].metadata.name}')
argocd --insecure --grpc-web login $ROUTE:443 --username "admin" --password $PASSWORD
# array=("argocd-managed" "demo")
# argocd cluster add $(oc config current-context) --name=cluster1 --in-cluster --system-namespace=$NAMESPACE --namespace=${array[@]}

argocd cluster add $(oc config current-context) --name=cluster1 --in-cluster --system-namespace=$NAMESPACE --namespace=argocd-managed --namespace=demo

# Al añadir el clúster mediante la CLI, ésta se encarga de añadir los siguientes permisos
# oc -n argocd create sa argocd-manager
# oc create role argocd-manager-role --resource=*.*  --verb=*
# oc create rolebinding argocd-manager-role-binding --role=argocd-manager-role --serviceaccount=$NAMESPACE:argocd-manager

argocd app create nexus --repo=https://github.com/redhat-canada-gitops/catalog --path=nexus2/base --dest-server=https://kubernetes.default.svc --dest-namespace=demo --sync-policy=auto
argocd app create nexus2 --repo=https://github.com/redhat-canada-gitops/catalog --path=nexus2/base --dest-server=https://kubernetes.default.svc --dest-namespace=argocd-managed --sync-policy=auto
