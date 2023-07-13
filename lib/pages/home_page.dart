import 'package:flutter/material.dart';
import 'package:zebrautility/ZebraPrinter.dart';
import 'package:zebrautility/zebrautility.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ZebraPrinter zebraPrinter;

  final String _macAddress = "0C:EC:80:ED:3E:96";

  String _status = "NOT CONNECTED YET";

  Color _color = Colors.grey;

  int _darkness = 100;

  List<int> list = [-99, -75, -50, -25, 0, 25, 50, 75, 100, 125, 150, 175, 200];

  EnumMediaType _mediaType = EnumMediaType.Journal;

  String template = """
    ^XA
    ^FX impresion invertida.
    ^POI
    ^FX LONGITUD DE 4CM
    ^LL600

    ^FX Seccion principal con logos? y con titulo.
    ^CF0,30

    ^FO50,50^FDBOLETA DE INFRACCION^FS
    ^CF0,20
    ^FO50,115^FDFecha de infraccion: 2023-06-15 a las 14:50:24^FS
    ^FO50,135^FDPlaca: PRUEBA^FS
    ^FO50,155^FDNumero de serie: SERIE420^FS
    ^FO50,175^FDTarjeta de circulacion: TARJETADECIRCULACION^FS
    ^FO50,200^GB500,3,3^FS
    ^FO50,225^FDDias de sancion: 5^FS
    ^FO50,245^FDPuntos de licencia: 1^FS
    ^FO50,270^GB500,3,3^FS
    
    ^FO250,300^
    ^BQN,2,6,H,7
    ^FDHM,Ahttp://estrados.cdmx.gob.mx^FS

    ^XZ
  """;

  @override
  void initState() {
    initializePrinter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("ZEBRA PRUEBA"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'PRUEBA DE IMPRESION ZEBRA 👻',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'ESTATUS DE LA IMPRESORA: $_status',
              style: TextStyle(
                  color: _color, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'MEDIA TYPE: $_mediaType',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'DARKNESS: $_darkness',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
              style: OutlinedButton.styleFrom(
                  textStyle: const TextStyle(color: Colors.black),
                  backgroundColor: Colors.black12),
              onPressed: () => disconnectPrinter(),
              child: const Text('DISCONNECT'),
            ),
            ElevatedButton(
              style: OutlinedButton.styleFrom(
                  textStyle: const TextStyle(color: Colors.white),
                  backgroundColor: Colors.purpleAccent),
              onPressed: () => _printTest(),
              child: const Text('PRINT TEST'),
            ),
            ElevatedButton(
              style: OutlinedButton.styleFrom(
                  textStyle: const TextStyle(color: Colors.white),
                  backgroundColor: Colors.greenAccent),
              onPressed: () => calibratePrinter(),
              child: const Text('CALIBRATE'),
            ),
            ElevatedButton(
              style: OutlinedButton.styleFrom(
                  textStyle: const TextStyle(color: Colors.white),
                  backgroundColor: Colors.pinkAccent),
              onPressed: () => rotateZpl(),
              child: const Text('ROTAR zpl'),
            ),
            DropdownButton<int>(
              value: _darkness,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (int? value) {
                // This is called when the user selects an item.
                setState(() {
                  _darkness = value!;
                  setDarkness();
                });
              },
              items: list.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    style: OutlinedButton.styleFrom(
                        textStyle: const TextStyle(color: Colors.black),
                        backgroundColor: Colors.black12),
                    onPressed: () => setMediaType(EnumMediaType.Label),
                    child: const Text('LABEL'),
                  ),
                  TextButton(
                    style: OutlinedButton.styleFrom(
                        textStyle: const TextStyle(color: Colors.black),
                        backgroundColor: Colors.black12),
                    onPressed: () => setMediaType(EnumMediaType.BlackMark),
                    child: const Text('BLACKMARK'),
                  ),
                  TextButton(
                    style: OutlinedButton.styleFrom(
                        textStyle: const TextStyle(color: Colors.black),
                        backgroundColor: Colors.black12),
                    onPressed: () => setMediaType(EnumMediaType.Journal),
                    child: const Text('JOURNAL'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: _connectPrinter,
        child: const Text("CONNECT"),
      ),
    );
  }

  void initializePrinter() async {
    print("initializing ...");
    zebraPrinter = await Zebrautility.getPrinterInstance(
      onPrinterFound: onPrinterFound,
      onDiscoveryError: onDiscoveryError,
      onPrinterDiscoveryDone: onPrinterDiscoveryDone,
      onChangePrinterStatus: onChangePrinterStatus,
      onPermissionDenied: onPermissionDenied,
    );

    // zebraPrinter.discoveryPrinters();
  }

  void onPrinterFound(String name, String ipAddress, bool isWifi) {
    printSuccess(
        "The following printer was found: $name, with ip: $ipAddress, is it wifi?: $isWifi");
    //
  }

  void onPrinterDiscoveryDone() {
    printSuccess("on Printer Discovery Done");
    //
  }

  void onChangePrinterStatus(String status, String color) {
    _status = status;

    switch (color) {
      case "G":
        _color = Colors.green;
        break;
      case "Y":
        _color = Colors.yellow;
        break;
      case "R":
        _color = Colors.red;
        break;
      default:
        _color = Colors.grey;
    }

    printWarning(
        "on Change Printer Status with status: $status and color: $color");

    setState(() {});
    //
  }

  void onDiscoveryError(int errorCode, String errorText) {
    printError(
        "on Discovery Error with code: $errorCode and the following error: $errorText");
    //
  }

  void onPermissionDenied() {
    printError("on Permission Denied");
    //
  }

  void disconnectPrinter() {
    zebraPrinter.disconnect();
    //
  }

  void printSuccess(String text) {
    print('\x1B[32m$text\x1B[0m');
  }

  void printWarning(String text) {
    print('\x1B[33m$text\x1B[0m');
  }

  void printError(String text) {
    print('\x1B[31m$text\x1B[0m');
  }

  void setMediaType(EnumMediaType enumMediaType) {
    _mediaType = enumMediaType;
    zebraPrinter.setMediaType(enumMediaType);
  }

  void _connectPrinter() {
    print("_connectPrinter");

    // changing discover process for connecting directly
    // zebraPrinter.discoveryPrinters();

    if (_status != "Connected") {
      // TODO: EVITAR QUE LA SIGUIENTE LINEA SE LLAME SI YA HAY UNA CONEXION PENDIENTE
      zebraPrinter.connectToPrinter(_macAddress);
    } else {
      printSuccess("PRINTER IS ALREADY CONNECTED");
    }
  }

  void calibratePrinter() {
    zebraPrinter.calibratePrinter();
  }

  void setDarkness() {
    zebraPrinter.setDarkness(_darkness);
  }

  void _printTest() {
    print(template);
    zebraPrinter.print(template);
  }

  void rotateZpl() {
    print("ROTATE");
    zebraPrinter.rotate();
  }
}
