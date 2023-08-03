#include "EEPROM.h"
#define EEPROM_SIZE 128

#include <WiFi.h>

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

#define orangeLED           12
#define whiteLED            12

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;

const int ledPin = 12;
const int modeAddr = 0;
const int wifiAddr = 10;
const int dataAddr = 11;

int modeIdx;

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
      Serial.println("Storing Received Data to EEPROM!");
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


void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  pinMode(ledPin, OUTPUT);
  pinMode(whiteLED, OUTPUT);
  pinMode(orangeLED, OUTPUT);
  
  if(!EEPROM.begin(EEPROM_SIZE)){
    delay(1000);
  }

//   for (int i = 0 ; i < EEPROM.length() ; i++) {
//   EEPROM.write(i, 0);
// }

  

  modeIdx = EEPROM.read(modeAddr);
  Serial.print("modeIdx : ");
  Serial.println(modeIdx);

  EEPROM.write(modeAddr, modeIdx !=0 ? 0 : 1);
  //Uncomment for EEPROM RESET
  // EEPROM.write(modeAddr, 1);
  // EEPROM.write(wifiAddr, 0);
  // EEPROM.write(dataAddr, 0);
  EEPROM.commit();

  if(modeIdx != 0){
    digitalWrite(ledPin, true);
    Serial.println("Calibration MODE");
    bleTask();
  }else{
    //WIFI MODE
    digitalWrite(ledPin, false);
    Serial.println("Telemetry MODE");
    wifiTask();
    
  }

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
  Serial.println("Waiting a client connection to notify...");
}

void wifiTask() {
  Serial.println("Accessing Data!");
  String receivedData;
  receivedData = read_String(wifiAddr);
  Serial.println("Data stored to String!");
  //receivedData = read_String(dataAddr);
  if(receivedData.length() > 0){
    // String wifiName = getValue(receivedData, ',', 0);
    // String wifiPassword = getValue(receivedData, ',', 1);

    Serial.print("STORED DATA IN MEMORY: ");
    Serial.println(receivedData);    
    String petName = getValue(receivedData, ',', 0);
    String userEmail = getValue(receivedData, ',', 1);
    String userPassword = getValue(receivedData, ',', 2);
    String homeAddress = getValue(receivedData, ',', 3);
    String homeGpsLat = getValue(receivedData, ',', 4);
    String homeGpsLon = getValue(receivedData, ',', 5);
    String fencePerimeter = getValue(receivedData, ',', 6);
    
    if(userEmail.length() >0 && userPassword.length() > 0){
      Serial.print("Pet: ");
      Serial.println(petName);
      Serial.print("Email: ");
      Serial.println(userEmail);
      Serial.print("Password: ");
      Serial.println(userPassword);
      Serial.print("Home Address: ");
      Serial.println(homeAddress);
      Serial.print("Home Latitude: ");
      Serial.println(homeGpsLat);
      Serial.print("Home Longitude: ");
      Serial.println(homeGpsLon);
      Serial.print("Fence Perimeter: ");
      Serial.println(fencePerimeter);
    }    

    // if(wifiName.length() > 0 && wifiPassword.length() > 0){
    //   Serial.print("WifiName : ");
    //   Serial.println(wifiName);

    //   Serial.print("wifiPassword : ");
    //   Serial.println(wifiPassword);

    //   WiFi.begin(wifiName.c_str(), wifiPassword.c_str());
    //   Serial.print("Connecting to Wifi");
    //   while(WiFi.status() != WL_CONNECTED){
    //     Serial.print(".");
    //     delay(300);
    //   }
    //   Serial.println();
    //   Serial.print("Connected with IP: ");
    //   Serial.println(WiFi.localIP());
    // }
  }
  else{
          Serial.println("NO DATA STORED!!");
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

void loop() {
  // put your main code here, to run repeatedly:
  locatingLED();
  delay(3000);
  telemetryLED();

}