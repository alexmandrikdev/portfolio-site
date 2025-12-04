.PHONY: deploy debug-on debug-off debug-status

deploy:
	docker stack deploy -c docker-compose.yml portfolio

debug-on:
	docker service update --env-add WORDPRESS_DEBUG=1 portfolio_wordpress

debug-off:
	docker service update --env-rm WORDPRESS_DEBUG portfolio_wordpress

debug-status:
	docker service inspect --format '{{range .Spec.TaskTemplate.ContainerSpec.Env}}{{println .}}{{end}}' portfolio_wordpress | grep WORDPRESS_DEBUG || echo "WORDPRESS_DEBUG not set"