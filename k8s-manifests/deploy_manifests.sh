# Apply NGINX Ingress Controller
kubectl apply -f ingress/ingress-nginx.yaml

# Wait for the Ingress Controller to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Apply namespaces
kubectl apply -f namespaces/

kubectl create deployment hello --image=hashicorp/http-echo -n app
kubectl expose deployment hello --type=LoadBalancer --port=80 --target-port=5678 -n app

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus using the prometheus-values.yaml file from the monitor directory
helm install prometheus prometheus-community/kube-prometheus-stack -n monitor -f monitor/prometheus-values.yaml

# Wait for CRDs to be ready
kubectl wait --for=condition=established --timeout=60s crd/alertmanagers.monitoring.coreos.com
kubectl wait --for=condition=established --timeout=60s crd/podmonitors.monitoring.coreos.com
kubectl wait --for=condition=established --timeout=60s crd/prometheuses.monitoring.coreos.com
kubectl wait --for=condition=established --timeout=60s crd/prometheusrules.monitoring.coreos.com
kubectl wait --for=condition=established --timeout=60s crd/servicemonitors.monitoring.coreos.com
kubectl wait --for=condition=established --timeout=60s crd/thanosrulers.monitoring.coreos.com

# Wait for Prometheus to be deployed
kubectl wait --namespace monitor \
  --for=condition=ready pod \
  --selector=app=prometheus-server \
  --timeout=90s

# Apply the ServiceMonitor for the Ingress Controller
kubectl apply -f monitor/ingress-nginx-servicemonitor.yaml

# Apply the ServiceMonitor for the hello service
kubectl apply -f ingress/test-ingress.yaml