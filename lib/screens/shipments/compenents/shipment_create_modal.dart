import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kazakhi_auto_admin/api/api.dart';
import 'package:kazakhi_auto_admin/screens/shipments/bloc/shipments_bloc.dart';
import 'package:kazakhi_auto_admin/screens/users/components/user_search_widget.dart';

class PickedFileItem {
  final PlatformFile file;
  final String uniqueId;

  PickedFileItem({required this.file, String? id})
    : uniqueId =
          id ??
          '${DateTime.now().microsecondsSinceEpoch}_${file.name}_${file.size}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PickedFileItem &&
          runtimeType == other.runtimeType &&
          uniqueId == other.uniqueId;

  @override
  int get hashCode => uniqueId.hashCode;
}

class ShipmentCreateModal extends StatefulWidget {
  final Map<String, dynamic>? shipmentData;

  const ShipmentCreateModal({super.key, this.shipmentData});

  @override
  State<ShipmentCreateModal> createState() => _ShipmentCreateModalState();
}

class _ShipmentCreateModalState extends State<ShipmentCreateModal> {
  bool get isEditMode => widget.shipmentData != null;

  late Map<String, dynamic> _initialShipmentData;
  List<PickedFileItem> _pickedCarFiles = [];
  List<PickedFileItem> _pickedPortFiles = [];
  List<PickedFileItem> _pickedInvoiceFiles = [];
  List<PickedFileItem> _pickedLocationScreenshots = [];

  // NEW: State for Carfax report
  List<PickedFileItem> _pickedCarfaxFiles = [];
  List<String> _uploadedCarfaxFileUrls = [];

  List<String> _uploadedCarImageUrls = [];
  List<String> _uploadedPortImageUrls = [];
  List<String> _uploadedInvoiceFileUrls = [];
  List<Map<String, dynamic>> _uploadedLocationScreenShots = [];

  final TextEditingController _internationalPortController =
      TextEditingController();
  final TextEditingController _receivingPortController =
      TextEditingController();
  final TextEditingController _containerNumberController =
      TextEditingController();
  final TextEditingController _terminalController = TextEditingController();
  final TextEditingController _containerOpenDateController =
      TextEditingController();
  final TextEditingController _greenDateController = TextEditingController();
  final TextEditingController _containerEntryDateController =
      TextEditingController();

  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _paidController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  // NEW: Controller for location name
  final TextEditingController _locationNameController = TextEditingController();

  // Map для сопоставления английских значений статусов с русскими для отображения
  final Map<String, String> _statusTranslations = {
    'purchased': 'Приобретено',
    'in_transit': 'В пути',
    'arrived': 'Прибыло',
    'delivered': 'Доставлено',
  };
  String? selectedUserId; // NEW: Store selected user ID

  String? selectedUserEmail; // NEW: Store selected user ID
  // Английские значения статусов для DropdownButtonFormField (value)
  final List<String> _statusOptions = [
    'purchased',
    'in_transit',
    'arrived',
    'delivered',
  ];
  String _selectedStatus = 'purchased'; // Default status (English key)

  @override
  void initState() {
    super.initState();
    // Determine if we are in edit mode or create mode
    _initialShipmentData = widget.shipmentData ?? _getDefaultShipmentData();
    _initializeFieldsWithData(_initialShipmentData);
  }

  // Provides default empty/placeholder data for create mode.
  Map<String, dynamic> _getDefaultShipmentData() {
    return {
      "carInfo": {
        "vin": "",
        "brand": "",
        "model": "",
        "year": null, // Use null for numbers to indicate no value
        "carImages": [], // Expecting array of STRINGS for backend
      },
      "status": "purchased",
      "currentLocation": {"lat": null, "lng": null, "updatedAt": null},
      "invoice": {
        "fileUrl": "", // Expecting single string for fileUrl
      },
      // NEW: Default for pdfVinReport
      "pdfVinReport": {"fileUrl": ""},
      "paid": null,
      "balance": null,
      "internationalPort": "",
      "receivingPort": "",
      "containerNumber": "",
      "terminal": "",
      "containerOpenDate": null,
      "greenDate": null,
      "containerEntryDate": null,
      "_id": null,
      "statusHistory": [],
      "locationScreenShots": [], // Default to empty list
      "portImages": [], // Expecting array of STRINGS for backend
      "createdAt": null,
      "updatedAt": null,
      "__v": null,
    };
  }

