# https://debezium.io/documentation/reference/stable/operations/kubernetes.html#_creating_secrets_for_the_database

minikube start --insecure-registry "10.0.0.0/24"

minikube addons enable registry

export NAMESPACE=debezium-example
kubectl create ns $NAMESPACE

# strimzi operator
kubectl create -f 'https://strimzi.io/install/latest?namespace='"$NAMESPACE" -n $NAMESPACE

# secrets
kubectl apply -f debezium/secrets.yaml -n $NAMESPACE

kubectl apply -f debezium/roles.yaml -n $NAMESPACE
kubectl apply -f debezium/role-binding.yaml -n $NAMESPACE

# kafka
kubectl apply -f debezium/kafka.yaml -n $NAMESPACE

kubectl apply -f debezium/mysql.yaml -n $NAMESPACE

# get minikube registry IP
kubectl -n kube-system get svc registry -o jsonpath='{.spec.clusterIP}'
#output 10.106.214.168
kubectl apply -f debezium/kafka-connect-build.yaml -n $NAMESPACE

kubectl apply -f debezium/kafka-connector.yaml -n $NAMESPACE

# Verifying the Deployment
kubectl -n $NAMESPACE get kctr debezium-connector-mysql -o yaml
#To verify the everything works fine, you can e.g. start watching mysql.inventory.customers Kafka topic:

$ kubectl run -n $NAMESPACE -it --rm --image=quay.io/debezium/tooling:1.2  --restart=Never watcher -- kcat -b debezium-cluster-kafka-bootstrap:9092 -C -o beginning -t mysql.inventory.customers

#Connect to the MySQL database:

$ kubectl run -n $NAMESPACE -it --rm --image=mysql:8.0 --restart=Never --env MYSQL_ROOT_PASSWORD=debezium mysqlterm -- mysql -hmysql -P3306 -uroot -pdebezium

#Do some changes in the customers table:

sql> update customers set first_name="Sally Marie" where id=1001;

#You now should be able to observe the change events on the Kafka topic:

{
...
  "payload": {
    "before": {
      "id": 1001,
      "first_name": "Sally",
      "last_name": "Thomas",
      "email": "sally.thomas@acme.com"
    },
    "after": {
      "id": 1001,
      "first_name": "Sally Marie",
      "last_name": "Thomas",
      "email": "sally.thomas@acme.com"
    },
    "source": {
      "version": "{debezium-version}",
      "connector": "mysql",
      "name": "mysql",
      "ts_ms": 1646300467000,
      "snapshot": "false",
      "db": "inventory",
      "sequence": null,
      "table": "customers",
      "server_id": 223344,
      "gtid": null,
      "file": "mysql-bin.000003",
      "pos": 401,
      "row": 0,
      "thread": null,
      "query": null
    },
    "op": "u",
    "ts_ms": 1646300467746,
    "transaction": null
  }
}


