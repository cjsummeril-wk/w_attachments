#!/bin/bash

if [ -z "$GIT_BRANCH" ]
then
	echo "GIT_BRANCH environment variable not set, skipping codecov push"
else
	TRACKING_REMOTE="$(git for-each-ref --format='%(upstream:short)' $(git symbolic-ref -q HEAD) | cut -d'/' -f1 | xargs git ls-remote --get-url | cut -d':' -f2 | sed 's/.git$//')"
	bash <(curl -s https://codecov.workiva.net/bash) -u https://codecov.workiva.net -t $CODECOV_TOKEN -B $GIT_BRANCH -r $TRACKING_REMOTE
fi
