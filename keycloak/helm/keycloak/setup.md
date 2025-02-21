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

## CLI Setup for keycloak

Create an initialization bash script with kc commands that will:
#### Create a realm

> NOTE: If you are inside a container (like in Kubernetes), / is typically read-only, but /tmp is writable.
```
keycloak@keycloak-0:/$ kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password RedHat1! --config /tmp/kcadm.config
Logging into http://localhost:8080 as user admin of realm master


keycloak@keycloak-0:/$ kcadm.sh create realms -s realm=selfhosted -s enabled=true --config /tmp/kcadm.config
Created new realm with id 'selfhosted'
```

#### Create User and set password
```
keycloak@keycloak-0:/$ kcadm.sh create users -r selfhosted -s username=anande -s enabled=true --config /tmp/kcadm.config
Created new user with id '1f29a814-fae5-481d-980c-7b6e43bfd2b5'


keycloak@keycloak-0:/$ kcadm.sh set-password -r selfhosted --username anande --new-password MyStrongPassword! --config /tmp/kcadm.config
```

#### Create Group
```
keycloak@keycloak-0:/$ kcadm.sh create groups -r selfhosted -s name=git-admins --config /tmp/kcadm.config
Created new group with id 'cc28b0f8-ccf2-47f7-b3fb-5c44fe66f797'
```
#### Add User to group
- Get group id:
```
keycloak@keycloak-0:/$ kcadm.sh get groups -r selfhosted --config /tmp/kcadm.config
[ {
  "id" : "cc28b0f8-ccf2-47f7-b3fb-5c44fe66f797",
  "name" : "git-admins",
  "path" : "/git-admins",
  "subGroupCount" : 0,
  "subGroups" : [ ],
  "access" : {
    "view" : true,
    "viewMembers" : true,
    "manageMembers" : true,
    "manage" : true,
    "manageMembership" : true
  }
} ]
```
- Get User id:
```
keycloak@keycloak-0:/$ kcadm.sh get users -r selfhosted --query username=anande --config /tmp/kcadm.config
[ {
  "id" : "1f29a814-fae5-481d-980c-7b6e43bfd2b5",
  "username" : "anande",
  "emailVerified" : false,
  "createdTimestamp" : 1740125449146,
  "enabled" : true,
  "totp" : false,
  "disableableCredentialTypes" : [ ],
  "requiredActions" : [ ],
  "notBefore" : 0,
  "access" : {
    "manageGroupMembership" : true,
    "view" : true,
    "mapRoles" : true,
    "impersonate" : true,
    "manage" : true
  }
} ]
```
- Add user to the group:
```
keycloak@keycloak-0:/$ kcadm.sh update users/1f29a814-fae5-481d-980c-7b6e43bfd2b5/groups/cc28b0f8-ccf2-47f7-b3fb-5c44fe66f797 -r selfhosted -s realm=selfhosted -s userId=1f29a814-fae5-481d-980c-7b6e43bfd2b5 -s groupId=cc28b0f8-ccf2-47f7-b3fb-5c44fe66f797 -n --config /tmp/kcadm.config
```
#### Create client
```
keycloak@keycloak-0:/$ kcadm.sh create clients -r selfhosted -s clientId=gitea -s enabled=true --config /tmp/kcadm.config
Created new client with id 'ffaf7f37-9539-4130-812a-35e5f24a20c1'
```
#### Get the credentials/secret 
```
keycloak@keycloak-0:/$ kcadm.sh get clients/ffaf7f37-9539-4130-812a-35e5f24a20c1/client-secret -r selfhosted --config /tmp/kcadm.config
{
  "type" : "secret",
  "value" : "aot8RrZ8Ifi3okzf93WrkcsVmiDccreI"
}
```
#### Change client scopes attributes
```
keycloak@keycloak-0:/$ kcadm.sh delete clients/ffaf7f37-9539-4130-812a-35e5f24a20c1/default-client-scopes/ae780694-5823-47ee-b5c1-2d0c180970a9 -r selfhosted --config /tmp/kcadm.config


keycloak@keycloak-0:/$ kcadm.sh update clients/ffaf7f37-9539-4130-812a-35e5f24a20c1/optional-client-scopes/ae780694-5823-47ee-b5c1-2d0c180970a9 -r selfhosted --config /tmp/kcadm.config
```

###### References:
1. [Server Administration Document](https://www.keycloak.org/docs/latest/server_admin/index.html#client-operations)