  // Initializes controllers and lists with provided shipment data.
  void _initializeFieldsWithData(Map<String, dynamic> data) {
    // Ensure the initial status is one of the English keys from _statusOptions
    _selectedStatus =
        _statusOptions.contains(data["status"]) ? data["status"] : 'purchased';

    _vinController.text = data["carInfo"]?["vin"] ?? '';
    _brandController.text = data["carInfo"]?["brand"] ?? '';
    _modelController.text = data["carInfo"]?["model"] ?? '';
    _yearController.text = data["carInfo"]?["year"]?.toString() ?? '';
    selectedUserEmail = data['userEmail'] ?? null;
    selectedUserId = data['user'] ?? null;
    _internationalPortController.text = data["internationalPort"] ?? '';
    _receivingPortController.text = data["receivingPort"] ?? '';
    _containerNumberController.text = data["containerNumber"] ?? '';
    _terminalController.text = data["terminal"] ?? '';

    _containerOpenDateController.text = _formatDate(data["containerOpenDate"]);
    _greenDateController.text = _formatDate(data["greenDate"]);
    _containerEntryDateController.text = _formatDate(
      data["containerEntryDate"],
    );
    _uploadedCarImageUrls = List<String>.from(
      data["carInfo"]?["carImages"]?.map((e) => e.toString()).toList() ?? [],
    );

    _uploadedPortImageUrls = List<String>.from(
      data["portImages"]?.map((e) => e.toString()).toList() ?? [],
    );
    final dynamic invoiceFileUrl = data["invoice"]?["fileUrl"];
    _uploadedInvoiceFileUrls = []; // Clear previous, always single or empty
    if (invoiceFileUrl is String && invoiceFileUrl.isNotEmpty) {
      _uploadedInvoiceFileUrls.add(invoiceFileUrl);
    }
    // If it was somehow an array from initial data, take the first one if not empty
    else if (invoiceFileUrl is List && invoiceFileUrl.isNotEmpty) {
      _uploadedInvoiceFileUrls.add(invoiceFileUrl.first.toString());
    }

    // NEW: Initialize Carfax file URL
    final dynamic carfaxFileUrl = data["pdfVinReport"]?["fileUrl"];
    _uploadedCarfaxFileUrls = [];
    if (carfaxFileUrl is String && carfaxFileUrl.isNotEmpty) {
      _uploadedCarfaxFileUrls.add(carfaxFileUrl);
    } else if (carfaxFileUrl is List && carfaxFileUrl.isNotEmpty) {
      _uploadedCarfaxFileUrls.add(carfaxFileUrl.first.toString());
    }

    _paidController.text = data["paid"]?.toString() ?? '';
    _balanceController.text = data["balance"]?.toString() ?? '';

    // NEW: Initialize location name and screenshots
    if (data["locationScreenShots"] is List &&
        (data["locationScreenShots"] as List).isNotEmpty) {
      _uploadedLocationScreenShots = List<Map<String, dynamic>>.from(
        data["locationScreenShots"],
      );
      // Assuming you only want to display the name of the *first* screenshot
      _locationNameController.text =
          _uploadedLocationScreenShots.first["locationName"] ?? '';
    } else {
      _uploadedLocationScreenShots = [];
      _locationNameController.text = '';
    }
  }

  // Helper to format date strings or return empty if null.
  String _formatDate(dynamic dateString) {
    if (dateString != null && dateString.toString().isNotEmpty) {
      try {
        return DateFormat('yyyy-MM-dd').format(DateTime.parse(dateString));
      } catch (e) {
        return ''; // Handle invalid date format
      }
    }
    return '';
  }

  @override
  void dispose() {
    _vinController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _internationalPortController.dispose();
    _receivingPortController.dispose();
    _containerNumberController.dispose();
    _terminalController.dispose();
    _containerOpenDateController.dispose();
    _greenDateController.dispose();
    _containerEntryDateController.dispose();
    _paidController.dispose();
    _balanceController.dispose();
    _locationNameController.dispose(); // NEW: Dispose new controller
    super.dispose();
  }

  // Function to show a custom message box (instead of alert)
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Function to handle form submission

  void _submitShipment() async {
    if (!_validateRequiredFields()) {
      return;
    }

    _showMessage('Обработка данных...', isError: false);

    try {
      if (isEditMode) {
        await _updateShipment(widget.shipmentData!['_id']);
      } else {
        await _createShipment();
      }
    } catch (e) {
      _showMessage('Произошла ошибка: $e', isError: true);
    }
  }

  // Validate required fields
  bool _validateRequiredFields() {
    if (_vinController.text.isEmpty ||
        _brandController.text.isEmpty ||
        _modelController.text.isEmpty ||
        _yearController.text.isEmpty ||
        _internationalPortController.text.isEmpty ||
        _receivingPortController.text.isEmpty ||
        _paidController.text.isEmpty ||
        _balanceController.text.isEmpty ||
        (selectedUserId?.isEmpty ?? true)) {
      _showMessage(
        'Пожалуйста, заполните все обязательные поля.',
        isError: true,
      );
      return false;
    }
    return true;
  }

  // Create new shipment
  Future<void> _createShipment() async {
    _showMessage('Создание отправления...', isError: false);

    // Upload all new files
    final uploadedData = await _uploadAllFiles();
    if (uploadedData == null) return; // Upload failed

    // Prepare shipment data
    final Map<String, dynamic> shipmentData = _buildShipmentData(uploadedData);

    // Call API to create shipment
    final res = await ApiClient.postUnAuth('api/shipments/', shipmentData);
    log('Create shipment response: ${res.toString()}');

    if (res['success']) {
      _showMessage('Отправление успешно создано!', isError: false);
      Navigator.of(context).pop();
    } else {
      _showMessage(
        'Ошибка при создании отправления: ${res['message']}',
        isError: true,
      );
    }
  }

  // Update existing shipment
  Future<void> _updateShipment(containerId) async {
    _showMessage('Обновление отправления...', isError: false);

    // Only upload new files, keep existing ones
    final uploadedData = await _uploadNewFilesForUpdate();
    if (uploadedData == null) return; // Upload failed

    // Prepare shipment data with both existing and new files
    final Map<String, dynamic> shipmentData = _buildShipmentDataForUpdate(
      uploadedData,
    );

    // Call API to update shipment
    final dataToSend = Map.of(shipmentData)..remove('_id');

    final res = await ApiClient.postUnAuth(
      'api/shipments/' + containerId,
      dataToSend,
    );
    log(res.toString());
    log('Update shipment response: ${res.toString()}');

    if (res['success']) {
      _showMessage('Отправление успешно обновлено!', isError: false);
      Navigator.of(context).pop();
    } else {
      _showMessage(
        'Ошибка при обновлении отправления: ${res['message']}',
        isError: true,
      );
    }
  }

