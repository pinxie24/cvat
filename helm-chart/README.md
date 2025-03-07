
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
4. helm install -f ./values.yaml -f ./values.override.yaml cvat-poc --version 0.14.3-valc2 oci://cr-demo-cn-shanghai.cr.volces.com/cvat/cvat

