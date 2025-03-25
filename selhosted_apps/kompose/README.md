# Test `docker-compose` conversion to k8s manifests

- Create a test directory to store your compose files:  
    ```
    mkdir sample_app; \
    cd sample_app; \
    wget https://raw.githubusercontent.com/kubernetes/kompose/main/examples/compose.yaml
    ```  

- Install [Kompose](https://kompose.io/installation/#macos)  
  `brew install kompose`  

- Make sure you are present in the same directory as your compose-files  

- Run kompose:
    ```
    kompose convert
    INFO Kubernetes file "redis-leader-service.yaml" created 
    INFO Kubernetes file "redis-replica-service.yaml" created 
    INFO Kubernetes file "web-service.yaml" created   
    INFO Kubernetes file "redis-leader-deployment.yaml" created 
    INFO Kubernetes file "redis-replica-deployment.yaml" created 
    INFO Kubernetes file "web-deployment.yaml" created 
    ```

- Test creation of kompose-app based on new manifests:
    ```
    # Create a test namespace

    k create ns kompose
    namespace/kompose created


    # Switch to that namespace
    
    kubens kompose
    Context "k3d-helm-demo" modified.
    Active namespace is "kompose".


    # Apply the newly created manifests:

    k apply -f redis-leader-deployment.yaml -f redis-leader-service.yaml -f redis-replica-deployment.yaml -f redis-replica-service.yaml -f web-deployment.yaml -f web-service.yaml 
    deployment.apps/redis-leader created
    service/redis-leader created
    deployment.apps/redis-replica created
    service/redis-replica created
    deployment.apps/web created
    service/web created

    ```

- After testing, delete the sample_app:
    ```
    k delete -f redis-leader-deployment.yaml -f redis-leader-service.yaml -f redis-replica-deployment.yaml -f redis-replica-service.yaml -f web-deployment.yaml -f web-service.yaml
    deployment.apps "redis-leader" deleted
    service "redis-leader" deleted
    deployment.apps "redis-replica" deleted
    service "redis-replica" deleted
    deployment.apps "web" deleted
    service "web" deleted
    ```