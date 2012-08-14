#!/bin/sh
# Shell script to install ICEcat PIM under Debian GNU Linux

# Abort on any errors
set -e

# Check the role. Exit if not Superuser
if [ ! -w /etc/passwd ]; then
    echo "Super-user privileges are required.  Please run this with 'sudo'." >&2
    exit 1
fi

# IMPORTANT: Do not use gdialog unless it has been fixed!
DIALOG=whiptail

PATH="/bin:/sbin:/usr/bin:/usr/sbin"
export PATH

# Get -nox option to force ncurses use
if [ "$1" = "-nox" ]; then
    export NOX=true
    shift
fi

# Set up (X)dialog
XDIALOG_HIGH_DIALOG_COMPAT=1
export XDIALOG_HIGH_DIALOG_COMPAT
if [ -n "$DISPLAY" ] && [ -x /usr/bin/Xdialog ] && [ ! -n "$NOX" ]; then
  DIALOG="Xdialog"
  X11="-X"
fi

# APACHEPATH=`httpd -V | grep HTTPD_ROOT | awk '{split($0,a,"="); print a[2]}'`

text='Welcome to the ICEcat PIM installation script!
This script will install and configure ICEcat PIM for basic usage.
It is strongly recommended that you review the default settings after installation. A good place to start is the "atomcfg.pm" file in the "lib" directory of your new installation.
This script need some basic information before it can begin. For any of these questions, you can simply press <enter> to accept the default value.

Continue?'


#This script will install: \n 1) ICECatPIM source code \n 2) MySQL database \n 3) Perl modules \n 4) Apache configuration files \n 5) Cron jobs \n\n Continue?
title='Welcome to the ICECatPIM installation script!'

fnProgressBar()
{
 { for I in 10 20 30 40 50 60 70 80 90; do
  echo $I
  sleep $2
  done
  echo; } | $DIALOG --gauge "$1" 6 70 0
}

fnChangePath()
{

PATH="/bin:/sbin:/usr/bin:/usr/sbin"
export PATH

# *HOST* *PATH* *DBNAME* *DBU* *DBP*
PATH="`cat /tmp/dir`"
        DBU=$1
        DBP=$2
        DBNAME=$3
        HOST=$4
        SYS=$5
        
        PIMCFG='files/atomcfg.pm'
        IMPORTCFG='files/PIMConfiguration.pm'
        APACHECFG='files/pim.conf'
        
        /usr/bin/replace *PATH* $PATH *DBNAME* $DBNAME *DBU* $DBU *DBP* $DBP *HOST* $HOST -- $PIMCFG $IMPORTCFG $APACHECFG
        
mv='/bin/mv'
cp='/bin/cp'
sudo='/usr/bin/sudo'

	$mv "$PATH/lib/atomcfg.pm" "$PATH/lib/atomcfg.pm_BAK"
        $cp $PIMCFG "$PATH/lib/atomcfg.pm"
      
        $mv "$PATH/data_source/IcecatToPIMImport/PIMImportConfiguration.pm" "$PATH/data_source/IcecatToPIMImport/PIMImportConfiguration.pm_BAK"
        $cp $IMPORTCFG "$PATH/data_source/IcecatToPIMImport/PIMImportConfiguration.pm"
        /usr/bin/replace "DocumentRoot $PATH" "DocumentRoot $PATH/www" -- $APACHECFG
        /usr/bin/replace "RewriteMap multimediaobjects prg:/home/pimasde/bin/multimedia_object_prg4apache2.pl" "RewriteMap multimediaobjects prg:/home/pim/bin/multimedia_object_prg4apache2.pl" -- $APACHECFG
            
        if [ "$SYS" = "CentOS" ] || [ "$SYS" = "Gentoo" ]; then
                $cp $APACHECFG /etc/httpd/conf.d/pim.conf
                change_htaccess "$DBNAME" "$DBU" "$DBP" "$PATH"
                $sudo /usr/bin/replace "/home/gcc/logs/custom_history.log" "$PATH/logs/custom_history.log" -- $PATH/lib/history.pm
                $sudo httpd
        fi
        
        if [ "$SYS" = "Ubuntu" ] || [ "$SYS" = "Debian" ]; then
        
                if [ "$SYS" = "Ubuntu" ]; then
    				setup='apt-get'
    			else
    				setup='/usr/bin/aptitude'
    			fi
        
                $cp $APACHECFG "/etc/apache2/sites-available/pim.conf"
                $sudo $setup install libapache2-mod-perl2  libgd-graph-perl  libdata-serializer-perl libemail-find-perl  libexporter-lite-perl  libspreadsheet-parseexcel-simple-perl  libarchive-zip-perl  libtext-csv-perl  libtext-csv-encoded-perl  libtext-csv-perl  libtext-csv-xs-perl  imagemagick  libalgorithm-diff-perl  libparams-validate-perl  libclass-inspector-perl libclass-csv-perl  libdata-dump-perl  libxml-libxml-perl  libalgorithm-checkdigits-perl  libsoap-lite-perl  libxml-validator-schema-perl  libapache2-mod-auth-mysql libparallel-forkmanager-perl libmime-types-perl libapache2-mod-fastcgi
                $sudo /usr/bin/cpan Text:CSV:Separator
                $sudo /usr/bin/cpan SOAP:WSDL
                if [ "$SYS" = "Ubuntu" ]; then
    				$sudo apt-get install zlib1g-dev
    			fi
                $sudo /usr/bin/cpan PerlIO::gzip
                
                $sudo /usr/sbin/a2dissite default
                $sudo /usr/sbin/a2dissite default-ssl
                $sudo /usr/sbin/a2ensite pim.conf
                $sudo /usr/sbin/a2enmod rewrite
                $sudo /usr/sbin/a2enmod perl
                $sudo /usr/sbin/a2enmod auth_mysql
                /usr/bin/replace "#AddHandler cgi-script .cgi" "AddHandler cgi-script .cgi" -- /etc/apache2/mods-available/mime.conf
                
                change_htaccess "$DBNAME" "$DBU" "$DBP" "$PATH"
              
                $sudo $setup install dh-make-perl zlib1g-dev

                    if [ "$SYS" = "Ubuntu" ]; then
                       $sudo cpan "XML::Simple"
                    else
                    	$sudo dh-make-perl --build --cpan "PerlIO::gzip"
                    fi
                $sudo /usr/bin/replace "/home/gcc/logs/custom_history.log" "$PATH/logs/custom_history.log" -- $PATH/lib/history.pm
                $sudo /usr/sbin/service apache2 restart
    

    
        fi
        
}

