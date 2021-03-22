# clintainer

[![Build Status](https://travis-ci.com/checkelmann/clintainer.svg?branch=main)](https://travis-ci.com/checkelmann/clintainer)

Docker Container loaded with a lot of K8s CLI's like kubectl, helm, istio and keptn preloaded with Oh My ZSH.

This image will be automatically build every week and is using the latest available releases of the tools.

If you need to work on a remote server and don't want to install all the tools manually, or for ad-hoc operation tasks.

![Screenshot](screenshot.png)

## Run clintainer on Docker

```
docker run -v ~/.kube/config:/home/operator/.kube/config -it checkelmann/clintainer
```
### Cleanup
```
docker rmi checkelmann/clintainer
```

## Run clintainer as cluster-admin in K8s

1. Create a clintainer service account with kubectl

```
kubectl create serviceaccount clintainer --namespace kube-system
```

2. Create a clintainer-rolebinding.yaml file with the following content

```
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: clintainer-clusterrolebinding
subjects:
- kind: ServiceAccount
  name: clintainer
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: ""
```

3. Deploy the rolebinding
```
kubectl apply -f clintainer-rolebinding.yaml
```

4. Run clintainer

```
kubectl run clintainer -n kube-system --image=checkelmann/clintainer -it --rm --restart=Never --serviceaccount=clintainer
```

5. Cleanup
```
kubectl delete -f clintainer-rolebinding.yaml
kubectl delete serviceaccount clintainer --namespace kube-system
```

### All in one (if you trust external Manifests)

```
kubectl create serviceaccount clintainer --namespace kube-system
kubectl apply -f https://raw.githubusercontent.com/checkelmann/clintainer/main/rolebinding.yaml
kubectl run clintainer -n kube-system --image=checkelmann/clintainer -it --rm --restart=Never --serviceaccount=clintainer
kubectl delete -f https://raw.githubusercontent.com/checkelmann/clintainer/main/rolebinding.yaml
kubectl delete serviceaccount clintainer --namespace kube-system
```

## Included tools:

- Git
- Git LFS
- Bit (github.com/chriswalz/bit)
- Oh My Zsh (github.com/ohmyzsh/ohmyzsh)
- kubectl 
- keptn (github.com/keptn)
- helm3 (helm.sh)
- istioctl (istio.io)
- OpenServiceMesh (github.com/openservicemesh)
- eksctl (eksctl.io)
- k9s (github.com/derailed/k9s)
- kubectx & kubens (github.com/ahmetb/kubectx)
- stern (github.com/wercker/stern)
- kubespy (github.com/pulumi/kubespy)
- kube-shell (github.com/cloudnativelabs/kube-shell)
- AWS CLI
- Dynatrace Monaco (github.com/dynatrace-oss/dynatrace-monitoring-as-code)

__If you want more, just open an issue or feel free to contribute!__