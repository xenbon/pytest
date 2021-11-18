#!/usr/bin/env sh

set -x
docker run -u root -d --rm -p 5000:5000 --name thecon -v /var/run/docker.sock:/var/run/docker.sock -v "$HOME":/home theimg
set +x

set -x
nohup flask run & sleep 1
echo $! > .pidfile
set +x

echo 'Now...'
echo 'Visit http://localhost:5000 to see your application in action.'
