.PHONY: deploy

deploy:
	docker stack deploy -c docker-compose.yml portfolio