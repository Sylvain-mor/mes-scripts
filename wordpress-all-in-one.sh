#!/bin/bash

set -e

NAMESPACE="wordpress"

echo "🔎 Vérification du cluster KIND..."
if ! kind get clusters | grep -q "kind"; then
    echo "❌ Aucun cluster KIND trouvé. Création..."
    kind create cluster --config kind-config.yaml
else
    echo "✅ Cluster KIND déjà présent."
fi

echo "🔎 Vérification du namespace..."
if ! kubectl get ns | grep -q "$NAMESPACE"; then
    echo "📦 Création du namespace $NAMESPACE..."
    kubectl create ns $NAMESPACE
else
    echo "✅ Namespace $NAMESPACE déjà présent."
fi

echo "📦 Déploiement du PVC MariaDB..."
kubectl apply -n $NAMESPACE -f mysql-pvc.yaml

echo "📦 Déploiement de MariaDB..."
kubectl apply -n $NAMESPACE -f mysql-deployment.yaml
kubectl apply -n $NAMESPACE -f mysql-service.yaml

echo "📦 Déploiement du PVC WordPress..."
kubectl apply -n $NAMESPACE -f wordpress-pvc.yaml

echo "📦 Déploiement de WordPress..."
kubectl apply -n $NAMESPACE -f wordpress-deployment.yaml
kubectl apply -n $NAMESPACE -f wordpress-service.yaml

echo "⏳ Attente du démarrage des pods..."
kubectl wait --for=condition=ready pod -l app=mysql -n $NAMESPACE --timeout=120s
kubectl wait --for=condition=ready pod -l app=wordpress -n $NAMESPACE --timeout=120s

echo "🎉 Déploiement terminé !"
echo "🌍 Accès WordPress : http://localhost:30080"
