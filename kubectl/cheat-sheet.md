# Kubectl Cheat Sheet

### CLUSTER INFO & EVENTS

<details><summary>show</summary>
<p>

```bash
# bash autocomplete for kubectl commands
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc

# zsh autocompletion for kubectl commands
source <(kubectl completion zsh)
echo "source <(kubectl completion zsh)" >> ~/.zshrc

# use two kubeconfig files named 'config' and 'kubeconfig2' at the same time
export KUBECONFIG=kubeconfig1:kubeconfig2:kubeconfig3:kubeconfig4

# flatten kubeconfig and save to ~/.kube directory as a file named config
kubectl config view --flatten > ~/.kube/config

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

# list namespaces resources in the kubernetes cluster
kubectl api-resources --namespaced=true

# list non-namespaced resources in the kubernetes cluster
kubectl api-resources --namespaced=false

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

# in a multi-control-plane setup, find the elected leader (in annotations)
kubectl get ep kube-scheduler -n kube-system -o yaml

# verify version of kubeadm
kubeadm version

# view all default values that kubeadm uses to initialize the cluster (with kubeadm init)
kubeadm config print init-defaults

# print the join command to join more nodes to the kubeadm cluster
sudo kubeadm token create --print-join-command

# list the tokens that haven't expired yet for kubeadm clusters
sudo kubeadm token list

# generate a new token
sudo kubeadm token generate

# verify the cluster components can be upgraded via kubeadm
kubeadm upgrade plan

# upgrade the local kubelet configuration
sudo kubeadm upgrade node

# view enabled admission controllers
kubectl exec kube-apiserver-kind-control-plane -n kube-system -- kube-apiserver -h | grep enable-admission-plugins

# view enabled and disabled admission controllers
ps -ef | grep kube-apiserver | grep admission-plugins
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

-OR-

kubectl get all -A

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

# set context to the current context including webapp namespace
kubectl config set-context --current --namespace webapp

# change context to a namespace named 'robot-shop' in the cluster named 'gkeCluster'
kubectl config set-context gkeCluster --namespace robot-shop

# change context to a user named 'admin' in the cluster named 'gkeCluster'
kubectl config set-context gkeCluster --user=admin

# set the default context to the cluster 'gkeCluster'
kubectl config use-context gkeCluster

# delete a cluster named 'docker-desktop' from kubeconfig
kubectl config delete-cluster docker-desktop
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

# list nodes with the label kubernetes.io/control-plane (NOTE: You may have to show node labels, depending on the bootstrapper)
kubectl get no -l node-role.kubernetes.io/control-plane

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

# get the name of the first node ([0]) only, in the list of nodes, using jsonpath
kubectl get no -o jsonpath='{.items[0].metadata.name}'

# view the resource utilization (CPU, memory) of a node named 'mynode1'
kubectl top node mynode1

# view taints on all nodes
kubectl get no -o json | jq '.items[].spec.taints'

# view taints with node node names
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[?(@.effect=='NoSchedule')].effect}{\"\n\"}{end}"

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

# run a temporary pod (deleted when exit) and open a shell inside the container
kubectl run curlpod --image=nicolaka/netshoot --rm -it -- sh

# run a pod to troubleshoot dns and get a shell to it
kubectl run dnstools --image infoblox/dnstools --rm -it -- bash

# start a pod named 'debug-pod' and get a shell to the container (keeping it running after exit)
kubectl run debug-pod --image=busybox -it

# run a pod to test networking using curl
kubectl run --rm -i -tty curl --image=curlimages/curl --restart=Never -- sh

# create a pod yaml file named pod.yml
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yml

# list all pods in the default namespace
kubectl get po

# continuously list all pods in all namespaces with wait flag
kubectl get po -A -w

# list all ready pods that have the label app=nginx
kubectl wait --for=condition=ready pod -l app=nginx

# list all pods in all namespaces
kubectl get po --all-namespaces

# list all pods in all namespaces with a wide output (showing pod IP addresses) and selecting only one node by it's name using field selectors
kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName=kind-control-plane

# list all pods in the kube-system namespace and sort by node name
kubectl get po -o custom-columns=POD:metadata.name,NODE:spec.nodeName --sort-by spec.nodeName -n kube-system

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

# In a running pod named 'bux', issue a command inside the container that will echo hello in a loop
kubectl exec -it bux -- sh -c "while true; do echo hello; sleep 2; done"

# create new temporary pod (deletes upon exit) and get dns info
kubectl run curlpod --image=nicolaka/netshoot --rm -it --restart=Never -- cat /etc/resolv.conf

# create new pod named "netshoot" using image "nicolaka/netshoot" and inserts sleep command to keep it running
kubectl run netshoot --image=nicolaka/netshoot --command sleep --command "3600"

# get dns info from a pod that's already running
kubectl exec –t nginx – cat /etc/resolv.conf

# get the log output for a pod named 'nginx' in the default namespace
kubectl logs nginx

# get the log output for a pods with the label 'app=nginx' in the default namespace
kubectl logs -l app=nginx

# same as above but output to a file named 'pod.log'
kubectl logs nginx > pod.log

# get the last hour of log output for a pod named 'nginx'
kubectl logs nginx --since=1h

# get the last 20 lines of a log output for a pod named 'nginx'
kubectl logs nginx --tail=20

# get the streaming log output for a container named 'log' in a pod named 'nginx'
kubectl logs -f nginx -c log

# tail the logs from a pod named 'nginx' that has one container
kubectl logs nginx -f

# tail the logs from a pod named 'nginx' that has one container
kubectl logs nginx --follow

# delete pod 'nginx'
kubectl delete po nginx

# edit the configuration of pod 'nginx'
kubectl edit po nginx

# port forward from 80 on the container to 8080 on the host (your laptop)
kubectl port-forward nginx 8080:80

# port forward from 9200 on the container to 9200 on the host but run it in the background, so you can get your prompt back
kubectl port-forward elasticsearch-pod 9200:9200 &

# after port forwarding, you can curl the port on localhost
curl --head http://localhost:9200
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

# restart pods in a deployment
kubectl rollout restart deployment/nginx

# get rollout history
kubectl rollout history deploy nginx

# scale deployment 'nginx' up to 5 replicas
kubectl scale deploy nginx --replicas=5

# scale deployment named 'nginx' down to 3 and record it into rollout history
kubectl scale deploy nginx --replicas 3 --record

# get rollout history of deployment nginx
kubectl rollout history deploy nginx

# set a new image for the deployment with verbose output
kubectl set image deployments/nginx nginx=nginx:1.14.2 --v 6

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

# create a load balancer type service named 'nginx' from a deployment
kubectl expose deploy nginx --port 80 --target-port 80 --type LoadBalancer

# Create a second service based on the above service, exposing the container port 8443 as port 443 with the name "nginx-https"
kubectl expose svc nginx --name nginx-https --port 443 --target-port 8443

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

# Create an ingress named 'cool-ing' that takes requests to mycoolwebapp.com/forums to our service named forums-svc on port 8080 with a tls secret "my-cert"
kubectl create ingress cool-ing --rule="mycoolwebapp.com/forums=forums-svc:8080,tls=my-cert"

# Create an ingress named 'one-ing' that takes all requests to a service named 'myweb-svc' on port 80
kubectl create ingress one-ing --rule="/path=myweb-svc:80"

# Create an ingress named 'appgw-ing' that adds an annotation for azure application gateways and forwards to 'azurewebapp.com/shop' to our service named 'web-svc' on port 8080
kubectl create ingress appgw-ing --rule="azurewebapp.com/shop=web-svc:8080" --annotation kubernetes.io/ingress.class=azure/application-gateway

# Create an ingress named 'rewir-ing' with an annotation to rewrite the path for nginx ingress controllers
kubectl create ingress rewire-ing --rule="circuitweb.com/shop=web-svc:8080" --annotation "nginx.ingress.kubernetes.io/rewrite-target= /"

# Create an ingress named 'moo-ing' where all requests going to service 'milk-svc' on port 80 but requests for 'moo.com/flavors' go to service 'flavor-svc' on port 8080
kubectl create ingress moo-ing --rule="moo.com/=milk-svc:80" --rule="moo.com/flavors=flavor-svc:8080"

# Create an ingress named 'rid-ing' where any requests with prefix 'bikepath.com/seats*' go to service 'seats-svc' on port 8080 and any requests with prefix 'bikepath.com/tires*' go to service 'tires-svc' on port 80 (http)
kubectl create ingress rid-ing --rule="bikepath.com/seats*=seats-svc:8080" --rule="bikepath.com/tires*=tires-svc:http"

# Create an ingress named 'soup-ing' with TLS enabled for all requests going to service 'soup-svc' on port 443 and any requests with a prefix 'mysoupwebsite.com/stew/carrot*' going to service 'carrots-svc' on port 8080
kubectl create ingress soup-ing --rule="mysoupwebsite.com/=soup-svc:https,tls" --rule="mysoupwebsite.com/stew/carrot*=carrots-svc:8080"

# Create an ingress named 'ssh-ing' with TLS enabled where all path requests go to service 'shh-svc' on port 8080 and use a secret named 'ssh-ertificate'
kubectl create ingress shh-ing --rule="lookapassword.com/*=shh-svc:8080,tls=shh-ertificate"

# Create an ingress named 'back-ing' with a default backend that goes to the service 'backdoor-svc' over port 80 and requests for any path at 'floorsdrawersdoors.com' go to service 'front-svc' on port 8080 and use secret named 'knock-knock'
kubectl create ingress back-ing --default-backend=backdoor-svc:http --rule="floorsdrawersdoors.com/*=front-svc:8080,tls=knock-knock"
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

# Get the clusterrole membership in system groups
kubectl get clusterrolebindings -o json | jq -r '.items[] | select(.subjects[0].kind=="Group") | select(.subjects[0].name=="system:masters")'

# Get the clusterrole membership by name only
kubectl get clusterrolebindings -o json | jq -r '.items[] | select(.subjects[0].kind=="Group") | select(.subjects[0].name=="system:masters") | .metadata.name'

# test authorization for user chad to view secrets in the default namespace
kubectl auth can-i get secrets --as chad -n default

# test if user chad has authorization to delete pods in the default namespace
kubectl auth can-i delete pods --as chad -n default

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

# create a secret named 'db-user-pass' from a file where the key name will be the name of the file
kubectl create secret generic db-user-pass --from-file=./username.txt --from-file=./password.txt

# create the username and password files from the previous command
echo -n 'admin' > ./username.txt
echo -n '1f2budjslkj8' > ./password.txt

# create a secret named 'db-user-pass' from a file and specify the name of the keys as 'username' and 'password'
kubectl create secret generic db-user-pass --from-file=username=./username.txt --from-file=password=./password.txt

# create a secret named 'vault-license' with the contents of an environment variable named 'secret' and set the key name to 'license'
kubectl create secret generic vault-license --from-literal="license=${secret}"

# create an environment variable named 'secret' and set it to the contents of a file named 'vault.hclic'
secret=$(cat valut.hclic)

# create a secret named 'vault-tls' that contains the certificate data for the CA (name of the file is ca) set to the key 'vault.ca',
# private key (name of the file is key) set to the key 'vault.key', and 
# PEM (name of the file is vault.example.com.pem) and set to the key 'vault.crt' for a valid tls certificate
kubectl create secret generic vault-tls --from-file=vault.key=key --from-file=vault.crt=vault.example.com.pem --from-file=vault.ca=ca

# list all secrets in the default namespace
kubectl get secrets

# list all secrets in all namespaces
kubectl get secrets --all-namespaces

# output the yaml manifest for all secrets in all namespaces
kubectl get secrets --all-namespaces -o yaml

# view the contents of a secret named db-user-pass
kubectl get secret db-user-pass -o jsonpath='{.data}'

# decode the password output from the previous command
echo 'MYyZDFUm2N2Rm' | base64 --decode

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

# view the volumes attached to nodes (non-namespaced)
kubectl get volumeattachments

```

</p>
</details>