  // Upload all files for new shipment creation
  Future<Map<String, dynamic>?> _uploadAllFiles() async {
    try {
      // Upload car images
      List<String> carImageUrls = [];
      for (final item in _pickedCarFiles) {
        final url = await _uploadToServerWithRetry(item.file);
        if (url != null) {
          carImageUrls.add(url);
        } else {
          _showMessage(
            'Не удалось загрузить изображение автомобиля: ${item.file.name}',
            isError: true,
          );
          return null;
        }
      }

      // Upload port images
      List<String> portImageUrls = [];
      for (final item in _pickedPortFiles) {
        final url = await _uploadToServerWithRetry(item.file);
        if (url != null) {
          portImageUrls.add(url);
        } else {
          _showMessage(
            'Не удалось загрузить изображение порта: ${item.file.name}',
            isError: true,
          );
          return null;
        }
      }

      // Upload invoice file
      String? invoiceFileUrl;
      if (_pickedInvoiceFiles.isNotEmpty) {
        invoiceFileUrl = await _uploadFile(_pickedInvoiceFiles.first.file);
        if (invoiceFileUrl == null) {
          _showMessage(
            'Не удалось загрузить файл счета: ${_pickedInvoiceFiles.first.file.name}',
            isError: true,
          );
          return null;
        }
      }

      // NEW: Upload Carfax file
      String? carfaxFileUrl;
      if (_pickedCarfaxFiles.isNotEmpty) {
        carfaxFileUrl = await _uploadFile(_pickedCarfaxFiles.first.file);
        if (carfaxFileUrl == null) {
          _showMessage(
            'Не удалось загрузить файл Carfax: ${_pickedCarfaxFiles.first.file.name}',
            isError: true,
          );
          return null;
        }
      }

      // Upload location screenshots
      List<Map<String, dynamic>> locationScreenshots = [];
      if (_locationNameController.text.isNotEmpty &&
          _pickedLocationScreenshots.isNotEmpty) {
        for (final item in _pickedLocationScreenshots) {
          final url = await _uploadToServerWithRetry(item.file);
          if (url != null) {
            locationScreenshots.add({
              "locationName": _locationNameController.text,
              "url": url,
              "uploadedAt": DateTime.now().toIso8601String(),
            });
          } else {
            _showMessage(
              'Не удалось загрузить скриншот локации: ${item.file.name}',
              isError: true,
            );
            return null;
          }
        }
      }

      return {
        'carImages': carImageUrls,
        'portImages': portImageUrls,
        'invoiceFileUrl': invoiceFileUrl,
        'carfaxFileUrl': carfaxFileUrl, // NEW: Include Carfax URL
        'locationScreenshots': locationScreenshots,
      };
    } catch (e) {
      _showMessage('Ошибка при загрузке файлов: $e', isError: true);
      return null;
    }
  }

  // Upload only new files for update (keep existing ones)
  Future<Map<String, dynamic>?> _uploadNewFilesForUpdate() async {
    try {
      // Upload new car images (keep existing ones)
      List<String> newCarImageUrls = [];
      for (final item in _pickedCarFiles) {
        final url = await _uploadToServerWithRetry(item.file);
        if (url != null) {
          newCarImageUrls.add(url);
        } else {
          _showMessage(
            'Не удалось загрузить новое изображение автомобиля: ${item.file.name}',
            isError: true,
          );
          return null;
        }
      }

      // Upload new port images (keep existing ones)
      List<String> newPortImageUrls = [];
      for (final item in _pickedPortFiles) {
        final url = await _uploadToServerWithRetry(item.file);
        if (url != null) {
          newPortImageUrls.add(url);
        } else {
          _showMessage(
            'Не удалось загрузить новое изображение порта: ${item.file.name}',
            isError: true,
          );
          return null;
        }
      }

      // Upload new invoice file (replace existing one if provided)
      String? newInvoiceFileUrl;
      if (_pickedInvoiceFiles.isNotEmpty) {
        newInvoiceFileUrl = await _uploadFile(_pickedInvoiceFiles.first.file);
        if (newInvoiceFileUrl == null) {
          _showMessage(
            'Не удалось загрузить новый файл счета: ${_pickedInvoiceFiles.first.file.name}',
            isError: true,
          );
          return null;
        }
      }

      // NEW: Upload new Carfax file (replace existing one if provided)
      String? newCarfaxFileUrl;
      if (_pickedCarfaxFiles.isNotEmpty) {
        newCarfaxFileUrl = await _uploadFile(_pickedCarfaxFiles.first.file);
        if (newCarfaxFileUrl == null) {
          _showMessage(
            'Не удалось загрузить новый файл Carfax: ${_pickedCarfaxFiles.first.file.name}',
            isError: true,
          );
          return null;
        }
      }

      // Upload new location screenshots (add to existing ones)
      List<Map<String, dynamic>> newLocationScreenshots = [];
      if (_locationNameController.text.isNotEmpty &&
          _pickedLocationScreenshots.isNotEmpty) {
        for (final item in _pickedLocationScreenshots) {
          final url = await _uploadToServerWithRetry(item.file);
          if (url != null) {
            newLocationScreenshots.add({
              "locationName": _locationNameController.text,
              "url": url,
              "uploadedAt": DateTime.now().toIso8601String(),
            });
          } else {
            _showMessage(
              'Не удалось загрузить новый скриншот локации: ${item.file.name}',
              isError: true,
            );
            return null;
          }
        }
      }

      return {
        'newCarImages': newCarImageUrls,
        'newPortImages': newPortImageUrls,
        'newInvoiceFileUrl': newInvoiceFileUrl,
        'newCarfaxFileUrl': newCarfaxFileUrl, // NEW: Include new Carfax URL
        'newLocationScreenshots': newLocationScreenshots,
      };
    } catch (e) {
      _showMessage('Ошибка при загрузке новых файлов: $e', isError: true);
      return null;
    }
  }

