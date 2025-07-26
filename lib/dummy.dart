import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taptrade/Utills/appColors.dart';

class ImagePickerCropperExample extends StatefulWidget {
  @override
  _ImagePickerCropperExampleState createState() => _ImagePickerCropperExampleState();
}

class _ImagePickerCropperExampleState extends State<ImagePickerCropperExample> {
  final ImagePicker _picker = ImagePicker();

  CroppedFile? _croppedFile;

  // Function to pick and crop the image
  Future<void> _pickAndCropImage() async {
    // Step 1: Pick an image
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage == null) return;

    // Step 2: Crop the image with a fixed aspect ratio
    // final CroppedFile? croppedFile = await ImageCropper().cropImage(
    //   sourcePath: pickedImage.path,
    //   aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3), // Define aspect ratio
    //   uiSettings: [
    //     AndroidUiSettings(
    //       toolbarTitle: 'Crop Image',
    //       toolbarColor: Colors.blue,
    //       toolbarWidgetColor: Colors.white,
    //       lockAspectRatio: true, // Lock the aspect ratio
    //     ),
    //     IOSUiSettings(
    //       title: 'Crop Image',
    //       aspectRatioLockEnabled: true, // Lock aspect ratio on iOS
    //     ),
    //   ],
    // );580 x 435
    // final File? resize = await resizeImage(pickedImage,400, 400);
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPresetCustom(),
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPresetCustom(), // IMPORTANT: iOS supports only one custom aspect ratio in preset list
          ],
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _croppedFile = croppedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick and Crop Image")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the cropped image if available
            if (_croppedFile != null)
              Image.file(File(_croppedFile!.path)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickAndCropImage,
              child: const Text("Pick and Crop Image"),
            ),
          ],
        ),
      ),
    );
  }
}

Future<File?> resizeImage(XFile pickedFile, int width, int height) async {
  if (pickedFile == null) return null;

  // Load the image from the file
  final File file = File(pickedFile.path);
  final img.Image? image = img.decodeImage(await file.readAsBytes());

  if (image == null) return null;

  // Resize the image
  final img.Image resizedImage = img.copyResize(image, width: width, height: height);

  // Save the resized image to a file
  final File resizedFile = File('${file.parent.path}/resized_image.png')
    ..writeAsBytesSync(img.encodePng(resizedImage));

  return resizedFile;
}

Future<File?> cropImage(BuildContext context,XFile pickedFile) async {
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: pickedFile.path,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
          CropAspectRatioPresetCustom(),
        ],
      ),
      IOSUiSettings(
        title: 'Cropper',
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPresetCustom(), // IMPORTANT: iOS supports only one custom aspect ratio in preset list
        ],
      ),
      WebUiSettings(
        context: context,
      ),
    ],
  );
  if(croppedFile == null) return null;
  File croppedImage = File(croppedFile.path);

  return croppedImage;
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}


// Example usage:
// final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
// final File? resizedImage = await resizeImage(pickedImage!, 800, 600); // Fix resolution to 800x600



