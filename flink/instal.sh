#
minikube start --kubernetes-version=v1.25.3

export NAMESPACE=flink
kubectl create ns $NAMESPACE

#Install the certificate manager on your Kubernetes cluster to enable adding the webhook component (only needed once per Kubernetes cluster):
kubectl create -f https://github.com/jetstack/cert-manager/releases/download/v1.8.2/cert-manager.yaml

#Now you can deploy the selected stable Flink Kubernetes Operator version using the included Helm chart:
helm repo add flink-operator-repo https://downloads.apache.org/flink/flink-kubernetes-operator-1.4.0/
helm install flink-kubernetes-operator flink-operator-repo/flink-kubernetes-operator

helm list

#Once the operator is running as seen in the previous step you are ready to submit a Flink job:
kubectl create -f https://raw.githubusercontent.com/apache/flink-kubernetes-operator/release-1.4/examples/basic.yaml

#You may follow the logs of your job, after a successful startup (which can take on the order of a minute in a fresh environment, seconds afterwards) you can:
kubectl logs -f deploy/basic-example

#To expose the Flink Dashboard you may add a port-forward rule or look the ingress configuration options:
kubectl port-forward svc/basic-example-rest 8081
#Now the Flink Dashboard is accessible at localhost:8081.

#In order to stop your job and delete your FlinkDeployment you can:
kubectl delete flinkdeployment/basic-example