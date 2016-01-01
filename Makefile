NAME=glynjackson/django-beanstalk-tutorial
VERSION=`git describe --abbrev=0 --tags`
BRANCH=`git rev-parse --abbrev-ref HEAD`
CONTAINER_IP=$(shell echo $(docker-machine ip default))

ifeq ($(shell echo $(BRANCH)),master)
	TAG='latest'
else
	TAG=$(VERSION)
endif

NO_COLOR=\033[0m
OK_COLOR=\033[32;01m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m

OK_STRING=$(OK_COLOR)[OK]$(NO_COLOR)
IP_STRING=$(OK_COLOR)$$(docker-machine ip default):80$(NO_COLOR)
ERROR_STRING=$(ERROR_COLOR)[ERRORS]$(NO_COLOR)
WARN_STRING=$(WARN_COLOR)[WARNINGS]$(NO_COLOR)

AWK_CMD = awk '{ printf "%-30s %-10s\n",$$1, $$2; }'
PRINT_ERROR = printf "$@ $(ERROR_STRING)\n" | $(AWK_CMD) && printf "$(CMD)\n$$LOG\n" && false
PRINT_WARNING = printf "$@ $(WARN_STRING)\n" | $(AWK_CMD) && printf "$(CMD)\n$$LOG\n"
PRINT_OK = printf "$@ $(OK_STRING)\n" | $(AWK_CMD)
PRINT_IP = printf "$@ $(IP_STRING)\n" | $(AWK_CMD)
BUILD_CMD = LOG=$$($(CMD) 2>&1) ; if [ $$? -eq 1 ]; then $(PRINT_ERROR); elif [ "$$LOG" != "" ] ; then $(PRINT_WARNING); else $(PRINT_OK); fi;


help:
	@echo "*******************************************************"
	@echo "Please use \`make <action>' where <action> is one of:"
	@echo "*******************************************************"
	@echo " container       to build and start a local container."
	@echo " app             to prepare and build image."
	@echo " pull            to pull from Docker Hub."
	@echo " run             to run a container already pulled."
	@echo " prepare         to create local git archive."
	@echo " clean           to remove git archive and containers."
	@echo " push            to push to Docker Hub."
	@echo " ip              to display IP:PORT of default container."
	@echo " delete_images   to deletes all images."
	@echo "*******************************************************"

# Pulls a build of the app and starts a local container.
container: pull run ip
	@$(PRINT_OK)

# Build and pushes the app to Docker Hub.
app: prepare build clean
	@$(PRINT_OK)

pull:
	docker pull $(NAME):$(TAG)
	@$(PRINT_OK)

run:
	docker run --env-file docker/env.conf -p 80:8002 -d $(NAME):$(TAG)
	@$(PRINT_OK)

prepare:
	git archive -o docker/mysite.tar HEAD
	@$(PRINT_OK)

build:
	docker build -t $(NAME):$(TAG) --rm docker
	@$(PRINT_OK)

clean:

	rm -f docker/mysite.tar
	docker rm -f $$(docker ps -a -q)
	@$(PRINT_OK)

push:
	docker push $(NAME):$(TAG)

.PHONY: ip
ip:
	 @$(PRINT_IP)

delete_images:
	docker rmi -f $$(docker images -q)
	@$(PRINT_OK)
