# Kubectl Cheat Sheet

### CLUSTER INFO & EVENTS

<details><summary>show</summary>
<p>

```bash
# list the kube config settings
kubectl config view

# list all the users in the cluster
kubectl config view -o jsonpath='{.users[*].name}'

# find where control plane is running
kubectl cluster-info

# get system health (controller manager, scheduler and etcd)
kubectl get componentstatus

# list all resources available to create (not currently created)
kubectl api-resources

# get the raw metrics for nodes
kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes

# get the raw metrics for pods
kubectl get --raw /apis/metrics.k8s.io/v1beta1/pods

# list all events in the default namespace
kubectl get events

# list all events in all namespaces
kubectl get events --all-namespaces

# list all events in the 'kube-system' namespace
kubectl get events -n kube-system

# watch as events occur in real time in the default namespace
kubectl get events -w

# print the join command to join more nodes to the kubeadm cluster
sudo kubeadm token create --print-join-command

# list the tokens that haven't expired yet for kubeadm clusters
sudo kubeadm token list

# generate a new token
sudo kubeadm token generate
```

</p>
</details>

### NAMESPACES & CONTEXT

<details><summary>show</summary>
<p>

```bash
# create namespace 'robot-shop'
kubectl create ns robot-shop

# list all namespaces in the cluster
kubectl get ns

# get the yaml config for all namespaces
kubectl get ns -o yaml

# list all kubernetes resources in all namespaces
kubectl get all --all-namespaces

# describe the namespace configuration
kubectl describe ns

# edit namespace 'robot-shop'
kubectl edit ns robot-shop

# delete namespace 'robot-shop'
kubectl delete ns robot-shop

# list all available contexts from kube config
kubectl config get-contexts

# get the current context for kubectl
kubectl config current-context

# switch context to a cluster named 'gkeCluster'
kubectl config set-context gkeCluster

# change context to a namespace named 'robot-shop' in the cluster named 'gkeCluster'
kubectl config set-context gkeCluster --namespace robot-shop

# change context to a user named 'admin' in the cluster named 'gkeCluster'
kubectl config set-context gkeCluster --user=admin

# set the default context to the cluster 'gkeCluster'
kubectl config use-context gkeCluster
```

</p>
</details>

### NODES

<details><summary>show</summary>
<p>

```bash
# list all nodes in the default namespace
kubectl get no

# same as previous, but with additional info (including IP address of nodes)
kubectl get no -o wide

# describe the configuration of all nodes in the cluster. Add the node name to the end in order to only get a specific node configuration (e.g. kubectl describe no node1)
kubectl describe no

# label node 'mynode1` with key 'disk' and value 'ssd'
kubectl label no mynode1 disk=ssd

# show labels for nodes in a cluster
kubectl get no --show-labels

# annotate node 'mynode1' with key 'azure', and value 'node'
kubectl annotate no mynode1 azure=node

# get the external IP addresses of all the nodes in the default namespace
kubectl get nodes -o jsonpath='{items[*].status.addresses[?(@.type=="ExternalIP")].addresses}'

# view the resource utilization (CPU, memory) of a node named 'mynode1'
kubectl top node mynode1

# taint node 'mynode1' with a key named 'node-role.kubernetes.io/master' and effect 'NoSchedule'
kubectl taint no mynode1 node-role.kubernetes.io/master:NoSchedule

# taint node 'mynode1' with a key named 'dedicated', a value of 'special-user' and an effect of 'NoSchedule'
kubectl taint no mynode1 dedicated=special-user:NoSchedule

# Remove taint from node 'mynode1' with key 'dedicated' and effect 'NoSchedule'
kubectl taint no mynode1 dedicated:NoSchedule-

# Remove taints with key 'dedicated' from node 'mynode1'
kubectl taint no mynode1 dedicated-

# list the taints applied to all nodes
kubectl describe no | grep Taint

# list the taints on all nodes in the cluster
kubectl get nodes -o=custom-columns=NODE:.metadata.name,KEY:.spec.taints[*].key,VALUE:.spec.taints[*].value,EFFECT:.spec.taints[*].effect

# taint nodes with the label 'disk=ssd' with key 'dedicated'
kubectl taint no -l disk=ssd dedicated=mynode1:PreferNoSchedule

# taint node 'mynode1' with key 'bar' and no value
kubectl taint no mynode1 bar:NoSchedule

# drain node 'mynode1', in order to remove any scheduled pods while also ensuring no pods are scheduled to it
kubectl drain mynode1 --ignore-daemonsets --force

# cordon node 'mynode1', to ensure no pods are scheduled to it
kubectl cordon mynode1

# uncordon node 'mynode1', to resume scheduling pods to the node
kubectl uncordon mynode1

# delete node 'mynode1' from the cluster
kubectl delete no mynode1

