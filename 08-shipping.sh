

dnf install maven -y &>>$LOGS_FILE
VALIDATE $? "Installing Maven"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop already created ... $Y SKIPPING $N"
fi

rm -rf /app
VALIDATE $? "Removing existing code"

rm -rf /tmp/shipping.zip
VALIDATE $? "Removed shipping zip"

mkdir -p /app  &>>$LOGS_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOGS_FILE
cd /app 
unzip /tmp/shipping.zip &>>$LOGS_FILE
VALIDATE $? "Downloaded and extracted shipping code"

mvn clean package  &>>$LOGS_FILE
mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Created systemctl service"

dnf install mysql -y &>>$LOGS_FILE
VALIDATE $? "Installing MySQL client"

mysql -h $MYSQL_HOST -u root -pRoboShop@1 -e "use cities" &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql
    VALIDATE $? "Data loaded"
else
    echo -e "Data already loaded ... $Y SKIPPING $N"
fi

systemctl enable shipping 
systemctl restart shipping
VALIDATE $? "Enable and restarted shipping"