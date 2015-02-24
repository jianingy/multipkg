# Multipkg by Examples

This file gives some examples on how to use multipkg.

## Build nginx with default configuration

By default, multipkg only needs one configuration file `index.yaml'. e.g,

Directory Layout

    + nginx
      +- index.yaml

nginx/index.yaml:

    default:
      name: nginx
      http: http://nginx.org/download/nginx-1.2.6.tar.gz
      version: 1.2.6

command:

    multipkg -v .

Notice that multipkg will download nginx source code automatically.


## Build nginx with custom configuration

If you want to apply some custom settings, you can use `scripts/build` to
customize the building process. e.g,

Directory Layout

    + nginx
      +- index.yaml
      +- scripts
         +- build

nginx/index.yaml:

    default:
      name: nginx
      http: http://nginx.org/download/nginx-1.2.6.tar.gz
      version: 1.2.6
      buildprefix: /opt/nginx

nginx/scripts/build:

    #!/bin/sh
    ./configure --prefix=$PREFIX --without-pcre --without-http_gzip_module --without-http_rewrite_module
    make install DESTDIR=$DESTDIR

command:

    multipkg -v .


Notice that `buildprefix` in the index.yaml is passed as environment variable
`PREFIX` into the build script.

## Build nginx with platform special settings

Depends on the platform you run multipkg, it can build deb or rpm
packages. You can specify platform special settings in 'rpm' or 'deb'
section. Settings in these sections will override the default settings. e.g,

Directory Layout

    + nginx
      +- index.yaml
      +- scripts
         +- build

nginx/index.yaml:

    default:
      name: nginx
      http: http://nginx.org/download/nginx-1.2.6.tar.gz
      version: 1.2.6
      buildprefix: /opt/nginx
      release: 5
    rpm:
      release: 5%{?dist}


nginx/scripts/build:

    #!/bin/sh
    ./configure --prefix=$PREFIX --without-pcre --without-http_gzip_module --without-http_rewrite_module
    make install DESTDIR=$DESTDIR

command:

    multipkg -v .

Notice that rpm variables like `{?dist}` can be directly used in index.yaml.

## Build daemontools with post-install and pre-uninstall hooks

By adding commands into `scripts/post.sh` or `scripts/preun.sh`, you can
perform actions after a successful installation or before an uninstallation.

Directory Layout:

    + daemontools
      +- index.yaml
      +- scripts
         +- build
         +- preun.sh
         +- post.sh

daemontools/index.yaml:

    default:
      name: daemontools
      http: 'http://cr.yp.to/daemontools/daemontools-0.76.tar.gz'
      version: '0.76'
      release: 1
      summary: A collection of tools for managing UNIX services.
      buildprefix: /usr

daemontools/scripts/build:

    #!/bin/sh
    cd daemontools-$PACKAGEVERSION
    sed -i -e 's#gcc#gcc -include /usr/include/errno.h #g' src/conf-cc
    sh package/compile
    mkdir -p $DESTDIR$PREFIX/bin
    install -m755 command/* $DESTDIR$PREFIX/bin

daemontools/scripts/post.sh:

    if ! grep svscanboot /etc/inittab 2>&1 > /dev/null ; then
        echo SV1:2345:respawn:/usr/bin/svscanboot >>/etc/inittab
        init q
    fi

    if [ ! -d /service ]; then
        mkdir /service
    fi

daemontools/scripts/pre.sh:

    if [ $1 = 0 ] ; then
        grep -q svscanboot /etc/inittab || exit 0
        mv -f /etc/inittab /etc/inittab.tmp.$$
        sed /svscanboot/d </etc/inittab.tmp.$$ >/etc/inittab && rm /etc/inittab.tmp.$$
    fi
    init q

command:

    multipkg -v .

## Build Python package from PyPi

You can build PyPi package by using `pypi` setting in the `index.yaml`. e.g,

Directory Layout:

    +- carbon
       +- index.yaml

carbon/index.yaml:

    ---
    default:
      name: coreops-python2-carbon
      version: "0.9.12"
      release: 1
      pypi: carbon
      summary: Backend data caching and persistence daemon for Graphite
      python: /usr/bin/python
      requires:
        - python
      buildrequires:
        - libpython-dev

command:

    multipkg -v .

Notice that `requires' and 'buildrequires' help specify package dependences
for installation and building process.

## Integrated source code with multipkg configurations

If you don't like download source from Internet, you can put your source into
tarball named `source.tar.gz`. Multipkg will first untar it before
building. e.g,

Directory Layout

    + nginx
      +- index.yaml
      +- source.tar.gz

nginx/index.yaml:

    default:
      name: nginx
      version: 1.2.6

command:

    multipkg -v .

## Build package from a folder of files

Without source code, you can put things you wanna pack into a directory named
`root`. Multipkg will pack all files in that directory into your package. e.g,

Directory Layout

    + helloworld
      +- index.yaml
      +- root
         +- usr
            +- bin
               +- hello.sh

helloworld/index.yaml:

    default:
      name: helloworld
      version: 0.0.1


helloworld/root/usr/bin/hello.sh:
    #!/bin/sh
    echo hello, $1

command:

    multipkg -v .
