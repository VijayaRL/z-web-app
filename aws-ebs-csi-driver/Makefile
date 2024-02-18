# Set variables
REGION := us-east-1
EKS_CLUSTER := vrledu-dev

install:
	aws eks --region $(REGION) update-kubeconfig --name $(EKS_CLUSTER); \
	helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver; \
	helm repo update; \
	kubectl apply -f ebs-ns.yaml; \
	kubectl apply -f ebs-sc.yaml; \
	kubectl apply -f ebs-csi-controller-sa.yaml; \
    helm upgrade --install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
		--version=2.10.1 \
		--namespace ebs-csi-controller --create-namespace \
		--set controller.serviceAccount.create=false \
		--set controller.serviceAccount.name=ebs-csi-controller-sa \
		--set controller.nodeSelector.type=ondemand-m6a-xlarge \
		--set controller.extraVolumeTags.Project="${EKS_CLUSTER}"

uninstall:
	helm uninstall aws-ebs-csi-driver -n ebs-csi-controller