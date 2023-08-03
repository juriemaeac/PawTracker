#include <WiFi.h>


//========================================================================================================//
#include <Arduino.h>
// Set serial for debug console (to the Serial Monitor, default speed 115200)
#define SerialMon Serial
#define SerialAT Serial1

#define TINY_GSM_MODEM_SIM7000
#define TINY_GSM_RX_BUFFER 1024 // Set RX buffer to 1Kb
#define SerialAT Serial1

// #define TINY_GSM_USE_GPRS true
// #define TINY_GSM_USE_WIFI false
// #define USE_GSM 

#include <TinyGsmClient.h>
// set GSM PIN, if any
#define GSM_PIN ""

// Your GPRS credentials, if any
const char apn[]  = "internet.globe.com.ph";     //SET TO YOUR APN
const char gprsUser[] = "";
const char gprsPass[] = "";


#include <SPI.h>
#include <SD.h>
#include <Ticker.h>

#ifdef DUMP_AT_COMMANDS
#include <StreamDebugger.h>
StreamDebugger debugger(SerialAT, SerialMon);
TinyGsm modem(debugger);
#else
TinyGsm modem(SerialAT);
#endif

TinyGsmClient client(modem);

#define uS_TO_S_FACTOR      1000000ULL  // Conversion factor for micro seconds to seconds
#define TIME_TO_SLEEP       60          // Time ESP32 will go to sleep (in seconds)

#define UART_BAUD           115200
#define PIN_DTR             25
#define PIN_TX              27
#define PIN_RX              26
#define PWR_PIN             4

#define orangeLED           32
#define whiteLED            33
#define SD_MISO             2
#define SD_MOSI             15
#define SD_SCLK             14
#define SD_CS               13
#define LED_PIN             12

//========================================================================================================//
//Firebase Setup
#define API_KEY "AIzaSyCIohVxFh9ghUvMxY63VOYn5CB2-XTyYHY"

// Insert Authorized Email and Corresponding Password
// #define USER_EMAIL "pawtracker1@gmail.com"
// #define USER_PASSWORD "Pawtracker111!"
String USER_EMAIL;
String USER_PASSWORD;

// Insert RTDB URLefine the RTDB URL
#define DATABASE_URL "https://pawtrackeriot-default-rtdb.asia-southeast1.firebasedatabase.app/"
//========================================================================================================//

float homeLatitude = 0.0;
float homeLongitude = 0.0;
float maxDistance = 50;
String petName;

int telemetryMode = 0;
//========================================================================================================//
//WiFi Connectivity FOR TESTING PURPOSES ONLY!
//#define WIFI_NETWORK "XPN-4014A7"
//#define WIFI_PASSWORD "NCTV082222"
// #define WIFI_NETWORK "zoeyrenae"
// #define WIFI_PASSWORD "040814zoey"
String WIFI_NETWORK;
String WIFI_PASSWORD;
#define WIFI_TIMEOUT_MS 20000

//========================================================================================================//
//Firebase Setup
#include <Firebase_ESP_Client.h>
#include "time.h"
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// Define Firebase objects
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

String uid; // Variable to save USER UID
String databasePath; // Database main path (to be updated in setup with the user UID)

// Database child nodes
String devicelatPath    = "/deviceLatitude";
String devicelonPath   = "/deviceLongitude";
String homelatPath = "/homeLatitude";
String homelonPath = "/homeLongitude";
String speedPath    = "/speed";
String altPath   = "/altitude";
String vSatsPath   = "/visibleSatellites";
String uSatsPath    = "/usedSatellites";
String acryPath  = "/accuracy";
String yearPath   = "/year";
String mnthPath   = "/month";
String dayPath   = "/day";
String hourPath   = "/hour";
String mntPath   = "/minute";
String secPath   = "/seconds";
String mapsPath  = "/maps";
String periPath = "/perimeter";
String petPath = "/pet";

// Parent Node (to be updated in every loop)
String parentPath;
FirebaseJson json;

