#!/bin/sh

if [ ! -f "/var/www/html/config/generis.conf.php" ]; then

    echo "TAO platform is not installed yet. We proceed to install it."
    
    if ! mysqladmin ping -h"$DB_HOST" --silent; then    
            echo "Unable to connect to database. Please check environment variables for your database connection."
            exit 1
    fi

    echo "Entering to TAO installer. We recommend to use default installation values if you are using the docker compose example."

    sudo -u www-data php -d max_execution_time=300 /var/www/html/tao/scripts/taoInstall.php --verbose --file_path $FILE_PATH --db_driver $DB_DRIVER --db_host $DB_HOST --db_name $DB_NAME --db_user $DB_USER --db_pass $DB_PASSWORD --module_namespace $TAO_HOST/first.rdf --module_url $TAO_HOST --user_login $TAO_USER --user_pass $TAO_PASSWORD -e taoCe
    echo "define('DEBUG_MODE', false)" >> /var/www/html/config/generis.conf.php

    echo "TAO platform was successully installed. Please go to $TAO_HOST with the $TAO_USER as user and $TAO_PASSWORD as password. Once inside the system, change the credentials for security reasons."
   
else
    echo "Systems ready. Please enter to your TAO platform through your browser."
fi

exec "$@"