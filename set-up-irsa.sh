#!/usr/bin/env bash
# Script to configure IRSA for the security-playground SA
SERVICE_ACCOUNT_NAME="irsa"
NAMESPACE="security-playground"
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
IAM_ROLE_NAME="irsa-$EKS_CLUSTER_NAME"
echo "Creating IAM role $IAM_ROLE_NAME"
cat > ./scripts/serviceaccount.yaml << EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::$AWS_ACCOUNT_ID:role/$IAM_ROLE_NAME
  labels:
    app.kubernetes.io/name: $SERVICE_ACCOUNT_NAME
  name: $SERVICE_ACCOUNT_NAME
  namespace: $NAMESPACE
EOF
kubectl apply -f ./scripts/serviceaccount.yaml
kubectl delete -n $NAMESPACE deploy security-playground
kubectl apply -f ./scripts/security-playground-irsa.yaml
