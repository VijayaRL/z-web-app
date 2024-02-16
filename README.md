### Run Terraform to create EKS Cluster

Go to terraform/resources/ folder and run 

Terraform Plan
```
terraform init -var-file="dev.tfvars"
terraform plan -var-file="dev.tfvars"
```

Terraform Apply
```
terraform apply -var-file="dev.tfvars"
```

### Build and Push the docker image to DockerHub

```
docker build -t vijayalakshman/python_web_app:latest .
docker push -t vijayalakshman/python_web_app:latest
```

### Install ArgoCD 

```
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
Create docker secret first
```
kubectl create ns web-app
kubectl -n web-app create secret docker-registry docker-login --docker-server=https://index.docker.io/v1/ --docker-username= --docker-password= --docker-email=
```

```
cd ../../argocd-app/
kubectl apply -f web-app.yaml
```

### Access web application 

```
kubectl get svc -n web-app
http://<load-balancer-dns>
```

### Connect to Postgres pod
In order to get Postgres credentials, check helm-chart/templates/backend-secret.yaml and you'll get the username and password. 
You can decode it using https://www.base64decode.org/

```
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
grafana                               ClusterIP   10.228.9.167   <none>        80/TCP     58s
prometheus-alertmanager               ClusterIP   10.228.4.105   <none>        9093/TCP   95s
prometheus-alertmanager-headless      ClusterIP   None           <none>        9093/TCP   95s
prometheus-kube-state-metrics         ClusterIP   10.228.6.18    <none>        8080/TCP   95s
prometheus-prometheus-node-exporter   ClusterIP   10.228.5.38    <none>        9100/TCP   95s
prometheus-prometheus-pushgateway     ClusterIP   10.228.2.52    <none>        9091/TCP   95s
prometheus-server                     ClusterIP   10.228.6.93    <none>        80/TCP     95s
```

Expose the Grafana service via Public Load Balancer and use the grafana service External IP to connect to it
```
kubectl get service grafana -n monitoring -o json | jq '.spec.type = "LoadBalancer"' | kubectl apply -f -
```

To login to Grafana, you can fetch credentials from the Grafana secret

```
kubectl -n monitoring get secret grafana -o yaml

echo "password_value" | openssl base64 -d ; echo
echo "username_value" | openssl base64 -d ; echo
```
Fetch the admin-password and admin-user and decode it using https://www.base64decode.org/