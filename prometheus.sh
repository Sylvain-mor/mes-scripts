#!/bin/bash

echo "=== Vérification du cluster KIND ==="
CLUSTER=$(kind get clusters)

if [ -z "$CLUSTER" ]; then
    echo "Aucun cluster trouvé. Démarrage du cluster KIND..."
    kind create cluster --name kind
else
    echo "Cluster KIND détecté : $CLUSTER"
fi

echo ""
echo "=== Vérification de Prometheus ==="
PROM_POD=$(kubectl get pods -n monitoring | grep prometheus-monitoring-kube-prometheus-prometheus | awk '{print $1}')

if [ -z "$PROM_POD" ]; then
    echo "Prometheus n'est pas encore prêt. Attente..."
    sleep 10
    PROM_POD=$(kubectl get pods -n monitoring | grep prometheus-monitoring-kube-prometheus-prometheus | awk '{print $1}')
fi

echo "Prometheus détecté : $PROM_POD"
echo ""

echo "=== Fermeture des anciens port-forward ==="
pkill -f "kubectl port-forward" 2>/dev/null

echo "=== Ouverture de Prometheus sur http://localhost:9092 ==="
kubectl port-forward -n monitoring $PROM_POD 9092:9090
