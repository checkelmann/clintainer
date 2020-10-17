# clintainer

Docker Container loaded with a lot of K8s CLI's like kubectl, helm, istio and keptn preloaded with Oh My ZSH


![Screenshot](screenshot.png)

Just run:

```
docker run -v ~/.kube/config:/home/commander/.kube/config -it checkelmann/clintainer
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
- eksctl
- k9s (github.com/derailed/k9s)
- kubectx & kubens (github.com/ahmetb/kubectx)

## If you want more, just open an issue or feel free to contribute!