change_htaccess(){
                
                DBNAME=$1
                DBU=$2
                DBP=$3
                PATH=$4
                
sudo='/usr/bin/sudo'
sed='/bin/sed'
             
                $sudo $sed -i '/AuthType Basic/ a\AuthUserFile \/dev\/null' $PATH/www/xml_s3/.htaccess
                $sudo $sed -i '/AuthBasicAuthoritative Off/ a\AuthMySQL_Authoritative on' $PATH/www/xml_s3/.htaccess
                $sudo /usr/bin/replace "AuthMySQLHost 62.250.11.171" "Auth_MySQL_Host <strong>127.0.0.1</strong>" "AuthMySQLDB gccdb" "Auth_MySQL_DB $DBNAME" "AuthMySQLUser gcc" "Auth_MySQL_User <strong>$DBU</strong>" "AuthMySQLPassword WV120xA" "Auth_MySQL_Password <strong>$DBP</strong>" "AuthMySQLPwEncryption none" "##Auth_MySQL_Pw_Encryption none" "AuthMySQLUserTable users" "Auth_MySQL_Password_Table users" "AuthMySQLNameField login" "Auth_MySQL_Username_Field login" "AuthMySQLPasswordField password" "Auth_MySQL_Password_Field password" -- $PATH/www/xml_s3/.htaccess
                $sudo $sed -i '/Auth_MySQL_Password_Field password/ a\AuthMySQL_Encryption_Types Plaintext' $PATH/www/xml_s3/.htaccess
                $sudo $sed -i '/a\AuthMySQL_Encryption_Types Plaintext/ a\Auth_MySQL On' $PATH/www/xml_s3/.htaccess

}


while [ 0 ]; do
  $DIALOG --backtitle "$title" --clear --yesno "$text" 20 65
  
  if [ $? = 0 ]; then

DIALOG=${DIALOG=dialog}
tempfile=`mktemp 2>/dev/null` || tempfile=/tmp/test$$
trap "/bin/rm -f $tempfile" 0 1 2 5 15

