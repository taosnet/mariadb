#!/bin/sh

if ! [ -d /var/lib/mysql/mysql ]; then
	/usr/bin/mysql_install_db --user=mysql --rpm
	/usr/bin/mysqld_safe "$@" &
	sleep 5
	/usr/bin/mysqladmin --force=TRUE drop test

	if [ -n "$MYSQL_DATABASE" ]; then
		mysqladmin create "$MYSQL_DATABASE"
		if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
			if [ -n "$MYSQL_HOST" ]; then
				echo "GRANT ALL ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'$MYSQL_HOST' IDENTIFIED BY '$MYSQL_PASSWORD';" | mysql
			else
				echo "GRANT ALL ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';" | mysql
			fi
		fi
	fi

	for f in `ls -1 /docker-entrypoint-initdb.d/*.sql 2>/dev/null`; do
		mysql <$f
	done

	if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
		choose() { echo -n ${1:$((RANDOM%${#1})):1}; }
		password=$({
			for i in $(seq 1 $((8+RANDOM%8))); do
				choose '!@#$%^0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
			done
		})
		/usr/bin/mysqladmin -h localhost -u root password "$password"
		echo Random Password Generated: $password
	else
		/usr/bin/mysqladmin -h localhost -u root password "$MYSQL_ROOT_PASSWORD"
		password="$MYSQL_ROOT_PASSWORD"
	fi
	echo 'DELETE FROM user WHERE `Password`="";' | mysql -h localhost --password="$password" mysql
	/usr/bin/mysqladmin -h localhost --password="$password" flush-privileges

else
	/usr/bin/mysqld_safe "$@" &
fi

