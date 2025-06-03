## Setup AWS CLI:  

Reference: [https://docs.aws.amazon.com/eks/latest/userguide/install-awscli.html](https://docs.aws.amazon.com/eks/latest/userguide/install-awscli.html)

```
$ cd ~/Documents/


$ curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 40.5M  100 40.5M    0     0  6090k      0  0:00:06  0:00:06 --:--:-- 6193k


$ sudo installer -pkg AWSCLIV2.pkg -target /
Password:
installer: Package name is AWS Command Line Interface
installer: Installing at base path /
installer: The install was successful.


$ which aws && aws --version
/usr/local/bin/aws
aws-cli/2.27.3 Python/3.13.2 Darwin/24.4.0 exe/x86_64


$ aws configure
AWS Access Key ID [None]: xxxxxxxxxxxxxxx
AWS Secret Access Key [None]: xxxxxxxxxxxxxxx
Default region name [None]: ap-south-1
Default output format [None]: json


$ aws sts get-session-token --duration-seconds 3600
{
    "Credentials": {
        "AccessKeyId": "xxxxxxxxxxxxxxx",
        "SecretAccessKey": "xxxxxxxxxxxxxxx",
        "SessionToken": "IQoJb3JpZ2luX2VjEPf//////////wEaCmFwLXNvdXRoLTEiSDBGAiEA7/ZILGVqaPiZS1rMNbs6yWUMyJkdkkpfTJIld6AxytwCIQCNpTSBbR/adfww1Ff+ee8pAHJNUTJYQViWpfK+YH0ANyrcAQiQ//////////8BEAAaDDM5MDI1NDg0NDk1OCIMQXwc6JQOEoJwW2pzKrABvonYtkuURJ68fyRqewkQZ3pjQ6kEdeHyR2pwSH63t3Se0BgMLhOPPMmAszQi76yb9grQ3kjuoIbUO+/KdIPRWKykZRVmz+RuFLgiwhe1XqtnLAKpAOYDJPXAT790bCQQqOFUWRW2EbJdOtSxKMOT7zu4PfbQOb0aYOxes9rAjpFZSHmN6Ju+a4WzY2pSTekHQuB+Hz23iouc9I9cXU+QRYhsw11SzwigOH7fNvjFJZ8wqsfDwAY6lwGWgd7i/1a56aJJbD9vKoGgmzlZsn8dPghH7Sz6eyoEQ7Xtusi2ENyA7u/qYOPfdNJepx8kkeH/OWvsTQ6yjBN1q1YZC/OZg1uOsaGSzST41t1PiIx67Vuf+CXnbCorTeYJRhFt4MGMMy9sqS8dgxUu7Jd4IaEHLHd0OqN4LXXqbSAHvVETnzkLSuSzKx2WeuDly0UL/SOM",
        "Expiration": "2025-04-29T15:35:22+00:00"
    }
}


$ aws sts get-caller-identity
{
    "UserId": "390254844958",
    "Account": "390254844958",
    "Arn": "arn:aws:iam::390254844958:root"
}
```

## Set up kubectl and eksctl

Reference: 
1. [https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)
2. [eksctl](https://eksctl.io/installation/#for-macos)

```
brew tap weaveworks/tap

brew install weaveworks/tap/eksctl
```

#### Deploy 2 node EKS cluster
```
eksctl create cluster -f cluster-config.yaml

aws eks describe-cluster --name argocd --output text
```

Add kube context to laptop
```
aws eks --region ap-south-1 update-kubeconfig --name argocd

kubectl config rename-context arn:aws:eks:ap-south-1:390254844958:cluster/argocd eks-argocd
```

To delete a cluster:
```
eksctl delete cluster -n argocd
```