//========================================================================================================//
// Time Configuration
int timestamp;
const char* ntpServer = "pool.ntp.org";
// Timer variables (send new readings every three minutes)
unsigned long sendDataPrevMillis = 0;
unsigned long timerDelay = 180000; //every 3mins
//unsigned long timerDelay = 120000; //every 2mins
//unsigned long timerDelay = 900000; //every 15mins
//unsigned long timerDelay = 3600000; //every 1hour
//========================================================================================================//

//GPS Variables
float gpsLat      = 0;
float gpsLon      = 0;
String gpsLatString;
String gpsLonString;
String homegpsLatString;
String homegpsLonString;
float gpsSpeed    = 0;
float gpsAlt      = 0;
int   gpsVsat     = 0;
int   gpsUsat     = 0;
float gpsAccuracy = 0;
int   gpsYear     = 0;
int   gpsMonth    = 0;
int   gpsDay      = 0;
int   gpsHour     = 0;
int   gpsMin      = 0;
int   gpsSec      = 0;
bool  gpsPerimeter = true;
String mapsLink;
bool isNetworkConnected = false;

//========================================================================================================//
#include "EEPROM.h"
#define EEPROM_SIZE 128

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;


const int modeAddr = 0;
const int wifiAddr = 10;
const int dataAddr = 11;

int modeIdx;             //Device connection mode 1 = Calibration mode; 0 = Telemetry Mode

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      BLEDevice::startAdvertising();
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};

class MyCallbacks: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic){
    std::string value = pCharacteristic->getValue();

    if(value.length() > 0){
      Serial.print("Value : ");
      Serial.println(value.c_str());
      writeString(wifiAddr, value.c_str());
      //writeString(dataAddr, value.c_str());
      Serial.println(F("Storing Received Data to EEPROM!"));
    }
  }

  void writeString(int add, String data){
    int _size = data.length();
    for(int i=0; i<_size; i++){
      EEPROM.write(add+i, data[i]);
    }
    EEPROM.write(add+_size, '\0');
    EEPROM.commit();
  }
};

void connectToWiFi(){
  Serial.println(F("= Connecting to Wifi ="));
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_NETWORK.c_str(), WIFI_PASSWORD.c_str());

  unsigned long startConnectionAttempt = millis();
  while(WiFi.status() != WL_CONNECTED && millis() - startConnectionAttempt < WIFI_TIMEOUT_MS){
    networkLED();
    Serial.println(F("Trying to connect..."));
    delay(100);
  }

  if(WiFi.status() != WL_CONNECTED){
    Serial.println(F("WiFi Connection Failed!"));
    while(true){
      digitalWrite(LED_PIN, HIGH);
      delay(50);
      digitalWrite(LED_PIN, LOW);
      delay(50);
    }
  }else{
    Serial.print("WiFi Connection Established: ");
    networkLED();
    networkLED();
    networkLED();
    Serial.println(WiFi.localIP());
  }
}

void enableGPS(void)
{
    // Set SIM7000G GPIO4 LOW ,turn on GPS power
    // CMD:AT+SGPIO=0,4,1,1
    // Only in version 20200415 is there a function to control GPS power
    Serial.println(F("Start positioning . Make sure to locate outdoors."));
    modem.sendAT("+SGPIO=0,4,1,1");
    if (modem.waitResponse(10000L) != 1) {
        DBG(" SGPIO=0,4,1,1 false ");
    }
    modem.enableGPS();
}



unsigned long getTime() {
  time_t now;
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    //Serial.println("Failed to obtain time");
    return(0);
  }
  time(&now);
  return now;
}

void disableGPS(void)
{
    // Set SIM7000G GPIO4 LOW ,turn off GPS power
    // CMD:AT+SGPIO=0,4,1,0
    // Only in version 20200415 is there a function to control GPS power
    modem.sendAT("+SGPIO=0,4,1,0");
    if (modem.waitResponse(10000L) != 1) {
        DBG(" SGPIO=0,4,1,0 false ");
    }
    modem.disableGPS();
}

void modemPowerOn()
{
    pinMode(PWR_PIN, OUTPUT);
    digitalWrite(PWR_PIN, LOW);
    delay(1000);    //Datasheet Ton mintues = 1S
    digitalWrite(PWR_PIN, HIGH);
    //wait_till_ready();
    Serial.println(F("Waiting till modem ready..."));
    delay(4510); //Ton uart 4.5sec but seems to need ~7sec after hard (button) reset
    //On soft-reset serial replies immediately.
}

