
[See for details](https://docs.cvat.ai/docs/administration/advanced/k8s_deployment_with_helm/)

# Guide to deploy cvat on volcengine kubernetes

## Upload all images to volcengine
1. ./upload-images2volc.sh # upload dependent images to volcengine

## Create VKE cluster
1. $env:KUBECONFIG = "C:\Users\pinox\Desktop\pinxie\projects\vke\kube.conf"  # powershell setup kube env.
2. kubectl get node
3. 1. kubectl create secret docker-registry volc-registry-secret --docker-server=cr-demo-cn-shanghai.cr.volces.com --docker-username=<your-name> --docker-password=<your-password> --namespace=default
4. helm package ./helm-chart
4. helm install cvat-poc ./helm-chart --namespace cvat --values values.override.yaml