# edit the configuration of 'mynode1'
kubectl edit no mynode1
```

</p>
</details>

### PODS

<details><summary>show</summary>
<p>

```bash
# create pod 'nginx' using the 'nginx' image
kubectl run nginx --image=nginx

# create pod 'busybox', open a shell inside of the container, and delete pod when exit shell
kubectl run busybox --image=busybox --rm -it -- sh

# create a pod yaml file named pod.yml
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yml

# list all pods in the default namespace
kubectl get po

# list all pods in all namespaces
kubectl get po --all-namespaces

# list all kubernetes resources in all namespaces
kubectl get all --all-namespaces

# list all pods, nodes and services in all namespaces
kubectl get po,no,svc --all-namespaces

# same as above but return additional info (e.g. node assignment)
kubectl get po -o wide

# describe the configuration of all pods in the default namespace
kubectl describe po

# give pod 'nginx' a label of 'app=prod'
kubectl label nginx app=prod

# show the labels for all pods in the default namespace
kubectl get po --show-labels

# show pods with a label of 'app=nginx'
kubectl get po -l app=nginx

# annotate pod 'nginx' with key 'special', and value of 'app1'
kubectl annotate po nginx special=app1

# show the yaml output for the pod named nginx
kubectl get po nginx -o yaml

# export the yaml manifest of a pod named 'nginx' to a file named 'podconfig.yml'
kubectl get pod nginx -o yaml --export > podconfig.yml

# list all the pods that are running
kubectl get po --field-selector status.phase=Running

# run 'mongo' command inside terminal in pod 'mongodb'
kubectl exec -it mongodb mongo

# list environment variables in pod 'nginx'
kubectl exec nginx env

# open shell to container 'cart' in pod 'mypod'
kubectl exec -it mypod -c cart -- /bin/bash

# get the log output for a pod named 'nginx' in the default namespace
kubectl logs nginx

# same as above but output to a file named 'pod.log'
kubectl logs nginx > pod.log

# get the last hour of log output for a pod named 'nginx'
kubectl logs nginx --since=1h

# get the last 20 lines of a log output for a pod named 'nginx'
kubectl logs nginx --tail=20

# get the streaming log output for a container named 'log' in a pod named 'nginx'
kubectl logs -f nginx -c log

# delete pod 'nginx'
kubectl delete po nginx

# edit the configuration of pod 'nginx'
kubectl edit po nginx
```

</p>
</details>

### DEPLOYMENT & REPLICASETS

<details><summary>show</summary>
<p>

```bash
# create a new deployment named 'nginx' using the image 'nginx'
kubectl create deploy nginx --image nginx

# create a deployment yaml file named deploy.yml
kubectl create deploy nginx --image nginx --dry-run=client -o yaml > deploy.yml

# create deployment from file
kubectl create -f deploy.yml

# create deployment and record history (useful for viewing rollout history later)
kubectl create -f deploy.yml --record

# apply the yaml configuration if resource already exists (will create resource if none exists)
kubectl apply -f deploy.yml

# apply the yaml configuration if resource already exists (will fail of no resource exists)
kubectl replace -f deploy.yml

# undo deployment rollout 
kubectl rollout undo deploy nginx

# undo rollout to a specific version
kubectl rollout undo deploy nginx --to-revision=3

# pause deployment while rolling out (good for canary releases)
kubectl rollout pause deploy nginx 

# resume rollout after pause
kubectl rollout resume deploy nginx

# get status of rollout
kubectl rollout status deployment/nginx

# get rollout history
kubectl rollout history deploy nginx

# scale deployment 'nginx' up to 5 replicas
kubectl scale deploy nginx --replicas=5

# set a new image for the deployment with verbose output
kubectl set image deployments/nginx app=nginx:1.14.2 --v 6

# edit deployment 'nginx'
kubectl edit deploy nginx

# list all deployments in the default namespace
kubectl get deploy

# list all deployments in all namespaces
kubectl get deploy --all-namespaces

# list all kubernetes resources in all namespaces
kubectl get all --all-namespaces

# list all pods, nodes and services in all namespaces
kubectl get po,no,svc --all-namespaces

# same as above but get additional information (e.g. labels)
kubectl get deploy -o wide

# show the yaml manifest for all deployments in the default namespace
kubectl get deploy -o yaml

# describe the configuration for all deployments in the default namespace
kubectl describe deploy

# delete deployment 'nginx'
kubectl delete deploy nginx

# list all replicasets in the default namespace
kubectl get rs

# same as above but output more information (e.g. selectors)
kubectl get rs -o wide

# output the yaml manifest for all replicasets in the default namespace
kubectl get rs -o yaml

# describe the configuration of all replicasets in the default namespace
kubectl describe rs
```

</p>
</details>

### SERVICES

<details><summary>show</summary>
<p>

```bash
# create nodePort type service 'nodeport-svc' in default namespace, exposing port 8080 from the container port 80
kubectl create svc nodeport nodeport-svc --tcp=8080:80

