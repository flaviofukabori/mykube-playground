# minikube start --insecure-registry "10.0.0.0/24"

kubectl create namespace kafka

kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka

kubectl get pod -n kafka --watch

# Apply the `Kafka` Cluster CR file 
kubectl apply -f https://strimzi.io/examples/latest/kafka/kafka-persistent-single.yaml -n kafka 

kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka 

# Send and receive messages
# With the cluster running, run a simple producer to send messages to a Kafka topic (the topic is automatically created):
kubectl -n $NAMESPACE run kafka-producer -ti --image=quay.io/strimzi/kafka:0.32.0-kafka-3.3.1 --rm=true --restart=Never -- bin/kafka-console-producer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic my-topic

# And to receive them in a different terminal, run:
kubectl -n $NAMESPACE run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.32.0-kafka-3.3.1 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic my-topic --from-beginning

kubectl -n $NAMESPACE run kafka-topics -ti --image=quay.io/strimzi/kafka:0.32.0-kafka-3.3.1 --rm=true --restart=Never -- bin/kafka-topics.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --list

# list topics
kafka-topics.sh --bootstrap-server localhost:9092 --list
kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic first_topic

# send messages to topics, external from k8s strimzi cluster
kubectl get service my-cluster-kafka-external-bootstrap -o=jsonpath='{.spec.ports[0].nodePort}{"\n"}' -n kafka\
kubectl get node minikube -o=jsonpath='{range .status.addresses[*]}{.type}{"\t"}{.address}{"\n"}'
bin/kafka-console-producer.sh --broker-list 192.168.64.9:31822 --topic flavio-topic
bin/kafka-console-consumer.sh --bootstrap-server 192.168.64.9:31822 --topic flavio-topic --from-beginning 

# examples
https://github.com/strimzi/strimzi-kafka-operator/tree/0.32.0/examples

# kafka connect