  // Build shipment data for creation
  Map<String, dynamic> _buildShipmentData(Map<String, dynamic> uploadedData) {
    final int? paidAmount = int.tryParse(_paidController.text);
    final int? balanceAmount = int.tryParse(_balanceController.text);

    return {
      "user": selectedUserId,
      "carInfo": {
        "vin": _vinController.text,
        "brand": _brandController.text,
        "model": _modelController.text,
        "year": int.tryParse(_yearController.text) ?? 0,
        "carImages": uploadedData['carImages'] ?? [],
      },
      "status": _selectedStatus,
      "invoice": {"fileUrl": uploadedData['invoiceFileUrl']},
      // NEW: Build the pdfVinReport object
      "pdfVinReport": {"fileUrl": uploadedData['carfaxFileUrl']},
      "paid": paidAmount,
      "balance": balanceAmount,
      "internationalPort": _internationalPortController.text,
      "receivingPort": _receivingPortController.text,
      "containerNumber": _containerNumberController.text,
      "terminal": _terminalController.text,
      "containerOpenDate": _containerOpenDateController.text,
      "greenDate": _greenDateController.text,
      "containerEntryDate": _containerEntryDateController.text,
      "portImages": uploadedData['portImages'] ?? [],
      "locationScreenShots": uploadedData['locationScreenshots'] ?? [],
    };
  }

  // Build shipment data for update (combine existing and new files)
  Map<String, dynamic> _buildShipmentDataForUpdate(
    Map<String, dynamic> uploadedData,
  ) {
    final int? paidAmount = int.tryParse(_paidController.text);
    final int? balanceAmount = int.tryParse(_balanceController.text);

    // Combine existing and new car images
    List<String> allCarImages = List<String>.from(_uploadedCarImageUrls);
    allCarImages.addAll(uploadedData['newCarImages'] ?? []);

    // Combine existing and new port images
    List<String> allPortImages = List<String>.from(_uploadedPortImageUrls);
    allPortImages.addAll(uploadedData['newPortImages'] ?? []);

    // Use new invoice file URL if provided, otherwise keep existing
    String? finalInvoiceFileUrl =
        uploadedData['newInvoiceFileUrl'] ??
        (_uploadedInvoiceFileUrls.isNotEmpty
            ? _uploadedInvoiceFileUrls.first
            : null);

    // NEW: Use new Carfax file URL if provided, otherwise keep existing
    String? finalCarfaxFileUrl =
        uploadedData['newCarfaxFileUrl'] ??
        (_uploadedCarfaxFileUrls.isNotEmpty
            ? _uploadedCarfaxFileUrls.first
            : null);

    // Combine existing and new location screenshots
    List<Map<String, dynamic>> allLocationScreenshots =
        List<Map<String, dynamic>>.from(_uploadedLocationScreenShots);
    allLocationScreenshots.addAll(uploadedData['newLocationScreenshots'] ?? []);

    return {
      "_id":
          _initialShipmentData["_id"], // Important: include the ID for update
      "user": selectedUserId,
      "carInfo": {
        "vin": _vinController.text,
        "brand": _brandController.text,
        "model": _modelController.text,
        "year": int.tryParse(_yearController.text) ?? 0,
        "carImages": allCarImages,
      },
      "status": _selectedStatus,
      "invoice": {"fileUrl": finalInvoiceFileUrl},
      "pdfVinReport": {"fileUrl": finalCarfaxFileUrl}, // NEW: Add Carfax object
      "paid": paidAmount,
      "balance": balanceAmount,
      "internationalPort": _internationalPortController.text,
      "receivingPort": _receivingPortController.text,
      "containerNumber": _containerNumberController.text,
      "terminal": _terminalController.text,
      "containerOpenDate": _containerOpenDateController.text,
      "greenDate": _greenDateController.text,
      "containerEntryDate": _containerEntryDateController.text,
      "portImages": allPortImages,
      "locationScreenShots": allLocationScreenshots,
    };
  }

  // Clear picked files after successful upload
  void _clearPickedFiles() {
    setState(() {
      _pickedCarFiles.clear();
      _pickedPortFiles.clear();
      _pickedInvoiceFiles.clear();
      _pickedLocationScreenshots.clear();
      _pickedCarfaxFiles.clear(); // NEW: Clear Carfax files
    });
  }

