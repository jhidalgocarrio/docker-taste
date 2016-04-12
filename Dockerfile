FROM i386/ubuntu:14.04

MAINTAINER "Javier Hidalgo Carrio" <javier.hidalgo_carrio@dfki.de>

# Make the binfmt_misc pseudo-filesystem available at boot.
#RUN echo "binfmt_misc /proc/sys/binfmt_misc binfmt_misc none" >> $ROOTFS/etc/fstab
#RUN mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
#RUN echo ":CLR:M::MZ::/usr/bin/mono:" > $ROOTFS/proc/sys/fs/binfmt_misc/register

# Create Taste user
RUN sudo adduser  --disabled-password --gecos -m taste && adduser taste sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Update the current system
RUN sudo apt-get update

# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

# Upgrade the current system
RUN DEBIAN_FRONTEND=noninteractive && sudo apt-get upgrade -y -q

#  Installing required packages:
#  There are some warnings (in red) that show up during the build. You can hide
#  them by prefixing each apt-get statement with DEBIAN_FRONTEND=noninteractive

RUN DEBIAN_FRONTEND=noninteractive &&\
            sudo apt-get update &&\
            sudo apt-get install -y -q  build-essential vim python-pyside\
            autotools-dev ccache python-setuptools python-dev libfreetype6-dev\
            sqlite3 libpng12-dev python-antlr python-ply m4 automake autoconf\
            swig python-pyparsing libxml-libxml-perl zip libarchive-dev\
            libacl1-dev libattr1-dev libacl1 libattr1 python-lxml python-jinja2\
            libxml-parser-perl libxml-libxml-perl libgtk2-perl\
            libfile-copy-recursive-perl libxml-libxml-simple-perl\
            xterm python-pexpect\
            libxenomai-dev xenomai-runtime python-gtk2-dev gtkwave\
            libdbd-sqlite3-perl libdbi-perl libsqlite3-dev xmldiff\
            libxml2-dev qemu-system wmctrl python-pygraphviz postgresql\
            pgadmin3 python-psycopg2 libmono-system-runtime4.0-cil\
            libmono-corlib4.0-cil\
            libmono-system-runtime-serialization-formatters-soap4.0-cil\
            libmono-system-web4.0-cil libmono-system-xml4.0-cil\
            libmono-system4.0-cil mono-runtime\
            libmono-system-numerics4.0-cil subversion\
            libmono-system-data-linq4.0-cil libmono-corlib2.0-cil\
            libmono-system2.0-cil python-pip python-matplotlib\
            wget gnat figlet

# great if we could remove this packages (they will probkem in the docker)
#            libbonoboui2-0 libgnome2-0 libgnomeui-0 libgnomevfs2-0
#            libgnome2-vfs-perl libgnomevfs2-common
#            libglib2.0-0 libgtk2-gladexml-perl xpdf libgnome2-perl\

# Note: The official Debian and Ubuntu images automatically ``apt-get clean``
# after each ``apt-get``
#RUN apt-get clean

# Handle "deeper" message queues
RUN sudo echo "fs.mqueue.msg_max=100" >> /etc/sysctl.conf

# Change to taste user
ENV HOME /home/taste
WORKDIR $HOME
USER taste

# Install python packages
RUN sudo easy_install matplotlib
RUN sudo pip install --upgrade sqlalchemy graphviz enum34 singledispatch
RUN wget http://download.tuxfamily.org/taste/misc/antlr_python_runtime-3.1.3.tar.gz
RUN tar zxvf antlr_python_runtime-3.1.3.tar.gz
WORKDIR $HOME/antlr_python_runtime-3.1.3
RUN pwd
RUN pip install --upgrade --user .
WORKDIR $HOME
RUN rm -rf antlr_python_runtime-3.1.3

# Create default installation folders
RUN mkdir /home/taste/tool-inst
RUN mkdir /home/taste/tool-inst/bin

# Define some alias and terminal prompt
RUN echo alias kate=\'vim\' >> /home/taste/.bashrc
RUN echo export PS1="\"\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \\$\[\033[00m\]" \" >> /home/taste/.bashrc

# Define some environmental variables
RUN echo export PREFIX=~/tool-inst >> /home/taste/.bashrc
RUN echo export PATH=~/tool-inst/bin:"\$PATH" >> /home/taste/.bashrc
RUN echo export PATH=\$PREFIX/share/OG:\$PREFIX/share/aadl2glueC:$PREFIX/share/asn2aadlPlus:\$PREFIX/share/asn1scc:\$PREFIX/share/asn2dataModel:"\$PATH" >> /home/taste/.bashrc
RUN echo export ASN1SCC=\$PREFIX/share/asn1scc/asn1.exe >> /home/taste/.bashrc

# Run the rest of the commands as the ``postgres`` user created by the ``postgres`` package when it was ``apt-get installed``
USER postgres

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "local all  all    trust" >> /etc/postgresql/9.3/main/pg_hba.conf


# Create a PostgreSQL role named ``docker`` with ``docker`` as the password and
# then create a database `docker` owned by the ``docker`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN /etc/init.d/postgresql start

#RUN psql --command "CREATE USER taste WITH SUPERUSER PASSWORD 'tastedb';"

# And add ``listen_addresses`` to ``/etc/postgresql/9.3/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]

# The taste user
USER taste
WORKDIR $HOME

# Download taste from version control system
# TO-DO: Change for git checkout
#RUN svn co --non-interactive --trust-server-cert https://tecsw.estec.esa.int/svn/taste/branches/stable tool-src

##################### INSTALLATION END #####################

# Set default container command entrypoint
ENTRYPOINT figlet taste && /bin/bash

