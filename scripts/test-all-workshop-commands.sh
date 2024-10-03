#!/bin/bash
./01-01-example-curls.sh
./01-02-example-curls-restricted.sh
./01-03-example-curls-restricted-nodrift.sh
./01-04-example-curls-restricted-nomalware.sh
#kubectl apply -f ./security-playground-irsa.yaml
#kubectl apply -f ./security-playground-aws-env-vars.yaml
#sleep 10
#export S3_BUCKET_NAME=bucket
#./02-01-example-curls-bucket-public.sh
#export SECURE_API_TOKEN=token
#./sysdig-cli-scanner -a app.au1.sysdig.com logstash:7.16.1
#./sysdig-cli-scanner -a app.au1.sysdig.com --iac example-scenarios/k8s-manifests/04-security-playground-deployment.yaml
./06-01-example-curls-networkpolicy.sh
kubectl apply -f ./generated-network-policy.yml
sleep 10
./06-01-example-curls-networkpolicy.sh
kubectl logs --since=5m deployment/hello-client-blocked -n hello
kubectl logs --since=5m deployment/hello-client -n hello
kubectl apply -f ./generated-network-policy2.yml
sleep 10
./01-01-example-curls.sh
