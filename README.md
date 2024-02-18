### Run Terraform to create EKS Cluster

Go to terraform/resources/ folder and run 

Terraform Plan
```
terraform init -var-file="dev.tfvars"
terraform plan -var-file="dev.tfvars"
```

Terraform Apply
```
terraform init -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

### Update EBS CSI driver role name

- Go to `aws-ebs-csi-driver` folder and update `ebs-csi-controller-sa.yaml`. Update the role ARN with your's `eks.amazonaws.com/role-arn: arn:aws:iam::123456789:role/vrledu-dev-ebs-csi-controller-role`
- Install `aws-ebs-csi-driver` by running `make install` (update region and cluster name in Makefile, if it's different for you)
To verify that aws-ebs-csi-driver has started, run:
```
kubectl get pod -n ebs-csi-controller -l "app.kubernetes.io/name=aws-ebs-csi-driver,app.kubernetes.io/instance=aws-ebs-csi-driver"

https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html
https://kubernetes.io/docs/concepts/storage/storage-classes/
```

### Build and Push the docker image to DockerHub

```
docker build -t datawavelabs/python_web_app:latest .
docker push -t datawavelabs/python_web_app:latest
```

### Install ArgoCD 

```
aws eks update-kubeconfig --profile default --name web-app-dev --alias eks-dev;kubectl config use-context eks-dev
kubectl create ns argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.10.0/manifests/install.yaml
```

Update service type from ClusterIP to LoadBalancer
```
kubectl get service argocd-server -n argocd -o json | jq '.spec.type = "LoadBalancer"' | kubectl apply -f -
```

Admin is the username and get password as
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

Access the ArgoCD server using Service External IP
```
kubectl get svc -n argocd
https://<<External DNS of argocd server>>/
```

### Run Argocd application

```
kubectl create ns web-app
kubectl apply -f web-app.yaml
```

### Access web application 

```
kubectl get svc -n web-app
http://<load-balancer-dns>
```

### Post validate the output
In order to validate that data what we are seeing in the output table, we can manually check the details ie,

```
kubectl get po -n argocd

NAME                                                READY   STATUS    RESTARTS   AGE
argocd-application-controller-0                     1/1     Running   0          11m
argocd-applicationset-controller-8478f5d679-mlppn   1/1     Running   0          11m
argocd-dex-server-7d5b457877-v8n8s                  1/1     Running   0          11m
argocd-notifications-controller-5dfb54dc99-wmmr9    1/1     Running   0          11m
argocd-redis-76748db5f4-2tnsh                       1/1     Running   0          11m
argocd-repo-server-65bbbc45d9-mj7jb                 1/1     Running   0          11m
argocd-server-8699f8544f-2kslh                      1/1     Running   0          11m

kubectl describe po argocd-server-8699f8544f-2kslh -n argocd

Name:         argocd-server-8699f8544f-2kslh
Namespace:    argocd
Priority:     0
Node:         ip-10-140-67-49.ec2.internal/10.140.67.49
Start Time:   Sun, 18 Feb 2024 09:40:54 +0000
Labels:       app.kubernetes.io/name=argocd-server
              pod-template-hash=8699f8544f
Annotations:  <none>
Status:       Running
IP:           10.140.68.165
IPs:
  IP:           10.140.68.165
Controlled By:  ReplicaSet/argocd-server-8699f8544f
Containers:
  argocd-server:
    Container ID:  containerd://101e075ded5050eece5f2ffa30e96938e0ea24e630d1dd24e9b674ff05bd824b
    Image:         quay.io/argoproj/argocd:v2.10.0
    Image ID:      quay.io/argoproj/argocd@sha256:13cdc24e2218bb74fe6ec988c8045c7afc3043f24601e33b20ee78b787440baa
    Ports:         8080/TCP, 8083/TCP
    Host Ports:    0/TCP, 0/TCP
    Args:
      /usr/local/bin/argocd-server
    State:          Running
      Started:      Sun, 18 Feb 2024 09:40:55 +0000
    Ready:          True
```

### Connect to Postgres pod

In order to get Postgres credentials, check `helm-chart/templates/backend-secret.yaml` and you'll get the `username` and `password`. You can decode it using https://www.base64decode.org/

```
kubectl get po -n web-app
select backend-<> pod name and run below command
kubectl -n web-app exec -it backend-5cd4bb994d-blcjn -- psql -h localhost -U admin --password -p 5432
Password:
psql (13.14 (Debian 13.14-1.pgdg120+2))
Type "help" for help.
admin=# \l
 admin     | admin | UTF8     | en_US.utf8 | en_US.utf8 |
 pod_info  | admin | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/admin        +
           |       |          |            |            | admin=CTc/admin
 postgres  | admin | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | admin | UTF8     | en_US.utf8 | en_US.utf8 | =c/admin         +
           |       |          |            |            | admin=CTc/admin
 template1 | admin | UTF8     | en_US.utf8 | en_US.utf8 | =c/admin         +
           |       |          |            |            | admin=CTc/admin

admin=# \c pod_info
Password:
You are now connected to database "pod_info" as user "admin".
pod_info=# \dt
 public | pod_info | table | admin

pod_info=# select * from pod_info;
pod_info=#
```

### Install Grafana/ Prometheus

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --cleanup-on-fail --install prometheus prometheus-community/prometheus --namespace monitoring --create-namespace
helm upgrade --cleanup-on-fail --install grafana grafana/grafana --namespace monitoring --create-namespace
```

Post deployment, check all pods and services

```
kubectl -n monitoring get pods
NAME                                                READY   STATUS    RESTARTS   AGE
grafana-7449c7bfd4-vng2g                            1/1     Running   0          50s
prometheus-alertmanager-0                           1/1     Running   0          86s
prometheus-kube-state-metrics-58bc485699-kptlx      1/1     Running   0          87s
prometheus-prometheus-node-exporter-5vpjc           1/1     Running   0          87s
prometheus-prometheus-node-exporter-76cbc           1/1     Running   0          87s
prometheus-prometheus-node-exporter-f4czf           1/1     Running   0          87s
prometheus-prometheus-pushgateway-f4557d877-hq5nc   1/1     Running   0          87s
prometheus-server-766cfcd7cb-s2bf4                  2/2     Running   0          87s

kubectl -n monitoring get svc 
NAME                                  TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
grafana                               ClusterIP   10.228.9.167   abd17aa9bf6c446ada3a385dd30b64e2-1844479935.us-east-1.elb.amazonaws.com        80/TCP     58s
prometheus-alertmanager               ClusterIP   10.228.4.105   <none>        9093/TCP   95s
prometheus-alertmanager-headless      ClusterIP   None           <none>        9093/TCP   95s
prometheus-kube-state-metrics         ClusterIP   10.228.6.18    <none>        8080/TCP   95s
prometheus-prometheus-node-exporter   ClusterIP   10.228.5.38    <none>        9100/TCP   95s
prometheus-prometheus-pushgateway     ClusterIP   10.228.2.52    <none>        9091/TCP   95s
prometheus-server                     ClusterIP   10.228.6.93    <none>        80/TCP     95s
```

Expose the Grafana service via Public Load Balancer and use the `grafana` service External IP to connect to it
```
kubectl get service grafana -n monitoring -o json | jq '.spec.type = "LoadBalancer"' | kubectl apply -f -
```

To login to Grafana, you can fetch credentials from the Grafana secret

```
kubectl -n monitoring get secret grafana -o yaml
```

Fetch the `admin-password` and `admin-user` and decode it using https://www.base64decode.org/

```
http://<load-balancer-dns>
```