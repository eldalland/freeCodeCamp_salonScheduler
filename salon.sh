#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services")

  echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  echo "Which service?"
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_ID ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
      else 
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      fi

      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"

      read SERVICE_TIME
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU
