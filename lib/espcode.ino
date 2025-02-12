#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

double flow;
unsigned long pulse_freq = 0;
unsigned long prev_pulse_freq = 0;

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;
int count = 0;
int send = 0;

#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define uS_TO_S_FACTOR 1000000ULL

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
  };

  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
    for (int i = 0; i < 5; i++) {
      digitalWrite(2, HIGH);
      delay(100);
      digitalWrite(2, LOW);
      delay(100);
    }
    ESP.restart();
  }
};

void setup() {
  Serial.begin(9600);

  pinMode(7, INPUT);
  attachInterrupt(digitalPinToInterrupt(7), pulse, RISING);

  BLEDevice::init("ESP32_BLE");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService* pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE);

  setCpuFrequencyMhz(80);

  pCharacteristic->setValue(String(count));
  pService->start();

  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  Serial.println("Waiting for a client connection to notify...");
  pinMode(2, OUTPUT);
}

void loop() {
  if (deviceConnected) {
    // flow = 0.00225 * (pulse_freq - prev_pulse_freq) * 33.814;
    flow = (pulse_freq - prev_pulse_freq) * 2;

    prev_pulse_freq = pulse_freq;

    if (flow >= 1) {
      send = int(trunc(flow * 10));
    } else {
      send = 0;
    }
    
    pCharacteristic->setValue(String(40));
    pCharacteristic->notify();
    Serial.println("Sent value : " + String(1));
    digitalWrite(2, HIGH);
    delay(1000);
    digitalWrite(2, LOW);
    delay(1000);
  }
  delay(5000);
}

void pulse() {
  pulse_freq++;
}
