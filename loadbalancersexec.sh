#!/bin/bash
kubectl apply -f ballot/ballot.yaml -n $ROOST_NAMESPACE

sleep 5

ballot_loadbalancer=$(kubectl get svc -n $ROOST_NAMESPACE | grep ballot | awk '{print $4}')
echo "ballot: $ballot_loadbalancer"
kubectl apply -f ecserver/ecserver.yaml -n $ROOST_NAMESPACE

sleep 5

ecserver_loadbalancer=$(kubectl get svc -n $ROOST_NAMESPACE | grep ecserver | awk '{print $4}')
echo "ecserver: $ecserver_loadbalancer"
sed -i -e "s#REACT_APP_BALLOT_ENDPOINT_VALUE#${ballot_loadbalancer}:8080#" -e "s#REACT_APP_EC_SERVER_ENDPOINT_VALUE#${ecserver_loadbalancer}:8081#" voter/voter.yaml

kubectl apply -f voter/voter.yaml -n $ROOST_NAMESPACE

sleep 5

sed -i -e "s#EC_SERVER_ENDPOINT_VALUE#${ecserver_loadbalancer}:8081#" election-commission/ec.yaml

kubectl apply -f election-commission/ec.yaml -n $ROOST_NAMESPACE