  // Update local state with uploaded URLs (for UI updates)
  void _updateLocalStateWithUploadedFiles(
    Map<String, dynamic> uploadedData, {
    bool isUpdate = false,
  }) {
    setState(() {
      if (isUpdate) {
        // For updates, add new files to existing ones
        _uploadedCarImageUrls.addAll(uploadedData['newCarImages'] ?? []);
        _uploadedPortImageUrls.addAll(uploadedData['newPortImages'] ?? []);

        if (uploadedData['newInvoiceFileUrl'] != null) {
          _uploadedInvoiceFileUrls = [uploadedData['newInvoiceFileUrl']];
        }
        // NEW: Update Carfax URL
        if (uploadedData['newCarfaxFileUrl'] != null) {
          _uploadedCarfaxFileUrls = [uploadedData['newCarfaxFileUrl']];
        }

        _uploadedLocationScreenShots.addAll(
          uploadedData['newLocationScreenshots'] ?? [],
        );
      } else {
        // For creation, replace with new uploaded files
        _uploadedCarImageUrls = uploadedData['carImages'] ?? [];
        _uploadedPortImageUrls = uploadedData['portImages'] ?? [];

        if (uploadedData['invoiceFileUrl'] != null) {
          _uploadedInvoiceFileUrls = [uploadedData['invoiceFileUrl']];
        } else {
          _uploadedInvoiceFileUrls = [];
        }

        // NEW: Update Carfax URL
        if (uploadedData['carfaxFileUrl'] != null) {
          _uploadedCarfaxFileUrls = [uploadedData['carfaxFileUrl']];
        } else {
          _uploadedCarfaxFileUrls = [];
        }

        _uploadedLocationScreenShots =
            uploadedData['locationScreenshots'] ?? [];
      }

      // Clear picked files after processing
      _clearPickedFiles();
    });
  }

