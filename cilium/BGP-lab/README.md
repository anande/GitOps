[Cilium BGP Lab](https://isovalent.com/labs/cilium-bgp/)

cilium install \
    --version v1.17.1 \
    --set ipam.mode=kubernetes \
    --set routingMode=native \
    --set ipv4NativeRoutingCIDR="10.0.0.0/8" \
    --set bgpControlPlane.enabled=true \
    --set k8s.requireIPv4PodCIDR=true

cilium status --wait

cilium config view | grep enable-bgp

kubectl apply -f netshoot-ds.yaml

SRC_POD=$(kubectl get pods -o wide | grep "kind-worker " | awk '{ print($1); }')

DST_IP=$(kubectl get pods -o wide | grep worker3 | awk '{ print($6); }')

kubectl exec -it $SRC_POD -- ping $DST_IP