# create a nodePort service 'app-service' from exposing deployment 'nginx'
kubectl expose deploy nginx --name=app-service --port=80 --type=NodePort

# create a load balancer type service from a deployment
kubectl expose deploy nginx --port 80 --target-port 80 --type LoadBalancer

# list all services in the default namespace
kubectl get svc

# same as above but get additional info (e.g. selectors)
kubectl get svc -o wide

# list all kubernetes resources in all namespaces
kubectl get all --all-namespaces

# list all pods, nodes and services in all namespaces
kubectl get po,no,svc --all-namespaces

# show the yaml manifest for all services in the default namespace
kubectl get svc -o yaml

# list configuration info and events for all services in the default namespace
kubectl describe svc

# show the labels on all services in the default namespace
kubectl get svc --show-labels

# edit service 'app-service' in the default namespace
kubectl edit svc app-service

# delete service 'app-service' in the default namespace
kubectl delete svc app-service
```

</p>
</details>

### ROLES & SERVICE ACCOUNTS

<details><summary>show</summary>
<p>

```bash
# list all roles in the 'kube-system' namespace
kubectl get roles -n kube-system

# output the yaml manifests for all roles in the 'kube-system' namespace
kubectl get roles -n kube-system -o yaml

# list all cluster roles
kubectl get clusterroles

# create a role named 'pod-reader' that can get, watch and list pods in the default namespace
kubectl create role pod-reader --verb=get --verb=list --verb=watch --resource=pods

# create a cluster role named 'pod-reader' that can get, watch and list pods
kubectl create clusterrole pod-reader --verb=get,list,watch --resource=pods

# give the user 'bob' permission in the 'admin' cluster role in the namespace 'robot-shop'
kubectl create rolebinding bob-admin-binding --clusterrole=admin --user=bob --namespace=robot-shop

# Across the entire cluster, grant the permissions in the "admin" ClusterRole to a user named 'bob'
kubectl create clusterrolebinding root-cluster-admin-binding --clusterrole=admin --user=bob

# list all service accounts in the default namespace
kubectl get sa

# view the yaml manifest for all service accounts in the default namespace
kubectl get sa -o yaml

# output the yaml manifest for a service account named 'default' to a file named 'sa.yml'
kubectl get sa default -o yaml > sa.yml

# replace the current service account named 'default' with a service account from a yaml manifest named 'sa.yml'
kubectl replace sa default -f sa.yml

# edit service account 'default' in the default namespace
kubectl edit sa default

# delete service account 'default' in the default namespace
kubectl delete sa default
```

</p>
</details>

### CONFIGMAPS & SECRETS

<details><summary>show</summary>
<p>

```bash
# list all the configmaps in the default namespace
kubectl get cm

# list all the configmaps in all namespaces
kubectl get cm --all-namespaces

# output the yaml manifest for all configmaps in all namespaces
kubectl get cm --all-namespaces -o yaml

# list all secrets in the default namespace
kubectl get secrets

# list all secrets in all namespaces
kubectl get secrets --all-namespaces

# output the yaml manifest for all secrets in all namespaces
kubectl get secrets --all-namespaces -o yaml

```

</p>
</details>

### DAEMONSETS

<details><summary>show</summary>
<p>

```bash
# list all daemonsets in the default namespace
kubectl get ds

# list all daemonsets in all namespaces (including in the 'kube-system' namespace)
kubectl get ds --all-namespaces

# describe the configuration for a daemonset named 'kube-proxy' in the 'kube-system' namespace
kubectl describe ds kube-proxy -n kube-system

# output the yaml manifest for a daemonset named 'kube-proxy' in the 'kube-system' namespace
kubectl get ds kube-proxy -n kube-system -o yaml

# edit daemonset 'kube-proxy' in the kube-system namespace
kubectl edit ds kube-proxy -n kube-system

# edit daemonset 'kube-proxy' in the kube-system namespace
kubectl edit ds kube-proxy -n kube-system

# delete daemonset 'kube-proxy' in the kube-system namespace
kubectl delete ds kube-proxy -n kube-system

```

</p>
</details>

### VOLUMES & STORAGE CLASS INFO

<details><summary>show</summary>
<p>

```bash
# list all persistent volumes in the default namespace
kubectl get pv

# get detailed configuration info for all persistent volumes in the default namespace
kubectl describe pv

# list all persisten volume claims in the default namespace
kubectl get pvc

# get detailed configuration info for all persistent volume claims in the default namespace
kubectl describe pvc

# list all storage class resources in the default namespace
kubectl get svc

# output the yaml manifest for all storage class resources in the default namespace
kubectl get sc -o yaml

```

</p>
</details>