  Future<String?> _uploadToServer(PlatformFile file) async {
    if (file.bytes == null && file.path == null) {
      _showMessage('Данные файла не найдены.', isError: true);
      return null;
    }

    try {
      final bytes = kIsWeb ? file.bytes! : await File(file.path!).readAsBytes();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://back.kazakhiauto.kz/api/admin/uploadFile',
        ), // Replace with your backend URL
      );

      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: file.name),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['url']; // URL from your backend
      } else {
        print('Upload failed: ${response.statusCode}, $responseBody');
        _showMessage('Ошибка загрузки: ${response.statusCode}', isError: true);
        return null;
      }
    } catch (e) {
      print('Error uploading: $e');
      _showMessage('Ошибка загрузки файла: $e', isError: true);
      return null;
    }
  }

  // Enhanced upload methods with better error handling
  Future<String?> _uploadToServerWithRetry(
    PlatformFile file, {
    int maxRetries = 3,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final result = await _uploadToServer(file);
        if (result != null) {
          return result;
        }
      } catch (e) {
        log('Upload attempt $attempt failed for ${file.name}: $e');
        if (attempt == maxRetries) {
          _showMessage(
            'Не удалось загрузить файл ${file.name} после $maxRetries попыток.',
            isError: true,
          );
        } else {
          // Wait before retry
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }
    return null;
  }

  // Function to show the date picker
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != DateTime.tryParse(controller.text)) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildModalContent(context);
  }

  // Builds the content of the modal
  Widget _buildModalContent(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: BoxConstraints(
        maxWidth: 800,
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Modal Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F8F8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.shipmentData == null
                      ? 'Создать новую отправку'
                      : 'Редактировать отправку',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 30,
                    color: Color(0xFF888888),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  splashRadius: 20,
                ),
              ],
            ),
          ),
          // Modal Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //User selection section
                  _buildSectionHeader('Выбор пользователя'),
                  UserSearchWidget(
                    onSelected: (user) {
                      setState(() {
                        selectedUserId = user['_id'];
                        selectedUserEmail = user['email'];
                      });
                    },
                    initialUser:
                        (selectedUserEmail != null)
                            ? {
                              '_id': selectedUserId,
                              'email': selectedUserEmail,
                            }
                            : null,
                  ),
                  // Car Details Section
                  SizedBox(height: 22),

                  _buildSectionHeader('Детали автомобиля'),
                  _buildTwoColumnGrid([
                    _buildEditableField(
                      'VIN',
                      _vinController,
                      isRequired: true,
                    ),
                    _buildEditableField(
                      'Марка',
                      _brandController,
                      isRequired: true,
                    ),
                    _buildEditableField(
                      'Модель',
                      _modelController,
                      isRequired: true,
                    ),
                    _buildEditableField(
                      'Год',
                      _yearController,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                    ),
                  ]),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12),
                      const Text(
                        'Текущий статус',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF444444),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFCFCFC),
                        ),
                        icon: const Icon(Icons.arrow_drop_down),
                        // Используем _statusTranslations для отображения русских названий
                        items:
                            _statusOptions.map((String statusKey) {
                              return DropdownMenuItem<String>(
                                value: statusKey, // Value remains English
                                child: Text(
                                  _statusTranslations[statusKey] ?? statusKey,
                                ), // Display Russian
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedStatus = newValue; // Save English key
                            });
                          }
                        },
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                  _buildImageUploadSection(
                    label: 'Изображения автомобиля:',
                    existingImageUrls: _uploadedCarImageUrls,
                    pickedFiles: _pickedCarFiles,
                    onFilesPicked: (files) {
                      setState(() {
                        _pickedCarFiles = List<PickedFileItem>.from(files);
                      });
                    },
                    onRemovePickedFile: (uniqueId) {
                      setState(() {
                        _pickedCarFiles.removeWhere(
                          (item) => item.uniqueId == uniqueId,
                        );
                      });
                    },
                    onRemoveExistingImage: (index) {
                      setState(() {
                        _uploadedCarImageUrls.removeAt(index);
                      });
                    },
                  ),
                  const Divider(
                    height: 60,
                    thickness: 1,
                    color: Color(0xFFE0E0E0),
                  ),

                  // Financial Overview Section
                  _buildSectionHeader('Финансовый обзор'),
                  _buildGenericFileUploadSection(
                    label: 'Файлы счета (PDF):',
                    pickedFiles: _pickedInvoiceFiles,
                    existingFileUrls: _uploadedInvoiceFileUrls,
                    onFilesPicked: (files) {
                      setState(() {
                        _pickedInvoiceFiles = List<PickedFileItem>.from(files);
                      });
                    },
                    onRemovePickedFile: (uniqueId) {
                      setState(() {
                        _pickedInvoiceFiles.removeWhere(
                          (item) => item.uniqueId == uniqueId,
                        );
                      });
                    },
                    onRemoveExistingFile: (index) {
                      setState(() {
                        _uploadedInvoiceFileUrls.removeAt(index);
                      });
                    },
                    allowedExtensions: const ['pdf'],
                    uploadButtonLabel: 'Выбрать файл(ы) PDF',
                  ),

                  const Divider(
                    height: 60,
                    thickness: 1,
                    color: Color(0xFFE0E0E0),
                  ),
                  // NEW: Carfax PDF report section
                  _buildSectionHeader('Carfax PDF отчет'),
                  _buildGenericFileUploadSection(
                    label: 'Файлы отчета (PDF):',
                    pickedFiles: _pickedCarfaxFiles,
                    existingFileUrls: _uploadedCarfaxFileUrls,
                    onFilesPicked: (files) {
                      setState(() {
                        // Ensure only one file is selected for Carfax
                        _pickedCarfaxFiles = List<PickedFileItem>.from(files);
                      });
                    },
                    onRemovePickedFile: (uniqueId) {
                      setState(() {
                        _pickedCarfaxFiles.removeWhere(
                          (item) => item.uniqueId == uniqueId,
                        );
                      });
                    },
                    onRemoveExistingFile: (index) {
                      setState(() {
                        _uploadedCarfaxFileUrls.removeAt(index);
                      });
                    },
                    allowedExtensions: const ['pdf'],
                    uploadButtonLabel: 'Выбрать файл PDF',
                  ),
                  const Divider(
                    height: 60,
                    thickness: 1,
                    color: Color(0xFFE0E0E0),
                  ),
                  // Shipment & Port Details Section
                  _buildSectionHeader('Детали отправления и порта'),
                  _buildTwoColumnGrid([
                    _buildEditableField(
                      'Международный порт',
                      _internationalPortController,
                      isRequired: true,
                      hintText: 'напр., Лос-Анджелес',
                    ),
                    _buildEditableField(
                      'Порт получения',
                      _receivingPortController,
                      isRequired: true,
                      hintText: 'напр., Актау',
                    ),
                    _buildEditableField(
                      'Оплаченная сумма',
                      _paidController,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                    ),
                    _buildEditableField(
                      'Остаток к оплате',
                      _balanceController,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                    ),
                    _buildEditableField(
                      'Номер контейнера',
                      _containerNumberController,
                      hintText: 'напр., ABC1234567',
                    ),
                    _buildEditableField(
                      'Терминал',
                      _terminalController,
                      hintText: 'напр., Терминал 3',
                    ),
                    _buildDateField(
                      context,
                      'Дата открытия контейнера',
                      _containerOpenDateController,
                    ),
                    _buildDateField(
                      context,
                      'Зеленая дата',
                      _greenDateController,
                    ),
                    _buildDateField(
                      context,
                      'Дата входа контейнера',
                      _containerEntryDateController,
                    ),
                  ]),
                  _buildImageUploadSection(
                    label: 'Изображения порта:',
                    existingImageUrls: _uploadedPortImageUrls,
                    pickedFiles: _pickedPortFiles,
                    onFilesPicked: (files) {
                      setState(() {
                        _pickedPortFiles = List<PickedFileItem>.from(files);
                      });
                    },
                    onRemovePickedFile: (uniqueId) {
                      setState(() {
                        _pickedPortFiles.removeWhere(
                          (item) => item.uniqueId == uniqueId,
                        );
                      });
                    },
                    onRemoveExistingImage: (index) {
                      setState(() {
                        _uploadedPortImageUrls.removeAt(index);
                      });
                    },
                  ),
                  const Divider(
                    height: 60,
                    thickness: 1,
                    color: Color(0xFFE0E0E0),
                  ),

                  // NEW SECTION: Container Location
                  _buildSectionHeader('Локация контейнера'),
                  _buildEditableField(
                    'Название локации',
                    _locationNameController,
                    hintText: 'напр., Склад 2',
                  ),
                  _buildLocationImageUploadSection(
                    // NEW: Specific section for location images
                    label: 'Скриншоты локации:',
                    existingScreenShots: _uploadedLocationScreenShots,
                    pickedFiles: _pickedLocationScreenshots,
                    onFilesPicked: (files) {
                      setState(() {
                        _pickedLocationScreenshots = List<PickedFileItem>.from(
                          files,
                        );
                      });
                    },
                    onRemovePickedFile: (uniqueId) {
                      setState(() {
                        _pickedLocationScreenshots.removeWhere(
                          (item) => item.uniqueId == uniqueId,
                        );
                      });
                    },
                    onRemoveExistingScreenshot: (index) {
                      setState(() {
                        _uploadedLocationScreenShots.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // Modal Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F8F8),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border(
                top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildButton(
                  text: 'Отмена',
                  isPrimary: false,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 15),
                _buildButton(
                  text:
                      widget.shipmentData == null
                          ? 'Создать отправление'
                          : 'Сохранить изменения',
                  isPrimary: true,
                  onPressed: _submitShipment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets for building the form sections

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 50,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFF007BFF),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoColumnGrid(List<Widget> children) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 30,
        mainAxisSpacing: 20,
        childAspectRatio: 4,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF444444),
                fontSize: 15,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Color(0xFFDC3545), fontSize: 16),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2),
            ),
            fillColor: const Color(0xFFFCFCFC),
            filled: true,
          ),
          style: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF444444),
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(context, controller),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2),
            ),
            fillColor: const Color(0xFFFCFCFC),
            filled: true,
            suffixIcon: const Icon(
              Icons.calendar_today,
              color: Color(0xFF888888),
            ),
          ),
          style: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
        ),
      ],
    );
  }

  Widget _buildGenericFileUploadSection({
    required String label,
    required List<PickedFileItem> pickedFiles,
    required List<String> existingFileUrls,
    required Function(List<PickedFileItem>) onFilesPicked,
    required Function(String) onRemovePickedFile,
    Function(int)? onRemoveExistingFile, // Add this parameter
    List<String>? allowedExtensions,
    String uploadButtonLabel = 'Choose File(s)',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF444444),
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 15),
        // Display picked file names or existing URLs as links
        if (existingFileUrls.isNotEmpty || pickedFiles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                // Existing file URLs
                ...existingFileUrls.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final String fileUrl = entry.value;
                  final fileName = fileUrl.split('/').last;
                  return Container(
                    key: ValueKey(
                      'existing_$index',
                    ), // Use index for existing files
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.insert_drive_file,
                          size: 18,
                          color: Color(0xFF007BFF),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            _showMessage('Открытие файла: $fileUrl');
                          },
                          child: Text(
                            fileName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF007BFF),
                              decoration: TextDecoration.underline,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        // ADD: Remove button for existing files
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => onRemoveExistingFile?.call(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                // Newly picked local files with remove button
                ...pickedFiles.map((item) {
                  return Container(
                    key: ValueKey(
                      item.uniqueId,
                    ), // Use uniqueId for picked files
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.insert_drive_file,
                          size: 18,
                          color: Color(0xFF666666),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.file.name,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.red,
                          ),
                          onPressed: () => onRemovePickedFile(item.uniqueId),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        // File upload area
        GestureDetector(
          onTap: () async {
            // Logic to handle single file selection if needed
            final bool isSingleFile =
                allowedExtensions != null &&
                allowedExtensions.contains('pdf') &&
                uploadButtonLabel.contains('файл PDF');
            final result = await FilePicker.platform.pickFiles(
              allowMultiple: !isSingleFile,
              type:
                  allowedExtensions == null || allowedExtensions.isEmpty
                      ? FileType.any
                      : FileType.custom,
              allowedExtensions: allowedExtensions,
            );
            if (result != null && result.files.isNotEmpty) {
              final newPickedItems =
                  result.files.map((file) {
                    return PickedFileItem(file: file);
                  }).toList();

              // If it's a single-file uploader, replace existing files
              if (isSingleFile) {
                onFilesPicked(newPickedItems);
              } else {
                // Combine existing picked files with new ones
                final updatedFiles = [...pickedFiles, ...newPickedItems];
                onFilesPicked(updatedFiles);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFC0C0C0),
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFFDFDFD),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.upload_file,
                  size: 40,
                  color: Color(0xFF007BFF),
                ),
                const SizedBox(height: 10),
                Text(
                  uploadButtonLabel,
                  style: const TextStyle(
                    color: Color(0xFF007BFF),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Adjusted _buildImageUploadSection for general image handling
  Widget _buildImageUploadSection({
    required String label,
    required List<String> existingImageUrls,
    required List<PickedFileItem> pickedFiles,
    required Function(List<PickedFileItem>) onFilesPicked,
    required Function(String) onRemovePickedFile,
    Function(int)? onRemoveExistingImage, // Add this parameter
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF444444),
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 15),
        // Display both existing URLs and picked file names
        if (existingImageUrls.isNotEmpty || pickedFiles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                // Existing image previews (from URLs)
                ...existingImageUrls.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final String imageUrl = entry.value;
                  return Stack(
                    key: ValueKey(
                      'existing_image_$index',
                    ), // Use index for existing images
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          // FIX: Call onRemoveExistingImage with index for existing images
                          onTap: () => onRemoveExistingImage?.call(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                // Newly picked file previews
                ...pickedFiles.map((item) {
                  return Stack(
                    key: ValueKey(
                      item.uniqueId,
                    ), // Use uniqueId for picked files
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            item.file.bytes != null
                                ? Image.memory(
                                  item.file.bytes!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                                : (item.file.path != null
                                    ? Image.file(
                                      File(item.file.path!),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                    : Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFE0E0E0),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Нет предварительного просмотра',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    )),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          // This is correct for picked files
                          onTap: () => onRemovePickedFile(item.uniqueId),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        // File upload area
        GestureDetector(
          onTap: () async {
            final result = await FilePicker.platform.pickFiles(
              allowMultiple: true,
              type: FileType.image,
            );
            if (result != null) {
              final newPickedItems =
                  result.files.map((file) {
                    return PickedFileItem(file: file);
                  }).toList();
              // Combine existing picked files with new ones
              final updatedFiles = [...pickedFiles, ...newPickedItems];
              onFilesPicked(updatedFiles);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFC0C0C0),
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFFDFDFD),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_upload,
                  size: 40,
                  color: Color(0xFF007BFF),
                ),
                const SizedBox(height: 10),
                Text(
                  'Загрузить ${label.replaceAll(':', '')}',
                  style: const TextStyle(
                    color: Color(0xFF007BFF),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // NEW: Dedicated widget for Location Screenshots, handles Map<String, dynamic> existing data
  Widget _buildLocationImageUploadSection({
    required String label,
    required List<Map<String, dynamic>> existingScreenShots,
    required List<PickedFileItem> pickedFiles,
    required Function(List<PickedFileItem>) onFilesPicked,
    required Function(String) onRemovePickedFile,
    required Function(int) onRemoveExistingScreenshot,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF444444),
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 15),
        if (existingScreenShots.isNotEmpty || pickedFiles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                // Existing location screenshots
                ...existingScreenShots.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final Map<String, dynamic> screenshot = entry.value;
                  final String? imageUrl = screenshot["url"];
                  final String? locationName = screenshot["locationName"];
                  final String displayLabel =
                      locationName != null && locationName.isNotEmpty
                          ? '$locationName'
                          : 'Скриншот'; // Default label if name is missing

                  return Stack(
                    key: ValueKey('existing_location_screenshot_$index'),
                    children: [
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                imageUrl != null && imageUrl.isNotEmpty
                                    ? Image.network(
                                      imageUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFFE0E0E0,
                                                    ),
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                    )
                                    : Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFE0E0E0),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Нет URL',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => onRemoveExistingScreenshot(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),

                // Newly picked location screenshot previews
                ...pickedFiles.map((item) {
                  return Stack(
                    key: ValueKey(item.uniqueId),
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            item.file.bytes != null
                                ? Image.memory(
                                  item.file.bytes!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                                : (item.file.path != null
                                    ? Image.file(
                                      File(item.file.path!),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                    : Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFE0E0E0),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Нет предварительного просмотра',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    )),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => onRemovePickedFile(item.uniqueId),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        // File upload area
        GestureDetector(
          onTap: () async {
            if (_locationNameController.text.isEmpty) {
              _showMessage(
                'Пожалуйста, введите название локации перед загрузкой скриншотов.',
                isError: true,
              );
              return;
            }
            final result = await FilePicker.platform.pickFiles(
              allowMultiple: true,
              type: FileType.image,
            );
            if (result != null) {
              final newPickedItems =
                  result.files.map((file) {
                    return PickedFileItem(file: file);
                  }).toList();
              final updatedFiles = [...pickedFiles, ...newPickedItems];
              onFilesPicked(updatedFiles);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFC0C0C0),
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFFDFDFD),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_upload,
                  size: 40,
                  color: Color(0xFF007BFF),
                ),
                const SizedBox(height: 10),
                Text(
                  'Загрузить ${label.replaceAll(':', '')}',
                  style: const TextStyle(
                    color: Color(0xFF007BFF),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_locationNameController.text.isEmpty && pickedFiles.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Введите название локации перед загрузкой скриншотов.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Future<String?> _uploadFile(PlatformFile file) async {
    // If it's an image, use the _uploadToServer logic
    if (file.extension?.toLowerCase().contains('jpg') == true ||
        file.extension?.toLowerCase().contains('jpeg') == true ||
        file.extension?.toLowerCase().contains('png') == true ||
        file.extension?.toLowerCase().contains('gif') == true) {
      return await _uploadToServerWithRetry(file);
    } else if (file.extension?.toLowerCase() == 'pdf') {
      _showMessage(
        'Файлы PDF имитируются для загрузки. Интегрируйте с подходящим сервисом хостинга PDF.',
        isError: false,
      );
      // Simulate a successful upload with a placeholder URL for demonstration
      try {
        final bytes =
            kIsWeb ? file.bytes! : await File(file.path!).readAsBytes();

        final request = http.MultipartRequest(
          'POST',
          Uri.parse(
            'https://back.kazakhiauto.kz/api/admin/uploadFile',
          ), // Replace with your backend URL
        );

        request.files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: file.name),
        );

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final data = jsonDecode(responseBody);
          return data['url']; // URL from your backend
        } else {
          print('Upload failed: ${response.statusCode}, $responseBody');
          _showMessage(
            'Ошибка загрузки: ${response.statusCode}',
            isError: true,
          );
          return null;
        }
      } catch (e) {
        print('Error uploading: $e');
        _showMessage('Ошибка загрузки файла: $e', isError: true);
        return null;
      }
    } else {
      _showMessage(
        'Неподдерживаемый тип файла: ${file.extension}. Только симуляция.',
        isError: true,
      );
      return null;
    }
  }

  Widget _buildButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isPrimary ? const Color(0xFF28A745) : const Color(0xFFE0E0E0),
        foregroundColor: isPrimary ? Colors.white : const Color(0xFF333333),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
        shadowColor:
            isPrimary
                ? const Color(0xFF28A745).withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color?>((
          Set<MaterialState> states,
        ) {
          if (states.contains(MaterialState.hovered)) {
            return isPrimary
                ? const Color(0xFF218838)
                : const Color(0xFFD0D0D0);
          }
          return null;
        }),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    );
  }
}