$DIALOG --backtitle "Choice of distribution" \
        --title "Choice of distribution" --clear \
        --radiolist "Please Choose a distribution in which the program will be installed:" 20 61 5 \
        "Ubuntu" " " ON\
        "Debian"  " " off \
        "Gentoo" " " off \
        "CentOS" " " off  2> $tempfile

retval=$?

L=`cat $tempfile`

    if [ "$L" = "Ubuntu" ] || [ "$L" = "Debian" ]; then
    	if [ "$L" = "Ubuntu" ]; then
    		setup='apt-get'
    		mysql='mysql-server'
    	fi
    	if [ "$L" = "Debian" ]; then
    		setup='/usr/bin/aptitude'
    		mysql='mysql-server-5.1'
    	fi
    $setup install apache2
    $setup install $mysql
    $setup install build-essential
    fi
    
    if [ "$L" = "CentOS" ]; then
    /usr/bin/yum install make
    /usr/bin/yum install libxml2-devel
    /usr/bin/yum install perl-ExtUtils-MakeMaker
    /usr/bin/yum install mysql mysql-server
    /sbin/chkconfig --levels 235 mysqld on
    /etc/init.d/mysqld start
    /usr/bin/mysql_secure_installation
    /usr/bin/yum install httpd
    /usr/bin/wget http://files.directadmin.com/services/9.0/ExtUtils-MakeMaker-6.31.tar.gz
    /bin/tar xvzf ExtUtils-MakeMaker-6.31.tar.gz
    cd ExtUtils-MakeMaker-6.31
    /usr/bin/perl Makefile.PL
    make
    make install
    cd ..
    fi
    if [ "$SYS" = "Gentoo" ]; then
    emerge apache
    /etc/init.d/apache2 start
    rc-update add apache2 default
    emerge mysql
    fi
      # configure and install
      $DIALOG --backtitle "$title" --title "Select the path:" --inputbox\
      "Input directory where you'd like to place ICECatPIM or\n press <Cancel> to exit"\
      9 40 '/home/pim/' $F 2>/tmp/dir
      
    if [ $? = 0 ]; then
	F="`cat /tmp/dir`"
	PWDa="`pwd`"
	if [ ! -d "$F" ]; then
		mkdir -p $F &
		fnProgressBar "Making folder..." "0.1"
    fi
	cd $F && tar xzf $PWDa/ICECatPIM-2.0.tar.gz && cd $PWDa &
        #( time=0 ; while $time < 100; do time=`expr $time + 13`; echo $time; done )  | $DIALOG --gauge "Progress" 6 70 0
 	 
	     if [ $? = 0 ]; then
              $DIALOG --backtitle "$title" --title "Select the path:" --inputbox\
              "Select MySQL host:"\
	      9 40 'localhost' $F 2>/tmp/host
			if [ $? = 0 ]; then
			              $DIALOG --backtitle "$title" --inputbox\
             				"Select MySQL username:"\
            				9 40 'root' $U 2>/tmp/user
				      
				      if [ $? = 0 ]; then
				      $DIALOG --backtitle "$title" --passwordbox\
					"Select MySQL password:"\
					9 40 '' $P 2>/tmp/pass
				      if [ $? = 0 ]; then
				      $DIALOG --backtitle "$title" --inputbox\
                                        "Select MySQL dbname:"\
                                        9 40 'pimdb' $N 2>/tmp/dbname
                                                
						if [ $? = 0 ]; then
							U="`cat /tmp/user`"
							P="`cat /tmp/pass`"
							D="`cat /tmp/dbname`"
							H="`cat /tmp/host`"
							
							mysqladmin -u $U -p$P create $D
							mysql -u $U -p$P $D < ./pim.sql &
							
							
							# Build modules
							if [ -f modules.tar.gz ] ; then
							   F="`cat /tmp/dir`"
							   echo "Installing Perl modules!"
							   gzip -dc modules.tar.gz | tar -xf -
							   cd modules
							   ./modules-build.pl
							   cd ..
							   cp -R modules/built_modules/* $F/lib
							fi
                                                       
                                                       
							fnChangePath "$U" "$P" "$D" "$H" "$L"
                                                        
							#fnProgressBar "Installation Perl modules..." "1"
							exit 0

						fi
				fi  fi
			fi
	     fi
      fi
      
      #end configure and inslall
fi
 if [ $? = 1 ]; then
 exit 0
fi
done 