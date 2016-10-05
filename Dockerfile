FROM i386/ubuntu:14.04

MAINTAINER "Javier Hidalgo Carrio" <javier.hidalgo_carrio@dfki.de>

# Create Taste user
RUN sudo adduser  --disabled-password --gecos -m assert && adduser assert sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV HOME /home/assert

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Yes, the symlinks point to nothing - bear with me
RUN ln -s $HOME/tool-inst /opt/ocarina-2.0w-suite-x86-linux-2016.svn
RUN ln -s /opt/DMT-Tools /opt/DMT

# Update the current system
RUN sudo apt-get update

# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN echo "#!/bin/sh\nexit 0" >> /usr/sbin/policy-rc.d

# Upgrade the current system
RUN DEBIAN_FRONTEND=noninteractive && sudo apt-get upgrade -y -q

#  Installing required packages:
#  There are some warnings (in red) that show up during the build. You can hide
#  them by prefixing each apt-get statement with DEBIAN_FRONTEND=noninteractive

RUN DEBIAN_FRONTEND=noninteractive &&\
            sudo apt-get install -y -q subversion libgtk2-gladexml-perl xpdf libgnome2-perl xterm\
            libxml-parser-perl libxml-libxml-perl libgtk2-perl libfile-copy-recursive-perl\
            nedit zip sudo libxml-libxml-simple-perl libbonoboui2-0 libgnome2-0 libgnomeui-0\
            libgnomevfs2-0  libgnome2-vfs-perl libgnomevfs2-common python-pexpect\
            libxenomai-dev xenomai-runtime python-gtk2-dev gtkwave libdbd-sqlite3-perl\
            libdbi-perl libsqlite3-dev sqlite3 xmldiff libxml2-dev qemu-system wmctrl\
            python-ply tree llvm llvm-runtime kate tk8.5 libtool python3-pip libxslt1-dev\
            libxml2-dev libarchive-dev libacl1-dev libattr1-dev libacl1 libattr1 python-lxml\
            python-jinja2 libglib2.0-0 libmono-system-runtime4.0-cil libmono-corlib4.0-cil\
            libmono-system-runtime-serialization-formatters-soap4.0-cil\
            libmono-system-web4.0-cil  libmono-system-xml4.0-cil libmono-system4.0-cil\
            mono-runtime libmono-system-numerics4.0-cil libmono-system-data-linq4.0-cil\
            libmono-corlib2.0-cil libmono-system2.0-cil python-pygraphviz postgresql\
            postgresql-client postgresql-client-common postgresql-common pgadmin3\
            python-psycopg2 lcov libzmq3-dev python-coverage curl autoconf automake gnat\
            ccache binfmt-support vim strace dos2unix python-antlr python-pip python3-pip\
            git python-pyside python-pip python-matplotlib gcc procps bash-completion\
            wget gnat figlet git git-gui

# Make the binfmt_misc pseudo-filesystem available at boot.
#RUN echo "binfmt_misc /proc/sys/binfmt_misc binfmt_misc none" >> $ROOTFS/etc/fstab
#RUN mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
#RUN echo ":CLR:M::MZ::/usr/bin/mono:" > $ROOTFS/proc/sys/fs/binfmt_misc/register

# Handle "deeper" message queues
RUN sudo echo "fs.mqueue.msg_max=100" >> /etc/sysctl.conf

# TODO If you target RTEMS, copy the /opt/rtems-4.11 folder from the ASSERT VM under /opt

#######################
# Change to taste user
#######################
WORKDIR $HOME
USER assert

# Copy assert environmental variables
COPY assert_env.sh $HOME/assert_env.sh

# add this sourcing at the end of your .bashrc
RUN echo '. ~/assert_env.sh' >> $HOME/.bashrc

# Source environmental variables
RUN . $HOME/assert_env.sh

# Ellidiss
RUN sudo mkdir -p /opt/Ellidiss-TASTE-linux/config/
RUN sudo chmod 777 /opt/Ellidiss-TASTE-linux/config/
RUN sudo chmod 777 /opt/Ellidiss-TASTE-linux/

# Install python packages
RUN pip install --user enum34
RUN pip install --user http://download.tuxfamily.org/taste/misc/antlr_python_runtime-3.1.3.tar.gz
RUN pip install --user singledispatch

# Create default installation folders
RUN mkdir $HOME/tool-inst
RUN mkdir $HOME/tool-inst/bin

# Define some environmental variables
RUN echo export PREFIX=\$HOME/tool-inst >> $HOME/.bashrc
RUN echo export PATH=\$HOME/tool-inst/bin:"\$PATH" >> $HOME/.bashrc
RUN echo export PATH=\$PREFIX/share/OG:\$PREFIX/share/aadl2glueC:$PREFIX/share/asn2aadlPlus:\$PREFIX/share/asn1scc:\$PREFIX/share/asn2dataModel:"\$PATH" >> $HOME/.bashrc
RUN echo export GIT_SSL_NO_VERIFY=1 >> $HOME/.bashrc
RUN echo export DISABLE_MULTICORE_CHECK=true >> $HOME/.bashrc


# Define some alias and terminal prompt
RUN echo alias kate=\'vim\' >> $HOME/.bashrc
RUN echo alias asn1.exe=\'mono \${ASN1SCC}\' >> $HOME/.bashrc
RUN echo export PS1="\"\[\033[01;32m\]\u@\h\[\033[01;34m\]:\w\\\[\033[01;31m\]$(__git_ps1 \"[%s]\")$\[\033[00m\]" \" >> $HOME/.bashrc

# Create bash function
RUN echo create_mono_executable\(\) \{ >> $HOME/.bashrc
RUN echo eval \"\$1\(\) \{ >> $HOME/.bashrc
RUN echo mono \$1 >> $HOME/.bashrc
RUN echo \}\" >> $HOME/.bashrc
RUN echo \} >> $HOME/.bashrc
RUN echo create_mono_executable \$ASN1SCC >> $HOME/.bashrc
RUN echo create_mono_executable \$DMT/asn1scc/taste-extract-asn-from-design.exe >> $HOME/.bashrc

# vimrc file for vim editor
RUN echo set term=xterm >> $HOME/.vimrc

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

#RUN psql --command "CREATE USER assert WITH SUPERUSER PASSWORD 'assertdb';"

# And add ``listen_addresses`` to ``/etc/postgresql/9.3/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]

#######################
# The assert user
#######################
USER assert
WORKDIR $HOME

RUN mkdir -p $HOME/.subversion/auth/svn.ssl.server
COPY 881c66f88fd3a39b27ff6b842d5c079b $HOME/.subversion/auth/svn.ssl.server/

# Download taste from version control system
# TO-DO: Change for git checkout
RUN svn co --non-interactive --trust-server-cert https://tecsw.estec.esa.int/svn/taste/branches/stable $HOME/tool-src
COPY taste-tool-src_stable.diff $HOME/tool-src/
WORKDIR $HOME/tool-src
RUN patch -p0 -i taste-tool-src_stable.diff
RUN make

##################### INSTALLATION END #####################

# Set default container command entrypoint
ENTRYPOINT figlet sargon && /bin/bash