void modemPowerOff()
{
    pinMode(PWR_PIN, OUTPUT);
    digitalWrite(PWR_PIN, LOW);
    delay(1500);    //Datasheet Ton mintues = 1.2S
    digitalWrite(PWR_PIN, HIGH);
}


void modemRestart()
{
    modemPowerOff();
    delay(1000);
    modemPowerOn();
}

void connectToFirebase(){
  delay(100);
  //Firebase Connect
  Serial.println(F("= Establishing Connection to Cloud DB ="));
  Serial.println(USER_EMAIL);
  Serial.println(USER_PASSWORD);
  config.api_key = API_KEY;               // Assign the api key (required)
  auth.user.email = USER_EMAIL;           // Assign the user sign in credentials
  auth.user.password = USER_PASSWORD;
  config.database_url = DATABASE_URL;     // Assign the RTDB URL (required)
  Firebase.reconnectWiFi(true);
  fbdo.setResponseSize(4096);
  config.token_status_callback = tokenStatusCallback; 
  config.max_token_generation_retry = 5;  // Assign the maximum retry of token generation
  Firebase.begin(&config, &auth);         // Initialize the library with the Firebase authen and config

  Serial.println(F("Getting User UID"));     // Getting the user UID might take a few seconds
  while ((auth.token.uid) == "") {
    Serial.print('.');
    delay(1000);
  }

  uid = auth.token.uid.c_str();   
  Serial.println(F("= PawTracker Device Registered! ="));        // Print user UID
  Serial.print("User UID: ");
  Serial.println(uid);
  databasePath = "/UsersData/" + uid + "/readings"; // Update database path
}

void sendGPSTelemetry(){
    Serial.println("= GPS Telemetry =");
    sendDataPrevMillis = millis();
    Serial.print("Time Now: ");
    Serial.print(gpsHour);
    Serial.print(":");
    Serial.println(gpsMin);
    //Prepare Sensor Log
    int hour = 0;
    hour = gpsHour + 8;
    if(hour > 24){
      hour = (hour-24);
      gpsHour = hour;
    }else{
      gpsHour = hour;
    }
    timestamp = getTime();//Get current timestamp
    Serial.print("Timestamp Now: ");
    Serial.println(timestamp);  
    parentPath= databasePath + "/" + String(timestamp);
    json.set(devicelatPath.c_str(), String(gpsLatString));
    json.set(devicelonPath.c_str(), String(gpsLonString));
    json.set(homelatPath.c_str(), String(homegpsLatString));
    json.set(homelonPath.c_str(), String(homegpsLonString));
    json.set(speedPath.c_str(), String(gpsSpeed));
    json.set(altPath.c_str(), String(gpsAlt));
    json.set(vSatsPath.c_str(), String(gpsVsat));
    json.set(uSatsPath.c_str(), String(gpsUsat));
    json.set(acryPath.c_str(), String(gpsAccuracy));
    json.set(yearPath.c_str(), String(gpsYear));
    json.set(mnthPath.c_str(), String(gpsMonth));
    json.set(dayPath.c_str(), String(gpsDay));
    json.set(hourPath.c_str(), String(gpsHour));
    json.set(mntPath.c_str(), String(gpsMin));
    json.set(secPath.c_str(), String(gpsSec));
    json.set(mapsPath.c_str(), String(mapsLink));
    json.set(periPath.c_str(), String(gpsPerimeter));
    json.set(petPath.c_str(), String(petName));

    Serial.printf("Set json... %s\n", Firebase.RTDB.setJSON(&fbdo, parentPath.c_str(), &json) ? "ok" : fbdo.errorReason().c_str());
    Serial.println("= GPS Telemetry pushed to CloudDB =");
}