// Future<File?> cropNewImage(BuildContext context, XFile pickedFile) async {
//   // Step 1: Preprocess the image (add padding to fit fixed dimensions)
//   File paddedFile = await _addPaddingToImage(File(pickedFile.path), 00, 900); // Fixed 2x3 dimensions
//
//   // Step 2: Open the cropping tool
//   CroppedFile? croppedFile = await ImageCropper().cropImage(
//     sourcePath: paddedFile.path,
//     uiSettings: [
//       AndroidUiSettings(
//         toolbarTitle: 'Cropper',
//         toolbarColor: Colors.deepOrange,
//         toolbarWidgetColor: Colors.white,
//         aspectRatioPresets: [
//           CropAspectRatioPreset.original,
//           CropAspectRatioPreset.square,
//           CropAspectRatioPreset.ratio3x2,
//           CropAspectRatioPreset.ratio4x3,
//           CropAspectRatioPreset.ratio16x9,
//           CropAspectRatioPresetCustom(),
//         ],
//       ),
//       IOSUiSettings(
//         title: 'Cropper',
//         aspectRatioPresets: [
//           CropAspectRatioPreset.original,
//           CropAspectRatioPreset.square,
//           CropAspectRatioPresetCustom(),
//         ],
//       ),
//       WebUiSettings(
//         context: context,
//       ),
//     ],
//   );
//
//   if (croppedFile == null) return null;
//   File croppedImage = File(croppedFile.path);
//
//   return croppedImage;
// }
//
// Future<File> _addPaddingToImage(File file, int targetWidth, int targetHeight) async {
//   // Load the image
//   final img.Image? originalImage = img.decodeImage(await file.readAsBytes());
//   if (originalImage == null) throw Exception("Unable to decode image");
//
//   // Use copyExpandCanvas to expand the canvas and add padding
//   final img.Image paddedImage = img.copyExpandCanvas(
//     originalImage,
//     newWidth: targetWidth,
//     newHeight: targetHeight,
//     padding: 20, // Optional padding to add around the image
//     position: img.ExpandCanvasPosition.center, // Positioning the original image at the center
//     // backgroundColor: Color.fromRGBO(255, 255, 255,0.5), // Background color (white)
//   );
//
//   // Save the padded image as a new file
//   final paddedFile = File('${file.parent.path}/padded_image.png')
//     ..writeAsBytesSync(img.encodePng(paddedImage));
//
//   return paddedFile;
// }

// Function to add padding to the image
// Future<File> _addPaddingToImage(File file, int targetWidth, int targetHeight) async {
//   // Load the image
//   final img.Image? originalImage = img.decodeImage(await file.readAsBytes());
//   if (originalImage == null) throw Exception("Unable to decode image");
//
//   // Create a blank canvas with the target dimensions
//   final img.Image paddedImage = img.Image(width: targetWidth, height: targetHeight);
//
//   // Fill the canvas with a background color (e.g., white or transparent)
//   img.fill(paddedImage, color: img.getColor(255, 255, 255, 255)); // White background
//
//   // Calculate the center position to place the original image
//   final int offsetX = (targetWidth - originalImage.width) ~/ 2;
//   final int offsetY = (targetHeight - originalImage.height) ~/ 2;
//
//   // Draw the original image on the canvas
//   img.copyInto(paddedImage, originalImage, dstX: offsetX, dstY: offsetY);
//
//   // Save the padded image as a new file
//   final paddedFile = File('${file.parent.path}/padded_image.png')
//     ..writeAsBytesSync(img.encodePng(paddedImage));
//
//   return paddedFile;
// }





Future<File?> resizeAndCropImage(XFile pickedFile, int width, int height) async {
  // final File? resizedFile = await resizeImage(pickedFile,width, height);
  final File? resizedFile = File(pickedFile.path);
  final croppedFile = await newCropImage(resizedFile!);
  return croppedFile;
}

Future<File?> newCropImage(File imageFile) async {
  final ImageCropper imageCropper = ImageCropper();

  // Crop the image using ImageCropper package
  final CroppedFile? croppedFile = await imageCropper.cropImage(
    sourcePath: imageFile.path,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: AppColors.secondaryColor,
        toolbarWidgetColor: AppColors.primaryTextColor,
        lockAspectRatio: false,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
          CropAspectRatioPreset.original,
          CropAspectRatioPresetCustom(),
        ],
      ),
      IOSUiSettings(
        title: 'Cropper',
        minimumAspectRatio: 1.0,
        aspectRatioLockEnabled: true,
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPresetCustom(),
        ],
      ),
    ],
  );

  // If the image was cropped successfully, return the cropped image file
  if (croppedFile != null) {
    return File(croppedFile.path);
  }

  return null;
}

class CropAspectRatioPresetCustomLast implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 2);

  @override
  String get name => '2x3 (customized)';
}
