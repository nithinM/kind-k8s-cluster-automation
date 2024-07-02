#!/bin/bash

# Namespace variables
NAMESPACE_APP="app"
NAMESPACE_MONITOR="monitor"
NAMESPACE_INGRESS="ingress-nginx"

# Helper functions for formatting output
print_header() {
  printf "\n===============================================================\n"
  printf " %s\n" "$1"
  printf "===============================================================\n\n"
}

print_success() {
  printf "✅ %s\n\n" "$1"
}

print_error() {
  printf "❌ %s\n\n" "$1"
}

# Apply Nginx Ingress Controller
print_header "Applying Nginx Ingress Controller"
kubectl apply -f ingress/ingress-nginx.yaml

# Wait for the Ingress Controller to be ready
print_header "Waiting for Nginx Ingress Controller to be ready"
kubectl wait --namespace $NAMESPACE_INGRESS \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Apply namespaces
print_header "Applying Namespaces"
kubectl apply -f namespaces/

# Add and update Helm repo
print_header "Adding and Updating Helm Repo"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus using the prometheus-values.yaml file from the monitor directory
print_header "Installing Prometheus"
helm install prometheus prometheus-community/kube-prometheus-stack -n $NAMESPACE_MONITOR -f monitor/prometheus-values.yaml

# Wait for CRDs to be ready
print_header "Waiting for Prometheus CRDs to be ready"
kubectl wait --for=condition=established --timeout=60s crd/alertmanagers.monitoring.coreos.com
kubectl wait --for=condition=established --timeout=60s crd/podmonitors.monitoring.coreos.com
kubectl wait --for=condition=established --timeout=60s crd/prometheuses.monitoring.coreos.com
kubectl wait --for=condition=established --timeout=60s crd/prometheusrules.monitoring.coreos.com
kubectl wait --for=condition=established --timeout=60s crd/servicemonitors.monitoring.coreos.com
kubectl wait --for=condition=established --timeout=60s crd/thanosrulers.monitoring.coreos.com

# Wait for Prometheus to be deployed
print_header "Waiting for Prometheus to be deployed"
kubectl wait --namespace $NAMESPACE_MONITOR \
  --for=condition=ready pod \
  --selector=app=prometheus-server \
  --timeout=90s

# Apply the ServiceMonitor for the Ingress Controller
print_header "Applying ServiceMonitor for the Ingress Controller"
kubectl apply -f monitor/ingress-nginx-servicemonitor.yaml

# Apply foo-app deployments and services
print_header "Applying foo-app Deployments and Services"
kubectl apply -f services/foo-app
# Wait for the foo-app deployment to be successfully rolled out
kubectl rollout status deployment/foo-deployment -n $NAMESPACE_APP

# Apply bar-app deployments and services
print_header "Applying bar-app Deployments and Services"
kubectl apply -f services/bar-app
# Wait for the bar-app deployment to be successfully rolled out
kubectl rollout status deployment/bar-deployment -n $NAMESPACE_APP

# Apply the Ingress for the foo-app and bar-app
print_header "Applying Ingress for foo-app and bar-app"
kubectl apply -f ingress/app-ingress.yaml

# Function to check the health of deployments
check_deployment_health() {
  local deployment=$1
  local namespace=$2
  printf "Checking health for deployment: %s\n" "$deployment"
  if ! kubectl rollout status deployment/"$deployment" -n "$namespace"; then
    print_error "Deployment $deployment in namespace $namespace is not healthy."
    exit 1
  fi
  print_success "Deployment $deployment in namespace $namespace is healthy."
}

# Function to check the health of services
check_service_health() {
  local service=$1
  local namespace=$2
  printf "Checking health for service: %s\n" "$service"
  if ! kubectl get service/"$service" -n "$namespace"; then
    print_error "Service $service in namespace $namespace is not healthy."
    exit 1
  fi
  print_success "Service $service in namespace $namespace is healthy."
}

# Function to check the health of the Ingress
check_ingress_health() {
  local ingress=$1
  local namespace=$2
  printf "Checking health for ingress: %s\n" "$ingress"
  if ! kubectl get ingress/"$ingress" -n "$namespace"; then
    print_error "Ingress $ingress in namespace $namespace is not healthy."
    exit 1
  fi
  local ingress_ready
  ingress_ready=$(kubectl get ingress/"$ingress" -n "$namespace" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
  if [ -z "$ingress_ready" ]; then
    ingress_ready=$(kubectl get ingress/"$ingress" -n "$namespace" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  fi
  if [ -n "$ingress_ready" ]; then
    print_success "Ingress $ingress in namespace $namespace is ready with hostname/IP: $ingress_ready"
  else
    print_error "Ingress $ingress in namespace $namespace is not ready."
    exit 1
  fi
}

# Check health of foo-app and bar-app deployments
print_header "Checking Health of Deployments"
check_deployment_health "foo-deployment" $NAMESPACE_APP
check_deployment_health "bar-deployment" $NAMESPACE_APP

# Check health of foo-app and bar-app services
print_header "Checking Health of Services"
check_service_health "foo-service" $NAMESPACE_APP
check_service_health "bar-service" $NAMESPACE_APP

# Check health of the Ingress
print_header "Checking Health of Ingress"
check_ingress_health "app-ingress" $NAMESPACE_APP

# Final success message
printf "\n===============================================================\n"
printf "              🎉 All resources are healthy! 🎉\n"
printf "===============================================================\n\n"
