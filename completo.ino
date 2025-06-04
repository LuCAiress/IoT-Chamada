#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <SPI.h>
#include <MFRC522.h>
#include <ThreeWire.h>
#include <RtcDS1302.h> // Rtc by Makuna


const char* ssid = "Lucas's iPhone";
const char* password = "12345678";
const char* serverName = "http://172.20.10.2:8000/db_conn"; // IP do seu servidor FastAPI

#define SS_PIN  21   // Ajuste conforme seu circuito
#define RST_PIN 2  // Ajuste conforme seu circuito
#define GREEN_LED 26 // Agora usando GPIO 26 para o pino do LED verde
#define RED_LED 25   // Agora usando GPIO 27 para o pino do LED vermelho
#define DS1302_RST 12 // Ajuste para o pino SCLK do DS1302
#define DS1302_DAT 13 // Agora usando GPIO 17 para o IO do DS1302
#define DS1302_CLK 14  // Ajuste para o pino CE do DS1302

MFRC522 mfrc522(SS_PIN, RST_PIN);
ThreeWire myWire(DS1302_DAT, DS1302_CLK, DS1302_RST);
RtcDS1302<ThreeWire> Rtc(myWire);

void setup() {
  Serial.begin(115200);
  SPI.begin();
  mfrc522.PCD_Init();

  pinMode(GREEN_LED, OUTPUT);
  pinMode(RED_LED, OUTPUT);
  digitalWrite(GREEN_LED, LOW);
  digitalWrite(RED_LED, LOW);

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Conectando ao WiFi...");
  }
  Serial.println("WiFi conectado!");

  Rtc.Begin();
  // Se quiser setar manualmente a data/hora, descomente a linha abaixo:
  // RtcDateTime customDateTime(2025, 5, 26, 18, 30, 0); // ano, mês, dia, hora, minuto, segundo
  // Rtc.SetDateTime(customDateTime);
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) return;
  if (!mfrc522.PICC_IsNewCardPresent() || !mfrc522.PICC_ReadCardSerial()) return;

  String rfid = "";
  for (byte i = 0; i < mfrc522.uid.size; i++) {
    if (mfrc522.uid.uidByte[i] < 0x10) rfid += "0";
    rfid += String(mfrc522.uid.uidByte[i], HEX);
  }
  rfid.toUpperCase();

  RtcDateTime now = Rtc.GetDateTime();
  char horaChar[120];
  snprintf(horaChar, sizeof(horaChar), "%04u-%02u-%02u %02u:%02u:%02u",
           now.Year(), now.Month(), now.Day(), now.Hour(), now.Minute(), now.Second());
  String hora = String(horaChar);

  HTTPClient http;
  http.begin(serverName);
  http.addHeader("Content-Type", "application/json");

  StaticJsonDocument<200> doc;
  doc["id_user"] = rfid;
  doc["hora"] = hora;

  String requestBody;
  serializeJson(doc, requestBody);
  Serial.print(requestBody);

  int httpResponseCode = http.POST(requestBody);
  if (httpResponseCode > 0) {
    Serial.println(httpResponseCode);
    Serial.println(http.getString());
    digitalWrite(GREEN_LED, HIGH);
    digitalWrite(RED_LED, LOW);
    delay(1000);
    digitalWrite(GREEN_LED, LOW);
  } else {
    Serial.print("Erro na requisição: ");
    Serial.println(httpResponseCode);
    digitalWrite(RED_LED, HIGH);
    digitalWrite(GREEN_LED, LOW);
    delay(1000);
    digitalWrite(RED_LED, LOW);
  }
  http.end();
  delay(1000); // Evita múltiplas leituras do mesmo cartão
}