float getDistance(float flat1, float flon1, float flat2, float flon2) {

  // Variables
  float dist_calc=0;
  float dist_calc2=0;
  float diflat=0;
  float diflon=0;

  // Calculations
  diflat  = radians(flat2-flat1);
  flat1 = radians(flat1);
  flat2 = radians(flat2);
  diflon = radians((flon2)-(flon1));

  dist_calc = (sin(diflat/2.0)*sin(diflat/2.0));
  dist_calc2 = cos(flat1);
  dist_calc2*=cos(flat2);
  dist_calc2*=sin(diflon/2.0);
  dist_calc2*=sin(diflon/2.0);
  dist_calc +=dist_calc2;

  dist_calc=(2*atan2(sqrt(dist_calc),sqrt(1.0-dist_calc)));
  
  dist_calc*=6371000.0; //Converting to meters

  return dist_calc;
}

void locatingLED(){
  digitalWrite(orangeLED, HIGH);
  delay(50);
  digitalWrite(orangeLED, LOW);
  delay(50);
  digitalWrite(orangeLED, HIGH);
  delay(50);
  digitalWrite(orangeLED, LOW);
  delay(50);
  digitalWrite(whiteLED, HIGH);
  delay(50);
  digitalWrite(whiteLED, LOW);
}

void telemetryLED(){
  digitalWrite(whiteLED, HIGH);
  delay(50);
  digitalWrite(whiteLED, LOW);
  delay(50);
  digitalWrite(whiteLED, HIGH);
  delay(50);
  digitalWrite(whiteLED, LOW);
  delay(50);
  digitalWrite(whiteLED, HIGH);
  delay(50);
  digitalWrite(whiteLED, LOW);
  delay(50);
  digitalWrite(orangeLED, HIGH);
  delay(50);
  digitalWrite(orangeLED, LOW);
}

void networkLED(){
  digitalWrite(whiteLED, HIGH);
  digitalWrite(orangeLED, HIGH);
  delay(1000);
  digitalWrite(whiteLED, LOW);
  digitalWrite(orangeLED, LOW);
}

void pulseLED(){
  digitalWrite(whiteLED, HIGH);
  delay(50);
  digitalWrite(whiteLED, LOW);
  delay(50);
  digitalWrite(orangeLED, HIGH);
  delay(50);
  digitalWrite(orangeLED, LOW);
  delay(50);
}

void setup()
{
    Serial.println(F("= Setting up PawTracker GPS Device ="));
    // Set console baud rate
    SerialMon.begin(115200);
    delay(10);
    // LED Strobes
    pinMode(LED_PIN, OUTPUT);
    pinMode(whiteLED, OUTPUT);
    pinMode(orangeLED, OUTPUT);
    digitalWrite(LED_PIN, HIGH);
    digitalWrite(whiteLED, LOW);
    digitalWrite(orangeLED, LOW);
    if(!EEPROM.begin(EEPROM_SIZE)){       //Initialize EEPROM
      delay(1000);
    }
    Serial.println(F("= Current Device Mode ="));
    modeIdx = EEPROM.read(modeAddr);
    Serial.print("modeIdx : ");
    Serial.println(modeIdx);

    EEPROM.write(modeAddr, modeIdx !=0 ? 0 : 1);
    EEPROM.commit();
    SerialAT.begin(UART_BAUD, SERIAL_8N1, PIN_RX, PIN_TX);
    modemPowerOn();

    if(modeIdx != 0){
      //Calibration Mode
      Serial.println(F("Calibration MODE"));
      Serial.println(F("Please set-up and calibrate device via companion app."));
      bleTask();
      while(1){
        if(modeIdx == 0){
          break;
        }
      }

    }else{
      //Telemetry Mode
      Serial.println(F("Telemetry MODE"));
      telemetryTask();
      //Power the coomunication module
      Serial.println("Initializing modem...");
      if (!modem.restart()){
        Serial.println("Failed to restart modem, attempting to continue without restarting");
      }
      // Unlock your SIM card with a PIN if needed
      if (GSM_PIN && modem.getSimStatus() != 3){
        modem.simUnlock(GSM_PIN);
      }
      connectToWiFi();                      //FOR TESTING PURPOSES ONLY!!
      //connectToNetwork();                     //Connect to internet via cellular data
      configTime(0, 0, ntpServer);          //Configure Time Server
      connectToFirebase();                  //Connect device to cloud database
      //==============================================================================================//

      delay(10000);
    } 
    

}


