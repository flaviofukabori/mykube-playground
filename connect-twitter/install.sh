#https://github.com/scholzj/DoK-Day-KubeCon-EU-2022/

cd $HOME/Documents/estudos/kubernetes/mykube-project/

minikube start --insecure-registry "10.0.0.0/24"

minikube addons enable registry

export NAMESPACE=connect-twitter

kubectl create ns $NAMESPACE

kubectl create -f 'https://strimzi.io/install/latest?namespace='"$NAMESPACE" -n $NAMESPACE

kubectl -n $NAMESPACE create -f connect-twitter/00-secret-twitter.yaml

kubectl -n $NAMESPACE create -f connect-twitter/01-kafka.yaml

# get minikube registry IP
export MY_REGISTRY=$(kubectl -n kube-system get svc registry -o jsonpath='{.spec.clusterIP}')
#output 10.106.214.168

cat connect-twitter/02-connect.yaml | envsubst | kubectl -n $NAMESPACE apply -f - 

kubectl -n $NAMESPACE create -f connect-twitter/10-search.yaml

kubectl -n $NAMESPACE run kafka-topics -ti --image=quay.io/strimzi/kafka:0.32.0-kafka-3.3.1 --rm=true --restart=Never

kubectl -n $NAMESPACE run kafka-topics -ti --image=quay.io/strimzi/kafka:0.32.0-kafka-3.3.1 --rm=true --restart=Never -- bin/kafka-topics.sh --bootstrap-server my-cluster-kafka-bootstrap:9095 --list

kubectl -n $NAMESPACE run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.32.0-kafka-3.3.1 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9095 --topic twitter-inbox --from-beginning

#chmod o+rw twitter-inbox.txt
