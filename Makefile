.PHONY: deploy

deploy:
	docker stack deploy -c docker-compose.yml portfolio

create-network:
	docker network create --driver overlay --attachable portfolio