void loop()
{ 

    if (!modem.testAT()) {
        Serial.println(F("Failed to restart modem, attempting to continue without restarting"));
        modemRestart();
        return;
    }

  // SerialMon.print(F("Connecting to "));
  // SerialMon.print(apn);
  // if (!modem.gprsConnect(apn, gprsUser, gprsPass))
  // {
  //   SerialMon.println(" fail");
  //   delay(10000);
  //   return;
  // }
  // SerialMon.println(" success");

  // if (modem.isGprsConnected())
  // {
  //   SerialMon.println("GPRS connected");
  // }
    enableGPS();
    pulseLED();

    float lat      = 0;
    float lon      = 0;
    float speed    = 0;
    float alt     = 0;
    int   vsat     = 0;
    int   usat     = 0;
    float accuracy = 0;
    int   year     = 0;
    int   month    = 0;
    int   day      = 0;
    int   hour     = 0;
    int   min      = 0;
    int   sec      = 0;
    // if (!modem.gprsConnect(apn, gprsUser, gprsPass)) {
    //   SerialMon.println("= Network Connection Failed =");
    // } 
    //else{
      while(1){
      Serial.println(F("Trying to fetch GPS location!"));
      Serial.println();
      if (modem.getGPS(&lat, &lon, &speed, &alt, &vsat, &usat, &accuracy,
                    &year, &month, &day, &hour, &min, &sec)) {
          Serial.println(F("The location has been locked, the latitude and longitude are:"));
          SerialMon.println("Latitude: " + String(lat, 8) + "\tLongitude: " + String(lon, 8));
          SerialMon.println("Speed: " + String(speed) + "\tAltitude: " + String(alt));
          SerialMon.println("Visible Satellites: " + String(vsat) + "\tUsed Satellites: " + String(usat));
          SerialMon.println("Accuracy: " + String(accuracy));
          SerialMon.println("Year: " + String(year) + "\tMonth: " + String(month) + "\tDay: " + String(day));
          SerialMon.println("Hour: " + String(hour) + "\tMinute: " + String(min) + "\tSecond: " + String(sec));
          locatingLED();
          locatingLED();
          String gps_raw = modem.getGPSraw();
          Serial.println();
          SerialMon.println("GPS/GNSS Based Location String: " + gps_raw);
          gpsLat      = lat;
          gpsLon      = lon;
          gpsLatString = String(lat,8);
          gpsLonString = String(lon,8);
          homegpsLatString = String(homeLatitude,7);
          homegpsLonString = String(homeLongitude,7);
          gpsSpeed    = speed;
          gpsAlt      = alt;
          gpsVsat     = vsat;
          gpsUsat     = usat;
          gpsAccuracy = accuracy;
          gpsYear     = year;
          gpsMonth    = month;
          gpsDay      = day;
          gpsHour     = hour;
          gpsMin      = min;
          gpsSec      = sec;
          float distance = getDistance(lat, lon, homeLatitude, homeLongitude);
          if(distance > maxDistance) {
            Serial.println("[ WARNING! ]");
            Serial.println(" = PET IS OUTSIDE THE GEOFENCE PERIMETER! = ");
            String link;
            link = "https://maps.google.com/maps?q=loc:";
            //link += String(gpsLat) + "," + String(gpsLon);
            link += String(gpsLatString) + "," + String(gpsLonString);
            mapsLink = link;
            gpsPerimeter  = false;
            sendGPSTelemetry();
            telemetryLED();
            telemetryLED();
          } else{
            gpsPerimeter = true;
            Serial.println("[ OKAY ]");
            Serial.println(" = PET IS WITHIN THE GEOFENCE PERIMETER = ");
            locatingLED();
            locatingLED();
          }
          break;
      }
      digitalWrite(LED_PIN, !digitalRead(LED_PIN));
      locatingLED();
      delay(1000);
    }
    delay(10000);
    //disableGPS();  //uncomment this if dont want to use gps and conserve battery

    if (Firebase.ready() && (millis() - sendDataPrevMillis > timerDelay || sendDataPrevMillis == 0)){
      //startLED();
      String link;
      link = "https://maps.google.com/maps?q=loc:";
      // //link += String(gpsLat) + "," + String(gpsLon);
      link += String(gpsLatString) + "," + String(gpsLonString);
      mapsLink = link;
      sendGPSTelemetry();
      telemetryLED();
      telemetryLED();
    }
    

    //}


}
    

