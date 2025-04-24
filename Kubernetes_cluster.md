# 1. Set up 3 ec2 in AWS console and run the following commands in all the nodes.
```
sudo apt-get update -y

sudo apt install docker.io -y
sudo chmod 666 /var/run/docker.sock

sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
```
```
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```
```
sudo apt-get update -y
sudo apt-get install -y kubelet=1.29.1-1.1 kubeadm=1.29.1-1.1 kubectl=1.29.1-1.1
```
# 2. Run the below commands only on master node

```
sudo kubeadm init
```
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

# 3. Run the commands to install calico in master node
```
curl https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/calico.yaml -O
```
```
kubectl apply -f calico.yaml
```

# 4. For continous delpoyment to in the jenkins server.
* Create service Account
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: webapps
```
* Create Role
```
apiVersion: rbac.authorization.k9s.io/v1
kind: Role
metadata:
  name: app-role
  namespace: webapps
rules:
  - apiGroups:
        - ""
        - apps
        - autoscaling
        - batch
        - extensions
        - policy
        - rbac.authorization.k8s.io
    resources:
        - pods
        - componentstatuses
        - configmaps
        - daemonsets
        - deployments
        - events
        - endpoints
        - horizontalpodautoscalers
        - ingress
        - jobs
        - limitranges
        - namespaces
        - nodes
        - pods
        - persistentvolumes
        - persistentvolumeclaims
        - resourceqoutas
        - replicasets
        - replicationcontrollers
        - serviceaccounts
        - services
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```
* Create Bind
```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-rolebinding
  namespace: webapps
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: app-role
subjects:
  - namespace: webapps
    kind: ServiceAccount
    name: jenkins
```
* Create secret
```
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: mysec
  annotations:
    kubernetes.io/service-account.name: jenkins
```
* To create secret run the below command
```
kubectl apply -f sec.yaml -n webapps
```
# 5. To integrate the k8s cluster in jenkins pipeline
```
kubectl describe secret <secret-name> -n webapps
```
