

dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
VALIDATE $? "Installing Python"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop already created ... $Y SKIPPING $N"
fi

rm -rf /app
VALIDATE $? "Removing existing code"

rm -rf /tmp/payment.zip
VALIDATE $? "Removed payment zip"

mkdir -p /app  &>>$LOGS_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>>$LOGS_FILE
cd /app 
unzip /tmp/payment.zip &>>$LOGS_FILE
VALIDATE $? "Downloaded and extracted payment code"

pip3 install -r requirements.txt  &>>$LOGS_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Created systemctl service"

systemctl enable payment 
systemctl restart payment
VALIDATE $? "Enable and restarted payment"