void bleTask(){
  // Create the BLE Device
  BLEDevice::init("PawTracker v.1");

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a BLE Characteristic
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY |
                      BLECharacteristic::PROPERTY_INDICATE
                    );

  pCharacteristic->setCallbacks(new MyCallbacks());
  // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.descriptor.gatt.client_characteristic_configuration.xml
  // Create a BLE Descriptor
  pCharacteristic->addDescriptor(new BLE2902());

  // Start the service
  pService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0);  // set value to 0x00 to not advertise this parameter
  BLEDevice::startAdvertising();
  Serial.println(F("Waiting a client connection to notify..."));
}

void telemetryTask() {
  String receivedData;
  String spaces = " ";
  String noSpace = "";
  String email;
  String password;
  String wifiName;
  String wifiPass;
  receivedData = read_String(wifiAddr);
  if(receivedData.length() > 0){
    petName = getValue(receivedData, ',', 0);
    email = getValue(receivedData, ',', 1);
    password = getValue(receivedData, ',', 2);
    // int countEmail = email.length();
    // int countPass = password.length();
    // Serial.print("String count before: ");
    // Serial.print(countEmail);
    // Serial.print(" - ");
    // Serial.println(countPass);
    //String homeAddress = getValue(receivedData, ',', 3);
    homeLatitude = getValue(receivedData, ',', 3).toFloat();
    homeLongitude = getValue(receivedData, ',',4).toFloat();
    maxDistance = getValue(receivedData, ',', 5).toFloat();
    wifiName = getValue(receivedData, ',', 6);
    wifiPass = getValue(receivedData, ',', 7);
    email.replace(spaces, noSpace);
    password.replace(spaces, noSpace);
    wifiName.replace(spaces, noSpace);
    wifiPass.replace(spaces, noSpace);
    // int countEmail2 = email.length();
    // int countPass2 = password.length();
    // Serial.print("String count after: ");
    // Serial.print(countEmail2);
    // Serial.print(" - ");
    // Serial.println(countPass2);
    USER_EMAIL = email;
    USER_PASSWORD = password; 
    WIFI_NETWORK = wifiName;
    WIFI_PASSWORD = wifiPass;
    Serial.println("= Stored Data =");
    Serial.println(receivedData);
    // Serial.print("EMAIL: ");
    // Serial.println(USER_EMAIL);
    // Serial.print("PASSWORD: ");
    // Serial.println(USER_PASSWORD);
    
    // petName = namePet;
    // USER_EMAIL = userEmail;
    // USER_PASSWORD = userPassword;
    // homeLatitude = homeGpsLat.toFloat();
    // homeLongitude = homeGpsLon.toFloat();
    // maxDistance = fencePerimeter.toFloat();
    Serial.println(F(" = Global variables UPDATED= "));
    telemetryMode = 1;  
  }
  else{
      Serial.println(F("NO DATA STORED!!"));
      telemetryMode = 0;
  }
}

String read_String(int add){
  char data[1000];
  int len = 0;
  unsigned char k;
  k = EEPROM.read(add);
  while(k != '\0' && len< 1000){
    k = EEPROM.read(add+len);
    data[len] = k;
    len++;
  }
  data[len] = '\0';
  return String(data);
}

String getValue(String data, char separator, int index){
  int found = 0;
  int strIndex[] = {0, -1};
  int maxIndex = data.length()-1;

  for(int i=0; i<=maxIndex && found <=index; i++){
    if(data.charAt(i)==separator || i==maxIndex){
      found++;
      strIndex[0] = strIndex[1]+1;
      strIndex[1] = (i==maxIndex) ? i+1 : i;
    }
  }
  return found>index ? data.substring(strIndex[0], strIndex[1]) : "";
}

