#if defined(ESP32)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#endif

//========================================================================================================//
#include <Arduino.h>
#include <TinyGPSPlus.h>
// Set serial for debug console (to the Serial Monitor, default speed 115200)
#define SerialMon Serial
#define SerialAT Serial1

#define TINY_GSM_MODEM_SIM7000
#define TINY_GSM_RX_BUFFER 1024 // Set RX buffer to 1Kb
#define SerialAT Serial1

// See all AT commands, if wanted
// #define DUMP_AT_COMMANDS

// set GSM PIN, if any
#define GSM_PIN ""

// Your GPRS credentials, if any
const char apn[]  = "internet.globe.com.ph";     //SET TO YOUR APN
const char gprsUser[] = "";
const char gprsPass[] = "";

#include <TinyGsmClient.h>
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

#define uS_TO_S_FACTOR      1000000ULL  // Conversion factor for micro seconds to seconds
#define TIME_TO_SLEEP       60          // Time ESP32 will go to sleep (in seconds)

#define UART_BAUD           9600
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
#define USER_EMAIL "pawtracker1@gmail.com"
#define USER_PASSWORD "Pawtracker111!"

// Insert RTDB URLefine the RTDB URL
#define DATABASE_URL "https://pawtrackeriot-default-rtdb.asia-southeast1.firebasedatabase.app/"
//========================================================================================================//

#define homeLatitude        14.29736
#define homeLongitude       120.7885       

// #define newLatitude         14.274140
// #define newLongitude        120.762273
//14.274140, 120.762273
//14.273844141402016, 120.76228240892087
const float maxDistance = 50;
TinyGPSPlus gpsCalculate;
//========================================================================================================//
//WiFi Connectivity FOR TESTING PURPOSES ONLY!
#define WIFI_NETWORK "XPN-4014A7"
#define WIFI_PASSWORD "NCTV082222"
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
String latPath    = "/latitude";
String lonPath   = "/longitude";
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
//unsigned long timerDelay = 180000; //every 3mins
//unsigned long timerDelay = 120000; //every 2mins
unsigned long timerDelay = 3600000; //every 1hour
//========================================================================================================//

//GPS Variables
float gpsLat      = 0;
float gpsLon      = 0;
String gpsLatString;
String gpsLonString;
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
const char* petName = "My Pet";
String mapsLink;
bool isNetworkConnected = false;

void enableGPS(void)
{
    // Set SIM7000G GPIO4 LOW ,turn on GPS power
    // CMD:AT+SGPIO=0,4,1,1
    // Only in version 20200415 is there a function to control GPS power
    Serial.println("Start positioning . Make sure to locate outdoors.");
    Serial.println("The blue indicator light flashes to indicate positioning.");
    modem.sendAT("+SGPIO=0,4,1,1");
    if (modem.waitResponse(10000L) != 1) {
        DBG(" SGPIO=0,4,1,1 false ");
    }
    modem.enableGPS();
}

void connectToWiFi(){
  Serial.println("= Connecting to Wifi =");
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_NETWORK, WIFI_PASSWORD);

  unsigned long startConnectionAttempt = millis();
  while(WiFi.status() != WL_CONNECTED && millis() - startConnectionAttempt < WIFI_TIMEOUT_MS){
    networkLED();
    Serial.println("Trying to connect...");
    delay(100);
  }

  if(WiFi.status() != WL_CONNECTED){
    Serial.println("WiFi Connection Failed!");
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
    Serial.println("Waiting till modem ready...");
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
  Serial.println("= Setting-up Cloud DB =");
  //Firebase Connect
  config.api_key = API_KEY;               // Assign the api key (required)
  auth.user.email = USER_EMAIL;           // Assign the user sign in credentials
  auth.user.password = USER_PASSWORD;
  config.database_url = DATABASE_URL;     // Assign the RTDB URL (required)
  Firebase.reconnectWiFi(true);
  fbdo.setResponseSize(4096);
  config.token_status_callback = tokenStatusCallback; 
  config.max_token_generation_retry = 5;  // Assign the maximum retry of token generation
  
  Serial.println("= Establishing Connection to Cloud DB =");
  Firebase.begin(&config, &auth);         // Initialize the library with the Firebase authen and config

  Serial.println("Getting User UID");     // Getting the user UID might take a few seconds
  while ((auth.token.uid) == "") {
    Serial.print('.');
    delay(1000);
  }

  uid = auth.token.uid.c_str();   
  Serial.println("= PawTracker Device Registered! =");        // Print user UID
  Serial.print("User UID: ");
  Serial.println(uid);
  databasePath = "/UsersData/" + uid + "/readings"; // Update database path
}

void sendGPSTelemetry(){
    Serial.println("");
    Serial.println("");
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
    json.set(latPath.c_str(), String(gpsLatString));
    json.set(lonPath.c_str(), String(gpsLonString));
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
    Serial.println("= Setting up PawTracker GPS Device =");
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
    //Power the coomunication module
    modemPowerOn();
    SerialAT.begin(UART_BAUD, SERIAL_8N1, PIN_RX, PIN_TX);
    //connectToNetwork();
    connectToWiFi();       //FOR TESTING PURPOSES ONLY!!
    configTime(0, 0, ntpServer);            //Configure Time Server
    connectToFirebase();
    delay(10000);
}


void loop()
{
    if (!modem.testAT()) {
        Serial.println("Failed to restart modem, attempting to continue without restarting");
        modemRestart();
        return;
    }
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

    while(1){
      Serial.println("Trying to fetch GPS location!");
      Serial.println();
      if (modem.getGPS(&lat, &lon, &speed, &alt, &vsat, &usat, &accuracy,
                    &year, &month, &day, &hour, &min, &sec)) {
          Serial.println("The location has been locked, the latitude and longitude are:");
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
          petName = "My Pet";
          float distance = getDistance(lat, lon, homeLatitude, homeLongitude);
          //float distance = getDistance(lat, lon, newLatitude, newLongitude);  
          if(distance > maxDistance) {
            Serial.println("[ WARNING! ]");
            Serial.println(" = PET IS OUTSIDE THE GEOFENCE PERIMETER! = ");
            String link;
            link = "http://maps.google.com/maps?q=loc:";
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
      link = "http://maps.google.com/maps?q=loc:";
      //link += String(gpsLat) + "," + String(gpsLon);
      link += String(gpsLatString) + "," + String(gpsLonString);
      mapsLink = link;
      sendGPSTelemetry();
      telemetryLED();
      telemetryLED();
    }

}

void connectToNetwork(){
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
    return;
  }
  SerialMon.println(F("Step 2: [OK] was able to open modem"));
  String modemInfo = modem.getModemInfo();
  SerialMon.println("Step 3: Modem details: ");
  SerialMon.println(modemInfo);

  SerialMon.println("Waiting for network...");
  if (!modem.waitForNetwork()) {
    SerialMon.println(" fail");
    delay(10000);
    return;
  }
  SerialMon.println(" success");

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
    return;
  }
  SerialMon.println(F("Found network: [OK]"));

  SerialMon.print("Step 5: About to set network mode: ");
  // Might not be needed for your carrier 
  modem.setNetworkMode(38);
  delay(3000);

  SerialMon.print("Step 6: About to set network mode: to CAT=M");
  // Might not be needed for your carrier 
  //modem.setPreferredMode(2);
  //delay(500);

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

  // GPRS connection parameters are usually set after network registration
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
      //configTime(0, 0, ntpServer);            //Configure Time Server
      //connectToFirebase();  // uncomment this after
      break;
    }
  }
}
