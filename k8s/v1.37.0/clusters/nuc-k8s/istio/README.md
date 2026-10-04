Install Istio Base chart for CRD resources:

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm install my-base istio-official/base --version 1.30.3