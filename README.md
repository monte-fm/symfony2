#Create container
```
docker run -i -t -d --name=symfony2 -h=symfony2 -p 1080:80 -p 1022:22 -p 9001:9000 cristo/symfony2 /bin/bash
```

#MySQL
```
user: root 
password: root
```
# SSH as docker user
```
ssh -p1022 docker@localhost
password: docker
```
# SSH as root
```
ssh -p1022 root@localhost
password: root
```
#NGINX server config file for communicate with docker
```
server {
        listen *:80;
        server_name localhost;
        proxy_set_header Host localhost;
        client_max_body_size 100M;

                location / {
                                proxy_set_header Host $host;
                                proxy_set_header X-Real-IP $remote_addr;
                                proxy_cache off;
                                proxy_pass http://localhost:1080;
                        }
}
```
#Code standard tests
Installed packets: 
http://phpmd.org/
https://github.com/squizlabs/PHP_CodeSniffer
https://github.com/sebastianbergmann/phpcpd

Now need to edit your build.xml file to allow start code-standart from ANT
``` 
    <target name="run-code-standards" depends="run-phpcs,run-phpcpd,run-phpmd" />
    <target name="run-phpcs">
        <exec dir="${basedir}" executable="phpcs" failonerror="true">
            <arg line="--encoding=utf-8 --extensions=php --standard=${confdir}/phpcs.xml --report=junit
                      --report-file=${reportdir}/phpcs.xml ${srcdir}"/>
        </exec>
    </target>

    <target name="run-phpmd">
        <exec dir="${basedir}" executable="phpmd" failonerror="true">
            <arg line="${srcdir} xml ${confdir}/phpmd.xml --reportfile ${reportdir}/phpmd.xml"/>
        </exec>
    </target>

    <target name="run-phpcpd">
        <exec dir="${basedir}" executable="phpcpd" failonerror="true">
            <arg line="--min-lines 25 --log-pmd ${reportdir}/phpcpd.xml --verbose"/>
            <arg line="${srcdir}"/>
        </exec>
    </target>
```
So now you can start code standart with command from your project path:
```
ant run-code-standards
```
# etcKeeper 
Added etcKeeper - autocommit on exit to /etc git local repository

#XDebug Intellij/PHPStorm setup
Go to: Languages & Frameworks > PHP > Debug > DBGp Proxy and set the following settings:
```
    Host: your IP address (example 172.17.0.1 for docker host)
    Port: 9001
```
#Origin
[Docker Hub] (https://registry.hub.docker.com/u/cristo/symfony2/)
[Git Hub] (https://github.com/monte-fm/symfony2)
