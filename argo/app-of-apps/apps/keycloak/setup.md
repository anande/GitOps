## Instructions 

Create and store adminPassword as secret in the same keycloak namespace:
```
kubectl create secret generic keycloak-admin-password --from-literal=adminPassword='password!' -n keycloak2
secret/keycloak-admin-password created
```

Generate certificates locally using `mkcert`,  
Create and store TLS certificates as secret in the same keycloak namespace:
```
kubectl create secret tls keycloak-tls-cert --key ./keycloak.local.com+1-key.pem --cert ./keycloak.local.com+1.pem -n keycloak2
secret/keycloak-tls-cert created
```