void connectToNetwork(){
    // Set-up modem  power pin
  pinMode(PWR_PIN, OUTPUT);
  digitalWrite(PWR_PIN, HIGH);
  delay(10);
  digitalWrite(PWR_PIN, LOW);
  delay(1010); //Ton 1sec
  digitalWrite(PWR_PIN, HIGH);

  //wait_till_ready();
  Serial.println("Waiting till modem ready...");
  delay(4510); 
  SerialMon.println("Wait...");
  SerialAT.begin(115200, SERIAL_8N1, PIN_RX, PIN_TX);
  modem.setBaud(115200);
  modem.begin();
  delay(10000);
  
  if (!modem.restart()) {
    SerialMon.println(F(" [fail]"));
    SerialMon.println(F("************************"));
    SerialMon.println(F(" Is your modem connected properly?"));
    SerialMon.println(F(" Is your serial speed (baud rate) correct?"));
    SerialMon.println(F(" Is your modem powered on?"));
    SerialMon.println(F(" Do you use a good, stable power source?"));
    SerialMon.println(F(" Try useing File -> Examples -> TinyGSM -> tools -> AT_Debug to find correct configuration"));
    SerialMon.println(F("************************"));
    delay(10000);
    //return;
  }
  SerialMon.println(F("[OK] was able to open modem"));
  String modemInfo = modem.getModemInfo();
  SerialMon.println("Modem details: ");
  SerialMon.println(modemInfo);

  SerialMon.println("Waiting for network...");
  if (!modem.waitForNetwork()) {
    SerialMon.println(" fail");
    delay(10000);
    //return;
  }
  SerialMon.println("Wait for network: Success");

  if (modem.isNetworkConnected()) {
    SerialMon.println("Network connected");
  }

  SerialMon.print("Step 4: Waiting for network...");
  if (!modem.waitForNetwork(1200000L)) {
    SerialMon.println(F(" [fail] while waiting for network"));
    SerialMon.println(F("************************"));
    SerialMon.println(F(" Is your sim card locked?"));
    SerialMon.println(F(" Do you have a good signal?"));
    SerialMon.println(F(" Is antenna attached?"));
    SerialMon.println(F(" Does the SIM card work with your phone?"));
    SerialMon.println(F("************************"));
    delay(10000);
    //return;
  }
  SerialMon.println(F("Found network: [OK]"));

  SerialMon.print("About to set network mode: ");
  /*
  2 Automatic
  13 GSM only
  38 LTE only
  51 GSM and LTE only
* * * */
  // Might not be needed for your carrier 
  //modem.setNetworkMode(51);  // Connect to Network OKAY!
  modem.setNetworkMode(51);  // Connect to Network OKAY!
  delay(3000);

  //SerialMon.print("Step 6: About to set network mode: to CAT=M");
  // Might not be needed for your carrier 
  /*
  1 CAT-M
  2 NB-Iot
  3 CAT-M and NB-IoT
* * */
  modem.setPreferredMode(2); // Connect to Network OKAY!
  delay(500);

  Serial.print(F("Waiting for network..."));
  if (!modem.waitForNetwork(60000L))
  {
    Serial.println(" fail");
    modemRestart();
    delay(1000);
  }
  Serial.println(" OK");

  Serial.print("Signal quality:");
  Serial.println(modem.getSignalQuality());
  delay(3000);

  // // GPRS connection parameters are usually set after network registration
  SerialMon.println("Step 7: Connecting to Globe's APN at LTE Mode Only (channel--> 38): ");
  SerialMon.println(apn);

  while(1){
    networkLED();
    if (!modem.gprsConnect(apn, gprsUser, gprsPass)) {
      SerialMon.println("Cannot connect to network! Trying again.");
      SerialMon.println(F(" [fail]"));
      SerialMon.println(F("************************"));
      SerialMon.println(F(" Is GPRS enabled by network provider?"));
      SerialMon.println(F(" Try checking your card balance."));
      SerialMon.println(F("************************"));
      delay(10000);
    }
    else {
      SerialMon.println("Network Connection = OK");
      SerialMon.println("Now Connecting to Firebase!");
      networkLED();
      networkLED();
      networkLED();
      // configTime(0, 0, ntpServer);            //Configure Time Server
      // connectToFirebase();  // uncomment this after
      break;
    }
  }
}
