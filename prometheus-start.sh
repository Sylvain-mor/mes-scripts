#!/bin/bash

echo "=== Vérification du cluster KIND ==="
CLUSTER=$(kind get clusters)

if [ -z "$CLUSTER" ]; then
    echo "Aucun cluster trouvé. Démarrage du cluster KIND..."
    kind create cluster --config kind-config.yaml
else
    echo "Cluster KIND détecté : $CLUSTER"
fi

echo ""
echo "=== Vérification de l'Ingress NGINX ==="
INGRESS_READY=$(kubectl get pods -n ingress-nginx --no-headers | grep ingress-nginx-controller | awk '{print $2}')

if [ "$INGRESS_READY" != "Running" ]; then
    echo "Ingress NGINX non prêt. Installation..."
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
    echo "Attente de l'Ingress..."
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=120s
else
    echo "Ingress NGINX prêt."
fi

echo ""
echo "=== Vérification du namespace monitoring ==="
kubectl get ns monitoring >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Namespace monitoring absent. Création..."
    kubectl create namespace monitoring
fi

echo ""
echo "=== Vérification de Prometheus (Helm) ==="
helm list -n monitoring | grep monitoring >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Prometheus non installé. Installation..."
    helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring
else
    echo "Prometheus déjà installé."
fi

echo ""
echo "=== Vérification de l'Ingress Prometheus ==="
kubectl get ingress prometheus-ingress -n monitoring >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Ingress Prometheus absent. Application..."
    kubectl apply -f prometheus-ingress.yaml
else
    echo "Ingress Prometheus déjà présent."
fi

echo ""
echo "=== Prometheus est prêt ==="
echo "Accès direct : https://prometheus.local/?utm_source=copilot.com"
echo ""
echo "Clique ici : https://prometheus.local/?utm_source=copilot.com"
