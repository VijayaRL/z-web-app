install:
	helm upgrade --cleanup-on-fail --install web-app . \
	--namespace web-app --create-namespace \
	--values values.yaml

uninstall:
	helm uninstall web-app --namespace web-app