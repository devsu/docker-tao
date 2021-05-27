#!/bin/sh

#If doesn't exist tao configuration file means system is not installed.
if [ ! -f "/var/www/html/config/generis.conf.php" ]; then

    echo "TAO platform is not installed yet. We proceed to install it."
    
    echo "Entering to TAO installer. We recommend to use default installation values if you are using the docker compose example."

    #Increase max execution time on fly to install system.
    sudo -u www-data php -d max_execution_time=300 /var/www/html/tao/scripts/taoInstall.php --verbose --file_path $FILE_PATH --db_driver $DB_DRIVER --db_host $DB_HOST --db_name $DB_NAME --db_user $DB_USER --db_pass $DB_PASSWORD --module_namespace $URL/first.rdf --module_url $URL --user_login $USER --user_pass $PASSWORD -e taoCe
        
    #Add DEBUG_MODE as false in order to have system in production mode.
    echo "define('DEBUG_MODE', false);" >> /var/www/html/config/generis.conf.php

    echo "TAO platform was successully installed. Please go to $TAO_HOST with the $TAO_USER as user and $TAO_PASSWORD as password. Once inside the system, change the password for security reasons."
   
else
    echo "Systems ready. Please enter to your TAO platform through your browser."
fi

exec "$@"