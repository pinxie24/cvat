
[See for details](https://docs.cvat.ai/docs/administration/advanced/k8s_deployment_with_helm/)

# Guide to deploy cvat on volcengine kubernetes

## Upload all images to volcengine
1. ./upload-images2volc.sh # upload dependent images to volcengine

## Create VKE cluster
1. $env:KUBECONFIG = "C:\Users\pinox\Desktop\pinxie\projects\vke\kube.conf"  # powershell setup kube env.
1. export KUBECONFIG=~/Desktop/pinxie/projects/vke/kube.conf # bash setup kube env.
2. kubectl get node
3. kubectl create secret docker-registry volc-registry-secret --docker-server=cr-demo-cn-shanghai.cr.volces.com --docker-username=<your-name> --docker-password=<your-password> --namespace=default


# Package cvat chart package for volcengine
1. helm registry login cr-demo-cn-shanghai.cr.volces.com
2. helm package ./helm-chart
3. helm push cvat-0.14.3-valc2.tgz oci://cr-demo-cn-shanghai.cr.volces.com/cvat
4. helm install cvat-poc oci://cr-demo-cn-shanghai.cr.volces.com/cvat/cvat --version 0.14.3-valc2 -f ./values.yaml -f ./values.override.yaml

# create CLB to allow public access
1. VKE - Service - create service
2. Select LB, and passthrough pod
3. Create CLB
4. Set port 80, protocol TCP
4. Associate with workload, cvat-frontend

# create super user

```
$env:HELM_RELEASE_NAMESPACE = "default"
$env:HELM_RELEASE_NAME = "cvat-poc"

$env:BACKEND_POD_NAME = $(kubectl get pod --namespace default -l tier=backend,app.kubernetes.io/instance=cvat-poc,component=server -o jsonpath='{.items[0].metadata.name}')

kubectl exec -it "$env:BACKEND_POD_NAME" -c cvat-backend --namespace "$env:HELM_RELEASE_NAMESPACE" -- python manage.py createsuperuser
```
