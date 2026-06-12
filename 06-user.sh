

dnf module disable nodejs -y &>>$LOGS_FILE
dnf module enable nodejs:20 -y  &>>$LOGS_FILE
dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Installing NodeJS:20"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop already created ... $Y SKIPPING $N"
fi

rm -rf /app
VALIDATE $? "Removing existing code"

rm -rf /tmp/user.zip
VALIDATE $? "Removed user zip"

mkdir -p /app  &>>$LOGS_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip  &>>$LOGS_FILE
cd /app 
unzip /tmp/user.zip &>>$LOGS_FILE
VALIDATE $? "Downloaded and extracted user code"

npm install  &>>$LOGS_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Created systemctl service"

systemctl enable user &>>$LOGS_FILE
systemctl restart user &>>$LOGS_FILE
VALIDATE $? "Restarting user"