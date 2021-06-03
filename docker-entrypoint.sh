#!/bin/bash

#Set WAIT_HOST value according DB_HOST and DB_PORT values.
export WAIT_HOSTS=$DB_HOST:$DB_PORT

/wait

#If doesn't exist tao configuration file means system is not installed.
if [ ! -f "/var/www/html/config/generis.conf.php" ]; then

    echo "TAO platform is not installed yet. We proceed to install it."
    
    echo "Entering to TAO installer. We recommend to use default installation values if you are using the docker compose example."

    #Increase max execution time on fly to install system.
    php -d max_execution_time=300 /var/www/html/tao/scripts/taoInstall.php -vvvv --file_path $FILE_PATH --db_driver $DB_DRIVER --db_host $DB_HOST --db_name $DB_NAME --db_user $DB_USER --db_pass $DB_PASSWORD --module_namespace $URL/first.rdf --module_url $URL --user_login $USER --user_pass $PASSWORD -e taoCe
        
    #Change DEBUG_MODE as false in order to have system in production mode.
    export search="define('DEBUG_MODE', true);"
    export replace="define('DEBUG_MODE', false);"
    sed -i "s/$search/$replace/" /var/www/html/config/generis.conf.php

    #Give permissions in order to create respective assets and files to run TAO platform.
    chmod -R 755 /var/www/html/
    chmod -R 777 /var/lib/tao/data/

    echo "TAO platform was successully installed. TAO running at $URL."
   
else
    echo "Systems ready. TAO running at $URL."
fi

exec "$@"